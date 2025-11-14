/**
 * @description Generates shopping lists from meal plans by aggregating ingredients
 * - Creates shopping lists organized by store (Publix, Walmart, Costco)
 * - Aggregates ingredients across all meals in the plan
 * - Calculates quantities for specified number of people
 * - Categories items for easier shopping
 */
public with sharing class ShoppingListGenerator {

    /**
     * @description Generates shopping lists for a meal plan
     * @param mealPlanId The Weekly_Meal_Plan__c record ID
     * @return List of Shopping_List__c IDs created
     */
    public static List<Id> generateShoppingLists(Id mealPlanId) {
        // Get meal plan details
        Weekly_Meal_Plan__c mealPlan = [
            SELECT Id, Name, Number_of_People__c, Week_Start_Date__c, Week_End_Date__c
            FROM Weekly_Meal_Plan__c
            WHERE Id = :mealPlanId
        ];

        // Get all planned meals with ingredients
        List<Planned_Meal__c> plannedMeals = [
            SELECT Id, Meal__c, Meal__r.Name, Servings__c,
                   Meal__r.Servings__c
            FROM Planned_Meal__c
            WHERE Weekly_Meal_Plan__c = :mealPlanId
        ];

        if (plannedMeals.isEmpty()) {
            return new List<Id>();
        }

        // Get all meal IDs
        Set<Id> mealIds = new Set<Id>();
        for (Planned_Meal__c pm : plannedMeals) {
            mealIds.add(pm.Meal__c);
        }

        // Get ingredients for all meals
        List<Meal_Ingredient__c> allIngredients = [
            SELECT Id, Meal__c, Ingredient_Name__c, Quantity__c, Unit__c,
                   Category__c, Estimated_Price__c, Is_Pantry_Staple__c
            FROM Meal_Ingredient__c
            WHERE Meal__c IN :mealIds
        ];

        // Aggregate ingredients by store
        Map<String, Map<String, AggregatedIngredient>> ingredientsByStore =
            aggregateIngredients(allIngredients, plannedMeals, mealPlan.Number_of_People__c);

        // Create shopping lists for each store
        List<Shopping_List__c> shoppingLists = new List<Shopping_List__c>();
        List<String> stores = new List<String>{'Publix', 'Walmart', 'Costco'};

        for (String store : stores) {
            if (ingredientsByStore.containsKey(store) && !ingredientsByStore.get(store).isEmpty()) {
                Shopping_List__c shoppingList = new Shopping_List__c(
                    Weekly_Meal_Plan__c = mealPlanId,
                    Store__c = store,
                    Shopping_Date__c = mealPlan.Week_Start_Date__c,
                    Status__c = 'Draft'
                );
                shoppingLists.add(shoppingList);
            }
        }

        if (shoppingLists.isEmpty()) {
            return new List<Id>();
        }

        insert shoppingLists;

        // Create shopping list items
        List<Shopping_List_Item__c> allItems = new List<Shopping_List_Item__c>();

        for (Shopping_List__c shoppingList : shoppingLists) {
            String store = shoppingList.Store__c;
            Map<String, AggregatedIngredient> storeIngredients = ingredientsByStore.get(store);

            if (storeIngredients != null) {
                for (AggregatedIngredient aggIngredient : storeIngredients.values()) {
                    // Truncate long ingredient names to fit field length (max 120 chars)
                    String itemName = aggIngredient.name;
                    if (itemName != null && itemName.length() > 120) {
                        itemName = itemName.substring(0, 117) + '...';
                    }

                    Shopping_List_Item__c item = new Shopping_List_Item__c(
                        Shopping_List__c = shoppingList.Id,
                        Item_Name__c = itemName,
                        Quantity__c = aggIngredient.totalQuantity.round(System.RoundingMode.UP),
                        Unit__c = aggIngredient.unit,
                        Category__c = aggIngredient.category,
                        Store__c = store,
                        Estimated_Price__c = aggIngredient.estimatedPrice,
                        Is_Purchased__c = false
                    );
                    allItems.add(item);
                }
            }
        }

        if (!allItems.isEmpty()) {
            insert allItems;
        }

        // Return shopping list IDs
        List<Id> shoppingListIds = new List<Id>();
        for (Shopping_List__c sl : shoppingLists) {
            shoppingListIds.add(sl.Id);
        }

        return shoppingListIds;
    }

    /**
     * @description Aggregates ingredients across meals and scales for number of people
     */
    private static Map<String, Map<String, AggregatedIngredient>> aggregateIngredients(
        List<Meal_Ingredient__c> ingredients,
        List<Planned_Meal__c> plannedMeals,
        Decimal numberOfPeople
    ) {
        // Map meal ID to serving adjustment ratio
        Map<Id, Decimal> servingRatios = new Map<Id, Decimal>();
        for (Planned_Meal__c pm : plannedMeals) {
            if (pm.Meal__r.Servings__c != null && pm.Meal__r.Servings__c > 0) {
                servingRatios.put(pm.Meal__c, numberOfPeople / pm.Meal__r.Servings__c);
            }
        }

        // Aggregate by store and ingredient name
        Map<String, Map<String, AggregatedIngredient>> result = new Map<String, Map<String, AggregatedIngredient>>();

        for (Meal_Ingredient__c ingredient : ingredients) {
            // Determine best store (simplified - could be enhanced with pricing logic)
            String store = determineBestStore(ingredient);

            if (!result.containsKey(store)) {
                result.put(store, new Map<String, AggregatedIngredient>());
            }

            Map<String, AggregatedIngredient> storeIngredients = result.get(store);
            String key = ingredient.Ingredient_Name__c + '|' + ingredient.Unit__c;

            // Special handling for pantry staples - list once, don't aggregate quantities
            if (ingredient.Is_Pantry_Staple__c == true) {
                if (!storeIngredients.containsKey(key)) {
                    AggregatedIngredient newAgg = new AggregatedIngredient();
                    newAgg.name = ingredient.Ingredient_Name__c;
                    newAgg.unit = 'each';
                    newAgg.category = ingredient.Category__c != null ? ingredient.Category__c : 'Pantry';
                    newAgg.totalQuantity = 1;
                    newAgg.estimatedPrice = 0;
                    storeIngredients.put(key, newAgg);
                }
                // Skip if already added - pantry staples are listed once only
                continue;
            }

            // Regular ingredient aggregation (non-staples)
            Decimal scalingFactor = servingRatios.get(ingredient.Meal__c);
            if (scalingFactor == null) {
                scalingFactor = 1.0;
            }

            Decimal adjustedQuantity = ingredient.Quantity__c * scalingFactor;

            if (storeIngredients.containsKey(key)) {
                // Add to existing
                AggregatedIngredient existing = storeIngredients.get(key);
                existing.totalQuantity += adjustedQuantity;
                existing.estimatedPrice += (ingredient.Estimated_Price__c != null ? ingredient.Estimated_Price__c * scalingFactor : 0);
            } else {
                // Create new
                AggregatedIngredient newAgg = new AggregatedIngredient();
                newAgg.name = ingredient.Ingredient_Name__c;
                newAgg.unit = ingredient.Unit__c;
                newAgg.category = ingredient.Category__c != null ? ingredient.Category__c : 'Pantry';
                newAgg.totalQuantity = adjustedQuantity;
                newAgg.estimatedPrice = ingredient.Estimated_Price__c != null ? ingredient.Estimated_Price__c * scalingFactor : 0;
                storeIngredients.put(key, newAgg);
            }
        }

        return result;
    }

    /**
     * @description Determines best store for ingredient (simplified logic)
     */
    private static String determineBestStore(Meal_Ingredient__c ingredient) {
        // Simplified: distribute items across stores
        // In production, this would use pricing data and store inventory
        String category = ingredient.Category__c;

        if (category == 'Meat & Seafood' || category == 'Frozen') {
            return 'Costco'; // Bulk items
        } else if (category == 'Produce' || category == 'Dairy') {
            return 'Publix'; // Fresh items
        } else {
            return 'Walmart'; // Pantry staples
        }
    }

    /**
     * @description Invocable method for Flow integration
     */
    @InvocableMethod(label='Generate Shopping Lists' description='Creates shopping lists from meal plan')
    public static List<ShoppingListResult> generateShoppingListsFromFlow(List<Id> mealPlanIds) {
        List<ShoppingListResult> results = new List<ShoppingListResult>();

        for (Id mealPlanId : mealPlanIds) {
            List<Id> shoppingListIds = generateShoppingLists(mealPlanId);

            ShoppingListResult result = new ShoppingListResult();
            result.mealPlanId = mealPlanId;
            result.shoppingListIds = shoppingListIds;
            result.success = true;
            results.add(result);
        }

        return results;
    }

    /**
     * @description Inner class for aggregating ingredients
     */
    private class AggregatedIngredient {
        public String name;
        public String unit;
        public String category;
        public Decimal totalQuantity = 0;
        public Decimal estimatedPrice = 0;
    }

    /**
     * @description Output wrapper for Flow invocable method
     */
    public class ShoppingListResult {
        @InvocableVariable(label='Meal Plan ID')
        public Id mealPlanId;

        @InvocableVariable(label='Shopping List IDs')
        public List<Id> shoppingListIds;

        @InvocableVariable(label='Success')
        public Boolean success;
    }
}

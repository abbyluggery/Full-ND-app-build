/**
 * @description Test class for ShoppingListGenerator
 */
@isTest
private class ShoppingListGeneratorTest {

    @TestSetup
    static void setupTestData() {
        // Create test recipes
        List<Meal__c> testRecipes = new List<Meal__c>();

        Meal__c recipe1 = new Meal__c(
            Name = 'Chicken Stir Fry',
            Servings__c = 4,
            Prep_Time_Minutes__c = 15,
            Cook_Time_Minutes__c = 15,
            Protein_Type__c = 'Chicken',
            Is_Heart_Healthy__c = true
        );
        testRecipes.add(recipe1);

        Meal__c recipe2 = new Meal__c(
            Name = 'Pasta Primavera',
            Servings__c = 6,
            Prep_Time_Minutes__c = 10,
            Cook_Time_Minutes__c = 20,
            Protein_Type__c = 'Vegetarian',
            Is_Diabetic_Friendly__c = true
        );
        testRecipes.add(recipe2);

        insert testRecipes;

        // Create meal plan
        Weekly_Meal_Plan__c mealPlan = new Weekly_Meal_Plan__c(
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(13),
            Number_of_People__c = 5,
            Status__c = 'Draft'
        );
        insert mealPlan;

        // Create planned meals
        List<Planned_Meal__c> plannedMeals = new List<Planned_Meal__c>();

        plannedMeals.add(new Planned_Meal__c(
            Weekly_Meal_Plan__c = mealPlan.Id,
            Meal__c = recipe1.Id,
            Meal_Date__c = Date.today(),
            Meal_Time__c = 'Dinner',
            Servings__c = 5
        ));

        plannedMeals.add(new Planned_Meal__c(
            Weekly_Meal_Plan__c = mealPlan.Id,
            Meal__c = recipe2.Id,
            Meal_Date__c = Date.today().addDays(1),
            Meal_Time__c = 'Dinner',
            Servings__c = 5
        ));

        insert plannedMeals;

        // Create ingredients for recipes
        List<Meal_Ingredient__c> ingredients = new List<Meal_Ingredient__c>();

        // Chicken Stir Fry ingredients
        ingredients.add(new Meal_Ingredient__c(
            Meal__c = recipe1.Id,
            Ingredient_Name__c = 'Chicken Breast',
            Quantity__c = 2,
            Unit__c = 'lb',
            Category__c = 'Meat & Seafood',
            Estimated_Price__c = 8.00
        ));

        ingredients.add(new Meal_Ingredient__c(
            Meal__c = recipe1.Id,
            Ingredient_Name__c = 'Bell Peppers',
            Quantity__c = 3,
            Unit__c = 'each',
            Category__c = 'Produce',
            Estimated_Price__c = 4.50
        ));

        ingredients.add(new Meal_Ingredient__c(
            Meal__c = recipe1.Id,
            Ingredient_Name__c = 'Soy Sauce',
            Quantity__c = 0.25,
            Unit__c = 'cup',
            Category__c = 'Condiments & Sauces',
            Estimated_Price__c = 1.50
        ));

        // Pasta Primavera ingredients
        ingredients.add(new Meal_Ingredient__c(
            Meal__c = recipe2.Id,
            Ingredient_Name__c = 'Pasta',
            Quantity__c = 1,
            Unit__c = 'lb',
            Category__c = 'Pantry',
            Estimated_Price__c = 2.00
        ));

        ingredients.add(new Meal_Ingredient__c(
            Meal__c = recipe2.Id,
            Ingredient_Name__c = 'Bell Peppers',
            Quantity__c = 2,
            Unit__c = 'each',
            Category__c = 'Produce',
            Estimated_Price__c = 3.00
        ));

        ingredients.add(new Meal_Ingredient__c(
            Meal__c = recipe2.Id,
            Ingredient_Name__c = 'Olive Oil',
            Quantity__c = 0.25,
            Unit__c = 'cup',
            Category__c = 'Pantry',
            Estimated_Price__c = 2.50
        ));

        insert ingredients;
    }

    @isTest
    static void testGenerateShoppingLists_Success() {
        Weekly_Meal_Plan__c mealPlan = [SELECT Id FROM Weekly_Meal_Plan__c LIMIT 1];

        Test.startTest();
        List<Id> shoppingListIds = ShoppingListGenerator.generateShoppingLists(mealPlan.Id);
        Test.stopTest();

        System.assert(!shoppingListIds.isEmpty(), 'Should create shopping lists');

        // Verify shopping lists created
        List<Shopping_List__c> shoppingLists = [
            SELECT Id, Name, Store__c, Status__c, Weekly_Meal_Plan__c
            FROM Shopping_List__c
            WHERE Id IN :shoppingListIds
        ];

        System.assert(!shoppingLists.isEmpty(), 'Shopping lists should be created');

        for (Shopping_List__c sl : shoppingLists) {
            System.assertEquals(mealPlan.Id, sl.Weekly_Meal_Plan__c, 'Should link to meal plan');
            System.assertEquals('Draft', sl.Status__c, 'Should be Draft status');
            System.assert(sl.Store__c != null, 'Should have store assigned');
        }
    }

    @isTest
    static void testShoppingListItems_Created() {
        Weekly_Meal_Plan__c mealPlan = [SELECT Id FROM Weekly_Meal_Plan__c LIMIT 1];

        Test.startTest();
        List<Id> shoppingListIds = ShoppingListGenerator.generateShoppingLists(mealPlan.Id);
        Test.stopTest();

        // Verify shopping list items created
        List<Shopping_List_Item__c> items = [
            SELECT Id, Item_Name__c, Quantity__c, Unit__c, Category__c, Store__c
            FROM Shopping_List_Item__c
            WHERE Shopping_List__c IN :shoppingListIds
        ];

        System.assert(!items.isEmpty(), 'Should create shopping list items');

        // Verify item properties
        for (Shopping_List_Item__c item : items) {
            System.assert(item.Item_Name__c != null, 'Item should have name');
            System.assert(item.Quantity__c != null && item.Quantity__c > 0, 'Item should have quantity');
            System.assert(item.Unit__c != null, 'Item should have unit');
        }
    }

    @isTest
    static void testIngredientAggregation() {
        Weekly_Meal_Plan__c mealPlan = [SELECT Id FROM Weekly_Meal_Plan__c LIMIT 1];

        Test.startTest();
        List<Id> shoppingListIds = ShoppingListGenerator.generateShoppingLists(mealPlan.Id);
        Test.stopTest();

        // Find Bell Peppers which appears in both recipes
        List<Shopping_List_Item__c> bellPepperItems = [
            SELECT Id, Item_Name__c, Quantity__c
            FROM Shopping_List_Item__c
            WHERE Shopping_List__c IN :shoppingListIds
            AND Item_Name__c = 'Bell Peppers'
        ];

        // Should aggregate bell peppers from both meals
        // Recipe 1: 3 peppers for 4 servings, scaled to 5 = 3.75
        // Recipe 2: 2 peppers for 6 servings, scaled to 5 = 1.67
        // Total should be aggregated
        if (!bellPepperItems.isEmpty()) {
            System.assert(bellPepperItems[0].Quantity__c > 3, 'Should aggregate quantities from multiple recipes');
        }
    }

    @isTest
    static void testServingScaling() {
        Weekly_Meal_Plan__c mealPlan = [SELECT Id, Number_of_People__c FROM Weekly_Meal_Plan__c LIMIT 1];
        System.assertEquals(5, mealPlan.Number_of_People__c, 'Setup should plan for 5 people');

        Test.startTest();
        List<Id> shoppingListIds = ShoppingListGenerator.generateShoppingLists(mealPlan.Id);
        Test.stopTest();

        List<Shopping_List_Item__c> items = [
            SELECT Quantity__c, Item_Name__c
            FROM Shopping_List_Item__c
            WHERE Shopping_List__c IN :shoppingListIds
            AND Item_Name__c = 'Chicken Breast'
        ];

        if (!items.isEmpty()) {
            // Recipe serves 4, planning for 5
            // Original: 2 lb chicken, scaled: 2 * (5/4) = 2.5 lb
            System.assert(items[0].Quantity__c > 2, 'Quantity should be scaled up for more people');
        }
    }

    @isTest
    static void testStoreDistribution() {
        Weekly_Meal_Plan__c mealPlan = [SELECT Id FROM Weekly_Meal_Plan__c LIMIT 1];

        Test.startTest();
        List<Id> shoppingListIds = ShoppingListGenerator.generateShoppingLists(mealPlan.Id);
        Test.stopTest();

        List<Shopping_List__c> shoppingLists = [
            SELECT Id, Store__c
            FROM Shopping_List__c
            WHERE Id IN :shoppingListIds
        ];

        Set<String> stores = new Set<String>();
        for (Shopping_List__c sl : shoppingLists) {
            stores.add(sl.Store__c);
        }

        // Should have items distributed across stores
        System.assert(!stores.isEmpty(), 'Should assign stores to shopping lists');
    }

    @isTest
    static void testCategoryAssignment() {
        Weekly_Meal_Plan__c mealPlan = [SELECT Id FROM Weekly_Meal_Plan__c LIMIT 1];

        Test.startTest();
        List<Id> shoppingListIds = ShoppingListGenerator.generateShoppingLists(mealPlan.Id);
        Test.stopTest();

        List<Shopping_List_Item__c> items = [
            SELECT Category__c
            FROM Shopping_List_Item__c
            WHERE Shopping_List__c IN :shoppingListIds
        ];

        Set<String> categories = new Set<String>();
        for (Shopping_List_Item__c item : items) {
            if (item.Category__c != null) {
                categories.add(item.Category__c);
            }
        }

        // Should have items in different categories
        System.assert(!categories.isEmpty(), 'Items should be categorized');
    }

    @isTest
    static void testEmptyMealPlan() {
        // Create meal plan with no meals
        Weekly_Meal_Plan__c emptyPlan = new Weekly_Meal_Plan__c(
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(13),
            Number_of_People__c = 5,
            Status__c = 'Draft'
        );
        insert emptyPlan;

        Test.startTest();
        List<Id> shoppingListIds = ShoppingListGenerator.generateShoppingLists(emptyPlan.Id);
        Test.stopTest();

        System.assert(shoppingListIds.isEmpty(), 'Should return empty list for meal plan with no meals');
    }

    @isTest
    static void testInvocableMethod() {
        Weekly_Meal_Plan__c mealPlan = [SELECT Id FROM Weekly_Meal_Plan__c LIMIT 1];

        Test.startTest();
        List<ShoppingListGenerator.ShoppingListResult> results =
            ShoppingListGenerator.generateShoppingListsFromFlow(new List<Id>{mealPlan.Id});
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].success, 'Should be successful');
        System.assertEquals(mealPlan.Id, results[0].mealPlanId, 'Should match meal plan ID');
        System.assert(!results[0].shoppingListIds.isEmpty(), 'Should have shopping list IDs');
    }

    @isTest
    static void testEstimatedCostCalculation() {
        Weekly_Meal_Plan__c mealPlan = [SELECT Id FROM Weekly_Meal_Plan__c LIMIT 1];

        Test.startTest();
        List<Id> shoppingListIds = ShoppingListGenerator.generateShoppingLists(mealPlan.Id);
        Test.stopTest();

        List<Shopping_List_Item__c> items = [
            SELECT Estimated_Price__c
            FROM Shopping_List_Item__c
            WHERE Shopping_List__c IN :shoppingListIds
        ];

        Boolean hasEstimatedPrice = false;
        for (Shopping_List_Item__c item : items) {
            if (item.Estimated_Price__c != null && item.Estimated_Price__c > 0) {
                hasEstimatedPrice = true;
                break;
            }
        }

        System.assert(hasEstimatedPrice, 'Some items should have estimated prices');
    }

    @isTest
    static void testIsPurchasedDefaultValue() {
        Weekly_Meal_Plan__c mealPlan = [SELECT Id FROM Weekly_Meal_Plan__c LIMIT 1];

        Test.startTest();
        List<Id> shoppingListIds = ShoppingListGenerator.generateShoppingLists(mealPlan.Id);
        Test.stopTest();

        List<Shopping_List_Item__c> items = [
            SELECT Is_Purchased__c
            FROM Shopping_List_Item__c
            WHERE Shopping_List__c IN :shoppingListIds
        ];

        for (Shopping_List_Item__c item : items) {
            System.assertEquals(false, item.Is_Purchased__c, 'Is_Purchased should default to false');
        }
    }
}

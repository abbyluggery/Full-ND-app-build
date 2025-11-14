/**
 * Anonymous Apex script to parse ingredients for all meals
 * Run this via Developer Console or Salesforce CLI
 *
 * Usage:
 * sf apex run --file scripts/parse_all_meal_ingredients.apex --target-org abbyluggery179@agentforce.com
 */

// Get all meals with ingredient text
List<Meal__c> meals = [
    SELECT Id, Name, Ingredients__c
    FROM Meal__c
    LIMIT 50000
];

System.debug('Found ' + meals.size() + ' total meals');

// Filter meals that have ingredients
Set<Id> mealIds = new Set<Id>();
Integer mealsWithIngredients = 0;

for (Meal__c meal : meals) {
    if (String.isNotBlank(meal.Ingredients__c)) {
        mealIds.add(meal.Id);
        mealsWithIngredients++;
    }
}

System.debug('Meals with ingredients: ' + mealsWithIngredients);

if (mealIds.isEmpty()) {
    System.debug('No meals found with ingredient text. Nothing to parse.');
} else {
    System.debug('Parsing ingredients for ' + mealIds.size() + ' meals...');

    try {
        Integer ingredientCount = IngredientParser.parseIngredientsForMeals(mealIds);
        System.debug('✅ SUCCESS! Created ' + ingredientCount + ' ingredient records');

        // Show sample ingredients
        List<Meal_Ingredient__c> sampleIngredients = [
            SELECT Id, Meal__r.Name, Ingredient_Name__c, Quantity__c, Unit__c, Category__c
            FROM Meal_Ingredient__c
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];

        System.debug('\n=== SAMPLE INGREDIENTS (Latest 10) ===');
        for (Meal_Ingredient__c ing : sampleIngredients) {
            System.debug(ing.Meal__r.Name + ': ' + ing.Quantity__c + ' ' + ing.Unit__c + ' ' +
                        ing.Ingredient_Name__c + ' (' + ing.Category__c + ')');
        }

    } catch (Exception e) {
        System.debug('❌ ERROR: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
}

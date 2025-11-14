/**
 * @description Test class for IngredientParser
 */
@isTest
private class IngredientParserTest {

    @isTest
    static void testParseBasicIngredients() {
        // Create test meal with ingredients
        Meal__c meal = new Meal__c(
            Name = 'Test Meal',
            Ingredients__c = '2 cups flour\n1 lb chicken breast\n3 tbsp olive oil\nSalt and pepper to taste',
            Prep_Time_Minutes__c = 10,
            Cook_Time_Minutes__c = 20,
            Servings__c = 4,
            Protein_Type__c = 'Chicken'
        );
        insert meal;

        Test.startTest();
        Integer count = IngredientParser.parseIngredientsForMeals(new Set<Id>{meal.Id});
        Test.stopTest();

        // Verify ingredients created
        List<Meal_Ingredient__c> ingredients = [
            SELECT Id, Ingredient_Name__c, Quantity__c, Unit__c, Category__c
            FROM Meal_Ingredient__c
            WHERE Meal__c = :meal.Id
            ORDER BY Ingredient_Name__c
        ];

        System.assertEquals(4, ingredients.size(), 'Should create 4 ingredients');
        System.assertEquals(4, count, 'Should return count of 4');

        // Check flour
        Meal_Ingredient__c flour = ingredients[1]; // "Flour" alphabetically second
        System.assertEquals('Flour', flour.Ingredient_Name__c);
        System.assertEquals(2, flour.Quantity__c);
        System.assertEquals('cup', flour.Unit__c);
        System.assertEquals('Pantry', flour.Category__c);

        // Check chicken
        Meal_Ingredient__c chicken = ingredients[0]; // "Chicken Breast" alphabetically first
        System.assertEquals('Chicken Breast', chicken.Ingredient_Name__c);
        System.assertEquals(1, chicken.Quantity__c);
        System.assertEquals('lb', chicken.Unit__c);
        System.assertEquals('Meat & Seafood', chicken.Category__c);
    }

    @isTest
    static void testParseIngredientsWithPluralUnits() {
        Meal__c meal = new Meal__c(
            Name = 'Test Meal 2',
            Ingredients__c = '2 pounds beef\n3 tablespoons butter\n4 ounces cheese',
            Prep_Time_Minutes__c = 15,
            Cook_Time_Minutes__c = 30,
            Servings__c = 6,
            Protein_Type__c = 'Beef'
        );
        insert meal;

        Test.startTest();
        IngredientParser.parseIngredientsForMeals(new Set<Id>{meal.Id});
        Test.stopTest();

        List<Meal_Ingredient__c> ingredients = [
            SELECT Id, Unit__c, Ingredient_Name__c
            FROM Meal_Ingredient__c
            WHERE Meal__c = :meal.Id
        ];

        System.assertEquals(3, ingredients.size());

        // Verify plural units converted to singular
        for (Meal_Ingredient__c ing : ingredients) {
            if (ing.Ingredient_Name__c.contains('Beef')) {
                System.assertEquals('lb', ing.Unit__c, 'Pounds should convert to lb');
            } else if (ing.Ingredient_Name__c.contains('Butter')) {
                System.assertEquals('tbsp', ing.Unit__c, 'Tablespoons should convert to tbsp');
            } else if (ing.Ingredient_Name__c.contains('Cheese')) {
                System.assertEquals('oz', ing.Unit__c, 'Ounces should convert to oz');
            }
        }
    }

    @isTest
    static void testParseIngredientsWithoutQuantity() {
        Meal__c meal = new Meal__c(
            Name = 'Test Meal 3',
            Ingredients__c = 'Salt and pepper to taste\nFresh herbs for garnish',
            Prep_Time_Minutes__c = 5,
            Cook_Time_Minutes__c = 0,
            Servings__c = 2,
            Protein_Type__c = 'Vegetarian'
        );
        insert meal;

        Test.startTest();
        IngredientParser.parseIngredientsForMeals(new Set<Id>{meal.Id});
        Test.stopTest();

        List<Meal_Ingredient__c> ingredients = [
            SELECT Id, Quantity__c, Unit__c
            FROM Meal_Ingredient__c
            WHERE Meal__c = :meal.Id
        ];

        System.assertEquals(2, ingredients.size());

        // Verify default values used
        for (Meal_Ingredient__c ing : ingredients) {
            System.assertEquals(1, ing.Quantity__c, 'Should default to quantity 1');
            System.assertEquals('each', ing.Unit__c, 'Should default to unit "each"');
        }
    }

    @isTest
    static void testParseIngredientsReplaceExisting() {
        // Create meal with ingredients
        Meal__c meal = new Meal__c(
            Name = 'Test Meal 4',
            Ingredients__c = '1 cup rice',
            Prep_Time_Minutes__c = 10,
            Cook_Time_Minutes__c = 20,
            Servings__c = 4,
            Protein_Type__c = 'Vegetarian'
        );
        insert meal;

        // First parse
        IngredientParser.parseIngredientsForMeals(new Set<Id>{meal.Id});

        List<Meal_Ingredient__c> firstParse = [
            SELECT Id FROM Meal_Ingredient__c WHERE Meal__c = :meal.Id
        ];
        System.assertEquals(1, firstParse.size());

        // Update meal ingredients
        meal.Ingredients__c = '2 cups rice\n1 lb beans';
        update meal;

        Test.startTest();
        // Parse again - should replace existing
        IngredientParser.parseIngredientsForMeals(new Set<Id>{meal.Id});
        Test.stopTest();

        List<Meal_Ingredient__c> secondParse = [
            SELECT Id, Ingredient_Name__c
            FROM Meal_Ingredient__c
            WHERE Meal__c = :meal.Id
        ];

        System.assertEquals(2, secondParse.size(), 'Should have 2 ingredients after reparse');
    }

    @isTest
    static void testInvocableMethod() {
        Meal__c meal = new Meal__c(
            Name = 'Test Meal 5',
            Ingredients__c = '2 cups pasta\n1 jar marinara sauce',
            Prep_Time_Minutes__c = 5,
            Cook_Time_Minutes__c = 15,
            Servings__c = 4,
            Protein_Type__c = 'Vegetarian'
        );
        insert meal;

        Test.startTest();
        List<IngredientParser.ParseResult> results =
            IngredientParser.parseIngredientsFromFlow(new List<Id>{meal.Id});
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        System.assertEquals(2, results[0].ingredientsCreated);
    }

    @isTest
    static void testMultipleMeals() {
        List<Meal__c> meals = new List<Meal__c>();

        for (Integer i = 0; i < 5; i++) {
            meals.add(new Meal__c(
                Name = 'Test Meal ' + i,
                Ingredients__c = '1 cup ingredient' + i + '\n2 tbsp spice' + i,
                Prep_Time_Minutes__c = 10,
                Cook_Time_Minutes__c = 15,
                Servings__c = 4,
                Protein_Type__c = 'Vegetarian'
            ));
        }
        insert meals;

        Set<Id> mealIds = new Set<Id>();
        for (Meal__c m : meals) {
            mealIds.add(m.Id);
        }

        Test.startTest();
        Integer count = IngredientParser.parseIngredientsForMeals(mealIds);
        Test.stopTest();

        System.assertEquals(10, count, 'Should create 10 ingredients (2 per meal × 5 meals)');
    }

    @isTest
    static void testEmptyIngredients() {
        Meal__c meal = new Meal__c(
            Name = 'Test Meal 6',
            Ingredients__c = '',
            Prep_Time_Minutes__c = 10,
            Cook_Time_Minutes__c = 20,
            Servings__c = 4,
            Protein_Type__c = 'Chicken'
        );
        insert meal;

        Test.startTest();
        Integer count = IngredientParser.parseIngredientsForMeals(new Set<Id>{meal.Id});
        Test.stopTest();

        System.assertEquals(0, count, 'Should create 0 ingredients for empty text');
    }

    @isTest
    static void testCategorization() {
        Meal__c meal = new Meal__c(
            Name = 'Test Meal 7',
            Ingredients__c = '1 lb salmon\n2 cups spinach\n1 cup milk\n2 tbsp olive oil',
            Prep_Time_Minutes__c = 15,
            Cook_Time_Minutes__c = 20,
            Servings__c = 4,
            Protein_Type__c = 'Fish/Seafood'
        );
        insert meal;

        Test.startTest();
        IngredientParser.parseIngredientsForMeals(new Set<Id>{meal.Id});
        Test.stopTest();

        Map<String, Meal_Ingredient__c> ingredientsByName = new Map<String, Meal_Ingredient__c>();
        for (Meal_Ingredient__c ing : [
            SELECT Ingredient_Name__c, Category__c
            FROM Meal_Ingredient__c
            WHERE Meal__c = :meal.Id
        ]) {
            ingredientsByName.put(ing.Ingredient_Name__c, ing);
        }

        System.assertEquals('Meat & Seafood', ingredientsByName.get('Salmon').Category__c);
        System.assertEquals('Produce', ingredientsByName.get('Spinach').Category__c);
        System.assertEquals('Dairy', ingredientsByName.get('Milk').Category__c);
        System.assertEquals('Pantry', ingredientsByName.get('Olive Oil').Category__c);
    }
}

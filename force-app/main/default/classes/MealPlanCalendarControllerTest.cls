/**
 * @description Test class for MealPlanCalendarController
 */
@isTest
private class MealPlanCalendarControllerTest {

    @testSetup
    static void setupTestData() {
        // Create test meals
        List<Meal__c> meals = new List<Meal__c>();

        meals.add(new Meal__c(
            Name = 'Test Breakfast',
            Servings__c = 4,
            Prep_Time_Minutes__c = 10,
            Cook_Time_Minutes__c = 10,
            Calories__c = 350,
            Protein_g__c = 15,
            Carbs_g__c = 45,
            Fat_g__c = 12,
            Protein_Type__c = 'Eggs',
            Difficulty__c = 'Easy',
            Is_Heart_Healthy__c = true,
            Is_Diabetic_Friendly__c = true,
            Instructions__c = 'Delicious breakfast recipe'
        ));

        meals.add(new Meal__c(
            Name = 'Test Lunch',
            Servings__c = 4,
            Prep_Time_Minutes__c = 15,
            Cook_Time_Minutes__c = 15,
            Calories__c = 450,
            Protein_g__c = 25,
            Carbs_g__c = 50,
            Fat_g__c = 15,
            Protein_Type__c = 'Chicken',
            Difficulty__c = 'Medium',
            Is_Heart_Healthy__c = true
        ));

        meals.add(new Meal__c(
            Name = 'Test Dinner',
            Servings__c = 6,
            Prep_Time_Minutes__c = 20,
            Cook_Time_Minutes__c = 25,
            Calories__c = 550,
            Protein_g__c = 35,
            Carbs_g__c = 40,
            Fat_g__c = 20,
            Protein_Type__c = 'Beef',
            Difficulty__c = 'Medium'
        ));

        insert meals;

        // Create meal ingredients
        List<Meal_Ingredient__c> ingredients = new List<Meal_Ingredient__c>();

        ingredients.add(new Meal_Ingredient__c(
            Meal__c = meals[0].Id,
            Ingredient_Name__c = 'Eggs',
            Quantity__c = 4,
            Unit__c = 'each',
            Category__c = 'Dairy',
            Estimated_Price__c = 2.50
        ));

        ingredients.add(new Meal_Ingredient__c(
            Meal__c = meals[0].Id,
            Ingredient_Name__c = 'Milk',
            Quantity__c = 1,
            Unit__c = 'cup',
            Category__c = 'Dairy',
            Estimated_Price__c = 0.75
        ));

        ingredients.add(new Meal_Ingredient__c(
            Meal__c = meals[1].Id,
            Ingredient_Name__c = 'Chicken Breast',
            Quantity__c = 1,
            Unit__c = 'lb',
            Category__c = 'Meat & Seafood',
            Estimated_Price__c = 5.99
        ));

        insert ingredients;

        // Create meal plan
        Weekly_Meal_Plan__c mealPlan = new Weekly_Meal_Plan__c(
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(13),
            Number_of_People__c = 5,
            Status__c = 'Draft',
            Generation_Method__c = 'Manual'
        );
        insert mealPlan;

        // Create planned meals
        List<Planned_Meal__c> plannedMeals = new List<Planned_Meal__c>();

        plannedMeals.add(new Planned_Meal__c(
            Weekly_Meal_Plan__c = mealPlan.Id,
            Meal__c = meals[0].Id,
            Meal_Date__c = Date.today(),
            Meal_Time__c = 'Breakfast',
            Servings__c = 5,
            Has_Leftovers__c = false
        ));

        plannedMeals.add(new Planned_Meal__c(
            Weekly_Meal_Plan__c = mealPlan.Id,
            Meal__c = meals[1].Id,
            Meal_Date__c = Date.today(),
            Meal_Time__c = 'Lunch',
            Servings__c = 5,
            Has_Leftovers__c = true
        ));

        plannedMeals.add(new Planned_Meal__c(
            Weekly_Meal_Plan__c = mealPlan.Id,
            Meal__c = meals[2].Id,
            Meal_Date__c = Date.today(),
            Meal_Time__c = 'Dinner',
            Servings__c = 5,
            Has_Leftovers__c = true
        ));

        insert plannedMeals;
    }

    @isTest
    static void testGetPlannedMeals_Success() {
        // Get test meal plan
        Weekly_Meal_Plan__c mealPlan = [SELECT Id FROM Weekly_Meal_Plan__c LIMIT 1];

        Test.startTest();
        MealPlanCalendarController.MealPlanData result =
            MealPlanCalendarController.getPlannedMeals(mealPlan.Id);
        Test.stopTest();

        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(mealPlan.Id, result.mealPlanId, 'Meal plan ID should match');
        System.assertEquals(5, result.numberOfPeople, 'Number of people should be 5');
        System.assertEquals('Draft', result.status, 'Status should be Draft');
        System.assertEquals(3, result.plannedMeals.size(), 'Should have 3 planned meals');

        // Verify breakfast meal
        MealPlanCalendarController.PlannedMealInfo breakfast =
            result.plannedMeals[0];
        System.assertEquals('Breakfast', breakfast.mealTime, 'First meal should be breakfast');
        System.assertEquals('Test Breakfast', breakfast.mealName, 'Meal name should match');
        System.assertEquals(20, breakfast.totalTime, 'Total time should be 20 minutes');
        System.assertEquals(false, breakfast.hasLeftovers, 'Should not have leftovers');
    }

    @isTest
    static void testGetPlannedMeals_InvalidId() {
        // Generate fake ID using FFLib pattern
        Id invalidId = Id.valueOf('a00000000000000AAA');

        Test.startTest();
        try {
            MealPlanCalendarController.getPlannedMeals(invalidId);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error loading meal plan'),
                         'Should contain error message');
        }
        Test.stopTest();
    }

    @isTest
    static void testGenerateMealPlan_Success() {
        // Create at least one meal for the generator to use
        Date startDate = Date.today().addDays(14);
        Integer numberOfPeople = 4;

        Test.startTest();
        Id mealPlanId = MealPlanCalendarController.generateMealPlan(startDate, numberOfPeople);
        Test.stopTest();

        // Verify meal plan was created
        System.assertNotEquals(null, mealPlanId, 'Meal plan ID should not be null');

        Weekly_Meal_Plan__c createdPlan = [
            SELECT Id, Start_Date__c, Number_of_People__c, Status__c
            FROM Weekly_Meal_Plan__c
            WHERE Id = :mealPlanId
        ];

        System.assertEquals(4, createdPlan.Number_of_People__c, 'Should plan for 4 people');
        System.assertEquals('Draft', createdPlan.Status__c, 'Should be Draft status');
    }

    @isTest
    static void testGetMealDetails_Success() {
        // Get test planned meal
        Planned_Meal__c plannedMeal = [
            SELECT Id
            FROM Planned_Meal__c
            WHERE Meal_Time__c = 'Breakfast'
            LIMIT 1
        ];

        Test.startTest();
        MealPlanCalendarController.MealDetailInfo result =
            MealPlanCalendarController.getMealDetails(plannedMeal.Id);
        Test.stopTest();

        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('Test Breakfast', result.mealName, 'Meal name should match');
        System.assertEquals(20, result.totalTime, 'Total time should be 20 minutes');
        System.assertEquals(10, result.prepTime, 'Prep time should be 10 minutes');
        System.assertEquals(10, result.cookTime, 'Cook time should be 10 minutes');
        System.assertEquals(4, result.servings, 'Servings should be 4');
        System.assertEquals(350, result.calories, 'Calories should be 350');
        System.assertEquals('Eggs', result.proteinType, 'Protein type should be Eggs');
        System.assertEquals('Easy', result.difficulty, 'Difficulty should be Easy');
        System.assertEquals(true, result.isHeartHealthy, 'Should be heart healthy');
        System.assertEquals(true, result.isDiabeticFriendly, 'Should be diabetic friendly');
        System.assertEquals(true, result.isWeeknightFriendly, 'Should be weeknight friendly');

        // Verify ingredients
        System.assertEquals(2, result.ingredients.size(), 'Should have 2 ingredients');

        MealPlanCalendarController.IngredientInfo egg = result.ingredients[0];
        System.assertEquals('Eggs', egg.name, 'Ingredient name should be Eggs');
        System.assertEquals(4, egg.quantity, 'Quantity should be 4');
        System.assertEquals('each', egg.unit, 'Unit should be each');
        System.assertEquals('Dairy', egg.category, 'Category should be Dairy');
    }

    @isTest
    static void testGetMealDetails_InvalidId() {
        // Generate fake Planned_Meal__c ID
        Id invalidId = Id.valueOf('a01000000000000AAA');

        Test.startTest();
        try {
            MealPlanCalendarController.getMealDetails(invalidId);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error loading meal details'),
                         'Should contain error message');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetPlannedMeals_EmptyPlan() {
        // Create meal plan with no planned meals
        Weekly_Meal_Plan__c emptyPlan = new Weekly_Meal_Plan__c(
            Start_Date__c = Date.today().addDays(20),
            End_Date__c = Date.today().addDays(33),
            Number_of_People__c = 3,
            Status__c = 'Draft'
        );
        insert emptyPlan;

        Test.startTest();
        MealPlanCalendarController.MealPlanData result =
            MealPlanCalendarController.getPlannedMeals(emptyPlan.Id);
        Test.stopTest();

        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.plannedMeals.size(), 'Should have 0 planned meals');
    }

    @isTest
    static void testWrapperClasses() {
        // Test that wrapper classes can be instantiated and used
        Test.startTest();

        MealPlanCalendarController.MealPlanData data = new MealPlanCalendarController.MealPlanData();
        data.mealPlanId = Id.valueOf('a00000000000000AAA');
        data.mealPlanName = 'Test Plan';
        data.startDate = Date.today();
        data.endDate = Date.today().addDays(13);
        data.numberOfPeople = 5;
        data.status = 'Active';

        MealPlanCalendarController.PlannedMealInfo mealInfo = new MealPlanCalendarController.PlannedMealInfo();
        mealInfo.id = Id.valueOf('a01000000000000AAA');
        mealInfo.mealDate = Date.today();
        mealInfo.mealTime = 'Dinner';
        mealInfo.mealName = 'Test Meal';
        mealInfo.totalTime = 45;
        mealInfo.servings = 4;
        mealInfo.hasLeftovers = true;

        MealPlanCalendarController.MealDetailInfo detailInfo = new MealPlanCalendarController.MealDetailInfo();
        detailInfo.mealName = 'Test Detail';
        detailInfo.description = 'Test Description';
        detailInfo.totalTime = 60;
        detailInfo.ingredients = new List<MealPlanCalendarController.IngredientInfo>();

        MealPlanCalendarController.IngredientInfo ingredient = new MealPlanCalendarController.IngredientInfo();
        ingredient.name = 'Test Ingredient';
        ingredient.quantity = 2;
        ingredient.unit = 'cup';
        ingredient.category = 'Pantry';

        Test.stopTest();

        // Verify instantiation worked
        System.assertNotEquals(null, data, 'MealPlanData should not be null');
        System.assertNotEquals(null, mealInfo, 'PlannedMealInfo should not be null');
        System.assertNotEquals(null, detailInfo, 'MealDetailInfo should not be null');
        System.assertNotEquals(null, ingredient, 'IngredientInfo should not be null');
    }
}

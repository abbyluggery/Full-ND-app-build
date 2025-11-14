/**
 * @description Test class for MealPlanGeneratorInvocable
 */
@isTest
private class MealPlanGeneratorInvocableTest {

    @testSetup
    static void setupTestData() {
        // Create test meals
        List<Meal__c> meals = new List<Meal__c>();
        for (Integer i = 1; i <= 20; i++) {
            meals.add(new Meal__c(
                Name = 'Test Meal ' + i,
                Servings__c = 4,
                Prep_Time_Minutes__c = 15,
                Cook_Time_Minutes__c = 15,  // Total_Time_Minutes__c will auto-calculate to 30
                Calories__c = 400,
                Protein_g__c = 25,
                Carbs_g__c = 40,
                Fat_g__c = 15,
                Sugar_g__c = 5,
                Protein_Type__c = i <= 10 ? 'Chicken' : 'Fish',
                Difficulty__c = 'Easy',
                Ingredients__c = 'Test ingredients',
                Instructions__c = 'Test instructions'
                // Is_Weeknight_Friendly__c is formula field, will auto-calculate to true (Total_Time <= 30)
            ));
        }
        insert meals;
    }

    @isTest
    static void testGenerateMealPlan_Success() {
        // Prepare input
        MealPlanGeneratorInvocable.Request request = new MealPlanGeneratorInvocable.Request();
        request.startDate = Date.today().toStartOfWeek();
        request.numberOfPeople = 5;

        List<MealPlanGeneratorInvocable.Request> requests = new List<MealPlanGeneratorInvocable.Request>{request};

        Test.startTest();
        List<MealPlanGeneratorInvocable.Result> results =
            MealPlanGeneratorInvocable.generateMealPlan(requests);
        Test.stopTest();

        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result');

        MealPlanGeneratorInvocable.Result result = results[0];
        System.assertEquals(true, result.success, 'Should be successful');
        System.assertNotEquals(null, result.mealPlanId, 'Should return meal plan ID');
        System.assert(result.message.contains('successfully'), 'Should have success message');

        // Verify meal plan was created
        Weekly_Meal_Plan__c mealPlan = [
            SELECT Id, Week_Start_Date__c, Week_End_Date__c, Number_of_People__c
            FROM Weekly_Meal_Plan__c
            WHERE Id = :result.mealPlanId
        ];

        System.assertEquals(request.startDate, mealPlan.Week_Start_Date__c, 'Start date should match');
        System.assertEquals(5, mealPlan.Number_of_People__c, 'Number of people should match');
    }

    @isTest
    static void testGenerateMealPlan_DefaultNumberOfPeople() {
        // Prepare input without numberOfPeople (should default to 5)
        MealPlanGeneratorInvocable.Request request = new MealPlanGeneratorInvocable.Request();
        request.startDate = Date.today().toStartOfWeek();

        List<MealPlanGeneratorInvocable.Request> requests = new List<MealPlanGeneratorInvocable.Request>{request};

        Test.startTest();
        List<MealPlanGeneratorInvocable.Result> results =
            MealPlanGeneratorInvocable.generateMealPlan(requests);
        Test.stopTest();

        // Verify results
        MealPlanGeneratorInvocable.Result result = results[0];
        System.assertEquals(true, result.success, 'Should be successful');

        // Verify default number of people was used
        Weekly_Meal_Plan__c mealPlan = [
            SELECT Number_of_People__c
            FROM Weekly_Meal_Plan__c
            WHERE Id = :result.mealPlanId
        ];

        System.assertEquals(5, mealPlan.Number_of_People__c, 'Should default to 5 people');
    }

    @isTest
    static void testGenerateMealPlan_MultipleRequests() {
        // Prepare multiple inputs
        List<MealPlanGeneratorInvocable.Request> requests = new List<MealPlanGeneratorInvocable.Request>();

        for (Integer i = 0; i < 2; i++) {
            MealPlanGeneratorInvocable.Request request = new MealPlanGeneratorInvocable.Request();
            request.startDate = Date.today().toStartOfWeek().addDays(i * 14);
            request.numberOfPeople = 4 + i;
            requests.add(request);
        }

        Test.startTest();
        List<MealPlanGeneratorInvocable.Result> results =
            MealPlanGeneratorInvocable.generateMealPlan(requests);
        Test.stopTest();

        // Verify multiple meal plans were created
        System.assertEquals(2, results.size(), 'Should return two results');
        System.assertEquals(true, results[0].success, 'First should be successful');
        System.assertEquals(true, results[1].success, 'Second should be successful');
    }
}

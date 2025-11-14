/**
 * @description Test class for MealPlanGenerator
 */
@isTest
private class MealPlanGeneratorTest {

    @TestSetup
    static void setupTestData() {
        // Create test recipes with various characteristics
        List<Meal__c> testRecipes = new List<Meal__c>();

        // Weeknight-friendly chicken recipes (≤30 min)
        for (Integer i = 1; i <= 15; i++) {
            testRecipes.add(new Meal__c(
                Name = 'Quick Chicken Recipe ' + i,
                Servings__c = 6,
                Prep_Time_Minutes__c = 10,
                Cook_Time_Minutes__c = 20,
                Protein_Type__c = 'Chicken',
                Is_Heart_Healthy__c = true,
                Is_Diabetic_Friendly__c = true,
                Calories__c = 350,
                Carbs_g__c = 25,
                Fat_g__c = 10,
                Sugar_g__c = 5
            ));
        }

        // Beef recipes (some weeknight-friendly, some not)
        for (Integer i = 1; i <= 5; i++) {
            testRecipes.add(new Meal__c(
                Name = 'Beef Recipe ' + i,
                Servings__c = 6,
                Prep_Time_Minutes__c = 15,
                Cook_Time_Minutes__c = i <= 2 ? 15 : 45, // First 2 are weeknight-friendly
                Protein_Type__c = 'Beef',
                Is_Heart_Healthy__c = false,
                Calories__c = 450,
                Carbs_g__c = 20,
                Fat_g__c = 25,
                Sugar_g__c = 3
            ));
        }

        // Pork recipes
        for (Integer i = 1; i <= 5; i++) {
            testRecipes.add(new Meal__c(
                Name = 'Pork Recipe ' + i,
                Servings__c = 6,
                Prep_Time_Minutes__c = 10,
                Cook_Time_Minutes__c = i <= 2 ? 20 : 60,
                Protein_Type__c = 'Pork',
                Is_Diabetic_Friendly__c = true,
                Calories__c = 400,
                Carbs_g__c = 15,
                Fat_g__c = 20,
                Sugar_g__c = 2
            ));
        }

        // Fish/Seafood recipes
        for (Integer i = 1; i <= 10; i++) {
            testRecipes.add(new Meal__c(
                Name = 'Fish Recipe ' + i,
                Servings__c = 5,
                Prep_Time_Minutes__c = 10,
                Cook_Time_Minutes__c = 15,
                Protein_Type__c = 'Fish/Seafood',
                Is_Heart_Healthy__c = true,
                Is_Diabetic_Friendly__c = true,
                Calories__c = 300,
                Carbs_g__c = 10,
                Fat_g__c = 12,
                Sugar_g__c = 1
            ));
        }

        // Vegetarian recipes
        for (Integer i = 1; i <= 10; i++) {
            testRecipes.add(new Meal__c(
                Name = 'Vegetarian Recipe ' + i,
                Servings__c = 6,
                Prep_Time_Minutes__c = 15,
                Cook_Time_Minutes__c = 15,
                Protein_Type__c = 'Vegetarian',
                Is_Heart_Healthy__c = true,
                Is_Diabetic_Friendly__c = true,
                Calories__c = 280,
                Carbs_g__c = 35,
                Fat_g__c = 8,
                Sugar_g__c = 6
            ));
        }

        insert testRecipes;
    }

    @isTest
    static void testGenerateMealPlan_ValidSunday() {
        // Get a Sunday date
        Date testDate = Date.newInstance(2025, 11, 9); // Sunday, Nov 9, 2025

        Test.startTest();
        Id mealPlanId = MealPlanGenerator.generateMealPlan(testDate, 5, false);
        Test.stopTest();

        // Verify meal plan created
        Weekly_Meal_Plan__c mealPlan = [
            SELECT Id, Name, Start_Date__c, End_Date__c, Number_of_People__c, Status__c, Generation_Method__c
            FROM Weekly_Meal_Plan__c
            WHERE Id = :mealPlanId
        ];

        System.assertEquals(testDate, mealPlan.Start_Date__c, 'Start date should be the provided Sunday');
        System.assertEquals(testDate.addDays(13), mealPlan.End_Date__c, 'End date should be 13 days after start');
        System.assertEquals(5, mealPlan.Number_of_People__c, 'Should plan for 5 people');
        System.assertEquals('Draft', mealPlan.Status__c, 'Should be Draft when autoAccept is false');
        System.assertEquals('Fully Automated', mealPlan.Generation_Method__c);

        // Verify planned meals created (14 days × 3 meals = 42)
        List<Planned_Meal__c> plannedMeals = [
            SELECT Id, Meal_Date__c, Meal_Time__c, Servings__c, Meal__r.Name
            FROM Planned_Meal__c
            WHERE Weekly_Meal_Plan__c = :mealPlanId
            ORDER BY Meal_Date__c, Meal_Time__c
        ];

        System.assertEquals(42, plannedMeals.size(), 'Should create 42 planned meals (14 days × 3 meals)');

        // Verify servings
        for (Planned_Meal__c pm : plannedMeals) {
            System.assertEquals(5, pm.Servings__c, 'Each meal should serve 5 people');
        }
    }

    @isTest
    static void testGenerateMealPlan_AutoAccept() {
        Date testDate = Date.newInstance(2025, 11, 9);

        Test.startTest();
        Id mealPlanId = MealPlanGenerator.generateMealPlan(testDate, 5, true);
        Test.stopTest();

        Weekly_Meal_Plan__c mealPlan = [SELECT Status__c FROM Weekly_Meal_Plan__c WHERE Id = :mealPlanId];
        System.assertEquals('Active', mealPlan.Status__c, 'Should be Active when autoAccept is true');
    }

    @isTest
    static void testGenerateMealPlan_NonSunday() {
        // Provide a Wednesday, should convert to next Sunday
        Date wednesday = Date.newInstance(2025, 11, 5); // Wednesday
        Date expectedSunday = Date.newInstance(2025, 11, 9); // Following Sunday

        Test.startTest();
        Id mealPlanId = MealPlanGenerator.generateMealPlan(wednesday, 5, false);
        Test.stopTest();

        Weekly_Meal_Plan__c mealPlan = [SELECT Start_Date__c FROM Weekly_Meal_Plan__c WHERE Id = :mealPlanId];
        System.assertEquals(expectedSunday, mealPlan.Start_Date__c, 'Should convert to next Sunday');
    }

    @isTest
    static void testWeeknightMealsAreQuick() {
        Date testDate = Date.newInstance(2025, 11, 9); // Sunday

        Test.startTest();
        Id mealPlanId = MealPlanGenerator.generateMealPlan(testDate, 5, false);
        Test.stopTest();

        // Get all weeknight dinners (Mon-Fri)
        List<Planned_Meal__c> weeknightDinners = [
            SELECT Id, Meal__r.Total_Time_Minutes__c, Meal__r.Is_Weeknight_Friendly__c, Meal_Date__c
            FROM Planned_Meal__c
            WHERE Weekly_Meal_Plan__c = :mealPlanId
            AND Meal_Time__c = 'Dinner'
        ];

        for (Planned_Meal__c dinner : weeknightDinners) {
            DateTime dt = DateTime.newInstance(dinner.Meal_Date__c, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek = dt.format('EEEE');

            // Check weeknight dinners are ≤30 minutes
            if (dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday') {
                System.assert(
                    dinner.Meal__r.Is_Weeknight_Friendly__c == true,
                    'Weeknight dinner should be weeknight-friendly: ' + dayOfWeek
                );
            }
        }
    }

    @isTest
    static void testNoRecipeDuplicates() {
        Date testDate = Date.newInstance(2025, 11, 9);

        Test.startTest();
        Id mealPlanId = MealPlanGenerator.generateMealPlan(testDate, 5, false);
        Test.stopTest();

        List<Planned_Meal__c> plannedMeals = [
            SELECT Meal__c
            FROM Planned_Meal__c
            WHERE Weekly_Meal_Plan__c = :mealPlanId
        ];

        Set<Id> recipeIds = new Set<Id>();
        for (Planned_Meal__c pm : plannedMeals) {
            System.assert(!recipeIds.contains(pm.Meal__c), 'Recipe should not be used twice in same plan');
            recipeIds.add(pm.Meal__c);
        }
    }

    @isTest
    static void testLastUsedDateUpdated() {
        Date testDate = Date.newInstance(2025, 11, 9);

        Test.startTest();
        Id mealPlanId = MealPlanGenerator.generateMealPlan(testDate, 5, false);
        Test.stopTest();

        // Get recipes used in the plan
        List<Planned_Meal__c> plannedMeals = [
            SELECT Meal__c
            FROM Planned_Meal__c
            WHERE Weekly_Meal_Plan__c = :mealPlanId
            LIMIT 1
        ];

        if (!plannedMeals.isEmpty()) {
            Meal__c usedRecipe = [
                SELECT Last_Used_Date__c
                FROM Meal__c
                WHERE Id = :plannedMeals[0].Meal__c
            ];

            System.assertEquals(Date.today(), usedRecipe.Last_Used_Date__c, 'Last used date should be updated');
        }
    }

    @isTest
    static void testBeefPorkLimits() {
        Date testDate = Date.newInstance(2025, 11, 9); // Sunday

        Test.startTest();
        Id mealPlanId = MealPlanGenerator.generateMealPlan(testDate, 5, false);
        Test.stopTest();

        // Get all dinners grouped by week
        List<Planned_Meal__c> week1Dinners = [
            SELECT Meal__r.Protein_Type__c
            FROM Planned_Meal__c
            WHERE Weekly_Meal_Plan__c = :mealPlanId
            AND Meal_Time__c = 'Dinner'
            AND Meal_Date__c >= :testDate
            AND Meal_Date__c < :testDate.addDays(7)
        ];

        List<Planned_Meal__c> week2Dinners = [
            SELECT Meal__r.Protein_Type__c
            FROM Planned_Meal__c
            WHERE Weekly_Meal_Plan__c = :mealPlanId
            AND Meal_Time__c = 'Dinner'
            AND Meal_Date__c >= :testDate.addDays(7)
            AND Meal_Date__c < :testDate.addDays(14)
        ];

        // Count beef and pork in each week
        Integer week1Beef = 0, week1Pork = 0;
        for (Planned_Meal__c dinner : week1Dinners) {
            if (dinner.Meal__r.Protein_Type__c == 'Beef') week1Beef++;
            if (dinner.Meal__r.Protein_Type__c == 'Pork') week1Pork++;
        }

        Integer week2Beef = 0, week2Pork = 0;
        for (Planned_Meal__c dinner : week2Dinners) {
            if (dinner.Meal__r.Protein_Type__c == 'Beef') week2Beef++;
            if (dinner.Meal__r.Protein_Type__c == 'Pork') week2Pork++;
        }

        System.assert(week1Beef <= 1, 'Week 1 should have max 1 beef dinner');
        System.assert(week1Pork <= 1, 'Week 1 should have max 1 pork dinner');
        System.assert(week2Beef <= 1, 'Week 2 should have max 1 beef dinner');
        System.assert(week2Pork <= 1, 'Week 2 should have max 1 pork dinner');
    }

    @isTest
    static void testInvocableMethod() {
        Date testDate = Date.newInstance(2025, 11, 9);

        MealPlanGenerator.MealPlanRequest request = new MealPlanGenerator.MealPlanRequest();
        request.startDate = testDate;
        request.numberOfPeople = 6;
        request.autoAccept = true;

        Test.startTest();
        List<Id> mealPlanIds = MealPlanGenerator.generateMealPlanFromFlow(new List<MealPlanGenerator.MealPlanRequest>{request});
        Test.stopTest();

        System.assertEquals(1, mealPlanIds.size(), 'Should return one meal plan ID');

        Weekly_Meal_Plan__c mealPlan = [
            SELECT Number_of_People__c, Status__c
            FROM Weekly_Meal_Plan__c
            WHERE Id = :mealPlanIds[0]
        ];

        System.assertEquals(6, mealPlan.Number_of_People__c, 'Should plan for 6 people');
        System.assertEquals('Active', mealPlan.Status__c, 'Should be active');
    }

    @isTest
    static void testMealTimesDistribution() {
        Date testDate = Date.newInstance(2025, 11, 9);

        Test.startTest();
        Id mealPlanId = MealPlanGenerator.generateMealPlan(testDate, 5, false);
        Test.stopTest();

        // Count meals by type
        AggregateResult[] results = [
            SELECT Meal_Time__c, COUNT(Id) cnt
            FROM Planned_Meal__c
            WHERE Weekly_Meal_Plan__c = :mealPlanId
            GROUP BY Meal_Time__c
        ];

        Map<String, Integer> mealCounts = new Map<String, Integer>();
        for (AggregateResult ar : results) {
            mealCounts.put((String)ar.get('Meal_Time__c'), (Integer)ar.get('cnt'));
        }

        System.assertEquals(14, mealCounts.get('Breakfast'), 'Should have 14 breakfasts');
        System.assertEquals(14, mealCounts.get('Lunch'), 'Should have 14 lunches');
        System.assertEquals(14, mealCounts.get('Dinner'), 'Should have 14 dinners');
    }
}

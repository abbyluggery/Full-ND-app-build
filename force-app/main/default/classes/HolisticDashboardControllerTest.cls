/**
 * @description Test class for HolisticDashboardController
 * @author Abby Luggery / Claude Code Assistant
 * @date November 12, 2025
 */
@isTest
private class HolisticDashboardControllerTest {

    @testSetup
    static void setupTestData() {
        // Create Job Postings
        List<Job_Posting__c> jobs = new List<Job_Posting__c>();
        jobs.add(new Job_Posting__c(
            Name = 'Senior Salesforce Developer',
            Company__c = 'Tech Corp',
            Application_Status__c = 'Discovered',
            Job_Discovered_Date__c = Date.today()
        ));
        jobs.add(new Job_Posting__c(
            Name = 'Salesforce Architect',
            Company__c = 'Cloud Solutions Inc',
            Application_Status__c = 'Researching',
            Job_Discovered_Date__c = Date.today()
        ));
        jobs.add(new Job_Posting__c(
            Name = 'Salesforce Admin',
            Company__c = 'Data Systems LLC',
            Application_Status__c = 'Applied',
            Applied_Date__c = Date.today(),
            Interview_Date__c = Date.today().addDays(3)
        ));
        jobs.add(new Job_Posting__c(
            Name = 'Technical Lead',
            Company__c = 'Innovation Labs',
            Application_Status__c = 'Interviewing',
            Applied_Date__c = Date.today().addDays(-7),
            Interview_Date__c = Date.today().addDays(5)
        ));
        jobs.add(new Job_Posting__c(
            Name = 'CRM Consultant',
            Company__c = 'Consulting Partners',
            Application_Status__c = 'Offer',
            Applied_Date__c = Date.today().addDays(-14)
        ));
        insert jobs;

        // Create Meals
        List<Meal__c> meals = new List<Meal__c>();
        for (Integer i = 1; i <= 10; i++) {
            meals.add(new Meal__c(
                Name = 'Test Meal ' + i,
                Meal_Type__c = 'Dinner',
                Calories__c = 500,
                Prep_Time_Minutes__c = 30,
                Cook_Time_Minutes__c = 45
            ));
        }
        insert meals;

        // Create Weekly Meal Plan
        Weekly_Meal_Plan__c plan = new Weekly_Meal_Plan__c(
            Plan_Name__c = 'Test Week',
            Start_Date__c = Date.today().toStartOfWeek(),
            End_Date__c = Date.today().toStartOfWeek().addDays(6),
            Status__c = 'Active',
            Number_of_People__c = 2
        );
        insert plan;

        // Create Planned Meals
        List<Planned_Meal__c> plannedMeals = new List<Planned_Meal__c>();
        String[] daysOfWeek = new String[]{'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'};
        String[] mealTimes = new String[]{'Breakfast', 'Lunch', 'Dinner'};

        for (Integer day = 0; day < 7; day++) {
            for (Integer mealIdx = 0; mealIdx < 3 && (day * 3 + mealIdx) < meals.size(); mealIdx++) {
                plannedMeals.add(new Planned_Meal__c(
                    Weekly_Meal_Plan__c = plan.Id,
                    Meal__c = meals[day * 3 + mealIdx].Id,
                    Day_of_Week__c = daysOfWeek[day],
                    Meal_Time__c = mealTimes[mealIdx],
                    Meal_Date__c = Date.today().toStartOfWeek().addDays(day),
                    Is_Completed__c = (day < 2) // First 2 days completed
                ));
            }
        }
        insert plannedMeals;

        // Create Shopping Lists
        Shopping_List__c shoppingList1 = new Shopping_List__c(
            Store__c = 'Publix',
            Status__c = 'Ready',
            Weekly_Meal_Plan__c = plan.Id,
            Estimated_Cost__c = 150.00,
            Savings_Amount__c = 15.00,
            Coupons_Applied_Count__c = 5
        );
        insert shoppingList1;

        Shopping_List__c shoppingList2 = new Shopping_List__c(
            Store__c = 'Target',
            Status__c = 'Ready',
            Weekly_Meal_Plan__c = plan.Id,
            Estimated_Cost__c = 75.00,
            Savings_Amount__c = 8.50,
            Coupons_Applied_Count__c = 3
        );
        insert shoppingList2;

        // Create Shopping List Items
        List<Shopping_List_Item__c> items = new List<Shopping_List_Item__c>();
        for (Integer i = 1; i <= 15; i++) {
            items.add(new Shopping_List_Item__c(
                Shopping_List__c = shoppingList1.Id,
                Item_Name__c = 'Test Item ' + i,
                Quantity__c = 1,
                Unit__c = 'ea',
                Estimated_Price__c = 5.00,
                Is_Purchased__c = false
            ));
        }
        insert items;

        // Create Store Coupons
        List<Store_Coupon__c> coupons = new List<Store_Coupon__c>();
        for (Integer i = 1; i <= 20; i++) {
            coupons.add(new Store_Coupon__c(
                Product_Name__c = 'Test Product ' + i,
                Store__c = 'Publix',
                Discount_Amount__c = 1.00,
                Expiration_Date__c = Date.today().addDays(30),
                Is_Digital__c = true
            ));
        }
        insert coupons;

        // Create Daily Routines
        List<Daily_Routine__c> routines = new List<Daily_Routine__c>();

        // Today's routine
        routines.add(new Daily_Routine__c(
            Date__c = Date.today(),
            Mood__c = 'Happy',
            Energy_Level__c = 7,
            Stress_Level__c = 3,
            Morning_Routine_Complete__c = true,
            Exercise_Completed__c = true,
            Gratitude__c = 'Test gratitude',
            Accomplished_Today__c = 'Test accomplishments'
        ));

        // This week's routines
        Date weekStart = Date.today().toStartOfWeek();
        for (Integer i = 0; i < 5; i++) {
            routines.add(new Daily_Routine__c(
                Date__c = weekStart.addDays(i),
                Mood__c = 'Calm',
                Energy_Level__c = 6,
                Stress_Level__c = 4,
                Morning_Routine_Complete__c = true,
                Exercise_Completed__c = (Math.mod(i, 2) == 0) // Every other day
            ));
        }

        insert routines;
    }

    @isTest
    static void testGetDashboardData_Success() {
        Test.startTest();
        HolisticDashboardController.DashboardData data = HolisticDashboardController.getDashboardData();
        Test.stopTest();

        // Verify data structure exists
        System.assertNotEquals(null, data, 'Dashboard data should not be null');
        System.assertNotEquals(null, data.jobSearch, 'Job search stats should not be null');
        System.assertNotEquals(null, data.upcomingInterviews, 'Upcoming interviews should not be null');
        System.assertNotEquals(null, data.mealPlanning, 'Meal planning stats should not be null');
        System.assertNotEquals(null, data.thisWeekMeals, 'This week meals should not be null');
        System.assertNotEquals(null, data.shopping, 'Shopping stats should not be null');
        System.assertNotEquals(null, data.wellness, 'Wellness stats should not be null');
    }

    @isTest
    static void testJobSearchStats() {
        Test.startTest();
        HolisticDashboardController.DashboardData data = HolisticDashboardController.getDashboardData();
        Test.stopTest();

        HolisticDashboardController.JobSearchStats jobStats = data.jobSearch;

        // Verify job counts
        System.assertEquals(5, jobStats.totalJobs, 'Should have 5 total jobs');
        System.assertEquals(1, jobStats.jobsDiscovered, 'Should have 1 discovered job');
        System.assertEquals(1, jobStats.jobsResearching, 'Should have 1 researching job');
        System.assertEquals(1, jobStats.jobsApplied, 'Should have 1 applied job');
        System.assertEquals(1, jobStats.jobsInterviewing, 'Should have 1 interviewing job');
        System.assertEquals(1, jobStats.jobsOffers, 'Should have 1 offer');

        // Verify upcoming interviews
        System.assertEquals(2, data.upcomingInterviews.size(), 'Should have 2 upcoming interviews');
        System.assertNotEquals(null, data.upcomingInterviews[0].company, 'Interview should have company name');
    }

    @isTest
    static void testMealPlanningStats() {
        Test.startTest();
        HolisticDashboardController.DashboardData data = HolisticDashboardController.getDashboardData();
        Test.stopTest();

        HolisticDashboardController.MealPlanningStats mealStats = data.mealPlanning;

        // Verify meal counts
        System.assertEquals(10, mealStats.totalMeals, 'Should have 10 total meals in database');
        System.assertNotEquals(null, mealStats.activePlanId, 'Should have an active plan');
        System.assertEquals(true, mealStats.plannedMealsThisWeek > 0, 'Should have planned meals this week');
        System.assertEquals(21, mealStats.totalMealsThisWeek, 'Should expect 21 total meals per week');

        // Verify this week's meals list
        System.assertEquals(true, data.thisWeekMeals.size() > 0, 'Should have meals listed for this week');
        System.assertNotEquals(null, data.thisWeekMeals[0].mealName, 'Meal should have a name');
        System.assertNotEquals(null, data.thisWeekMeals[0].dayOfWeek, 'Meal should have a day of week');
    }

    @isTest
    static void testShoppingStats() {
        Test.startTest();
        HolisticDashboardController.DashboardData data = HolisticDashboardController.getDashboardData();
        Test.stopTest();

        HolisticDashboardController.ShoppingStats shopStats = data.shopping;

        // Verify shopping counts
        System.assertEquals(2, shopStats.listsReady, 'Should have 2 ready shopping lists');
        System.assertEquals(20, shopStats.activeCoupons, 'Should have 20 active coupons');
        System.assertEquals(23.50, shopStats.estimatedSavings, 'Should have $23.50 in estimated savings');
        System.assertEquals(15, shopStats.itemsOnLists, 'Should have 15 items on lists');

        // Verify high-value coupon detection
        System.assertEquals(true, shopStats.hasHighValueCoupons, 'Should detect high-value coupons');
        System.assertEquals(true, shopStats.highValueCouponCount > 0, 'Should have high-value coupon count');
    }

    @isTest
    static void testWellnessStats() {
        Test.startTest();
        HolisticDashboardController.DashboardData data = HolisticDashboardController.getDashboardData();
        Test.stopTest();

        HolisticDashboardController.WellnessStats wellnessStats = data.wellness;

        // Verify today's wellness data
        System.assertNotEquals(null, wellnessStats.todayMood, 'Should have today\'s mood');
        System.assertEquals(true, wellnessStats.todayEnergy > 0, 'Should have today\'s energy level');
        System.assertEquals(true, wellnessStats.morningRoutineComplete, 'Morning routine should be complete');

        // Verify weekly stats
        System.assertEquals(true, wellnessStats.routinesThisWeek > 0, 'Should have routines logged this week');
        System.assertEquals(true, wellnessStats.exerciseDaysThisWeek >= 0, 'Should have exercise days count');
    }

    @isTest
    static void testEmptyData() {
        // Delete all test data
        delete [SELECT Id FROM Job_Posting__c];
        delete [SELECT Id FROM Planned_Meal__c];
        delete [SELECT Id FROM Weekly_Meal_Plan__c];
        delete [SELECT Id FROM Shopping_List_Item__c];
        delete [SELECT Id FROM Shopping_List__c];
        delete [SELECT Id FROM Store_Coupon__c];
        delete [SELECT Id FROM Daily_Routine__c];

        Test.startTest();
        HolisticDashboardController.DashboardData data = HolisticDashboardController.getDashboardData();
        Test.stopTest();

        // Verify empty data returns zeros/nulls gracefully
        System.assertEquals(0, data.jobSearch.totalJobs, 'Should have 0 jobs');
        System.assertEquals(0, data.upcomingInterviews.size(), 'Should have 0 interviews');
        System.assertEquals(null, data.mealPlanning.activePlanId, 'Should have no active plan');
        System.assertEquals(0, data.thisWeekMeals.size(), 'Should have 0 meals');
        System.assertEquals(0, data.shopping.listsReady, 'Should have 0 shopping lists');
        System.assertEquals(null, data.wellness.todayMood, 'Should have no mood data');
    }

    @isTest
    static void testMealCompletionCalculation() {
        // Get the active plan and mark specific meals as completed
        Weekly_Meal_Plan__c plan = [SELECT Id FROM Weekly_Meal_Plan__c LIMIT 1];
        List<Planned_Meal__c> mealsToComplete = [
            SELECT Id, Is_Completed__c
            FROM Planned_Meal__c
            WHERE Weekly_Meal_Plan__c = :plan.Id
            LIMIT 6
        ];

        for (Planned_Meal__c pm : mealsToComplete) {
            pm.Is_Completed__c = true;
        }
        update mealsToComplete;

        Test.startTest();
        HolisticDashboardController.DashboardData data = HolisticDashboardController.getDashboardData();
        Test.stopTest();

        // Verify completion count
        System.assertEquals(true, data.mealPlanning.completedMealsThisWeek >= 6,
            'Should have at least 6 completed meals');
    }

    @isTest
    static void testCacheableAnnotation() {
        // Test that the method can be called multiple times (cacheable methods should work)
        Test.startTest();
        HolisticDashboardController.DashboardData data1 = HolisticDashboardController.getDashboardData();
        HolisticDashboardController.DashboardData data2 = HolisticDashboardController.getDashboardData();
        Test.stopTest();

        // Both calls should return data
        System.assertNotEquals(null, data1, 'First call should return data');
        System.assertNotEquals(null, data2, 'Second call should return data');
    }
}

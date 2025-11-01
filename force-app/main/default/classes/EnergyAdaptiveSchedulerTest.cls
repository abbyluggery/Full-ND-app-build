/**
 * @description Test class for EnergyAdaptiveScheduler
 * Tests energy-adaptive schedule recommendations and pattern analysis
 *
 * @author Claude AI Assistant
 * @date 2025-10-29
 */
@isTest
private class EnergyAdaptiveSchedulerTest {

    /**
     * @description Test data setup - creates Daily_Routine records for testing
     */
    @testSetup
    static void setupTestData() {
        // Create 30 days of Daily_Routine records for pattern analysis
        List<Daily_Routine__c> routines = new List<Daily_Routine__c>();

        for (Integer i = 29; i >= 0; i--) {
            Daily_Routine__c routine = new Daily_Routine__c();
            routine.Date__c = Date.today().addDays(-i);

            // Simulate realistic energy patterns
            if (Math.mod(i, 7) == 0 || Math.mod(i, 7) == 6) {
                // Weekends: Lower energy
                routine.Energy_Level_Morning__c = 5;
                routine.Mood__c = 'Okay';
            } else if (Math.mod(i, 7) == 3 || Math.mod(i, 7) == 4) {
                // Wed/Thu: High energy
                routine.Energy_Level_Morning__c = 8;
                routine.Mood__c = 'Great';
            } else {
                // Other days: Medium energy
                routine.Energy_Level_Morning__c = 6;
                routine.Mood__c = 'Good';
            }

            routine.Energy_Level_Afternoon__c = routine.Energy_Level_Morning__c - 1;
            routine.Energy_Level_Evening__c = routine.Energy_Level_Morning__c - 2;

            // Morning routine completed most days
            routine.Morning_Routine_Complete__c = (Math.mod(i, 5) != 0);

            // Exercise every other day
            routine.Exercise_Completed__c = (Math.mod(i, 2) == 0);
            routine.Exercise_Type__c = routine.Exercise_Completed__c ? '20 min walk' : null;

            // Water intake varies
            routine.Water_Intake__c = 6 + Math.mod(i, 3);

            // Stress varies
            routine.Stress_Level__c = (Math.mod(i, 7) == 2) ? 'Moderate' : 'Mild';

            routine.Accomplished_Today__c = 'Test accomplishment ' + i;
            routine.Gratitude__c = 'Test gratitude ' + i;

            routines.add(routine);
        }

        insert routines;
    }

    /**
     * @description Test high energy schedule recommendations
     */
    @isTest
    static void testHighEnergySchedule() {
        // Create high energy routine
        Daily_Routine__c routine = new Daily_Routine__c();
        routine.Date__c = Date.today();
        routine.Energy_Level_Morning__c = 9;
        routine.Mood__c = 'Great';
        routine.Morning_Routine_Complete__c = true;
        insert routine;

        Test.startTest();

        Map<String, Object> recommendations =
            EnergyAdaptiveScheduler.getScheduleRecommendations(routine.Id);

        Test.stopTest();

        // Verify high energy recommendations
        System.assertEquals(9, recommendations.get('energyLevel'),
            'Energy level should be 9');
        System.assertEquals('High', recommendations.get('energyCategory'),
            'Should be categorized as High energy');
        System.assertEquals(4, recommendations.get('studyHours'),
            'High energy should recommend 4 study hours');
        System.assertEquals(2, recommendations.get('jobSearchHours'),
            'High energy should recommend 2 job search hours');
        System.assertEquals('4-5 applications', recommendations.get('applicationGoal'),
            'High energy should target 4-5 applications');

        // Verify schedule list exists
        List<String> schedule = (List<String>)recommendations.get('schedule');
        System.assertNotEquals(null, schedule, 'Schedule should not be null');
        System.assert(schedule.size() > 0, 'Schedule should have items');

        // Verify motivational message
        String message = (String)recommendations.get('message');
        System.assert(message.contains('High energy'),
            'Message should mention high energy');
    }

    /**
     * @description Test medium energy schedule recommendations
     */
    @isTest
    static void testMediumEnergySchedule() {
        Daily_Routine__c routine = new Daily_Routine__c();
        routine.Date__c = Date.today();
        routine.Energy_Level_Morning__c = 6;
        routine.Mood__c = 'Good';
        routine.Morning_Routine_Complete__c = true;
        insert routine;

        Test.startTest();

        Map<String, Object> recommendations =
            EnergyAdaptiveScheduler.getScheduleRecommendations(routine.Id);

        Test.stopTest();

        System.assertEquals(6, recommendations.get('energyLevel'));
        System.assertEquals('Medium', recommendations.get('energyCategory'));
        System.assertEquals(3, recommendations.get('studyHours'));
        System.assertEquals(1.5, recommendations.get('jobSearchHours'));
        System.assertEquals('2-3 applications', recommendations.get('applicationGoal'));

        String message = (String)recommendations.get('message');
        System.assert(message.contains('Medium energy'),
            'Message should mention medium energy');
    }

    /**
     * @description Test low energy schedule recommendations
     */
    @isTest
    static void testLowEnergySchedule() {
        Daily_Routine__c routine = new Daily_Routine__c();
        routine.Date__c = Date.today();
        routine.Energy_Level_Morning__c = 3;
        routine.Mood__c = 'Low';
        routine.Morning_Routine_Complete__c = false;
        insert routine;

        Test.startTest();

        Map<String, Object> recommendations =
            EnergyAdaptiveScheduler.getScheduleRecommendations(routine.Id);

        Test.stopTest();

        System.assertEquals(3, recommendations.get('energyLevel'));
        System.assertEquals('Low', recommendations.get('energyCategory'));
        System.assertEquals(2, recommendations.get('studyHours'));
        System.assertEquals(1, recommendations.get('jobSearchHours'));
        System.assertEquals('1-2 Quick Apply jobs', recommendations.get('applicationGoal'));

        String message = (String)recommendations.get('message');
        System.assert(message.contains('Low energy'),
            'Message should mention low energy');
        System.assert(message.contains('Rest is productive'),
            'Message should validate rest');
    }

    /**
     * @description Test flare-up schedule recommendations
     */
    @isTest
    static void testFlareUpSchedule() {
        Daily_Routine__c routine = new Daily_Routine__c();
        routine.Date__c = Date.today();
        routine.Energy_Level_Morning__c = 1;
        routine.Mood__c = 'Very Low';
        routine.Stress_Level__c = 'Overwhelmed';
        routine.Morning_Routine_Complete__c = false;
        insert routine;

        Test.startTest();

        Map<String, Object> recommendations =
            EnergyAdaptiveScheduler.getScheduleRecommendations(routine.Id);

        Test.stopTest();

        System.assertEquals(1, recommendations.get('energyLevel'));
        System.assertEquals('Flare-up', recommendations.get('energyCategory'));
        System.assertEquals(0, recommendations.get('studyHours'),
            'Flare-up should recommend 0 study hours');
        System.assertEquals(0, recommendations.get('jobSearchHours'),
            'Flare-up should recommend 0 job search hours');
        System.assertEquals('Rest and recover', recommendations.get('applicationGoal'));

        String message = (String)recommendations.get('message');
        System.assert(message.contains('HEALTH FIRST'),
            'Message should emphasize health');
        System.assert(message.contains('No guilt'),
            'Message should remove guilt');
    }

    /**
     * @description Test null energy handling (defaults to medium)
     */
    @isTest
    static void testNullEnergyDefaultsToMedium() {
        Daily_Routine__c routine = new Daily_Routine__c();
        routine.Date__c = Date.today();
        routine.Energy_Level_Morning__c = null; // No energy logged
        routine.Mood__c = 'Okay';
        insert routine;

        Test.startTest();

        Map<String, Object> recommendations =
            EnergyAdaptiveScheduler.getScheduleRecommendations(routine.Id);

        Test.stopTest();

        System.assertEquals(5, recommendations.get('energyLevel'),
            'Null energy should default to 5');
        System.assertEquals('Medium', recommendations.get('energyCategory'),
            'Should default to Medium category');
    }

    /**
     * @description Test pattern analysis with sufficient data
     */
    @isTest
    static void testAnalyzeEnergyPatternsWithData() {
        Test.startTest();

        Map<String, Object> insights =
            EnergyAdaptiveScheduler.analyzeEnergyPatterns(30);

        Test.stopTest();

        // Verify data availability
        System.assertEquals(true, insights.get('hasData'),
            'Should have data from test setup');
        System.assertEquals(30, insights.get('daysAnalyzed'),
            'Should analyze 30 days');

        // Verify average energy calculation
        Decimal avgEnergy = (Decimal)insights.get('avgEnergy');
        System.assert(avgEnergy > 0 && avgEnergy <= 10,
            'Average energy should be between 0 and 10');

        // Verify rate calculations
        Decimal morningRoutineRate = (Decimal)insights.get('morningRoutineRate');
        System.assert(morningRoutineRate >= 0 && morningRoutineRate <= 100,
            'Morning routine rate should be a percentage');

        Decimal exerciseRate = (Decimal)insights.get('exerciseRate');
        System.assert(exerciseRate >= 0 && exerciseRate <= 100,
            'Exercise rate should be a percentage');

        // Verify mood distribution
        Map<String, Integer> moodDistribution =
            (Map<String, Integer>)insights.get('moodDistribution');
        System.assertNotEquals(null, moodDistribution,
            'Mood distribution should not be null');

        // Verify recommendations exist
        List<String> recommendations =
            (List<String>)insights.get('recommendations');
        System.assertNotEquals(null, recommendations,
            'Recommendations should not be null');
    }

    /**
     * @description Test pattern analysis with no data
     */
    @isTest
    static void testAnalyzeEnergyPatternsWithNoData() {
        // Delete all test data
        delete [SELECT Id FROM Daily_Routine__c];

        Test.startTest();

        Map<String, Object> insights =
            EnergyAdaptiveScheduler.analyzeEnergyPatterns(30);

        Test.stopTest();

        // Verify no data handling
        System.assertEquals(false, insights.get('hasData'),
            'Should indicate no data available');
        System.assert(insights.containsKey('message'),
            'Should provide a message');
        String message = (String)insights.get('message');
        System.assert(message.contains('No data'),
            'Message should mention no data');
    }

    /**
     * @description Test pattern analysis with 7-day window
     */
    @isTest
    static void testAnalyzeEnergyPatternsShortWindow() {
        Test.startTest();

        Map<String, Object> insights =
            EnergyAdaptiveScheduler.analyzeEnergyPatterns(7);

        Test.stopTest();

        System.assertEquals(true, insights.get('hasData'));
        System.assertEquals(7, insights.get('daysAnalyzed'),
            'Should analyze exactly 7 days');
    }

    /**
     * @description Test recommendations vary by morning routine completion
     */
    @isTest
    static void testRecommendationsForLowRoutineCompletion() {
        // Delete test setup data to start fresh
        delete [SELECT Id FROM Daily_Routine__c];

        // Create routines with low completion rate
        List<Daily_Routine__c> routines = new List<Daily_Routine__c>();
        for (Integer i = 0; i < 10; i++) {
            Daily_Routine__c routine = new Daily_Routine__c();
            routine.Date__c = Date.today().addDays(-i);
            routine.Energy_Level_Morning__c = 6;
            routine.Morning_Routine_Complete__c = (i < 3); // Only 30% complete
            routine.Exercise_Completed__c = false;
            routines.add(routine);
        }
        insert routines;

        Test.startTest();

        Map<String, Object> insights =
            EnergyAdaptiveScheduler.analyzeEnergyPatterns(10);

        Test.stopTest();

        Decimal morningRoutineRate = (Decimal)insights.get('morningRoutineRate');
        System.assertEquals(30, morningRoutineRate,
            'Morning routine rate should be 30%');

        List<String> recommendations =
            (List<String>)insights.get('recommendations');
        Boolean hasRoutineRecommendation = false;
        for (String rec : recommendations) {
            if (rec.contains('Morning routine') && rec.contains('below 50%')) {
                hasRoutineRecommendation = true;
                break;
            }
        }
        System.assert(hasRoutineRecommendation,
            'Should recommend improving morning routine');
    }

    /**
     * @description Test recommendations for excellent routine consistency
     */
    @isTest
    static void testRecommendationsForHighRoutineCompletion() {
        // Delete test setup data to start fresh
        delete [SELECT Id FROM Daily_Routine__c];

        // Create routines with high completion rate
        List<Daily_Routine__c> routines = new List<Daily_Routine__c>();
        for (Integer i = 0; i < 10; i++) {
            Daily_Routine__c routine = new Daily_Routine__c();
            routine.Date__c = Date.today().addDays(-i);
            routine.Energy_Level_Morning__c = 7;
            routine.Morning_Routine_Complete__c = (i < 9); // 90% complete
            routine.Exercise_Completed__c = true;
            routines.add(routine);
        }
        insert routines;

        Test.startTest();

        Map<String, Object> insights =
            EnergyAdaptiveScheduler.analyzeEnergyPatterns(10);

        Test.stopTest();

        Decimal morningRoutineRate = (Decimal)insights.get('morningRoutineRate');
        System.assert(morningRoutineRate >= 80,
            'Morning routine rate should be at least 80%');

        List<String> recommendations =
            (List<String>)insights.get('recommendations');
        Boolean hasCongratulations = false;
        for (String rec : recommendations) {
            if (rec.contains('Excellent') && rec.contains('morning routine')) {
                hasCongratulations = true;
                break;
            }
        }
        System.assert(hasCongratulations,
            'Should congratulate on excellent routine consistency');
    }

    /**
     * @description Test boundary: Energy level exactly 8 (edge of High category)
     */
    @isTest
    static void testEnergyBoundaryHighCategory() {
        Daily_Routine__c routine = new Daily_Routine__c();
        routine.Date__c = Date.today();
        routine.Energy_Level_Morning__c = 8; // Exactly on boundary
        routine.Mood__c = 'Great';
        insert routine;

        Test.startTest();

        Map<String, Object> recommendations =
            EnergyAdaptiveScheduler.getScheduleRecommendations(routine.Id);

        Test.stopTest();

        System.assertEquals('High', recommendations.get('energyCategory'),
            'Energy 8 should be High category');
    }

    /**
     * @description Test boundary: Energy level exactly 5 (edge of Medium category)
     */
    @isTest
    static void testEnergyBoundaryMediumCategory() {
        Daily_Routine__c routine = new Daily_Routine__c();
        routine.Date__c = Date.today();
        routine.Energy_Level_Morning__c = 5; // Exactly on boundary
        routine.Mood__c = 'Okay';
        insert routine;

        Test.startTest();

        Map<String, Object> recommendations =
            EnergyAdaptiveScheduler.getScheduleRecommendations(routine.Id);

        Test.stopTest();

        System.assertEquals('Medium', recommendations.get('energyCategory'),
            'Energy 5 should be Medium category');
    }

    /**
     * @description Test boundary: Energy level exactly 2 (edge of Low category)
     */
    @isTest
    static void testEnergyBoundaryLowCategory() {
        Daily_Routine__c routine = new Daily_Routine__c();
        routine.Date__c = Date.today();
        routine.Energy_Level_Morning__c = 2; // Exactly on boundary
        routine.Mood__c = 'Low';
        insert routine;

        Test.startTest();

        Map<String, Object> recommendations =
            EnergyAdaptiveScheduler.getScheduleRecommendations(routine.Id);

        Test.stopTest();

        System.assertEquals('Low', recommendations.get('energyCategory'),
            'Energy 2 should be Low category');
    }
}

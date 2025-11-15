/**
 * @description Test class for MoodTrackerService
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
@isTest
private class MoodTrackerServiceTest {

    @testSetup
    static void setup() {
        // Create test mood entries for 14 days
        List<Mood_Entry__c> moods = new List<Mood_Entry__c>();

        for (Integer i = 0; i < 14; i++) {
            // Create 3 moods per day (morning, afternoon, evening)
            moods.add(new Mood_Entry__c(
                Mood_Score__c = 6 + (i * 0.2), // Gradually improving
                Energy_Score__c = 5,
                Time_of_Day__c = 'Morning',
                Timestamp__c = DateTime.now().addDays(-i).addHours(-12)
            ));

            moods.add(new Mood_Entry__c(
                Mood_Score__c = 7 + (i * 0.2),
                Energy_Score__c = 6,
                Time_of_Day__c = 'Afternoon',
                Timestamp__c = DateTime.now().addDays(-i).addHours(-6)
            ));

            moods.add(new Mood_Entry__c(
                Mood_Score__c = 5 + (i * 0.2),
                Energy_Score__c = 4,
                Time_of_Day__c = 'Evening',
                Timestamp__c = DateTime.now().addDays(-i)
            ));
        }

        insert moods;
    }

    @isTest
    static void testGetWeeklyMoodAverage() {
        Test.startTest();
        Decimal avg = MoodTrackerService.getWeeklyMoodAverage(UserInfo.getUserId());
        Test.stopTest();

        System.assertNotEquals(null, avg, 'Average should not be null');
        System.assert(avg > 0 && avg <= 10, 'Average should be between 1-10');
    }

    @isTest
    static void testGetWeeklyMoodAverage_NoData() {
        delete [SELECT Id FROM Mood_Entry__c];

        Test.startTest();
        Decimal avg = MoodTrackerService.getWeeklyMoodAverage(UserInfo.getUserId());
        Test.stopTest();

        System.assertEquals(null, avg, 'Should return null when no data');
    }

    @isTest
    static void testAnalyzeMoodTrend() {
        Test.startTest();
        String trend = MoodTrackerService.analyzeMoodTrend(UserInfo.getUserId(), 14);
        Test.stopTest();

        System.assertNotEquals(null, trend, 'Trend should not be null');
        System.assert(
            trend == 'Improving' || trend == 'Declining' || trend == 'Stable',
            'Trend should be valid: ' + trend
        );
    }

    @isTest
    static void testAnalyzeMoodTrend_InsufficientData() {
        delete [SELECT Id FROM Mood_Entry__c WHERE CreatedDate != TODAY];

        Test.startTest();
        String trend = MoodTrackerService.analyzeMoodTrend(UserInfo.getUserId(), 7);
        Test.stopTest();

        System.assertEquals('Insufficient data', trend, 'Should return insufficient data');
    }

    @isTest
    static void testFindMoodTriggers() {
        Test.startTest();
        Map<String, Decimal> triggers = MoodTrackerService.findMoodTriggers(UserInfo.getUserId());
        Test.stopTest();

        System.assertNotEquals(null, triggers, 'Triggers map should not be null');
        System.assert(triggers.size() > 0, 'Should have some triggers');
        System.assert(triggers.containsKey('Morning'), 'Should have Morning data');
        System.assert(triggers.containsKey('Afternoon'), 'Should have Afternoon data');
        System.assert(triggers.containsKey('Evening'), 'Should have Evening data');
    }

    @isTest
    static void testGenerateMoodInsights() {
        Test.startTest();
        String insights = MoodTrackerService.generateMoodInsights(UserInfo.getUserId());
        Test.stopTest();

        System.assertNotEquals(null, insights, 'Insights should not be null');
        System.assert(insights.length() > 0, 'Insights should have content');
        System.assert(insights.contains('Weekly average'), 'Should contain weekly average');
        System.assert(insights.contains('Mood trend'), 'Should contain trend');
    }

    @isTest
    static void testGetMoodHistory() {
        Date startDate = Date.today().addDays(-7);
        Date endDate = Date.today();

        Test.startTest();
        List<Mood_Entry__c> moods = MoodTrackerService.getMoodHistory(
            UserInfo.getUserId(),
            startDate,
            endDate
        );
        Test.stopTest();

        System.assert(moods.size() > 0, 'Should return some moods');
        // Should be ordered by timestamp
        if (moods.size() > 1) {
            System.assert(
                moods[0].Timestamp__c <= moods[moods.size() - 1].Timestamp__c,
                'Should be ordered by timestamp ascending'
            );
        }
    }
}

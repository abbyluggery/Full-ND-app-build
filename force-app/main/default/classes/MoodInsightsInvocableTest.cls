/**
 * @description Test class for MoodInsightsInvocable
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
@isTest
private class MoodInsightsInvocableTest {

    @testSetup
    static void setup() {
        // Create daily routine
        Daily_Routine__c routine = new Daily_Routine__c(
            Date__c = Date.today()
        );
        insert routine;

        // Create mood entries for the past week
        List<Mood_Entry__c> moodEntries = new List<Mood_Entry__c>();

        for (Integer i = 0; i < 7; i++) {
            moodEntries.add(new Mood_Entry__c(
                Daily_Routine__c = routine.Id,
                Mood_Score__c = 7 + i * 0.5,
                Energy_Score__c = 6,
                Time_of_Day__c = 'Morning',
                Notes__c = 'Test mood entry ' + i,
                Timestamp__c = DateTime.now().addDays(-i)
            ));
        }

        insert moodEntries;
    }

    @isTest
    static void testGenerateMoodInsights_Success() {
        MoodInsightsInvocable.MoodInsightsRequest request =
            new MoodInsightsInvocable.MoodInsightsRequest();
        request.userId = UserInfo.getUserId();
        request.numberOfDays = 14;

        Test.startTest();
        List<MoodInsightsInvocable.MoodInsightsResult> results =
            MoodInsightsInvocable.generateMoodInsights(new List<MoodInsightsInvocable.MoodInsightsRequest>{request});
        Test.stopTest();

        // Verify
        System.assertEquals(1, results.size(), 'Should return one result');
        MoodInsightsInvocable.MoodInsightsResult result = results[0];
        System.assertNotEquals(null, result.weeklyAverage, 'Should have weekly average');
        System.assertNotEquals(null, result.moodTrend, 'Should have mood trend');
        System.assertNotEquals(null, result.insightsText, 'Should have insights text');
        System.assert(result.insightsText.length() > 0, 'Insights should have content');
    }

    @isTest
    static void testGenerateMoodInsights_DefaultUserId() {
        MoodInsightsInvocable.MoodInsightsRequest request =
            new MoodInsightsInvocable.MoodInsightsRequest();
        // Don't set userId - should default to current user

        Test.startTest();
        List<MoodInsightsInvocable.MoodInsightsResult> results =
            MoodInsightsInvocable.generateMoodInsights(new List<MoodInsightsInvocable.MoodInsightsRequest>{request});
        Test.stopTest();

        // Verify
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertNotEquals(null, results[0].moodTrend, 'Should still get results');
    }

    @isTest
    static void testGenerateMoodInsights_CustomDays() {
        MoodInsightsInvocable.MoodInsightsRequest request =
            new MoodInsightsInvocable.MoodInsightsRequest();
        request.numberOfDays = 7;

        Test.startTest();
        List<MoodInsightsInvocable.MoodInsightsResult> results =
            MoodInsightsInvocable.generateMoodInsights(new List<MoodInsightsInvocable.MoodInsightsRequest>{request});
        Test.stopTest();

        // Verify
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertNotEquals(null, results[0].moodTrend, 'Should analyze 7 days');
    }

    @isTest
    static void testGetWeeklySummary_Success() {
        MoodInsightsInvocable.MoodInsightsRequest request =
            new MoodInsightsInvocable.MoodInsightsRequest();
        request.userId = UserInfo.getUserId();

        Test.startTest();
        List<MoodInsightsInvocable.MoodSummaryResult> results =
            MoodInsightsInvocable.getWeeklySummary(new List<MoodInsightsInvocable.MoodInsightsRequest>{request});
        Test.stopTest();

        // Verify
        System.assertEquals(1, results.size(), 'Should return one result');
        MoodInsightsInvocable.MoodSummaryResult result = results[0];
        System.assertNotEquals(null, result.totalMoodEntries, 'Should have entry count');
        System.assert(result.totalMoodEntries > 0, 'Should have mood entries');
        System.assertNotEquals(null, result.averageMood, 'Should have average mood');
        System.assertNotEquals(null, result.highestMood, 'Should have highest mood');
        System.assertNotEquals(null, result.lowestMood, 'Should have lowest mood');
        System.assertNotEquals(null, result.moodTrend, 'Should have trend');
        System.assertNotEquals(null, result.insightsText, 'Should have insights');
    }

    @isTest
    static void testGetWeeklySummary_NoMoodData() {
        // Delete all mood entries
        delete [SELECT Id FROM Mood_Entry__c];

        MoodInsightsInvocable.MoodInsightsRequest request =
            new MoodInsightsInvocable.MoodInsightsRequest();

        Test.startTest();
        List<MoodInsightsInvocable.MoodSummaryResult> results =
            MoodInsightsInvocable.getWeeklySummary(new List<MoodInsightsInvocable.MoodInsightsRequest>{request});
        Test.stopTest();

        // Verify
        System.assertEquals(1, results.size(), 'Should return one result');
        MoodInsightsInvocable.MoodSummaryResult result = results[0];
        System.assertEquals(0, result.totalMoodEntries, 'Should have zero entries');
        System.assertEquals(null, result.averageMood, 'Should have null average');
    }

    @isTest
    static void testGetWeeklySummary_MultipleRequests() {
        List<MoodInsightsInvocable.MoodInsightsRequest> requests =
            new List<MoodInsightsInvocable.MoodInsightsRequest>();

        for (Integer i = 0; i < 3; i++) {
            MoodInsightsInvocable.MoodInsightsRequest request =
                new MoodInsightsInvocable.MoodInsightsRequest();
            request.userId = UserInfo.getUserId();
            requests.add(request);
        }

        Test.startTest();
        List<MoodInsightsInvocable.MoodSummaryResult> results =
            MoodInsightsInvocable.getWeeklySummary(requests);
        Test.stopTest();

        // Verify
        System.assertEquals(3, results.size(), 'Should return three results');
    }

    @isTest
    static void testMoodTriggersJson() {
        MoodInsightsInvocable.MoodInsightsRequest request =
            new MoodInsightsInvocable.MoodInsightsRequest();

        Test.startTest();
        List<MoodInsightsInvocable.MoodInsightsResult> results =
            MoodInsightsInvocable.generateMoodInsights(new List<MoodInsightsInvocable.MoodInsightsRequest>{request});
        Test.stopTest();

        // Verify JSON is valid
        MoodInsightsInvocable.MoodInsightsResult result = results[0];
        System.assertNotEquals(null, result.moodTriggersJson, 'Should have triggers JSON');

        // Parse to verify it's valid JSON
        Map<String, Object> triggersMap =
            (Map<String, Object>) JSON.deserializeUntyped(result.moodTriggersJson);
        System.assertNotEquals(null, triggersMap, 'Should be valid JSON');
    }
}

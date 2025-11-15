/**
 * @description Invocable wrapper for weekly mood summary (used in email flows)
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
public with sharing class MoodWeeklySummaryInvocable {

    /**
     * @description Request wrapper for weekly summary
     */
    public class SummaryRequest {
        @InvocableVariable(label='User ID' description='The user ID to analyze (defaults to current user)' required=false)
        public Id userId;
    }

    /**
     * @description Result wrapper for mood summary statistics
     */
    public class MoodSummaryResult {
        @InvocableVariable(label='Total Mood Entries' description='Number of mood entries this week')
        public Integer totalMoodEntries;

        @InvocableVariable(label='Average Mood' description='Average mood score')
        public Decimal averageMood;

        @InvocableVariable(label='Highest Mood' description='Highest mood score this week')
        public Decimal highestMood;

        @InvocableVariable(label='Lowest Mood' description='Lowest mood score this week')
        public Decimal lowestMood;

        @InvocableVariable(label='Mood Trend' description='Overall trend')
        public String moodTrend;

        @InvocableVariable(label='Insights Text' description='Full insights text')
        public String insightsText;
    }

    /**
     * @description Get mood summary statistics for email templates
     * @param requests List of request parameters
     * @return List of summary results
     */
    @InvocableMethod(
        label='Get Weekly Mood Summary'
        description='Gets weekly mood statistics for summary emails'
        category='Wellness'
    )
    public static List<MoodSummaryResult> getWeeklySummary(List<SummaryRequest> requests) {
        List<MoodSummaryResult> results = new List<MoodSummaryResult>();

        for (SummaryRequest request : requests) {
            MoodSummaryResult result = new MoodSummaryResult();

            // Use current user if not specified
            Id userId = request.userId != null ? request.userId : UserInfo.getUserId();

            // Get mood data for past week
            List<Mood_Entry__c> moodEntries = MoodTrackerService.getMoodHistory(
                userId,
                Date.today().addDays(-7),
                Date.today()
            );

            result.totalMoodEntries = moodEntries.size();

            if (!moodEntries.isEmpty()) {
                Decimal total = 0;
                Decimal highestMood = 0;
                Decimal lowestMood = 10;

                for (Mood_Entry__c entry : moodEntries) {
                    total += entry.Mood_Score__c;
                    if (entry.Mood_Score__c > highestMood) {
                        highestMood = entry.Mood_Score__c;
                    }
                    if (entry.Mood_Score__c < lowestMood) {
                        lowestMood = entry.Mood_Score__c;
                    }
                }

                result.averageMood = (total / moodEntries.size()).setScale(1);
                result.highestMood = highestMood;
                result.lowestMood = lowestMood;
            }

            result.moodTrend = MoodTrackerService.analyzeMoodTrend(userId, 14);
            result.insightsText = MoodTrackerService.generateMoodInsights(userId);

            results.add(result);
        }

        return results;
    }
}

/**
 * @description Invocable wrapper for MoodTrackerService to be called from Flows
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
public with sharing class MoodInsightsInvocable {

    /**
     * @description Request wrapper for generating mood insights
     */
    public class MoodInsightsRequest {
        @InvocableVariable(label='User ID' description='The user ID to analyze (defaults to current user)' required=false)
        public Id userId;

        @InvocableVariable(label='Number of Days' description='Number of days to analyze (default 14)' required=false)
        public Integer numberOfDays;
    }

    /**
     * @description Result wrapper for mood insights
     */
    public class MoodInsightsResult {
        @InvocableVariable(label='Weekly Mood Average' description='Average mood score for the week')
        public Decimal weeklyAverage;

        @InvocableVariable(label='Mood Trend' description='Mood trend: Improving, Declining, or Stable')
        public String moodTrend;

        @InvocableVariable(label='Full Insights Text' description='Complete mood insights text')
        public String insightsText;

        @InvocableVariable(label='Mood Triggers' description='JSON string of mood triggers by time of day')
        public String moodTriggersJson;
    }

    /**
     * @description Generate mood insights for a user (invocable from Flow)
     * @param requests List of request parameters
     * @return List of mood insights results
     */
    @InvocableMethod(
        label='Generate Mood Insights'
        description='Analyzes mood patterns and generates personalized insights'
        category='Wellness'
    )
    public static List<MoodInsightsResult> generateMoodInsights(List<MoodInsightsRequest> requests) {
        List<MoodInsightsResult> results = new List<MoodInsightsResult>();

        for (MoodInsightsRequest request : requests) {
            MoodInsightsResult result = new MoodInsightsResult();

            // Use current user if not specified
            Id userId = request.userId != null ? request.userId : UserInfo.getUserId();
            Integer days = request.numberOfDays != null ? request.numberOfDays : 14;

            // Get mood insights
            result.weeklyAverage = MoodTrackerService.getWeeklyMoodAverage(userId);
            result.moodTrend = MoodTrackerService.analyzeMoodTrend(userId, days);
            result.insightsText = MoodTrackerService.generateMoodInsights(userId);

            // Get mood triggers and convert to JSON
            Map<String, Decimal> triggers = MoodTrackerService.findMoodTriggers(userId);
            result.moodTriggersJson = JSON.serialize(triggers);

            results.add(result);
        }

        return results;
    }

}

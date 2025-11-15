/**
 * @description Service class to analyze mood patterns, detect trends, and provide insights
 * on mood triggers. Pure analytics - no AI required.
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
public with sharing class MoodTrackerService {

    /**
     * @description Calculate 7-day mood average for a user
     * @param userId The user ID (currently using running user)
     * @return Decimal The average mood score
     */
    public static Decimal getWeeklyMoodAverage(Id userId) {
        List<Mood_Entry__c> moods = getMoodHistory(userId, Date.today().addDays(-7), Date.today());

        if (moods.isEmpty()) {
            return null;
        }

        Decimal total = 0;
        for (Mood_Entry__c mood : moods) {
            total += mood.Mood_Score__c;
        }

        return total / moods.size();
    }

    /**
     * @description Analyze mood trend over specified days
     * @param userId The user ID
     * @param days Number of days to analyze
     * @return String Trend description (improving, declining, stable)
     */
    public static String analyzeMoodTrend(Id userId, Integer days) {
        if (days == null || days < 2) {
            days = 7; // Default to week
        }

        List<Mood_Entry__c> moods = getMoodHistory(userId, Date.today().addDays(-days), Date.today());

        if (moods.size() < 2) {
            return 'Insufficient data';
        }

        // Split into two halves and compare averages
        Integer midpoint = moods.size() / 2;
        Decimal firstHalfAvg = 0;
        Decimal secondHalfAvg = 0;

        for (Integer i = 0; i < midpoint; i++) {
            firstHalfAvg += moods[i].Mood_Score__c;
        }
        firstHalfAvg = firstHalfAvg / midpoint;

        Integer secondHalfSize = moods.size() - midpoint;
        for (Integer i = midpoint; i < moods.size(); i++) {
            secondHalfAvg += moods[i].Mood_Score__c;
        }
        secondHalfAvg = secondHalfAvg / secondHalfSize;

        Decimal difference = secondHalfAvg - firstHalfAvg;

        if (difference > 1.0) {
            return 'Improving';
        } else if (difference < -1.0) {
            return 'Declining';
        } else {
            return 'Stable';
        }
    }

    /**
     * @description Find correlation between activities and mood
     * Currently returns basic statistics about mood by time of day
     * @param userId The user ID
     * @return Map<String, Decimal> Activity-to-mood correlations
     */
    public static Map<String, Decimal> findMoodTriggers(Id userId) {
        Map<String, Decimal> triggers = new Map<String, Decimal>();

        List<Mood_Entry__c> moods = getMoodHistory(userId, Date.today().addDays(-30), Date.today());

        if (moods.isEmpty()) {
            return triggers;
        }

        // Group by time of day
        Map<String, List<Decimal>> moodByTime = new Map<String, List<Decimal>>();

        for (Mood_Entry__c mood : moods) {
            if (String.isNotBlank(mood.Time_of_Day__c)) {
                if (!moodByTime.containsKey(mood.Time_of_Day__c)) {
                    moodByTime.put(mood.Time_of_Day__c, new List<Decimal>());
                }
                moodByTime.get(mood.Time_of_Day__c).add(mood.Mood_Score__c);
            }
        }

        // Calculate averages
        for (String timeOfDay : moodByTime.keySet()) {
            List<Decimal> scores = moodByTime.get(timeOfDay);
            Decimal total = 0;
            for (Decimal score : scores) {
                total += score;
            }
            triggers.put(timeOfDay, total / scores.size());
        }

        return triggers;
    }

    /**
     * @description Generate personalized mood insights
     * @param userId The user ID
     * @return String Insights text
     */
    public static String generateMoodInsights(Id userId) {
        String insights = '';

        Decimal weeklyAvg = getWeeklyMoodAverage(userId);
        String trend = analyzeMoodTrend(userId, 14); // 2 weeks
        Map<String, Decimal> triggers = findMoodTriggers(userId);

        if (weeklyAvg != null) {
            insights += 'Weekly average mood: ' + weeklyAvg.setScale(1) + '/10\n';

            if (weeklyAvg >= 7) {
                insights += 'Your mood has been good this week! ';
            } else if (weeklyAvg >= 5) {
                insights += 'Your mood has been moderate this week. ';
            } else {
                insights += 'Your mood has been lower this week. Consider reaching out for support. ';
            }
        }

        if (String.isNotBlank(trend)) {
            insights += '\nMood trend: ' + trend + '\n';

            if (trend == 'Improving') {
                insights += 'Great job! Keep doing what you\'re doing. ';
            } else if (trend == 'Declining') {
                insights += 'Consider what might be contributing to this decline. ';
            }
        }

        if (!triggers.isEmpty()) {
            insights += '\n\nMood patterns by time of day:\n';
            for (String timeOfDay : triggers.keySet()) {
                insights += '  ' + timeOfDay + ': ' + triggers.get(timeOfDay).setScale(1) + '/10\n';
            }
        }

        return insights;
    }

    /**
     * @description Get mood entries for date range
     * @param userId The user ID
     * @param startDate Start date
     * @param endDate End date
     * @return List<Mood_Entry__c> Mood entries
     */
    public static List<Mood_Entry__c> getMoodHistory(Id userId, Date startDate, Date endDate) {
        return [
            SELECT Id, Mood_Score__c, Energy_Score__c, Notes__c, Time_of_Day__c, Timestamp__c, CreatedDate
            FROM Mood_Entry__c
            WHERE CreatedDate >= :startDate
            AND CreatedDate <= :endDate
            ORDER BY Timestamp__c ASC
        ];
    }
}

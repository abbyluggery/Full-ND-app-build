/**
 * @description Service to manage routine task timing, identify bottlenecks,
 * and optimize morning/evening routines
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
public with sharing class RoutineTaskTimerService {

    /**
     * @description Start task timer
     * @param dailyRoutineId The daily routine ID
     * @param taskName The task name
     * @return Routine_Task_Timer__c The started timer
     */
    public static Routine_Task_Timer__c startTask(Id dailyRoutineId, String taskName) {
        Routine_Task_Timer__c timer = new Routine_Task_Timer__c();
        timer.Daily_Routine__c = dailyRoutineId;
        timer.Task_Name__c = taskName;
        timer.Start_Time__c = DateTime.now();

        // Set expected duration based on historical average
        Decimal avgDuration = getAverageTaskDuration(taskName, 30);
        if (avgDuration != null && avgDuration > 0) {
            timer.Expected_Duration_Minutes__c = avgDuration.intValue();
        }

        insert timer;
        return timer;
    }

    /**
     * @description Stop task timer
     * @param timerId The timer ID
     * @return Routine_Task_Timer__c The stopped timer
     */
    public static Routine_Task_Timer__c stopTask(Id timerId) {
        Routine_Task_Timer__c timer = [
            SELECT Id, End_Time__c
            FROM Routine_Task_Timer__c
            WHERE Id = :timerId
            LIMIT 1
        ];

        timer.End_Time__c = DateTime.now();
        update timer;

        return timer;
    }

    /**
     * @description Calculate average duration for a task over specified days
     * @param taskName The task name
     * @param days Number of days to analyze
     * @return Decimal Average duration in minutes
     */
    public static Decimal getAverageTaskDuration(String taskName, Integer days) {
        Date startDate = Date.today().addDays(-days);

        AggregateResult[] results = [
            SELECT AVG(Duration_Minutes__c) avgDuration
            FROM Routine_Task_Timer__c
            WHERE Task_Name__c = :taskName
            AND CreatedDate >= :startDate
            AND Duration_Minutes__c != null
        ];

        if (results.isEmpty()) {
            return null;
        }

        Object avgObj = results[0].get('avgDuration');
        return avgObj != null ? (Decimal) avgObj : null;
    }

    /**
     * @description Identify bottleneck tasks (taking longer than expected)
     * @param userId User ID
     * @return List<TaskBottleneck> Identified bottlenecks
     */
    public static List<TaskBottleneck> findBottlenecks(Id userId) {
        List<TaskBottleneck> bottlenecks = new List<TaskBottleneck>();

        // Get task statistics for last 30 days
        AggregateResult[] results = [
            SELECT Task_Name__c,
                   AVG(Duration_Minutes__c) avgDuration,
                   AVG(Expected_Duration_Minutes__c) avgExpected,
                   AVG(Delay_Minutes__c) avgDelay,
                   COUNT(Id) taskCount
            FROM Routine_Task_Timer__c
            WHERE CreatedDate = LAST_N_DAYS:30
            AND Was_Skipped__c = false
            AND Duration_Minutes__c != null
            GROUP BY Task_Name__c
            HAVING AVG(Delay_Minutes__c) > 5
            ORDER BY AVG(Delay_Minutes__c) DESC
        ];

        for (AggregateResult result : results) {
            TaskBottleneck bottleneck = new TaskBottleneck();
            bottleneck.taskName = (String) result.get('Task_Name__c');
            bottleneck.avgDuration = (Decimal) result.get('avgDuration');
            bottleneck.expectedDuration = (Decimal) result.get('avgExpected');
            bottleneck.avgDelay = (Decimal) result.get('avgDelay');
            bottleneck.suggestion = generateSuggestion(bottleneck);

            bottlenecks.add(bottleneck);
        }

        return bottlenecks;
    }

    /**
     * @description Generate routine optimization suggestions
     * @param userId User ID
     * @return String Optimization suggestions
     */
    public static String optimizeRoutine(Id userId) {
        List<TaskBottleneck> bottlenecks = findBottlenecks(userId);

        if (bottlenecks.isEmpty()) {
            return 'Your routine is running smoothly! No significant bottlenecks detected.';
        }

        String suggestions = 'Routine Optimization Suggestions:\n\n';

        for (TaskBottleneck bottleneck : bottlenecks) {
            suggestions += '**' + bottleneck.taskName + '**\n';
            suggestions += '  Average time: ' + bottleneck.avgDuration.setScale(1) + ' minutes\n';

            if (bottleneck.expectedDuration != null) {
                suggestions += '  Expected: ' + bottleneck.expectedDuration.setScale(1) + ' minutes\n';
                suggestions += '  Running ' + bottleneck.avgDelay.setScale(1) + ' minutes over\n';
            }

            suggestions += '  Suggestion: ' + bottleneck.suggestion + '\n\n';
        }

        return suggestions;
    }

    /**
     * @description Generate suggestion for a bottleneck
     * @param bottleneck The bottleneck data
     * @return String Suggestion text
     */
    private static String generateSuggestion(TaskBottleneck bottleneck) {
        String taskName = bottleneck.taskName.toLowerCase();

        if (taskName.contains('shower') || taskName.contains('breakfast')) {
            return 'Prep the night before to save time in the morning.';
        } else if (taskName.contains('exercise')) {
            return 'Consider shorter, high-intensity workouts or exercising at a different time.';
        } else if (taskName.contains('planning') || taskName.contains('journaling')) {
            return 'Set a timer to stay focused and avoid spending too much time.';
        } else if (taskName.contains('meditation')) {
            return 'Try shorter guided meditations if time is limited.';
        }

        Decimal delayPercent = (bottleneck.avgDelay / bottleneck.expectedDuration) * 100;

        if (delayPercent > 50) {
            return 'Consider allocating more time for this task or breaking it into smaller steps.';
        } else {
            return 'Look for ways to streamline or prepare this task in advance.';
        }
    }

    /**
     * @description Inner class representing a task bottleneck
     */
    public class TaskBottleneck {
        public String taskName;
        public Decimal avgDuration;
        public Decimal expectedDuration;
        public Decimal avgDelay;
        public String suggestion;

        public TaskBottleneck() {
            this.avgDuration = 0;
            this.avgDelay = 0;
        }
    }
}

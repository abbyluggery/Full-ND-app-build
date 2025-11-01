/**
 * @description Invocable method wrapper for Daily Routine actions
 * Enables Flow integration for creating routines and getting schedule recommendations
 *
 * @author Claude AI Assistant
 * @date 2025-10-29
 */
public with sharing class DailyRoutineInvocable {

    /**
     * @description Creates today's Daily_Routine record and returns energy-adaptive schedule
     * Can be called from Flow for "Log Today's Energy" button
     */
    @InvocableMethod(
        label='Get Energy-Adaptive Schedule'
        description='Creates today\'s routine, gets energy level, and returns adaptive schedule recommendations'
        category='Wellness')
    public static List<Result> getAdaptiveSchedule(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result res = new Result();
            try {
                // Check if today's routine already exists
                List<Daily_Routine__c> existing = [
                    SELECT Id, Energy_Level_Morning__c
                    FROM Daily_Routine__c
                    WHERE Date__c = TODAY
                    LIMIT 1
                ];

                Daily_Routine__c routine;

                if (existing.isEmpty()) {
                    // Create new routine for today
                    routine = new Daily_Routine__c();
                    routine.Date__c = Date.today();
                    routine.Energy_Level_Morning__c = req.energyLevel;
                    routine.Mood__c = req.mood;
                    routine.Morning_Routine_Complete__c = req.morningRoutineComplete;
                    insert routine;
                    res.message = 'Daily routine created successfully!';
                } else {
                    // Update existing routine
                    routine = existing[0];
                    if (req.energyLevel != null) {
                        routine.Energy_Level_Morning__c = req.energyLevel;
                    }
                    if (req.mood != null) {
                        routine.Mood__c = req.mood;
                    }
                    if (req.morningRoutineComplete != null) {
                        routine.Morning_Routine_Complete__c = req.morningRoutineComplete;
                    }
                    update routine;
                    res.message = 'Daily routine updated successfully!';
                }

                // Get energy-adaptive schedule recommendations
                Map<String, Object> recommendations =
                    EnergyAdaptiveScheduler.getScheduleRecommendations(routine.Id);

                // Populate result
                res.dailyRoutineId = routine.Id;
                res.success = true;
                res.energyLevel = (Decimal)recommendations.get('energyLevel');
                res.energyCategory = (String)recommendations.get('energyCategory');
                res.studyHours = (Integer)recommendations.get('studyHours');
                res.jobSearchHours = (Decimal)recommendations.get('jobSearchHours');
                res.applicationGoal = (String)recommendations.get('applicationGoal');
                res.motivationalMessage = (String)recommendations.get('message');

                // Convert schedule list to formatted string
                List<String> scheduleList = (List<String>)recommendations.get('schedule');
                res.todaysSchedule = String.join(scheduleList, '\n');

            } catch (Exception e) {
                res.success = false;
                res.message = 'Error: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR,
                    'Daily routine invocable error: ' + e.getMessage() +
                    '\nStack trace: ' + e.getStackTraceString());
            }

            results.add(res);
        }

        return results;
    }

    /**
     * @description Request wrapper class for input parameters
     */
    public class Request {
        @InvocableVariable(
            label='Energy Level (1-10)'
            description='Your energy level this morning (1=Flare-up, 2-4=Low, 5-7=Medium, 8-10=High)'
            required=true)
        public Decimal energyLevel;

        @InvocableVariable(
            label='Mood'
            description='How are you feeling today?'
            required=false)
        public String mood;

        @InvocableVariable(
            label='Morning Routine Complete'
            description='Did you complete your morning wellness routine?'
            required=false)
        public Boolean morningRoutineComplete;
    }

    /**
     * @description Result wrapper class for output values
     */
    public class Result {
        @InvocableVariable(
            label='Daily Routine ID'
            description='ID of the created or updated Daily Routine record')
        public Id dailyRoutineId;

        @InvocableVariable(
            label='Success'
            description='Whether the operation was successful')
        public Boolean success;

        @InvocableVariable(
            label='Message'
            description='Success or error message')
        public String message;

        @InvocableVariable(
            label='Energy Level'
            description='Your energy level for today')
        public Decimal energyLevel;

        @InvocableVariable(
            label='Energy Category'
            description='Energy category: High, Medium, Low, or Flare-up')
        public String energyCategory;

        @InvocableVariable(
            label='Study Hours Recommended'
            description='Recommended Salesforce study hours for today')
        public Integer studyHours;

        @InvocableVariable(
            label='Job Search Hours Recommended'
            description='Recommended job search hours for today')
        public Decimal jobSearchHours;

        @InvocableVariable(
            label='Application Goal'
            description='Recommended number of applications to send today')
        public String applicationGoal;

        @InvocableVariable(
            label='Today\'s Schedule'
            description='Your personalized schedule for today')
        public String todaysSchedule;

        @InvocableVariable(
            label='Motivational Message'
            description='Personalized message based on your energy')
        public String motivationalMessage;
    }
}

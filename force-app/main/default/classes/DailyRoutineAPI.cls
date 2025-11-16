/**
 * @description REST API for Daily Routine tracking - enables PWA integration
 * @author Abby Luggery / Claude Code Assistant
 * @date November 16, 2025
 *
 * Endpoints:
 * POST   /services/apexrest/dailyroutine - Create/Update daily routine
 * GET    /services/apexrest/dailyroutine - Get today's or date-specific routine
 * GET    /services/apexrest/dailyroutine/patterns - Get energy/mood patterns
 * DELETE /services/apexrest/dailyroutine - Delete a routine record
 */
@RestResource(urlMapping='/dailyroutine/*')
global with sharing class DailyRoutineAPI {

    /**
     * @description Create or update a daily routine record
     * POST /services/apexrest/dailyroutine
     *
     * Request body:
     * {
     *   "date": "2025-11-16",
     *   "morningRoutineComplete": true,
     *   "energyLevel": 7,
     *   "moodLevel": 8,
     *   "mood": "Happy",
     *   "stressLevel": 3,
     *   "sleepHours": 7.5,
     *   "sleepQuality": "Good",
     *   "notes": "Felt great today!",
     *   "tasksCompleted": 5,
     *   "tasksPlanned": 7
     * }
     */
    @HttpPost
    global static ResponseWrapper createOrUpdateRoutine() {
        try {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            // Parse request body
            String requestBody = req.requestBody.toString();
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

            // Extract date (default to today)
            String dateStr = (String) requestData.get('date');
            Date routineDate = dateStr != null ? Date.valueOf(dateStr) : Date.today();

            // Check if routine exists for this date
            List<Daily_Routine__c> existingRoutines = [
                SELECT Id, Date__c, Morning_Routine_Complete__c, Energy_Level__c,
                       Mood_Level__c, Mood__c, Stress_Level__c, Sleep_Hours__c,
                       Sleep_Quality__c, Notes__c, Tasks_Completed__c, Tasks_Planned__c
                FROM Daily_Routine__c
                WHERE Date__c = :routineDate
                AND OwnerId = :UserInfo.getUserId()
                LIMIT 1
            ];

            Daily_Routine__c routine;
            if (existingRoutines.isEmpty()) {
                routine = new Daily_Routine__c();
                routine.Date__c = routineDate;
            } else {
                routine = existingRoutines[0];
            }

            // Update fields from request
            if (requestData.containsKey('morningRoutineComplete')) {
                routine.Morning_Routine_Complete__c = (Boolean) requestData.get('morningRoutineComplete');
            }
            if (requestData.containsKey('energyLevel')) {
                routine.Energy_Level__c = (Decimal) requestData.get('energyLevel');
            }
            if (requestData.containsKey('moodLevel')) {
                routine.Mood_Level__c = (Decimal) requestData.get('moodLevel');
            }
            if (requestData.containsKey('mood')) {
                routine.Mood__c = (String) requestData.get('mood');
            }
            if (requestData.containsKey('stressLevel')) {
                routine.Stress_Level__c = (Decimal) requestData.get('stressLevel');
            }
            if (requestData.containsKey('sleepHours')) {
                routine.Sleep_Hours__c = (Decimal) requestData.get('sleepHours');
            }
            if (requestData.containsKey('sleepQuality')) {
                routine.Sleep_Quality__c = (String) requestData.get('sleepQuality');
            }
            if (requestData.containsKey('notes')) {
                routine.Notes__c = (String) requestData.get('notes');
            }
            if (requestData.containsKey('tasksCompleted')) {
                routine.Tasks_Completed__c = (Decimal) requestData.get('tasksCompleted');
            }
            if (requestData.containsKey('tasksPlanned')) {
                routine.Tasks_Planned__c = (Decimal) requestData.get('tasksPlanned');
            }

            upsert routine;

            res.statusCode = existingRoutines.isEmpty() ? 201 : 200;
            return new ResponseWrapper(true, 'Daily routine saved successfully', routine.Id, routine);

        } catch (Exception e) {
            RestContext.response.statusCode = 400;
            return new ResponseWrapper(false, 'Error saving daily routine: ' + e.getMessage(), null, null);
        }
    }

    /**
     * @description Get daily routine for a specific date or today
     * GET /services/apexrest/dailyroutine?date=2025-11-16
     */
    @HttpGet
    global static ResponseWrapper getRoutine() {
        try {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            // Check for special paths
            String requestPath = req.requestURI;
            if (requestPath.endsWith('/patterns')) {
                return getPatterns();
            }

            // Get date from query parameter (default to today)
            String dateParam = req.params.get('date');
            Date routineDate = dateParam != null ? Date.valueOf(dateParam) : Date.today();

            // Query routine
            List<Daily_Routine__c> routines = [
                SELECT Id, Date__c, Morning_Routine_Complete__c, Energy_Level__c,
                       Mood_Level__c, Mood__c, Stress_Level__c, Sleep_Hours__c,
                       Sleep_Quality__c, Notes__c, Tasks_Completed__c, Tasks_Planned__c,
                       CreatedDate, LastModifiedDate
                FROM Daily_Routine__c
                WHERE Date__c = :routineDate
                AND OwnerId = :UserInfo.getUserId()
                LIMIT 1
            ];

            if (routines.isEmpty()) {
                res.statusCode = 404;
                return new ResponseWrapper(false, 'No routine found for ' + routineDate, null, null);
            }

            res.statusCode = 200;
            return new ResponseWrapper(true, 'Routine retrieved successfully', routines[0].Id, routines[0]);

        } catch (Exception e) {
            RestContext.response.statusCode = 400;
            return new ResponseWrapper(false, 'Error retrieving routine: ' + e.getMessage(), null, null);
        }
    }

    /**
     * @description Get energy and mood patterns over the last 30 days
     * GET /services/apexrest/dailyroutine/patterns
     */
    private static ResponseWrapper getPatterns() {
        try {
            Date thirtyDaysAgo = Date.today().addDays(-30);

            List<Daily_Routine__c> routines = [
                SELECT Id, Date__c, Energy_Level__c, Mood_Level__c, Mood__c,
                       Stress_Level__c, Sleep_Hours__c, Sleep_Quality__c,
                       Morning_Routine_Complete__c, Tasks_Completed__c, Tasks_Planned__c
                FROM Daily_Routine__c
                WHERE Date__c >= :thirtyDaysAgo
                AND OwnerId = :UserInfo.getUserId()
                ORDER BY Date__c DESC
                LIMIT 100
            ];

            // Calculate pattern statistics
            Decimal avgEnergy = 0;
            Decimal avgMood = 0;
            Decimal avgStress = 0;
            Decimal avgSleep = 0;
            Integer routineCompleteCount = 0;
            Integer count = 0;

            for (Daily_Routine__c routine : routines) {
                if (routine.Energy_Level__c != null) {
                    avgEnergy += routine.Energy_Level__c;
                }
                if (routine.Mood_Level__c != null) {
                    avgMood += routine.Mood_Level__c;
                }
                if (routine.Stress_Level__c != null) {
                    avgStress += routine.Stress_Level__c;
                }
                if (routine.Sleep_Hours__c != null) {
                    avgSleep += routine.Sleep_Hours__c;
                }
                if (routine.Morning_Routine_Complete__c == true) {
                    routineCompleteCount++;
                }
                count++;
            }

            Map<String, Object> patterns = new Map<String, Object>();
            if (count > 0) {
                patterns.put('averageEnergy', avgEnergy / count);
                patterns.put('averageMood', avgMood / count);
                patterns.put('averageStress', avgStress / count);
                patterns.put('averageSleep', avgSleep / count);
                patterns.put('routineCompletionRate', (Decimal) routineCompleteCount / count * 100);
                patterns.put('daysTracked', count);
            } else {
                patterns.put('averageEnergy', 0);
                patterns.put('averageMood', 0);
                patterns.put('averageStress', 0);
                patterns.put('averageSleep', 0);
                patterns.put('routineCompletionRate', 0);
                patterns.put('daysTracked', 0);
            }
            patterns.put('history', routines);

            // Get recommendations using EnergyAdaptiveScheduler
            if (count > 0 && routines[0].Energy_Level__c != null && routines[0].Mood__c != null) {
                String recommendations = EnergyAdaptiveScheduler.getRecommendations(
                    Integer.valueOf(routines[0].Energy_Level__c),
                    routines[0].Mood__c
                );
                patterns.put('todayRecommendations', recommendations);
            }

            RestContext.response.statusCode = 200;
            return new ResponseWrapper(true, 'Patterns retrieved successfully', null, patterns);

        } catch (Exception e) {
            RestContext.response.statusCode = 400;
            return new ResponseWrapper(false, 'Error retrieving patterns: ' + e.getMessage(), null, null);
        }
    }

    /**
     * @description Delete a daily routine record
     * DELETE /services/apexrest/dailyroutine?date=2025-11-16
     */
    @HttpDelete
    global static ResponseWrapper deleteRoutine() {
        try {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            String dateParam = req.params.get('date');
            if (dateParam == null) {
                res.statusCode = 400;
                return new ResponseWrapper(false, 'Date parameter is required', null, null);
            }

            Date routineDate = Date.valueOf(dateParam);

            List<Daily_Routine__c> routines = [
                SELECT Id
                FROM Daily_Routine__c
                WHERE Date__c = :routineDate
                AND OwnerId = :UserInfo.getUserId()
                LIMIT 1
            ];

            if (routines.isEmpty()) {
                res.statusCode = 404;
                return new ResponseWrapper(false, 'No routine found for ' + routineDate, null, null);
            }

            delete routines;

            res.statusCode = 200;
            return new ResponseWrapper(true, 'Routine deleted successfully', null, null);

        } catch (Exception e) {
            RestContext.response.statusCode = 400;
            return new ResponseWrapper(false, 'Error deleting routine: ' + e.getMessage(), null, null);
        }
    }

    /**
     * @description Wrapper class for API responses
     */
    global class ResponseWrapper {
        public Boolean success;
        public String message;
        public String recordId;
        public Object data;

        public ResponseWrapper(Boolean success, String message, String recordId, Object data) {
            this.success = success;
            this.message = message;
            this.recordId = recordId;
            this.data = data;
        }
    }
}

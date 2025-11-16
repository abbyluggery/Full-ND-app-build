/**
 * @description Test class for DailyRoutineAPI
 * @author Abby Luggery / Claude Code Assistant
 * @date November 16, 2025
 */
@isTest
private class DailyRoutineAPITest {

    @testSetup
    static void setup() {
        // Create test daily routine records
        List<Daily_Routine__c> routines = new List<Daily_Routine__c>();

        for (Integer i = 0; i < 15; i++) {
            Daily_Routine__c routine = new Daily_Routine__c(
                Date__c = Date.today().addDays(-i),
                Morning_Routine_Complete__c = math.mod(i, 2) == 0,
                Energy_Level__c = 5 + math.mod(i, 5),
                Mood_Level__c = 6 + math.mod(i, 4),
                Mood__c = math.mod(i, 2) == 0 ? 'Happy' : 'Calm',
                Stress_Level__c = 3 + math.mod(i, 7),
                Sleep_Hours__c = 6.5 + (math.mod(i, 3) * 0.5),
                Sleep_Quality__c = math.mod(i, 2) == 0 ? 'Good' : 'Fair',
                Tasks_Completed__c = 3 + math.mod(i, 5),
                Tasks_Planned__c = 5 + math.mod(i, 3),
                Notes__c = 'Test notes for day ' + i
            );
            routines.add(routine);
        }

        insert routines;
    }

    @isTest
    static void testCreateNewRoutine() {
        // Setup REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dailyroutine';
        req.httpMethod = 'POST';

        // Create request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'date' => String.valueOf(Date.today().addDays(10)),
            'morningRoutineComplete' => true,
            'energyLevel' => 8,
            'moodLevel' => 9,
            'mood' => 'Energized',
            'stressLevel' => 2,
            'sleepHours' => 8.0,
            'sleepQuality' => 'Excellent',
            'notes' => 'Great day!',
            'tasksCompleted' => 10,
            'tasksPlanned' => 10
        };

        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        DailyRoutineAPI.ResponseWrapper response = DailyRoutineAPI.createOrUpdateRoutine();
        Test.stopTest();

        // Verify response
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertNotEquals(null, response.recordId, 'Record ID should be returned');
        System.assertEquals(201, res.statusCode, 'Status code should be 201 for new record');

        // Verify record was created
        Daily_Routine__c routine = [SELECT Id, Energy_Level__c, Mood__c FROM Daily_Routine__c WHERE Id = :response.recordId];
        System.assertEquals(8, routine.Energy_Level__c, 'Energy level should match');
        System.assertEquals('Energized', routine.Mood__c, 'Mood should match');
    }

    @isTest
    static void testUpdateExistingRoutine() {
        // Get existing routine
        Daily_Routine__c existingRoutine = [SELECT Id, Date__c, Energy_Level__c FROM Daily_Routine__c WHERE Date__c = :Date.today() LIMIT 1];

        // Setup REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dailyroutine';
        req.httpMethod = 'POST';

        // Create request body to update
        Map<String, Object> requestBody = new Map<String, Object>{
            'date' => String.valueOf(Date.today()),
            'energyLevel' => 10,
            'moodLevel' => 10,
            'mood' => 'Excellent'
        };

        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        DailyRoutineAPI.ResponseWrapper response = DailyRoutineAPI.createOrUpdateRoutine();
        Test.stopTest();

        // Verify response
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals(200, res.statusCode, 'Status code should be 200 for updated record');

        // Verify record was updated
        Daily_Routine__c routine = [SELECT Id, Energy_Level__c, Mood__c FROM Daily_Routine__c WHERE Date__c = :Date.today()];
        System.assertEquals(10, routine.Energy_Level__c, 'Energy level should be updated');
        System.assertEquals('Excellent', routine.Mood__c, 'Mood should be updated');
    }

    @isTest
    static void testGetRoutineToday() {
        // Setup REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dailyroutine';
        req.httpMethod = 'GET';
        req.params = new Map<String, String>();

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        DailyRoutineAPI.ResponseWrapper response = DailyRoutineAPI.getRoutine();
        Test.stopTest();

        // Verify response
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        System.assertNotEquals(null, response.data, 'Data should be returned');

        // Verify data
        Daily_Routine__c routine = (Daily_Routine__c) response.data;
        System.assertEquals(Date.today(), routine.Date__c, 'Should return today\'s routine');
    }

    @isTest
    static void testGetRoutineSpecificDate() {
        Date targetDate = Date.today().addDays(-5);

        // Setup REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dailyroutine';
        req.httpMethod = 'GET';
        req.params = new Map<String, String>{
            'date' => String.valueOf(targetDate)
        };

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        DailyRoutineAPI.ResponseWrapper response = DailyRoutineAPI.getRoutine();
        Test.stopTest();

        // Verify response
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals(200, res.statusCode, 'Status code should be 200');

        // Verify correct date
        Daily_Routine__c routine = (Daily_Routine__c) response.data;
        System.assertEquals(targetDate, routine.Date__c, 'Should return routine for specified date');
    }

    @isTest
    static void testGetRoutineNotFound() {
        Date futureDate = Date.today().addDays(100);

        // Setup REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dailyroutine';
        req.httpMethod = 'GET';
        req.params = new Map<String, String>{
            'date' => String.valueOf(futureDate)
        };

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        DailyRoutineAPI.ResponseWrapper response = DailyRoutineAPI.getRoutine();
        Test.stopTest();

        // Verify response
        System.assertEquals(false, response.success, 'Response should indicate not found');
        System.assertEquals(404, res.statusCode, 'Status code should be 404');
    }

    @isTest
    static void testGetPatterns() {
        // Setup REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dailyroutine/patterns';
        req.httpMethod = 'GET';
        req.params = new Map<String, String>();

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        DailyRoutineAPI.ResponseWrapper response = DailyRoutineAPI.getRoutine();
        Test.stopTest();

        // Verify response
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        System.assertNotEquals(null, response.data, 'Data should be returned');

        // Verify pattern data
        Map<String, Object> patterns = (Map<String, Object>) response.data;
        System.assert(patterns.containsKey('averageEnergy'), 'Should include average energy');
        System.assert(patterns.containsKey('averageMood'), 'Should include average mood');
        System.assert(patterns.containsKey('averageStress'), 'Should include average stress');
        System.assert(patterns.containsKey('averageSleep'), 'Should include average sleep');
        System.assert(patterns.containsKey('routineCompletionRate'), 'Should include completion rate');
        System.assert(patterns.containsKey('daysTracked'), 'Should include days tracked');
        System.assert(patterns.containsKey('history'), 'Should include history');

        Integer daysTracked = (Integer) patterns.get('daysTracked');
        System.assert(daysTracked > 0, 'Should have tracked days');
    }

    @isTest
    static void testDeleteRoutine() {
        Date targetDate = Date.today().addDays(-3);

        // Setup REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dailyroutine';
        req.httpMethod = 'DELETE';
        req.params = new Map<String, String>{
            'date' => String.valueOf(targetDate)
        };

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        DailyRoutineAPI.ResponseWrapper response = DailyRoutineAPI.deleteRoutine();
        Test.stopTest();

        // Verify response
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals(200, res.statusCode, 'Status code should be 200');

        // Verify record was deleted
        List<Daily_Routine__c> routines = [SELECT Id FROM Daily_Routine__c WHERE Date__c = :targetDate];
        System.assertEquals(0, routines.size(), 'Routine should be deleted');
    }

    @isTest
    static void testDeleteRoutineNotFound() {
        Date futureDate = Date.today().addDays(100);

        // Setup REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dailyroutine';
        req.httpMethod = 'DELETE';
        req.params = new Map<String, String>{
            'date' => String.valueOf(futureDate)
        };

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        DailyRoutineAPI.ResponseWrapper response = DailyRoutineAPI.deleteRoutine();
        Test.stopTest();

        // Verify response
        System.assertEquals(false, response.success, 'Response should indicate not found');
        System.assertEquals(404, res.statusCode, 'Status code should be 404');
    }

    @isTest
    static void testDeleteRoutineMissingDate() {
        // Setup REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dailyroutine';
        req.httpMethod = 'DELETE';
        req.params = new Map<String, String>();

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        DailyRoutineAPI.ResponseWrapper response = DailyRoutineAPI.deleteRoutine();
        Test.stopTest();

        // Verify response
        System.assertEquals(false, response.success, 'Response should indicate error');
        System.assertEquals(400, res.statusCode, 'Status code should be 400');
    }

    @isTest
    static void testCreateRoutineWithInvalidData() {
        // Setup REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dailyroutine';
        req.httpMethod = 'POST';

        // Invalid JSON
        req.requestBody = Blob.valueOf('{invalid json}');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        DailyRoutineAPI.ResponseWrapper response = DailyRoutineAPI.createOrUpdateRoutine();
        Test.stopTest();

        // Verify error response
        System.assertEquals(false, response.success, 'Response should indicate error');
        System.assertEquals(400, res.statusCode, 'Status code should be 400');
    }
}

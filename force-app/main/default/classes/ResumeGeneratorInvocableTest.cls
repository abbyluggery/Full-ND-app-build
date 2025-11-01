/**
 * @description Test class for ResumeGeneratorInvocable
 * Tests invocable method for Flow integration
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-10-29
 */
@isTest
private class ResumeGeneratorInvocableTest {

    /**
     * @description Mock HTTP callout for resume generation
     */
    private class InvocableMockSuccess implements HttpCalloutMock {
        private Integer callCount = 0;

        public HTTPResponse respond(HTTPRequest req) {
            callCount++;

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String responseText = (callCount == 1) ?
                'JOHN DOE\\nSalesforce Developer\\n\\nEXPERIENCE...' :
                'Dear Hiring Manager,\\n\\nI am interested...';

            String responseBody = '{' +
                '"id": "msg_invocable_' + callCount + '",' +
                '"type": "message",' +
                '"role": "assistant",' +
                '"content": [{"type": "text", "text": "' + responseText + '"}],' +
                '"model": "claude-3-haiku-20240307",' +
                '"stop_reason": "end_turn",' +
                '"usage": {"input_tokens": 200, "output_tokens": 150}' +
            '}';

            res.setBody(responseBody);
            return res;
        }
    }

    /**
     * @description Test successful invocable method execution
     */
    @isTest
    static void testGenerateResumePackages_Success() {
        Test.setMock(HttpCalloutMock.class, new InvocableMockSuccess());

        // Create test data
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Salesforce Developer',
            Company__c = 'Tech Company',
            Location__c = 'Remote',
            Description__c = 'Great opportunity'
        );
        insert testJob;

        Master_Resume_Config__c masterResume = new Master_Resume_Config__c(
            Resume_Content__c = 'JOHN DOE\nSalesforce Developer\nExperience...'
        );
        insert masterResume;

        // Create invocable request
        ResumeGeneratorInvocable.Request request = new ResumeGeneratorInvocable.Request();
        request.jobPostingId = testJob.Id;

        List<ResumeGeneratorInvocable.Request> requests = new List<ResumeGeneratorInvocable.Request>();
        requests.add(request);

        Test.startTest();

        List<ResumeGeneratorInvocable.Result> results = ResumeGeneratorInvocable.generateResumePackages(requests);

        Test.stopTest();

        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].success, 'Generation should be successful');
        System.assertNotEquals(null, results[0].resumePackageId, 'Should return resume package ID');
        System.assert(results[0].message.contains('successfully'), 'Success message should be positive');

        // Verify resume package was created
        List<Resume_Package__c> packages = [SELECT Id FROM Resume_Package__c WHERE Job_Posting__c = :testJob.Id];
        System.assertEquals(1, packages.size(), 'Should create one resume package');
    }

    /**
     * @description Test invocable method with multiple requests
     */
    @isTest
    static void testGenerateResumePackages_MultipleJobs() {
        Test.setMock(HttpCalloutMock.class, new InvocableMockSuccess());

        // Create test data
        Job_Posting__c job1 = new Job_Posting__c(
            Title__c = 'Job 1',
            Company__c = 'Company 1',
            Location__c = 'Remote'
        );
        Job_Posting__c job2 = new Job_Posting__c(
            Title__c = 'Job 2',
            Company__c = 'Company 2',
            Location__c = 'Remote'
        );
        insert new List<Job_Posting__c>{job1, job2};

        Master_Resume_Config__c masterResume = new Master_Resume_Config__c(
            Resume_Content__c = 'Test resume content'
        );
        insert masterResume;

        // Create multiple requests
        List<ResumeGeneratorInvocable.Request> requests = new List<ResumeGeneratorInvocable.Request>();

        ResumeGeneratorInvocable.Request req1 = new ResumeGeneratorInvocable.Request();
        req1.jobPostingId = job1.Id;
        requests.add(req1);

        ResumeGeneratorInvocable.Request req2 = new ResumeGeneratorInvocable.Request();
        req2.jobPostingId = job2.Id;
        requests.add(req2);

        Test.startTest();

        List<ResumeGeneratorInvocable.Result> results = ResumeGeneratorInvocable.generateResumePackages(requests);

        Test.stopTest();

        // Verify results
        System.assertEquals(2, results.size(), 'Should return two results');
        System.assertEquals(true, results[0].success, 'First generation should succeed');
        System.assertEquals(true, results[1].success, 'Second generation should succeed');

        // Verify resume packages were created
        List<Resume_Package__c> packages = [SELECT Id FROM Resume_Package__c];
        System.assertEquals(2, packages.size(), 'Should create two resume packages');
    }

    /**
     * @description Test error handling in invocable method
     */
    @isTest
    static void testGenerateResumePackages_Error() {
        // No master resume configured - should cause error

        // Create test job
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Test Job',
            Company__c = 'Test Company',
            Location__c = 'Remote'
        );
        insert testJob;

        // Create request
        ResumeGeneratorInvocable.Request request = new ResumeGeneratorInvocable.Request();
        request.jobPostingId = testJob.Id;

        List<ResumeGeneratorInvocable.Request> requests = new List<ResumeGeneratorInvocable.Request>();
        requests.add(request);

        Test.startTest();

        List<ResumeGeneratorInvocable.Result> results = ResumeGeneratorInvocable.generateResumePackages(requests);

        Test.stopTest();

        // Verify error handling
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(false, results[0].success, 'Generation should fail');
        System.assertEquals(null, results[0].resumePackageId, 'Should not have resume package ID');
        System.assert(results[0].message.contains('Error'), 'Should return error message');
    }

    /**
     * @description Test API error handling in invocable method
     */
    @isTest
    static void testGenerateResumePackages_APIError() {
        Test.setMock(HttpCalloutMock.class, new APIErrorMock());

        // Create test data
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Test Job',
            Company__c = 'Test Company',
            Location__c = 'Remote'
        );
        insert testJob;

        Master_Resume_Config__c masterResume = new Master_Resume_Config__c(
            Resume_Content__c = 'Test resume'
        );
        insert masterResume;

        // Create request
        ResumeGeneratorInvocable.Request request = new ResumeGeneratorInvocable.Request();
        request.jobPostingId = testJob.Id;

        List<ResumeGeneratorInvocable.Request> requests = new List<ResumeGeneratorInvocable.Request>();
        requests.add(request);

        Test.startTest();

        List<ResumeGeneratorInvocable.Result> results = ResumeGeneratorInvocable.generateResumePackages(requests);

        Test.stopTest();

        // Verify error was caught and returned
        System.assertEquals(false, results[0].success, 'Should report failure');
        System.assert(results[0].message.contains('Error'), 'Should include error message');
    }

    /**
     * @description Mock for API error
     */
    private class APIErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error": "Internal error"}');
            return res;
        }
    }
}

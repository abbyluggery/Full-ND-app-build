@isTest
private class JobPostingAPITest {

    @isTest
    static void testCreateJobPosting() {
        // Create test request
        JobPostingAPI.JobPostingRequest request = new JobPostingAPI.JobPostingRequest();
        request.title = 'Senior Salesforce Developer';
        request.company = 'Test Company Inc';
        request.location = 'Remote - USA';
        request.description = 'Great remote Salesforce job with flexible hours and Agentforce focus.';
        request.applyUrl = 'https://test.com/job/123';
        request.provider = 'LinkedIn';
        request.externalId = 'test_123';
        request.salaryMin = '95000';
        request.salaryMax = '125000';
        request.currencyCode = 'USD';
        request.salaryInterval = 'Yearly';

        // Setup REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/jobposting/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        JobPostingAPI.JobPostingResponse response = JobPostingAPI.createJobPosting(request);
        Test.stopTest();

        // Verify response
        System.assert(response.success, 'Job posting creation should succeed');
        System.assertNotEquals(null, response.jobId, 'Job ID should be returned');
        System.assert(response.message.contains('successfully'), 'Success message should be returned');

        // Verify job was created
        Job_Posting__c job = [SELECT Id, Title__c, Company__c, Location__c, Status__c,
                                      Salary_Min__c, Salary_Max__c, Workplace_Type__c
                               FROM Job_Posting__c
                               WHERE Id = :response.jobId];

        System.assertEquals('Senior Salesforce Developer', job.Title__c);
        System.assertEquals('Test Company Inc', job.Company__c);
        System.assertEquals('Active', job.Status__c);
        System.assertEquals(95000, job.Salary_Min__c);
        System.assertEquals(125000, job.Salary_Max__c);
        System.assertEquals('Remote', job.Workplace_Type__c);
    }

    @isTest
    static void testWorkplaceTypeDetection() {
        JobPostingAPI.JobPostingRequest remoteRequest = new JobPostingAPI.JobPostingRequest();
        remoteRequest.title = 'Remote Developer';
        remoteRequest.company = 'Test Co';
        remoteRequest.location = 'Remote';
        remoteRequest.description = 'Work from home';
        remoteRequest.applyUrl = 'https://test.com';
        remoteRequest.externalId = 'remote_test';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        JobPostingAPI.JobPostingResponse response = JobPostingAPI.createJobPosting(remoteRequest);
        Test.stopTest();

        Job_Posting__c job = [SELECT Workplace_Type__c FROM Job_Posting__c WHERE Id = :response.jobId];
        System.assertEquals('Remote', job.Workplace_Type__c);
    }

    @isTest
    static void testErrorHandling() {
        // Create invalid request (missing required fields)
        JobPostingAPI.JobPostingRequest request = new JobPostingAPI.JobPostingRequest();
        // Intentionally leave title and company null

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        JobPostingAPI.JobPostingResponse response = JobPostingAPI.createJobPosting(request);
        Test.stopTest();

        // Should fail gracefully
        System.assertEquals(false, response.success, 'Should fail with missing required fields');
        System.assert(response.message.contains('Error'), 'Error message should be returned');
    }
}

// TEST JobPostingAPI
// Run this in Developer Console > Debug > Execute Anonymous Window

RestRequest req = new RestRequest();
RestResponse res = new RestResponse();
req.requestURI = '/services/apexrest/jobposting/';
req.httpMethod = 'POST';
RestContext.request = req;
RestContext.response = res;

JobPostingAPI.JobPostingRequest testReq = new JobPostingAPI.JobPostingRequest();
testReq.title = 'API Test - Salesforce Developer';
testReq.company = 'Test Company via API';
testReq.location = 'Remote';
testReq.description = 'Testing the JobPostingAPI endpoint - this job will be analyzed by Claude AI automatically!';
testReq.applyUrl = 'https://test.com/api-test-job';
testReq.provider = 'LinkedIn';
testReq.externalId = 'api_test_' + System.now().getTime();
testReq.salaryMin = '100000';
testReq.salaryMax = '130000';
testReq.currencyCode = 'USD';
testReq.salaryInterval = 'Yearly';

JobPostingAPI.JobPostingResponse response = JobPostingAPI.createJobPosting(testReq);

System.debug('=== JobPostingAPI Test Results ===');
System.debug('Success: ' + response.success);
System.debug('Job ID: ' + response.jobId);
System.debug('Message: ' + response.message);

if (response.success) {
    System.debug('');
    System.debug('✓ SUCCESS! JobPostingAPI is working!');
    System.debug('✓ Job was created with ID: ' + response.jobId);
    System.debug('✓ Claude AI analysis was triggered automatically');
    System.debug('');
    System.debug('Next: Check Job_Posting__c record to see Claude\'s analysis');
} else {
    System.debug('');
    System.debug('✗ ERROR: ' + response.message);
}

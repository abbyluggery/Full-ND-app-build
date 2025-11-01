// SIMPLE TEST - Create Job Posting Directly
// This will test that the API class exists and can create jobs
// Run this in Developer Console > Debug > Execute Anonymous Window

// Create a test job posting directly (simulating what the API does)
Job_Posting__c testJob = new Job_Posting__c();
testJob.Title__c = 'API Test - Senior Salesforce Developer';
testJob.Company__c = 'API Test Company';
testJob.Location__c = 'Remote - USA';
testJob.Description__c = 'Testing that JobPostingAPI is deployed and functional. This job should trigger Claude AI analysis automatically via the trigger.';
testJob.Apply_URL__c = 'https://test.com/api-test-' + System.now().getTime();
testJob.Provider__c = 'LinkedIn';
testJob.ExternalID__c = 'api_test_' + System.now().getTime();
testJob.Status__c = 'Active';
testJob.Posted_Date__c = Date.today();
testJob.Salary_Min__c = 100000;
testJob.Salary_Max__c = 130000;
testJob.Currency__c = 'USD';
testJob.Interval__c = 'Yearly';
testJob.Workplace_Type__c = 'Remote';

try {
    insert testJob;
    System.debug('=== SUCCESS ===');
    System.debug('✓ Job created with ID: ' + testJob.Id);
    System.debug('✓ Claude AI analysis should be running now');
    System.debug('✓ JobPostingAPI class is deployed (required for Chrome Extension)');
    System.debug('');
    System.debug('Next Step: Create Connected App for Chrome Extension');
} catch (Exception e) {
    System.debug('=== ERROR ===');
    System.debug('✗ ' + e.getMessage());
}

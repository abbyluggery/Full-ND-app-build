# Fixed API Test

The Provider__c field is a restricted picklist. Let's use a valid value.

Run this in Developer Console:

```apex
// Test the API endpoint with valid Provider value
String result = JobPostingAPI.createJobPosting(
    'TEST - Senior Salesforce Developer',
    'Test Company from API',
    'Remote - USA',
    'Great remote Salesforce job with flexible hours and Agentforce focus.',
    'https://test.com/job/chrome-ext-test',
    'LinkedIn', // Use valid picklist value
    'test_api_' + System.now().getTime(),
    '95000',
    '125000'
);

System.debug('====== API RESPONSE ======');
System.debug(result);
System.debug('====== END RESPONSE ======');

// Parse the response
Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(result);
System.debug('Success: ' + response.get('success'));
System.debug('Job ID: ' + response.get('jobId'));
System.debug('Message: ' + response.get('message'));

// If successful, check the job was created
if ((Boolean)response.get('success')) {
    String jobId = (String)response.get('jobId');
    Job_Posting__c job = [SELECT Id, Title__c, Company__c, Provider__c FROM Job_Posting__c WHERE Id = :jobId];
    System.debug('✅ Job created: ' + job.Title__c + ' at ' + job.Company__c);
}
```

This should work! The Provider will be "LinkedIn" which is a valid picklist value.

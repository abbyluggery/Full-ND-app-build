# Debug JSON Extraction

Run this to see exactly what Claude is returning and what we're trying to parse:

```apex
// 1. Create test job
Job_Posting__c testJob = new Job_Posting__c(
    Title__c = 'DEBUG TEST - Remote Developer',
    Company__c = 'Test Company',
    Location__c = 'Remote',
    Workplace_Type__c = 'Remote',
    Remote_Policy__c = 'Fully Remote',
    Salary_Min__c = 90000,
    Salary_Max__c = 120000,
    Description__c = 'Remote Salesforce developer position. Flexible hours, async-first culture.',
    Status__c = 'Active',
    Posted_Date__c = Date.today(),
    Apply_URL__c = 'https://test.com/job',
    Provider__c = 'LinkedIn',
    ExternalID__c = 'DEBUG_TEST_' + System.now().getTime()
);

// 2. Get system context
String systemContext = JobPostingAnalyzer.buildHolisticSystemContext();

// 3. Call Claude
ClaudeAPIService.ClaudeResponse response = ClaudeAPIService.analyzeJobPosting(testJob, systemContext);

// 4. Extract text
String responseText = ClaudeAPIService.extractTextContent(response);

System.debug('====== RAW RESPONSE TEXT ======');
System.debug(responseText);
System.debug('====== END RAW RESPONSE ======');

// 5. Try to extract JSON
String jsonText = responseText;
Integer jsonStart = responseText.indexOf('```json');
if (jsonStart != -1) {
    jsonStart = responseText.indexOf('\n', jsonStart) + 1;
    Integer jsonEnd = responseText.indexOf('```', jsonStart);
    if (jsonEnd != -1) {
        jsonText = responseText.substring(jsonStart, jsonEnd).trim();
    }
}

System.debug('====== EXTRACTED JSON ======');
System.debug(jsonText);
System.debug('====== END EXTRACTED JSON ======');

// 6. Try to parse
try {
    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
    System.debug('✅ JSON PARSED SUCCESSFULLY!');
    System.debug('fit_score: ' + jsonMap.get('fit_score'));
    System.debug('nd_friendliness_score: ' + jsonMap.get('nd_friendliness_score'));
} catch (Exception e) {
    System.debug('❌ JSON PARSE FAILED: ' + e.getMessage());
}
```

This will show us the exact response and where the parsing is failing.

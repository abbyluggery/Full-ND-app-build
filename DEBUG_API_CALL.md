# Debug API Call Test

Run this in Developer Console to see EXACTLY what's happening with the Claude API:

```apex
// 1. Create a minimal test job posting
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

// 2. Call the analyzer DIRECTLY (bypassing the queue) to see the raw response
System.debug('====== STARTING ANALYSIS ======');

try {
    JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(testJob);

    System.debug('✅ SUCCESS! Analysis completed:');
    System.debug('Fit Score: ' + result.fitScore);
    System.debug('ND Friendliness: ' + result.ndFriendlinessScore);
    System.debug('Green Flags: ' + result.greenFlags);
    System.debug('Red Flags: ' + result.redFlags);

} catch (Exception e) {
    System.debug('❌ FAILED with error:');
    System.debug('Type: ' + e.getTypeName());
    System.debug('Message: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
}

System.debug('====== END ANALYSIS ======');
```

## What This Tests

1. **Direct API call** - Bypasses queue to see immediate results
2. **Full error details** - Shows exact exception if it fails
3. **Raw response** - Shows what Claude actually returns

## Expected Outcomes

**If it works:**
- You'll see "✅ SUCCESS!" with fit scores and flags
- This means the API is working but queue might have an issue

**If it fails:**
- You'll see "❌ FAILED" with the exact error message
- Common errors:
  - "Claude API returned status 400" → JSON format issue
  - "Claude API returned status 401" → API key issue
  - "Unauthorized endpoint" → Remote Site Settings issue

## Next Steps Based on Results

Run this and paste the debug output here. The error message will tell us exactly what to fix!

# Test JobPostingAnalyzer Class

Now that Claude API is working, let's test the full JobPostingAnalyzer class!

## Step 1: Create a Test Job Posting Record

```apex
// Create a test job posting
Job_Posting__c testJob = new Job_Posting__c(
    Title__c = 'Senior Salesforce Developer - Agentforce Team',
    Company__c = 'InnovateCo',
    Location__c = 'Remote USA',
    Workplace_Type__c = 'Remote',
    Remote_Policy__c = 'Remote-first, async communication, no required meetings before 10am',
    Salary_Min__c = 120000,
    Salary_Max__c = 145000,
    Description__c = 'Join our AI innovation team building cutting-edge Agentforce solutions. ' +
                     'We value neurodiversity and offer flexible schedules, unlimited PTO, and async-first culture. ' +
                     'Work on autonomous agents using Claude API, Prompt Builder, and Model Builder. ' +
                     'Strong emphasis on work-life balance and mental health support.',
    Status__c = 'Active',
    Posted_Date__c = Date.today()
);

insert testJob;
System.debug('Created Job Posting: ' + testJob.Id);
```

## Step 2: Test the Analyzer

```apex
// Get the job posting we just created
Job_Posting__c job = [SELECT Id, Title__c, Company__c, Location__c, Workplace_Type__c,
                              Remote_Policy__c, Salary_Min__c, Salary_Max__c, Description__c
                       FROM Job_Posting__c
                       WHERE Company__c = 'InnovateCo'
                       LIMIT 1];

System.debug('Testing analyzer with job: ' + job.Title__c);

try {
    // Call the analyzer
    JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJobPosting(job);

    System.debug('\n=== JOB ANALYSIS RESULT ===');
    System.debug('Fit Score: ' + result.fitScore);
    System.debug('ND Friendliness: ' + result.ndFriendlinessScore);
    System.debug('Recommendation: ' + result.recommendation);
    System.debug('Reasoning: ' + result.reasoning);
    System.debug('\nGreen Flags:');
    for (String flag : result.greenFlags) {
        System.debug('  ✓ ' + flag);
    }
    System.debug('\nRed Flags:');
    for (String flag : result.redFlags) {
        System.debug('  ✗ ' + flag);
    }
    System.debug('=== END RESULT ===\n');

    // Update the job posting record with the analysis
    job.Fit_Score__c = result.fitScore;
    job.Application_Status__c = 'Not Applied';
    update job;

    System.debug('Job posting updated with analysis!');

} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
```

## Step 3: View the Updated Record

After running the test, go to your Salesforce org and find the Job Posting record:

1. **App Launcher** → Search for "Job Postings"
2. Click on the **InnovateCo** job
3. You should see:
   - **Fit Score:** 9.5
   - **Application Status:** Not Applied

## Expected Result

```
=== JOB ANALYSIS RESULT ===
Fit Score: 9.5
ND Friendliness: 9
Recommendation: HIGH PRIORITY
Reasoning: This job posting is an excellent fit for Abby's requirements...

Green Flags:
  ✓ Fully remote
  ✓ Agentforce focus
  ✓ ND-friendly culture
  ✓ No required meetings before 10am
  ✓ Flexible schedule
  ✓ Competitive salary range

Red Flags:
  ✗ Startup pace may be fast

=== END RESULT ===

Job posting updated with analysis!
```

## Troubleshooting

**If you get "We couldn't access the credential(s)":**
- The JobPostingAnalyzer is trying to use Named Credential
- You need to temporarily bypass it by modifying ClaudeAPIService to use direct API key
- Or set up Named Credential first (see FIX_NAMED_CREDENTIAL.md)

**If you get "Invalid type: JobPostingAnalyzer.JobAnalysisResult":**
- Make sure both classes are deployed (we did this earlier)
- Try refreshing your Developer Console

**If you get field errors:**
- Make sure Fit_Score__c and Application_Status__c fields are deployed

---

**Run Step 1 first to create the job, then Step 2 to analyze it!**

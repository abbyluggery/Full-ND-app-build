# Test Direct Endpoint Approach

I've updated ClaudeAPIService to bypass Named Credential and use direct endpoint (like your working test scripts).

## Step 1: Add Remote Site Settings

Before testing, you need to whitelist the API endpoint:

1. **Setup → Quick Find** → `remote site`
2. Click **Remote Site Settings**
3. Check if `https://api.anthropic.com` exists
4. If NOT, click **New Remote Site**:
   - **Remote Site Name:** `Anthropic_API`
   - **Remote Site URL:** `https://api.anthropic.com`
   - **Active:** ✅ Check
   - Click **Save**

## Step 2: Test JobPostingAnalyzer

Now test if the JobPostingAnalyzer class works:

```apex
// Create a test job
Job_Posting__c testJob = new Job_Posting__c(
    Title__c = 'Senior Salesforce Developer',
    Company__c = 'Test Company',
    Location__c = 'Remote USA',
    Workplace_Type__c = 'Remote',
    Remote_Policy__c = 'Fully remote, flexible hours',
    Salary_Min__c = 100000,
    Salary_Max__c = 130000,
    Description__c = 'Looking for a Salesforce developer with Agentforce experience. ' +
                     'We offer flexible work hours, async communication, and ND-friendly culture. ' +
                     'No early morning meetings. Strong focus on work-life balance.',
    Status__c = 'Active',
    Posted_Date__c = Date.today()
);

insert testJob;
System.debug('Created job: ' + testJob.Id);

// Wait 2 seconds for insert to complete
System.sleep(2000);

// Query the job back
Job_Posting__c job = [SELECT Id, Title__c, Company__c, Location__c, Workplace_Type__c,
                              Remote_Policy__c, Salary_Min__c, Salary_Max__c, Description__c
                       FROM Job_Posting__c
                       WHERE Id = :testJob.Id];

// Test the analyzer
System.debug('Testing analyzer...');
JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(job);

System.debug('\n=== JOB ANALYSIS RESULT ===');
System.debug('Fit Score: ' + result.fitScore);
System.debug('ND Friendliness: ' + result.ndFriendlinessScore);
System.debug('Recommendation: ' + result.recommendation);
System.debug('Reasoning: ' + result.reasoning);
System.debug('\nGreen Flags:');
System.debug(result.greenFlags);
System.debug('\nRed Flags:');
System.debug(result.redFlags);
System.debug('=== END RESULT ===\n');
```

**Expected:**
- Fit Score: 8-9
- ND Friendliness: 8-9
- Green flags and red flags populated

## Step 3: If That Works, Deploy Automation!

Once the analyzer works, we can deploy the automation:

```bash
sf project deploy start --metadata ApexClass:JobPostingAnalysisQueue --target-org MyDevOrg
sf project deploy start --metadata ApexClass:JobPostingTriggerHandler --target-org MyDevOrg
sf project deploy start --metadata ApexTrigger:JobPostingTrigger --target-org MyDevOrg
```

Then you'll be able to just create jobs in Salesforce UI and they'll analyze automatically!

---

**First: Add Remote Site Settings, then run the test!**

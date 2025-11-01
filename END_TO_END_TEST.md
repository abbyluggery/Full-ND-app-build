# End-to-End Automation Test

The automation should now be deployed! Let's test it.

## Test Method 1: Create Job via Salesforce UI (Easiest)

1. **Open your Salesforce org**
2. **App Launcher** → Search "Job Postings"
3. **Click "New"**
4. **Fill in these fields:**
   - **Title:** `Agentforce Developer - Remote`
   - **Company:** `InnovateCo`
   - **Location:** `Remote USA`
   - **Workplace Type:** `Remote`
   - **Remote Policy:** `Fully Remote` (select from dropdown)
   - **Salary Min:** `100000`
   - **Salary Max:** `140000`
   - **Description:**
     ```
     Seeking Salesforce developer with Agentforce experience. Build AI agents using Claude API, Prompt Builder, and Model Builder. Fully remote role with flexible hours, no meetings before 10am. ND-friendly culture with async-first communication. Competitive salary and unlimited PTO.
     ```
   - **Status:** `Active`
   - **Posted Date:** Today's date
   - **Apply URL:** `https://innovateco.com/careers/12345`
   - **Provider:** `LinkedIn` (select from dropdown)
   - **External ID:** `LinkedIn:TEST001`

5. **Click Save**
6. **Wait 30-60 seconds**
7. **Refresh the page**
8. **Check if these fields are populated:**
   - Fit Score (should be ~9)
   - ND Friendliness Score (should be ~8-9)
   - Green Flags
   - Red Flags
   - Application Status: "Not Applied"

## Test Method 2: Create Job via Execute Anonymous

If you prefer code, run this in Developer Console:

```apex
Job_Posting__c testJob = new Job_Posting__c(
    Title__c = 'Agentforce Developer - Remote',
    Company__c = 'InnovateCo',
    Location__c = 'Remote USA',
    Workplace_Type__c = 'Remote',
    Remote_Policy__c = 'Fully Remote',
    Salary_Min__c = 100000,
    Salary_Max__c = 140000,
    Description__c = 'Seeking Salesforce developer with Agentforce experience. ' +
                     'Build AI agents using Claude API, Prompt Builder, and Model Builder. ' +
                     'Fully remote role with flexible hours, no meetings before 10am. ' +
                     'ND-friendly culture with async-first communication. ' +
                     'Competitive salary and unlimited PTO.',
    Status__c = 'Active',
    Posted_Date__c = Date.today(),
    Apply_URL__c = 'https://innovateco.com/careers/12345',
    Provider__c = 'LinkedIn',
    ExternalID__c = 'LinkedIn:TEST001'
);

insert testJob;
System.debug('Job created: ' + testJob.Id);
System.debug('Trigger should fire automatically and enqueue analysis...');
System.debug('Wait 30-60 seconds, then query this ID to see results!');
```

**Then wait 30-60 seconds and query:**

```apex
Job_Posting__c result = [
    SELECT Id, Title__c, Fit_Score__c, ND_Friendliness_Score__c,
           Green_Flags__c, Red_Flags__c, Application_Status__c
    FROM Job_Posting__c
    WHERE ExternalID__c = 'LinkedIn:TEST001'
];

System.debug('\n=== RESULTS ===');
System.debug('Fit Score: ' + result.Fit_Score__c);
System.debug('ND Friendliness: ' + result.ND_Friendliness_Score__c);
System.debug('Green Flags: ' + result.Green_Flags__c);
System.debug('Red Flags: ' + result.Red_Flags__c);
System.debug('Status: ' + result.Application_Status__c);
```

## Monitoring the Queue Job

To see if the async job ran:

1. **Setup → Apex Jobs**
2. Look for `JobPostingAnalysisQueue`
3. **Status should be:**
   - **Queued** → Waiting to run
   - **Processing** → Running now
   - **Completed** → Finished! ✅
   - **Failed** → Check error message

## Debug Logs

To see detailed logs:

1. **Setup → Debug Logs**
2. **Click "New"**
3. **Select your user**
4. **Set expiration to 1 hour**
5. **Save**
6. Create a job (Method 1 or 2)
7. **Refresh Debug Logs page** after 1 minute
8. **Click the log** to see what happened

## Expected Results

**If everything works:**
- Fit Score: 9-9.5 (excellent match)
- ND Friendliness: 8-9
- Green Flags: "Fully remote, Agentforce focus, ND-friendly, flexible hours, no early meetings"
- Red Flags: Minimal or none
- Application Status: "Not Applied"

**If it doesn't work:**
- Check Apex Jobs for errors
- Check Debug Logs
- Run the queue manually (next section)

## Manual Queue Test (If Automation Isn't Working)

If the trigger isn't firing, test the queue directly:

```apex
// Get a job ID
Id jobId = [SELECT Id FROM Job_Posting__c WHERE Title__c = 'Agentforce Developer - Remote' LIMIT 1].Id;

// Manually enqueue analysis
System.enqueueJob(new JobPostingAnalysisQueue(new List<Id>{ jobId }));

System.debug('Manually enqueued analysis for job: ' + jobId);
System.debug('Wait 30 seconds then query the record!');
```

---

**Try Method 1 (UI) first - it's the easiest! Let me know what happens!**

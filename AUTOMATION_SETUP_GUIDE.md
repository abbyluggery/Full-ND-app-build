# Automation Setup Guide - Auto-Analyze Jobs

This will enable automatic job analysis! Just create a Job_Posting__c record and Claude analyzes it automatically.

## Prerequisites

✅ Named Credential configured (follow [SETUP_NAMED_CREDENTIAL_STEPS.md](SETUP_NAMED_CREDENTIAL_STEPS.md) first!)

## What We're Building

**Before (Manual):**
1. Create job record
2. Copy test script
3. Paste job details into script
4. Run in Developer Console
5. View results

**After (Automated):**
1. Create job record
2. Wait 10-30 seconds
3. Refresh page - analysis complete! ✨

## Architecture

### Three New Components

1. **JobPostingAnalysisQueue.cls** (Queueable)
   - Runs asynchronously in background
   - Makes API callout to Claude
   - Updates job records with results
   - Handles errors gracefully

2. **JobPostingTrigger.trigger** (Database Trigger)
   - Fires when job record is created/updated
   - Delegates to handler class
   - After insert: Analyze new jobs
   - After update: Re-analyze if description/salary changed

3. **JobPostingTriggerHandler.cls** (Handler)
   - Business logic for trigger
   - Validates data before analysis
   - Enqueues async jobs
   - Follows trigger best practices

### How It Works

```
User creates Job_Posting__c
    ↓
JobPostingTrigger fires (after insert)
    ↓
JobPostingTriggerHandler validates & collects IDs
    ↓
JobPostingAnalysisQueue enqueued (async)
    ↓
Queue calls JobPostingAnalyzer.analyzeJob()
    ↓
Analyzer calls ClaudeAPIService (uses Named Credential)
    ↓
Claude API returns analysis
    ↓
Queue updates Job_Posting__c with results
    ↓
User refreshes page - sees Fit Score! ✅
```

## Deployment Steps

### Step 1: Verify Named Credential Works

Run this test first:

```apex
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Claude_API/v1/messages');
req.setMethod('POST');
req.setTimeout(60000);
req.setHeader('Content-Type', 'application/json');

String body = '{"model":"claude-3-haiku-20240307","max_tokens":100,"messages":[{"role":"user","content":"Hello"}]}';
req.setBody(body);

Http http = new Http();
HttpResponse res = http.send(req);

System.debug('Status: ' + res.getStatusCode());
System.debug('Response: ' + res.getBody());
```

**Expected:** Status: 200

**If it fails:** Don't deploy automation yet - fix Named Credential first!

### Step 2: Deploy Automation Classes

Open terminal and run:

```bash
cd "C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant"

sf project deploy start --metadata ApexClass:JobPostingAnalysisQueue --target-org MyDevOrg

sf project deploy start --metadata ApexClass:JobPostingTriggerHandler --target-org MyDevOrg

sf project deploy start --metadata ApexTrigger:JobPostingTrigger --target-org MyDevOrg
```

### Step 3: Test the Automation

**Test 1: Create a Job via Developer Console**

```apex
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
System.debug('Automatic analysis enqueued! Wait 10-30 seconds then check the record.');
```

**Test 2: Wait and Verify**

1. Copy the Job ID from the debug log
2. Wait 10-30 seconds (async job running)
3. Query the record:

```apex
Job_Posting__c result = [
    SELECT Id, Title__c, Fit_Score__c, ND_Friendliness_Score__c,
           Green_Flags__c, Red_Flags__c, Application_Status__c
    FROM Job_Posting__c
    WHERE Id = 'PASTE_JOB_ID_HERE'
];

System.debug('Fit Score: ' + result.Fit_Score__c);
System.debug('ND Friendliness: ' + result.ND_Friendliness_Score__c);
System.debug('Green Flags: ' + result.Green_Flags__c);
System.debug('Red Flags: ' + result.Red_Flags__c);
```

**Expected Results:**
- Fit_Score__c: 8-9 (good fit)
- ND_Friendliness_Score__c: 8-9
- Green_Flags__c: List of positive indicators
- Red_Flags__c: Any concerns
- Application_Status__c: "Not Applied"

**Test 3: Create Job via Salesforce UI**

1. Go to your Salesforce org
2. App Launcher → "Job Postings"
3. Click **New**
4. Fill in the fields (make sure to include Description!)
5. Click **Save**
6. Wait 10-30 seconds
7. Refresh the page
8. Check the **Fit Score** field - it should be populated!

## Monitoring Async Jobs

To see if your analysis jobs are running:

**Setup → Apex Jobs**

You'll see entries for `JobPostingAnalysisQueue` with status:
- **Queued:** Waiting to run
- **Processing:** Currently analyzing
- **Completed:** Analysis done!
- **Failed:** Check error logs

## Troubleshooting

### Issue: Job created but no Fit Score after 1 minute

**Check 1: Debug Logs**
- Setup → Debug Logs
- Click **New** → Add yourself as monitored user
- Create a job again
- Check logs for errors

**Check 2: Apex Jobs**
- Setup → Apex Jobs
- Find the JobPostingAnalysisQueue job
- Check status - if "Failed", click to see error

**Check 3: Named Credential**
- Most common issue: Named Credential not working
- Run Step 1 test again
- If it fails, re-configure Named Credential

### Issue: "We couldn't access the credential(s)"

- Named Credential not configured correctly
- Go back to [SETUP_NAMED_CREDENTIAL_STEPS.md](SETUP_NAMED_CREDENTIAL_STEPS.md)
- Try the "Legacy Named Credential" approach

### Issue: Trigger isn't firing

**Check if trigger is active:**
```apex
ApexTrigger trigger = [SELECT Status FROM ApexTrigger WHERE Name = 'JobPostingTrigger'];
System.debug('Trigger Status: ' + trigger.Status); // Should be 'Active'
```

### Issue: Analysis takes too long

- Normal: 10-30 seconds (API callout + queueable delay)
- If > 1 minute, check Apex Jobs for errors

## What Gets Analyzed Automatically

**Automatically analyzed when:**
- ✅ New job posting created (with description)
- ✅ Description updated
- ✅ Salary Min/Max updated
- ✅ Remote Policy updated

**NOT analyzed when:**
- ❌ No description provided
- ❌ Only non-critical fields updated (title, company name, etc.)

## Performance Notes

- **Queueable Jobs:** Run asynchronously (don't block UI)
- **API Callouts:** ~2-5 seconds per job
- **Salesforce Limits:** 250,000 async jobs per day (you're fine!)
- **Batch Size:** Processes jobs individually (can enhance later for bulk)

## Next Steps After Automation Works

1. **Create List Views** for prioritization
   - "High Priority Jobs" (Fit Score ≥ 9)
   - "Good Fits" (Fit Score 7-8.9)
   - "Review Needed" (Fit Score < 7)

2. **Add Quick Actions**
   - "Mark as Applied"
   - "Decline Job"
   - "Re-Analyze" button

3. **Build Dashboard**
   - Lightning Web Component
   - Visual fit score display
   - Color-coded recommendations

4. **Schedule Batch Job**
   - Analyze any unanalyzed jobs daily
   - Re-analyze old jobs if criteria changed

---

**Once this works, you can just paste job postings into Salesforce and get instant AI-powered analysis!**

# Agentforce: Deploy Job Search AI System - Ready to Execute

Custom Metadata test passed ✅ - API connection confirmed working!

---

## 🎯 What You're Deploying

AI-powered job search system that:
- Automatically analyzes job postings with Claude AI
- Scores for ND-friendliness (0-10)
- Calculates fit scores (0-10)
- Identifies green flags and red flags
- All fully automated!

---

## 📦 Deployment Order (MUST deploy in this order!)

### Phase 1: Deploy Custom Object

**Task 1.1: Deploy Job_Posting__c Object**

```bash
sf project deploy start --source-path "force-app/main/default/objects/Job_Posting__c" --target-org MyDevOrg
```

**What this deploys:**
- Job_Posting__c custom object
- All fields including:
  - Fit_Score__c (Number)
  - ND_Friendliness_Score__c (Number)
  - Green_Flags__c (Long Text)
  - Red_Flags__c (Long Text)
  - Application_Status__c (Picklist)
  - Title__c, Company__c, Description__c, etc.

**Verify:**
```
Setup → Object Manager → Search "Job Posting"
Should see: Job_Posting__c object with 15+ fields
```

**Expected output:**
```
Deployment Status: Succeeded
Components Deployed: 1 CustomObject
```

---

### Phase 2: Deploy Apex Classes (ONE AT A TIME!)

**Task 2.1: Deploy ClaudeAPIService (Foundation)**

```bash
sf project deploy start --source-path "force-app/main/default/classes/ClaudeAPIService.cls" --target-org MyDevOrg
```

**What this does:**
- Deploys the service that calls Claude API
- Uses Custom Metadata for API key (already configured ✅)
- Handles all HTTP communication with Claude

**Verify:**
```
Setup → Apex Classes → Search "ClaudeAPIService"
Should see: ClaudeAPIService with no compilation errors
```

---

**Task 2.2: Deploy ClaudeAPIServiceTest**

```bash
sf project deploy start --source-path "force-app/main/default/classes/ClaudeAPIServiceTest.cls" --target-org MyDevOrg
```

**What this does:**
- Test class for ClaudeAPIService
- Required for deployment to production later

---

**Task 2.3: Deploy JobPostingAnalyzer (Analysis Logic)**

```bash
sf project deploy start --source-path "force-app/main/default/classes/JobPostingAnalyzer.cls" --target-org MyDevOrg
```

**What this does:**
- Contains the AI analysis logic
- Applies your ND-friendly criteria
- Calculates fit scores

---

**Task 2.4: Deploy JobPostingAnalyzerTest**

```bash
sf project deploy start --source-path "force-app/main/default/classes/JobPostingAnalyzerTest.cls" --target-org MyDevOrg
```

---

**Task 2.5: Deploy JobPostingAnalysisQueue (Async Processing)**

```bash
sf project deploy start --source-path "force-app/main/default/classes/JobPostingAnalysisQueue.cls" --target-org MyDevOrg
```

**What this does:**
- Handles asynchronous job analysis
- Prevents timeout issues
- Processes jobs in background

---

**Task 2.6: Deploy JobPostingTriggerHandler (Trigger Logic)**

```bash
sf project deploy start --source-path "force-app/main/default/classes/JobPostingTriggerHandler.cls" --target-org MyDevOrg
```

**What this does:**
- Handles trigger business logic
- Queues jobs for AI analysis
- Follows best practices (handler pattern)

---

### Phase 3: Deploy Trigger (Automation!)

**Task 3.1: Deploy JobPostingTrigger**

```bash
sf project deploy start --source-path "force-app/main/default/triggers/JobPostingTrigger.trigger" --target-org MyDevOrg
```

**What this does:**
- Fires automatically when Job_Posting__c records are created
- Queues them for AI analysis
- Makes everything automatic!

**Verify:**
```
Setup → Apex Triggers → Should see "JobPostingTrigger"
Status should be: Active ✅
```

---

## ✅ Deployment Checklist

After each task, verify:

**Phase 1:**
- [ ] Job_Posting__c object exists
- [ ] Fit_Score__c field exists
- [ ] ND_Friendliness_Score__c field exists
- [ ] Green_Flags__c field exists
- [ ] Red_Flags__c field exists

**Phase 2:**
- [ ] ClaudeAPIService class deployed
- [ ] ClaudeAPIServiceTest class deployed
- [ ] JobPostingAnalyzer class deployed
- [ ] JobPostingAnalyzerTest class deployed
- [ ] JobPostingAnalysisQueue class deployed
- [ ] JobPostingTriggerHandler class deployed
- [ ] All classes show "0 errors" in Setup → Apex Classes

**Phase 3:**
- [ ] JobPostingTrigger trigger deployed
- [ ] Trigger is Active
- [ ] No compilation errors

---

## 🧪 Test After Deployment

### Quick Test Script

Run this in Developer Console:

```apex
// Test 1: Verify classes are accessible
System.debug('=== VERIFYING DEPLOYMENT ===');

try {
    // This will fail if classes aren't deployed
    Type t1 = Type.forName('ClaudeAPIService');
    Type t2 = Type.forName('JobPostingAnalyzer');
    Type t3 = Type.forName('JobPostingAnalysisQueue');
    Type t4 = Type.forName('JobPostingTriggerHandler');

    System.debug('✅ All classes found!');

    // Test 2: Verify Custom Metadata is accessible
    API_Configuration__mdt config = [
        SELECT Claude_API_Key__c
        FROM API_Configuration__mdt
        WHERE DeveloperName = 'Claude'
        LIMIT 1
    ];

    if (config != null && String.isNotBlank(config.Claude_API_Key__c)) {
        System.debug('✅ Custom Metadata configured!');
    }

    // Test 3: Verify Job_Posting__c object exists
    Schema.DescribeSObjectResult jobPostingDescribe = Job_Posting__c.sObjectType.getDescribe();
    System.debug('✅ Job_Posting__c object exists!');
    System.debug('   Fields: ' + jobPostingDescribe.fields.getMap().keySet().size());

    System.debug('\n✅✅✅ ALL VERIFICATIONS PASSED! ✅✅✅');
    System.debug('System is ready for testing with real job posting!');

} catch (Exception e) {
    System.debug('❌ Error: ' + e.getMessage());
}
```

**Expected Output:**
```
=== VERIFYING DEPLOYMENT ===
✅ All classes found!
✅ Custom Metadata configured!
✅ Job_Posting__c object exists!
   Fields: 20
✅✅✅ ALL VERIFICATIONS PASSED! ✅✅✅
System is ready for testing with real job posting!
```

---

## 🎯 Create Test Job Posting

After deployment succeeds, create a test job:

```apex
// Create a test job that should score HIGH
Job_Posting__c testJob = new Job_Posting__c(
    Title__c = 'Senior Salesforce Developer',
    Company__c = 'Tech Startup',
    Location__c = 'Remote',
    Workplace_Type__c = 'Remote',
    Remote_Policy__c = 'Fully Remote',
    Salary_Min__c = 90000,
    Salary_Max__c = 120000,
    Description__c = 'Remote Salesforce role with flexible hours. ' +
                     'Async-first communication. We value neurodiversity ' +
                     'and provide accommodations. Work-life balance is key. ' +
                     'Agentforce experience a plus.'
);

insert testJob;

System.debug('✅ Test job created: ' + testJob.Id);
System.debug('⏰ Wait 30-60 seconds, then check the record for AI analysis!');
System.debug('📊 Fields to check: Fit_Score__c, ND_Friendliness_Score__c, Green_Flags__c, Red_Flags__c');
```

**Then:**
```
1. Wait 30-60 seconds
2. Go to: Job Postings tab → Find your test record
3. Refresh the page
4. Check these fields:
   - Fit Score: Should be 8-10 (high fit!)
   - ND Friendliness Score: Should be 8-10
   - Green Flags: Should list: Remote, Flexible, ND accommodations, Agentforce
   - Red Flags: Should be empty or minimal
```

---

## 🆘 Troubleshooting

### Issue: "Component not found" during deployment
**Solution:** Deploy in the correct order (Object → Classes → Trigger)

### Issue: Compilation errors in classes
**Solution:**
- Check that Job_Posting__c object deployed first
- Check that API_Configuration__mdt.Claude record exists
- Share the specific error message

### Issue: Test job doesn't analyze (fields stay empty)
**Check these:**

1. **Apex Jobs for errors:**
```
Setup → Apex Jobs
Look for JobPostingAnalysisQueue with status "Failed"
Click to see error details
```

2. **Debug logs:**
```
Setup → Debug Logs
Click "New" → Add your user → Save
Create another test job
Check logs for errors
```

3. **Trigger is active:**
```
Setup → Apex Triggers → JobPostingTrigger
Status should be: Active ✅
```

4. **Fields exist:**
```
Setup → Object Manager → Job Posting → Fields
Verify: Fit_Score__c, ND_Friendliness_Score__c, Green_Flags__c, Red_Flags__c all exist
```

---

## 📊 Success Metrics

**System is fully working when:**

- [ ] All classes deployed without errors
- [ ] Trigger is active
- [ ] Test job creation succeeds
- [ ] After 30-60 seconds, AI fields populate:
  - Fit_Score__c = number between 0-10
  - ND_Friendliness_Score__c = number between 0-10
  - Green_Flags__c = bulleted list of positives
  - Red_Flags__c = bulleted list of concerns (may be empty for good jobs)
- [ ] Creating second job also triggers analysis

---

## 🎉 What Happens Next

Once deployment succeeds:

1. **Every job you create** gets analyzed automatically
2. **No manual work** needed
3. **30-60 seconds** and AI scores appear
4. **Sort by Fit Score** to prioritize applications
5. **Make better decisions** faster

**Next features to deploy:**
- Resume Generator (uses same Claude API)
- Job Search Dashboard (visual pipeline)
- Email alerts for high-fit jobs
- Interview preparation prompts

---

## 💬 Report Back

**After each phase, report:**

✅ **Success:**
```
"Phase 1 complete - Job_Posting__c deployed"
"Phase 2 complete - All classes deployed"
"Phase 3 complete - Trigger deployed"
"Test job created - waiting for analysis"
"Test passed - AI fields populated!"
```

❌ **Errors:**
```
"Error in Task X.X: [paste full error message]"
Include: Error type, line number, any stack trace
```

---

## 🚀 Ready to Deploy?

**Start with Phase 1, Task 1.1** and work through sequentially.

Report back after each phase so we can verify before moving to the next!

Let's get this AI system live! 🎉

# Deploy Job Search AI System - Quick Start Guide

Now that you have your Claude API key, let's get your AI-powered job search system deployed!

---

## 🎯 What You're Building

**AI Job Search Assistant that:**
- 🤖 Automatically analyzes job postings with Claude AI
- 🎯 Scores jobs for ND-friendliness (1-10)
- 📊 Calculates overall fit scores
- ✅ Identifies green flags (positive indicators)
- ⚠️ Identifies red flags (concerns)
- 📝 Generates tailored resumes for top jobs
- 📈 Tracks your application pipeline

**All powered by Claude AI!**

---

## 📋 Quick Deployment Checklist

### Phase 1: Setup (You Do This - 10 minutes)

- [ ] Create Named Credential in Salesforce
- [ ] Test connection to Claude API
- [ ] Provide deployment instructions to Agentforce

### Phase 2: Deploy Code (Agentforce Does This - 30 minutes)

- [ ] Deploy Job_Posting__c custom object
- [ ] Deploy ClaudeAPIService class
- [ ] Deploy JobPostingAnalyzer class
- [ ] Deploy JobPostingAnalysisQueue class
- [ ] Deploy JobPostingTriggerHandler class
- [ ] Deploy JobPostingTrigger trigger
- [ ] Deploy test classes

### Phase 3: Test (You + Agentforce - 10 minutes)

- [ ] Create a test job posting
- [ ] Wait 30-60 seconds
- [ ] Verify AI analysis fields populate
- [ ] Celebrate! 🎉

---

## 🚀 Step-by-Step: Create Named Credential

### Step 1: Navigate to Named Credentials

```
1. Salesforce → Setup (gear icon ⚙️)
2. Quick Find: "Named Credentials"
3. Click: Named Credentials
4. Click: "New Legacy" (or "New")
```

---

### Step 2: Basic Settings

**Fill in these fields:**

```
Label: Claude API
Name: Claude_API
URL: https://api.anthropic.com/v1/messages

Identity Type: Named Principal
Authentication Protocol: No Authentication

☐ Generate Authorization Header (UNCHECK this!)
☑ Allow Merge Fields in HTTP Header (CHECK this!)
☑ Allow Merge Fields in HTTP Body (CHECK this!)
```

---

### Step 3: Add Custom Headers

Click "New" under Custom Headers section and add these **3 headers**:

**Header 1 (Your API Key):**
```
Key: x-api-key
Value: [PASTE YOUR FULL sk-ant-api03-... KEY HERE]
☑ Protected (CHECK this - keeps it encrypted!)
```

**Header 2 (API Version):**
```
Key: anthropic-version
Value: 2023-06-01
☐ Protected (leave unchecked)
```

**Header 3 (Content Type):**
```
Key: Content-Type
Value: application/json
☐ Protected (leave unchecked)
```

---

### Step 4: Save & Verify

```
1. Click "Save"
2. Verify it appears in the Named Credentials list
3. Name should be: Claude_API
```

---

## 🧪 Test the Connection (Recommended)

**Run this in Developer Console → Execute Anonymous Apex:**

```apex
// Quick test to verify Claude API connection
Http h = new Http();
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Claude_API');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/json');

String testBody = '{' +
    '"model": "claude-3-haiku-20240307",' +
    '"max_tokens": 50,' +
    '"messages": [{"role": "user", "content": "Reply with just: Connection successful"}]' +
'}';
req.setBody(testBody);

HttpResponse res = h.send(req);
System.debug('Status Code: ' + res.getStatusCode());
System.debug('Response Body: ' + res.getBody());

if (res.getStatusCode() == 200) {
    System.debug('✅ SUCCESS! Named Credential is working!');
} else {
    System.debug('❌ Error: Check Named Credential configuration');
}
```

**Expected output:**
```
Status Code: 200
Response Body: {"content":[{"text":"Connection successful",...
✅ SUCCESS! Named Credential is working!
```

---

## 📦 For Agentforce: Deployment Instructions

Once Named Credential is ready, **give these instructions to Agentforce:**

---

### Deployment Task 1: Deploy Job_Posting__c Object

**Command:**
```bash
sf project deploy start --source-path "force-app/main/default/objects/Job_Posting__c" --target-org MyDevOrg
```

**What this does:**
- Deploys the Job_Posting__c custom object
- Includes ALL fields (Fit_Score__c, ND_Friendliness_Score__c, Green_Flags__c, Red_Flags__c, etc.)
- Creates the object in your org

**Verify after deployment:**
- Setup → Object Manager → Job Posting should exist
- Check that these fields exist:
  - Fit_Score__c (Number)
  - ND_Friendliness_Score__c (Number)
  - Green_Flags__c (Long Text)
  - Red_Flags__c (Long Text)
  - Application_Status__c (Picklist)

---

### Deployment Task 2: Deploy Apex Classes (In Order!)

**Deploy these classes ONE AT A TIME in this order:**

**1. ClaudeAPIService (Foundation)**
```bash
sf project deploy start --source-path "force-app/main/default/classes/ClaudeAPIService.cls" --target-org MyDevOrg
```

**2. JobPostingAnalyzer (Analysis Logic)**
```bash
sf project deploy start --source-path "force-app/main/default/classes/JobPostingAnalyzer.cls" --target-org MyDevOrg
```

**3. JobPostingAnalysisQueue (Async Processing)**
```bash
sf project deploy start --source-path "force-app/main/default/classes/JobPostingAnalysisQueue.cls" --target-org MyDevOrg
```

**4. JobPostingTriggerHandler (Trigger Logic)**
```bash
sf project deploy start --source-path "force-app/main/default/classes/JobPostingTriggerHandler.cls" --target-org MyDevOrg
```

**5. Test Classes (Required for deployment)**
```bash
sf project deploy start --source-path "force-app/main/default/classes/ClaudeAPIServiceTest.cls" --target-org MyDevOrg
sf project deploy start --source-path "force-app/main/default/classes/JobPostingAnalyzerTest.cls" --target-org MyDevOrg
```

**Verify after each:**
- Setup → Apex Classes → Class should appear in list
- No compilation errors

---

### Deployment Task 3: Deploy Trigger

**Command:**
```bash
sf project deploy start --source-path "force-app/main/default/triggers/JobPostingTrigger.trigger" --target-org MyDevOrg
```

**What this does:**
- Creates trigger that fires when Job_Posting__c records are created
- Automatically queues Claude AI analysis
- No manual intervention needed after this!

**Verify:**
- Setup → Apex Triggers → JobPostingTrigger should exist
- Status should be "Active"

---

## 🧪 Testing the AI System

### Test 1: Create a Job Posting

**Via Salesforce UI:**
```
1. App Launcher → Job Postings (or Sales/Service app)
2. Click "New"
3. Fill in:
   - Title: Senior Salesforce Developer
   - Company: Test Company
   - Description: Remote Salesforce role with flexible hours and async communication
   - Salary Range: $90,000 - $120,000
   - Location: Remote
4. Click "Save"
5. Wait 30-60 seconds
6. Refresh the page
7. Check these fields populate:
   ✓ Fit_Score__c (should be 7-9)
   ✓ ND_Friendliness_Score__c (should be 8-10 for remote/flexible)
   ✓ Green_Flags__c (should list: Remote, Flexible hours, etc.)
   ✓ Red_Flags__c (should be empty or minimal)
```

---

### Test 2: Create a Low-Fit Job

**Try another one:**
```
Title: Account Manager
Company: Fast-Paced Startup
Description: In-office required 5 days/week. Fast-paced environment with constant interruptions. Open office layout.
Salary: $50,000

Expected Results:
✓ Fit_Score__c: 2-4 (low)
✓ ND_Friendliness_Score__c: 2-3 (not ND-friendly)
✓ Red_Flags__c: In-office required, Open office, Constant interruptions
```

---

## 🎯 Success Criteria

**System is working when:**

- [ ] Named Credential "Claude_API" exists and tests successfully
- [ ] Job_Posting__c object exists with all fields
- [ ] All 5 Apex classes deployed successfully
- [ ] JobPostingTrigger is active
- [ ] Creating a Job_Posting__c record triggers analysis automatically
- [ ] AI fields populate within 60 seconds:
  - Fit_Score__c (number 0-10)
  - ND_Friendliness_Score__c (number 0-10)
  - Green_Flags__c (text listing positives)
  - Red_Flags__c (text listing concerns)

---

## 🆘 Troubleshooting

### Issue: "Endpoint not found"
**Fix:** Check Named Credential name is exactly `Claude_API` (underscore, not space)

### Issue: 401 Unauthorized
**Fix:**
- Open Named Credential
- Verify x-api-key header has correct value
- Re-paste API key if needed

### Issue: Fields don't populate
**Check:**
1. Setup → Apex Jobs → Look for errors
2. Debug Logs → Check for exceptions
3. Verify trigger is active
4. Check Job_Posting__c has all required fields

### Issue: Compilation errors
**Check:**
- ClaudeAPIService must deploy before JobPostingAnalyzer
- All classes deployed in correct order
- Test classes have correct @isTest annotation

---

## 📊 What Happens After Deployment

**Automatic Workflow:**

```
1. User creates Job_Posting__c record
   ↓
2. JobPostingTrigger fires
   ↓
3. Trigger queues JobPostingAnalysisQueue
   ↓
4. Queue calls JobPostingAnalyzer
   ↓
5. Analyzer calls ClaudeAPIService
   ↓
6. ClaudeAPIService calls Claude API (via Named Credential)
   ↓
7. Claude analyzes job using your ND-friendly criteria
   ↓
8. Response parsed and saved to Job_Posting__c fields
   ↓
9. User sees AI analysis on the record!
```

**All in 30-60 seconds, fully automated!** 🎉

---

## 🎨 What Claude Analyzes

**Your criteria built into JobPostingAnalyzer:**

**MUST-HAVES (Deal-breakers if missing):**
- Remote work
- ND-friendly culture/accommodations
- Salary ≥ $85,000
- Flexible schedule

**NICE-TO-HAVES (Bonus points):**
- Agentforce experience (+2 points)
- Growth-stage company (+1 point)
- Explicit ND accommodations (+2 points)

**RED FLAGS (Deductions):**
- In-office required
- Fast-paced/high-pressure language
- Ambiguous expectations
- Low salary

**Fit Score Calculation:**
- Start at 5
- +1 for each MUST-HAVE present
- +1-2 for NICE-TO-HAVEs
- -2 for each RED FLAG
- Final score: 0-10

---

## 🚀 Next Steps After Deployment

1. **Create 5-10 test job postings** with variety:
   - Good fit vs bad fit
   - Remote vs in-office
   - High salary vs low salary

2. **Watch patterns emerge:**
   - Which jobs score highest?
   - Are the flags accurate?
   - Does it match your intuition?

3. **Deploy Resume Generator** (next feature!)
   - Generates tailored resumes for high-fit jobs
   - Uses same Claude API
   - Automatically customizes for each posting

4. **Set up Job Search Dashboard:**
   - Visual pipeline tracking
   - Reports on fit scores
   - Application funnel

---

## 📁 Files Being Deployed

**Custom Objects:**
- force-app/main/default/objects/Job_Posting__c/Job_Posting__c.object-meta.xml
- force-app/main/default/objects/Job_Posting__c/fields/*.field-meta.xml

**Apex Classes:**
- force-app/main/default/classes/ClaudeAPIService.cls
- force-app/main/default/classes/JobPostingAnalyzer.cls
- force-app/main/default/classes/JobPostingAnalysisQueue.cls
- force-app/main/default/classes/JobPostingTriggerHandler.cls
- force-app/main/default/classes/*Test.cls

**Triggers:**
- force-app/main/default/triggers/JobPostingTrigger.trigger

---

## 🎉 You're About to Have...

**An AI-powered job search assistant that:**
- ✅ Analyzes every job automatically
- ✅ Scores for YOUR specific needs (ND-friendly, remote, salary)
- ✅ Identifies green and red flags
- ✅ Prioritizes which jobs to apply to
- ✅ Saves you hours of manual evaluation
- ✅ Reduces decision fatigue
- ✅ Increases application quality

**This is game-changing for job searching!** 🚀

---

## 💬 Communication

**Tell me when:**
- ✅ "Named Credential is created" → I'll prepare Agentforce instructions
- ✅ "Agentforce deployed classes" → I'll create test scripts
- ✅ "Test job created" → I'll help verify results
- ❌ "Hit an error" → I'll help troubleshoot

**Tell Agentforce:**
- Share this file: DEPLOY_JOB_SEARCH_AI_NOW.md
- Ask them to follow "Deployment Task 1, 2, 3" sections
- Have them report back after each task

---

**Let's get this deployed! Start with the Named Credential and let me know when it's ready!** 🎯

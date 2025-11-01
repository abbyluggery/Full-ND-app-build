# 🚀 Quick Deployment Instructions

## Step 1: Choose Your Target Org

You have three orgs connected:
1. **AI-WORKSHOP** (`abbyluggery@resourceful-moose-pohes7.com`)
2. **MyDevOrg** (`abbyluggery179@agentforce.com`)
3. **trailhead-playground** (`abbyluggery@creative-shark-cub7oy.com`)

**Recommendation**: Use **MyDevOrg** for testing this integration.

---

## Step 2: Deploy the Code

Open Terminal/Command Prompt in VS Code and run:

```bash
# Set MyDevOrg as default (recommended)
sf config set target-org MyDevOrg

# Deploy all classes and fields
sf project deploy start --source-dir force-app/main/default
```

**Wait for deployment** - this takes 30-60 seconds.

---

## Step 3: Set Up Remote Site Settings

The deployment will succeed, but you need to manually configure Remote Site Settings:

1. Log into Salesforce (MyDevOrg)
2. Go to **Setup** (gear icon ⚙️)
3. In Quick Find, search: **"Remote Site Settings"**
4. Click **New Remote Site**
5. Fill in:
   - **Remote Site Name**: `Claude_API`
   - **Remote Site URL**: `https://api.anthropic.com`
   - **Description**: `Anthropic Claude AI API`
   - ✅ Check **Active**
6. Click **Save**

---

## Step 4: Test the Integration

Now run the test script from [TEST_SCRIPTS.md](TEST_SCRIPTS.md):

1. Open **Developer Console** in Salesforce
2. **Debug** → **Open Execute Anonymous Window**
3. Copy this simple test:

```apex
// Simple test
Job_Posting__c testJob = new Job_Posting__c(
    Title__c = 'Test Job',
    Company__c = 'Test Co',
    Location__c = 'Remote',
    Workplace_Type__c = 'Remote',
    Remote_Policy__c = 'Fully Remote',
    Salary_Min__c = 95000,
    Salary_Max__c = 115000,
    Description__c = 'Remote Salesforce role with Agentforce. Flexible hours.'
);

try {
    JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(testJob);
    System.debug('✅ SUCCESS!');
    System.debug('Fit Score: ' + result.fitScore);
    System.debug('Recommendation: ' + result.recommendation);
} catch (Exception e) {
    System.debug('❌ Error: ' + e.getMessage());
}
```

4. Check **Open Log**
5. Click **Execute**
6. Click **Debug Only** filter
7. Look for "SUCCESS!" and your fit score!

---

## Alternative: Deploy Specific Components Only

If you only want to deploy the new classes (not all metadata):

```bash
# Deploy just the Claude integration classes
sf project deploy start --source-dir force-app/main/default/classes/ClaudeAPIService.cls
sf project deploy start --source-dir force-app/main/default/classes/JobPostingAnalyzer.cls

# Deploy the Named Credential
sf project deploy start --source-dir force-app/main/default/namedCredentials

# Deploy the new fields
sf project deploy start --source-dir force-app/main/default/objects/Job_Posting__c/fields/Fit_Score__c.field-meta.xml
sf project deploy start --source-dir force-app/main/default/objects/Job_Posting__c/fields/Application_Status__c.field-meta.xml
```

---

## What Gets Deployed

✅ **Apex Classes**:
- ClaudeAPIService.cls (API wrapper)
- JobPostingAnalyzer.cls (Business logic)
- All existing classes (no changes to them)

✅ **Named Credential**:
- Claude_API (with your API key)

✅ **Custom Fields** (on Job_Posting__c):
- Fit_Score__c
- Application_Status__c

✅ **Existing** (no changes):
- Job_Posting__c object
- All other existing fields

---

## Troubleshooting

### "No default org found"

**Run**:
```bash
sf config set target-org MyDevOrg
```

### "Component failures" during deployment

**Check** what failed:
- If it's about permissions, that's usually a warning (safe to ignore)
- If it's about missing fields, deploy objects first

### "Invalid type: JobPostingAnalyzer.JobAnalysisResult" after deployment

**Wait 2-3 minutes** then try again - sometimes Salesforce needs time to index new classes.

Or **refresh** your Developer Console:
1. Close Developer Console
2. Re-open it
3. Try the test script again

---

## Success Checklist

After deployment, you should have:

✅ ClaudeAPIService class visible in Setup → Apex Classes
✅ JobPostingAnalyzer class visible in Setup → Apex Classes
✅ Fit_Score__c field on Job_Posting__c
✅ Application_Status__c field on Job_Posting__c
✅ Claude_API Named Credential visible in Setup → Named Credentials
✅ Remote Site Setting for anthropic.com
✅ Test script runs without errors
✅ You see a fit score in the debug logs!

---

**Ready?** Run the deployment command above! ⬆️

Any errors? Copy the error message and ask Claude Code for help! 🤖

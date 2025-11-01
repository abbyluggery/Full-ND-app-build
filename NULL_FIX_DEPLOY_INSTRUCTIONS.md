# Null Handling Fix - Deploy Instructions

## New Error Found

**Error**: `"null argument for JSONGenerator.writeStringField()"`

**Root Cause**: `JSONGenerator` methods don't accept null values. If any string field is null, it throws an error.

**Solution**: Add null checks before writing each field.

---

## Fix Applied - Need to Deploy

I've added null checks to [ClaudeAPIService.cls:48-85](force-app/main/default/classes/ClaudeAPIService.cls#L48-L85).

### What Changed:

**BEFORE** (Would crash on null):
```apex
gen.writeStringField('model', this.model); // ← Crashes if null
gen.writeStringField('system', this.systemPrompts[0]); // ← Crashes if null
gen.writeStringField('role', msg.role); // ← Crashes if null
gen.writeStringField('content', msg.content); // ← Crashes if null
```

**AFTER** (Null-safe):
```apex
// Only write if not null/blank
if (String.isNotBlank(this.model)) {
    gen.writeStringField('model', this.model);
}

if (!this.systemPrompts.isEmpty() && String.isNotBlank(this.systemPrompts[0])) {
    gen.writeStringField('system', this.systemPrompts[0]);
}

if (String.isNotBlank(msg.role)) {
    gen.writeStringField('role', msg.role);
}

if (String.isNotBlank(msg.content)) {
    gen.writeStringField('content', msg.content);
}
```

---

## Deploy Via Developer Console (Recommended)

SF CLI is having deployment issues, so let's use Developer Console:

### Step 1: Open Developer Console
1. In Salesforce, click the **gear icon** (Setup menu)
2. Click **Developer Console**

### Step 2: Open ClaudeAPIService
1. In Developer Console, go to **File → Open Lightning Resources**
2. Wait, that's wrong - go to **File → Open**
3. In the dialog, select **Apex Classes** from the dropdown
4. Find and select **ClaudeAPIService**
5. Click **Open**

### Step 3: Replace the Code
1. In the code editor, press **Ctrl+A** (Select All)
2. Press **Delete** to remove all code
3. Open this file on your computer: `force-app\main\default\classes\ClaudeAPIService.cls`
4. Copy ALL the code (Ctrl+A, then Ctrl+C)
5. Paste into Developer Console (Ctrl+V)
6. Press **Ctrl+S** to save

### Step 4: Verify Save
- Look for **"Saved"** message at the bottom of Developer Console
- If you see any red underlines or errors, let me know
- If "Saved" appears with no errors, the deployment is complete ✅

---

## After Deployment - Test Again

### Delete the Failed Job Posting
1. Go to your Job Postings tab
2. Open **Senior Salesforce Developer**
3. Click **Delete**

### Create a New Job Posting

Fill in these fields:

**Required Fields:**
- **Apply URL**: `https://linkedin.com/jobs/test007`
- **Provider**: Select `LinkedIn`
- **External ID**: `LinkedIn:TEST-007`
- **Status**: Select `Active`

**Job Info:**
- **Title**: `Senior Salesforce Developer - Remote`
- **Company**: `Tech Company`
- **Location**: `Remote`
- **Description**:
  ```
  Remote Salesforce role with Agentforce experience.
  Flexible hours and async communication.
  Neurodiversity-friendly culture with accommodations.
  Work-life balance is a core value.
  ```

**ND-Friendly Fields:**
- **Workplace Type**: `Remote`
- **Remote Policy**: `Fully Remote`
- **Flexible Schedule**: ✓ (checked)

**Salary:**
- **Salary Min**: `95000`
- **Salary Max**: `125000`

Click **Save**

### Wait and Check
1. **Wait 30-60 seconds** for async processing
2. **Refresh** the page
3. **Check these fields** - they should populate:
   - Fit Score (should be 8-10)
   - ND Friendliness Score (should be 8-10)
   - Green Flags (should list positive indicators)
   - Red Flags (should be minimal or empty)

---

## Expected Results

### Success =
- ✅ No "Analysis failed" error
- ✅ All AI fields populate within 60 seconds
- ✅ Fit Score: 8-10
- ✅ ND Friendliness: 8-10
- ✅ Green/Red flags populated

### Still Broken =
If you still see errors, we'll need to check:
1. **Setup → Apex Jobs** - for JobPostingAnalysisQueue errors
2. **Setup → Debug Logs** - to see the exact error
3. The actual code in Developer Console to verify it deployed

---

## Alternative: Test Via Developer Console Script

If you prefer to test via code first:

```apex
// Run in Developer Console → Execute Anonymous Apex

Job_Posting__c testJob = new Job_Posting__c(
    Apply_URL__c = 'https://linkedin.com/jobs/dev-test-001',
    Provider__c = 'LinkedIn',
    ExternalID__c = 'LinkedIn:DEV-TEST-001',
    Status__c = 'Active',
    Title__c = 'Test Salesforce Dev Role',
    Company__c = 'Test Corp',
    Location__c = 'Remote',
    Description__c = 'Remote role with flexibility and ND accommodations.',
    Workplace_Type__c = 'Remote',
    Remote_Policy__c = 'Fully Remote',
    Flexible_Schedule__c = true,
    Salary_Min__c = 95000,
    Salary_Max__c = 125000
);

try {
    insert testJob;
    System.debug('✅ Job created: ' + testJob.Id);
    System.debug('Wait 60 seconds, refresh, and check fields.');
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
}
```

---

## Why This Fix Was Needed

`JSONGenerator` is stricter than `JSON.serialize()`:
- **Requires non-null values** for all write methods
- **Throws exceptions immediately** if you try to write null
- **Best practice**: Always check for null/blank before writing

This is actually a **good thing** because it catches errors early rather than sending invalid JSON to the API.

---

**Let me know if you need help deploying via Developer Console or if you encounter any other errors!**

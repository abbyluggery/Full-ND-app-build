# Deploy ClaudeAPIService Fix via Developer Console

## The Issue You Found

You're absolutely right - **the same JSON serialization errors from yesterday came back!**

**Yesterday's errors**:
- `"model: Input should be a valid string"`
- `"max_tokens: Input should be a valid integer"`

**Root cause**: The `JSON.serialize()` with Maps approach doesn't properly preserve data types for Claude API.

**Working solution from yesterday**: `JSONGenerator` with explicit type methods:
- `writeStringField()` for strings
- `writeNumberField()` for integers

---

## Fix Applied

I've updated [ClaudeAPIService.cls:48-76](force-app/main/default/classes/ClaudeAPIService.cls#L48-L76) to use the **JSONGenerator** approach that worked yesterday.

### Changed Code:

**BEFORE** (Broken - using JSON.serialize with Maps):
```apex
Map<String, Object> jsonMap = new Map<String, Object>();
jsonMap.put('model', this.model);
jsonMap.put('max_tokens', this.max_tokens);
// ...
return JSON.serialize(jsonMap);
```

**AFTER** (Working - using JSONGenerator):
```apex
JSONGenerator gen = JSON.createGenerator(true);
gen.writeStartObject();
gen.writeStringField('model', this.model);  // ← Explicit string type
gen.writeNumberField('max_tokens', this.max_tokens);  // ← Explicit number type
// ... messages array ...
gen.writeEndObject();
return gen.getAsString();
```

---

## Deploy Now - Developer Console Method

### Step 1: Open Developer Console
1. In Salesforce, click the gear icon (Setup)
2. Click **Developer Console**

### Step 2: Open ClaudeAPIService
1. In Developer Console, go to **File → Open**
2. Select **Apex Classes**
3. Find and open **ClaudeAPIService**

### Step 3: Replace the Code
1. Select ALL the code in Developer Console (Ctrl+A)
2. Delete it
3. Copy the entire fixed code from: [ClaudeAPIService.cls](force-app/main/default/classes/ClaudeAPIService.cls)
4. Paste into Developer Console
5. Click **File → Save** (or Ctrl+S)

### Step 4: Verify Save Succeeded
- Look for "Saved" message at bottom of Developer Console
- No red error lines should appear

---

## Alternative: Use SF CLI (if you prefer)

If you want to try SF CLI deployment despite the warnings:

```bash
sf project deploy start --metadata ApexClass:ClaudeAPIService --ignore-warnings
```

The warnings about "metadata.transfer" are just localization messages and don't affect functionality.

---

## After Deployment - Test It

### Option 1: Delete & Recreate Your Job Posting

1. Go to the existing **Senior Salesforce Developer** job posting
2. Click **Delete**
3. Create a new job posting with these fields:

**Required Fields:**
- Apply URL: `https://linkedin.com/jobs/test003`
- Provider: `LinkedIn`
- External ID: `LinkedIn:TEST-003`
- Status: `Active`

**Job Info:**
- Title: `Senior Salesforce Developer - Remote`
- Company: `Tech Company`
- Location: `Remote`
- Description: `Remote Salesforce role with flexible hours and ND-friendly culture`
- Workplace Type: `Remote`
- Remote Policy: `Fully Remote`
- Flexible Schedule: ✓ (checked)
- Salary Min: `95000`
- Salary Max: `125000`

4. **Save**
5. **Wait 30-60 seconds**
6. **Refresh** the page
7. **Check** if these fields populate:
   - Fit Score (should be 8-10)
   - ND Friendliness Score (should be 8-10)
   - Green Flags (should list positive indicators)
   - Red Flags (should be minimal/empty)

### Option 2: Developer Console Test Script

```apex
// Run in Developer Console → Execute Anonymous Apex

Job_Posting__c testJob = new Job_Posting__c(
    Apply_URL__c = 'https://linkedin.com/jobs/test004',
    Provider__c = 'LinkedIn',
    ExternalID__c = 'LinkedIn:TEST-004',
    Status__c = 'Active',
    Title__c = 'Test Job - Remote Salesforce',
    Company__c = 'Tech Co',
    Location__c = 'Remote',
    Description__c = 'Remote Salesforce role with flexible schedule and ND accommodations.',
    Workplace_Type__c = 'Remote',
    Remote_Policy__c = 'Fully Remote',
    Flexible_Schedule__c = true,
    Salary_Min__c = 95000,
    Salary_Max__c = 125000
);

insert testJob;
System.debug('Job created: ' + testJob.Id);
System.debug('Wait 60 seconds, then check record for AI analysis.');
```

---

## Expected Results

### If Fix Works:
- ✅ Job posting creates successfully
- ✅ After 60 seconds, AI fields populate automatically
- ✅ **No "Analysis failed" errors**
- ✅ Fit Score: 8-10
- ✅ ND Friendliness: 8-10
- ✅ Green Flags populated
- ✅ Red Flags minimal/empty

### If Still Broken:
- Check **Setup → Apex Jobs** for JobPostingAnalysisQueue errors
- Check **Debug Logs** for the actual JSON being sent
- Verify the code in Developer Console matches the fixed version

---

## Why This Approach is Needed

**Salesforce quirk**: `JSON.serialize()` with generic Maps doesn't reliably preserve type information for external APIs.

**Solution**: Use `JSONGenerator` with explicit type methods:
- `writeStringField()` - forces string type
- `writeNumberField()` - forces numeric type
- `writeBooleanField()` - forces boolean type

This ensures Claude API receives exactly the data types it expects.

---

**After you deploy, test with a new job posting and let me know if the AI analysis works!**

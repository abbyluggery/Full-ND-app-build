# Manual Re-Analysis Instructions

## Problem

The automatic trigger didn't re-analyze the job when you edited it. This could be because:
1. The edit didn't actually change the field value (adding a space may not count as a change)
2. The async job is delayed
3. There's a caching issue

## Solution: Manually Trigger Analysis

### Step 1: Open Developer Console
1. In Salesforce, click **gear icon** → **Developer Console**

### Step 2: Run the Manual Trigger Script
1. In Developer Console, click **Debug** → **Open Execute Anonymous Window**
2. Copy the code from `manually_trigger_analysis.apex`
3. Paste into the Execute Anonymous Window
4. **Check** the box "Open Log"
5. Click **Execute**

### Step 3: Check the Log
1. A new log tab will open
2. Look for these lines:
   ```
   Found job: Salesforce Administrator (ID: ...)
   Salary Min: 50
   Salary Max: 54
   Analysis queued successfully!
   ```

### Step 4: Wait and Check
1. **Wait 60 seconds** for the async job to complete
2. Go to the **Salesforce Administrator** job posting
3. **Refresh** the page
4. **Check these fields**:
   - ND Friendliness Score: Should be something other than 7 (if ND-friendly indicators present)
   - Red Flags: Should NOT show salary red flag (or if it does, it should reference annual equivalent)

---

## Alternative: Create a NEW Job Posting

If manual triggering still doesn't work, the safest test is to create a **brand new** job posting:

### Test Job Details:

**Required Fields:**
- **Apply URL**: `https://linkedin.com/jobs/hourly-test`
- **Provider**: `LinkedIn`
- **External ID**: `LinkedIn:HOURLY-TEST`
- **Status**: `Active`

**Job Details:**
- **Title**: `Test Hourly Salary Detection`
- **Company**: `Test Company`
- **Location**: `Remote`
- **Description**:
  ```
  Remote position with flexible hours.
  Async communication preferred.
  ND-friendly culture with comprehensive accommodations.
  Work-life balance is a core value.
  ```

**Salary (HOURLY):**
- **Salary Min**: `50`
- **Salary Max**: `54`

**ND-Friendly Fields:**
- **Workplace Type**: `Remote`
- **Remote Policy**: `Fully Remote`
- **Flexible Schedule**: ✓ (checked)

**Click Save**

### Expected Results (After 60 Seconds):

✅ **ND Friendliness Score**: 8-9 (due to remote, flexible, ND-friendly language)
✅ **Fit Score**: 8-10
✅ **Green Flags**: Should mention remote work, flexibility, ND accommodations
✅ **Red Flags**: Should NOT mention low salary (or should show hourly → annual conversion)

---

## What to Look For

### Success Indicators:
1. **Hourly Salary Detection Working**:
   - AI sees: "$50/hr (~$104K annual)" in its analysis
   - AI compares $104K to $85K threshold
   - Result: Above threshold, no red flag

2. **Improved ND Scoring**:
   - Jobs with strong ND indicators score 8-10
   - Jobs with no ND indicators score 5-6
   - Jobs with anti-ND language score 1-4
   - Scores are no longer always 7

### Failure Indicators:
1. **Hourly Salary Still Broken**:
   - Red Flags: "Salary range of $50-54k is below the $85k minimum"
   - This means AI is still seeing "$50-54" directly without conversion

2. **ND Scoring Still Vague**:
   - All jobs still scoring 7 regardless of ND-friendly features
   - This means improved criteria didn't deploy

---

## Debugging Steps

If neither manual trigger nor new job works:

### 1. Verify Code Deployed Correctly

**Check ClaudeAPIService.cls**:
1. Developer Console → File → Open → Apex Classes → ClaudeAPIService
2. Look for line ~230: Should see `Boolean isHourly = false;`
3. Look for line ~275: Should see detailed ND scoring criteria with 9-10, 7-8, etc.

If you don't see these lines, the code didn't deploy correctly.

### 2. Check Debug Logs

1. Setup → Debug Logs
2. Click **New**
3. Set your user, all categories to FINEST
4. Create a new test job
5. Wait 60 seconds
6. Click the log
7. Search for "REQUEST JSON" to see what's being sent to Claude
8. Search for "buildJobAnalysisPrompt" to see the prompt being built

### 3. Check Async Jobs

1. Setup → Apex Jobs
2. Look for JobPostingAnalysisQueue
3. Check Status (should be Completed, not Failed)
4. If Failed, click to see error details

---

## Next Steps

**Try in this order**:

1. ✅ **Run manual trigger script** (quickest test)
2. ✅ **Create new job posting** (most reliable test)
3. ✅ **Check debug logs** (if still not working)
4. ✅ **Verify code deployment** (if logs show old code)

**Report back** which method you used and what the results were!

# Test Job Posting Creation - With All Required Fields

## Required Fields Identified

The following fields are marked as **required=true** in the Job_Posting__c object:

1. **Apply_URL__c** - URL field
2. **Provider__c** - Picklist (Dice, FlexJobs, Glassdoor, Greenhouse, Indeed, Ladders, Lever, LinkedIn)
3. **ExternalID__c** - Text Area (Format: {Provider}:{JobID})
4. **Status__c** - Picklist (Active, Inactive, Expired, Filled)

---

## Updated Test Script for Developer Console

Run this in **Developer Console → Execute Anonymous Apex**:

```apex
// Test Job Posting Creation - HIGH FIT JOB
// This script includes ALL required fields

Job_Posting__c testJob = new Job_Posting__c(
    // REQUIRED FIELDS
    Apply_URL__c = 'https://example.com/jobs/senior-salesforce-dev',
    Provider__c = 'LinkedIn',
    ExternalID__c = 'LinkedIn:TEST-001',
    Status__c = 'Active',

    // CORE JOB INFO
    Title__c = 'Senior Salesforce Developer - Agentforce Focus',
    Company__c = 'Innovative Tech Company',
    Location__c = 'Remote - USA',
    Description__c = 'We are seeking a Senior Salesforce Developer with Agentforce experience. ' +
                     'This is a fully remote position with flexible hours and async-first communication. ' +
                     'We value neurodiversity and provide comprehensive accommodations. ' +
                     'Work-life balance is a core company value. ' +
                     'You will work on cutting-edge AI projects using Agentforce and Einstein GPT. ' +
                     'Expected salary range: $95K-$125K.',

    // ND-FRIENDLY INDICATORS
    Workplace_Type__c = 'Remote',
    Remote_Policy__c = 'Fully Remote',
    Flexible_Schedule__c = true,

    // SALARY INFO
    Salary_Min__c = 95000,
    Salary_Max__c = 125000
);

try {
    insert testJob;
    System.debug('✅ SUCCESS! Job Posting created: ' + testJob.Id);
    System.debug('');
    System.debug('⏰ NEXT STEPS:');
    System.debug('1. Wait 30-60 seconds for AI analysis to complete');
    System.debug('2. Go to: Job Postings tab');
    System.debug('3. Open the record: ' + testJob.Id);
    System.debug('4. Refresh the page');
    System.debug('5. Check these fields:');
    System.debug('   - Fit Score (should be 8-10)');
    System.debug('   - ND Friendliness Score (should be 9-10)');
    System.debug('   - Green Flags (should list: Remote, Flexible, Agentforce, etc.)');
    System.debug('   - Red Flags (should be empty or minimal)');
    System.debug('');
    System.debug('📊 Expected Results:');
    System.debug('   This job should score HIGH because:');
    System.debug('   ✓ Fully remote');
    System.debug('   ✓ Flexible schedule');
    System.debug('   ✓ ND accommodations mentioned');
    System.debug('   ✓ Agentforce experience (bonus)');
    System.debug('   ✓ Salary above $85K threshold');

} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
    System.debug('Type: ' + e.getTypeName());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
```

---

## Alternative: Low-Fit Job (For Comparison)

After the high-fit job works, test with a low-fit job:

```apex
// Test Job Posting Creation - LOW FIT JOB
// This should score POORLY

Job_Posting__c lowFitJob = new Job_Posting__c(
    // REQUIRED FIELDS
    Apply_URL__c = 'https://example.com/jobs/account-manager',
    Provider__c = 'Indeed',
    ExternalID__c = 'Indeed:TEST-002',
    Status__c = 'Active',

    // CORE JOB INFO
    Title__c = 'Account Manager - Fast Paced Environment',
    Company__c = 'High Pressure Sales Corp',
    Location__c = 'New York, NY (In-Office)',
    Description__c = 'Dynamic account manager needed for fast-paced startup. ' +
                     'Open office environment with constant collaboration. ' +
                     'In-office required 5 days/week. ' +
                     'Must be comfortable with ambiguity and rapid pivots. ' +
                     'High-energy team culture. ' +
                     'Salary: $50K-$60K.',

    // NOT ND-FRIENDLY
    Workplace_Type__c = 'On-site',
    Remote_Policy__c = 'No Remote',
    Flexible_Schedule__c = false,

    // LOW SALARY
    Salary_Min__c = 50000,
    Salary_Max__c = 60000
);

try {
    insert lowFitJob;
    System.debug('✅ Low-fit job created: ' + lowFitJob.Id);
    System.debug('📊 Expected Results:');
    System.debug('   This job should score LOW because:');
    System.debug('   ✗ In-office required (major red flag)');
    System.debug('   ✗ Open office layout (ND concern)');
    System.debug('   ✗ Fast-paced/high-pressure language');
    System.debug('   ✗ Salary below $85K threshold');
    System.debug('   ✗ No flexibility mentioned');
    System.debug('');
    System.debug('   - Fit Score: Should be 2-4');
    System.debug('   - ND Friendliness Score: Should be 1-3');
    System.debug('   - Red Flags: Should list all concerns above');

} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}
```

---

## Via Salesforce UI

If you're creating via the UI, make sure to fill in these required fields:

1. **Apply URL**: Any valid URL (e.g., https://linkedin.com/jobs/12345)
2. **Provider**: Select from dropdown (LinkedIn, Indeed, etc.)
3. **External ID**: Format as `Provider:JobID` (e.g., "LinkedIn:12345")
4. **Status**: Select "Active"

Then add your optional fields:
- Title, Company, Location, Description
- Remote Policy, Workplace Type
- Salary Range
- Etc.

---

## After Job Creation

**Wait 30-60 seconds**, then check these fields on the Job_Posting__c record:

### AI Analysis Fields (Should Auto-Populate):

| Field | What to Check |
|-------|---------------|
| **Fit_Score__c** | Number between 0-10 |
| **ND_Friendliness_Score__c** | Number between 0-10 |
| **Green_Flags__c** | Bulleted list of positive indicators |
| **Red_Flags__c** | Bulleted list of concerns |

### High-Fit Job Expected Results:
- Fit Score: 8-10
- ND Friendliness: 8-10
- Green Flags: Remote work, Flexible schedule, ND accommodations, Agentforce focus, Good salary
- Red Flags: Empty or minimal

### Low-Fit Job Expected Results:
- Fit Score: 2-4
- ND Friendliness: 1-3
- Green Flags: Minimal or none
- Red Flags: In-office required, Open office, High pressure, Low salary, No flexibility

---

## Troubleshooting If Fields Don't Populate

1. **Check Apex Jobs for Errors**:
   ```
   Setup → Apex Jobs
   Look for: JobPostingAnalysisQueue
   Status: Should be "Completed" (not "Failed")
   ```

2. **Check Debug Logs**:
   ```
   Setup → Debug Logs
   Create log for your user
   Create another test job
   Check logs for exceptions
   ```

3. **Verify Trigger is Active**:
   ```
   Setup → Apex Triggers
   Find: JobPostingTrigger
   Status: Should be "Active"
   ```

4. **Check Custom Metadata**:
   ```
   Setup → Custom Metadata Types → API Configuration
   Record: Claude
   Field: Claude_API_Key__c should have your API key
   ```

---

## Success Criteria

System is working when:
- ✅ Job posting creates without errors
- ✅ After 30-60 seconds, AI fields populate automatically
- ✅ High-fit jobs score 7-10
- ✅ Low-fit jobs score 1-4
- ✅ Green/Red flags accurately reflect job characteristics
- ✅ Creating multiple jobs all get analyzed

---

**Let me know what happens when you create the job posting!**

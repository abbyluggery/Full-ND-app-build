# 🧪 Test Scripts - Job Search Assistant

## ⚠️ Before Running These Scripts

Make sure you've deployed the code first:
```bash
sfdx force:source:deploy -p force-app/main/default/classes
```

And set up Remote Site Settings in Salesforce Setup for `https://api.anthropic.com`

---

## 📝 Test Script 1: Simple Analysis Test

**Purpose**: Test if Claude API integration works with a perfect-fit job

**Copy this into Developer Console → Debug → Execute Anonymous Window**:

```apex
// Create a test job posting (not saved to database)
Job_Posting__c testJob = new Job_Posting__c(
    Title__c = 'Salesforce Developer - Agentforce Focus',
    Company__c = 'InnovateCo',
    Location__c = 'Remote USA',
    Workplace_Type__c = 'Remote',
    Remote_Policy__c = 'Fully Remote',
    Salary_Min__c = 95000,
    Salary_Max__c = 115000,
    Description__c = 'Join our team building AI agents with Agentforce! ' +
        'We offer flexible hours, unlimited PTO, and support neurodivergent employees. ' +
        'No meetings before 10am. Async-first culture. Growth-stage startup with ' +
        'clear career progression to Senior roles.'
);

// Call the analyzer (note: no dot notation needed for inner class in same execution context)
try {
    // Call analyze method
    Object resultObj = JobPostingAnalyzer.analyzeJob(testJob);

    // Get the result (Apex doesn't require casting in execute anonymous)
    System.debug('\n=== ANALYSIS COMPLETE ===');
    System.debug('This job should score HIGH PRIORITY (9-10/10)');
    System.debug('Check the logs below for full details from Claude');

} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
    System.debug('\nTroubleshooting:');
    System.debug('1. Did you deploy the code? Run: sfdx force:source:deploy -p force-app/main/default/classes');
    System.debug('2. Did you set up Remote Site Settings for anthropic.com?');
    System.debug('3. Is the Named Credential configured with your API key?');
}
```

**Expected Result**:
- Check the Debug logs (click "Debug Only" filter)
- Look for "ANALYSIS COMPLETE"
- You should see Fit Score and other details in the ClaudeAPIService logs

---

## 📝 Test Script 2: Detailed Analysis with Output

**Purpose**: See the full analysis results printed clearly

```apex
// Create test job
Job_Posting__c testJob = new Job_Posting__c(
    Title__c = 'Senior Salesforce Admin',
    Company__c = 'TechCorp',
    Location__c = 'Remote',
    Workplace_Type__c = 'Remote',
    Remote_Policy__c = 'Fully Remote',
    Salary_Min__c = 90000,
    Salary_Max__c = 120000,
    Description__c = 'We are seeking a Senior Salesforce Admin with Agentforce experience. ' +
        'This is a fully remote position with flexible hours. We value work-life balance ' +
        'and support neurodivergent team members with accommodations. ' +
        'Unlimited PTO, no strict meeting schedules.'
);

try {
    // Analyze the job
    JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(testJob);

    // Print results in a nice format
    System.debug('\n╔════════════════════════════════════════════════╗');
    System.debug('║         JOB ANALYSIS RESULTS                   ║');
    System.debug('╚════════════════════════════════════════════════╝\n');

    System.debug('📊 SCORES:');
    System.debug('   Fit Score: ' + result.fitScore + '/10');
    System.debug('   ND Friendliness: ' + result.ndFriendlinessScore + '/10');
    System.debug('   Recommendation: ' + result.recommendation);

    System.debug('\n✅ GREEN FLAGS:');
    System.debug(result.greenFlags);

    System.debug('\n⚠️  RED FLAGS:');
    System.debug(result.redFlags);

    System.debug('\n💭 REASONING:');
    System.debug(result.reasoning);

    System.debug('\n' + '═'.repeat(50));

} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
    System.debug('Type: ' + e.getTypeName());
    System.debug('Line: ' + e.getLineNumber());
    System.debug('\nStack Trace:');
    System.debug(e.getStackTraceString());
}
```

---

## 📝 Test Script 3: Bad Fit Job (Should Score Low)

**Purpose**: Test that the AI correctly identifies deal-breakers

```apex
// Create a job with deal-breakers
Job_Posting__c badFitJob = new Job_Posting__c(
    Title__c = 'Junior Salesforce Admin',
    Company__c = 'Corporate Inc',
    Location__c = 'New York, NY',
    Workplace_Type__c = 'On-site',  // ❌ Deal breaker: not remote
    Remote_Policy__c = 'Office-based',
    Salary_Min__c = 55000,  // ❌ Deal breaker: below $85K minimum
    Salary_Max__c = 70000,
    Description__c = 'Fast-paced corporate environment. Must be in office 9-6pm Monday-Friday. ' +
        'Team player who can wear many hats. High-energy startup culture.'
);

try {
    JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(badFitJob);

    System.debug('\n=== BAD FIT JOB TEST ===');
    System.debug('This should score SKIP (0-4/10)');
    System.debug('');
    System.debug('Fit Score: ' + result.fitScore + '/10');
    System.debug('Recommendation: ' + result.recommendation);
    System.debug('');
    System.debug('Red Flags:');
    System.debug(result.redFlags);

    if (result.fitScore < 5 && result.recommendation == 'SKIP') {
        System.debug('\n✅ TEST PASSED: AI correctly identified deal-breakers!');
    } else {
        System.debug('\n⚠️  Unexpected score - check the reasoning');
    }

} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}
```

---

## 📝 Test Script 4: Analyze and Save Real Job

**Purpose**: Analyze a real job and save results to Salesforce

**Step 1**: First create the Job_Posting__c record in Salesforce:
1. Go to Job Postings tab
2. Click New
3. Fill in details from a real job you found
4. Save and note the Record ID

**Step 2**: Run this script (replace the ID):

```apex
// Replace with your actual Job Posting ID
Id jobId = 'a00XXXXXXXXXXXXXXX';  // ← CHANGE THIS!

// Query the job
Job_Posting__c job = [
    SELECT Id, Title__c, Company__c, Location__c,
           Workplace_Type__c, Remote_Policy__c,
           Salary_Min__c, Salary_Max__c, Description__c, URL__c
    FROM Job_Posting__c
    WHERE Id = :jobId
    LIMIT 1
];

System.debug('Analyzing job: ' + job.Title__c + ' at ' + job.Company__c);

try {
    // Analyze the job
    JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(job);

    System.debug('\n✅ Analysis complete!');
    System.debug('Fit Score: ' + result.fitScore);
    System.debug('Recommendation: ' + result.recommendation);

    // Save results back to the job record
    job.Fit_Score__c = result.fitScore;
    job.ND_Friendliness_Score__c = result.ndFriendlinessScore;
    job.Green_Flags__c = result.greenFlags;
    job.Red_Flags__c = result.redFlags;
    job.Research_JSON__c = result.fullResponse;
    job.Research_Date__c = DateTime.now();

    update job;

    System.debug('\n💾 Job record updated successfully!');
    System.debug('Refresh the record in Salesforce to see the analysis');

} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
    System.debug(e.getStackTraceString());
}
```

**Step 3**: Refresh the Job Posting record in Salesforce to see the analysis!

---

## 🔍 Troubleshooting

### Error: "Invalid type: JobPostingAnalyzer.JobAnalysisResult"

**Cause**: The code hasn't been deployed to your org yet.

**Solution**: Deploy the code first:
```bash
sfdx force:source:deploy -p force-app/main/default/classes
```

Wait for deployment to complete, then try again.

---

### Error: "Unauthorized endpoint, please check Setup->Security->Remote site settings"

**Cause**: Salesforce doesn't have permission to call the Claude API.

**Solution**:
1. Go to Setup → Remote Site Settings
2. Click New Remote Site
3. Name: `Claude_API`
4. URL: `https://api.anthropic.com`
5. Check "Active"
6. Save

---

### Error: "401 Unauthorized"

**Cause**: API key is incorrect or not configured.

**Solution**:
1. Go to Setup → Named Credentials
2. Find Claude_API
3. Click Edit
4. Verify the x-api-key header has your API key
5. Save

---

### Error: "Read timed out"

**Cause**: Claude is taking longer than 60 seconds (unusual).

**Solution**:
- Try with a shorter job description
- Check your internet connection
- Retry - might be temporary API slowness

---

### No Error, But No Results

**Check**:
1. Open Developer Console → Logs tab
2. Find your log (most recent)
3. Click "Debug Only" filter
4. Look for:
   - "Claude API Request" - confirms request was sent
   - "Claude API Response Status: 200" - confirms Claude responded
   - "Job Analysis Complete" - confirms parsing worked

---

## 📊 What Good Results Look Like

### HIGH PRIORITY Job (Fit Score 9-10):
```
Fit Score: 9.2/10
ND Friendliness: 8.5/10
Recommendation: HIGH PRIORITY

Green Flags:
• Fully remote work (MUST HAVE ✓)
• Agentforce focus - matches your expertise
• Flexible hours mentioned
• Neurodivergent-friendly culture stated
• Salary $95-115K (in target range)
• Unlimited PTO
• Async-first communication

Red Flags:
• Startup pace might be intense

Reasoning: Excellent fit - meets all MUST HAVEs plus Agentforce expertise match.
```

### SKIP Job (Fit Score 0-4):
```
Fit Score: 2.0/10
ND Friendliness: 3.0/10
Recommendation: SKIP

Green Flags:
(none)

Red Flags:
• On-site required (deal breaker - you need remote)
• Salary $55-70K (below $85K minimum)
• Rigid 9-6pm hours (no flexibility)
• "Fast-paced" language (burnout risk)

Reasoning: Multiple deal-breakers present. Skip this role.
```

---

## 🎯 Next Steps After Testing

Once tests pass:
1. ✅ Analyze 5-10 real jobs from LinkedIn/Indeed
2. ✅ Build up your Job_Posting__c records
3. ✅ Use Fit Scores to prioritize applications
4. ✅ Apply only to 8+ scores during your optimal job search time
5. ✅ Track your pipeline with Application_Status__c

**Ready for automation?** Next we'll build a trigger to auto-analyze new jobs!

---

## 💡 Pro Tips

1. **Always include full job descriptions** - more context = better analysis
2. **Test with both good and bad fits** - verify the scoring works both ways
3. **Check Research_JSON__c field** - contains Claude's full response
4. **Use Debug Only filter** - easier to read logs
5. **Save good test cases** - reuse them when testing future changes

---

Need help? The error messages will point you to the issue. Check the troubleshooting section above! 🚀

# 🚀 Job Search Assistant - Deployment Guide

## Overview

This guide will walk you through deploying your Claude-powered Job Search Assistant to your Salesforce org using the modern sf CLI. In this environment, you can also use the MCP Deploy Metadata tool. By the end, you'll have a working system that automatically analyzes job postings using AI.

---

## 📋 Prerequisites

Before deploying, make sure you have:

- ✅ Salesforce Developer Org or Sandbox (get free at [developer.salesforce.com](https://developer.salesforce.com))
- ✅ Salesforce CLI (sf) installed
- ✅ VS Code with Salesforce Extensions
- ✅ Claude API key (you already provided this)
- ✅ Git (for version control)

---

## 🔧 Step 1: Authenticate with Salesforce

Open your terminal in VS Code and run:

```bash
# Authorize your Salesforce org and set it as default
sf org login web --alias MyDevOrg --set-default

# This will open a browser window
# Log in with your Salesforce credentials
# After login, return to VS Code
```

Alternative (JSON auth file):
```bash
# If you have a connected app and JWT or auth URL, you can also use:
# sf org login sfdx-url --sfdx-url-file ./config/auth-url.txt --alias MyDevOrg --set-default
```

What's happening: This connects your local project to your Salesforce org so you can deploy code.

---

## 📦 Step 2: Deploy the Metadata

Preferred in this environment (MCP tool):
- Use the Deploy Metadata tool (deploy_metadata) to deploy your local changes to the default org. No need to specify sourceDir unless you only want a subset deployed.

Fallback: sf CLI

Deploy all the code we created to your org:

```bash
# Deploy everything in force-app directory
sf project deploy start --source-dir force-app/main/default

# Or deploy the whole project (auto-detects changes)
sf project deploy start
```

This will deploy:
- ClaudeAPIService.cls (API wrapper)
- JobPostingAnalyzer.cls (Business logic)
- Named Credential / External Credential assets for the API key
- New fields (Fit_Score__c, Application_Status__c, etc.)

Expected output (will vary based on API version):
```
Deploying metadata to <your org>...
Deploy ID: 0Af...

DEPLOY PROGRESS | ████████████████████████████████████████ | 12/12 Components

=== Deployed Source
FULL NAME                    TYPE              PROJECT PATH
───────────────────────────  ────────────────  ──────────────────────────
ClaudeAPIService             ApexClass         force-app/main/default/classes/ClaudeAPIService.cls
JobPostingAnalyzer           ApexClass         force-app/main/default/classes/JobPostingAnalyzer.cls
Fit_Score__c                 CustomField       force-app/main/default/objects/Job_Posting__c/fields/Fit_Score__c.field-meta.xml
Application_Status__c        CustomField       force-app/main/default/objects/Job_Posting__c/fields/Application_Status__c.field-meta.xml
Claude_API                   ExternalCredential force-app/main/default/externalCredentials/Claude_API.externalCredential-meta.xml

Deploy Succeeded.
```

If you get errors:
- "Unknown user permission": This is often a warning about permissions your org doesn't have
- "Missing field": Make sure Job_Posting__c object exists in your org
- "Invalid API key": We'll configure this next

---

## 🔑 Step 3: Configure Remote Site Settings

Salesforce needs permission to call external APIs. If your org uses Remote Site Settings for callouts, enable Claude API access:

1. In Salesforce, go to Setup → Search "Remote Site Settings"
2. Click New Remote Site
3. Fill in:
   - Remote Site Name: Claude_API
   - Remote Site URL: https://api.anthropic.com
   - Description: Anthropic Claude AI API for job posting analysis
   - Check Active
4. Click Save

Note: If your integration uses a Named Credential with per-callout host whitelisting, a Remote Site Setting may not be required. Keep this step if callouts fail with "Unauthorized endpoint".

---

## ✅ Step 4: Verify External/Named Credential

Your credential stores the Claude API key securely:

1. Go to Setup → Search "Named Credentials" (and "External Credentials" if applicable)
2. Find Claude_API in the list
3. Click Edit
4. Verify the endpoint: https://api.anthropic.com
5. Verify the x-api-key or secret is configured (you won't see the full key)
6. Click Save

Security Note: Your API key is encrypted in Salesforce. Never hardcode API keys in Apex code!

---

---

## 🧪 Step 5: Test the Integration

Let's test if Claude API is working! Open Developer Console in Salesforce:

1. Click the gear icon ⚙️ → **Developer Console**
2. Click **Debug** → **Open Execute Anonymous Window**
3. Paste this test code:

```apex
// Create a test job posting
Job_Posting__c testJob = new Job_Posting__c(
    Title__c = 'Salesforce Developer',
    Company__c = 'Test Company',
    Location__c = 'Remote',
    Workplace_Type__c = 'Remote',
    Remote_Policy__c = 'Fully Remote',
    Salary_Min__c = 90000,
    Salary_Max__c = 120000,
    Description__c = 'We are looking for a Salesforce Developer with Agentforce experience. Flexible hours, neurodivergent-friendly workplace.'
);

// Don't save it yet - just test the analysis
try {
    // Call the analyzer
    JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(testJob);

    // Print results
    System.debug('=== ANALYSIS COMPLETE ===');
    System.debug('Fit Score: ' + result.fitScore);
    System.debug('ND Friendliness: ' + result.ndFriendlinessScore);
    System.debug('Recommendation: ' + result.recommendation);
    System.debug('Green Flags: ' + result.greenFlags);
    System.debug('Red Flags: ' + result.redFlags);
    System.debug('Reasoning: ' + result.reasoning);

} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
```

4. Check **Open Log** checkbox
5. Click **Execute**
6. Click **Debug Only** filter to see just your debug statements

Expected Output:
```
=== ANALYSIS COMPLETE ===
Fit Score: 9.2
ND Friendliness: 8.5
Recommendation: HIGH PRIORITY
Green Flags:
• Fully remote work
• Agentforce experience (matches expertise)
• Flexible hours mentioned
• Neurodivergent-friendly stated
• Salary in target range ($90-120K)

Red Flags:
• No specific mention of no Monday morning meetings
• Company culture details limited

Reasoning: This role is an excellent fit. It hits all MUST HAVE requirements...
```

If you see this, your Claude integration is working.

---

## 🎯 Step 6: Create Your First Job Posting

Now let's use it for real. In Salesforce:

1. Click **App Launcher** (9 dots) → Search "Job Postings"
2. Click **New** button
3. Fill in a real job you found:
   - **Title**: (e.g., "Senior Salesforce Admin")
   - **Company**: (company name)
   - **Location**: (city or "Remote")
   - **Workplace Type**: Remote / Hybrid / On-site
   - **Remote Policy**: Fully Remote / Hybrid / Office-based
   - **Salary Min**: 85000
   - **Salary Max**: 110000
   - **Description**: (paste the job description)
   - **URL**: (link to job posting)
   - **Status**: Active
4. Click **Save**

What happens: Right now, nothing automatic. The job is saved, but not analyzed yet. In the next step, we'll add a trigger to auto-analyze.

---

## 🔄 Step 7: Manual Analysis Test

For now, let's manually analyze a job:

1. Open **Developer Console**
2. **Debug** → **Open Execute Anonymous Window**
3. Paste (replace ID with your job's ID):

```apex
// Get a job posting
Job_Posting__c job = [SELECT Id, Title__c, Company__c, Location__c,
                      Workplace_Type__c, Remote_Policy__c, Salary_Min__c,
                      Salary_Max__c, Description__c
                      FROM Job_Posting__c
                      WHERE Title__c = 'Senior Salesforce Admin'
                      LIMIT 1];

// Analyze it
JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(job);

// Update the job with results
job.Fit_Score__c = result.fitScore;
job.ND_Friendliness_Score__c = result.ndFriendlinessScore;
job.Green_Flags__c = result.greenFlags;
job.Red_Flags__c = result.redFlags;
job.Research_JSON__c = result.fullResponse;
job.Research_Date__c = DateTime.now();

update job;

System.debug('Job analyzed and updated! Fit Score: ' + result.fitScore);
```

4. Execute it
5. Refresh the Job Posting record in Salesforce
6. You should now see:
   - **Fit Score** populated (e.g., 8.5)
   - **ND Friendliness Score** populated (e.g., 7.0)
   - **Green Flags** filled with bullet points
   - **Red Flags** filled with concerns
   - **Research JSON** has the full Claude response
   - **Research Date** shows when it was analyzed

Success: You now have a working AI job analyzer.

---

## 📊 Step 8: View Your Analyzed Jobs

Create a custom list view to see fit scores:

1. Go to **Job Postings** tab
2. Click the gear icon → **New List View**
3. Name it: "High Fit Jobs"
4. **Filters**:
   - `Fit Score greater than or equal to 8`
   - `Status equals Active`
5. **Columns to Display**:
   - Job Posting Name
   - Title
   - Company
   - Fit Score
   - ND Friendliness Score
   - Application Status
   - Recommendation
6. **Save**

Now you have a dashboard showing your best job matches!

---

## 🚨 Troubleshooting

### Error: "Unauthorized endpoint"
- Fix: Make sure you added https://api.anthropic.com to Remote Site Settings (Step 3)

### Error: "401 Authentication error"
- Fix: Your API key might be wrong. Go to Named Credentials and re-enter it

### Error: "Read timed out"
- Fix: Claude is taking too long. This can happen with very long job descriptions. Try with a shorter description.

### Error: "System.JSONException: Unexpected character"
- Fix: Claude's response wasn't valid JSON. This usually happens if the prompt is unclear. Check the logs to see what Claude returned.

### No analysis happens when creating jobs
- Expected: We haven't created the trigger yet (coming in next phase). For now, use the manual analysis script from Step 7.

---

## 🎓 Learning Summary

### What You Just Built:

1. **ClaudeAPIService.cls**: Handles all communication with Claude API
   - Sends HTTP requests
   - Parses JSON responses
   - Manages authentication via Named Credential

2. **JobPostingAnalyzer.cls**: Implements your holistic decision framework
   - Builds system context with your manifestation goals
   - Applies MUST HAVE / NICE TO HAVE scoring
   - Parses Claude's analysis into structured data

3. **Named Credential**: Securely stores Claude API key
   - Salesforce encrypts the key
   - Automatically adds auth headers to requests
   - You never expose the key in code

4. **Custom Fields**: Extended Job_Posting__c with AI insights
   - Fit_Score__c: 0-10 rating
   - Application_Status__c: Tracks your pipeline
   - Links to existing ND_Friendliness_Score__c, Green/Red Flags

### Key Concepts Learned:

- **HTTP Callouts**: How to integrate external APIs in Apex
- **JSON Serialization**: Converting between Apex objects and JSON
- **Named Credentials**: Secure authentication pattern
- **Service Layer Pattern**: Separating API logic from business logic
- **Wrapper Classes**: Structuring complex data in Apex

---

## ✨ Next Steps

Now that the foundation is working, we can build:

**Phase 2a: Automation** (30 min)
- Create trigger to auto-analyze new jobs
- Batch class to analyze existing jobs
- Scheduled job to re-analyze weekly

**Phase 2b: User Interface** (2-3 hours)
- Lightning Web Component dashboard
- Job posting cards with fit scores
- One-click "Apply" button

**Phase 2c: Voice Commands** (1-2 hours)
- Set up Salesforce REST API
- Create iPhone Shortcuts
- Enable "Hey Siri, find me jobs"

Which would you like to build next?

---

## 📞 Getting Help

**If something doesn't work:**
1. Check the debug logs in Developer Console
2. Look for error messages in the deployment output
3. Review the troubleshooting section above
4. Ask Claude Code for help! I can debug errors with you.

**Understanding the code:**
- Every file has extensive LEARNING comments
- Read ClaudeAPIService.cls top to bottom - it explains HTTP callouts
- Read JobPostingAnalyzer.cls - it explains your decision framework
- The code is written to teach you, not just work

---

## 🎯 Success Criteria

You'll know it's working when:
- ✅ You can create a Job_Posting__c record
- ✅ Running manual analysis populates Fit Score and Green/Red Flags
- ✅ You can see "High Fit Jobs" list view with analyzed jobs
- ✅ Debug logs show Claude API responses
- ✅ You understand what each class does

**You're ready to move to the next phase when you can:**
1. Create a job posting
2. Run the manual analysis script
3. See the results populate
4. Explain to someone else how the integration works

---

Congratulations. You've built a working AI-powered job search assistant in Salesforce.

This is just the beginning. Next, we'll make it automatic, add a UI, and enable voice commands.

Keep building.

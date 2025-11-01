# Agentforce Deployment Guide
## Task List for Moving the Project Forward

This guide provides **clear, actionable tasks** for Agentforce to execute, helping Claude Code move the project forward efficiently.

---

## Current Status Summary

### ✅ Already Deployed
- Daily_Routine__c custom object (14 fields)
- EnergyAdaptiveScheduler.cls
- DailyRoutineInvocable.cls
- Test classes for above
- Validation rules and list views
- Report folders (Job_Search_Reports, Wellness_Reports)

### 🔧 Fixed by Claude Code (Ready to Deploy)
- Mood_Pattern_by_Day_of_Week.report-meta.xml
- Wellness_Tracker.dashboard-meta.xml

### 📝 New Files Created by Claude Code
- test_all_energy_levels.apex (comprehensive test script)
- DAILY_ENERGY_CHECKIN_FLOW_DESIGN.md (flow specification)

---

## Priority 1: Test Current Deployment 🧪

### Task 1.1: Run Basic Wellness Test
**What to do:**
```
1. Open Developer Console in Salesforce
2. Click: Debug → Open Execute Anonymous Window
3. Copy and paste contents of: test_wellness_functionality.apex
4. Check "Open Log"
5. Click "Execute"
```

**What to verify:**
- [ ] No errors in execution
- [ ] Debug log shows "Success: true"
- [ ] Debug log shows Energy Category = "Medium"
- [ ] Debug log shows Study Hours = 3
- [ ] Debug log shows today's schedule

**If successful, proceed to Task 1.2**
**If errors occur, report the error message to Claude Code**

---

### Task 1.2: Run Comprehensive Energy Tests
**What to do:**
```
1. Open Developer Console
2. Debug → Open Execute Anonymous Window
3. Copy and paste contents of: test_all_energy_levels.apex
4. Check "Open Log"
5. Click "Execute"
```

**What to verify:**
- [ ] All 5 tests execute without errors
- [ ] High Energy (level 9): 4 study hrs, 2 job search hrs
- [ ] Medium Energy (level 6): 3 study hrs, 1.5 job search hrs
- [ ] Low Energy (level 3): 2 study hrs, 0.5-1 job search hrs
- [ ] Flare-up (level 1): 0 study hrs, rest message shown
- [ ] Update test shows "updated successfully"

**If successful, proceed to Priority 2**
**If errors occur, report which test failed and the error**

---

### Task 1.3: Verify Data Created
**What to do:**
```
1. In Salesforce, navigate to: App Launcher → Daily Routines
2. Look for records with today's date
3. Click on a record to view details
```

**What to verify:**
- [ ] Daily_Routine__c records exist
- [ ] Fields populated: Energy_Level_Morning__c, Mood__c, Date__c
- [ ] Date__c = Today
- [ ] At least one record has Energy_Level_Morning__c = 8

**Report findings to Claude Code**

---

## Priority 2: Deploy Fixed Wellness Reports & Dashboards 📊

### Task 2.1: Deploy Fixed Report
**What to do:**
```
1. Deploy this file to the org:
   force-app/main/default/reports/Wellness_Reports/Mood_Pattern_by_Day_of_Week.report-meta.xml

Command:
sf project deploy start --source-path "force-app/main/default/reports/Wellness_Reports/Mood_Pattern_by_Day_of_Week.report-meta.xml" --target-org MyDevOrg
```

**What to verify:**
- [ ] Deployment succeeds (Status: Succeeded)
- [ ] No XML parsing errors
- [ ] Report appears in Salesforce: Reports → Wellness Reports → Mood Pattern by Day of Week

**If successful, proceed to Task 2.2**
**If errors occur, copy the FULL error message to Claude Code**

---

### Task 2.2: Deploy Remaining Wellness Reports
**What to do:**
```
Deploy these files:
- force-app/main/default/reports/Wellness_Reports/Energy_Trend_Past_30_Days.report-meta.xml
- force-app/main/default/reports/Wellness_Reports/Morning_Routine_Completion_Streak.report-meta.xml

Command:
sf project deploy start --source-path "force-app/main/default/reports/Wellness_Reports" --target-org MyDevOrg
```

**What to verify:**
- [ ] Both reports deploy successfully
- [ ] Reports visible in Salesforce UI
- [ ] No XML errors

**Report any errors to Claude Code**

---

### Task 2.3: Deploy Fixed Wellness Dashboard
**What to do:**
```
Deploy this file:
force-app/main/default/dashboards/Wellness_Dashboards/Wellness_Tracker.dashboard-meta.xml

Command:
sf project deploy start --source-path "force-app/main/default/dashboards/Wellness_Dashboards" --target-org MyDevOrg
```

**What to verify:**
- [ ] Dashboard deploys successfully
- [ ] Dashboard visible: Dashboards → Wellness Dashboards → Wellness Tracker
- [ ] Dashboard components display (even if "No data" message)

**Report success or errors to Claude Code**

---

### Task 2.4: Test Dashboard with Real Data
**What to do:**
```
1. Create 5-7 Daily_Routine__c records with different dates (last week)
2. Vary the energy levels: 3, 5, 6, 7, 9
3. Vary the moods: Low, Okay, Good, Good, Great
4. Open the Wellness Tracker dashboard
5. Click "Refresh" button
```

**What to verify:**
- [ ] Dashboard shows energy trend line
- [ ] Mood pattern chart displays with colors
- [ ] Morning routine streak shows a number
- [ ] Recent check-ins table shows records

**Report what you see - success or any component errors**

---

## Priority 3: Create Daily Energy Check-In Flow 🌟

### Task 3.1: Create the Screen Flow
**What to do:**
```
1. In Salesforce: Setup → Flows → New Flow
2. Select: Screen Flow
3. Follow the detailed instructions in: DAILY_ENERGY_CHECKIN_FLOW_DESIGN.md
4. Build each screen, action, and decision as specified
```

**Key elements to create:**
- [ ] Screen 1: Energy input (slider 1-10, mood radio buttons, morning routine toggle)
- [ ] Action: Call "Get Energy-Adaptive Schedule" invocable method
- [ ] Decision: Check if success = true
- [ ] Screen 2: Display schedule and goals (success path)
- [ ] Screen 3: Error message (failure path)
- [ ] All variables created as specified in design doc

**This is the most complex task - report any questions or issues to Claude Code**

---

### Task 3.2: Test the Flow
**What to do:**
```
1. Click "Run" in Flow Builder (lightning bolt icon)
2. Test with Energy Level = 7, Mood = Good, Morning Routine = checked
3. Click through to see the schedule display
4. Run again with Energy Level = 2, Mood = Low, Morning Routine = unchecked
```

**What to verify:**
- [ ] Flow runs without errors
- [ ] Schedule displays based on energy level
- [ ] Different energy levels show different schedules
- [ ] Record is created/updated in Daily_Routine__c

**Report success or any error messages**

---

### Task 3.3: Activate the Flow
**What to do:**
```
1. In Flow Builder, click "Save"
2. Flow Label: "Daily Energy Check-In"
3. Flow API Name: "Daily_Energy_Check_In"
4. Click "Activate"
```

**What to verify:**
- [ ] Flow saves successfully
- [ ] Flow status = "Active"
- [ ] Flow visible in Flow list

---

### Task 3.4: Add Flow to Home Page
**What to do:**
```
Option A - Lightning App Builder:
1. Setup → Lightning App Builder
2. Edit the home page (or create new)
3. Drag "Flow" component to page
4. Select: Daily_Energy_Check_In
5. Save & Activate

Option B - Quick Action:
1. Setup → Global Actions → New Action
2. Action Type: Flow
3. Flow: Daily_Energy_Check_In
4. Label: "Daily Check-In"
5. Save and add to Home page layout
```

**What to verify:**
- [ ] "Daily Check-In" button/component visible on home page
- [ ] Clicking it launches the flow
- [ ] Flow works as expected from home page

**Report which option you chose and if it worked**

---

## Priority 4: Deploy Job Search AI System 🤖

**IMPORTANT:** Only start Priority 4 after Priorities 1-3 are successful.

### Task 4.1: Verify Claude API Key
**What to do:**
```
1. Check if you have access to the Claude API key
2. Verify it's in this format: sk-ant-api03-...
```

**Action needed:**
- [ ] If you have the API key, proceed to Task 4.2
- [ ] If you DON'T have it, ask the user to provide it

---

### Task 4.2: Create Named Credential
**What to do:**
```
1. Setup → Named Credentials
2. Click "New" → "New Legacy"
3. Fill in:
   - Label: Claude API
   - Name: Claude_API
   - URL: https://api.anthropic.com/v1/messages
   - Identity Type: Named Principal
   - Authentication Protocol: Custom
   - Generate Authorization Header: UNCHECKED
   - Allow Merge Fields: CHECKED
```

**Custom Headers to add:**
```
Key: anthropic-version
Value: 2023-06-01

Key: x-api-key
Value: [INSERT CLAUDE API KEY HERE]

Key: Content-Type
Value: application/json
```

**What to verify:**
- [ ] Named Credential saves successfully
- [ ] Named Credential visible in list
- [ ] URL and headers are correct

**Report success or any errors**

---

### Task 4.3: Deploy Job_Posting__c Object
**What to do:**
```
Deploy the Job_Posting__c custom object and all its fields:

Command:
sf project deploy start --source-path "force-app/main/default/objects/Job_Posting__c" --target-org MyDevOrg
```

**Key fields to verify after deployment:**
- [ ] Title__c
- [ ] Company__c
- [ ] Fit_Score__c (Number)
- [ ] ND_Friendliness_Score__c (Number)
- [ ] Green_Flags__c (Long Text)
- [ ] Red_Flags__c (Long Text)
- [ ] Application_Status__c (Picklist)

**Report success or specific field errors**

---

### Task 4.4: Deploy Claude API Classes
**What to do:**
```
Deploy these Apex classes IN ORDER:

1. ClaudeAPIService.cls (the foundation)
2. JobPostingAnalyzer.cls (uses ClaudeAPIService)
3. JobPostingAnalysisQueue.cls (queueable)
4. JobPostingTriggerHandler.cls (trigger handler)

Command:
sf project deploy start --source-path "force-app/main/default/classes/ClaudeAPIService.cls" --target-org MyDevOrg

sf project deploy start --source-path "force-app/main/default/classes/JobPostingAnalyzer.cls" --target-org MyDevOrg

# Continue for each class...
```

**What to verify:**
- [ ] All 4 classes deploy successfully
- [ ] Test classes also deploy
- [ ] Classes visible in Setup → Apex Classes

**Report any compilation errors to Claude Code**

---

### Task 4.5: Deploy Job Posting Trigger
**What to do:**
```
Deploy the trigger that auto-analyzes jobs:

Command:
sf project deploy start --source-path "force-app/main/default/triggers" --target-org MyDevOrg
```

**What to verify:**
- [ ] JobPostingTrigger deploys successfully
- [ ] Trigger is active

**Report success or errors**

---

### Task 4.6: Test Claude API Integration
**What to do:**
```
1. Create a Job_Posting__c record manually:
   - Title: "Senior Salesforce Developer"
   - Company: "Test Company"
   - Description: "Remote Salesforce role with flexible hours"
   - Salary Range: "$90,000 - $120,000"

2. Wait 30-60 seconds

3. Refresh the Job_Posting__c record

4. Check these fields:
   - Fit_Score__c
   - ND_Friendliness_Score__c
   - Green_Flags__c
   - Red_Flags__c
```

**What to verify:**
- [ ] Record creates without error
- [ ] After 30-60 seconds, AI fields populate
- [ ] Fit_Score__c has a value (0-10)
- [ ] Green_Flags__c contains text
- [ ] Red_Flags__c contains text

**If fields DON'T populate:**
- Check: Setup → Apex Jobs → check for errors
- Check: Debug Logs for API errors
- Report findings to Claude Code

---

## Priority 5: Deploy Resume Generator 📝

**IMPORTANT:** Only start Priority 5 after Priority 4 is working.

### Task 5.1: Deploy Resume Objects
**What to do:**
```
Deploy these custom objects:
- Resume_Package__c
- Master_Resume__c
- Master_Resume_Config__c

Command:
sf project deploy start --source-path "force-app/main/default/objects/Resume_Package__c" --target-org MyDevOrg

# Repeat for other objects
```

**What to verify:**
- [ ] All 3 objects deploy successfully
- [ ] Objects visible in Object Manager

---

### Task 5.2: Deploy Resume Generator Classes
**What to do:**
```
Deploy:
- ResumeGenerator.cls
- ResumeGeneratorInvocable.cls
- Test classes

Command:
sf project deploy start --source-path "force-app/main/default/classes/ResumeGenerator.cls" --target-org MyDevOrg

# Repeat for other classes
```

**What to verify:**
- [ ] Classes deploy without errors
- [ ] Test classes pass

---

### Task 5.3: Deploy Quick Action
**What to do:**
```
Deploy the "Generate Resume Package" quick action:

Command:
sf project deploy start --source-path "force-app/main/default/quickActions" --target-org MyDevOrg
```

**What to verify:**
- [ ] Quick action deploys
- [ ] Quick action visible on Job_Posting__c page layout

---

### Task 5.4: Test Resume Generation
**What to do:**
```
1. Create a Master_Resume__c record with your info
2. Open a Job_Posting__c record (with Fit_Score > 7)
3. Click "Generate Resume Package" button
4. Wait 30-60 seconds
5. Check for new Resume_Package__c record
```

**What to verify:**
- [ ] Resume_Package__c record is created
- [ ] Tailored resume content is generated
- [ ] Content is relevant to job posting

**Report success or errors**

---

## Priority 6: Deploy Flows & Automation ⚡

### Task 6.1: Deploy Flows
**What to do:**
```
Deploy these flows:
- High_Priority_Job_Alert
- Interview_Reminder_Tasks
- Weekly_Job_Search_Summary
- Auto_Update_Job_Status_on_Resume_Generation

Command:
sf project deploy start --source-path "force-app/main/default/flows" --target-org MyDevOrg
```

**What to verify:**
- [ ] All flows deploy successfully
- [ ] Flows are Active (or Activate them manually)

---

### Task 6.2: Test High Priority Alert
**What to do:**
```
1. Create a Job_Posting__c with:
   - ND_Friendliness_Score__c = 9
   - Application_Status__c = "Not Applied"

2. Wait a few minutes

3. Check: Home → Today's Tasks
```

**What to verify:**
- [ ] Task created reminding you to apply
- [ ] Task links to the job posting

---

## Priority 7: Deploy Reports & Dashboards 📊

### Task 7.1: Deploy Job Search Reports
**What to do:**
```
Deploy all Job Search reports:

Command:
sf project deploy start --source-path "force-app/main/default/reports/Job_Search_Reports" --target-org MyDevOrg
```

**What to verify:**
- [ ] All 6 reports deploy successfully
- [ ] Reports visible in Reports tab

---

### Task 7.2: Deploy Job Search Dashboard
**What to do:**
```
Deploy the Job Search Overview dashboard:

Command:
sf project deploy start --source-path "force-app/main/default/dashboards/Job_Search_Dashboards" --target-org MyDevOrg
```

**What to verify:**
- [ ] Dashboard deploys successfully
- [ ] Dashboard displays (even if no data yet)

---

### Task 7.3: Populate Test Data
**What to do:**
```
Create 5-10 Job_Posting__c records with various:
- Fit scores (4, 6, 7, 8, 9)
- Application statuses
- Interview dates (some upcoming, some past)
```

**What to verify:**
- [ ] Dashboard shows data in all components
- [ ] Charts render correctly
- [ ] Metrics display numbers

**Take a screenshot and share with user!**

---

## Priority 8: Deploy Permission Sets 🔐

### Task 8.1: Deploy Permission Sets
**What to do:**
```
Deploy permission sets:
- Full_Platform_Access
- Wellness_Only_Access

Command:
sf project deploy start --source-path "force-app/main/default/permissionsets" --target-org MyDevOrg
```

**What to verify:**
- [ ] Permission sets deploy successfully
- [ ] Permission sets visible in Setup → Permission Sets

---

### Task 8.2: Assign Permission Set to User
**What to do:**
```
1. Setup → Users → [Your User]
2. Permission Set Assignments
3. Click "Edit Assignments"
4. Add: Full_Platform_Access
5. Save
```

**What to verify:**
- [ ] Permission set assigned
- [ ] User has access to all custom objects

---

## Communication Protocol 📣

### When Reporting Success
Please provide:
- ✅ Task completed: [Task Number]
- ✅ What you deployed/tested
- ✅ Verification results (all checkboxes passed)
- ✅ Ready for next task? Yes/No

### When Reporting Errors
Please provide:
- ❌ Task failed: [Task Number]
- ❌ What you were attempting
- ❌ FULL error message (copy/paste entire error)
- ❌ Any relevant debug log snippets
- ❌ Screenshots if helpful

### When Asking Questions
Please provide:
- ❓ Task you're on: [Task Number]
- ❓ Specific question
- ❓ What you've tried so far
- ❓ What you're unsure about

---

## Quick Reference: Files by Priority

### Priority 1 (Testing)
- test_wellness_functionality.apex
- test_all_energy_levels.apex

### Priority 2 (Wellness Reports)
- reports/Wellness_Reports/Mood_Pattern_by_Day_of_Week.report-meta.xml
- reports/Wellness_Reports/Energy_Trend_Past_30_Days.report-meta.xml
- reports/Wellness_Reports/Morning_Routine_Completion_Streak.report-meta.xml
- dashboards/Wellness_Dashboards/Wellness_Tracker.dashboard-meta.xml

### Priority 3 (Flow)
- Follow DAILY_ENERGY_CHECKIN_FLOW_DESIGN.md

### Priority 4 (Job Search Core)
- objects/Job_Posting__c/
- classes/ClaudeAPIService.cls
- classes/JobPostingAnalyzer.cls
- classes/JobPostingAnalysisQueue.cls
- classes/JobPostingTriggerHandler.cls
- triggers/JobPostingTrigger.trigger

### Priority 5 (Resume Generator)
- objects/Resume_Package__c/
- objects/Master_Resume__c/
- classes/ResumeGenerator.cls
- classes/ResumeGeneratorInvocable.cls
- quickActions/Job_Posting__c.Generate_Resume_Package.quickAction-meta.xml

### Priority 6 (Flows)
- flows/High_Priority_Job_Alert.flow-meta.xml
- flows/Interview_Reminder_Tasks.flow-meta.xml
- flows/Weekly_Job_Search_Summary.flow-meta.xml
- flows/Auto_Update_Job_Status_on_Resume_Generation.flow-meta.xml

### Priority 7 (Job Search Reports)
- reports/Job_Search_Reports/ (all files)
- dashboards/Job_Search_Dashboards/Job_Search_Overview.dashboard-meta.xml

### Priority 8 (Security)
- permissionsets/Full_Platform_Access.permissionset-meta.xml
- permissionsets/Wellness_Only_Access.permissionset-meta.xml

---

## Success Metrics

### Wellness System Complete When:
- [ ] Daily Energy Check-In flow works from home page
- [ ] Wellness dashboard displays with real data
- [ ] User can log energy and get adaptive schedule

### Job Search AI Complete When:
- [ ] Creating Job_Posting__c auto-analyzes with Claude
- [ ] Fit scores and ND scores populate automatically
- [ ] Job Search dashboard shows pipeline

### Resume Generator Complete When:
- [ ] "Generate Resume Package" button works
- [ ] Tailored resumes created via Claude API
- [ ] Resume_Package__c records linked to jobs

### Full System Complete When:
- [ ] All 8 priorities completed
- [ ] User can check-in daily and get adaptive schedule
- [ ] User can add jobs and get AI analysis
- [ ] User can generate tailored resumes
- [ ] Dashboards show full pipeline and wellness trends
- [ ] Flows send alerts and reminders

---

**Let's ship this! 🚀**

Start with Priority 1, Task 1.1 and report back!

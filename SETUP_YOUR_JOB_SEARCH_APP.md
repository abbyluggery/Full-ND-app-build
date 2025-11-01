# Setup Your Automated Job Search App

## What We Built

You now have a **Claude-powered job analysis system** that automatically:
- Analyzes job postings using your manifestation goals ($155K target, ND accommodations)
- Scores ND-friendliness (0-10)
- Identifies green flags (remote work, Agentforce focus, flexibility)
- Flags red flags (missing accommodations, rigid schedules)
- Runs automatically when you create/update job postings

---

## Step 1: Add Job Posting to Your App Menu

Right now the Job_Posting__c object exists but isn't visible in your app navigation.

### Option A: Add to Sales App (Quick)

1. **Click the gear icon** (⚙️) in top-right → **Setup**
2. In Quick Find box, search: **App Manager**
3. Find **Sales** app → Click dropdown → **Edit**
4. Click **Navigation Items**
5. Click **Add More Items**
6. Find **Job Postings** in Available Items
7. Click **Add** (moves it to Selected Items)
8. Click **Save**

### Option B: Create a Custom Job Search App (Better!)

1. **Setup** → Quick Find: **App Manager**
2. Click **New Lightning App**
3. **App Details:**
   - App Name: `Job Search Assistant`
   - Developer Name: `Job_Search_Assistant`
   - Description: `Claude-powered job search with ND-friendly analysis`
4. Click **Next**
5. **App Options:**
   - Leave defaults
   - Click **Next**
6. **Utility Items:**
   - Skip for now
   - Click **Next**
7. **Navigation Items:**
   - Select **Job Postings** from Available Items
   - Click **Add** to move to Selected Items
   - Order: Job Postings should be first
   - Click **Next**
8. **User Profiles:**
   - Select **System Administrator**
   - Click **Save & Finish**

Now you'll see **Job Search Assistant** in your app launcher!

---

## Step 2: Create a List View for Active Jobs

1. **Go to Job Postings** tab (in your app)
2. Click the list view dropdown (probably says "Recently Viewed")
3. Click **New**
4. **List Name:** `Active - Needs Review`
5. **List API Name:** `Active_Needs_Review`
6. **Who sees this list view:** All users can see this list view
7. Click **Save**
8. Click **Add Filter**:
   - Field: **Status** | Operator: **equals** | Value: **Active**
9. Click **Done** → **Save**
10. Click **Select Fields to Display**
11. Add these columns (drag from Available to Visible):
    - Title
    - Company
    - Location
    - Remote Policy
    - Salary Min
    - Salary Max
    - ND Friendliness Score
    - Green Flags
    - Red Flags
    - Posted Date
12. Click **Save**

---

## Step 3: Create a Quick Action to Add Jobs Fast

1. **Setup** → Quick Find: **Object Manager**
2. Click **Job Posting**
3. Click **Buttons, Links, and Actions**
4. Click **New Action**
5. **Action Type:** Create a Record
6. **Target Object:** Job_Posting__c
7. **Label:** Quick Add Job
8. Click **Save**
9. **Layout Editor:**
   - Add these fields to the layout:
     - Title
     - Company
     - Location
     - Remote Policy
     - Salary Min
     - Salary Max
     - Description
     - Apply URL
     - Provider
   - Remove fields you don't need
10. Click **Save**

---

## Step 4: Test the Full Workflow

### Create Your First Real Job Posting

1. Go to **Job Postings** tab
2. Click **New**
3. Fill in a real job:

**Example Job:**
```
Title: Senior Salesforce Developer - Remote
Company: CloudTech Solutions
Location: Remote - USA
Workplace Type: Remote
Remote Policy: Fully Remote
Salary Min: 100000
Salary Max: 130000
Status: Active
Posted Date: [Today]
Provider: LinkedIn
Apply URL: https://linkedin.com/jobs/12345
ExternalID: linkedin_12345

Description:
Join our growing Agentforce team! We're looking for a Salesforce developer passionate about AI and automation.

What we offer:
- 100% remote, work from anywhere
- Flexible hours - no rigid 9-5
- Async-first communication
- Unlimited PTO
- Strong focus on work-life balance
- Mental health support

Requirements:
- 3+ years Salesforce experience
- Apex, LWC, Flows
- Experience with AI/Agentforce a plus
```

4. Click **Save**
5. **Wait 10-15 seconds** for Claude to analyze
6. **Refresh the page**
7. Scroll down to see:
   - ND Friendliness Score
   - Green Flags
   - Red Flags

---

## Step 5: Check the Queue Status (Optional)

To see if your automation is running:

1. **Setup** → Quick Find: **Apex Jobs**
2. Look for jobs named **JobPostingAnalysisQueue**
3. Status should show:
   - **Queued** (waiting to run)
   - **Processing** (currently running)
   - **Completed** (finished successfully)

If Status = Completed and errors = 0, it worked!

---

## What Happens Automatically

When you create or update a job posting:

1. **Trigger fires** (JobPostingTrigger)
2. **Queue job starts** (JobPostingAnalysisQueue)
3. **Claude API is called** with your holistic context:
   - Your skills (2.5 years SF experience, Agentforce expertise)
   - Your manifestation goals ($155K target, $85K minimum)
   - Your ND accommodations (no meetings before 10am Monday, 5:15pm hard stop)
   - MUST HAVEs (remote, flexible schedule, ND-friendly culture)
   - NICE TO HAVEs (Agentforce focus +2, ND accommodations +2)
4. **Claude analyzes** the job against your framework
5. **Fields populate** automatically:
   - ND Friendliness Score (0-10)
   - Green Flags (bulleted list)
   - Red Flags (concerns)

---

## Tips for Using Your System

### High Priority Jobs
- ND Friendliness Score ≥ 8
- Green Flags mention: Agentforce, flexibility, remote, accommodations
- No major red flags

### Good Fit Jobs
- ND Friendliness Score 6-7
- Most MUST HAVEs met
- Minor red flags that can be discussed

### Skip These
- ND Friendliness Score < 6
- Red flags mention: rigid hours, office required, no flexibility
- Missing multiple MUST HAVEs

---

## Troubleshooting

**Fields not populating?**
1. Check Apex Jobs (Setup → Apex Jobs)
2. Look for errors in the queue job
3. Run this in Developer Console to manually trigger:
```apex
List<Id> jobIds = [SELECT Id FROM Job_Posting__c WHERE nd_friendliness_score__c = null LIMIT 1];
if (!jobIds.isEmpty()) {
    JobPostingAnalysisQueue.enqueueAnalysis(jobIds);
}
```

**"Content Blocked" error in UI?**
- Use list views instead of record detail pages
- Or check with your admin about page layout permissions

---

## Next Steps

1. ✅ Set up your app navigation (Step 1)
2. ✅ Create list views (Step 2)
3. ✅ Test with a real job posting (Step 4)
4. 📊 Add more fields like `fit_score__c` for overall scoring
5. 📈 Create reports and dashboards for job tracking
6. 🎯 Add more automation (email alerts for high-priority jobs)

You now have a working AI-powered job search assistant! 🚀

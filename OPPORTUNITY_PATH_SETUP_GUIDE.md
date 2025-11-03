# Opportunity Path Setup Guide
## Job Search Application Tracking

This guide explains how to configure the Opportunity Path with custom stages for tracking your job application progress.

---

## Overview

The Opportunity object will track your job applications through various stages from initial callback to final offer. The Path component at the top of the Opportunity page will show visual progress through these stages.

---

## Stage Configuration

### Recommended Stages for Job Search Applications

| Stage Name | Probability | Description |
|-----------|-------------|-------------|
| **Job Discovered** | 10% | Initial job posting found and saved |
| **Application Prepared** | 20% | Resume and cover letter tailored |
| **Application Submitted** | 30% | Application submitted to company |
| **Screening Call** | 40% | Initial phone screen with recruiter (default when callback occurs) |
| **Phone Screen** | 50% | Technical or hiring manager phone interview |
| **Technical Interview** | 60% | Technical assessment or coding challenge |
| **Final Interview** | 75% | Final round with hiring manager/team |
| **Offer Negotiation** | 90% | Offer received, negotiating terms |
| **Closed Won** | 100% | Offer accepted! |
| **Closed Lost** | 0% | Rejected or withdrew application |

---

## Setup Instructions

### Step 1: Add Custom Stages to Opportunity

1. Navigate to **Setup** > **Object Manager** > **Opportunity**
2. Click **Fields & Relationships**
3. Click on the **Stage** field
4. Scroll to the **Opportunity Stage Picklist Values** section
5. Click **New** for each stage listed above
6. Enter the **Stage Name** exactly as shown
7. Enter the **Probability** percentage
8. Check **Forecast Category** as appropriate:
   - Screening Call through Offer Negotiation → "Pipeline"
   - Closed Won → "Closed"
   - Closed Lost → "Omitted"
9. Click **Save**

### Step 2: Create Sales Process

1. Navigate to **Setup** > **Feature Settings** > **Sales** > **Sales Processes**
2. Click **New**
3. Name it: **Job Search Application Process**
4. Select **Existing Sales Process**: Master (or any existing process)
5. Click **Save**
6. Select the stages you created:
   - ☑ Job Discovered
   - ☑ Application Prepared
   - ☑ Application Submitted
   - ☑ Screening Call
   - ☑ Phone Screen
   - ☑ Technical Interview
   - ☑ Final Interview
   - ☑ Offer Negotiation
   - ☑ Closed Won
   - ☑ Closed Lost
7. Click **Save**

### Step 3: Create Record Type (Optional but Recommended)

1. Navigate to **Setup** > **Object Manager** > **Opportunity** > **Record Types**
2. Click **New**
3. Enter:
   - **Record Type Label**: Job Search Application
   - **Record Type Name**: Job_Search_Application
   - **Description**: For tracking job application progress
4. Select the **Job Search Application Process** sales process
5. Make it available to your profile
6. Click **Save**

### Step 4: Enable Path

1. Navigate to **Setup** > **User Interface** > **Path Settings**
2. Click **Enable** (if not already enabled)
3. Click **New Path**
4. Select **Object**: Opportunity
5. Select **Record Type**: Job Search Application (if you created one)
6. Select **Picklist**: Stage
7. Click **Next**
8. Configure Path Settings:
   - **Path Name**: Job Application Progress
   - **API Name**: Job_Application_Progress
9. Click **Finish**

### Step 5: Configure Path Fields and Guidance

For each stage, you can add guidance text and key fields:

**Screening Call Stage:**
- **Guidance**: "Great! You received a callback. Prepare for the screening call by researching the company and reviewing the job description."
- **Key Fields to Update**: Close Date, Primary Contact

**Phone Screen Stage:**
- **Guidance**: "Prepare technical questions and examples of your work. Review the job requirements in detail."

**Technical Interview Stage:**
- **Guidance**: "Complete any take-home assessments. Practice explaining your thought process."

**Final Interview Stage:**
- **Guidance**: "Meet with the team. Ask about day-to-day responsibilities and team culture."

**Offer Negotiation Stage:**
- **Guidance**: "Review the offer carefully. Negotiate salary, benefits, start date, and remote work policy."

### Step 6: Update Page Layout

1. Navigate to **Setup** > **Object Manager** > **Opportunity** > **Page Layouts**
2. Click **Edit** on the relevant layout
3. Ensure the **Path** component is added at the top
4. Add the **Job Posting** lookup field to the layout (in the Information section)
5. Click **Save**

---

## Using the Workflow

### When Callback Occurs on Job_Posting__c

1. Update **Application_Status__c** to "Callback Received"
2. The trigger will automatically:
   - Create an Account (or use existing) for the company
   - Create a Contact from the recruiter information
   - Create an Opportunity in the "Screening Call" stage
   - Link the Contact as the primary contact role
3. Navigate to the newly created Opportunity
4. Use the Path component to track your progress through interview stages

### Moving Through Stages

- Click on a stage in the Path to expand it
- Update the fields shown in the guidance panel
- Click **Mark Stage as Complete** to move to the next stage
- Add notes in the Activity timeline about each interview

---

## Integration with Existing Job_Posting__c Fields

The Opportunity mirrors your Application_Status__c field but provides more granular tracking:

| Job_Posting__c Status | Opportunity Stage |
|-----------------------|-------------------|
| Not Applied | Job Discovered |
| Applied | Application Submitted |
| Callback Received | Screening Call ← **Trigger creates Opportunity here** |
| Phone Screen | Phone Screen |
| Interview | Technical Interview or Final Interview |
| Offer | Offer Negotiation |
| Accepted | Closed Won |
| Rejected | Closed Lost |
| Declined | Closed Lost |

---

## Reporting and Dashboards

With Opportunities tracking your applications, you can create powerful reports:

### Recommended Reports

1. **Active Applications by Stage** - See how many jobs are in each stage
2. **Average Time in Stage** - Identify bottlenecks in your job search
3. **Conversion Rate by Company** - Which companies have the highest offer rate
4. **Applications by Month** - Track your job search velocity

### Sample Dashboard Components

- **Applications Pipeline** - Funnel chart showing stages
- **Offers Pending** - Opportunities in "Offer Negotiation"
- **Interview Calendar** - Upcoming close dates (interview dates)
- **Top Companies** - Accounts with most opportunities

---

## Tips for Success

### Keep Opportunities Updated
- Update the stage after each interview or interaction
- Use the Close Date field for your next scheduled interview
- Log calls and emails in the Activity timeline

### Use Tasks for Prep Work
- Create tasks for "Prepare for technical interview"
- Set reminders for follow-up emails
- Track thank-you notes sent

### Leverage Contact Roles
- Add multiple contacts from the same company
- Mark decision-makers vs. interviewers
- Track who you've interviewed with

---

## Troubleshooting

### Path Not Showing
- Verify Path is enabled in Setup
- Check that you're using the correct Record Type
- Ensure the Page Layout includes the Path component

### Opportunity Not Created Automatically
- Verify Application_Status__c changed to "Callback Received"
- Check that Company__c field has a value
- Review debug logs for errors in OpportunityCreationTrigger

### Wrong Stage Default
- The handler creates Opportunities in "Screening Call" stage
- If you need a different default, update line 145 in OpportunityCreationHandler.cls:
  ```apex
  opp.StageName = 'Screening Call'; // Change this value
  ```

---

## Next Steps

After setup:

1. ✅ Deploy all metadata to your org
2. ✅ Configure Opportunity stages in Setup
3. ✅ Create the Sales Process
4. ✅ Enable and configure Path
5. ✅ Test the workflow end-to-end
6. ✅ Create reports and dashboards

---

## Additional Enhancements

### Future Improvements

- **Automated Stage Updates**: Create a Flow to update Job_Posting__c.Application_Status__c when Opportunity stage changes
- **Email Alerts**: Send yourself reminders when you haven't updated an Opportunity in 7 days
- **Interview Scheduler**: Integrate with Google Calendar to auto-create events
- **Offer Comparison**: Create a custom object to compare multiple offers side-by-side

---

**Created**: November 2025
**For**: Job Search AI Assistant Project
**Author**: Abby Luggery

# Weekly Job Search Summary Flow - Setup Guide
**Date**: November 12, 2025
**Time Required**: 10-15 minutes
**Complexity**: Easy (point-and-click in Flow Builder)

---

## Why Build in UI Instead of Deploy?

Scheduled flows are notoriously difficult to deploy via CLI because:
- Schedule jobs must be manually activated
- Text template connections have strict validation
- UI provides real-time validation and easier debugging

**Building in UI is actually faster and more reliable!**

---

## Step-by-Step Instructions

### Step 1: Open Flow Builder (2 min)
1. Click Setup gear icon (top right)
2. Type "Flows" in Quick Find
3. Click **Flows**
4. Click **New Flow** button
5. Select **Scheduled Flow**
6. Click **Create**

---

### Step 2: Configure Schedule (1 min)
1. Click the **Start** element
2. Set schedule:
   - **Frequency**: Weekly
   - **Day**: Monday (or your preference)
   - **Time**: 8:00 AM
   - **Start Date**: Next Monday (or today to test)
3. Click **Done**

---

### Step 3: Get Jobs Analyzed This Week (2 min)
1. Click the **+** icon after Start
2. Select **Get Records**
3. Configure:
   - **Label**: Get Jobs Analyzed This Week
   - **Object**: Job_Posting__c
   - **Condition Requirements**: All Conditions Are Met (AND)
   - **Conditions**:
     - Research_Date__c ≥ `{!LastWeekStartDate}` (we'll create this formula next)
   - **How Many Records**: All records
   - **How to Store**: Automatically store all fields
4. Click **Done**

**WAIT!** We need to create the formula first. Let's do that:

#### Create LastWeekStartDate Formula
1. In the Toolbox (left side), click **New Resource**
2. **Resource Type**: Formula
3. **API Name**: LastWeekStartDate
4. **Data Type**: Date
5. **Formula**: `TODAY() - 7`
6. Click **Done**

Now go back and add that condition to step 3 above.

---

### Step 4: Get High Priority Jobs (2 min)
1. Click the **+** icon after "Get Jobs Analyzed This Week"
2. Select **Get Records**
3. Configure:
   - **Label**: Get High Priority Jobs
   - **Object**: Job_Posting__c
   - **Condition Requirements**: All Conditions Are Met (AND)
   - **Conditions**:
     - ND_Friendliness_Score__c ≥ 8
     - Application_Status__c ≠ Applied
     - Application_Status__c ≠ Rejected
   - **How Many Records**: All records
   - **How to Store**: Automatically store all fields
4. Click **Done**

---

### Step 5: Get Upcoming Interviews (2 min)
1. Click **+** after "Get High Priority Jobs"
2. Select **Get Records**
3. Configure:
   - **Label**: Get Upcoming Interviews
   - **Object**: Job_Posting__c
   - **Condition Requirements**: All Conditions Are Met (AND)
   - **Conditions**:
     - Interview_Date__c ≥ `{!$Flow.CurrentDate}`
     - Interview_Date__c ≤ `{!NextWeekEndDate}` (create this formula - see below)
     - Interview_Completed__c = False
   - **How Many Records**: All records
   - **How to Store**: Automatically store all fields
4. Click **Done**

#### Create NextWeekEndDate Formula
1. Click **New Resource**
2. **Resource Type**: Formula
3. **API Name**: NextWeekEndDate
4. **Data Type**: Date
5. **Formula**: `TODAY() + 7`
6. Click **Done**

---

### Step 6: Send Email (3 min)
1. Click **+** after "Get Upcoming Interviews"
2. Select **Action**
3. Search for and select **Send Email**
4. Configure:
   - **Label**: Send Weekly Summary
   - **Recipient Email Addresses**: `{!$User.Email}`
   - **Subject**:
     ```
     📊 Your Job Search Summary - Week of {!$Flow.CurrentDate}
     ```
   - **Body** (use rich text editor):

```
📊 WEEKLY JOB SEARCH SUMMARY
========================================

Week of: {!$Flow.CurrentDate}


📈 THIS WEEK'S ACTIVITY:
========================================

• Jobs Analyzed: {!Get_Jobs_Analyzed_This_Week}
• High Priority Jobs (ND Score ≥ 8): {!Get_High_Priority_Jobs}
• Upcoming Interviews: {!Get_Upcoming_Interviews}


🎯 ACTION ITEMS FOR THIS WEEK:
========================================

1. HIGH-PRIORITY JOBS NEEDING ATTENTION
   ▸ You have {!Get_High_Priority_Jobs} jobs with ND Friendliness Score ≥ 8
   ▸ These jobs haven't been applied to yet
   ▸ ACTION: Generate resume packages and apply!

2. UPCOMING INTERVIEWS
   ▸ You have {!Get_Upcoming_Interviews} interviews scheduled in the next 7 days
   ▸ ACTION: Review your interview preparation tasks
   ▸ Check the 3-day and 1-day reminder tasks


💡 TIPS FOR THIS WEEK:
========================================

✓ Focus on high ND-friendliness scores (≥ 8)
✓ Use "Generate Resume Package" button to save time
✓ Review interview notes 3 days before scheduled interviews
✓ Track patterns in red flags across companies
✓ Celebrate small wins - every step forward counts!


🌟 REMEMBER:
========================================

You're not just looking for any job - you're finding the RIGHT job
that values your neurodivergent strengths, supports your needs,
and aligns with your goals. Quality over quantity!


---
Sent by your AI-powered ND-Friendly Job Search Assistant
```

5. Click **Done**

---

### Step 7: Save and Activate (1 min)
1. Click **Save** button (top right)
2. **Flow Label**: Weekly Job Search Summary
3. **Flow API Name**: Weekly_Job_Search_Summary
4. Click **Save**
5. Click **Activate**
6. **Done!**

---

## Testing Your Flow

### Test Immediately (Don't Wait for Monday!)
1. In the flow, click the **Run** button (top right)
2. Check your email in 1-2 minutes
3. You should receive the weekly summary

### Adjust Frequency
Want it more than weekly? Easy!
1. Open the flow
2. Click **Start** element
3. Change frequency:
   - **Daily**: Every day at 8 AM
   - **Twice Weekly**: Monday and Thursday
   - **Bi-Weekly**: Every other Monday
4. Save and reactivate

---

## Troubleshooting

### "I don't see the email"
- Check your spam folder
- Verify `{!$User.Email}` has your correct email
- Check Salesforce email deliverability settings

### "The formula isn't working"
- Make sure Data Type is set to **Date** (not DateTime)
- Formula expressions are case-sensitive

### "I want to change the email content"
- Open the flow
- Click the **Send Email** action
- Edit the body
- Save and reactivate

---

## Advanced: Customize for Your Needs

### Add More Data
Want to include more stats? Add more Get Records elements:
- Jobs by company
- Average ND Friendliness Score this week
- Total interviews completed
- Applications submitted

### Change Recipients
Send to multiple people:
- In Send Email action
- Recipient Email Addresses field
- Enter: `your@email.com;partner@email.com`

### Add Conditional Logic
Only send if there's activity:
- Add Decision element after Get Records
- Check if record count > 0
- Only send email if true

---

## What Happens After Setup?

✅ **Monday at 8 AM**: You'll automatically receive your weekly summary
✅ **No manual work**: Completely automated
✅ **Always up-to-date**: Pulls live data from your Job_Posting__c records
✅ **Actionable insights**: Clear action items for the week ahead

---

## Questions?

This flow is:
- ✅ Fully automated
- ✅ Easy to modify
- ✅ Can run daily, weekly, or any frequency
- ✅ Helps you stay on top of your job search

**Time to complete**: 10-15 minutes of your time for weekly automation forever!

Let me know when you've set it up and tested it!

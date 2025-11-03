# Wellness System UI Setup Guide
**Complete Step-by-Step Instructions for Manual Salesforce Configuration**

---

## Overview

This guide walks you through 4 manual setup tasks to complete your Wellness System:

1. Create Daily Energy Check-In Flow
2. Add Flow to Home Page
3. Recreate Morning Routine Completion Streak Report
4. Fix Wellness Tracker Dashboard

**Estimated Time:** 45-60 minutes
**Salesforce Org:** abbyluggery@creative-shark-cub7oy.com

---

## ✅ Prerequisites

Before starting, ensure:
- [ ] You're logged into your Salesforce org
- [ ] DailyRoutineInvocable Apex class is deployed
- [ ] Daily_Routine__c custom object exists
- [ ] Energy_Trend_Past_30_Days and Mood_Pattern_by_Day_of_Week reports are deployed

---

# Task 1: Create Daily Energy Check-In Flow

## Step 1.1: Start New Flow

1. Navigate to **Setup** (gear icon → Setup)
2. In Quick Find, search for **Flows**
3. Click **Flows**
4. Click **New Flow** button
5. Select **Screen Flow**
6. Click **Create**

---

## Step 1.2: Create Flow Variables

Before building screens, create all variables to store data:

### Create Variables (Click "+ New Resource" → Variable for each):

| Variable Name | Data Type | Available for Input | Available for Output | Default Value |
|---------------|-----------|---------------------|----------------------|---------------|
| energyLevelInput | Number | ✅ Yes | ❌ No | 5 |
| moodInput | Text | ✅ Yes | ❌ No | Okay |
| morningRoutineInput | Boolean | ✅ Yes | ❌ No | {!$GlobalConstant.False} |
| dailyRoutineIdOutput | Text | ❌ No | ✅ Yes | (blank) |
| successOutput | Boolean | ❌ No | ✅ Yes | (blank) |
| messageOutput | Text | ❌ No | ✅ Yes | (blank) |
| energyLevelOutput | Number | ❌ No | ✅ Yes | (blank) |
| energyCategoryOutput | Text | ❌ No | ✅ Yes | (blank) |
| studyHoursOutput | Number | ❌ No | ✅ Yes | (blank) |
| jobSearchHoursOutput | Number | ❌ No | ✅ Yes | (blank) |
| applicationGoalOutput | Text | ❌ No | ✅ Yes | (blank) |
| todaysScheduleOutput | Text | ❌ No | ✅ Yes | (blank) |
| motivationalMessageOutput | Text | ❌ No | ✅ Yes | (blank) |

**To create each variable:**
1. Click **+ New Resource**
2. Select **Variable**
3. Enter the name (e.g., `energyLevelInput`)
4. Select Data Type
5. Check boxes for Input/Output as shown above
6. Enter Default Value if specified
7. Click **Done**

---

## Step 1.3: Build Screen 1 - Energy Input

### Add Screen Element:

1. From the Toolbox, drag **Screen** onto the canvas
2. Configure Screen Properties:
   - **Label:** How are you feeling today?
   - **API Name:** Energy_Input_Screen

### Add Components to Screen 1:

#### Component 1: Header Text
- Drag **Display Text** to screen
- **API Name:** Header
- Click **Insert a resource** → **$GlobalConstant** → **EmptyString**
- Delete the placeholder and type:
  ```
  Good morning! Let's plan your day based on your energy 🌟
  ```
- Formatting:
  - Font Size: **Large**
  - Alignment: **Center**

#### Component 2: Instructions
- Drag **Display Text** to screen
- **API Name:** Instructions
- Text:
  ```
  Take a moment to check in with yourself. How's your energy this morning?
  ```

#### Component 3: Energy Level Slider
- Drag **Slider** to screen
- **API Name:** energyLevelInput
- **Label:** Energy Level (1-10)
- **Required:** ✅ Yes
- **Minimum Value:** 1
- **Maximum Value:** 10
- **Scale:** 0
- **Help Text:**
  ```
  1 = Flare-up (rest day needed)
  2-4 = Low (minimum viable tasks)
  5-7 = Medium (steady progress)
  8-10 = High (full productivity)
  ```
- **Store value in:** {!energyLevelInput}

#### Component 4: Mood Radio Buttons
- Drag **Radio Buttons** to screen
- **API Name:** moodInput
- **Label:** How are you feeling?
- **Required:** ✅ Yes
- Click **+ New Choice** for each option:
  1. **Choice Label:** Great, **Choice Value:** Great
  2. **Choice Label:** Good, **Choice Value:** Good
  3. **Choice Label:** Okay, **Choice Value:** Okay (set as default)
  4. **Choice Label:** Low, **Choice Value:** Low
  5. **Choice Label:** Very Low, **Choice Value:** Very Low
- **Store value in:** {!moodInput}

#### Component 5: Morning Routine Toggle
- Drag **Toggle** to screen
- **API Name:** morningRoutineInput
- **Label:** Morning routine completed?
- **Help Text:** Did you complete your wellness routine? (meditation, stretching, breakfast, etc.)
- **Store value in:** {!morningRoutineInput}

### Configure Screen Navigation:
- **Show Previous Button:** ❌ No
- **Pause Label:** (leave blank)
- **Next or Finish Label:** Next

---

## Step 1.4: Add Action - Call Invocable Apex

1. From Toolbox, drag **Action** onto canvas (after Screen 1)
2. **Action Type:** Apex Action
3. **Search for:** DailyRoutineInvocable
4. Select **DailyRoutineInvocable.getEnergyAdaptiveSchedule**
5. **Label:** Get Energy Adaptive Schedule
6. **API Name:** Get_Energy_Adaptive_Schedule

### Map Input Variables:
- **energyLevel:** {!energyLevelInput}
- **mood:** {!moodInput}
- **morningRoutineComplete:** {!morningRoutineInput}

### Store Output Values:
Click "Manually assign variables" and map each output:

| Output Variable | Store In |
|-----------------|----------|
| dailyRoutineId | {!dailyRoutineIdOutput} |
| success | {!successOutput} |
| message | {!messageOutput} |
| energyLevel | {!energyLevelOutput} |
| energyCategory | {!energyCategoryOutput} |
| studyHours | {!studyHoursOutput} |
| jobSearchHours | {!jobSearchHoursOutput} |
| applicationGoal | {!applicationGoalOutput} |
| todaysSchedule | {!todaysScheduleOutput} |
| motivationalMessage | {!motivationalMessageOutput} |

---

## Step 1.5: Add Decision Element

1. Drag **Decision** onto canvas (after Action)
2. **Label:** Check Success
3. **API Name:** Check_Success

### Create Outcome 1: Success
- **Outcome Label:** Success
- **Outcome API Name:** Success
- **Condition Requirements to Execute Outcome:** All Conditions Are Met (AND)
- Add Condition:
  - **Resource:** {!successOutput}
  - **Operator:** Equals
  - **Value:** {!$GlobalConstant.True}

### Create Outcome 2: Error
- **Outcome Label:** Error
- **Outcome API Name:** Error
- **Condition:** Use Default Outcome for this Decision

---

## Step 1.6: Build Screen 2 - Success Screen

1. Drag **Screen** onto canvas
2. Connect from Decision "Success" outcome to this screen
3. **Label:** Your Plan for Today
4. **API Name:** Success_Screen

### Add Components to Screen 2:

#### Component 1: Energy Badge
- Drag **Display Text** to screen
- **API Name:** Energy_Badge
- Click "View as HTML"
- Paste:
  ```html
  <p style="text-align: center; font-size: 24px; padding: 20px;
     background-color: #e6f7ff; border-radius: 10px; margin-bottom: 20px;">
     ⚡ {!energyCategoryOutput} Energy Day
  </p>
  ```

#### Component 2: Motivational Message
- Drag **Display Text** to screen
- **API Name:** Motivational_Message
- Text: `{!motivationalMessageOutput}`

#### Component 3: Daily Goals Header
- Drag **Display Text** to screen
- **API Name:** Goals_Header
- Text: `📊 Your Goals for Today`
- Font Size: **Large**

#### Component 4: Goals Summary
- Drag **Display Text** to screen
- **API Name:** Goals_Summary
- Click "View as HTML"
- Paste:
  ```html
  <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; font-family: monospace;">
  📚 Salesforce Study: {!studyHoursOutput} hours<br/>
  💼 Job Search: {!jobSearchHoursOutput} hours<br/>
  📝 Applications: {!applicationGoalOutput}
  </div>
  ```

#### Component 5: Schedule Header
- Drag **Display Text** to screen
- **API Name:** Schedule_Header
- Text: `📅 Your Schedule`
- Font Size: **Large**

#### Component 6: Schedule
- Drag **Display Text** to screen
- **API Name:** Schedule
- Click "View as HTML"
- Paste:
  ```html
  <div style="background-color: white; padding: 15px; border: 1px solid #ccc; border-radius: 5px; white-space: pre-line; font-family: monospace;">
  {!todaysScheduleOutput}
  </div>
  ```

#### Component 7: Record Link
- Drag **Display Text** to screen
- **API Name:** Record_Link
- Click "View as HTML"
- Paste:
  ```html
  <p style="color: green; font-weight: bold;">✅ Your check-in has been saved!</p>
  <p><a href="/{!dailyRoutineIdOutput}" target="_blank">View your Daily Routine record</a></p>
  ```

### Configure Screen Navigation:
- **Show Previous Button:** ❌ No
- **Pause Label:** (leave blank)
- **Next or Finish Label:** Finish

---

## Step 1.7: Build Screen 3 - Error Screen

1. Drag **Screen** onto canvas
2. Connect from Decision "Error" outcome to this screen
3. **Label:** Oops! Something went wrong
4. **API Name:** Error_Screen

### Add Components to Screen 3:

#### Component 1: Error Icon
- Drag **Display Text** to screen
- **API Name:** Error_Icon
- Text: `⚠️`
- Font Size: **XX-Large**
- Alignment: **Center**

#### Component 2: Error Message
- Drag **Display Text** to screen
- **API Name:** Error_Message
- Text: `{!messageOutput}`

#### Component 3: Troubleshooting
- Drag **Display Text** to screen
- **API Name:** Troubleshooting
- Text:
  ```
  Try these steps:
  1. Check your internet connection
  2. Refresh the page and try again
  3. Contact your administrator if the problem persists
  ```

### Configure Screen Navigation:
- **Show Previous Button:** ✅ Yes
- **Pause Label:** (leave blank)
- **Next or Finish Label:** Finish

---

## Step 1.8: Save and Activate Flow

1. Click **Save**
2. **Flow Label:** Daily Energy Check-In
3. **Flow API Name:** Daily_Energy_Check_In (auto-filled)
4. **Description:** Daily wellness check-in for energy-adaptive scheduling
5. Click **Save**
6. Click **Activate**
7. Confirm activation

**✅ Flow Created!** API Name: `Daily_Energy_Check_In`

---

# Task 2: Add Flow to Home Page

## Option A: Add as Quick Action (Recommended)

### Step 2.1: Create Global Action

1. Navigate to **Setup** → **Global Actions**
2. Click **New Action**
3. **Action Type:** Flow
4. **Flow:** Daily_Energy_Check_In
5. **Label:** Daily Check-In
6. **Name:** Daily_Check_In
7. **Icon:** Choose an appropriate icon (e.g., Emoji or Custom)
8. Click **Save**

### Step 2.2: Add to Home Page Layout

1. Navigate to **Setup** → **Home Page Layouts**
2. Click **Edit** next to your default layout
3. In the "Quick Actions in the Salesforce Classic Publisher" section:
   - Click **override the predefined actions**
4. Drag **Daily Check-In** from Available Actions to Selected Actions
5. Position it at the top
6. Click **Save**

### Step 2.3: Add to Lightning Home Page

1. Navigate to **Setup** → **Lightning App Builder**
2. Click **New** → **Home Page**
3. **Label:** Wellness Home Page
4. Select **Clone Salesforce Default Page**
5. Click **Next**, then **Finish**
6. From the Components panel (left side):
   - Drag **Flow** component to the top of the page
7. In the component properties (right side):
   - **Flow:** Daily_Energy_Check_In
   - **Flow Layout:** One Column
8. Click **Save**
9. Click **Activation**
10. Select **Assign as Org Default**
11. Click **Save**

---

## Option B: Add to Custom App Home Page

If you have a custom app:

1. Navigate to **Setup** → **Lightning App Builder**
2. Find your app's home page and click **Edit**
3. Drag **Flow** component to desired location
4. Configure:
   - **Flow:** Daily_Energy_Check_In
   - **Flow Layout:** One Column
5. Click **Save**

---

# Task 3: Recreate Morning Routine Completion Streak Report

**Why manual:** The report had field reference errors during deployment. Recreating in UI ensures all fields are correctly mapped.

## Step 3.1: Create New Report

1. Navigate to **Reports** tab
2. Click **New Report**
3. **Report Type:** Daily Routines (or search for "Daily_Routine__c")
4. Click **Continue**

---

## Step 3.2: Configure Report Filters

### Date Filter:
1. In the Filters panel, find **Date: Date**
2. Click to edit
3. **Range:** Last 30 Days
4. Click **Apply**

### Morning Routine Filter:
1. Click **Add Filter**
2. Select **Morning Routine Complete**
3. **Operator:** equals
4. **Value:** True (checked)
5. Click **Apply**

---

## Step 3.3: Add Columns

From the Fields panel (left), drag these fields to the Columns area:

1. **Date**
2. **Morning Routine Complete**
3. **Energy Level (Morning)**
4. **Mood**

---

## Step 3.4: Add Grouping

1. In the Outline panel, click **Add Group**
2. **Group Rows By:** Date
3. **Date Granularity:** Week
4. **Sort Order:** Descending (newest first)
5. Click **OK**

---

## Step 3.5: Add Formula (Total Days)

1. Click **Add Formula**
2. **Column Name:** Total Days
3. **Formula:**
   ```
   RowCount
   ```
4. **Format:** Number
5. **Decimal Places:** 0
6. Click **OK**

---

## Step 3.6: Configure Report Format

1. Click the **Format** dropdown at top
2. Select **Summary**
3. In the report settings:
   - **Show Details:** ✅ Yes
   - **Show Subtotals:** ✅ Yes
   - **Show Grand Total:** ✅ Yes

---

## Step 3.7: Save Report

1. Click **Save & Run**
2. **Report Name:** Morning Routine Completion Streak
3. **Report Unique Name:** Morning_Routine_Completion_Streak (auto-filled)
4. **Report Description:** Track morning routine completion to maintain streak and identify patterns
5. **Report Folder:** Wellness_Reports (or create folder if it doesn't exist)
6. Click **Save**

**✅ Report Created!**

---

# Task 4: Fix Wellness Tracker Dashboard

**Why manual:** Dashboard had XML compatibility issues with chart types. Recreating charts in UI ensures proper formatting.

## Step 4.1: Open Dashboard

1. Navigate to **Dashboards** tab
2. Find **Wellness Tracker** dashboard
3. If it doesn't exist:
   - Click **New Dashboard**
   - Name: **Wellness Tracker**
   - Folder: Wellness_Dashboards
   - Click **Create**

---

## Step 4.2: Create Dashboard Component 1 - Energy Trend

### Add Component:
1. Click **+ Component**
2. **Data Source:** Report
3. **Report:** Energy_Trend_Past_30_Days (search in Wellness_Reports folder)
4. Click **Select**

### Configure Chart:
1. **Display As:** Line Chart
2. **Title:** 30-Day Energy Trend
3. **Subtitle:** Morning Energy Level (1-10)
4. **X-Axis:** Date
5. **Y-Axis:** AVG Energy Level Morning (or similar metric)
6. **Show Values:** ❌ No
7. **Legend Position:** Bottom
8. Click **Add**

### Position Component:
- Drag to **Left Column**, **Top Position**

---

## Step 4.3: Create Dashboard Component 2 - Mood Pattern

### Add Component:
1. Click **+ Component**
2. **Data Source:** Report
3. **Report:** Mood_Pattern_by_Day_of_Week (search in Wellness_Reports folder)
4. Click **Select**

### Configure Chart:
1. **Display As:** Stacked Column Chart
2. **Title:** Mood Pattern by Day
3. **Subtitle:** Mood Distribution
4. **X-Axis:** Day of Week (or Date)
5. **Y-Axis:** Record Count
6. **Grouping:** Mood
7. **Show Values:** ✅ Yes
8. **Legend Position:** Bottom
9. Click **Add**

### Position Component:
- Drag to **Left Column**, **Below Energy Trend**

---

## Step 4.4: (Optional) Add Component 3 - Morning Routine Streak

If you want to add the newly created Morning Routine report:

### Add Component:
1. Click **+ Component**
2. **Data Source:** Report
3. **Report:** Morning_Routine_Completion_Streak
4. Click **Select**

### Configure Chart:
1. **Display As:** Gauge
2. **Title:** Morning Routine Streak
3. **Subtitle:** Days Completed (Last 30 Days)
4. **Value:** Total Days formula
5. **Breakpoints:**
   - Low (0-9): Red
   - Medium (10-19): Yellow
   - High (20-30): Green
6. Click **Add**

### Position Component:
- Drag to **Right Column**, **Top Position**

---

## Step 4.5: Configure Dashboard Settings

1. Click **Settings** (gear icon)
2. **Dashboard Properties:**
   - **Title:** Wellness Tracker
   - **Description:** Wellness tracking dashboard showing energy patterns, mood trends, and habit completion for neurodivergent executive function support
3. **View Settings:**
   - **Running User:** Me (for personal dashboard) OR Specific User
4. Click **Save**

---

## Step 4.6: Save Dashboard

1. Click **Save**
2. **Dashboard Name:** Wellness Tracker (if creating new)
3. **Dashboard Folder:** Wellness_Dashboards
4. Click **Save**

**✅ Dashboard Fixed and Ready!**

---

# Post-Setup Testing

## Test Checklist

Run through these tests to ensure everything works:

### Flow Testing:
- [ ] Navigate to Home page
- [ ] Click "Daily Check-In" action
- [ ] **Test 1:** Energy Level 1 (Flare-up)
  - Set slider to 1
  - Select any mood
  - Click Next
  - Verify schedule shows rest day
- [ ] **Test 2:** Energy Level 6 (Medium)
  - Set slider to 6
  - Select "Good" mood
  - Toggle morning routine ON
  - Click Next
  - Verify schedule shows 3 hrs study, 1.5 hrs job search
- [ ] **Test 3:** Record Creation
  - After completing flow, click "View your Daily Routine record"
  - Verify all fields are populated correctly
- [ ] **Test 4:** Same-Day Update
  - Run flow again on same day
  - Verify it updates existing record (not creates new one)

### Report Testing:
- [ ] Navigate to **Reports** tab
- [ ] Open **Morning Routine Completion Streak** report
- [ ] Verify report runs without errors
- [ ] Check that data displays if you have Daily_Routine__c records
- [ ] Filter by different date ranges

### Dashboard Testing:
- [ ] Navigate to **Dashboards** tab
- [ ] Open **Wellness Tracker** dashboard
- [ ] Verify all charts load
- [ ] Check that charts update when reports are refreshed
- [ ] Test drill-down on charts (click data points)

---

# Troubleshooting

## Flow Issues

### "Flow not found" error:
- **Solution:** Ensure flow is activated (Setup → Flows → Daily_Energy_Check_In → Activate)

### "Apex action not available":
- **Solution:** Verify DailyRoutineInvocable class is deployed
- Check that the Invocable Method exists: `getEnergyAdaptiveSchedule`

### Variables not showing in dropdown:
- **Solution:** Ensure variables are created with correct "Available for Input/Output" settings
- Save the flow and reopen if variables don't appear

### Screen doesn't display correctly:
- **Solution:** Check HTML syntax in Display Text components
- Ensure resource references use correct API names (e.g., `{!energyCategoryOutput}`)

## Report Issues

### "Report type not found":
- **Solution:** Verify Daily_Routine__c custom object exists
- Check that you have Read permission on Daily_Routine__c

### No data showing:
- **Solution:** Create test Daily_Routine__c records via the flow
- Check date filter isn't excluding all records

### Formula errors:
- **Solution:** Use simple formulas like `RowCount` or `SUM(field_name)`

## Dashboard Issues

### Component won't add:
- **Solution:** Verify the underlying report exists and runs without errors
- Refresh the report before adding to dashboard

### Chart displays incorrectly:
- **Solution:** Check report groupings and aggregations
- Ensure chart type matches data structure (e.g., Line charts need date-based X-axis)

### "Insufficient Privileges":
- **Solution:** Set Dashboard "Running User" to "Me" in dashboard settings
- Or ensure you have access to all reports used in dashboard

---

# Next Steps

After completing all 4 tasks:

1. **✅ Run End-to-End Test:**
   - Complete Daily Check-In flow
   - Wait a few minutes for reports to refresh
   - View Wellness Tracker dashboard
   - Verify your check-in appears in charts

2. **📱 Add to Mobile:**
   - Open Salesforce Mobile App
   - Navigate to Today view
   - Find Daily Check-In action
   - Test flow works on mobile

3. **📊 Create Dashboard Subscription:**
   - Open Wellness Tracker dashboard
   - Click **Subscribe**
   - Schedule: Daily at 9 AM
   - This sends dashboard snapshot to your email each morning

4. **🔔 Set Up Reminders (Optional):**
   - Create a custom reminder to complete Daily Check-In each morning
   - Use Process Builder or Flow to send notification if check-in not completed by 10 AM

5. **📈 Review After 7 Days:**
   - After one week of data, review your energy patterns
   - Identify optimal days for intensive work
   - Adjust your routine based on insights

---

# Support & Documentation

## Additional Resources

- **Salesforce Flow Documentation:** https://help.salesforce.com/s/articleView?id=sf.flow.htm
- **Report Builder Guide:** https://help.salesforce.com/s/articleView?id=sf.reports_builder.htm
- **Dashboard Builder Guide:** https://help.salesforce.com/s/articleView?id=sf.dashboards_create.htm

## Getting Help

If you encounter issues:

1. **Check Debug Logs:**
   - Setup → Debug Logs
   - Add your user as a Traced Entity
   - Run the flow again
   - Review logs for errors

2. **Test Apex Class:**
   - Developer Console → Open Execute Anonymous
   - Run test code for DailyRoutineInvocable
   - Verify outputs are correct

3. **Community Resources:**
   - Salesforce Stack Exchange: https://salesforce.stackexchange.com
   - Trailblazer Community: https://trailhead.salesforce.com/community

---

**Setup Guide Created:** November 3, 2025
**Salesforce Org:** abbyluggery@creative-shark-cub7oy.com
**Estimated Completion Time:** 45-60 minutes
**Completion Status:** ⬜ To Do → 🔄 In Progress → ✅ Complete

---

Good luck with your setup! You're building an amazing neurodivergent-friendly wellness tracking system! 🌟

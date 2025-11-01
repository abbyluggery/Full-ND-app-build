# Daily Energy Check-In Screen Flow Design

## Overview
This Screen Flow provides a user-friendly interface for logging daily energy levels and receiving personalized, adaptive schedule recommendations.

## Flow Metadata
- **Flow Label:** Daily Energy Check-In
- **Flow API Name:** Daily_Energy_Check_In
- **Flow Type:** Screen Flow
- **Run Mode:** System Context with Sharing
- **Start Button Location:**
  - Home page Quick Action
  - Daily Routine object list view button
  - Daily Routine record page

---

## Flow Structure

### Screen 1: Welcome & Energy Input

**Screen Label:** How are you feeling today?

**Components:**

1. **Display Text - Header**
   - **Text:** `Good morning! Let's plan your day based on your energy 🌟`
   - **Font Size:** Large
   - **Alignment:** Center

2. **Display Text - Instructions**
   - **Text:** `Take a moment to check in with yourself. How's your energy this morning?`
   - **Font Style:** Regular

3. **Slider - Energy Level**
   - **Field Label:** Energy Level (1-10)
   - **API Name:** energyLevelInput
   - **Min Value:** 1
   - **Max Value:** 10
   - **Default Value:** 5
   - **Required:** Yes
   - **Help Text:**
     ```
     1 = Flare-up (rest day needed)
     2-4 = Low (minimum viable tasks)
     5-7 = Medium (steady progress)
     8-10 = High (full productivity)
     ```

4. **Radio Buttons - Mood**
   - **Field Label:** How are you feeling?
   - **API Name:** moodInput
   - **Required:** Yes
   - **Choices:**
     - Great
     - Good
     - Okay
     - Low
     - Very Low
   - **Default:** Okay

5. **Toggle - Morning Routine**
   - **Field Label:** Morning routine completed?
   - **API Name:** morningRoutineInput
   - **Default Value:** False
   - **Help Text:** Did you complete your wellness routine? (meditation, stretching, breakfast, etc.)

---

### Action: Call Invocable Method

**Action Type:** Invocable Action

**Action:** Get Energy-Adaptive Schedule (DailyRoutineInvocable)

**Input Variables:**
- **energyLevel:** `{!energyLevelInput}`
- **mood:** `{!moodInput}`
- **morningRoutineComplete:** `{!morningRoutineInput}`

**Output Variables:** Store ALL outputs
- `{!dailyRoutineIdOutput}` → Daily Routine ID
- `{!successOutput}` → Success
- `{!messageOutput}` → Message
- `{!energyLevelOutput}` → Energy Level
- `{!energyCategoryOutput}` → Energy Category
- `{!studyHoursOutput}` → Study Hours Recommended
- `{!jobSearchHoursOutput}` → Job Search Hours Recommended
- `{!applicationGoalOutput}` → Application Goal
- `{!todaysScheduleOutput}` → Today's Schedule
- `{!motivationalMessageOutput}` → Motivational Message

---

### Decision: Check Success

**Outcome 1: Success**
- **Condition:** `{!successOutput}` EQUALS `true`
- **Next:** Screen 2 (Display Schedule)

**Outcome 2: Error**
- **Condition:** Default
- **Next:** Screen 3 (Error Screen)

---

### Screen 2: Your Personalized Schedule

**Screen Label:** Your Plan for Today

**Components:**

1. **Display Text - Energy Badge**
   - **Text:**
     ```
     <p style="text-align: center; font-size: 24px; padding: 20px;
        background-color: #e6f7ff; border-radius: 10px; margin-bottom: 20px;">
        ⚡ {!energyCategoryOutput} Energy Day
     </p>
     ```
   - **Support HTML:** Yes

2. **Display Text - Motivational Message**
   - **Text:** `{!motivationalMessageOutput}`
   - **Font Style:** Italic
   - **Background Color:** Light Yellow

3. **Display Text - Daily Goals Header**
   - **Text:** `📊 Your Goals for Today`
   - **Font Size:** Large
   - **Font Weight:** Bold

4. **Display Text - Goals Summary**
   - **Text:**
     ```
     📚 Salesforce Study: {!studyHoursOutput} hours
     💼 Job Search: {!jobSearchHoursOutput} hours
     📝 Applications: {!applicationGoalOutput}
     ```
   - **Font Family:** Monospace
   - **Background Color:** Light Gray

5. **Display Text - Schedule Header**
   - **Text:** `📅 Your Schedule`
   - **Font Size:** Large
   - **Font Weight:** Bold

6. **Display Text - Schedule**
   - **Text:** `{!todaysScheduleOutput}`
   - **Font Family:** Monospace
   - **Background Color:** White
   - **Border:** 1px solid gray

7. **Display Text - Record Link**
   - **Text:**
     ```
     ✅ Your check-in has been saved!

     <a href="/{!dailyRoutineIdOutput}">View your Daily Routine record</a>
     ```
   - **Support HTML:** Yes

---

### Screen 3: Error Screen (Alternative Path)

**Screen Label:** Oops! Something went wrong

**Components:**

1. **Display Text - Error Icon**
   - **Text:** `⚠️`
   - **Font Size:** XX-Large
   - **Alignment:** Center

2. **Display Text - Error Message**
   - **Text:** `{!messageOutput}`
   - **Font Color:** Red

3. **Display Text - Troubleshooting**
   - **Text:**
     ```
     Try these steps:
     1. Check your internet connection
     2. Refresh the page and try again
     3. Contact your administrator if the problem persists
     ```

---

## Flow Variables

Create these variables to store outputs:

| Variable Name | Data Type | Input/Output | Description |
|---------------|-----------|--------------|-------------|
| energyLevelInput | Number | Input | User's energy level (1-10) |
| moodInput | Text | Input | User's mood selection |
| morningRoutineInput | Boolean | Input | Whether morning routine completed |
| dailyRoutineIdOutput | Text | Output | ID of created/updated record |
| successOutput | Boolean | Output | Whether operation succeeded |
| messageOutput | Text | Output | Success/error message |
| energyLevelOutput | Number | Output | Energy level (echoed back) |
| energyCategoryOutput | Text | Output | High/Medium/Low/Flare-up |
| studyHoursOutput | Number | Output | Recommended study hours |
| jobSearchHoursOutput | Number | Output | Recommended job search hours |
| applicationGoalOutput | Text | Output | Application target |
| todaysScheduleOutput | Text | Output | Full schedule as formatted text |
| motivationalMessageOutput | Text | Output | Personalized message |

---

## User Experience Flow

```
User clicks "Daily Check-In" button
    ↓
Screen 1: Energy input (slider, mood, checkbox)
    ↓
User clicks "Next"
    ↓
System calls DailyRoutineInvocable
    ↓
System creates/updates Daily_Routine__c record
    ↓
System calculates adaptive schedule
    ↓
Screen 2: Display personalized schedule & goals
    ↓
User clicks "Finish"
    ↓
Flow closes, user returns to home/record
```

---

## Visual Design Mockup

```
┌─────────────────────────────────────────────────────┐
│  Good morning! Let's plan your day based on         │
│  your energy 🌟                                      │
│                                                      │
│  Take a moment to check in with yourself.           │
│  How's your energy this morning?                    │
│                                                      │
│  Energy Level (1-10)                                │
│  [====|=============================] 5             │
│  1 = Flare-up, 2-4 = Low, 5-7 = Medium, 8-10 = High│
│                                                      │
│  How are you feeling?                               │
│  ○ Great  ○ Good  ● Okay  ○ Low  ○ Very Low         │
│                                                      │
│  Morning routine completed?                         │
│  [Toggle: OFF]                                      │
│                                                      │
│              [Previous]  [Next]                     │
└─────────────────────────────────────────────────────┘

                      ⬇️

┌─────────────────────────────────────────────────────┐
│          ⚡ Medium Energy Day                        │
│                                                      │
│  Good energy today! This is your sweet spot for     │
│  consistent progress...                             │
│                                                      │
│  📊 Your Goals for Today                            │
│  ┌─────────────────────────────────────────────┐   │
│  │ 📚 Salesforce Study: 3 hours                │   │
│  │ 💼 Job Search: 1.5 hours                    │   │
│  │ 📝 Applications: 2-3 applications           │   │
│  └─────────────────────────────────────────────┘   │
│                                                      │
│  📅 Your Schedule                                   │
│  ┌─────────────────────────────────────────────┐   │
│  │ 9:00 AM - Complete morning wellness routine │   │
│  │ 10:00 AM - Salesforce study (3 hours)      │   │
│  │ 1:00 PM - Lunch + movement break           │   │
│  │ 2:00 PM - Job search (1.5 hrs, 2-3 apps)   │   │
│  │ 4:00 PM - Wrap-up & plan tomorrow          │   │
│  └─────────────────────────────────────────────┘   │
│                                                      │
│  ✅ Your check-in has been saved!                   │
│  View your Daily Routine record                     │
│                                                      │
│                   [Finish]                          │
└─────────────────────────────────────────────────────┘
```

---

## Deployment Instructions for Agentforce

### Step 1: Create the Flow in Salesforce

1. **Navigate to:** Setup → Flows → New Flow
2. **Select:** Screen Flow
3. **Build the flow** following the structure above

### Step 2: Create Flow Elements

**Elements to create (in order):**
1. Screen: "How are you feeling today?"
2. Action: "Call DailyRoutineInvocable"
3. Decision: "Check Success"
4. Screen: "Your Personalized Schedule" (success path)
5. Screen: "Error Screen" (failure path)

### Step 3: Activate the Flow

1. Click **Save**
2. Enter Flow Label: `Daily Energy Check-In`
3. Click **Activate**

### Step 4: Add Flow to Home Page

**Create Quick Action:**
1. **Setup → Home Page Layouts**
2. Click **Edit** on the default layout
3. Add **Flow** component
4. Select: `Daily_Energy_Check_In`
5. Position: Top of page
6. **Save**

**Alternative: Lightning App Builder**
1. **Setup → Lightning App Builder**
2. Edit your app's home page
3. Drag **Flow** component to desired location
4. Configure: Select `Daily_Energy_Check_In`
5. **Save & Activate**

### Step 5: Create Quick Action Button (Optional)

**For Daily_Routine__c Object:**
1. **Setup → Object Manager → Daily Routine**
2. **Buttons, Links, and Actions → New Action**
3. **Action Type:** Flow
4. **Flow:** Daily_Energy_Check_In
5. **Label:** Check-In Today
6. **Save**
7. Add to page layout

---

## Testing Checklist

After deployment, test these scenarios:

- [ ] **Flow loads** without errors
- [ ] **Slider moves** smoothly from 1-10
- [ ] **Mood radio buttons** all work
- [ ] **Toggle switches** properly
- [ ] **Clicking Next** creates Daily_Routine__c record
- [ ] **Schedule displays** correctly for each energy level
- [ ] **Energy categories** show correctly:
  - Level 1 → "Flare-up"
  - Level 3 → "Low"
  - Level 6 → "Medium"
  - Level 9 → "High"
- [ ] **Record link** navigates to correct Daily_Routine__c record
- [ ] **Running twice** on same day UPDATES existing record
- [ ] **Error handling** shows error screen on failure

---

## Enhancement Ideas (Future)

1. **Data Visualization:**
   - Embed chart showing last 7 days' energy levels
   - Show streak counter for morning routine completion

2. **Smart Defaults:**
   - Pre-populate energy level based on yesterday's afternoon level
   - Suggest mood based on recent patterns

3. **Additional Inputs:**
   - Sleep quality (1-10)
   - Stress level (1-10)
   - Pain level (1-10)
   - Medication taken (checkbox)

4. **Schedule Customization:**
   - Allow user to adjust recommended hours
   - Save preferences for each energy level

5. **Integration:**
   - Send schedule to calendar
   - Set reminders for each scheduled block
   - Integrate with task management

---

## Support & Documentation

**For Users:**
- See: "How to Use Daily Check-In" guide
- Video tutorial: [Link to Loom/YouTube]

**For Admins:**
- Flow API Name: `Daily_Energy_Check_In`
- Called Apex Class: `DailyRoutineInvocable`
- Required Permissions: Read/Create on Daily_Routine__c

---

**Created by:** Claude AI Assistant
**Date:** 2025-10-30
**Version:** 1.0

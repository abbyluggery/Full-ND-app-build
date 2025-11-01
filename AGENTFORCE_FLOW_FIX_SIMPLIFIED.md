# Simplified Flow Fix Guide for Agentforce

## 🚨 IMPORTANT: Don't Edit XML Directly!

**DO NOT try to edit the Daily_Wellness_Log.flow-meta.xml file manually.**

Flows should be edited using the **Salesforce Flow Builder visual interface**. Editing XML directly is error-prone and not recommended.

---

## ✅ Correct Approach: Use Flow Builder

### Step 1: Open Flow in Salesforce UI

```
1. Open Salesforce in browser
2. Click Setup (gear icon)
3. In Quick Find box, type: Flows
4. Click: Flows
5. Find: "Daily Wellness Log"
6. Click on the flow name to open it in Flow Builder
```

**You should see a visual canvas with boxes and arrows, NOT XML code.**

---

## 🎯 The Core Issues (Simple Explanation)

Your flow has **one major problem**:

### Problem: Duplicate Record Creation

**Current flow does:**
1. User enters energy level → Screen 1
2. Flow creates Daily_Routine__c record ❌ (WRONG - causes duplicate)
3. Flow calls DailyRoutineInvocable.getAdaptiveSchedule()
4. That Apex method ALSO creates Daily_Routine__c record ❌ (DUPLICATE!)
5. Result: 2 records created instead of 1

**What it should do:**
1. User enters energy level → Screen 1
2. Flow calls DailyRoutineInvocable.getAdaptiveSchedule() ✅
3. That Apex method creates the record AND calculates schedule ✅
4. Flow displays the results → Screen 2 ✅
5. Result: 1 record created, schedule shown ✅

---

## 🔧 The Fix (Visual Steps in Flow Builder)

### Fix 1: Remove the Duplicate Record Creation

```
1. In Flow Builder, you'll see elements connected like this:

   [Log_Energy_Level Screen]
        ↓
   [Create_Daily_Routine] ← DELETE THIS ONE
        ↓
   [Set_Request_Variables]
        ↓
   [Call_Apex_Method]
        ↓
   [View_Schedule Screen]

2. Click on the "Create_Daily_Routine" element
3. Click "Delete" button (or right-click → Delete)
4. Reconnect the elements:
   - Drag from Log_Energy_Level screen's output
   - Connect directly to Set_Request_Variables
5. Save
```

**That's the main fix!** This alone will prevent duplicate records.

---

### Fix 2: Make Output Values Actually Display (Important!)

Currently, the results screen shows empty fields because the values aren't connected.

**In Flow Builder:**

```
1. Click on "Call_Apex_Method" element
2. Look for the "Store Output Values" section
3. You'll see output variables like:
   - dailyRoutineId
   - success
   - energyCategory
   - studyHours
   - etc.

4. For EACH output, click "Add" or "Manually assign variables"
5. Create new variables to store outputs:

   Output Name              → Store In Variable
   ─────────────────────────────────────────────
   dailyRoutineId          → varDailyRoutineId (Text)
   success                 → varSuccess (Boolean)
   message                 → varMessage (Text)
   energyCategory          → varEnergyCategory (Text)
   studyHours              → varStudyHours (Number)
   jobSearchHours          → varJobSearchHours (Number)
   applicationGoal         → varApplicationGoal (Text)
   todaysSchedule          → varTodaysSchedule (Text)
   motivationalMessage     → varMotivationalMessage (Text)

6. Click "Done"
```

---

### Fix 3: Connect Variables to Screen 2

```
1. Click on "View_Schedule" screen element
2. For each field on the screen:

   ENERGY CATEGORY field:
   - Click on the field
   - Set "Value" = {!varEnergyCategory}

   MOTIVATIONAL MESSAGE field:
   - Click on the field
   - Set "Value" = {!varMotivationalMessage}

   STUDY HOURS field:
   - Click on the field
   - Set "Value" = {!varStudyHours}

   JOB SEARCH HOURS field:
   - Click on the field
   - Set "Value" = {!varJobSearchHours}

   APPLICATION GOAL field:
   - Click on the field
   - Set "Value" = {!varApplicationGoal}

   SCHEDULE RECOMMENDATIONS field:
   - Click on the field
   - Set "Value" = {!varTodaysSchedule}

3. Save
```

---

### Fix 4: Fix Mood Picklist (Quick Fix)

```
1. Click on "Log_Energy_Level" screen
2. Click on the "Mood" field
3. Under "Choice Options", find "Happy"
4. Click Edit on that choice
5. Change:
   - Choice Label: Happy → Great
   - Choice Value: Happy → Great
6. Click Done
7. Save
```

---

## 🧪 Test the Flow

After making these fixes:

```
1. In Flow Builder, click "Run" button (lightning bolt icon)
2. Enter test data:
   - Energy Level: 7
   - Mood: Good
   - Morning Routine: Check the box
3. Click "Next"
4. You should see Screen 2 with:
   ✓ Energy Category: Medium
   ✓ Study Hours: 3
   ✓ Job Search Hours: 1.5
   ✓ Application Goal: 2-3 applications
   ✓ Today's Schedule: (text with time blocks)
   ✓ Motivational Message: (personalized text)
5. Click "Finish"
6. Check: Setup → Object Manager → Daily Routine → Records
7. Verify: Only ONE record created for today
```

---

## 🆘 If You Can't Access Flow Builder

**Option A: Ask the User**
```
"I need access to edit Flows in the Salesforce UI. Can you:
1. Give me permission to edit Flows
2. Or make these changes yourself following this guide
3. Or grant me Flow Builder access in the org"
```

**Option B: Alternative - Recreate from Scratch**

If you can access Flow Builder but the current flow is too broken:

```
1. Create a NEW flow instead
2. Use the design from DAILY_ENERGY_CHECKIN_FLOW_DESIGN.md
3. Follow the structure there (it's correct)
4. Takes ~1 hour but guarantees it works
```

---

## 📋 Summary: What Needs to Change

| Current (Broken) | Fixed (Working) |
|------------------|-----------------|
| Screen 1 → Create Record → Apex Call → Screen 2 | Screen 1 → Apex Call → Screen 2 |
| Apex outputs go nowhere | Apex outputs stored in variables |
| Screen 2 fields are empty | Screen 2 fields show variable values |
| Mood choice: "Happy" | Mood choice: "Great" |
| Creates 2 Daily_Routine records | Creates 1 Daily_Routine record |

---

## 🎯 Success Criteria

Flow is working when:
- [ ] Running flow once creates EXACTLY 1 Daily_Routine__c record
- [ ] Screen 2 shows actual values (not blank)
- [ ] Energy Category displays: High, Medium, Low, or Flare-up
- [ ] Study Hours, Job Search Hours, Application Goal all show numbers
- [ ] Today's Schedule shows text with time blocks
- [ ] Running flow twice on same day updates (doesn't duplicate)

---

## 💡 Key Takeaway

**Flows = Visual Tools**
- Edit in Flow Builder (visual interface) ✅
- Don't edit XML directly ❌

**The main fix is simple:**
1. Delete the duplicate record creation element
2. Map Apex outputs to variables
3. Display those variables on Screen 2

**That's it!** The rest is minor polish.

---

## 📞 Report Back

After making changes, report:
- ✅ "Fixed: Removed duplicate record creation"
- ✅ "Fixed: Mapped outputs to variables"
- ✅ "Fixed: Connected variables to Screen 2"
- ✅ "Tested: Flow creates 1 record and displays results"
- ✅ "Ready for next step"

OR if stuck:
- ❌ "Cannot access Flow Builder - need help with [specific issue]"
- ❌ "Stuck on [specific step] - seeing [what you see]"

---

**You've got this! The fixes are straightforward in the visual Flow Builder.** 🚀

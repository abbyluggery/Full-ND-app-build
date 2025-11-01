# Field Permission Issue - Daily_Routine__c

## Problem
The 13 wellness fields exist in Object Manager (you can see them in the UI), but Apex cannot access them. Error: "Invalid field Energy_Level_Morning__c for Daily_Routine__c"

## Root Cause
**Field-Level Security (FLS)** - The fields exist but your user profile doesn't have read/write permissions on them via the API.

## Solution: Grant Field Permissions

### Option 1: Via Permission Set (Recommended)
1. Go to **Setup** > **Permission Sets**
2. Find or create a permission set (e.g., "Full_Platform_Access")
3. Click **Object Settings**
4. Click **Daily_Routine__c**
5. Click **Edit**
6. For each of the 13 wellness fields, check both:
   - ✅ **Read Access**
   - ✅ **Edit Access**
7. Save
8. Assign the permission set to your user

### Option 2: Via Profile
1. Go to **Setup** > **Profiles**
2. Click on your profile (System Administrator)
3. Click **Object Settings**
4. Click **Daily_Routine__c**
5. Click **Edit**
6. For each wellness field, enable **Read** and **Edit** access
7. Save

### Option 3: Make Fields Visible to All Profiles
1. Go to **Setup** > **Object Manager** > **Daily_Routine__c** > **Fields & Relationships**
2. For EACH of the 13 fields:
   - Click the field name
   - Click **Set Field-Level Security**
   - Check **Visible** for System Administrator (and any other profiles)
   - Click **Save**

## Fields Needing Permission:
1. Energy_Level_Morning__c
2. Energy_Level_Afternoon__c
3. Energy_Level_Evening__c
4. Mood__c
5. Stress_Level__c
6. Exercise_Completed__c
7. Exercise_Type__c
8. Water_Intake__c
9. Morning_Routine_Complete__c
10. Accomplished_Today__c
11. Challenges__c
12. Gratitude__c
13. Tomorrow_Priorities__c

## Quick Test After Fix
After granting permissions, run this in Anonymous Apex:
```apex
Daily_Routine__c test = new Daily_Routine__c(
    Date__c = Date.today()-20,
    Energy_Level_Morning__c = 8
);
insert test;
System.debug('SUCCESS! Field permissions working. ID: ' + test.Id);
```

If you see "SUCCESS!" then permissions are fixed and I can update all 10 records with wellness data.

## Why This Happened
When Agentforce deployed the fields, they were created without default field-level security, so they're visible in Object Manager but not accessible via API/Apex.

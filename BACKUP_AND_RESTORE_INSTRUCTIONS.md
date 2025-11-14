# Backup and Restore Instructions

**Date:** November 7, 2025

---

## STEP 1: Backup Current Salesforce Data (BEFORE Making Changes)

### Via Salesforce Workbench:

1. **Login to Workbench:**
   - Go to: https://workbench.developerforce.com
   - Login with: `abbyluggery179@agentforce.com`
   - Environment: **Production**

2. **Export Current Meal Data:**
   - Click **Queries** → **SOQL Query**
   - Object: **Meal__c**
   - Fields: Select **Id, Name, Ingredients__c, Instructions__c, Recipe_Content__c, LastModifiedDate**
   - Click **Query**

3. **Download Results:**
   - Click **Download** to save as CSV
   - Save as: `salesforce_meals_BACKUP_2025-11-07.csv`
   - **KEEP THIS FILE SAFE!**

---

## STEP 2: Identify Which Meals Were Incorrectly Updated

### Option A: Use Last Modified Date

**If you imported TODAY (Nov 7, 2025):**

1. In Workbench, add this WHERE clause to the query:
   ```
   WHERE LastModifiedDate = TODAY
   ```

2. This will show only meals updated today
3. Download this list - these are the 63 meals that got wrong data

### Option B: Manual Review

1. Go to Salesforce → Meals tab
2. Create a List View filtered by:
   - **Last Modified Date = Today**
3. Review the list to confirm these are the incorrectly updated meals

---

## STEP 3: Restore Original Data

### Method 1: Full Restore (if you have pre-import backup)

**IF you have a backup from BEFORE the import:**

1. In Workbench → **Data** → **Update**
2. Object: **Meal__c**
3. Upload your backup CSV
4. Map fields:
   - Id → Record ID
   - Ingredients__c → Ingredients
   - Instructions__c → Instructions
   - Recipe_Content__c → Recipe Content
5. Click **Update**

### Method 2: Clear the Incorrect Data

**To blank out the wrongly imported data:**

1. Create a CSV with just the IDs of the 63 incorrectly updated meals:
   ```csv
   Id,Ingredients__c,Instructions__c,Recipe_Content__c
   a1Hg500000001tnEAA,,,
   a1Hg500000001xxEAA,,,
   ... (all 63 IDs with empty values)
   ```

2. Upload via Workbench Update to clear those fields
3. This will remove the bad data so you can re-import correctly

---

## STEP 4: Fix Your Import File

Before re-importing, you MUST verify that each Salesforce ID matches the correct recipe name.

**I will create a script to help you with this.**

---

## STEP 5: Re-Import with Correct Data

Once you have:
1. ✓ Backed up current data
2. ✓ Restored or cleared incorrect data
3. ✓ Verified your import file has correct ID-to-recipe matches

Then you can re-import using Workbench.

---

## Important Notes:

- **ALWAYS backup before making changes**
- **Verify ID matches before importing**
- **Test with 5-10 records first** before importing all 63

---

## Quick Reference: Salesforce Meal Fields

| Field API Name | Type | Max Length |
|----------------|------|------------|
| Name | Text | 80 |
| Ingredients__c | LongTextArea | 32,768 |
| Instructions__c | LongTextArea | 32,768 |
| Recipe_Content__c | LongTextArea | 32,768 |

---

**Status:** Awaiting you to close Excel file so we can verify ID matches

# Recipe Import Fix Instructions

**Date:** November 7, 2025
**Problem:** Recipe data was imported to the wrong Salesforce meals due to ID mismatches

---

## What Happened

You imported recipe data using `Meal__c_CLEANED_IMPORT.csv`, but the Salesforce IDs in your file didn't match the correct recipe names. For example:

- **ID `a1Hg500000001tnEAA`** = "Asiago Chicken Pasta" in Salesforce
- But your import file had "**Chicken & Quinoa Buddha Bowl**" data for that ID
- So now "Asiago Chicken Pasta" has the wrong recipe data

**Result:** All 63 imported meals now have incorrect ingredients, instructions, and content.

---

## Step-by-Step Fix

### STEP 1: Backup Your Current Salesforce Data ⚠️

**CRITICAL:** Do this BEFORE making any changes!

1. Login to Workbench: https://workbench.developerforce.com
2. Go to **Queries** → **SOQL Query**
3. Object: **Meal__c**
4. Select fields: **Id, Name, Ingredients__c, Instructions__c, Recipe_Content__c, LastModifiedDate**
5. Add WHERE clause:
   ```
   WHERE LastModifiedDate = TODAY
   ```
6. Click **Query**
7. **Download** the results as CSV
8. Save as: `salesforce_meals_BACKUP_Nov7_2025.csv`
9. **KEEP THIS FILE SAFE** - it's your backup!

---

### STEP 2: Review the Excel File with Meal Names

I've created a new file for you:

**File:** `C:\Users\Abbyl\OneDrive\Desktop\Receips\new\existing_meals_export2_WITH_NAMES.xlsx`

This file now has:
- **Column A:** Salesforce ID
- **Column B:** Salesforce Meal Name (what meal that ID corresponds to)
- **Column C:** Ingredients (your recipe data)
- **Column D:** Instructions (your recipe data)
- **Column E:** Recipe_Content (your recipe data)

**Open this file and review it** to see the mismatches.

---

### STEP 3: Understand the Mismatches

Looking at the file, here's an example:

| ID | Salesforce Meal Name | Ingredients (Your Data) |
|----|---------------------|------------------------|
| a1Hg500000001tnEAA | **Asiago Chicken Pasta** | 1 cup cooked quinoa... (Buddha Bowl data) |
| a1Hg500000001tsEAA | **Baked Lemon Pepper Chicken** | Baked Lemon Pepper Chicken data |
| a1Hg500000001ttEAA | **Baked Salmon with Herb Butter** | Herb Crusted Salmon data |

**The problem:** Column B (Salesforce name) doesn't always match Column C-E (recipe data).

---

### STEP 4: Decide How to Fix This

You have two options:

#### Option A: Find the Correct IDs (RECOMMENDED if you want to keep all data)

For each row:
1. Look at the recipe data in columns C-E
2. Determine what recipe it's actually for
3. Look up the correct Salesforce ID from `existing_meals_export.csv`
4. Update column A with the correct ID

**Example:**
- Row 2 has Buddha Bowl data
- Find "Chicken & Quinoa Buddha Bowl" in `existing_meals_export.csv`
- Get its ID and replace in column A

#### Option B: Remove Mismatched Rows (FASTER)

1. Delete any row where the Salesforce name (column B) doesn't match the recipe data (columns C-E)
2. Keep only rows that match correctly
3. You'll import fewer recipes, but they'll all be correct

---

### STEP 5: Clear the Bad Data from Salesforce

Once you've identified which 63 meals have wrong data, you need to clear them:

#### Method 1: Restore from Backup (if you have one from BEFORE the import)

1. In Workbench → **Data** → **Update**
2. Upload your pre-import backup CSV
3. Map fields and update

#### Method 2: Clear the Fields

1. Create a CSV with just the 63 IDs and blank values:
   ```csv
   Id,Ingredients__c,Instructions__c,Recipe_Content__c
   a1Hg500000001tnEAA,,,
   a1Hg500000001tsEAA,,,
   ... (all 63 IDs)
   ```

2. Upload via Workbench Update to clear those fields

**I can create this "clear" CSV for you if needed.**

---

### STEP 6: Create Corrected Import File

Once your Excel file has the correct IDs:

1. Let me know it's ready
2. I'll create a new import CSV from it
3. This time with verified ID-to-recipe matches

---

### STEP 7: Re-Import (Correctly This Time)

1. Upload the corrected CSV via Workbench
2. Data → Update → Meal__c
3. Map fields and execute
4. Verify a few recipes in Salesforce to confirm they're correct

---

## Quick Summary

**The Core Problem:** Your original file (`existing_meals_export2.xlsx`) had IDs but no recipe names, so there was no way to verify that ID matched the recipe data.

**The Solution:**
1. I added the Salesforce meal names to column B
2. You review and fix the mismatches
3. Clear the bad data from Salesforce
4. Re-import with correct IDs

---

## Files Reference

### Created for You:
- **existing_meals_export2_WITH_NAMES.xlsx** - Your file with Salesforce names added (REVIEW THIS)
- **MISMATCH_REPORT.md** - Detailed list of all 63 mismatches
- **BACKUP_AND_RESTORE_INSTRUCTIONS.md** - Detailed Salesforce backup/restore steps

### Reference Files:
- **existing_meals_export.csv** - All 116 Salesforce meals with correct IDs (use this to look up correct IDs)

---

## What To Do Next

1. **BACKUP SALESFORCE DATA** (Step 1 above)
2. **Open:** `existing_meals_export2_WITH_NAMES.xlsx`
3. **Review** columns A and B to see the mismatches
4. **Decide:** Fix the IDs (Option A) or remove bad rows (Option B)
5. **Let me know when ready** and I'll help with next steps

---

## Need Help?

Let me know if you want me to:
- Create the "clear bad data" CSV for you
- Help identify which IDs are correct
- Create the corrected import CSV once you've fixed the Excel file

---

**Status:** Waiting for you to review `existing_meals_export2_WITH_NAMES.xlsx`

# Meal Timing Data Import Guide

**Date**: November 8, 2025
**Status**: Ready to Import

---

## Summary of Generated Data

I've analyzed your 116 existing Meal__c records and generated estimated timing and categorization data.

### Import File Created:
**File**: `data/Meal__c_timing_update.csv`
**Records**: 116 meals
**Fields**: Id, Prep_Time_Minutes__c, Cook_Time_Minutes__c, Servings__c, Protein_Type__c

---

## Statistics from the Analysis

### Protein Type Distribution:
- **Other**: 52 meals (45%) - Needs manual review/correction
- **Chicken**: 32 meals (28%)
- **Pork**: 11 meals (9%)
- **Fish/Seafood**: 10 meals (9%)
- **Beef**: 5 meals (4%)
- **Eggs**: 3 meals (3%)
- **Vegetarian**: 2 meals (2%)
- **Turkey**: 1 meal (1%)

### Timing Breakdown:
- **Prep Time Range**: 5-15 minutes
- **Cook Time Range**: 0-40 minutes
- **Total Time Range**: 5-55 minutes

### Meal Planning Impact:
- **Weeknight Friendly**: 65 of 116 meals (56%)
  - These are meals with ≤30 min total time
  - Perfect for Mon-Fri dinners
- **Weekend Meals**: 51 of 116 meals (44%)
  - 31-55 minute meals
  - Better for Saturday/Sunday when you have more time

---

## Sample Estimates (First 15 Meals)

| Meal Name | Protein | Prep | Cook | Total | Weeknight? |
|-----------|---------|------|------|-------|------------|
| Apple Cinnamon Roll Casserole | Other | 15 | 40 | 55 | No |
| Apples with Almond-Apricot Sauce | Other | 10 | 20 | 30 | Yes |
| Asiago Chicken Pasta | Chicken | 10 | 20 | 30 | Yes |
| Avocado and Coconut Refresher Smoothie | Other | 5 | 0 | 5 | Yes |
| Avocado-Chimichurri Steak | Beef | 10 | 25 | 35 | No |
| AvoFredo Zoodles | Other | 10 | 20 | 30 | Yes |
| Bacon Mac and Cheese | Pork | 10 | 25 | 35 | No |
| Baked Lemon Pepper Chicken | Chicken | 15 | 25 | 40 | No |
| Baked Salmon with Herb Butter | Fish/Seafood | 15 | 25 | 40 | No |
| Baked Spaghetti | Other | 15 | 25 | 40 | No |
| Banana Bread Smoothie | Other | 5 | 0 | 5 | Yes |
| Beef with Broccoli | Beef | 10 | 25 | 35 | No |
| Bengali Chicken Curry | Chicken | 15 | 30 | 45 | No |
| Biscuits and Gravy Casserole | Other | 15 | 40 | 55 | No |

---

## Important Notes

### ⚠️ Protein Type "Other" Needs Review

**52 meals** were categorized as "Other" because the meal name didn't clearly indicate a protein source. These likely need manual correction.

**Common reasons for "Other" classification:**
- Generic names (e.g., "Best for meal prep?")
- Desserts/sides (e.g., "Apple Cinnamon Roll Casserole")
- Unclear protein source from name alone

**Recommended action:**
- After import, go through meals with Protein_Type__c = "Other"
- Update them to the correct protein type
- Or leave as "Other" if they truly are sides/desserts

### How Estimates Were Generated:

**Prep Time** - Based on meal type keywords:
- 5 min: Smoothies, yogurt, wraps, sandwiches
- 10 min: Salads, bowls, scrambles, stir fries
- 15 min: Casseroles, bakes, roasts, soups, stews

**Cook Time** - Based on meal type and protein:
- 0 min: No-cook meals (wraps, smoothies, overnight oats)
- 12 min: Quick-cook (scrambles, stir fries)
- 15 min: Fish/seafood
- 20 min: Chicken
- 25 min: Bakes, roasts, beef, pork
- 30 min: Soups, curries, chili
- 40 min: Casseroles, stews, slow-cooked

**Servings**: Default to 5 people (adjust as needed)

---

## Import Instructions

### Option 1: Import via Salesforce Data Loader (Recommended)

1. **Download Data Loader**
   - Go to Setup → Data → Data Loader
   - Download and install if not already installed

2. **Login to Data Loader**
   - Open Data Loader
   - Click "Log in"
   - Environment: Production
   - Username: `abbyluggery179@agentforce.com`
   - Login

3. **Select Update Operation**
   - Click "Update"
   - Object: `Meal__c`
   - Click "Next"

4. **Select CSV File**
   - Browse to: `data/Meal__c_timing_update.csv`
   - Click "Next"

5. **Map Fields**
   - Auto-map fields (should match automatically)
   - Verify mapping:
     * Id → Id
     * Prep_Time_Minutes__c → Prep Time Minutes
     * Cook_Time_Minutes__c → Cook Time Minutes
     * Servings__c → Servings
     * Protein_Type__c → Protein Type
   - Click "Next"

6. **Select Output Directory**
   - Choose where to save success/error files
   - Click "Finish"

7. **Verify Results**
   - Check success.csv for all 116 records
   - Check error.csv for any failures

### Option 2: Import via Workbench

1. **Login to Workbench**
   - Go to: https://workbench.developerforce.com
   - Environment: Production
   - Login with: `abbyluggery179@agentforce.com`

2. **Select Update**
   - Click "Data" menu → "Update"
   - Object: Meal__c
   - Click "Next"

3. **Upload CSV**
   - Click "Choose File"
   - Select: `data/Meal__c_timing_update.csv`
   - Click "Next"

4. **Map Fields** (same as Data Loader option)

5. **Confirm and Execute**
   - Review mapping
   - Click "Confirm Update"
   - Wait for completion

---

## After Import - Verification Steps

### 1. Check Formula Fields Auto-Calculated

Go to any Meal record and verify:
- **Total_Time_Minutes__c** = Prep_Time_Minutes__c + Cook_Time_Minutes__c
- **Is_Weeknight_Friendly__c** = true if Total_Time_Minutes__c ≤ 30

### 2. Review "Other" Protein Type Meals

Run this SOQL query:
```sql
SELECT Id, Name, Protein_Type__c
FROM Meal__c
WHERE Protein_Type__c = 'Other'
```

Update the 52 records with correct protein types.

### 3. Test Meal Plan Generation

Now that you have 116 meals + 8 test meals = 124 total meals with timing data:

1. Go to Generate Meal Plan Wizard
2. Enter:
   - Start Date: 11/10/2025
   - Number of People: 5
3. Run the wizard

**Expected result**: Full 2-week meal plan with:
- 14 days of meals
- 3 meals per day (breakfast, lunch, dinner)
- Weeknight dinners ≤ 30 minutes
- Beef and Pork limited to 1x per week each
- No recipe repeats

---

## Next Steps After Import

1. **Import the timing data** (this file)
2. **Import the recipe content** (Ingredients, Instructions)
   - Use: `data/Meal__c_FINAL_IMPORT.csv`
   - See: `FINAL_IMPORT_SUMMARY.md` for instructions
3. **Test the Meal Plan Wizard**
4. **Verify shopping list generation**
5. **Configure Walgreens API** (if/when approved)

---

## Troubleshooting

### If import fails:

**Check error message** - Common issues:
- Invalid picklist value for Protein_Type__c
  - Valid values: Chicken, Beef, Pork, Fish/Seafood, Turkey, Vegetarian, Eggs, Other
- Field not writable
  - Make sure you're updating, not inserting
- Record not found
  - Verify the IDs in your CSV match actual Salesforce record IDs

### If formula fields don't calculate:

- Save the record again (triggers formula recalculation)
- Check field dependencies in Setup

---

## Files Reference

### Input:
- `data/existing_meals_export.csv` - Your 116 existing meals with IDs

### Output:
- `data/Meal__c_timing_update.csv` - **IMPORT THIS FILE**
  - 116 records ready for update
  - Fields: Id, Prep_Time_Minutes__c, Cook_Time_Minutes__c, Servings__c, Protein_Type__c

### Scripts:
- `scripts/enrich_meals_with_timing_data.py` - Generated the estimates

---

## Estimated Time to Complete

- **Import**: 5-10 minutes
- **Verify/Review**: 10-15 minutes
- **Fix "Other" proteins** (optional): 20-30 minutes
- **Total**: ~30-50 minutes

---

**Current Status**: CSV file ready for import
**Next Action**: Import `data/Meal__c_timing_update.csv` via Data Loader or Workbench
**After Import**: Test the Meal Plan Wizard to generate a full 2-week plan!

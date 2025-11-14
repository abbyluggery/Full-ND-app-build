# How to Import All 21 Recipes to Salesforce

**Date**: November 6, 2025
**Status**: Master CSV Created - Ready for Your Review

---

## What You Now Have

✅ **Master CSV File Created**: `data/ALL_21_RECIPES_MASTER.csv`

This CSV contains **all 21 recipes** from your markdown files:
- 7 Breakfast recipes
- 7 Lunch recipes
- 7 Dinner recipes

---

## CSV Column Structure

| Column | Description |
|--------|-------------|
| **Markdown_Recipe_Name** | Exact name from the markdown file |
| **Suggested_Salesforce_Name** | My suggested name (you can edit this!) |
| **Category** | Breakfast, Lunch, or Dinner |
| **Ingredients** | Full ingredients list with measurements |
| **Instructions** | Step-by-step cooking directions |
| **Recipe_Content** | Complete recipe text (all details) |
| **Source_File** | Which markdown file it came from |
| **Extracted** | "Yes" = full data, "No" or "Partial" = needs review |

---

## Extraction Results

### ✅ Fully Extracted (5 recipes):
1. Overnight Steel-Cut Oats (Breakfast)
2. Egg Muffin Cups (Breakfast) - **Already imported!**
3. Breakfast Burrito Wraps (Breakfast) - **Already imported!**
4. Mediterranean Pasta Salad (Lunch)
5. Tuna & White Bean Salad (Lunch) - **Already imported!**

### ⚠️ Partially Extracted (16 recipes):
These have the full recipe content but ingredients/instructions need manual review:

**Breakfast (4)**:
- Greek Yogurt Parfait Jars
- PB Banana Overnight Oats
- Whole Wheat Toast with Toppings Bar
- Protein Smoothie Bowls

**Lunch (5)**:
- Mason Jar Salads
- Turkey & Veggie Wrap
- Chicken & Quinoa Buddha Bowl
- DIY Bento Box
- Chicken Caesar Salad

**Dinner (7)**:
- Baked Lemon Pepper Chicken
- Mediterranean Sheet Pan Chicken
- Quick Turkey & Veggie Stir-Fry
- One-Pot Creamy Garlic Pasta
- Sheet Pan Chicken Fajitas
- Baked Salmon with Herb Butter
- Slow Cooker Chicken & Vegetable Soup

---

## Your Next Steps

### Step 1: Open the CSV in Excel

1. Navigate to: `C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant\data\`
2. Open: `ALL_21_RECIPES_MASTER.csv` in Excel

### Step 2: Standardize the Names

Review the `Suggested_Salesforce_Name` column and update it to match your existing Salesforce meal names.

**For example:**
- If you have "Baked Lemon Pepper Chicken" in Salesforce, use that exact name
- If the recipe doesn't exist yet, keep the suggested name (you'll create it in Salesforce)

**Quick Reference - Your Current Salesforce Meals:**
Here are some of your existing meal names that might match:
- Baked Lemon Pepper Chicken
- Mediterranean Chicken Sheet Pan Dinner
- Quick Turkey & Veggie Stir-Fry
- One-Pan Chicken & Rice (vs One-Pot Creamy Garlic Pasta)
- Sheet Pan Chicken Fajitas
- Baked Salmon with Herb Butter
- Slow Cooker Chicken & Vegetable Soup
- Greek Yogurt Parfait Jars
- Overnight No-Cook Banana Oatmeal (vs Overnight Steel-Cut Oats)

### Step 3: Review Partial Extractions

For recipes marked "No" or "Partial" in the Extracted column:

1. Look at the `Recipe_Content` column - it has the full recipe text
2. You can either:
   - **Option A**: Copy ingredients and instructions from Recipe_Content into the respective columns
   - **Option B**: Leave them - the Recipe_Content field has everything, you can separate them later

### Step 4: Export to Salesforce-Ready Format

Once you've standardized the names, you need to:

1. Export your current Salesforce meals with IDs (if you haven't already)
2. Match the recipe names to get the Salesforce IDs
3. Create a new CSV with these columns:
   - `Id` (Salesforce record ID)
   - `Ingredients__c`
   - `Instructions__c`
   - `Recipe_Content__c`

---

## Two Import Approaches

### Approach A: Update Existing Recipes (Recommended First)

**For recipes that match existing Salesforce meals:**

1. Use the `existing_meals_export.csv` you already have
2. Match recipe names to get Salesforce IDs
3. Create update CSV with ID + recipe data
4. Import via Workbench (like you just did successfully!)

**Recipes likely to match your existing Salesforce meals:**
- Baked Lemon Pepper Chicken
- Sheet Pan Chicken Fajitas
- Baked Salmon with Herb Butter
- Mediterranean Sheet Pan Chicken
- Slow Cooker Chicken & Vegetable Soup
- Quick Turkey & Veggie Stir-Fry

### Approach B: Create New Meal Records

**For recipes that don't exist in Salesforce yet:**

1. Create new Meal__c records in Salesforce
2. Note their new IDs
3. Import recipe data to these new records

---

## Quick Win Option

**Want to import more recipes RIGHT NOW?**

I can create another update CSV that includes **ONLY the 5 fully extracted recipes** (including the 2 new ones you haven't imported yet):

1. Overnight Steel-Cut Oats - NEW
2. Mediterranean Pasta Salad - NEW
3. Plus the 3 you already imported

This would give you 5 complete recipes immediately!

---

## Need Help with Matching?

I can create a script that:

1. Reads your existing Salesforce meals export
2. Auto-matches the 21 recipe names to Salesforce IDs
3. Creates a ready-to-import CSV

Just let me know which approach you prefer!

---

## What's in the CSV

### Example Row (Overnight Steel-Cut Oats):

```
Markdown_Recipe_Name: Overnight Steel-Cut Oats
Suggested_Salesforce_Name: Overnight Steel-Cut Oats
Category: Breakfast
Ingredients:
  2.5 cups steel-cut oats
  5 cups unsweetened almond milk (or skim milk)
  2 tsp cinnamon
  2 tsp vanilla extract
  2 Tbsp honey (optional)
  TOPPINGS: Berries, nuts, Greek yogurt
Instructions: [contains the 4 preparation steps]
Recipe_Content: [full recipe with all sections]
Source_File: Grab_and_Go_Breakfasts_Guide.md
Extracted: Yes
```

---

## Questions?

**Q: Why are some marked "Partial"?**
A: The extraction script found the recipes but the format was slightly different (like "#### Assembly" instead of "#### Instructions"). The full data is still in Recipe_Content - it just needs manual separation into Ingredients and Instructions columns.

**Q: Can you fix the partial extractions?**
A: Yes! I can improve the extraction script, or you can manually edit the CSV in Excel (faster for 16 recipes).

**Q: Should I create new Salesforce meals or update existing ones?**
A: Start with updating existing meals first (you have ~10-12 that likely match). Then decide if you want to create new meal records for the others.

**Q: What about the other 95+ recipes in Salesforce?**
A: Those don't have matching markdown files with full details. Your options:
- Manual entry (as originally planned)
- Find other data sources
- Use the PDFs as reference for manual entry

---

## Files You Have Now

✅ `data/ALL_21_RECIPES_MASTER.csv` - **Master file with all 21 recipes**

✅ `data/Meal__c_comprehensive_update.csv` - 3 recipes already imported

✅ `data/existing_meals_export.csv` - Your 116 Salesforce meals with IDs

✅ Scripts available to create more update CSVs as needed

---

**Ready to proceed?** Let me know:

1. Do you want me to create an auto-matched CSV for immediate import?
2. Do you want to manually standardize the names first in Excel?
3. Do you want help with matching the names to existing Salesforce meals?

I'm here to help with whatever approach works best for you!

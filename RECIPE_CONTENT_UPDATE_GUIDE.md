# Recipe Content Update Guide
**Date**: November 6, 2025
**Status**: In Progress

---

## What We've Accomplished Today

### ✅ Completed Tasks:

1. **Made Meal Planning Tabs Visible**
   - Created 6 custom tabs (Meals, Weekly Meal Plans, Planned Meals, Shopping Lists, Job Postings, Resume Packages)
   - Deployed NeuroThrive Assistant Lightning App
   - All tabs now visible in Salesforce

2. **Added New Fields to Meal Object**
   - **Ingredients__c** (Long Text Area, 32,768 characters)
   - **Instructions__c** (Long Text Area, 32,768 characters)
   - Successfully deployed to Salesforce

3. **Created Extraction Scripts**
   - PDF extraction script: `scripts/extract_recipes_from_pdfs.py`
   - Excel extraction script: `scripts/extract_recipes_from_excel.py`
   - Export script: `scripts/export_meals.bat`

4. **Exported Salesforce Data**
   - 116 meal records exported with IDs
   - File: `data/existing_meals_export.csv`

---

## Current Challenge

**PDF Issue**: The recipe PDFs appear to be scanned images, not text-based PDFs. PyPDF2 cannot extract text from image-based PDFs. Only 2 out of 80+ PDFs were successfully extracted.

**Excel Issue**: The Excel files have complex structures:
- `Recipes (version 1).xlsx`: Each recipe in a single column (not tabular)
- `Recipes Extented.xlsm`: Each recipe on a separate sheet

---

## Recommended Solutions (Choose One)

### Option 1: Manual Entry (Most Reliable)
**Best for**: If you want complete control and accuracy

**Process**:
1. Go to Salesforce → Recipes tab
2. Open each recipe record
3. Click "Edit"
4. Copy/paste from your PDF files into the new fields:
   - **Ingredients**: List all ingredients with measurements
   - **Instructions**: Step-by-step cooking directions
   - **Recipe Content**: Full recipe text
5. Click "Save"

**Pros**:
- Most accurate
- You can format exactly as you want
- No technical issues

**Cons**:
- Time-consuming (116 recipes)

---

### Option 2: Use OCR to Extract PDF Text
**Best for**: If you want automation but PDFs are images

**Requirements**:
- Install OCR library: `pip install pytesseract pillow pdf2image`
- Install Tesseract OCR: https://github.com/UB-Mannheim/tesseract/wiki
- Update the PDF extraction script to use OCR

**Process**:
1. Install required software
2. I can update the script to use OCR
3. Re-run extraction
4. Import via Workbench

**Pros**:
- Automated extraction
- Handles image-based PDFs

**Cons**:
- Requires additional software installation
- OCR may have accuracy issues
- Setup time required

---

### Option 3: Reorganize Excel Data
**Best for**: If Excel data can be consolidated

**Process**:
1. Open `Recipes Extented.xlsm`
2. Create a new sheet called "All Recipes"
3. Add columns: Recipe Name, Ingredients, Instructions
4. Copy data from each sheet into the consolidated sheet
5. Export as CSV
6. Update the Excel extraction script to read the new format
7. Run extraction and import

**Pros**:
- Structured data
- Can be automated once consolidated

**Cons**:
- Manual Excel work required first
- Time-consuming consolidation

---

### Option 4: Hybrid Approach (RECOMMENDED)
**Best for**: Balance of automation and accuracy

**Process**:
1. **Start with top 10-20 most used recipes** - enter manually
2. **Use Recipe_Content__c field** to store full recipe temporarily
3. **Gradually add more** as you use them
4. **Use the PDFs as reference** - open PDF side-by-side with Salesforce

**Pros**:
- Get value immediately with most-used recipes
- No technical barriers
- Spread work over time

**Cons**:
- Not all recipes populated immediately

---

## Page Layout Update (Still Needed)

To see the new Ingredients and Instructions fields on your recipe pages:

1. **Go to Setup**
2. **Search**: "Object Manager"
3. **Click**: "Meal"
4. **Click**: "Page Layouts"
5. **Click**: "Meal Layout"
6. **Drag these fields** from the top onto the layout:
   - Ingredients
   - Instructions
7. **Click "Save"**

After this, when you open any Meal/Recipe record, you'll see these fields and can enter data.

---

## Shopping List & Meal Planning Integration

Once recipes have Ingredients populated, here's how they connect:

### Planned Meals
- Links a Meal (recipe) to a specific date
- Shows in Weekly Meal Plan
- When you click the Meal name, you see the full recipe with ingredients

### Shopping Lists
- Linked to Weekly Meal Plan
- **Manual Process**: Review planned meals for the week, compile ingredients
- **Future Enhancement**: Could create a Flow/Apex to auto-generate shopping list from planned meals' ingredients

### Weekly Meal Plans
- Container for the week's planned meals
- Shows all meals for Monday-Sunday
- Used to generate shopping list

---

## Quick Win: Add One Complete Recipe

Let's test the system with one complete recipe:

1. Go to Salesforce → **Recipes** tab
2. Click **"Easy Sesame Chicken"** (the one you looked at earlier)
3. Click **"Edit"**
4. Open the PDF: `C:\Users\Abbyl\OneDrive\Desktop\Receips\Easy Sesame Chicken.pdf`
5. Copy the ingredients list into the **Ingredients** field
6. Copy the cooking instructions into the **Instructions** field
7. Click **"Save"**
8. Verify it displays correctly

This will prove the system works end-to-end!

---

## Files Created This Session

### Scripts:
- `scripts/extract_recipes_from_pdfs.py` - Extract from PDF files
- `scripts/extract_recipes_from_excel.py` - Extract from Excel files
- `scripts/export_meals.bat` - Export meals from Salesforce

### Data Files:
- `data/existing_meals_export.csv` - 116 meals with Salesforce IDs
- `data/Meal__c_update.csv` - Update file (only 2 recipes extracted)

### Metadata:
- `force-app/main/default/objects/Meal__c/fields/Ingredients__c.field-meta.xml`
- `force-app/main/default/objects/Meal__c/fields/Instructions__c.field-meta.xml`
- All meal planning tabs (6 files in `force-app/main/default/tabs/`)
- NeuroThrive Assistant app

---

## Next Session Goals

1. **Update Meal page layout** to show new fields
2. **Choose an approach** for populating recipe data
3. **Test with 5-10 recipes** to verify the system
4. **Create test meal plan** for this week
5. **Generate shopping list** from meal plan

---

## Recipe Data Locations

Your recipe data is in multiple places:

1. **PDFs** (Image-based): `C:\Users\Abbyl\OneDrive\Desktop\Receips\*.pdf`
2. **Excel** (Complex structure):
   - `C:\Users\Abbyl\OneDrive\Desktop\Receips\Recipes (version 1).xlsx`
   - `C:\Users\Abbyl\OneDrive\Desktop\Receips\Recipes Extented.xlsm`
3. **Markdown** (Summary only): `RECIPES_DATABASE.md`
4. **Skill Package**: `C:\Users\Abbyl\OneDrive\Desktop\Summary Artifacts and Documents from Claude\Household\family-meal-dietician\references\RECIPES.md`

**Recommendation**: Use the PDFs as your primary source - they appear to be the most complete and readable format.

---

## Summary

**Today's Achievement**: Successfully configured Salesforce meal planning system with all necessary objects, fields, and tabs visible!

**Remaining Work**: Populate recipe content (ingredients and instructions) into the 116 meal records.

**Best Path Forward**: Hybrid approach - start with your top 10-20 most-used recipes, enter manually, expand over time.

---

**Created**: November 6, 2025
**Next Update**: After page layout update and test recipe entry

# Ingredient Parser System - Complete Guide

**Date**: November 9, 2025
**Status**: Deployed and Ready to Use

---

## Overview

The Ingredient Parser System automatically converts text-based ingredient lists (stored in `Meal__c.Ingredients__c`) into structured `Meal_Ingredient__c` records that power the shopping list generation feature.

### What It Does:

1. **Parses ingredient text** like "2 cups flour\n1 lb chicken breast"
2. **Extracts quantity, unit, and ingredient name** from each line
3. **Auto-categorizes ingredients** (Produce, Meat & Seafood, Dairy, Pantry, etc.)
4. **Creates `Meal_Ingredient__c` records** for shopping list generation

---

## System Components

### 1. IngredientParser.cls (Apex Class)

**Location**: [force-app/main/default/classes/IngredientParser.cls](force-app/main/default/classes/IngredientParser.cls)

**Key Methods**:
- `parseIngredientsForMeals(Set<Id> mealIds)` - Main parsing method
- `parseIngredientText(Id mealId, String ingredientText)` - Parses single meal
- `parseIngredientLine(Id mealId, String line)` - Parses single ingredient line
- `categorizeIngredient(String ingredientName)` - Auto-categorizes by keywords

**Example Usage** (Anonymous Apex):
```apex
Set<Id> mealIds = new Set<Id>{
    'a015g000001XYZ123' // Your meal ID
};

Integer count = IngredientParser.parseIngredientsForMeals(mealIds);
System.debug('Created ' + count + ' ingredients');
```

### 2. IngredientParserTest.cls (Test Class)

**Location**: [force-app/main/default/classes/IngredientParserTest.cls](force-app/main/default/classes/IngredientParserTest.cls)

**Test Coverage**: 8 test methods covering:
- Basic ingredient parsing
- Plural unit conversion (pounds → lb, tablespoons → tbsp)
- Ingredients without quantities
- Replacing existing ingredients
- Flow invocable method
- Multiple meals batch processing
- Empty ingredients handling
- Auto-categorization

### 3. parse_all_meal_ingredients.apex (Anonymous Apex Script)

**Location**: [scripts/parse_all_meal_ingredients.apex](scripts/parse_all_meal_ingredients.apex)

**Purpose**: Bulk parse all meals in your org

---

## How Ingredient Parsing Works

### Input Format

The parser expects ingredients in the `Ingredients__c` text field, one per line:

```
2 cups flour
1 lb chicken breast
3 tbsp olive oil
Salt and pepper to taste
```

### Parsing Logic

**Pattern**: `[quantity] [unit] [ingredient name]`

1. **Extract Quantity** (optional):
   - Looks for a number at the start: `2`, `1.5`, `3`
   - Default: `1` if no quantity found

2. **Extract Unit** (optional):
   - Checks for known units: `cup`, `lb`, `tbsp`, `tsp`, `oz`, etc.
   - Converts plurals to singular: `cups` → `cup`, `pounds` → `lb`
   - Default: `each` if no unit found

3. **Extract Ingredient Name**:
   - Remaining text after quantity and unit
   - Capitalized for consistency: `chicken breast` → `Chicken Breast`

4. **Auto-Categorize**:
   - Scans ingredient name for keywords
   - Matches to categories: Produce, Meat & Seafood, Dairy, Pantry, etc.
   - Default: `Pantry` if no match

### Supported Units

**Valid picklist values** in `Meal_Ingredient__c.Unit__c`:
- `lb`, `oz` (weight)
- `cup`, `tbsp`, `tsp` (volume)
- `each` (count - default)
- `package`, `can`, `jar`, `bottle` (containers)
- `bunch`, `clove`, `pinch` (produce/spices)

**Plural→Singular Mapping**:
```
lbs/pounds → lb
ounces → oz
cups → cup
tablespoons → tbsp
teaspoons → tsp
```

### Category Keywords

**Produce**: lettuce, tomato, onion, garlic, carrot, pepper, spinach, broccoli, etc.
**Meat & Seafood**: chicken, beef, pork, turkey, bacon, salmon, shrimp, fish, etc.
**Dairy**: milk, cheese, butter, cream, yogurt, eggs, etc.
**Pantry**: flour, sugar, salt, pepper, oil, rice, pasta, beans, spices, etc.
**Condiments & Sauces**: ketchup, mustard, mayo, soy sauce, vinegar, dressing, etc.
**Frozen**: frozen vegetables, ice cream, etc.
**Bakery**: tortilla, bun, roll, bagel, pita, etc.
**Beverages**: juice, coffee, tea, soda, wine, etc.

---

## How to Use

### Method 1: Parse All Meals (Recommended First Run)

**Step 1**: Open Developer Console
- In Salesforce, click Setup (gear icon) → Developer Console

**Step 2**: Open Execute Anonymous Window
- Debug → Open Execute Anonymous Window

**Step 3**: Paste and Run Script
```apex
// Get all meals
List<Meal__c> meals = [SELECT Id FROM Meal__c LIMIT 50000];
Set<Id> mealIds = new Set<Id>();
for (Meal__c m : meals) {
    mealIds.add(m.Id);
}

// Parse ingredients
Integer count = IngredientParser.parseIngredientsForMeals(mealIds);
System.debug('Created ' + count + ' ingredient records');
```

**Step 4**: Check Logs
- Look for: `✅ SUCCESS! Created XXX ingredient records`

### Method 2: Parse Specific Meals

If you want to parse only certain meals:

```apex
Set<Id> mealIds = new Set<Id>{
    'a015g000001ABC123',  // Meal 1
    'a015g000001DEF456'   // Meal 2
};

Integer count = IngredientParser.parseIngredientsForMeals(mealIds);
System.debug('Created ' + count + ' ingredients');
```

### Method 3: Via Salesforce CLI

From your project directory:

```bash
cd "C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant"

"C:\Program Files\sf\bin\sf.cmd" apex run \
  --file scripts/parse_all_meal_ingredients.apex \
  --target-org abbyluggery179@agentforce.com
```

### Method 4: Automatic via Flow (Future Enhancement)

You can create a Record-Triggered Flow on `Meal__c` that automatically calls the `IngredientParser.parseIngredientsFromFlow` invocable method whenever a meal's `Ingredients__c` field changes.

---

## Verification After Parsing

### Check Ingredient Count

```apex
// Total ingredients created
Integer totalIngredients = [SELECT COUNT() FROM Meal_Ingredient__c];
System.debug('Total ingredients: ' + totalIngredients);

// Breakdown by category
AggregateResult[] results = [
    SELECT Category__c, COUNT(Id) count
    FROM Meal_Ingredient__c
    GROUP BY Category__c
    ORDER BY COUNT(Id) DESC
];

for (AggregateResult ar : results) {
    System.debug(ar.get('Category__c') + ': ' + ar.get('count'));
}
```

### View Sample Ingredients

```apex
List<Meal_Ingredient__c> ingredients = [
    SELECT Meal__r.Name, Ingredient_Name__c, Quantity__c, Unit__c, Category__c
    FROM Meal_Ingredient__c
    ORDER BY CreatedDate DESC
    LIMIT 20
];

for (Meal_Ingredient__c ing : ingredients) {
    System.debug(ing.Meal__r.Name + ': ' + ing.Quantity__c + ' ' + ing.Unit__c + ' ' + ing.Ingredient_Name__c);
}
```

### Query Specific Meal's Ingredients

```apex
String mealName = 'Baked Salmon with Vegetables';

List<Meal_Ingredient__c> ingredients = [
    SELECT Ingredient_Name__c, Quantity__c, Unit__c, Category__c
    FROM Meal_Ingredient__c
    WHERE Meal__r.Name = :mealName
    ORDER BY Category__c, Ingredient_Name__c
];

System.debug('=== Ingredients for: ' + mealName + ' ===');
for (Meal_Ingredient__c ing : ingredients) {
    System.debug('  ' + ing.Quantity__c + ' ' + ing.Unit__c + ' ' + ing.Ingredient_Name__c + ' (' + ing.Category__c + ')');
}
```

---

## Impact on Shopping Lists

### Before Ingredient Parser:
- ShoppingListGenerator found **0 ingredients**
- Created **0 shopping lists**
- Message: "Shopping Lists Generated: Created 0 shopping list(s)"

### After Ingredient Parser:
- ShoppingListGenerator finds ingredients for all meals in the plan
- Creates shopping lists for Publix, Walmart, and Costco
- Shopping lists populated with aggregated ingredients
- Quantities scaled for number of people

### Example Shopping List Output:

**Publix (Fresh items)**:
- 4 lb Salmon (Meat & Seafood)
- 10 cups Spinach (Produce)
- 6 cups Broccoli (Produce)

**Walmart (Pantry staples)**:
- 12 tbsp Olive Oil (Pantry)
- 4 cup Rice (Pantry)

**Costco (Bulk items)**:
- 6 lb Chicken Breast (Meat & Seafood)

---

## Troubleshooting

### Issue: "0 ingredients created"

**Possible Causes**:
1. Meals don't have `Ingredients__c` text field populated
2. `Ingredients__c` field is blank/null

**Solution**:
```apex
// Check how many meals have ingredients
List<Meal__c> meals = [SELECT Id, Name, Ingredients__c FROM Meal__c];
Integer withIngredients = 0;
for (Meal__c m : meals) {
    if (String.isNotBlank(m.Ingredients__c)) {
        withIngredients++;
        System.debug(m.Name + ': ' + m.Ingredients__c);
    }
}
System.debug(withIngredients + ' meals have ingredients text');
```

### Issue: "field 'Ingredients__c' can not be filtered in a query call"

**Cause**: SOQL WHERE clauses cannot filter on long text area fields

**Solution**: Already fixed in IngredientParser.cls (lines 82-88) - filters in code after query

### Issue: "Invalid unit" error

**Cause**: Ingredient text contains a unit not in the picklist

**Examples**: `dozen`, `slices`, `pieces`

**Solution**:
1. Add the unit to `Meal_Ingredient__c.Unit__c` picklist
2. Update `IngredientParser.UNIT_MAPPINGS` if it's a plural
3. Or use "each" as default unit

### Issue: Ingredients categorized as "Other" or "Pantry"

**Cause**: Ingredient name doesn't contain recognized keywords

**Solution**:
1. Update `IngredientParser.CATEGORY_KEYWORDS` with more keywords
2. Redeploy the class
3. Re-run the parser

---

## Next Steps

### 1. Run the Parser on Your Meals

```bash
# Via CLI
"C:\Program Files\sf\bin\sf.cmd" apex run \
  --file scripts/parse_all_meal_ingredients.apex \
  --target-org abbyluggery179@agentforce.com
```

**OR via Developer Console** (see Method 1 above)

### 2. Verify Ingredient Records Created

Check in Salesforce UI:
- App Launcher → Meal Ingredients
- Or run verification queries (see "Verification After Parsing" section)

### 3. Test Shopping List Generation

1. Go to existing meal plan: Week-0015
2. Click "Generate Lists" button
3. Verify shopping lists created with ingredients

### 4. Generate New Meal Plan

1. Run Generate Meal Plan Wizard
2. Start Date: Next Sunday
3. Number of People: 5
4. Check that shopping lists auto-generate with ingredients

---

## Files Reference

### Deployed to Salesforce:
- `force-app/main/default/classes/IngredientParser.cls` - Main parser logic
- `force-app/main/default/classes/IngredientParser.cls-meta.xml` - Metadata
- `force-app/main/default/classes/IngredientParserTest.cls` - Test coverage
- `force-app/main/default/classes/IngredientParserTest.cls-meta.xml` - Test metadata

### Local Scripts:
- `scripts/parse_all_meal_ingredients.apex` - Bulk parsing script

### Documentation:
- `INGREDIENT_PARSER_GUIDE.md` - This file

---

## Summary

The Ingredient Parser System is **deployed and ready to use**. To enable shopping list generation:

1. ✅ Deploy IngredientParser classes (DONE)
2. ⏳ Run parser on existing meals (NEXT STEP)
3. ⏳ Test shopping list generation
4. ⏳ Verify ingredients appear in shopping lists

**Current Status**: Ready to parse ingredients from your 116+ meals!

**Next Command to Run**:
```bash
"C:\Program Files\sf\bin\sf.cmd" apex run --file scripts/parse_all_meal_ingredients.apex --target-org abbyluggery179@agentforce.com
```

# Deployment Steps - Let's Get This Working!

## What We Need to Deploy

1. ✅ `Is_Pantry_Staple__c` field - Already deployed!
2. ⏳ `IngredientParser.cls` - Enhanced with normalization and pricing
3. ⏳ `ShoppingListGenerator.cls` - Enhanced with pantry staple logic
4. ⏳ Re-parse ingredients to apply enhancements

---

## Option 1: Developer Console (Easiest)

### Step 1: Deploy IngredientParser.cls

1. Open Salesforce
2. Click the gear icon (⚙️) → **Developer Console**
3. File → New → Apex Class
4. Name it: `IngredientParser`
5. Delete all the template code
6. Copy ENTIRE contents from: `force-app/main/default/classes/IngredientParser.cls`
7. Paste into Developer Console
8. File → Save
9. Wait for "Compiled successfully" message

### Step 2: Deploy ShoppingListGenerator.cls

1. In Developer Console: File → New → Apex Class
2. Name it: `ShoppingListGenerator`
3. Delete template code
4. Copy ENTIRE contents from: `force-app/main/default/classes/ShoppingListGenerator.cls`
5. Paste into Developer Console
6. File → Save
7. Wait for "Compiled successfully"

### Step 3: Set Field Security for Is_Pantry_Staple__c

1. In Salesforce: Setup (⚙️) → Object Manager
2. Search for: `Meal Ingredient`
3. Click **Fields & Relationships**
4. Find and click: `Is Pantry Staple`
5. Click **Set Field-Level Security**
6. Check **Visible** for your profile
7. Click **Save**

### Step 4: Re-Parse Ingredients

1. In Developer Console: Debug → Open Execute Anonymous Window
2. Paste this code:
   ```apex
   // Get all meals with ingredient text
   List<Meal__c> meals = [
       SELECT Id, Name, Ingredients__c
       FROM Meal__c
       LIMIT 50000
   ];

   System.debug('Found ' + meals.size() + ' total meals');

   // Filter meals that have ingredients
   Set<Id> mealIds = new Set<Id>();
   Integer mealsWithIngredients = 0;

   for (Meal__c meal : meals) {
       if (String.isNotBlank(meal.Ingredients__c)) {
           mealIds.add(meal.Id);
           mealsWithIngredients++;
       }
   }

   System.debug('Meals with ingredients: ' + mealsWithIngredients);

   if (mealIds.isEmpty()) {
       System.debug('No meals found with ingredient text. Nothing to parse.');
   } else {
       System.debug('Parsing ingredients for ' + mealIds.size() + ' meals...');

       try {
           Integer ingredientCount = IngredientParser.parseIngredientsForMeals(mealIds);
           System.debug('✅ SUCCESS! Created ' + ingredientCount + ' ingredient records');

       } catch (Exception e) {
           System.debug('❌ ERROR: ' + e.getMessage());
           System.debug('Stack trace: ' + e.getStackTraceString());
       }
   }
   ```
3. Check **Open Log**
4. Click **Execute**
5. Wait 30-60 seconds
6. Check the logs - should say "SUCCESS! Created 1111 ingredient records"

---

## Option 2: VS Code (If you prefer)

If you have VS Code with Salesforce Extensions installed:

1. Right-click on `force-app/main/default/classes/IngredientParser.cls`
2. Choose: **SFDX: Deploy Source to Org**
3. Repeat for `ShoppingListGenerator.cls`
4. Follow Steps 3-4 from Option 1

---

## Verify Deployment

### Check Apex Classes Deployed

1. Setup → Apex Classes
2. Search for: `IngredientParser`
3. Should show "Last Modified: Today"
4. Search for: `ShoppingListGenerator`
5. Should show "Last Modified: Today"

### Check Ingredient Records Updated

1. Go to **Meal Ingredients** tab
2. Open any ingredient record
3. You should see:
   - `Is Pantry Staple` checkbox (visible)
   - `Estimated Price` field populated
   - Normalized ingredient names (e.g., all egg variations → "Eggs")

---

## What This Fixes

✅ **Ingredient Normalization:**
- "eggs", "Eggs", "large eggs" → all become "Eggs"
- No more duplicate ingredients in shopping lists!

✅ **Pantry Staples:**
- Salt, pepper, oil, butter, eggs, etc. flagged automatically
- Shopping lists will show these once (not summed)

✅ **Price Estimation:**
- Estimated prices auto-calculated based on category and quantity
- Budget estimates more accurate

✅ **Enhanced Shopping Lists:**
- Pantry staples listed as "check pantry" (quantity = 1)
- Regular ingredients summed across meals as before
- Better shopping experience!

---

## Troubleshooting

**Problem: "Dependent class is invalid"**
- Make sure you deployed `IngredientParser` FIRST
- Then deploy `ShoppingListGenerator`
- Order matters!

**Problem: "Method does not exist"**
- Make sure you copied the ENTIRE file
- Check that all imports and methods are included
- Try File → Save again

**Problem: "Field not found: Is_Pantry_Staple__c"**
- Field was already deployed successfully
- Set field-level security (Step 3)
- Refresh your Developer Console

**Problem: Re-parse creates duplicates**
- The parser automatically deletes old ingredients before creating new ones
- Check that `parseIngredientsForMeals` method includes the delete statement (lines 90-96)

---

## Need Help?

If you get stuck:
1. Take a screenshot of the error
2. Check which step failed
3. We can troubleshoot together!

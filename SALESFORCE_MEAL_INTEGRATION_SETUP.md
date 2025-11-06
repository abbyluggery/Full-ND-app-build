# Salesforce Meal Planning Integration - Setup Guide

## What We've Built

### ✅ Completed Components:

1. **Salesforce Data Model** (Deployed Successfully):
   - `Meal__c` - Recipe library with nutrition info
   - `Weekly_Meal_Plan__c` - Weekly meal plan containers
   - `Planned_Meal__c` - Individual planned meals (junction object)
   - `Shopping_List__c` - Shopping lists with coupons

2. **Apex REST API** (Code Created, Pending Deployment):
   - `MealPlanTodayAPI` - Get today's meals via REST

3. **PWA Updates** (Deployed to GitHub Pages):
   - Fixed Imposter Syndrome detection
   - Removed Bot Training
   - Added Box Breathing countdown
   - Reorganized Journal layout

### 📋 Manual Deployment Needed:

The Apex REST API needs to be deployed manually through Salesforce Setup.

---

## Setup Instructions

### Step 1: Deploy the REST API (Manual)

1. **Open Salesforce Setup**:
   - Log into your Salesforce org: https://login.salesforce.com
   - Username: `abbyluggery179@agentforce.com`

2. **Navigate to Apex Classes**:
   - Setup → Apex Classes → New

3. **Create MealPlanTodayAPI**:
   - Copy the code from: `force-app/main/default/classes/MealPlanTodayAPI.cls`
   - Paste into the Apex Class editor
   - Click "Save"

4. **Test the API**:
   - Setup → Apex Classes → MealPlanTodayAPI → Execute Anonymous
   - Test with: `RestRequest req = new RestRequest(); RestContext.request = req; MealPlanTodayAPI.getTodaysMeals();`

---

### Step 2: Get Your Salesforce Access Token

1. **Open Developer Console**:
   - Gear icon → Developer Console

2. **Execute Anonymous Apex**:
   ```apex
   System.debug('Session ID: ' + UserInfo.getSessionId());
   System.debug('Instance URL: ' + URL.getSalesforceBaseUrl().toExternalForm());
   ```

3. **Copy the Output**:
   - Session ID: This is your access token
   - Instance URL: Your Salesforce org URL

4. **Save These Values**:
   - You'll need them for the PWA configuration

---

### Step 3: Configure the PWA

The PWA Meals tab currently has placeholder meal tracking. To connect it to Salesforce:

1. **Open the PWA** index.html
2. **Find the Meals Tab Section** (around line 1260)
3. **Add Salesforce Configuration**:

```javascript
// Salesforce Configuration
const SF_CONFIG = {
    instanceUrl: 'YOUR_INSTANCE_URL_HERE', // e.g., https://orgfarm-d7ac6d4026-dev-ed.develop.my.salesforce.com
    accessToken: 'YOUR_ACCESS_TOKEN_HERE',  // From Step 2
    apiVersion: 'v65.0'
};

// Function to fetch today's meals from Salesforce
async function fetchTodaysMeals() {
    try {
        const response = await fetch(`${SF_CONFIG.instanceUrl}/services/apexrest/mealplan/today`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${SF_CONFIG.accessToken}`,
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();

        if (data.success) {
            displayMeals(data.meals);
        } else {
            console.error('API Error:', data.errorMessage);
        }
    } catch (error) {
        console.error('Fetch Error:', error);
    }
}

// Function to display meals in the UI
function displayMeals(meals) {
    const breakfastDiv = document.getElementById('breakfastHistory');
    const lunchDiv = document.getElementById('lunchHistory');
    const dinnerDiv = document.getElementById('dinnerHistory');

    // Clear existing content
    breakfastDiv.innerHTML = '';
    lunchDiv.innerHTML = '';
    dinnerDiv.innerHTML = '';

    meals.forEach(meal => {
        const mealCard = `
            <div class="meal-history-item" style="padding: 0.5rem; margin: 0.5rem 0; background: #f5f5f5; border-radius: 8px;">
                <div style="font-weight: 600;">${meal.name}</div>
                <div style="font-size: 0.85rem; color: #666;">
                    ⏱️ ${meal.cookTimeMinutes} min |
                    🧂 ${meal.sodiumMg}mg sodium |
                    💪 ${meal.proteinG}g protein
                </div>
                ${meal.isCompleted ? '<span style="color: green;">✓ Completed</span>' : '<button onclick="markMealComplete(\'' + meal.plannedMealId + '\')">Mark Complete</button>'}
            </div>
        `;

        if (meal.mealType === 'Breakfast') {
            breakfastDiv.innerHTML += mealCard;
        } else if (meal.mealType === 'Lunch') {
            lunchDiv.innerHTML += mealCard;
        } else if (meal.mealType === 'Dinner') {
            dinnerDiv.innerHTML += mealCard;
        }
    });
}

// Load meals when Meals tab is opened
function switchTab(tabName) {
    // ... existing code ...

    if (tabName === 'meals') {
        fetchTodaysMeals();
    }
}
```

---

### Step 4: Create Sample Data in Salesforce

1. **Create a Meal Record**:
   ```
   Setup → Object Manager → Meal → New
   - Name: Grilled Chicken with Vegetables
   - Meal Type: Dinner
   - Cook Time: 30 minutes
   - Sodium: 450mg
   - Protein: 35g
   - Fiber: 8g
   - Heart Healthy: ✓
   - Diabetic Friendly: ✓
   - Recipe Content: "Season chicken breast with herbs. Grill for 6-7 minutes per side..."
   ```

2. **Create a Weekly Meal Plan**:
   ```
   Setup → Object Manager → Weekly Meal Plan → New
   - Week Start Date: [Today's date - day of week]
   - Week End Date: [Week start + 6 days]
   ```

3. **Create a Planned Meal**:
   ```
   Setup → Object Manager → Planned Meal → New
   - Weekly Meal Plan: [Select the plan you just created]
   - Meal: [Select the meal you just created]
   - Meal Date: [Today's date]
   - Day of Week: [Today's day]
   - Completed: ☐
   ```

4. **Create a Shopping List**:
   ```
   Setup → Object Manager → Shopping List → New
   - Weekly Meal Plan: [Your weekly plan]
   - Store: Publix
   - Total Estimated Cost: $125.00
   - Coupons Available: "• BOGO Chicken Breast\n• $1 off mixed vegetables"
   ```

---

### Step 5: Test the Integration

1. **Open the PWA**: https://abbyluggery.github.io/Full-ND-app-build/

2. **Navigate to Meals Tab**

3. **Verify**:
   - Today's meals should load from Salesforce
   - Meal details should display (name, cook time, nutrition)
   - "Mark Complete" button should work

---

## Troubleshooting

### Issue: "401 Unauthorized" Error

**Cause**: Access token expired

**Solution**:
1. Get a new session ID from Developer Console
2. Update `SF_CONFIG.accessToken` in the PWA
3. Refresh the page

### Issue: "No meals found"

**Cause**: No Planned_Meal__c records for today

**Solution**:
1. Check the Meal_Date__c field on your Planned_Meal__c records
2. Ensure it matches today's date
3. Create a new Planned_Meal__c record for today

### Issue: CORS Error

**Cause**: Salesforce blocking requests from GitHub Pages

**Solution**:
1. Setup → CORS → New
2. Origin URL Pattern: `https://abbyluggery.github.io`
3. Save

---

## Next Steps (Future Enhancements)

1. **Implement OAuth 2.0**: Replace session ID with proper OAuth flow
2. **Add Shopping List View**: Display coupons and items
3. **Sync Offline**: Use Service Worker to cache meal data
4. **Add Meal Prep Timer**: Countdown timers for cooking
5. **Nutrition Dashboard**: Weekly nutrition tracking

---

## Files Modified

### Salesforce (Desktop):
- `force-app/main/default/objects/Meal__c/` - Meal object
- `force-app/main/default/objects/Weekly_Meal_Plan__c/` - Weekly plan
- `force-app/main/default/objects/Planned_Meal__c/` - Planned meals
- `force-app/main/default/objects/Shopping_List__c/` - Shopping lists
- `force-app/main/default/classes/MealPlanTodayAPI.cls` - REST API

### PWA (GitHub Pages):
- `index.html` - Updated with all fixes
- Deployed to: https://abbyluggery.github.io/Full-ND-app-build/

---

## Support

If you encounter issues:
1. Check Salesforce debug logs (Setup → Debug Logs)
2. Check browser console for JavaScript errors
3. Verify your access token is current
4. Ensure CORS is configured properly

---

**Created**: November 5, 2025
**Status**: Data model deployed ✅ | API pending manual deployment ⏳ | PWA ready for configuration ⏳

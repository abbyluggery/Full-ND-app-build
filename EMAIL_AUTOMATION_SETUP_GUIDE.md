# Email Automation Setup Guide

## Overview
This guide shows how to set up 3 automated email notifications for your Meal Planning system:
1. **Weekly Meal Plan Summary** - Sent when a new meal plan is created
2. **High-Value Coupon Alert** - Sent when shopping lists have significant savings
3. **Shopping List Ready** - Sent when a new shopping list is created

## Prerequisites
- Email templates have been deployed to Salesforce (folder: Meal Planning Templates)
- You have access to Flow Builder in Salesforce

---

## Flow 1: Send Meal Plan Email

### Purpose
Automatically send an email summary when a new Weekly Meal Plan is created.

### Setup Steps

1. **Navigate to Setup** → Search for "Flows" → Click **New Flow**

2. **Select Flow Type**: Record-Triggered Flow → Click **Create**

3. **Configure Start Element**:
   - Object: `Weekly_Meal_Plan__c`
   - Trigger: `A record is created`
   - Entry Conditions: None needed (all new plans)
   - Optimize for: `Actions and Related Records`
   - Click **Done**

4. **Add Send Email Action**:
   - Click **+** → **Action** → Search "Send Email"
   - Select **Send Email** (standard action)

5. **Configure Email Action**:
   - **Label**: Send Meal Plan Summary Email
   - **Email Addresses**: `{!$User.Email}` (or use a specific email field)
   - **Subject**:
     ```
     Your Meal Plan is Ready for {!$Record.Week_Start_Date__c}
     ```
   - **Body** (Plain Text):
     ```
     Your Meal Plan for {!$Record.Week_Start_Date__c} - {!$Record.Week_End_Date__c}

     Hello!

     Your meal plan "{!$Record.Plan_Name__c}" is ready with {!$Record.Number_of_People__c} servings per meal.

     WEEK AT A GLANCE
     ========================================

     Shopping Lists Created: Yes
     Total Estimated Cost: ${!$Record.Budget_Target__c}
     Matched Coupons: Check your shopping lists for savings!

     NEXT STEPS
     ========================================

     1. Review your shopping lists by store
     2. Clip any digital coupons before shopping
     3. Check off items as you shop
     4. Track actual costs for budget insights

     Happy meal planning!
     ```
   - Click **Done**

6. **Save the Flow**:
   - **Flow Label**: Send Meal Plan Email
   - **Flow API Name**: Send_Meal_Plan_Email
   - **Description**: Sends weekly meal plan summary email when a new meal plan is created
   - Click **Save**

7. **Activate the Flow**: Click **Activate**

---

## Flow 2: Send High Value Coupon Alert

### Purpose
Send an alert when a shopping list has high-value coupon matches ($3+ savings OR 5+ coupons).

### Setup Steps

1. **Navigate to Setup** → Search for "Flows" → Click **New Flow**

2. **Select Flow Type**: Record-Triggered Flow → Click **Create**

3. **Configure Start Element**:
   - Object: `Shopping_List__c`
   - Trigger: `A record is created or updated`
   - Entry Conditions: **All Conditions Are Met (AND)**
     - `Savings_Amount__c` Greater Than or Equal To `3`
     - OR Logic: `Coupons_Applied_Count__c` Greater Than or Equal To `5`
   - Condition Requirements: `Any Condition Is Met (OR)`
   - Optimize for: `Actions and Related Records`
   - Click **Done**

4. **Add Send Email Action**:
   - Click **+** → **Action** → Search "Send Email"
   - Select **Send Email** (standard action)

5. **Configure Email Action**:
   - **Label**: Send Coupon Alert Email
   - **Email Addresses**: `{!$User.Email}`
   - **Subject**:
     ```
     💰 ${!$Record.Savings_Amount__c} in Coupons Match Your {!$Record.Store_Location__c} List!
     ```
   - **Body** (Plain Text):
     ```
     GREAT SAVINGS ALERT! High-Value Coupons Match Your Shopping List
     ========================================

     Hello!

     We found {!$Record.Coupons_Applied_Count__c} valuable coupons that match items on your shopping list for {!$Record.Store_Location__c}.

     POTENTIAL SAVINGS
     ========================================

     Total Estimated Savings: ${!$Record.Savings_Amount__c}
     Shopping List Total: ${!$Record.Estimated_Cost__c}

     Your matched coupons include high-value offers that could save you significant money on this shopping trip.

     WHAT TO DO NOW
     ========================================

     1. Open your shopping list in Salesforce
     2. Review all matched coupons before they expire
     3. Clip digital coupons to your store loyalty card
     4. Print any paper coupons you need
     5. Check expiration dates - some coupons may expire soon!

     TIPS FOR MAXIMUM SAVINGS
     ========================================

     - Stack manufacturer coupons with store sales when possible
     - Check if your store doubles coupons
     - Watch for BOGO (Buy One Get One) opportunities
     - Consider buying extra of non-perishables with great deals

     Happy saving!
     ```
   - Click **Done**

6. **Save the Flow**:
   - **Flow Label**: Send High Value Coupon Alert
   - **Flow API Name**: Send_High_Value_Coupon_Alert
   - **Description**: Sends email alert when shopping list has high-value matched coupons ($3+ savings or 5+ coupons)
   - Click **Save**

7. **Activate the Flow**: Click **Activate**

---

## Flow 3: Send Shopping List Ready Email

### Purpose
Send a notification when a new shopping list is created and ready to use.

### Setup Steps

1. **Navigate to Setup** → Search for "Flows" → Click **New Flow**

2. **Select Flow Type**: Record-Triggered Flow → Click **Create**

3. **Configure Start Element**:
   - Object: `Shopping_List__c`
   - Trigger: `A record is created`
   - Entry Conditions: **All Conditions Are Met (AND)**
     - `Status__c` Equals `Active`
   - Optimize for: `Actions and Related Records`
   - Click **Done**

4. **Add Send Email Action**:
   - Click **+** → **Action** → Search "Send Email"
   - Select **Send Email** (standard action)

5. **Configure Email Action**:
   - **Label**: Send Shopping List Email
   - **Email Addresses**: `{!$User.Email}`
   - **Subject**:
     ```
     Your {!$Record.Store_Location__c} Shopping List is Ready - ${!$Record.Estimated_Cost__c}
     ```
   - **Body** (Plain Text):
     ```
     Your Shopping List is Ready for {!$Record.Store_Location__c}
     ========================================

     Hello!

     Your shopping list for {!$Record.Store_Location__c} has been generated and is ready to use.

     SHOPPING LIST SUMMARY
     ========================================

     Store: {!$Record.Store_Location__c}
     Shopping Date: {!$Record.Shopping_Date__c}
     Status: {!$Record.Status__c}

     Estimated Cost: ${!$Record.Estimated_Cost__c}
     Coupons Matched: {!$Record.Coupons_Applied_Count__c}
     Potential Savings: ${!$Record.Savings_Amount__c}

     BEFORE YOU SHOP
     ========================================

     ✓ Review your list and check off any items you already have
     ✓ Clip all matched digital coupons to your loyalty card
     ✓ Print any paper coupons needed
     ✓ Check store hours and plan your shopping time
     ✓ Bring reusable bags

     MONEY-SAVING TIPS
     ========================================

     • Shop the perimeter first for fresh items
     • Compare unit prices, not just package prices
     • Check expiration dates on sale items
     • Consider store brands for additional savings
     • Use your store's app for additional digital-only deals

     AFTER SHOPPING
     ========================================

     Don't forget to update your shopping list in Salesforce with:
     - Actual costs paid (helps with budgeting)
     - Mark items as purchased
     - Track your actual savings

     Happy shopping!
     ```
   - Click **Done**

6. **Save the Flow**:
   - **Flow Label**: Send Shopping List Ready Email
   - **Flow API Name**: Send_Shopping_List_Ready_Email
   - **Description**: Sends email notification when a new shopping list is created with Active status
   - Click **Save**

7. **Activate the Flow**: Click **Activate**

---

## Testing Your Flows

### Test Flow 1 (Meal Plan Email)
1. Navigate to **Weekly Meal Plans** tab
2. Click **New**
3. Fill in required fields and click **Save**
4. Check your email inbox for the meal plan summary

### Test Flow 2 (Coupon Alert)
1. Create or update a Shopping List with:
   - `Savings_Amount__c` = $5.00 (or any amount ≥ $3)
   - OR `Coupons_Applied_Count__c` = 5 or more
2. Save the record
3. Check your email for the coupon alert

### Test Flow 3 (Shopping List Ready)
1. Create a new Shopping List
2. Set `Status__c` = Active
3. Click **Save**
4. Check your email for the shopping list ready notification

---

## Troubleshooting

### Emails Not Sending

1. **Check Flow Activation**: Setup → Flows → Verify flows are "Active"
2. **Check User Email**: Ensure `{!$User.Email}` is valid in your user record
3. **Check Email Deliverability**: Setup → Deliverability → Ensure "Access level" is not "No access"
4. **Check Flow Debug Logs**: Setup → Debug Logs → Create debug log for your user → Test flow → Review logs

### Wrong Email Address

- To send to a specific email instead of current user:
  - Replace `{!$User.Email}` with a specific email address (e.g., `your.email@example.com`)
  - Or add an Email field to your objects and reference it: `{!$Record.Contact_Email__c}`

### Duplicate Emails

- Check if multiple flows are active for the same trigger
- Review flow entry conditions to ensure they don't overlap

---

## Time Estimate

- **Flow 1**: ~10 minutes
- **Flow 2**: ~15 minutes (includes OR logic setup)
- **Flow 3**: ~10 minutes
- **Testing**: ~10 minutes
- **Total**: ~45 minutes

---

## Summary

Once all three flows are set up and activated, your meal planning system will automatically:

✅ **Notify you** when a new meal plan is ready
✅ **Alert you** when high-value coupons match your shopping list
✅ **Remind you** when shopping lists are ready to use

This automation ensures you never miss savings opportunities and stay on top of your meal planning!
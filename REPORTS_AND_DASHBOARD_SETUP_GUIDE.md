# Meal Planning Reports & Dashboard Setup Guide

## Overview
The report XML files have configuration issues that prevent automated deployment. Follow this guide to create the reports manually in Salesforce.

## Step 1: Create Report Folder

1. Go to **Reports** tab in Salesforce
2. Click **New Folder**
3. Name: `Meal Planning Reports`
4. Access: Public Read/Write
5. Click **Save**

## Step 2: Create Reports Manually

### Report 1: Weekly Savings Tracker

**Create Report:**
1. Click **New Report**
2. Report Type: **Shopping Lists**
3. Click **Create**

**Configure Columns:**
- Shopping List Name
- Store
- Shopping Date
- Status
- Estimated Cost
- Actual Cost
- Savings Amount
- Coupons Applied Count

**Group By:**
- First Grouping: Shopping Date (by Week)
- Second Grouping: Store

**Chart:**
- Type: Vertical Bar
- Y-Axis: SUM of Savings Amount
- X-Axis: Store

**Filters:**
- Shopping Date = Last 30 Days

**Save As:** `Weekly Savings Tracker` in Meal Planning Reports folder

---

### Report 2: Most Cost-Effective Meals

**Create Report:**
1. Click **New Report**
2. Report Type: **Meals with Ingredients**
3. Click **Create**

**Configure Columns:**
- Meal Name
- Protein Type
- Servings
- Prep Time (Minutes)
- Total Time (Minutes)
- Calories
- Protein (g)
- Difficulty
- Is Weeknight Friendly

**Group By:**
- Protein Type

**Sort:**
- Total Time (ascending)

**Save As:** `Most Cost-Effective Meals` in Meal Planning Reports folder

---

### Report 3: Coupon Match Summary

**Create Report:**
1. Click **New Report**
2. Report Type: **Shopping List Items**
3. Click **Create**

**Configure Columns:**
- Item Name
- Store
- Quantity
- Estimated Price
- Coupon Discount
- Matched Coupon Name
- Discount Type
- Coupon Valid To

**Group By:**
- First Grouping: Store
- Second Grouping: Discount Type (from Matched Coupon)

**Filters:**
- Coupon Available = TRUE
- Created Date = Last 30 Days

**Chart:**
- Type: Horizontal Bar
- Y-Axis: SUM of Coupon Discount
- X-Axis: Discount Type

**Summary Fields:**
- SUM(Coupon Discount) - label as "Total Savings"
- Record Count - label as "Items with Coupons"

**Save As:** `Coupon Match Summary` in Meal Planning Reports folder

---

### Report 4: Monthly Grocery Spending

**Create Report:**
1. Click **New Report**
2. Report Type: **Shopping Lists**
3. Click **Create**

**Configure as Matrix Report:**
1. Click **Format** → Select **Matrix**
2. Rows: Store (Publix, Walmart, Costco)
3. Columns: Shopping Date (grouped by Month)
4. Values:
   - SUM(Actual Cost) - label as "Total Spent"
   - SUM(Savings Amount) - label as "Total Savings"

**Columns to Show:**
- Shopping List Name
- Store
- Status
- Estimated Cost
- Actual Cost
- Savings Amount

**Chart:**
- Type: Stacked Vertical Column
- Y-Axis: Total Spent, Total Savings
- X-Axis: Month
- Group By: Store

**Filters:**
- Shopping Date = Last 6 Months

**Save As:** `Monthly Grocery Spending` in Meal Planning Reports folder

---

### Report 5: Recipe Usage and Variety

**Create Report:**
1. Click **New Report**
2. Report Type: **Planned Meals**
3. Click **Create**

**Configure Columns:**
- Meal Name
- Protein Type (from Meal)
- Meal Date
- Total Time (from Meal)
- Difficulty (from Meal)
- Is Weeknight Friendly (from Meal)
- Last Used Date (from Meal)

**Group By:**
- First Grouping: Protein Type
- Second Grouping: Meal Name

**Summary Fields:**
- Record Count - label as "Times Used"

**Chart:**
- Type: Donut
- Values: Record Count
- Slices: Protein Type
- Show Percentage: TRUE

**Filters:**
- Meal Date = Last 90 Days

**Sort:**
- Times Used (descending)

**Save As:** `Recipe Usage and Variety` in Meal Planning Reports folder

---

## Step 3: Create Dashboard

### Dashboard: Weekly Meal Planning Overview

1. Go to **Dashboards** tab
2. Click **New Dashboard**
3. Name: `Weekly Meal Planning Overview`
4. Folder: Create new folder called "Meal Planning Dashboards" (Public)
5. Click **Create**

### Add Components:

#### Component 1: This Week's Savings (Metric)
- Source Report: Weekly Savings Tracker
- Component Type: Metric
- Display: SUM of Savings Amount
- Title: "This Week's Savings"
- Subtitle: "From matched coupons"

#### Component 2: Savings by Store (Donut Chart)
- Source Report: Weekly Savings Tracker
- Component Type: Donut Chart
- Values: SUM of Savings Amount
- Wedges: Store
- Title: "Savings by Store"

#### Component 3: Top 5 Cost-Effective Meals (Table)
- Source Report: Most Cost-Effective Meals
- Component Type: Table
- Columns: Meal Name, Total Time, Protein Type
- Max Rows: 5
- Title: "Quickest Meals"

#### Component 4: Monthly Spending Trend (Line Chart)
- Source Report: Monthly Grocery Spending
- Component Type: Line Chart
- Y-Axis: Total Spent
- X-Axis: Month
- Title: "Monthly Spending Trend"

#### Component 5: Active Coupon Matches (Metric)
- Source Report: Coupon Match Summary
- Component Type: Metric
- Display: Record Count
- Title: "Active Coupon Matches"
- Subtitle: "Items with savings"

#### Component 6: Recipe Variety (Donut Chart)
- Source Report: Recipe Usage and Variety
- Component Type: Donut Chart
- Values: Record Count (Times Used)
- Wedges: Protein Type
- Title: "Recipe Variety"

### Dashboard Filters:
1. Click **Add Filter**
2. Add: Date Range (This Week, Last Week, This Month, Custom)
3. Add: Store (All, Publix, Walmart, Costco)

### Save Dashboard

---

## Step 4: Verify Reports & Dashboard

### Test Reports:
1. Go to **Reports** tab
2. Navigate to **Meal Planning Reports** folder
3. Open each report
4. Click **Run Report**
5. Verify data displays correctly

### Test Dashboard:
1. Go to **Dashboards** tab
2. Open **Weekly Meal Planning Overview**
3. Verify all 6 components load
4. Test filters (date range, store)
5. Verify charts display data

---

## Next Steps

After reports and dashboard are created:
1. Create email templates (see EMAIL_TEMPLATES_SETUP_GUIDE.md)
2. Build automation flows (see AUTOMATION_FLOWS_GUIDE.md)
3. Test end-to-end workflow

---

## Troubleshooting

**No Data in Reports:**
- Ensure you have Shopping Lists created with Status = "Completed"
- Ensure Actual Cost and Savings Amount fields are populated
- Check date filters match your data dates

**Chart Not Showing:**
- Verify groupings are correct
- Check that summary fields are added (SUM, COUNT, etc.)
- Ensure chart type is appropriate for data

**Dashboard Components Empty:**
- Refresh dashboard (click refresh icon)
- Verify source reports have data
- Check dashboard filters aren't excluding all data

---

## Time Estimate

- Creating 5 reports manually: **30-40 minutes**
- Creating dashboard with 6 components: **15-20 minutes**
- Testing and refinement: **10 minutes**

**Total: ~1 hour**

---

## Alternative: Quick Start

If you want to start with just the essentials:

1. Create **Weekly Savings Tracker** report (most important)
2. Create **Coupon Match Summary** report
3. Create simple dashboard with just these 2 reports

This gives you immediate visibility into savings and coupon matches in ~20 minutes.

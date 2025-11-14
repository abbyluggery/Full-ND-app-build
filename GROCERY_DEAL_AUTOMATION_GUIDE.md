# Grocery Deal Automation Setup Guide

Complete guide for automating weekly grocery deal imports from Publix, Walmart, and other stores into your Salesforce meal planning system.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Setup Instructions](#setup-instructions)
4. [Weekly Workflow](#weekly-workflow)
5. [Troubleshooting](#troubleshooting)
6. [Advanced Configuration](#advanced-configuration)

---

## Overview

This automation system extracts grocery deals from multiple sources and imports them into your Salesforce `Store_Coupon__c` object:

- **Publix:** Email-based extraction from shopping list emails
- **Walmart, Kroger, Target:** Web scraping from Southern Savers coupon matchups
- **Costco:** Manual PDF entry (recommended until Instacart API access secured)

**Time Savings:**
- Before: 3 hours/week (manual entry)
- After: 1 hour/week (automated + review)
- **67% time reduction**

---

## Prerequisites

### 1. Python Environment

Install Python 3.8 or later: [python.org/downloads](https://www.python.org/downloads/)

### 2. Required Python Libraries

Open Command Prompt or PowerShell and run:

```bash
pip install beautifulsoup4 pandas requests python-dateutil fuzzywuzzy python-Levenshtein
```

**Library purposes:**
- `beautifulsoup4` - HTML parsing
- `pandas` - Data manipulation and CSV export
- `requests` - Web scraping
- `python-dateutil` - Date handling
- `fuzzywuzzy` - Fuzzy string matching to your ingredient database
- `python-Levenshtein` - Faster fuzzy matching (optional but recommended)

### 3. Gmail App Password (for Publix Email Parser)

**Steps:**

1. Go to your Google Account: [myaccount.google.com](https://myaccount.google.com)
2. Navigate to **Security** → **2-Step Verification** (enable if not already)
3. Scroll down to **App Passwords**: [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
4. Select app: **Mail**
5. Select device: **Windows Computer** (or your device)
6. Click **Generate**
7. Copy the 16-character password (e.g., `abcd efgh ijkl mnop`)
8. Save this password - you'll use it in the script configuration

**Security Note:** App Passwords allow apps to access your Gmail without your main password. Keep this password secure and never share it.

### 4. Publix Club Account

1. Sign up at [publix.com](https://www.publix.com/)
2. Download Publix app (iOS/Android)
3. Verify you can email shopping lists from the app

### 5. Salesforce Access

- Data Loader installed: [developer.salesforce.com/tools/salesforcedx/en/sfdx_dataloader](https://developer.salesforce.com/tools/salesforcedx/en/sfdx_dataloader)
- OR Salesforce Workbench access: [workbench.developerforce.com](https://workbench.developerforce.com/)

---

## Setup Instructions

### Part 1: Publix Email Parser Configuration

1. **Open the script:**
   ```
   scripts/publix_email_parser.py
   ```

2. **Update credentials (lines 25-26):**
   ```python
   GMAIL_USER = "your-email@gmail.com"  # Your Gmail address
   GMAIL_APP_PASSWORD = "abcd efgh ijkl mnop"  # Your 16-char App Password
   ```

3. **Test the setup:**
   ```bash
   # First, send yourself a shopping list from Publix app
   # Then run the script
   cd "C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant"
   python scripts/publix_email_parser.py
   ```

4. **Expected output:**
   ```
   Connecting to Gmail for your-email@gmail.com...
   ✅ Connected successfully!
   ✅ Found 1 Publix email(s)
   ✅ Extracted 15 items
   ✅ Saved 15 coupons to: data/publix_deals_2025-11-09.csv
   ```

5. **If it fails:**
   - Check `debug_email.html` (created automatically)
   - Open in browser to see email structure
   - Update `extract_items_from_html()` function with correct CSS selectors

### Part 2: Southern Savers Scraper Configuration

1. **Create ingredient reference file:**
   ```bash
   # Export your ingredients from Salesforce to CSV
   # Save as: data/ingredient_reference.csv
   # Required column: Ingredient_Name__c (your 1,111 ingredients)
   ```

2. **Test the scraper:**
   ```bash
   # Scrape Publix deals
   python scripts/southern_savers_scraper.py --store publix

   # Scrape Walmart deals
   python scripts/southern_savers_scraper.py --store walmart

   # Scrape all stores
   python scripts/southern_savers_scraper.py --all
   ```

3. **Expected output:**
   ```
   Fetching publix deals from: https://www.southernsavers.com/publix-coupon-matchups/
   ✅ Successfully fetched page
   ✅ Parsed 45 deals
   ✅ Saved 45 coupons to: data/southern_savers_deals_publix_2025-11-09.csv

   Deal Summary:
     BOGO deals: 12
     Fixed Price: 20
     Percentage Off: 8
     Dollar Amount Off: 5
     Matched to ingredients: 32/45 (71.1%)
   ```

4. **If it fails:**
   - Check `debug_southern_savers_publix.html`
   - Update CSS selectors in `parse_southern_savers_page()`
   - Verify Southern Savers URL is still valid

### Part 3: Salesforce Data Loader Setup

1. **Download Data Loader:** [Salesforce Data Loader](https://developer.salesforce.com/tools/salesforcedx/en/sfdx_dataloader)

2. **Configure connection:**
   - Username: `abbyluggery179@agentforce.com`
   - Password: [Your password] + [Security Token]
   - Server URL: `https://login.salesforce.com`

3. **Create import mapping:**
   - Object: `Store_Coupon__c`
   - Operation: **Upsert** (prevents duplicates)
   - External ID: `Item_Name__c` + `Store__c` (composite key)

4. **CSV field mapping:**
   ```
   CSV Column              → Salesforce Field
   Store__c                → Store__c
   Item_Name__c            → Item_Name__c
   Discount_Type__c        → Discount_Type__c
   Discount_Value__c       → Discount_Value__c
   Valid_From__c           → Valid_From__c
   Valid_To__c             → Valid_To__c
   Source__c               → Source__c
   Source_URL__c           → Source_URL__c (if exists)
   API_Source__c           → API_Source__c (if exists)
   Last_Synced__c          → Last_Synced__c (if exists)
   Requires_Clipping__c    → Requires_Clipping__c
   Notes__c                → Notes__c
   ```

5. **Save mapping file:**
   - Save as: `salesforce_mappings/store_coupon_upsert.sdl`
   - Reuse for weekly imports

---

## Weekly Workflow

### Sunday Morning Routine (60 minutes total)

#### Step 1: Publix Email Deals (15 min)

1. **Open Publix app** on your phone
2. **Add this week's sale items to shopping list:**
   - Browse weekly ad (BOGO deals, featured items)
   - Tap items you use regularly
   - Add 15-30 items to list
3. **Email list to yourself:**
   - Tap "Share" or "Email List"
   - Send to your Gmail address
4. **Run parser script:**
   ```bash
   cd "C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant"
   python scripts/publix_email_parser.py
   ```
5. **Review CSV:**
   - Open `data/publix_deals_YYYY-MM-DD.csv`
   - Verify item names and prices
   - Correct any parsing errors
6. **Import to Salesforce:**
   - Data Loader → Upsert → `Store_Coupon__c`
   - Use saved mapping file
   - Run import

#### Step 2: Southern Savers Scraping (20 min)

1. **Run scraper for all stores:**
   ```bash
   python scripts/southern_savers_scraper.py --all
   ```

2. **Review generated CSVs:**
   - `data/southern_savers_deals_publix_YYYY-MM-DD.csv`
   - `data/southern_savers_deals_walmart_YYYY-MM-DD.csv`
   - `data/southern_savers_deals_kroger_YYYY-MM-DD.csv`

3. **Check ingredient matching:**
   - Look at `Matched_Ingredient__c` column
   - Items with matches will auto-integrate with meal plans
   - Manually match unmatched items if desired

4. **Import to Salesforce:**
   - Data Loader → Upsert → `Store_Coupon__c`
   - Import each CSV
   - Duplicates will be updated (not re-created)

#### Step 3: Costco Manual Entry (25 min)

1. **Download Costco warehouse savings PDF:**
   - Visit [costco.com/warehouse-savings](https://www.costco.com/warehouse-savings.html)
   - Print → Save as PDF
   - Save as: `costco_weekly_savings_YYYY-MM-DD.pdf`

2. **Review PDF and extract deals:**
   - Open PDF
   - Create CSV with template (see below)
   - Enter 10-15 high-value items (focus on proteins, bulk staples)

3. **CSV template:**
   ```csv
   Store__c,Item_Name__c,Discount_Type__c,Discount_Value__c,Valid_From__c,Valid_To__c,Source__c
   Costco,Chicken Breast,Fixed Price,5.99,2025-11-09,2025-11-15,Costco Weekly Savings
   Costco,Ground Beef,Fixed Price,3.49,2025-11-09,2025-11-15,Costco Weekly Savings
   ```

4. **Import to Salesforce:**
   - Data Loader → Upsert → `Store_Coupon__c`

#### Step 4: Generate Meal Plan (Automatic)

Now when you run your meal plan generation:

1. ShoppingListGenerator will query `Store_Coupon__c` for active deals
2. Ingredients matching sale items will be routed to the cheapest store
3. Shopping list will show sale prices
4. Estimated budget will reflect savings

**No additional work needed!** The system automatically uses the deal data.

---

## Troubleshooting

### Publix Email Parser Issues

**Problem: "No Publix emails found"**

**Solutions:**
- Check Gmail folder (Promotions, Updates, Social tabs)
- Verify email is from `@publix.com` domain
- Update `PUBLIX_EMAIL_FROM` variable if sender changed
- Manually search Gmail for "publix shopping list"

**Problem: "No items extracted from email"**

**Solutions:**
1. Check `debug_email.html` created by script
2. Open in browser and inspect HTML structure
3. Update `extract_items_from_html()` function:
   ```python
   # Example: if items are in <div class="product-item">
   divs = soup.find_all('div', class_='product-item')
   for div in divs:
       item_name = div.find('span', class_='name').text
       # ...extract other fields
   ```

**Problem: "Authentication failed"**

**Solutions:**
- Verify Gmail App Password is correct (16 characters with spaces)
- Ensure 2-Step Verification is enabled
- Generate new App Password if old one expired
- Check for typos in `GMAIL_USER` email address

### Southern Savers Scraper Issues

**Problem: "No deals found for publix"**

**Solutions:**
1. Check `debug_southern_savers_publix.html`
2. Open in browser - does it show deals?
3. If yes, HTML structure changed:
   - Inspect page source in browser
   - Find CSS selectors for deal items
   - Update `parse_southern_savers_page()` function
4. If no, URL may have changed:
   - Visit southernsavers.com manually
   - Find correct URL for Publix matchups
   - Update `STORE_URLS` dictionary

**Problem: "Request timed out"**

**Solutions:**
- Check internet connection
- Southern Savers may be down temporarily (try again in 10 min)
- Increase timeout in `fetch_page()` function (line with `timeout=30`)
- Check if site is blocking automated requests (rare)

**Problem: "Low ingredient matching rate (<50%)"**

**Solutions:**
1. Verify `ingredient_reference.csv` exists and has correct column name
2. Check for spelling variations:
   - Deal: "Chick Breast" → Ingredient: "Chicken Breast"
   - Add normalization in `match_to_ingredient()` function
3. Lower `MIN_MATCH_SCORE` threshold (currently 80, try 70)
4. Manually review unmatched items and add to ingredient database

### Salesforce Import Issues

**Problem: "Required fields are missing"**

**Solutions:**
- Ensure CSV has all required fields: `Store__c`, `Item_Name__c`, `Valid_From__c`, `Valid_To__c`
- Check field API names match exactly (case-sensitive)
- Verify date format is YYYY-MM-DD

**Problem: "INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST"**

**Solutions:**
- Check `Discount_Type__c` values match picklist exactly
- Valid values: BOGO, Percentage, Dollar Amount, Fixed Price, Multi-Buy
- Update picklist values in Salesforce if needed

**Problem: "Duplicates being created"**

**Solutions:**
- Use **Upsert** operation (not Insert)
- Set External ID to composite key: `Item_Name__c` + `Store__c`
- OR create formula field for unique key

---

## Advanced Configuration

### Scheduling Automation (Windows Task Scheduler)

**Create batch file: `run_weekly_deals.bat`**

```batch
@echo off
cd "C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant"

echo Running Publix email parser...
python scripts/publix_email_parser.py

echo Running Southern Savers scraper...
python scripts/southern_savers_scraper.py --all

echo Done! Check data/ folder for CSV files.
pause
```

**Schedule in Windows Task Scheduler:**

1. Open Task Scheduler
2. Create Basic Task → "Weekly Deal Import"
3. Trigger: Weekly, Sunday at 8:00 AM
4. Action: Start a program → `run_weekly_deals.bat`
5. Save task

Now the scripts run automatically every Sunday morning!

### Fuzzy Matching Improvements

**Expand ingredient normalization:**

Add to `southern_savers_scraper.py`:

```python
# Before fuzzy matching, normalize item names
NORMALIZATIONS = {
    'chick breast': 'chicken breast',
    'grnd beef': 'ground beef',
    'ice crm': 'ice cream',
    # ...add more variations
}

def normalize_item_name(name):
    name_lower = name.lower()
    for variation, standard in NORMALIZATIONS.items():
        if variation in name_lower:
            return standard
    return name

# Use in match_to_ingredient()
normalized_name = normalize_item_name(item_name)
match = process.extractOne(normalized_name, ingredient_list, ...)
```

### Email Notifications

**Add email alerts when deals are imported:**

```python
import smtplib
from email.message import EmailMessage

def send_summary_email(deal_count):
    msg = EmailMessage()
    msg['Subject'] = f'{deal_count} grocery deals imported this week'
    msg['From'] = GMAIL_USER
    msg['To'] = GMAIL_USER
    msg.set_content(f'Successfully imported {deal_count} deals to Salesforce!')

    with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp:
        smtp.login(GMAIL_USER, GMAIL_APP_PASSWORD)
        smtp.send_message(msg)

# Call after CSV creation
send_summary_email(len(coupons))
```

### Walmart Invoice Exporter Integration

**Chrome Extension:** [Walmart Invoice Exporter](https://chrome.google.com/webstore/detail/walmart-invoice-exporter)

**Workflow:**

1. Install extension in Chrome
2. Visit Walmart.com → Order History
3. Click extension icon
4. Download orders as Excel
5. Convert to CSV format matching `Store_Coupon__c`
6. Use for post-purchase price verification

---

## Success Metrics

Track your automation success:

**Weekly Time Savings:**
- Manual entry time: 180 min
- Automated time: 60 min
- **Savings: 2 hours/week = 104 hours/year**

**Deal Volume:**
- Manual entry: ~30 deals/week
- Automated: ~100+ deals/week
- **3x more deal coverage**

**Cost Savings:**
- Estimated grocery savings: 15-20% with better deal visibility
- Family of 4 budget: $200/week
- **Potential savings: $30-40/week = $1,560-2,080/year**

**ROI:**
- Development time: 10-15 hours (one-time)
- Weekly time saved: 2 hours
- **Break-even: 5-7 weeks**

---

## Support & Updates

**Script Issues:**
- Check this guide first
- Inspect debug HTML files
- Update CSS selectors as needed

**Website Structure Changes:**
- Southern Savers and Publix may update their HTML periodically
- Keep backup of working selectors
- Test scripts weekly to catch breaking changes early

**Feature Requests:**
- Add new stores (Kroger, Target already supported)
- Integrate Instacart API when partnership secured
- Build LWC dashboard for deal visualization

---

## Next Steps

1. Complete setup (Prerequisites + Setup Instructions)
2. Test each script individually
3. Run first weekly workflow this Sunday
4. Review imported deals in Salesforce
5. Generate meal plan and verify deal integration
6. Track time savings and cost savings
7. Optimize fuzzy matching over 4-8 weeks
8. Consider scheduling automation

**Happy deal hunting! 🎉**

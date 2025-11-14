# Quick Start: Grocery Deal Automation

Get your grocery deal automation running in 30 minutes!

## Step 1: Install Python Libraries (5 min)

Open Command Prompt and run:

```bash
pip install beautifulsoup4 pandas requests python-dateutil fuzzywuzzy python-Levenshtein
```

## Step 2: Configure Publix Email Parser (10 min)

1. **Get Gmail App Password:**
   - Visit: https://myaccount.google.com/apppasswords
   - Enable 2-Step Verification if needed
   - Generate App Password for "Mail"
   - Copy the 16-character password

2. **Edit script:**
   - Open: `scripts/publix_email_parser.py`
   - Update lines 25-26:
     ```python
     GMAIL_USER = "YOUR_EMAIL@gmail.com"
     GMAIL_APP_PASSWORD = "xxxx xxxx xxxx xxxx"
     ```

3. **Send test email:**
   - Open Publix app on phone
   - Add a few items to shopping list
   - Email list to yourself

4. **Run parser:**
   ```bash
   cd "C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant"
   python scripts/publix_email_parser.py
   ```

5. **Check output:**
   - Look for: `data/publix_deals_2025-XX-XX.csv`
   - Review the CSV file

## Step 3: Test Southern Savers Scraper (5 min)

```bash
python scripts/southern_savers_scraper.py --store publix
```

**Expected:** CSV file created with ~30-50 deals

## Step 4: Import to Salesforce (10 min)

### Option A: Data Loader

1. Open Salesforce Data Loader
2. Select **Upsert** operation
3. Choose object: `Store_Coupon__c`
4. Select CSV file from `data/` folder
5. Map fields (most auto-map by name)
6. Run import

### Option B: Workbench

1. Visit: https://workbench.developerforce.com/
2. Login with your Salesforce credentials
3. Navigate to: **Insert** → **Store_Coupon__c**
4. Upload CSV file
5. Map fields and submit

## Step 5: Verify in Salesforce (2 min)

1. Open Salesforce
2. Go to **Store Coupons** tab
3. View recently created records
4. Check that:
   - Store names are correct (Publix, Walmart, etc.)
   - Prices and discount types look accurate
   - Valid dates are this week

## Success! 🎉

You now have automated grocery deal imports!

**Next Steps:**

- Read full documentation: `GROCERY_DEAL_AUTOMATION_GUIDE.md`
- Set up weekly workflow (Sunday mornings)
- Export your ingredient list to: `data/ingredient_reference.csv`
- Enable fuzzy matching for better integration

**Weekly Routine (60 min):**

1. Email Publix list → Run parser (15 min)
2. Run Southern Savers scraper (5 min)
3. Manual Costco entry (25 min)
4. Import all CSVs to Salesforce (15 min)

**Questions?** Check the troubleshooting section in the full guide.

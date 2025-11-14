"""
Southern Savers Coupon Matchup Web Scraper

Scrapes weekly grocery deals from SouthernSavers.com for Publix, Walmart, and other stores.
Extracts item names, prices, discount types, and expiration dates for import to Salesforce.

Prerequisites:
- Python libraries: pip install requests beautifulsoup4 pandas fuzzywuzzy python-Levenshtein

Usage:
python scripts/southern_savers_scraper.py --store publix
python scripts/southern_savers_scraper.py --store walmart
python scripts/southern_savers_scraper.py --all

Output:
- CSV file: data/southern_savers_deals_STORE_YYYY-MM-DD.csv
- Ready for Salesforce Data Loader import to Store_Coupon__c
"""

import requests
from bs4 import BeautifulSoup
import pandas as pd
from datetime import datetime, timedelta
import re
import argparse
import os
from fuzzywuzzy import fuzz, process
import time


# ==================== CONFIGURATION ====================

# Southern Savers URLs
# NOTE: Publix deals are now dynamically loaded via JavaScript widget - web scraping won't work
# Use Publix email parser instead (scripts/publix_email_parser.py)
STORE_URLS = {
    'publix': 'https://www.southernsavers.com/publix-weekly-ad-deals/',
    'walmart': 'https://www.southernsavers.com/walmart-coupon-matchups/',
    'kroger': 'https://www.southernsavers.com/kroger-coupon-matchups/',
    'target': 'https://www.southernsavers.com/target-coupon-matchups/'
}

# Request headers to avoid being blocked
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
    'Referer': 'https://www.southernsavers.com/',
    'DNT': '1',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1'
}

# Date configuration
VALID_FROM = datetime.now().strftime('%Y-%m-%d')
VALID_TO = (datetime.now() + timedelta(days=7)).strftime('%Y-%m-%d')

# Output configuration
OUTPUT_DIR = "data"
OUTPUT_FILE_PREFIX = "southern_savers_deals"

# Ingredient matching configuration
INGREDIENT_LIST_FILE = "data/ingredient_reference.csv"  # Your 1,111 ingredients
MIN_MATCH_SCORE = 80  # Fuzzy matching threshold (0-100)

# ==================== HELPER FUNCTIONS ====================

def load_ingredient_reference():
    """Load your 1,111 ingredient names for fuzzy matching."""
    try:
        if os.path.exists(INGREDIENT_LIST_FILE):
            df = pd.read_csv(INGREDIENT_LIST_FILE)
            # Assumes column is named 'Ingredient_Name__c' or 'Name'
            if 'Ingredient_Name__c' in df.columns:
                ingredients = df['Ingredient_Name__c'].tolist()
            elif 'Name' in df.columns:
                ingredients = df['Name'].tolist()
            else:
                ingredients = df.iloc[:, 0].tolist()  # Use first column

            print(f"Loaded {len(ingredients)} ingredient names for matching")
            return ingredients
        else:
            print(f"Ingredient reference file not found: {INGREDIENT_LIST_FILE}")
            print("   Fuzzy matching will be disabled")
            return None
    except Exception as e:
        print(f"Error loading ingredient reference: {e}")
        return None


def match_to_ingredient(item_name, ingredient_list, threshold=MIN_MATCH_SCORE):
    """
    Fuzzy match deal item name to your ingredient database.

    Returns:
        tuple: (matched_ingredient, confidence_score)
    """
    if not ingredient_list:
        return None, 0

    # Use fuzzywuzzy to find best match
    match = process.extractOne(item_name, ingredient_list, scorer=fuzz.token_sort_ratio)

    if match and match[1] >= threshold:
        return match[0], match[1]
    else:
        return None, match[1] if match else 0


def fetch_page(url, store_name):
    """Fetch webpage with error handling."""
    print(f"\nFetching {store_name} deals from: {url}")

    try:
        response = requests.get(url, headers=HEADERS, timeout=30)
        response.raise_for_status()

        print(f"Successfully fetched page (Status: {response.status_code})")
        return response.text

    except requests.exceptions.Timeout:
        print(f"Request timed out after 30 seconds")
        return None
    except requests.exceptions.HTTPError as e:
        print(f"HTTP Error: {e}")
        return None
    except requests.exceptions.RequestException as e:
        print(f"Error fetching page: {e}")
        return None


def parse_southern_savers_page(html_content, store_name):
    """
    Parse Southern Savers HTML to extract deal information.

    Note: HTML structure may vary. This is a template that may need adjustment
    based on actual page structure.
    """
    soup = BeautifulSoup(html_content, 'html.parser')

    deals = []

    # ========== APPROACH 1: Find deal cards/items ==========

    # Try common selectors for deal listings
    selectors_to_try = [
        ('div', {'class': lambda x: x and 'deal' in x.lower() if x else False}),
        ('div', {'class': lambda x: x and 'coupon' in x.lower() if x else False}),
        ('div', {'class': lambda x: x and 'matchup' in x.lower() if x else False}),
        ('article', {}),
        ('li', {'class': lambda x: x and 'product' in x.lower() if x else False}),
    ]

    deal_elements = []
    for tag, attrs in selectors_to_try:
        elements = soup.find_all(tag, attrs)
        if elements:
            deal_elements = elements
            print(f"Found {len(elements)} potential deals using <{tag}> selector")
            break

    if not deal_elements:
        print("No deal elements found with standard selectors")
        print("   Trying fallback: all list items and paragraphs")

        # Fallback: get all list items
        deal_elements = soup.find_all(['li', 'p'])

    # ========== APPROACH 2: Parse each deal element ==========

    for element in deal_elements:
        deal_text = element.get_text(separator=' ', strip=True)

        # Skip empty or very short text
        if len(deal_text) < 5:
            continue

        # Skip common non-deal text
        skip_keywords = ['unsubscribe', 'copyright', 'privacy policy', 'about us',
                        'follow us', 'advertisement', 'sponsored', 'click here']
        if any(keyword in deal_text.lower() for keyword in skip_keywords):
            continue

        # Extract deal information
        deal = parse_deal_text(deal_text, element)

        if deal:
            deal['Store__c'] = store_name.title()
            deals.append(deal)

    print(f"Parsed {len(deals)} deals")
    return deals


def parse_deal_text(text, element=None):
    """
    Parse deal text to extract structured information.

    Expected formats:
    - "Chicken Breast - $5.99"
    - "BOGO Free: Ice Cream"
    - "2 for $5: Frozen Pizza"
    - "$1 off any brand: Cereal"
    - "50% off: Yogurt"
    """

    deal = {
        'Item_Name__c': text,
        'Sale_Price__c': None,
        'Discount_Type__c': 'Fixed Price',  # Default to Fixed Price (valid picklist value)
        'Discount_Value__c': None,
        'Multi_Buy_Quantity__c': None,
        'Notes__c': f"Original: {text[:200]}"  # Truncate long text
    }

    # Detect BOGO
    bogo_pattern = r'\bBOGO\b|Buy One Get One|B1G1|buy 1 get 1'
    if re.search(bogo_pattern, text, re.IGNORECASE):
        deal['Discount_Type__c'] = 'BOGO'

        # Check if BOGO Free or BOGO 50%
        if re.search(r'BOGO\s*(Free|F)', text, re.IGNORECASE):
            deal['Discount_Value__c'] = 100  # 100% off second item
        elif re.search(r'BOGO\s*50%', text, re.IGNORECASE):
            deal['Discount_Value__c'] = 50

    # Detect Multi-Buy (e.g., "2 for $5", "5 for $10")
    multi_buy_match = re.search(r'(\d+)\s+for\s+\$(\d+\.?\d*)', text, re.IGNORECASE)
    if multi_buy_match:
        deal['Multi_Buy_Quantity__c'] = int(multi_buy_match.group(1))
        total_price = float(multi_buy_match.group(2))
        deal['Sale_Price__c'] = round(total_price / deal['Multi_Buy_Quantity__c'], 2)
        deal['Discount_Type__c'] = 'Multi-Buy'
        deal['Discount_Value__c'] = total_price

    # Detect percentage off (e.g., "50% off", "25% discount")
    percent_match = re.search(r'(\d+)%\s*(off|discount)', text, re.IGNORECASE)
    if percent_match:
        deal['Discount_Type__c'] = 'Percentage'
        deal['Discount_Value__c'] = float(percent_match.group(1))

    # Detect dollar amount off (e.g., "$1 off", "$2.50 discount")
    dollar_off_match = re.search(r'\$(\d+\.?\d*)\s*(off|discount)', text, re.IGNORECASE)
    if dollar_off_match:
        deal['Discount_Type__c'] = 'Dollar Amount'
        deal['Discount_Value__c'] = float(dollar_off_match.group(1))

    # Extract sale price (e.g., "$5.99")
    price_match = re.search(r'\$(\d+\.?\d*)', text)
    if price_match and not deal['Sale_Price__c']:  # Don't override multi-buy price
        deal['Sale_Price__c'] = float(price_match.group(1))
        # Type is already set to 'Fixed Price' by default

    # Clean up item name
    # Remove price from name
    if price_match:
        deal['Item_Name__c'] = text.replace(price_match.group(0), '').strip()

    # Remove discount text from name
    deal['Item_Name__c'] = re.sub(bogo_pattern, '', deal['Item_Name__c'], flags=re.IGNORECASE).strip()
    if percent_match:
        deal['Item_Name__c'] = deal['Item_Name__c'].replace(percent_match.group(0), '').strip()
    if dollar_off_match:
        deal['Item_Name__c'] = deal['Item_Name__c'].replace(dollar_off_match.group(0), '').strip()

    # Remove common separators
    deal['Item_Name__c'] = re.sub(r'\s*[-–—:]\s*', ' ', deal['Item_Name__c']).strip()

    # Remove extra whitespace
    deal['Item_Name__c'] = ' '.join(deal['Item_Name__c'].split())

    # Validate: must have item name
    if len(deal['Item_Name__c']) < 3:
        return None

    return deal


def create_salesforce_coupon_records(deals, ingredient_list=None):
    """Convert parsed deals to Salesforce Store_Coupon__c format with fuzzy matching."""

    coupons = []

    for deal in deals:
        # Attempt fuzzy matching to ingredient database
        matched_ingredient = None
        match_confidence = 0

        if ingredient_list:
            matched_ingredient, match_confidence = match_to_ingredient(
                deal['Item_Name__c'],
                ingredient_list
            )

        # Truncate item name to 120 characters max
        item_name = deal['Item_Name__c']
        if len(item_name) > 120:
            item_name = item_name[:117] + '...'

        coupon = {
            'Store__c': deal['Store__c'],
            'Item_Name__c': item_name,
            'Matched_Ingredient__c': matched_ingredient if match_confidence >= MIN_MATCH_SCORE else None,
            'Match_Confidence__c': match_confidence,
            'Discount_Type__c': deal['Discount_Type__c'],
            'Discount_Value__c': deal['Discount_Value__c'],
            'Multi_Buy_Quantity__c': deal.get('Multi_Buy_Quantity__c'),
            'Valid_From__c': VALID_FROM,
            'Valid_To__c': VALID_TO,
            'Source__c': 'Southern Savers',
            'Source_URL__c': STORE_URLS.get(deal['Store__c'].lower(), 'https://www.southernsavers.com'),
            'API_Source__c': 'southern_savers_scraper.py',
            'Last_Synced__c': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'Requires_Clipping__c': False,
            'Notes__c': deal['Notes__c']
        }

        coupons.append(coupon)

    return coupons


def save_to_csv(coupons, store_name, filename=None):
    """Save coupon data to CSV for Salesforce import."""

    if not coupons:
        print("No coupons to save")
        return None

    # Create output directory if it doesn't exist
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Generate filename
    if not filename:
        timestamp = datetime.now().strftime('%Y-%m-%d')
        filename = f"{OUTPUT_FILE_PREFIX}_{store_name.lower()}_{timestamp}.csv"

    filepath = os.path.join(OUTPUT_DIR, filename)

    # Create DataFrame
    df = pd.DataFrame(coupons)

    # Save to CSV
    df.to_csv(filepath, index=False)

    print(f"\nSaved {len(coupons)} coupons to: {filepath}")

    # Show summary stats
    print(f"\nDeal Summary:")
    print(f"  BOGO deals: {len(df[df['Discount_Type__c'] == 'BOGO'])}")
    print(f"  Fixed Price: {len(df[df['Discount_Type__c'] == 'Fixed Price'])}")
    print(f"  Percentage Off: {len(df[df['Discount_Type__c'] == 'Percentage'])}")
    print(f"  Dollar Amount Off: {len(df[df['Discount_Type__c'] == 'Dollar Amount'])}")
    print(f"  Multi-Buy: {len(df[df['Discount_Type__c'] == 'Multi-Buy'])}")

    if 'Matched_Ingredient__c' in df.columns:
        matched_count = df['Matched_Ingredient__c'].notna().sum()
        print(f"  Matched to ingredients: {matched_count}/{len(df)} ({matched_count/len(df)*100:.1f}%)")

    print(f"\nPreview (first 5 rows):")
    print(df[['Item_Name__c', 'Discount_Type__c', 'Discount_Value__c', 'Store__c']].head().to_string(index=False))

    return filepath


def scrape_store(store_name, ingredient_list=None):
    """Scrape deals for a specific store."""

    if store_name.lower() not in STORE_URLS:
        print(f"Unknown store: {store_name}")
        print(f"   Available stores: {', '.join(STORE_URLS.keys())}")
        return None

    url = STORE_URLS[store_name.lower()]

    # Fetch page
    html_content = fetch_page(url, store_name)
    if not html_content:
        return None

    # Parse deals
    deals = parse_southern_savers_page(html_content, store_name)

    if not deals:
        print(f"No deals found for {store_name}")
        print("\nDEBUG: Saving HTML to debug_southern_savers.html for inspection...")
        with open(f'debug_southern_savers_{store_name.lower()}.html', 'w', encoding='utf-8') as f:
            f.write(html_content)
        print(f"Please inspect debug file and update parse_southern_savers_page() selectors")
        return None

    # Create Salesforce records
    coupons = create_salesforce_coupon_records(deals, ingredient_list)

    # Save to CSV
    csv_file = save_to_csv(coupons, store_name)

    return csv_file


# ==================== MAIN FUNCTION ====================

def main():
    """Main execution function."""

    # Parse command-line arguments
    parser = argparse.ArgumentParser(description='Scrape Southern Savers coupon matchups')
    parser.add_argument('--store', type=str, help='Store to scrape (publix, walmart, kroger, target)')
    parser.add_argument('--all', action='store_true', help='Scrape all stores')
    args = parser.parse_args()

    print("=" * 60)
    print("Southern Savers Coupon Matchup Scraper")
    print("=" * 60)

    # Load ingredient reference for fuzzy matching
    ingredient_list = load_ingredient_reference()

    # Determine which stores to scrape
    stores_to_scrape = []

    if args.all:
        stores_to_scrape = list(STORE_URLS.keys())
    elif args.store:
        stores_to_scrape = [args.store.lower()]
    else:
        # Default: Publix and Walmart
        stores_to_scrape = ['publix', 'walmart']
        print("\nNo store specified. Defaulting to Publix and Walmart.")
        print("Use --store <name> or --all to change.\n")

    # Scrape each store
    csv_files = []

    for store in stores_to_scrape:
        print(f"\n{'=' * 60}")
        print(f"Scraping: {store.upper()}")
        print(f"{'=' * 60}")

        csv_file = scrape_store(store, ingredient_list)
        if csv_file:
            csv_files.append(csv_file)

        # Be polite - wait between requests
        if len(stores_to_scrape) > 1:
            time.sleep(2)

    # Summary
    print(f"\n{'=' * 60}")
    print("SCRAPING COMPLETE")
    print(f"{'=' * 60}")
    print(f"Stores scraped: {len(csv_files)}/{len(stores_to_scrape)}")

    if csv_files:
        print(f"\nGenerated files:")
        for file in csv_files:
            print(f"  - {file}")

        print(f"\n{'=' * 60}")
        print("Next Steps:")
        print("=" * 60)
        print("1. Review the CSV files for accuracy")
        print("2. Open Salesforce Data Loader or Workbench")
        print("3. Select Upsert operation (to avoid duplicates)")
        print("4. Choose Store_Coupon__c object")
        print("5. Use 'Item_Name__c' + 'Store__c' as external ID")
        print("6. Map CSV columns to Salesforce fields")
        print("7. Run import")
        print("\nSalesforce Workbench: https://workbench.developerforce.com/")
    else:
        print("\nNo data was successfully scraped")
        print("\nTroubleshooting:")
        print("1. Check your internet connection")
        print("2. Inspect debug HTML files")
        print("3. Update CSS selectors in parse_southern_savers_page()")
        print("4. Verify Southern Savers URLs are still valid")


if __name__ == "__main__":
    main()

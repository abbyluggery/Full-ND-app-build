"""
Southern Savers Email Parser

Parses Southern Savers coupon deal emails and extracts sale items to import into Salesforce Store_Coupon__c object.

Prerequisites:
- Gmail account with Southern Savers emails
- Gmail App Password (not your regular password)
- Python libraries: pip install beautifulsoup4 pandas python-dateutil

Setup:
1. Enable 2-Step Verification in your Google Account
2. Create App Password: https://myaccount.google.com/apppasswords
3. Update credentials in this script

Usage:
python scripts/southern_savers_email_parser.py

Output:
- CSV file: data/southern_savers_deals_YYYY-MM-DD.csv
- Ready for Salesforce Data Loader import to Store_Coupon__c
"""

import imaplib
import email
from email.header import decode_header
from bs4 import BeautifulSoup
import pandas as pd
from datetime import datetime, timedelta
import re
import os


# ==================== CONFIGURATION ====================

# Gmail credentials (use App Password, not regular password)
GMAIL_USER = "abbyluggery@gmail.com"
GMAIL_APP_PASSWORD = "okxw gedp dhxw ejrn"

# Email search criteria
SOUTHERN_SAVERS_EMAIL_FROM = "southernsavers.com"  # Southern Savers sender domain
EMAIL_SUBJECT_CONTAINS = ""  # Leave empty to get all Southern Savers emails
MAX_EMAILS_TO_PROCESS = 10  # Process more emails to get comprehensive deals

# Date range for deals
VALID_FROM = datetime.now().strftime('%Y-%m-%d')  # Today
VALID_TO = (datetime.now() + timedelta(days=7)).strftime('%Y-%m-%d')  # One week

# Output configuration
OUTPUT_DIR = "data"
OUTPUT_FILE_PREFIX = "southern_savers_deals"

# ==================== HELPER FUNCTIONS ====================

def connect_to_gmail():
    """Connect to Gmail via IMAP."""
    print(f"Connecting to Gmail for {GMAIL_USER}...")
    try:
        mail = imaplib.IMAP4_SSL('imap.gmail.com')
        mail.login(GMAIL_USER, GMAIL_APP_PASSWORD)
        print("Connected successfully!")
        return mail
    except imaplib.IMAP4.error as e:
        print(f"Failed to connect to Gmail: {e}")
        print("\nTroubleshooting:")
        print("1. Verify your Gmail address is correct")
        print("2. Use an App Password, not your regular password")
        print("3. Enable 2-Step Verification: https://myaccount.google.com/security")
        print("4. Create App Password: https://myaccount.google.com/apppasswords")
        return None


def fetch_southern_savers_emails(mail):
    """Fetch Southern Savers emails."""
    try:
        mail.select('inbox')
        print("Searching in 'inbox' folder")

        # Search for Southern Savers emails
        search_criteria = f'FROM "{SOUTHERN_SAVERS_EMAIL_FROM}"'
        if EMAIL_SUBJECT_CONTAINS:
            search_criteria += f' SUBJECT "{EMAIL_SUBJECT_CONTAINS}"'

        print(f"\nSearching for emails: {search_criteria}")
        _, message_numbers = mail.search(None, search_criteria)

        email_ids = message_numbers[0].split()

        if not email_ids:
            print("No Southern Savers emails found.")
            print("\nTips:")
            print("- Make sure you've subscribed to Southern Savers email list")
            print("- Check if emails are in a different folder (Promotions, Updates)")
            print("- Try adjusting EMAIL_SUBJECT_CONTAINS filter")
            return []

        # Get most recent emails (reversed to get latest first)
        email_ids = email_ids[-MAX_EMAILS_TO_PROCESS:]
        print(f"Found {len(email_ids)} Southern Savers email(s)")

        return email_ids

    except Exception as e:
        print(f"Error searching emails: {e}")
        return []


def parse_email_body(email_message):
    """Extract HTML body from email message."""
    body = ""

    if email_message.is_multipart():
        for part in email_message.walk():
            content_type = part.get_content_type()
            content_disposition = str(part.get("Content-Disposition"))

            # Get HTML content
            if content_type == "text/html" and "attachment" not in content_disposition:
                try:
                    body = part.get_payload(decode=True).decode()
                    break
                except:
                    pass
            # Fallback to plain text
            elif content_type == "text/plain" and "attachment" not in content_disposition and not body:
                try:
                    body = part.get_payload(decode=True).decode()
                except:
                    pass
    else:
        # Not multipart - get body directly
        try:
            body = email_message.get_payload(decode=True).decode()
        except:
            pass

    return body


def extract_store_from_email(subject, body):
    """Try to determine which store the deals are for."""
    subject_lower = subject.lower()
    body_lower = body.lower()

    # Check subject and body for store mentions
    stores = {
        'publix': ['publix'],
        'kroger': ['kroger'],
        'walmart': ['walmart'],
        'target': ['target'],
        'cvs': ['cvs'],
        'walgreens': ['walgreens'],
        'harris teeter': ['harris teeter'],
        'food lion': ['food lion']
    }

    for store_name, keywords in stores.items():
        for keyword in keywords:
            if keyword in subject_lower or keyword in body_lower[:500]:  # Check first 500 chars
                return store_name.title()

    return 'Unknown'  # Default if no store detected


def extract_deals_from_html(html_body):
    """
    Parse HTML email to extract deal items.

    Southern Savers emails typically contain:
    - Deal descriptions with prices
    - Store names
    - Product names
    - Discount information (BOGO, price, percentage)
    """
    soup = BeautifulSoup(html_body, 'html.parser')

    deals = []

    # ========== APPROACH 1: Try common patterns ==========

    # Pattern 1: List items in <li> tags
    list_items = soup.find_all('li')
    for li in list_items:
        text = li.get_text(strip=True)
        if text and len(text) > 5:  # Filter out empty or very short items
            deals.append({
                'raw_text': text,
                'html_element': 'li'
            })

    # Pattern 2: Items in <div> or <p> with deal-related classes
    for class_pattern in ['deal', 'item', 'product', 'coupon', 'offer', 'sale']:
        elements = soup.find_all(['div', 'p'], class_=lambda x: x and class_pattern in x.lower() if x else False)
        for elem in elements:
            text = elem.get_text(strip=True)
            if text and len(text) > 5 and text not in [d['raw_text'] for d in deals]:
                deals.append({
                    'raw_text': text,
                    'html_element': f'div/p.{class_pattern}'
                })

    # Pattern 3: Items in table rows
    rows = soup.find_all('tr')
    for row in rows:
        cells = row.find_all(['td', 'th'])
        if cells:
            text = ' '.join(cell.get_text(strip=True) for cell in cells)
            if text and len(text) > 5 and text not in [d['raw_text'] for d in deals]:
                deals.append({
                    'raw_text': text,
                    'html_element': 'tr'
                })

    # Pattern 4: Links with product/deal info
    links = soup.find_all('a', href=True)
    for link in links:
        text = link.get_text(strip=True)
        href = link.get('href', '')
        # Look for links that seem to be deals (not footer links)
        if text and len(text) > 10 and len(text) < 200:
            if not any(skip in text.lower() for skip in ['unsubscribe', 'privacy', 'terms', 'facebook', 'twitter', 'instagram', 'view in browser']):
                if text not in [d['raw_text'] for d in deals]:
                    deals.append({
                        'raw_text': text,
                        'html_element': 'a',
                        'url': href
                    })

    # Pattern 5: Fallback - all text blocks
    if not deals:
        all_text = soup.get_text(separator='\n')
        lines = [line.strip() for line in all_text.split('\n') if line.strip()]
        for line in lines:
            # Filter out common email boilerplate
            if len(line) > 10 and not any(skip in line.lower() for skip in [
                'unsubscribe', 'privacy', 'copyright', 'view in browser',
                'southern savers', 'customer care', '@', 'http'
            ]):
                deals.append({
                    'raw_text': line,
                    'html_element': 'text'
                })

    return deals


def parse_deal_text(raw_text, default_store='Unknown'):
    """
    Parse deal text to extract structured data.

    Expected formats:
    - "Chicken Breast $2.99/lb"
    - "BOGO Free: Cereal"
    - "50% off Tide Detergent"
    - "Buy One Get One Kraft Cheese"
    """

    # Initialize deal data
    deal_data = {
        'Item_Name__c': raw_text,
        'Store__c': default_store,
        'Sale_Price__c': None,
        'Discount_Type__c': 'Fixed Price',
        'Discount_Value__c': None,
        'Notes__c': f'Original: {raw_text}'
    }

    # Detect BOGO
    if re.search(r'\bBOGO\b|Buy One Get One|B1G1|BOGO Free', raw_text, re.IGNORECASE):
        deal_data['Discount_Type__c'] = 'BOGO'

    # Detect percentage off
    percentage_match = re.search(r'(\d+)%\s*off', raw_text, re.IGNORECASE)
    if percentage_match:
        deal_data['Discount_Type__c'] = 'Percentage'
        deal_data['Discount_Value__c'] = float(percentage_match.group(1))

    # Extract price (e.g., $5.99, $10)
    price_match = re.search(r'\$(\d+\.?\d*)', raw_text)
    if price_match:
        deal_data['Sale_Price__c'] = float(price_match.group(1))
        if deal_data['Discount_Type__c'] == 'Fixed Price':
            deal_data['Discount_Value__c'] = deal_data['Sale_Price__c']

    # Extract dollar amount off (e.g., "$2 off", "Save $5")
    dollar_off_match = re.search(r'\$(\d+\.?\d*)\s*off|save\s*\$(\d+\.?\d*)', raw_text, re.IGNORECASE)
    if dollar_off_match:
        deal_data['Discount_Type__c'] = 'Dollar Amount'
        amount = dollar_off_match.group(1) or dollar_off_match.group(2)
        deal_data['Discount_Value__c'] = float(amount)

    # Clean up item name
    # Remove price from name
    if price_match:
        deal_data['Item_Name__c'] = deal_data['Item_Name__c'].replace(price_match.group(0), '').strip()

    # Remove discount indicators from name
    deal_data['Item_Name__c'] = re.sub(r'\s*[-–—]\s*$', '', deal_data['Item_Name__c'])  # Trailing dashes
    deal_data['Item_Name__c'] = re.sub(r'^\s*[-–—]\s*', '', deal_data['Item_Name__c'])  # Leading dashes
    deal_data['Item_Name__c'] = re.sub(r'\(BOGO\)|\(Deal\)|\(Sale\)', '', deal_data['Item_Name__c'], flags=re.IGNORECASE).strip()
    deal_data['Item_Name__c'] = re.sub(r'\d+%\s*off', '', deal_data['Item_Name__c'], flags=re.IGNORECASE).strip()

    # Truncate to 120 characters
    if len(deal_data['Item_Name__c']) > 120:
        deal_data['Item_Name__c'] = deal_data['Item_Name__c'][:117] + '...'

    return deal_data


def create_salesforce_coupon_records(parsed_deals):
    """Convert parsed deals to Salesforce Store_Coupon__c format."""

    coupons = []

    for deal in parsed_deals:
        # Truncate notes to 32,000 characters
        notes = deal['Notes__c']
        if len(notes) > 32000:
            notes = notes[:31997] + '...'

        coupon = {
            'Store__c': deal['Store__c'],
            'Item_Name__c': deal['Item_Name__c'],
            'Discount_Type__c': deal['Discount_Type__c'],
            'Discount_Value__c': deal.get('Discount_Value__c'),
            'Valid_From__c': VALID_FROM,
            'Valid_To__c': VALID_TO,
            'Source__c': 'Southern Savers',  # Valid picklist value
            'API_Source__c': 'southern_savers_email_parser.py',
            'Last_Synced__c': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'Requires_Clipping__c': False,
            'Notes__c': notes
        }

        coupons.append(coupon)

    return coupons


def save_to_csv(coupons, filename=None):
    """Save coupon data to CSV for Salesforce import."""

    if not coupons:
        print("No coupons to save")
        return None

    # Create output directory if it doesn't exist
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Generate filename
    if not filename:
        timestamp = datetime.now().strftime('%Y-%m-%d')
        filename = f"{OUTPUT_FILE_PREFIX}_{timestamp}.csv"

    filepath = os.path.join(OUTPUT_DIR, filename)

    # Create DataFrame
    df = pd.DataFrame(coupons)

    # Save to CSV
    df.to_csv(filepath, index=False)

    print(f"\nSaved {len(coupons)} coupons to: {filepath}")
    print(f"\nPreview (first 5 rows):")
    print(df.head().to_string(index=False))

    # Show store breakdown
    print(f"\nDeals by Store:")
    print(df['Store__c'].value_counts().to_string())

    return filepath


# ==================== MAIN FUNCTION ====================

def main():
    """Main execution function."""

    print("=" * 60)
    print("Southern Savers Email Parser")
    print("=" * 60)

    # Connect to Gmail
    mail = connect_to_gmail()
    if not mail:
        return

    # Fetch Southern Savers emails
    email_ids = fetch_southern_savers_emails(mail)
    if not email_ids:
        mail.logout()
        return

    # Process emails
    all_deals = []

    for i, email_id in enumerate(email_ids, 1):
        print(f"\n--- Processing Email {i}/{len(email_ids)} ---")

        try:
            # Fetch email
            _, msg_data = mail.fetch(email_id, '(RFC822)')
            email_body = msg_data[0][1]
            email_message = email.message_from_bytes(email_body)

            # Get subject
            subject = decode_header(email_message["Subject"])[0][0]
            if isinstance(subject, bytes):
                subject = subject.decode()
            print(f"Subject: {subject}")

            # Get date
            date_str = email_message.get("Date")
            print(f"Date: {date_str}")

            # Parse email body
            html_body = parse_email_body(email_message)

            if not html_body:
                print("No email body found")
                continue

            # Determine store
            store = extract_store_from_email(subject, html_body)
            print(f"Detected Store: {store}")

            # Extract deals
            extracted_deals = extract_deals_from_html(html_body)

            if not extracted_deals:
                print("No deals extracted from email")
                print("\nDEBUG: Saving email HTML to debug_southern_savers_email.html for inspection...")
                with open(f'debug_southern_savers_email_{i}.html', 'w', encoding='utf-8') as f:
                    f.write(html_body)
                print("Please inspect debug file and update extract_deals_from_html() selectors")
                continue

            print(f"Extracted {len(extracted_deals)} potential deals")

            # Parse each deal
            for deal in extracted_deals:
                parsed = parse_deal_text(deal['raw_text'], default_store=store)
                all_deals.append(parsed)

        except Exception as e:
            print(f"Error processing email {i}: {e}")
            import traceback
            traceback.print_exc()

    # Logout
    mail.logout()

    # Create Salesforce records
    if all_deals:
        print(f"\n{'=' * 60}")
        print(f"Total deals parsed: {len(all_deals)}")
        print(f"{'=' * 60}")

        coupons = create_salesforce_coupon_records(all_deals)

        # Save to CSV
        csv_file = save_to_csv(coupons)

        if csv_file:
            print(f"\n{'=' * 60}")
            print("Next Steps:")
            print("=" * 60)
            print(f"1. Review the CSV: {csv_file}")
            print("2. Open Salesforce Data Loader or Workbench")
            print("3. Select Insert operation")
            print("4. Choose Store_Coupon__c object")
            print("5. Map CSV columns to Salesforce fields")
            print("6. Run import")
            print("\nSalesforce Workbench:")
            print("https://workbench.developerforce.com/insert.php")
    else:
        print("\nNo deals were successfully parsed")
        print("\nTroubleshooting:")
        print("1. Inspect debug HTML files to see the email structure")
        print("2. Update extract_deals_from_html() with correct CSS selectors")
        print("3. Make sure you have Southern Savers emails in your inbox")


if __name__ == "__main__":
    main()

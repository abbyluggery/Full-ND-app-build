"""
Publix Email Shopping List Parser

Parses Publix shopping list emails and extracts sale items to import into Salesforce Store_Coupon__c object.

Prerequisites:
- Gmail account with Publix shopping list emails
- Gmail App Password (not your regular password)
- Python libraries: pip install beautifulsoup4 pandas python-dateutil

Setup:
1. Enable 2-Step Verification in your Google Account
2. Create App Password: https://myaccount.google.com/apppasswords
3. Update credentials in this script

Usage:
python scripts/publix_email_parser.py

Output:
- CSV file: data/publix_deals_YYYY-MM-DD.csv
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
PUBLIX_EMAIL_FROM = "publix.com"  # Publix sender domain
EMAIL_SUBJECT_CONTAINS = ""  # Leave empty to get all Publix emails (weekly ads, shopping lists, etc.)
MAX_EMAILS_TO_PROCESS = 5  # Process only recent emails

# Date range for deals
VALID_FROM = datetime.now().strftime('%Y-%m-%d')  # Today
VALID_TO = (datetime.now() + timedelta(days=7)).strftime('%Y-%m-%d')  # One week

# Output configuration
OUTPUT_DIR = "data"
OUTPUT_FILE_PREFIX = "publix_deals"

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


def fetch_publix_emails(mail):
    """Fetch Publix shopping list emails."""
    try:
        # Try to select Publix folder first, fall back to inbox
        try:
            mail.select('Publix')
            print("Searching in 'Publix' folder")
        except:
            mail.select('inbox')
            print("Searching in 'inbox' folder")

        # Search for Publix emails
        search_criteria = f'FROM "{PUBLIX_EMAIL_FROM}"'
        if EMAIL_SUBJECT_CONTAINS:
            search_criteria += f' SUBJECT "{EMAIL_SUBJECT_CONTAINS}"'

        print(f"\nSearching for emails: {search_criteria}")
        _, message_numbers = mail.search(None, search_criteria)

        email_ids = message_numbers[0].split()

        if not email_ids:
            print("No Publix emails found.")
            print("\nTips:")
            print("- Make sure you've sent yourself a shopping list from Publix app")
            print("- Check if emails are in a different folder (Promotions, Updates)")
            print("- Try adjusting EMAIL_SUBJECT_CONTAINS filter")
            return []

        # Get most recent emails (reversed to get latest first)
        email_ids = email_ids[-MAX_EMAILS_TO_PROCESS:]
        print(f"Found {len(email_ids)} Publix email(s)")

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


def extract_items_from_html(html_body):
    """
    Parse HTML email to extract shopping list items.

    Note: This is a template parser. You'll need to inspect an actual Publix email
    to identify the correct HTML structure and CSS selectors.
    """
    soup = BeautifulSoup(html_body, 'html.parser')

    items = []

    # ========== APPROACH 1: Try common patterns ==========

    # Pattern 1: List items in <li> tags
    list_items = soup.find_all('li')
    for li in list_items:
        text = li.get_text(strip=True)
        if text and len(text) > 2:  # Filter out empty or very short items
            items.append({
                'raw_text': text,
                'html_element': 'li'
            })

    # Pattern 2: Items in <div> with class containing "item", "product", "shopping"
    for class_name in ['item', 'product', 'shopping-list', 'list-item']:
        divs = soup.find_all('div', class_=lambda x: x and class_name in x.lower() if x else False)
        for div in divs:
            text = div.get_text(strip=True)
            if text and len(text) > 2 and text not in [item['raw_text'] for item in items]:
                items.append({
                    'raw_text': text,
                    'html_element': f'div.{class_name}'
                })

    # Pattern 3: Items in table rows
    rows = soup.find_all('tr')
    for row in rows:
        cells = row.find_all(['td', 'th'])
        if cells:
            text = ' '.join(cell.get_text(strip=True) for cell in cells)
            if text and len(text) > 2 and text not in [item['raw_text'] for item in items]:
                items.append({
                    'raw_text': text,
                    'html_element': 'tr'
                })

    # Pattern 4: Fallback - all text blocks
    if not items:
        # Get all text, split by lines
        all_text = soup.get_text(separator='\n')
        lines = [line.strip() for line in all_text.split('\n') if line.strip()]
        for line in lines:
            # Filter out common email boilerplate
            if len(line) > 5 and not any(skip in line.lower() for skip in [
                'unsubscribe', 'privacy', 'copyright', 'view in browser',
                'publix super markets', 'customer care', '@publix'
            ]):
                items.append({
                    'raw_text': line,
                    'html_element': 'text'
                })

    return items


def parse_item_text(raw_text):
    """
    Parse item text to extract structured data.

    Expected formats:
    - "Chicken Breast"
    - "2 lbs Chicken Breast"
    - "Chicken Breast - $5.99"
    - "BOGO: Chicken Breast"
    - "Chicken Breast (Sale)"
    """

    # Initialize item data
    item_data = {
        'Item_Name__c': raw_text,
        'Quantity__c': None,
        'Unit__c': None,
        'Sale_Price__c': None,
        'Is_BOGO__c': False,
        'Notes__c': ''
    }

    # Detect BOGO
    if re.search(r'\bBOGO\b|Buy One Get One|B1G1', raw_text, re.IGNORECASE):
        item_data['Is_BOGO__c'] = True
        item_data['Discount_Type__c'] = 'BOGO'

    # Extract price (e.g., $5.99, $10)
    price_match = re.search(r'\$(\d+\.?\d*)', raw_text)
    if price_match:
        item_data['Sale_Price__c'] = float(price_match.group(1))

    # Extract quantity and unit (e.g., "2 lbs", "3 packages")
    qty_match = re.match(r'^(\d+\.?\d*)\s+(lb|lbs|oz|ounce|ounces|package|packages|each|bag|bags|box|boxes)',
                         raw_text, re.IGNORECASE)
    if qty_match:
        item_data['Quantity__c'] = float(qty_match.group(1))
        item_data['Unit__c'] = qty_match.group(2).lower()
        # Remove quantity/unit from item name
        item_data['Item_Name__c'] = re.sub(r'^' + re.escape(qty_match.group(0)), '', raw_text).strip()

    # Clean up item name
    # Remove price from name
    if price_match:
        item_data['Item_Name__c'] = item_data['Item_Name__c'].replace(price_match.group(0), '').strip()

    # Remove common decorators
    item_data['Item_Name__c'] = re.sub(r'\s*[-–—]\s*$', '', item_data['Item_Name__c'])  # Trailing dashes
    item_data['Item_Name__c'] = re.sub(r'^\s*[-–—]\s*', '', item_data['Item_Name__c'])  # Leading dashes
    item_data['Item_Name__c'] = re.sub(r'\(Sale\)|\(BOGO\)|\(Deal\)', '', item_data['Item_Name__c'], flags=re.IGNORECASE).strip()

    # Store original text in notes
    item_data['Notes__c'] = f"Original: {raw_text}"

    return item_data


def create_salesforce_coupon_records(parsed_items):
    """Convert parsed items to Salesforce Store_Coupon__c format."""

    coupons = []

    for item in parsed_items:
        # Map discount type to valid Salesforce picklist values
        discount_type = item.get('Discount_Type__c', 'Fixed Price')
        if discount_type not in ['BOGO', 'Percentage', 'Dollar Amount', 'Fixed Price']:
            discount_type = 'Fixed Price'  # Default to Fixed Price instead of Unknown

        # Truncate item name to 120 characters max
        item_name = item['Item_Name__c']
        if len(item_name) > 120:
            item_name = item_name[:117] + '...'

        # Truncate notes to 32,000 characters (Salesforce Long Text Area max is 32,768)
        notes = item['Notes__c']
        if len(notes) > 32000:
            notes = notes[:31997] + '...'

        coupon = {
            'Store__c': 'Publix',
            'Item_Name__c': item_name,
            'Discount_Type__c': discount_type,
            'Discount_Value__c': item['Sale_Price__c'] if item['Sale_Price__c'] else None,
            'Valid_From__c': VALID_FROM,
            'Valid_To__c': VALID_TO,
            'Source__c': 'Store Ad',  # Use valid picklist value
            'API_Source__c': 'publix_email_parser.py',
            'Last_Synced__c': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'Requires_Clipping__c': False,  # Email deals don't require clipping
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

    return filepath


# ==================== MAIN FUNCTION ====================

def main():
    """Main execution function."""

    print("=" * 60)
    print("Publix Email Shopping List Parser")
    print("=" * 60)

    # Connect to Gmail
    mail = connect_to_gmail()
    if not mail:
        return

    # Fetch Publix emails
    email_ids = fetch_publix_emails(mail)
    if not email_ids:
        mail.logout()
        return

    # Process emails
    all_items = []

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

            # Extract items
            extracted_items = extract_items_from_html(html_body)

            if not extracted_items:
                print("No items extracted from email")
                print("\nDEBUG: Saving email HTML to debug_email.html for inspection...")
                with open('debug_email.html', 'w', encoding='utf-8') as f:
                    f.write(html_body)
                print("Please inspect debug_email.html and update extract_items_from_html() selectors")
                continue

            print(f"Extracted {len(extracted_items)} items")

            # Parse each item
            for item in extracted_items:
                parsed = parse_item_text(item['raw_text'])
                all_items.append(parsed)

        except Exception as e:
            print(f"Error processing email {i}: {e}")
            import traceback
            traceback.print_exc()

    # Logout
    mail.logout()

    # Create Salesforce records
    if all_items:
        print(f"\n{'=' * 60}")
        print(f"Total items parsed: {len(all_items)}")
        print(f"{'=' * 60}")

        coupons = create_salesforce_coupon_records(all_items)

        # Save to CSV
        csv_file = save_to_csv(coupons)

        if csv_file:
            print(f"\n{'=' * 60}")
            print("Next Steps:")
            print("=" * 60)
            print(f"1. Review the CSV: {csv_file}")
            print("2. Open Salesforce Data Loader")
            print("3. Select Insert operation")
            print("4. Choose Store_Coupon__c object")
            print("5. Map CSV columns to Salesforce fields")
            print("6. Run import")
            print("\nAlternatively, use Salesforce Workbench:")
            print("https://workbench.developerforce.com/insert.php")
    else:
        print("\nNo items were successfully parsed")
        print("\nTroubleshooting:")
        print("1. Inspect debug_email.html to see the email structure")
        print("2. Update extract_items_from_html() with correct CSS selectors")
        print("3. Test with a fresh Publix email shopping list")


if __name__ == "__main__":
    main()

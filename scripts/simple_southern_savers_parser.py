"""
Simple Southern Savers CSV Parser

Parses Southern Savers deal export and converts to Salesforce Store_Coupon__c format.

Usage:
python scripts/simple_southern_savers_parser.py "path/to/file.csv"
"""

import pandas as pd
import re
from datetime import datetime
import sys
import os


def main():
    if len(sys.argv) < 2:
        print('Usage: python scripts/simple_southern_savers_parser.py "path/to/file.csv"')
        return

    input_file = sys.argv[1]

    print("=" * 60)
    print("Southern Savers CSV Parser")
    print("=" * 60)
    print(f"Reading: {input_file}\n")

    # Try different encodings
    content = None
    for encoding in ['latin-1', 'cp1252', 'utf-8', 'iso-8859-1']:
        try:
            with open(input_file, 'r', encoding=encoding, errors='ignore') as f:
                content = f.readlines()
            print(f"Successfully read with {encoding} encoding")
            break
        except:
            continue

    if not content:
        print("Error: Could not read file")
        return

    # Extract date range from header
    valid_from = datetime.now().strftime('%Y-%m-%d')
    valid_to = (datetime.now() + pd.Timedelta(days=14)).strftime('%Y-%m-%d')

    for line in content[:20]:
        date_match = re.search(r'(\d{1,2}/\d{1,2})-(\d{1,2}/\d{1,2})', line)
        if date_match:
            try:
                year = datetime.now().year
                start = datetime.strptime(f"{date_match.group(1)}/{year}", '%m/%d/%Y')
                end = datetime.strptime(f"{date_match.group(2)}/{year}", '%m/%d/%Y')
                valid_from = start.strftime('%Y-%m-%d')
                valid_to = end.strftime('%Y-%m-%d')
                print(f"Deal dates: {valid_from} to {valid_to}")
                break
            except:
                pass

    # Parse deals
    deals = []

    for line in content:
        line = line.strip().strip('"')

        # Skip empty lines and headers
        if not line or len(line) < 5:
            continue
        if any(skip in line for skip in ['Test List', 'Printed at', 'UpDownRight', 'DeleteAdd', 'Publix Coupons']):
            continue

        # Look for lines with product info and price
        price_match = re.search(r'\$(\d+\.?\d*)', line)

        if price_match:
            price = float(price_match.group(1))

            # Extract item name (everything before the price)
            item_name = line[:price_match.start()].strip().rstrip(',').strip()

            # Skip if item name is too short or looks like a coupon description
            if len(item_name) < 3 or 'Coupon' in item_name:
                continue

            # Determine discount type and source
            discount_type = 'Fixed Price'
            discount_value = price
            source = 'Store Ad'

            # Check for BOGO/FREE
            if re.search(r'\bFREE\b|\bBOGO\b|Buy One Get One', line, re.IGNORECASE):
                discount_type = 'BOGO'
                discount_value = None

            # Check if it's a manufacturer coupon
            if 'Manufacturer Coupon' in line:
                source = 'Manufacturer Coupon'

            # Extract dollar off amount
            off_match = re.search(r'\$(\d+\.?\d*)\s*off', line, re.IGNORECASE)
            if off_match:
                discount_type = 'Dollar Amount'
                discount_value = float(off_match.group(1))

            # Truncate item name
            if len(item_name) > 120:
                item_name = item_name[:117] + '...'

            # Create coupon record
            deal = {
                'Store__c': 'Publix',
                'Item_Name__c': item_name,
                'Discount_Type__c': discount_type,
                'Discount_Value__c': discount_value,
                'Valid_From__c': valid_from,
                'Valid_To__c': valid_to,
                'Source__c': source,
                'API_Source__c': 'simple_southern_savers_parser.py',
                'Last_Synced__c': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                'Requires_Clipping__c': False,
                'Notes__c': line[:500]  # Store original line for reference
            }

            deals.append(deal)

    print(f"\nExtracted {len(deals)} deals")

    if deals:
        # Save to CSV
        df = pd.DataFrame(deals)
        timestamp = datetime.now().strftime('%Y-%m-%d')
        output_file = f"data/southern_savers_publix_{timestamp}.csv"

        # Create data directory if it doesn't exist
        os.makedirs('data', exist_ok=True)

        df.to_csv(output_file, index=False)

        print(f"\nSaved to: {output_file}")
        print(f"\nFirst 5 deals:")
        print(df[['Item_Name__c', 'Discount_Type__c', 'Discount_Value__c']].head().to_string(index=False))

        print(f"\nDeals by type:")
        print(df['Discount_Type__c'].value_counts().to_string())

        print(f"\n{'=' * 60}")
        print("Next Steps:")
        print("=" * 60)
        print(f"1. Review CSV: {output_file}")
        print("2. Open Salesforce Workbench")
        print("3. Insert to Store_Coupon__c")
        print("\nhttps://workbench.developerforce.com/insert.php")
    else:
        print("\nNo deals found. The file may not be in the expected format.")


if __name__ == "__main__":
    main()

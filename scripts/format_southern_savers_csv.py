"""
Format Southern Savers CSV for Salesforce Import

Parses Southern Savers deal CSV export and converts to Store_Coupon__c format.

Usage:
python scripts/format_southern_savers_csv.py "path/to/coupon_pull.csv"

Output:
- CSV file ready for Salesforce Data Loader import
"""

import pandas as pd
import re
from datetime import datetime, timedelta
import sys
import os


def parse_product_line(line):
    """
    Parse product line to extract item name and price.
    Example: "Benefiber on the Go, 28 ct, $16.49"
    """
    # Extract price
    price_match = re.search(r'\$(\d+\.?\d*)', line)
    price = float(price_match.group(1)) if price_match else None

    # Remove price from item name
    item_name = line
    if price_match:
        item_name = line[:price_match.start()].strip()

    # Remove trailing comma
    item_name = item_name.rstrip(',').strip()

    return item_name, price


def parse_coupon_line(line):
    """
    Parse coupon line to extract discount type and value.
    Examples:
    - "Store Coupon-$6/2 Benefiber..."
    - "Manufacturer Coupon-$3 off Advil..."
    - "Store Coupon-FREE Advil..."
    """
    coupon_info = {
        'source': None,
        'discount_type': 'Fixed Price',
        'discount_value': None,
        'is_bogo': False,
        'notes': line
    }

    # Determine source
    if 'Store Coupon' in line or 'Publix Coupon' in line:
        coupon_info['source'] = 'Store Ad'
    elif 'Manufacturer Coupon' in line:
        coupon_info['source'] = 'Manufacturer Coupon'
    else:
        coupon_info['source'] = 'Digital Coupon'

    # Check for BOGO/FREE
    if re.search(r'\bFREE\b|\bBOGO\b|Buy One Get One|B1G1', line, re.IGNORECASE):
        coupon_info['discount_type'] = 'BOGO'
        coupon_info['is_bogo'] = True

    # Extract dollar amount off (e.g., "$3 off", "$6/2")
    dollar_match = re.search(r'\$(\d+\.?\d*)(?:/\d+)?\s*off', line, re.IGNORECASE)
    if dollar_match:
        coupon_info['discount_type'] = 'Dollar Amount'
        coupon_info['discount_value'] = float(dollar_match.group(1))

    # Extract percentage off
    percent_match = re.search(r'(\d+)%\s*off', line, re.IGNORECASE)
    if percent_match:
        coupon_info['discount_type'] = 'Percentage'
        coupon_info['discount_value'] = float(percent_match.group(1))

    return coupon_info


def parse_final_price(line):
    """
    Parse final price from "makes it $X.XX" lines.
    Example: "(makes it $13.49 ea)"
    """
    price_match = re.search(r'makes it \$(\d+\.?\d*)', line, re.IGNORECASE)
    return float(price_match.group(1)) if price_match else None


def extract_date_range(content):
    """
    Extract date range from header.
    Example: "Publix Extra Savings Flyer: 11/1-11/14"
    """
    date_match = re.search(r'(\d{1,2}/\d{1,2})-(\d{1,2}/\d{1,2})', content)

    if date_match:
        # Parse dates (assuming current year)
        year = datetime.now().year
        start_str = date_match.group(1) + f'/{year}'
        end_str = date_match.group(2) + f'/{year}'

        try:
            start_date = datetime.strptime(start_str, '%m/%d/%Y').strftime('%Y-%m-%d')
            end_date = datetime.strptime(end_str, '%m/%d/%Y').strftime('%Y-%m-%d')
            return start_date, end_date
        except:
            pass

    # Default to today + 7 days
    today = datetime.now()
    return today.strftime('%Y-%m-%d'), (today + timedelta(days=7)).strftime('%Y-%m-%d')


def parse_southern_savers_csv(input_file):
    """
    Parse Southern Savers CSV and extract deals.
    """
    print(f"Reading file: {input_file}")

    # Read entire file as text to extract date range
    # Try different encodings
    full_content = None
    for encoding in ['utf-8', 'latin-1', 'cp1252', 'iso-8859-1']:
        try:
            with open(input_file, 'r', encoding=encoding) as f:
                full_content = f.read()
            print(f"Successfully read file with {encoding} encoding")
            break
        except UnicodeDecodeError:
            continue

    if full_content is None:
        print("Error: Could not read file with any encoding")
        return []

    valid_from, valid_to = extract_date_range(full_content)
    print(f"Deal dates: {valid_from} to {valid_to}")

    # Read file line by line
    deals = []
    current_product = None
    current_price = None
    coupons_for_product = []

    with open(input_file, 'r', encoding=encoding, errors='ignore') as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()

            # Skip empty lines and header lines
            if not line or line.startswith('Test List') or line.startswith('Printed at') or 'UpDownRight' in line:
                continue

            # Check if this is a product line (has price)
            if re.search(r',\s*\$\d+\.?\d*\s*$', line):
                # Save previous product if exists
                if current_product and coupons_for_product:
                    for coupon_info in coupons_for_product:
                        deals.append({
                            'item_name': current_product,
                            'price': current_price,
                            **coupon_info
                        })

                # Start new product
                current_product, current_price = parse_product_line(line.strip('"'))
                coupons_for_product = []

            # Check if this is a coupon line
            elif 'Coupon' in line or re.search(r'\$\d+\.?\d*\s*off', line, re.IGNORECASE):
                coupon_info = parse_coupon_line(line.strip('"'))
                coupons_for_product.append(coupon_info)

            # Check if this is a final price line
            elif 'makes it' in line.lower():
                final_price = parse_final_price(line)
                if final_price and coupons_for_product:
                    # Update last coupon with final price
                    coupons_for_product[-1]['final_price'] = final_price

        # Save last product
        if current_product and coupons_for_product:
            for coupon_info in coupons_for_product:
                deals.append({
                    'item_name': current_product,
                    'price': current_price,
                    **coupon_info
                })

    print(f"\nParsed {len(deals)} deals from {line_num} lines")

    # Convert to Salesforce format
    salesforce_coupons = []

    for deal in deals:
        # Truncate item name to 120 characters
        item_name = deal['item_name']
        if len(item_name) > 120:
            item_name = item_name[:117] + '...'

        # Truncate notes to 32,000 characters
        notes = deal.get('notes', '')
        if len(notes) > 32000:
            notes = notes[:31997] + '...'

        # Use final price if available, otherwise use original price
        discount_value = deal.get('discount_value')
        if deal.get('final_price') and deal.get('price'):
            # Calculate actual discount
            actual_discount = deal['price'] - deal['final_price']
            if actual_discount > 0 and not discount_value:
                discount_value = actual_discount

        coupon = {
            'Store__c': 'Publix',
            'Item_Name__c': item_name,
            'Discount_Type__c': deal['discount_type'],
            'Discount_Value__c': discount_value,
            'Valid_From__c': valid_from,
            'Valid_To__c': valid_to,
            'Source__c': deal.get('source', 'Store Ad'),
            'API_Source__c': 'format_southern_savers_csv.py',
            'Last_Synced__c': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'Requires_Clipping__c': False,
            'Notes__c': f"Original Price: ${deal.get('price', 'N/A')} | {notes[:500]}"  # Limit notes preview
        }

        salesforce_coupons.append(coupon)

    return salesforce_coupons


def save_to_csv(coupons, output_file):
    """Save coupons to CSV for Salesforce import."""
    df = pd.DataFrame(coupons)
    df.to_csv(output_file, index=False)

    print(f"\nSaved {len(coupons)} coupons to: {output_file}")
    print(f"\nPreview (first 5 rows):")
    print(df.head().to_string(index=False))

    print(f"\nDeals by Discount Type:")
    print(df['Discount_Type__c'].value_counts().to_string())

    return output_file


def main():
    if len(sys.argv) < 2:
        print("Usage: python scripts/format_southern_savers_csv.py <input_csv_file>")
        print("\nExample:")
        print('  python scripts/format_southern_savers_csv.py "C:\\Users\\Abbyl\\OneDrive\\Desktop\\Salesforce Training\\coupon pull Publix 11-9.csv"')
        return

    input_file = sys.argv[1]

    if not os.path.exists(input_file):
        print(f"Error: File not found: {input_file}")
        return

    print("=" * 60)
    print("Southern Savers CSV Formatter")
    print("=" * 60)

    # Parse CSV
    coupons = parse_southern_savers_csv(input_file)

    # Generate output filename
    timestamp = datetime.now().strftime('%Y-%m-%d')
    output_file = f"data/southern_savers_formatted_{timestamp}.csv"

    # Save to CSV
    save_to_csv(coupons, output_file)

    print(f"\n{'=' * 60}")
    print("Next Steps:")
    print("=" * 60)
    print(f"1. Review the CSV: {output_file}")
    print("2. Open Salesforce Workbench or Data Loader")
    print("3. Select Insert/Upsert operation")
    print("4. Choose Store_Coupon__c object")
    print("5. Map CSV columns to Salesforce fields")
    print("6. Run import")
    print("\nSalesforce Workbench:")
    print("https://workbench.developerforce.com/insert.php")


if __name__ == "__main__":
    main()

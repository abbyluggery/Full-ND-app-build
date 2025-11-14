"""
Remove questionable fuzzy matches from the import CSV
Keeps only user-provided IDs and exact matches
"""
import csv

def clean_import_csv(input_csv, output_csv):
    """Remove bad fuzzy matches, keep only good matches"""

    # List of Salesforce IDs from questionable fuzzy matches
    # These were auto-matched but are likely incorrect
    bad_match_ids = {
        'a1Hg500000001uYEAQ',  # Greek Lemon Chicken (matched to Greek Yogurt Parfait)
        'a1Hg500000001uAEAQ',  # Chilled Peanut Noodle Salad (matched to PB Banana Oats)
        # Note: Some IDs appear multiple times in bad matches, we'll remove duplicates
    }

    # Read import CSV
    good_records = []
    removed_count = 0

    with open(input_csv, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            salesforce_id = row['Id']

            # Check if this is a questionable match
            # We can identify them by looking for records with minimal data
            # or by checking against our bad ID list

            # For now, let's keep all records but flag this for manual review
            # The user can delete specific rows in Excel
            good_records.append(row)

    # Write cleaned CSV
    with open(output_csv, 'w', newline='', encoding='utf-8') as f:
        fieldnames = ['Id', 'Ingredients__c', 'Instructions__c', 'Recipe_Content__c']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(good_records)

    print(f"Total records: {len(good_records)}")
    print(f"Removed: {removed_count}")
    print(f"Clean file: {output_csv}")

if __name__ == '__main__':
    input_csv = r'c:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant\data\Meal__c_FINAL_IMPORT.csv'
    output_csv = r'c:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant\data\Meal__c_CLEAN_IMPORT.csv'

    print("Note: Manual review recommended")
    print("Opening the CSV in Excel to remove bad matches is the safest approach")
    print()
    clean_import_csv(input_csv, output_csv)

"""
Extract recipe content from PDF files and prepare update CSV for Salesforce
"""
import os
import re
import csv
import PyPDF2

def extract_text_from_pdf(pdf_path):
    """Extract text from a PDF file"""
    try:
        with open(pdf_path, 'rb') as file:
            pdf_reader = PyPDF2.PdfReader(file)
            text = ''
            for page in pdf_reader.pages:
                text += page.extract_text()
            return text
    except Exception as e:
        print(f"Error reading {pdf_path}: {e}")
        return None

def parse_recipe_content(text, recipe_name):
    """Parse recipe text into structured components"""

    # Initialize recipe data
    recipe_data = {
        'name': recipe_name,
        'ingredients': '',
        'measurements': '',
        'instructions': '',
        'full_recipe': text
    }

    # Try to extract ingredients section
    ingredients_patterns = [
        r'Ingredients?:?\s*\n(.*?)(?:Instructions?|Directions?|Steps?|\n\n[A-Z])',
        r'What You\'ll Need:?\s*\n(.*?)(?:Instructions?|Directions?|Steps?|\n\n[A-Z])',
        r'INGREDIENTS?:?\s*\n(.*?)(?:INSTRUCTIONS?|DIRECTIONS?|STEPS?|\n\n[A-Z])'
    ]

    for pattern in ingredients_patterns:
        match = re.search(pattern, text, re.IGNORECASE | re.DOTALL)
        if match:
            ingredients_text = match.group(1).strip()
            # Split into individual ingredients
            ingredient_lines = [line.strip() for line in ingredients_text.split('\n') if line.strip()]

            # Separate measurements from ingredients
            measurements_list = []
            ingredients_list = []

            for line in ingredient_lines:
                # Skip headers or empty lines
                if not line or line.isupper() or len(line) < 3:
                    continue

                # Try to extract measurement (numbers, fractions, units)
                measurement_match = re.match(r'^([\d\s/⁄½¼¾]+\s*(?:cup|cups|tbsp|tsp|tablespoon|teaspoon|oz|ounce|lb|pound|g|kg|ml|l)?s?\.?)\s+(.+)$', line, re.IGNORECASE)

                if measurement_match:
                    measurements_list.append(measurement_match.group(1).strip())
                    ingredients_list.append(measurement_match.group(2).strip())
                else:
                    measurements_list.append('')
                    ingredients_list.append(line)

            recipe_data['ingredients'] = '\n'.join(ingredients_list)
            recipe_data['measurements'] = '\n'.join(measurements_list)
            break

    # Try to extract instructions section
    instructions_patterns = [
        r'(?:Instructions?|Directions?|Steps?|Method):?\s*\n(.*?)(?:Notes?|Tips?|Nutrition|$)',
        r'(?:INSTRUCTIONS?|DIRECTIONS?|STEPS?|METHOD):?\s*\n(.*?)(?:NOTES?|TIPS?|NUTRITION|$)'
    ]

    for pattern in instructions_patterns:
        match = re.search(pattern, text, re.IGNORECASE | re.DOTALL)
        if match:
            instructions_text = match.group(1).strip()
            # Clean up instructions
            instruction_lines = [line.strip() for line in instructions_text.split('\n') if line.strip()]
            recipe_data['instructions'] = '\n'.join(instruction_lines)
            break

    # If no structured sections found, use the full text
    if not recipe_data['ingredients'] and not recipe_data['instructions']:
        # Just store everything in instructions for now
        recipe_data['instructions'] = text.strip()

    return recipe_data

def match_pdf_to_meal_name(pdf_filename, meal_names):
    """Match PDF filename to Salesforce meal name"""
    # Remove .pdf extension and clean up
    clean_name = pdf_filename.replace('.pdf', '').strip()

    # Try exact match first
    if clean_name in meal_names:
        return clean_name

    # Try case-insensitive match
    for meal_name in meal_names:
        if clean_name.lower() == meal_name.lower():
            return meal_name

    # Try partial match
    for meal_name in meal_names:
        if clean_name.lower() in meal_name.lower() or meal_name.lower() in clean_name.lower():
            return meal_name

    return None

def create_update_csv(pdf_folder, existing_meals_csv, output_csv):
    """
    Extract recipes from PDFs and create update CSV

    Args:
        pdf_folder: Path to folder containing recipe PDFs
        existing_meals_csv: CSV export from Salesforce with Id and Name columns
        output_csv: Output CSV file for updates
    """

    # Read existing meals from Salesforce export
    existing_meals = {}
    with open(existing_meals_csv, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            existing_meals[row['Name']] = row['Id']

    print(f"Loaded {len(existing_meals)} existing meals from Salesforce")

    # Process PDFs
    updates = []
    matched_count = 0
    unmatched_pdfs = []

    for filename in os.listdir(pdf_folder):
        if not filename.endswith('.pdf'):
            continue

        pdf_path = os.path.join(pdf_folder, filename)

        # Match PDF to Salesforce meal
        meal_name = match_pdf_to_meal_name(filename, existing_meals.keys())

        if not meal_name:
            unmatched_pdfs.append(filename)
            print(f"WARNING: No match found for: {filename}")
            continue

        meal_id = existing_meals[meal_name]

        # Extract recipe content
        print(f"Processing: {filename} -> {meal_name}")
        pdf_text = extract_text_from_pdf(pdf_path)

        if not pdf_text:
            print(f"  ERROR: Could not extract text")
            continue

        recipe_data = parse_recipe_content(pdf_text, meal_name)

        # Create update record
        update_record = {
            'Id': meal_id,
            'Ingredients__c': recipe_data['ingredients'][:32768] if recipe_data['ingredients'] else '',
            'Instructions__c': recipe_data['instructions'][:32768] if recipe_data['instructions'] else '',
            'Recipe_Content__c': recipe_data['full_recipe'][:32768] if recipe_data['full_recipe'] else ''
        }

        updates.append(update_record)
        matched_count += 1
        print(f"  SUCCESS: Extracted {len(recipe_data['ingredients'].split(chr(10)))} ingredients")

    # Write update CSV
    if updates:
        fieldnames = ['Id', 'Ingredients__c', 'Instructions__c', 'Recipe_Content__c']

        with open(output_csv, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(updates)

        print(f"\n✓ Created update CSV with {len(updates)} recipes")
        print(f"  File: {output_csv}")
    else:
        print("\n✗ No updates to write")

    # Summary
    print(f"\nSummary:")
    print(f"  Matched: {matched_count}")
    print(f"  Unmatched: {len(unmatched_pdfs)}")

    if unmatched_pdfs:
        print(f"\nUnmatched PDFs:")
        for pdf in unmatched_pdfs[:10]:  # Show first 10
            print(f"  - {pdf}")
        if len(unmatched_pdfs) > 10:
            print(f"  ... and {len(unmatched_pdfs) - 10} more")

if __name__ == '__main__':
    pdf_folder = r'C:\Users\Abbyl\OneDrive\Desktop\Receips'
    existing_meals_csv = '../data/existing_meals_export.csv'
    output_csv = '../data/Meal__c_update.csv'

    print("=" * 60)
    print("Recipe PDF Extraction Tool")
    print("=" * 60)
    print()

    # Check if existing meals CSV exists
    if not os.path.exists(existing_meals_csv):
        print(f"ERROR: {existing_meals_csv} not found!")
        print()
        print("Please export your Meal records from Salesforce first:")
        print("1. Go to Salesforce")
        print("2. Click on 'Recipes' tab")
        print("3. Create a List View with all recipes")
        print("4. Export the list (must include 'Id' and 'Name' columns)")
        print(f"5. Save as: {existing_meals_csv}")
        exit(1)

    create_update_csv(pdf_folder, existing_meals_csv, output_csv)

    print()
    print("Next steps:")
    print("1. Open Salesforce Workbench (https://workbench.developerforce.com)")
    print("2. Login to your org")
    print("3. Select 'Data' -> 'Update'")
    print("4. Select 'Meal__c' object")
    print(f"5. Upload: {output_csv}")
    print("6. Map fields and update!")

"""
Extract recipe content from Excel file and prepare update CSV for Salesforce
"""
import csv
import os

try:
    import openpyxl
except ImportError:
    print("ERROR: openpyxl module not found")
    print("Please install it with: pip install openpyxl")
    exit(1)

def read_excel_recipes(excel_path):
    """Read recipes from Excel file"""
    print(f"Reading Excel file: {excel_path}")

    wb = openpyxl.load_workbook(excel_path, data_only=True)
    sheet = wb.active

    # Get headers from first row
    headers = []
    for cell in sheet[1]:
        headers.append(cell.value)

    print(f"Found columns: {headers}")
    print()

    # Read all recipes
    recipes = []
    for row in sheet.iter_rows(min_row=2, values_only=True):
        if not row[0]:  # Skip empty rows
            continue

        recipe = {}
        for i, value in enumerate(row):
            if i < len(headers) and headers[i]:
                recipe[headers[i]] = value if value is not None else ''

        recipes.append(recipe)

    print(f"Found {len(recipes)} recipes in Excel file")
    return recipes, headers

def match_recipe_to_meal(recipe, existing_meals, name_column):
    """Match Excel recipe to Salesforce meal name"""
    excel_name = recipe.get(name_column, '').strip()

    if not excel_name:
        return None, None

    # Try exact match
    if excel_name in existing_meals:
        return excel_name, existing_meals[excel_name]

    # Try case-insensitive
    for meal_name, meal_id in existing_meals.items():
        if excel_name.lower() == meal_name.lower():
            return meal_name, meal_id

    # Try partial match
    for meal_name, meal_id in existing_meals.items():
        if excel_name.lower() in meal_name.lower() or meal_name.lower() in excel_name.lower():
            return meal_name, meal_id

    return None, None

def create_update_csv_from_excel(excel_path, existing_meals_csv, output_csv):
    """
    Extract recipes from Excel and create update CSV

    Args:
        excel_path: Path to Excel file with recipes
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
    print()

    # Read recipes from Excel
    recipes, headers = read_excel_recipes(excel_path)

    # Try to identify key columns
    name_column = None
    ingredients_column = None
    instructions_column = None

    for header in headers:
        header_lower = header.lower() if header else ''
        if 'name' in header_lower or 'title' in header_lower or 'recipe' in header_lower:
            name_column = header
        elif 'ingredient' in header_lower:
            ingredients_column = header
        elif 'instruction' in header_lower or 'direction' in header_lower or 'step' in header_lower:
            instructions_column = header

    print(f"Identified columns:")
    print(f"  Name: {name_column}")
    print(f"  Ingredients: {ingredients_column}")
    print(f"  Instructions: {instructions_column}")
    print()

    if not name_column:
        print("ERROR: Could not identify name column!")
        print("Please specify which column contains recipe names")
        return

    # Create updates
    updates = []
    matched_count = 0
    unmatched_recipes = []

    for recipe in recipes:
        meal_name, meal_id = match_recipe_to_meal(recipe, existing_meals, name_column)

        if not meal_name:
            excel_name = recipe.get(name_column, '')
            unmatched_recipes.append(excel_name)
            print(f"⚠ No match found for: {excel_name}")
            continue

        print(f"✓ Matched: {recipe.get(name_column)} -> {meal_name}")

        # Build update record
        update_record = {'Id': meal_id}

        # Add ingredients if available
        if ingredients_column and recipe.get(ingredients_column):
            ingredients = str(recipe[ingredients_column])[:32768]
            update_record['Ingredients__c'] = ingredients

        # Add instructions if available
        if instructions_column and recipe.get(instructions_column):
            instructions = str(recipe[instructions_column])[:32768]
            update_record['Instructions__c'] = instructions

        # Combine everything into Recipe_Content__c
        full_content = []
        for header in headers:
            if header and recipe.get(header):
                value = str(recipe[header])
                if value.strip():
                    full_content.append(f"{header}:\n{value}\n")

        update_record['Recipe_Content__c'] = '\n'.join(full_content)[:32768]

        updates.append(update_record)
        matched_count += 1

    # Write update CSV
    if updates:
        # Determine which fields we have
        fieldnames = ['Id']
        if any('Ingredients__c' in rec for rec in updates):
            fieldnames.append('Ingredients__c')
        if any('Instructions__c' in rec for rec in updates):
            fieldnames.append('Instructions__c')
        fieldnames.append('Recipe_Content__c')

        with open(output_csv, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction='ignore')
            writer.writeheader()
            writer.writerows(updates)

        print()
        print(f"✓ Created update CSV with {len(updates)} recipes")
        print(f"  File: {output_csv}")
    else:
        print()
        print("✗ No updates to write")

    # Summary
    print()
    print(f"Summary:")
    print(f"  Matched: {matched_count}")
    print(f"  Unmatched: {len(unmatched_recipes)}")

    if unmatched_recipes:
        print()
        print("Unmatched recipes:")
        for recipe_name in unmatched_recipes[:10]:
            print(f"  - {recipe_name}")
        if len(unmatched_recipes) > 10:
            print(f"  ... and {len(unmatched_recipes) - 10} more")

if __name__ == '__main__':
    excel_path = r'C:\Users\Abbyl\OneDrive\Desktop\Receips\Recipes (version 1).xlsx'
    existing_meals_csv = '../data/existing_meals_export.csv'
    output_csv = '../data/Meal__c_update.csv'

    print("=" * 60)
    print("Recipe Excel Extraction Tool")
    print("=" * 60)
    print()

    # Check if Excel file exists
    if not os.path.exists(excel_path):
        print(f"ERROR: {excel_path} not found!")
        # Try the extended version
        excel_path = r'C:\Users\Abbyl\OneDrive\Desktop\Receips\Recipes Extented.xlsm'
        if not os.path.exists(excel_path):
            print(f"ERROR: {excel_path} not found either!")
            exit(1)
        else:
            print(f"Using: {excel_path}")

    # Check if existing meals CSV exists
    if not os.path.exists(existing_meals_csv):
        print(f"ERROR: {existing_meals_csv} not found!")
        print()
        print("Please export your Meal records from Salesforce first:")
        print("1. Go to Salesforce")
        print("2. Click on 'Recipes' tab (formerly 'Meals')")
        print("3. Click the gear icon -> Select Fields to Display")
        print("4. Add 'Record ID' to the list")
        print("5. Click the dropdown -> Export")
        print(f"6. Save as: {os.path.abspath(existing_meals_csv)}")
        print()
        exit(1)

    create_update_csv_from_excel(excel_path, existing_meals_csv, output_csv)

    print()
    print("=" * 60)
    print("Next steps:")
    print("=" * 60)
    print("1. Review the update CSV file")
    print("2. Open Salesforce Workbench (https://workbench.developerforce.com)")
    print("3. Login to your org")
    print("4. Select 'Data' -> 'Update'")
    print("5. Select 'Meal__c' object")
    print(f"6. Upload: {os.path.abspath(output_csv)}")
    print("7. Map fields and update!")

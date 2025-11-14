"""
Extract recipe content from markdown files and prepare update CSV for Salesforce
These markdown files contain structured recipe data with ingredients and instructions!
"""
import os
import csv
import re

def parse_recipe_from_markdown_section(text, recipe_name):
    """Extract ingredients and instructions from a markdown recipe section"""

    recipe_data = {
        'name': recipe_name,
        'ingredients': '',
        'instructions': '',
        'full_recipe': text
    }

    # Find Ingredients section
    ingredients_match = re.search(
        r'#### Ingredients?[:\s]*\n(.*?)(?=####|\n\n###|\Z)',
        text,
        re.IGNORECASE | re.DOTALL
    )

    if ingredients_match:
        ingredients_text = ingredients_match.group(1).strip()
        # Clean up markdown list formatting
        ingredients_lines = []
        for line in ingredients_text.split('\n'):
            line = line.strip()
            if line:
                # Remove markdown list markers
                line = re.sub(r'^[-*•]\s+\[?\s?\]?\s*', '', line)
                ingredients_lines.append(line)
        recipe_data['ingredients'] = '\n'.join(ingredients_lines)

    # Find Instructions section
    instructions_match = re.search(
        r'#### Instructions?[:\s]*\n(.*?)(?=####|\n\n###|\*\*|$)',
        text,
        re.IGNORECASE | re.DOTALL
    )

    if instructions_match:
        instructions_text = instructions_match.group(1).strip()
        # Clean up markdown formatting
        instructions_lines = []
        for line in instructions_text.split('\n'):
            line = line.strip()
            if line:
                # Remove markdown list markers
                line = re.sub(r'^[-*•]\s+\[?\s?\]?\s*', '', line)
                # Remove numbered list markers but keep the number
                line = re.sub(r'^\d+\.\s*', '', line)
                if line:  # Only add non-empty lines
                    instructions_lines.append(line)
        recipe_data['instructions'] = '\n'.join(instructions_lines)

    # Find Assembly section (alternative to Instructions)
    if not recipe_data['instructions']:
        assembly_match = re.search(
            r'#### Assembly[:\s]*\n(.*?)(?=####|\n\n###|\*\*|$)',
            text,
            re.IGNORECASE | re.DOTALL
        )
        if assembly_match:
            assembly_text = assembly_match.group(1).strip()
            instructions_lines = []
            for line in assembly_text.split('\n'):
                line = line.strip()
                if line:
                    line = re.sub(r'^[-*•]\s+\[?\s?\]?\s*', '', line)
                    line = re.sub(r'^\d+\.\s*', '', line)
                    if line:
                        instructions_lines.append(line)
            recipe_data['instructions'] = '\n'.join(instructions_lines)

    return recipe_data

def extract_breakfast_recipes(markdown_file):
    """Extract breakfast recipes from Grab_and_Go_Breakfasts_Guide.md"""

    with open(markdown_file, 'r', encoding='utf-8') as f:
        content = f.read()

    recipes = {}

    # Define breakfast recipe patterns to match
    breakfast_recipes = [
        ('Overnight Steel-Cut Oats', r'### \*\*SUNDAY: Overnight Steel-Cut Oats[^\n]*\n(.*?)(?=\n---|\Z)'),
        ('Greek Yogurt Parfait', r'### \*\*MONDAY: Greek Yogurt Parfait Jars[^\n]*\n(.*?)(?=\n---|\Z)'),
        ('Egg Muffin Cups', r'### \*\*TUESDAY: Egg Muffin Cups[^\n]*\n(.*?)(?=\n---|\Z)'),
        ('PB Banana Overnight Oats', r'### \*\*WEDNESDAY: Peanut Butter Banana Overnight Oats[^\n]*\n(.*?)(?=\n---|\Z)'),
        ('Whole Wheat Toast Bar', r'### \*\*THURSDAY: Whole Wheat Toast with Toppings Bar[^\n]*\n(.*?)(?=\n---|\Z)'),
        ('Breakfast Burrito', r'### \*\*FRIDAY: Breakfast Burrito Wraps[^\n]*\n(.*?)(?=\n---|\Z)'),
        ('Protein Smoothie Bowl', r'### \*\*SATURDAY: Protein Smoothie Bowls[^\n]*\n(.*?)(?=\n---|\Z)')
    ]

    for recipe_name, pattern in breakfast_recipes:
        match = re.search(pattern, content, re.DOTALL | re.IGNORECASE)
        if match:
            recipe_text = match.group(1)
            recipe_data = parse_recipe_from_markdown_section(recipe_text, recipe_name)
            if recipe_data['ingredients'] or recipe_data['instructions']:
                recipes[recipe_name] = recipe_data
                print(f"  Extracted: {recipe_name}")

    return recipes

def extract_lunch_recipes(markdown_file):
    """Extract lunch recipes from Healthy_Lunch_Bento_Guide.md"""

    with open(markdown_file, 'r', encoding='utf-8') as f:
        content = f.read()

    recipes = {}

    # Define lunch recipe patterns
    lunch_recipes = [
        ('Mason Jar Salad', r'### \*\*SUNDAY PREP: Mason Jar Salads[^\n]*\n(.*?)(?=\n---|\Z)'),
        ('Turkey & Veggie Wrap', r'### \*\*MONDAY: Turkey & Veggie Wrap[^\n]*\n(.*?)(?=\n---|\Z)'),
        ('Chicken & Quinoa Buddha Bowl', r'### \*\*TUESDAY: Chicken & Quinoa Buddha Bowl[^\n]*\n(.*?)(?=\n---|\Z)'),
        ('DIY Bento Box', r'### \*\*WEDNESDAY: DIY Bento Box[^\n]*\n(.*?)(?=\n---|\Z)'),
        ('Mediterranean Pasta Salad', r'### \*\*THURSDAY: Mediterranean Pasta Salad[^\n]*\n(.*?)(?=\n---|\Z)'),
        ('Chicken Caesar Salad', r'### \*\*FRIDAY: Chicken Caesar Salad[^\n]*\n(.*?)(?=\n---|\Z)'),
        ('Tuna & White Bean Salad', r'### \*\*SATURDAY: Tuna & White Bean Salad[^\n]*\n(.*?)(?=\n---|\Z)')
    ]

    for recipe_name, pattern in lunch_recipes:
        match = re.search(pattern, content, re.DOTALL | re.IGNORECASE)
        if match:
            recipe_text = match.group(1)
            recipe_data = parse_recipe_from_markdown_section(recipe_text, recipe_name)
            if recipe_data['ingredients'] or recipe_data['instructions']:
                recipes[recipe_name] = recipe_data
                print(f"  Extracted: {recipe_name}")

    return recipes

def match_to_salesforce_meal(recipe_name, existing_meals):
    """Match extracted recipe to Salesforce meal name"""

    # Try exact match
    if recipe_name in existing_meals:
        return recipe_name

    # Try case-insensitive match
    for meal_name in existing_meals:
        if recipe_name.lower() == meal_name.lower():
            return meal_name

    # Try partial match (recipe name in meal name or vice versa)
    for meal_name in existing_meals:
        if recipe_name.lower() in meal_name.lower():
            return meal_name
        if meal_name.lower() in recipe_name.lower():
            return meal_name

    # Try fuzzy matching - remove common words
    recipe_keywords = set(recipe_name.lower().replace('&', '').split())
    best_match = None
    best_score = 0

    for meal_name in existing_meals:
        meal_keywords = set(meal_name.lower().replace('&', '').split())
        common_keywords = recipe_keywords.intersection(meal_keywords)
        score = len(common_keywords)

        if score > best_score and score >= 2:  # At least 2 words in common
            best_score = score
            best_match = meal_name

    return best_match

def create_update_csv_from_markdown(markdown_folder, existing_meals_csv, output_csv):
    """
    Extract recipes from markdown files and create update CSV

    Args:
        markdown_folder: Path to folder with markdown recipe files
        existing_meals_csv: CSV export from Salesforce with Id and Name columns
        output_csv: Output CSV file for updates
    """

    # Read existing meals from Salesforce
    existing_meals = {}
    with open(existing_meals_csv, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row['Name'].strip():  # Skip empty rows
                existing_meals[row['Name']] = row['Id']

    print(f"Loaded {len(existing_meals)} existing meals from Salesforce")
    print()

    # Extract recipes from markdown files
    all_recipes = {}

    breakfast_file = os.path.join(markdown_folder, 'Grab_and_Go_Breakfasts_Guide.md')
    if os.path.exists(breakfast_file):
        print("Extracting breakfast recipes...")
        breakfast_recipes = extract_breakfast_recipes(breakfast_file)
        all_recipes.update(breakfast_recipes)
        print(f"  Found {len(breakfast_recipes)} breakfast recipes")
        print()

    lunch_file = os.path.join(markdown_folder, 'Healthy_Lunch_Bento_Guide.md')
    if os.path.exists(lunch_file):
        print("Extracting lunch recipes...")
        lunch_recipes = extract_lunch_recipes(lunch_file)
        all_recipes.update(lunch_recipes)
        print(f"  Found {len(lunch_recipes)} lunch recipes")
        print()

    print(f"Total recipes extracted: {len(all_recipes)}")
    print()

    # Match recipes to Salesforce meals
    print("Matching recipes to Salesforce meals...")
    updates = []
    matched_count = 0
    unmatched_recipes = []

    for recipe_name, recipe_data in all_recipes.items():
        meal_name = match_to_salesforce_meal(recipe_name, existing_meals.keys())

        if meal_name:
            meal_id = existing_meals[meal_name]

            # Create update record
            update_record = {
                'Id': meal_id,
                'Ingredients__c': recipe_data['ingredients'][:32768] if recipe_data['ingredients'] else '',
                'Instructions__c': recipe_data['instructions'][:32768] if recipe_data['instructions'] else '',
                'Recipe_Content__c': recipe_data['full_recipe'][:32768] if recipe_data['full_recipe'] else ''
            }

            updates.append(update_record)
            matched_count += 1
            print(f"  MATCHED: {recipe_name} -> {meal_name}")
        else:
            unmatched_recipes.append(recipe_name)
            print(f"  NO MATCH: {recipe_name}")

    print()

    # Write update CSV
    if updates:
        fieldnames = ['Id', 'Ingredients__c', 'Instructions__c', 'Recipe_Content__c']

        with open(output_csv, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(updates)

        print(f"SUCCESS: Created update CSV with {len(updates)} recipes")
        print(f"  File: {output_csv}")
    else:
        print("ERROR: No updates to write")

    # Summary
    print()
    print(f"Summary:")
    print(f"  Recipes extracted: {len(all_recipes)}")
    print(f"  Matched to Salesforce: {matched_count}")
    print(f"  Unmatched: {len(unmatched_recipes)}")

    if unmatched_recipes:
        print()
        print("Unmatched recipes:")
        for recipe_name in unmatched_recipes:
            print(f"  - {recipe_name}")

if __name__ == '__main__':
    markdown_folder = r'C:\Users\Abbyl\OneDrive\Desktop\Receips\new'
    existing_meals_csv = r'c:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant\data\existing_meals_export.csv'
    output_csv = r'c:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant\data\Meal__c_update_from_markdown.csv'

    print("=" * 60)
    print("Recipe Markdown Extraction Tool")
    print("=" * 60)
    print()

    # Check if files exist
    if not os.path.exists(existing_meals_csv):
        print(f"ERROR: {existing_meals_csv} not found!")
        print("Please ensure the Salesforce export exists")
        exit(1)

    if not os.path.exists(markdown_folder):
        print(f"ERROR: {markdown_folder} not found!")
        exit(1)

    create_update_csv_from_markdown(markdown_folder, existing_meals_csv, output_csv)

    print()
    print("=" * 60)
    print("Next steps:")
    print("=" * 60)
    print("1. Review the update CSV file")
    print("2. Open Salesforce Workbench (https://workbench.developerforce.com)")
    print("3. Login to your org")
    print("4. Select 'Data' -> 'Update'")
    print("5. Select 'Meal__c' object")
    print(f"6. Upload: {output_csv}")
    print("7. Map fields and update!")
    print()
    print("This will populate your Salesforce recipes with full ingredients")
    print("and instructions from your markdown files!")

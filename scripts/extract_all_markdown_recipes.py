"""
Comprehensive recipe extraction from ALL markdown sources
Extracts breakfasts, lunches, AND dinners with full ingredients and instructions
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
        r'#### (?:Ingredients?|.*Ingredients?)[:\s]*\n(.*?)(?=####|\n\n###|\*\*Instructions|\Z)',
        text,
        re.IGNORECASE | re.DOTALL
    )

    if ingredients_match:
        ingredients_text = ingredients_match.group(1).strip()
        # Clean up markdown list formatting
        ingredients_lines = []
        for line in ingredients_text.split('\n'):
            line = line.strip()
            if line and not line.startswith('**'):  # Skip bold headers
                # Remove markdown list markers
                line = re.sub(r'^[-*•]\s+\[?\s?\]?\s*', '', line)
                if line:
                    ingredients_lines.append(line)
        recipe_data['ingredients'] = '\n'.join(ingredients_lines)

    # Find Instructions section
    instructions_match = re.search(
        r'\*\*Instructions[:\s]*\*\*\n(.*?)(?=\*\*|####|\n\n###|\Z)',
        text,
        re.IGNORECASE | re.DOTALL
    )

    if instructions_match:
        instructions_text = instructions_match.group(1).strip()
        # Clean up markdown formatting
        instructions_lines = []
        for line in instructions_text.split('\n'):
            line = line.strip()
            if line and not line.startswith('**'):  # Skip bold headers
                # Remove markdown list markers
                line = re.sub(r'^[-*•]\s+\[?\s?\]?\s*', '', line)
                # Keep numbered steps
                line = re.sub(r'^\d+\.\s*\*\*([^*]+)\*\*', r'\1', line)  # Remove bold from steps
                if line:
                    instructions_lines.append(line)
        recipe_data['instructions'] = '\n'.join(instructions_lines)

    # Alternative: look for Assembly or other instruction patterns
    if not recipe_data['instructions']:
        alt_instructions = re.search(
            r'(?:#### Instructions?|#### Assembly)[:\s]*\n(.*?)(?=####|\*\*|\n\n###|\Z)',
            text,
            re.IGNORECASE | re.DOTALL
        )
        if alt_instructions:
            instructions_text = alt_instructions.group(1).strip()
            instructions_lines = []
            for line in instructions_text.split('\n'):
                line = line.strip()
                if line and not line.startswith('**'):
                    line = re.sub(r'^[-*•]\s+\[?\s?\]?\s*', '', line)
                    line = re.sub(r'^\d+\.\s*', '', line)
                    if line:
                        instructions_lines.append(line)
            recipe_data['instructions'] = '\n'.join(instructions_lines)

    return recipe_data

def extract_dinners_from_week1(markdown_file):
    """Extract dinner recipes from Week_1_Meal_Plan_5_People.md"""

    with open(markdown_file, 'r', encoding='utf-8') as f:
        content = f.read()

    recipes = {}

    # Define dinner patterns for Week 1
    dinner_recipes = [
        ('Baked Lemon Pepper Chicken', r'### \*\*DINNER: Baked Lemon Pepper Chicken[^\n]*\n(.*?)(?=\n---|\n##|\Z)'),
        ('Mediterranean Sheet Pan Chicken', r'### \*\*DINNER: Mediterranean Sheet Pan Chicken[^\n]*\n(.*?)(?=\n---|\n##|\Z)'),
        ('Quick Turkey & Veggie Stir-Fry', r'### \*\*DINNER: Quick Turkey & Veggie Stir-Fry[^\n]*\n(.*?)(?=\n---|\n##|\Z)'),
        ('One-Pot Creamy Garlic Pasta', r'### \*\*DINNER: One-Pot Creamy Garlic Pasta[^\n]*\n(.*?)(?=\n---|\n##|\Z)'),
        ('Sheet Pan Chicken Fajitas', r'### \*\*DINNER: Sheet Pan Chicken Fajitas[^\n]*\n(.*?)(?=\n---|\n##|\Z)'),
        ('Baked Salmon with Herb Butter', r'### \*\*DINNER: Baked Salmon with Herb Butter[^\n]*\n(.*?)(?=\n---|\n##|\Z)'),
        ('Slow Cooker Chicken & Vegetable Soup', r'### \*\*DINNER: Slow Cooker Chicken & Vegetable Soup[^\n]*\n(.*?)(?=\n---|\n##|\Z)')
    ]

    for recipe_name, pattern in dinner_recipes:
        match = re.search(pattern, content, re.DOTALL | re.IGNORECASE)
        if match:
            recipe_text = match.group(1)
            recipe_data = parse_recipe_from_markdown_section(recipe_text, recipe_name)
            if recipe_data['ingredients'] or recipe_data['instructions']:
                recipes[recipe_name] = recipe_data
                print(f"  Extracted: {recipe_name}")

    return recipes

def extract_breakfasts(markdown_file):
    """Extract breakfast recipes"""

    with open(markdown_file, 'r', encoding='utf-8') as f:
        content = f.read()

    recipes = {}

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

def extract_lunches(markdown_file):
    """Extract lunch recipes"""

    with open(markdown_file, 'r', encoding='utf-8') as f:
        content = f.read()

    recipes = {}

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

    # Try partial match
    for meal_name in existing_meals:
        if recipe_name.lower() in meal_name.lower():
            return meal_name
        if meal_name.lower() in recipe_name.lower():
            return meal_name

    # Try fuzzy matching - remove common words
    recipe_keywords = set(recipe_name.lower().replace('&', '').replace('-', ' ').split())
    best_match = None
    best_score = 0

    for meal_name in existing_meals:
        meal_keywords = set(meal_name.lower().replace('&', '').replace('-', ' ').split())
        common_keywords = recipe_keywords.intersection(meal_keywords)
        score = len(common_keywords)

        if score > best_score and score >= 2:
            best_score = score
            best_match = meal_name

    return best_match

def create_comprehensive_update_csv(source_folders, existing_meals_csv, output_csv):
    """
    Extract ALL recipes from markdown files and create comprehensive update CSV
    """

    # Read existing meals from Salesforce
    existing_meals = {}
    with open(existing_meals_csv, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row['Name'].strip():
                existing_meals[row['Name']] = row['Id']

    print(f"Loaded {len(existing_meals)} existing meals from Salesforce")
    print()

    # Extract recipes from all sources
    all_recipes = {}

    # 1. Breakfast recipes
    breakfast_file1 = r'C:\Users\Abbyl\OneDrive\Desktop\Receips\new\Grab_and_Go_Breakfasts_Guide.md'
    breakfast_file2 = r'C:\Users\Abbyl\OneDrive\Desktop\Summary Artifacts and  Documents from Claude\Household\Grab_and_Go_Breakfasts_Guide.md'

    for breakfast_file in [breakfast_file1, breakfast_file2]:
        if os.path.exists(breakfast_file):
            print(f"Extracting breakfast recipes from: {os.path.basename(breakfast_file)}")
            breakfast_recipes = extract_breakfasts(breakfast_file)
            all_recipes.update(breakfast_recipes)
            print(f"  Found {len(breakfast_recipes)} breakfast recipes")
            print()
            break

    # 2. Lunch recipes
    lunch_file1 = r'C:\Users\Abbyl\OneDrive\Desktop\Receips\new\Healthy_Lunch_Bento_Guide.md'
    lunch_file2 = r'C:\Users\Abbyl\OneDrive\Desktop\Summary Artifacts and  Documents from Claude\Household\Healthy_Lunch_Bento_Guide.md'

    for lunch_file in [lunch_file1, lunch_file2]:
        if os.path.exists(lunch_file):
            print(f"Extracting lunch recipes from: {os.path.basename(lunch_file)}")
            lunch_recipes = extract_lunches(lunch_file)
            all_recipes.update(lunch_recipes)
            print(f"  Found {len(lunch_recipes)} lunch recipes")
            print()
            break

    # 3. Dinner recipes from Week 1 meal plan
    dinner_file = r'C:\Users\Abbyl\OneDrive\Desktop\Summary Artifacts and  Documents from Claude\Household\Week_1_Meal_Plan_5_People.md'

    if os.path.exists(dinner_file):
        print(f"Extracting dinner recipes from: {os.path.basename(dinner_file)}")
        dinner_recipes = extract_dinners_from_week1(dinner_file)
        all_recipes.update(dinner_recipes)
        print(f"  Found {len(dinner_recipes)} dinner recipes")
        print()

    print(f"Total recipes extracted from all sources: {len(all_recipes)}")
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

        print(f"SUCCESS: Created comprehensive update CSV with {len(updates)} recipes")
        print(f"  File: {output_csv}")
    else:
        print("ERROR: No updates to write")

    # Summary
    print()
    print(f"=" * 60)
    print(f"EXTRACTION SUMMARY:")
    print(f"=" * 60)
    print(f"  Total recipes extracted: {len(all_recipes)}")
    print(f"  Successfully matched to Salesforce: {matched_count}")
    print(f"  Unmatched (not in Salesforce): {len(unmatched_recipes)}")
    print()

    if unmatched_recipes:
        print("Unmatched recipes (these won't be imported):")
        for recipe_name in unmatched_recipes:
            print(f"  - {recipe_name}")
        print()

    print(f"Ready to import {matched_count} recipes with full ingredients and instructions!")

if __name__ == '__main__':
    source_folders = [
        r'C:\Users\Abbyl\OneDrive\Desktop\Receips\new',
        r'C:\Users\Abbyl\OneDrive\Desktop\Summary Artifacts and  Documents from Claude\Household'
    ]

    existing_meals_csv = r'c:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant\data\existing_meals_export.csv'
    output_csv = r'c:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant\data\Meal__c_comprehensive_update.csv'

    print("=" * 60)
    print("COMPREHENSIVE RECIPE EXTRACTION FROM ALL MARKDOWN SOURCES")
    print("=" * 60)
    print()
    print("Sources:")
    print("  - Grab-and-Go Breakfasts Guide (7 recipes)")
    print("  - Healthy Lunch & Bento Guide (7 recipes)")
    print("  - Week 1 Meal Plan (7 dinner recipes)")
    print("  TOTAL: Up to 21 recipes with full details!")
    print()

    # Check if files exist
    if not os.path.exists(existing_meals_csv):
        print(f"ERROR: {existing_meals_csv} not found!")
        exit(1)

    create_comprehensive_update_csv(source_folders, existing_meals_csv, output_csv)

    print()
    print("=" * 60)
    print("NEXT STEPS:")
    print("=" * 60)
    print("1. Review the update CSV file")
    print("2. Open Salesforce Workbench (https://workbench.developerforce.com)")
    print("3. Login to your org")
    print("4. Select 'Data' -> 'Update'")
    print("5. Select 'Meal__c' object")
    print(f"6. Upload: {output_csv}")
    print("7. Map the fields:")
    print("   - Id -> Id")
    print("   - Ingredients__c -> Ingredients")
    print("   - Instructions__c -> Instructions")
    print("   - Recipe_Content__c -> Recipe Content")
    print("8. Click 'Update' and confirm!")
    print()
    print("This will populate your Salesforce recipes with complete")
    print("ingredients, measurements, and cooking instructions!")

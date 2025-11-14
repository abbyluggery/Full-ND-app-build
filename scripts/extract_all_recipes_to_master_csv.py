"""
Extract ALL 21 recipes from markdown files to a master CSV for user review
User can then standardize names and match to Salesforce records
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

    # Find Ingredients section - multiple patterns
    ingredients_patterns = [
        r'#### Ingredients?[:\s]*\n(.*?)(?=####|\*\*Instructions|\n\n###|\Z)',
        r'#### .*Ingredients?[:\s]*\n(.*?)(?=####|\*\*Instructions|\n\n###|\Z)',
    ]

    for pattern in ingredients_patterns:
        ingredients_match = re.search(pattern, text, re.IGNORECASE | re.DOTALL)
        if ingredients_match:
            ingredients_text = ingredients_match.group(1).strip()
            # Clean up markdown list formatting
            ingredients_lines = []
            for line in ingredients_text.split('\n'):
                line = line.strip()
                if line and not line.startswith('**'):  # Skip bold headers
                    # Remove markdown list markers
                    line = re.sub(r'^[-*•]\s+\[?\s?\]?\s*', '', line)
                    if line and not line.startswith('####'):
                        ingredients_lines.append(line)
            recipe_data['ingredients'] = '\n'.join(ingredients_lines)
            break

    # Find Instructions section - multiple patterns
    instructions_patterns = [
        r'\*\*Instructions[:\s]*\*\*\n(.*?)(?=\*\*(?!Instructions)|####|\n\n###|\Z)',
        r'#### Instructions?[:\s]*\n(.*?)(?=####|\*\*|\n\n###|\Z)',
        r'#### Assembly[:\s]*\n(.*?)(?=####|\*\*|\n\n###|\Z)',
    ]

    for pattern in instructions_patterns:
        instructions_match = re.search(pattern, text, re.IGNORECASE | re.DOTALL)
        if instructions_match:
            instructions_text = instructions_match.group(1).strip()
            # Clean up markdown formatting
            instructions_lines = []
            for line in instructions_text.split('\n'):
                line = line.strip()
                if line and not line.startswith('**') and not line.startswith('####'):
                    # Remove markdown list markers
                    line = re.sub(r'^[-*•]\s+\[?\s?\]?\s*', '', line)
                    # Keep numbered steps
                    line = re.sub(r'^\d+\.\s*\*\*([^*]+)\*\*', r'\1', line)
                    if line:
                        instructions_lines.append(line)
            recipe_data['instructions'] = '\n'.join(instructions_lines)
            break

    return recipe_data

def extract_all_recipes_to_master_csv(output_csv):
    """Extract ALL recipes from all markdown sources to one master CSV"""

    all_recipes = []

    # Source 1: Breakfast recipes
    breakfast_file = r'C:\Users\Abbyl\OneDrive\Desktop\Receips\new\Grab_and_Go_Breakfasts_Guide.md'

    if os.path.exists(breakfast_file):
        print("Extracting breakfast recipes...")
        with open(breakfast_file, 'r', encoding='utf-8') as f:
            content = f.read()

        breakfast_recipes = [
            'Overnight Steel-Cut Oats',
            'Greek Yogurt Parfait Jars',
            'Egg Muffin Cups',
            'Peanut Butter Banana Overnight Oats',
            'Whole Wheat Toast with Toppings Bar',
            'Breakfast Burrito Wraps',
            'Protein Smoothie Bowls'
        ]

        patterns = [
            r'### \*\*SUNDAY: Overnight Steel-Cut Oats[^\n]*\n(.*?)(?=\n---|\Z)',
            r'### \*\*MONDAY: Greek Yogurt Parfait Jars[^\n]*\n(.*?)(?=\n---|\Z)',
            r'### \*\*TUESDAY: Egg Muffin Cups[^\n]*\n(.*?)(?=\n---|\Z)',
            r'### \*\*WEDNESDAY: Peanut Butter Banana Overnight Oats[^\n]*\n(.*?)(?=\n---|\Z)',
            r'### \*\*THURSDAY: Whole Wheat Toast with Toppings Bar[^\n]*\n(.*?)(?=\n---|\Z)',
            r'### \*\*FRIDAY: Breakfast Burrito Wraps[^\n]*\n(.*?)(?=\n---|\Z)',
            r'### \*\*SATURDAY: Protein Smoothie Bowls[^\n]*\n(.*?)(?=\n---|\Z)'
        ]

        for recipe_name, pattern in zip(breakfast_recipes, patterns):
            match = re.search(pattern, content, re.DOTALL | re.IGNORECASE)
            if match:
                recipe_text = match.group(1)
                recipe_data = parse_recipe_from_markdown_section(recipe_text, recipe_name)

                all_recipes.append({
                    'Markdown_Recipe_Name': recipe_name,
                    'Suggested_Salesforce_Name': recipe_name,
                    'Category': 'Breakfast',
                    'Ingredients': recipe_data['ingredients'],
                    'Instructions': recipe_data['instructions'],
                    'Recipe_Content': recipe_data['full_recipe'][:32768],
                    'Source_File': 'Grab_and_Go_Breakfasts_Guide.md',
                    'Extracted': 'Yes' if recipe_data['ingredients'] else 'No'
                })
                print(f"  [{recipe_name}]: {'Extracted' if recipe_data['ingredients'] else 'Found but empty'}")

    # Source 2: Lunch recipes
    lunch_file = r'C:\Users\Abbyl\OneDrive\Desktop\Receips\new\Healthy_Lunch_Bento_Guide.md'

    if os.path.exists(lunch_file):
        print("\nExtracting lunch recipes...")
        with open(lunch_file, 'r', encoding='utf-8') as f:
            content = f.read()

        lunch_recipes = [
            'Mason Jar Salads',
            'Turkey & Veggie Wrap',
            'Chicken & Quinoa Buddha Bowl',
            'DIY Bento Box',
            'Mediterranean Pasta Salad',
            'Chicken Caesar Salad',
            'Tuna & White Bean Salad'
        ]

        patterns = [
            r'### \*\*SUNDAY PREP: Mason Jar Salads[^\n]*\n(.*?)(?=\n---|\Z)',
            r'### \*\*MONDAY: Turkey & Veggie Wrap[^\n]*\n(.*?)(?=\n---|\Z)',
            r'### \*\*TUESDAY: Chicken & Quinoa Buddha Bowl[^\n]*\n(.*?)(?=\n---|\Z)',
            r'### \*\*WEDNESDAY: DIY Bento Box[^\n]*\n(.*?)(?=\n---|\Z)',
            r'### \*\*THURSDAY: Mediterranean Pasta Salad[^\n]*\n(.*?)(?=\n---|\Z)',
            r'### \*\*FRIDAY: Chicken Caesar Salad[^\n]*\n(.*?)(?=\n---|\Z)',
            r'### \*\*SATURDAY: Tuna & White Bean Salad[^\n]*\n(.*?)(?=\n---|\Z)'
        ]

        for recipe_name, pattern in zip(lunch_recipes, patterns):
            match = re.search(pattern, content, re.DOTALL | re.IGNORECASE)
            if match:
                recipe_text = match.group(1)
                recipe_data = parse_recipe_from_markdown_section(recipe_text, recipe_name)

                all_recipes.append({
                    'Markdown_Recipe_Name': recipe_name,
                    'Suggested_Salesforce_Name': recipe_name,
                    'Category': 'Lunch',
                    'Ingredients': recipe_data['ingredients'],
                    'Instructions': recipe_data['instructions'],
                    'Recipe_Content': recipe_data['full_recipe'][:32768],
                    'Source_File': 'Healthy_Lunch_Bento_Guide.md',
                    'Extracted': 'Yes' if recipe_data['ingredients'] else 'No'
                })
                print(f"  [{recipe_name}]: {'Extracted' if recipe_data['ingredients'] else 'Found but empty'}")

    # Source 3: Dinner recipes from Week 1 Meal Plan
    dinner_file = r'C:\Users\Abbyl\OneDrive\Desktop\Summary Artifacts and  Documents from Claude\Household\Week_1_Meal_Plan_5_People.md'

    if os.path.exists(dinner_file):
        print("\nExtracting dinner recipes...")
        with open(dinner_file, 'r', encoding='utf-8') as f:
            content = f.read()

        dinner_recipes = [
            ('Baked Lemon Pepper Chicken', r'### \*\*DINNER: Baked Lemon Pepper Chicken[^\n]*\n(.*?)(?=\n---|\n## 🍽️)'),
            ('Mediterranean Sheet Pan Chicken', r'### \*\*DINNER: Mediterranean Sheet Pan Chicken[^\n]*\n(.*?)(?=\n---|\n## 🍽️)'),
            ('Quick Turkey & Veggie Stir-Fry', r'### \*\*DINNER: Quick Turkey & Veggie Stir-Fry[^\n]*\n(.*?)(?=\n---|\n## 🍽️)'),
            ('One-Pot Creamy Garlic Pasta', r'### \*\*DINNER: One-Pot Creamy Garlic Pasta[^\n]*\n(.*?)(?=\n---|\n## 🍽️)'),
            ('Sheet Pan Chicken Fajitas', r'### \*\*DINNER: Sheet Pan Chicken Fajitas[^\n]*\n(.*?)(?=\n---|\n## 🍽️)'),
            ('Baked Salmon with Herb Butter', r'### \*\*DINNER: Baked Salmon with Herb Butter[^\n]*\n(.*?)(?=\n---|\n## 🍽️)'),
            ('Slow Cooker Chicken & Vegetable Soup', r'### \*\*DINNER: Slow Cooker Chicken & Vegetable Soup[^\n]*\n(.*?)(?=\n---|\n## 🍽️)')
        ]

        for recipe_name, pattern in dinner_recipes:
            match = re.search(pattern, content, re.DOTALL | re.IGNORECASE)
            if match:
                recipe_text = match.group(1)

                # For dinners, extract all ingredient sections (they may have multiple sub-recipes)
                all_ingredients = []
                all_instructions = []

                # Find all #### Ingredients or #### [Name]: sections
                ingredient_sections = re.finditer(r'#### ([^:\n]+)[:\s]*\n(.*?)(?=####|\*\*|(?=\n\n###)|\Z)', recipe_text, re.DOTALL)
                for section in ingredient_sections:
                    section_name = section.group(1).strip()
                    section_content = section.group(2).strip()

                    # Clean up the content
                    lines = []
                    for line in section_content.split('\n'):
                        line = line.strip()
                        if line and not line.startswith('**'):
                            line = re.sub(r'^[-*•]\s+', '', line)
                            if line and not line.startswith('####'):
                                lines.append(line)

                    if lines:
                        if 'ingredient' in section_name.lower():
                            all_ingredients.extend(lines)
                        else:
                            # This might be a sub-recipe component
                            all_ingredients.append(f"\n{section_name}:")
                            all_ingredients.extend(lines)

                # Find instructions
                instructions_match = re.search(r'\*\*Instructions[:\s]*\*\*\n(.*?)(?=\*\*(?!Instructions)|####|\n\n###|\Z)', recipe_text, re.IGNORECASE | re.DOTALL)
                if instructions_match:
                    instructions_text = instructions_match.group(1).strip()
                    for line in instructions_text.split('\n'):
                        line = line.strip()
                        if line and not line.startswith('**'):
                            line = re.sub(r'^[-*•]\s+', '', line)
                            line = re.sub(r'^\d+\.\s*\*\*([^*]+)\*\*', r'\1', line)
                            if line:
                                all_instructions.append(line)

                all_recipes.append({
                    'Markdown_Recipe_Name': recipe_name,
                    'Suggested_Salesforce_Name': recipe_name,
                    'Category': 'Dinner',
                    'Ingredients': '\n'.join(all_ingredients),
                    'Instructions': '\n'.join(all_instructions),
                    'Recipe_Content': recipe_text[:32768],
                    'Source_File': 'Week_1_Meal_Plan_5_People.md',
                    'Extracted': 'Yes' if all_ingredients else 'Partial'
                })
                print(f"  [{recipe_name}]: {'Extracted' if all_ingredients else 'Found but needs review'}")

    # Write to CSV
    if all_recipes:
        fieldnames = [
            'Markdown_Recipe_Name',
            'Suggested_Salesforce_Name',
            'Category',
            'Ingredients',
            'Instructions',
            'Recipe_Content',
            'Source_File',
            'Extracted'
        ]

        with open(output_csv, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(all_recipes)

        print(f"\n{'='*60}")
        print(f"SUCCESS! Extracted {len(all_recipes)} recipes to CSV")
        print(f"{'='*60}")
        print(f"\nFile created: {output_csv}")
        print(f"\nBreakdown:")
        print(f"  Breakfast: {sum(1 for r in all_recipes if r['Category'] == 'Breakfast')}")
        print(f"  Lunch: {sum(1 for r in all_recipes if r['Category'] == 'Lunch')}")
        print(f"  Dinner: {sum(1 for r in all_recipes if r['Category'] == 'Dinner')}")
        print(f"\nFully extracted: {sum(1 for r in all_recipes if r['Extracted'] == 'Yes')}")
        print(f"Partial/needs review: {sum(1 for r in all_recipes if r['Extracted'] != 'Yes')}")

        return all_recipes
    else:
        print("ERROR: No recipes extracted")
        return []

if __name__ == '__main__':
    output_csv = r'c:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant\data\ALL_21_RECIPES_MASTER.csv'

    print("="*60)
    print("MASTER RECIPE EXTRACTION - ALL 21 RECIPES")
    print("="*60)
    print()

    recipes = extract_all_recipes_to_master_csv(output_csv)

    print("\n" + "="*60)
    print("NEXT STEPS:")
    print("="*60)
    print()
    print("1. Open the CSV file in Excel:")
    print(f"   {output_csv}")
    print()
    print("2. Review the 'Markdown_Recipe_Name' column")
    print()
    print("3. Edit 'Suggested_Salesforce_Name' to match your existing")
    print("   Salesforce meal names (or create new ones)")
    print()
    print("4. Once names are standardized, you can either:")
    print("   a) Import via Workbench (for updates to existing records)")
    print("   b) Create new Meal records (for recipes not in Salesforce)")
    print()
    print("5. Check 'Extracted' column - 'Yes' means full data extracted")
    print()
    print("The CSV has all the data ready - ingredients, instructions,")
    print("and full recipe content for all 21 recipes!")

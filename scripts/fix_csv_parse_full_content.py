"""
Fix the master CSV by properly parsing Recipe_Content into Ingredients and Instructions
This ensures shopping list functionality will work properly
"""
import csv
import re

def parse_full_recipe_content(recipe_content):
    """Extract ingredients and instructions from full recipe content"""

    ingredients = []
    instructions = []

    # Find ingredients section
    ingredients_match = re.search(
        r'#### Ingredients?[:\s]*(?:\([^)]+\))?\s*\n(.*?)(?=####|\*\*(?:Instructions|Assembly|TO SERVE|MEAL PREP|Nutrition|COST|SIDE)|\n\n###|\Z)',
        recipe_content,
        re.IGNORECASE | re.DOTALL
    )

    if ingredients_match:
        ingredients_text = ingredients_match.group(1).strip()
        for line in ingredients_text.split('\n'):
            line = line.strip()
            if line and not line.startswith('**') and not line.startswith('####'):
                # Remove markdown list markers
                line = re.sub(r'^[-*•]\s+', '', line)
                if line:
                    ingredients.append(line)

    # Try to find all ingredient subsections (for complex recipes)
    if not ingredients:
        # Look for patterns like "#### Baked Lemon Pepper Chicken:" followed by ingredient list
        all_ingredient_sections = re.finditer(
            r'#### ([^:\n]+)[:\s]*\n(.*?)(?=\n\*\*Instructions|\n####|\n\*\*|\Z)',
            recipe_content,
            re.IGNORECASE | re.DOTALL
        )

        for section in all_ingredient_sections:
            section_name = section.group(1).strip()
            section_content = section.group(2).strip()

            # Check if this looks like ingredients (has measurements, food items)
            if any(word in section_content.lower() for word in ['cup', 'tbsp', 'tsp', 'oz', 'lb', 'lbs', 'gram', 'ml', 'pieces', 'cloves']):
                if section_name.lower() not in ['instructions', 'assembly', 'to serve', 'side']:
                    # Add section name as header if it's a sub-recipe
                    if section_name.lower() not in ['ingredients', 'ingredient']:
                        if ingredients:  # Add newline before new section (except first)
                            ingredients.append('')
                        ingredients.append(f"{section_name}:")

                    for line in section_content.split('\n'):
                        line = line.strip()
                        if line and not line.startswith('**') and not line.startswith('####'):
                            line = re.sub(r'^[-*•]\s+', '', line)
                            if line and not line.lower().startswith('instructions:'):
                                ingredients.append(line)

    # Find instructions section
    instructions_patterns = [
        r'\*\*Instructions[:\s]*\*\*\s*\n(.*?)(?=\*\*(?!Instructions)|####|\n\n###|\Z)',
        r'#### Instructions?[:\s]*\n(.*?)(?=####|\*\*|\n\n###|\Z)',
        r'#### Assembly[:\s]*\n(.*?)(?=####|\*\*|\n\n###|\Z)',
    ]

    for pattern in instructions_patterns:
        instructions_match = re.search(pattern, recipe_content, re.IGNORECASE | re.DOTALL)
        if instructions_match:
            instructions_text = instructions_match.group(1).strip()
            for line in instructions_text.split('\n'):
                line = line.strip()
                if line and not line.startswith('**') and not line.startswith('####'):
                    # Remove markdown list markers but keep numbers
                    line = re.sub(r'^[-*•]\s+', '', line)
                    # Clean up bold text around numbered steps
                    line = re.sub(r'^\d+\.\s*\*\*([^*]+)\*\*\s*', r'\1 ', line)
                    if line and not line.startswith('Nutrition') and not line.startswith('Calories'):
                        instructions.append(line)
            if instructions:
                break

    # If no instructions found with standard patterns, look for **Instructions:** within sections
    if not instructions:
        all_instruction_blocks = re.finditer(
            r'\*\*Instructions[:\s]*\*\*\s*\n(.*?)(?=\n####|\n\*\*[A-Z]|\Z)',
            recipe_content,
            re.IGNORECASE | re.DOTALL
        )

        for block in all_instruction_blocks:
            block_text = block.group(1).strip()
            for line in block_text.split('\n'):
                line = line.strip()
                if line and not line.startswith('**') and not line.startswith('####'):
                    line = re.sub(r'^[-*•]\s+', '', line)
                    line = re.sub(r'^\d+\.\s*\*\*([^*]+)\*\*\s*', r'\1', line)
                    if line and not any(skip in line for skip in ['HEART-HEALTHY', 'TOTAL TIME', 'CALORIES', 'SODIUM', 'Nutrition']):
                        instructions.append(line)

    return '\n'.join(ingredients), '\n'.join(instructions)

def fix_master_csv(input_csv, output_csv):
    """Read master CSV and properly parse Recipe_Content into Ingredients and Instructions"""

    fixed_recipes = []

    with open(input_csv, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)

        for row in reader:
            recipe_name = row['Markdown_Recipe_Name']
            recipe_content = row['Recipe_Content']
            current_ingredients = row['Ingredients']
            current_instructions = row['Instructions']

            # If ingredients or instructions are missing/incomplete, parse from Recipe_Content
            if not current_ingredients or len(current_ingredients) < 20:
                print(f"Fixing: {recipe_name}")
                parsed_ingredients, parsed_instructions = parse_full_recipe_content(recipe_content)

                if parsed_ingredients:
                    row['Ingredients'] = parsed_ingredients
                    print(f"  - Extracted {len(parsed_ingredients.split(chr(10)))} ingredient lines")

                if parsed_instructions:
                    row['Instructions'] = parsed_instructions
                    print(f"  - Extracted {len(parsed_instructions.split(chr(10)))} instruction lines")

                # Update extracted status
                if parsed_ingredients and parsed_instructions:
                    row['Extracted'] = 'Yes'
                elif parsed_ingredients:
                    row['Extracted'] = 'Partial'
            else:
                print(f"Keeping: {recipe_name} (already has data)")

            fixed_recipes.append(row)

    # Write fixed CSV
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
        writer.writerows(fixed_recipes)

    print(f"\n{'='*60}")
    print(f"FIXED CSV CREATED!")
    print(f"{'='*60}")
    print(f"File: {output_csv}")
    print(f"\nTotal recipes: {len(fixed_recipes)}")
    print(f"With ingredients: {sum(1 for r in fixed_recipes if r['Ingredients'])}")
    print(f"With instructions: {sum(1 for r in fixed_recipes if r['Instructions'])}")
    print(f"Fully extracted: {sum(1 for r in fixed_recipes if r['Extracted'] == 'Yes')}")

if __name__ == '__main__':
    input_csv = r'c:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant\data\ALL_21_RECIPES_MASTER.csv'
    output_csv = r'c:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant\data\ALL_21_RECIPES_FIXED.csv'

    print("="*60)
    print("FIXING MASTER CSV - PARSING FULL RECIPE CONTENT")
    print("="*60)
    print()
    print("This will properly extract Ingredients and Instructions")
    print("from the Recipe_Content field for shopping list functionality")
    print()

    fix_master_csv(input_csv, output_csv)

    print("\n" + "="*60)
    print("NEXT STEP:")
    print("="*60)
    print()
    print("Review the fixed CSV and then I can create an import file")
    print("that matches these recipes to your Salesforce meal IDs!")

"""
Enriches existing Meal__c records with timing and categorization data
Reads from existing_meals_export.csv and estimates required values
Outputs Salesforce-ready CSV for import
"""

import csv
from pathlib import Path
from collections import Counter

def estimate_protein_type(meal_name):
    """Estimate protein type based on meal name"""
    name_lower = meal_name.lower()

    # Check for specific proteins
    if any(word in name_lower for word in ['chicken', 'poultry']):
        return 'Chicken'
    elif any(word in name_lower for word in ['beef', 'steak', 'burger']):
        return 'Beef'
    elif any(word in name_lower for word in ['pork', 'bacon', 'ham', 'sausage']):
        return 'Pork'
    elif any(word in name_lower for word in ['fish', 'salmon', 'tuna', 'tilapia', 'cod', 'shrimp', 'seafood', 'crab']):
        return 'Fish/Seafood'
    elif any(word in name_lower for word in ['turkey']):
        return 'Turkey'
    elif any(word in name_lower for word in ['egg', 'omelet', 'frittata', 'quiche']):
        return 'Eggs'
    elif any(word in name_lower for word in ['veggie', 'vegetable', 'vegetarian', 'bean', 'lentil', 'tofu', 'quinoa']):
        return 'Vegetarian'
    else:
        return 'Other'

def estimate_prep_time(meal_name):
    """Estimate prep time based on meal type"""
    name_lower = meal_name.lower()

    # Quick meals (5 min prep)
    if any(word in name_lower for word in ['smoothie', 'yogurt', 'parfait', 'overnight', 'wrap', 'sandwich']):
        return 5
    # Medium prep (10-15 min)
    elif any(word in name_lower for word in ['salad', 'bowl', 'scramble', 'stir fry', 'oats']):
        return 10
    # Longer prep (15-20 min)
    elif any(word in name_lower for word in ['casserole', 'bake', 'roast', 'soup', 'stew', 'curry']):
        return 15
    else:
        return 10  # Default

def estimate_cook_time(meal_name, protein_type):
    """Estimate cook time based on meal type and protein"""
    name_lower = meal_name.lower()

    # No cook meals
    if any(word in name_lower for word in ['overnight', 'parfait', 'yogurt', 'wrap', 'sandwich', 'smoothie']):
        return 0
    # Quick cook (10-15 min)
    elif any(word in name_lower for word in ['scramble', 'stir fry', 'sauté', 'oats']):
        return 12
    # Medium cook (20-30 min)
    elif any(word in name_lower for word in ['bake', 'roast', 'sheet pan']):
        return 25
    # Longer cook (30-45 min)
    elif any(word in name_lower for word in ['casserole', 'stew', 'braise', 'slow']):
        return 40
    # Soup/curry
    elif any(word in name_lower for word in ['soup', 'curry', 'chili']):
        return 30
    # Fish cooks fast
    elif protein_type == 'Fish/Seafood':
        return 15
    # Chicken
    elif protein_type == 'Chicken':
        return 20
    # Beef/Pork
    elif protein_type in ['Beef', 'Pork']:
        return 25
    else:
        return 20  # Default

# Load existing meals
data_dir = Path('data')
input_file = data_dir / 'existing_meals_export.csv'

meals = []
with open(input_file, 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        meal_name = row['Name']
        meal_id = row['Id']

        # Estimate values
        protein_type = estimate_protein_type(meal_name)
        prep_time = estimate_prep_time(meal_name)
        cook_time = estimate_cook_time(meal_name, protein_type)
        total_time = prep_time + cook_time
        weeknight = total_time <= 30

        meals.append({
            'Id': meal_id,
            'Name': meal_name,
            'Protein_Type__c': protein_type,
            'Prep_Time_Minutes__c': prep_time,
            'Cook_Time_Minutes__c': cook_time,
            'Servings__c': 5,  # Default to 5 people
            'Total_Time': total_time,
            'Weeknight_Friendly': weeknight
        })

print(f"Loaded {len(meals)} existing meals")

# Calculate statistics
protein_counts = Counter(m['Protein_Type__c'] for m in meals)
prep_times = [m['Prep_Time_Minutes__c'] for m in meals]
cook_times = [m['Cook_Time_Minutes__c'] for m in meals]
total_times = [m['Total_Time'] for m in meals]
weeknight_count = sum(1 for m in meals if m['Weeknight_Friendly'])

print("\n=== SUMMARY STATISTICS ===")
print(f"\nProtein Type Distribution:")
for protein, count in protein_counts.most_common():
    print(f"  {protein}: {count}")

print(f"\nPrep Time Range: {min(prep_times)}-{max(prep_times)} minutes")
print(f"Cook Time Range: {min(cook_times)}-{max(cook_times)} minutes")
print(f"Total Time Range: {min(total_times)}-{max(total_times)} minutes")

print(f"\nWeeknight Friendly Meals: {weeknight_count} of {len(meals)} ({weeknight_count/len(meals)*100:.1f}%)")

# Show sample
print("\n=== SAMPLE ESTIMATES (First 15 meals) ===")
print(f"{'Name':<40} {'Protein':<15} {'Prep':>5} {'Cook':>5} {'Total':>6} {'Week?':>6}")
print("-" * 92)
for meal in meals[:15]:
    wn = "Yes" if meal['Weeknight_Friendly'] else "No"
    print(f"{meal['Name']:<40} {meal['Protein_Type__c']:<15} {meal['Prep_Time_Minutes__c']:>5} {meal['Cook_Time_Minutes__c']:>5} {meal['Total_Time']:>6} {wn:>6}")

# Create import file (only fields needed for Salesforce)
output_file = data_dir / 'Meal__c_timing_update.csv'
import_fields = ['Id', 'Prep_Time_Minutes__c', 'Cook_Time_Minutes__c', 'Servings__c', 'Protein_Type__c']

with open(output_file, 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=import_fields)
    writer.writeheader()
    for meal in meals:
        writer.writerow({k: meal[k] for k in import_fields})

print(f"\n✅ Created import file: {output_file}")
print(f"   Records: {len(meals)}")
print(f"   Fields: {', '.join(import_fields)}")

# Create review file (with names for verification)
review_file = data_dir / 'Meal_Timing_Review.csv'
review_fields = ['Id', 'Name', 'Protein_Type__c', 'Prep_Time_Minutes__c', 'Cook_Time_Minutes__c', 'Total_Time', 'Weeknight_Friendly', 'Servings__c']

with open(review_file, 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=review_fields)
    writer.writeheader()
    writer.writerows(meals)

print(f"✅ Created review file: {review_file}")
print(f"   Open this in Excel to verify/adjust estimates before importing")

print("\n=== NEXT STEPS ===")
print("1. Open: data/Meal_Timing_Review.csv in Excel")
print("2. Review estimated values - adjust any that look incorrect")
print("3. If you make changes, update data/Meal__c_timing_update.csv with the same values")
print("4. Import via Workbench or Data Loader:")
print("   - Operation: UPDATE")
print("   - Object: Meal__c")
print("   - File: Meal__c_timing_update.csv")
print("   - Field Mapping:")
print("     * Id → Record ID")
print("     * Prep_Time_Minutes__c → Prep Time Minutes")
print("     * Cook_Time_Minutes__c → Cook Time Minutes")
print("     * Servings__c → Servings")
print("     * Protein_Type__c → Protein Type")
print("\n⚠️  IMPORTANT: These are ESTIMATES based on meal names.")
print("   Review the Meal_Timing_Review.csv file and adjust as needed!")
print("\n💡 TIP: After import, the formula fields will auto-calculate:")
print("   - Total_Time_Minutes__c = Prep + Cook")
print("   - Is_Weeknight_Friendly__c = (Total ≤ 30 min)")

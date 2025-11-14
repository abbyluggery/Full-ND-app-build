/**
 * @description Parses ingredient text from Meal__c.Ingredients__c field and creates Meal_Ingredient__c records
 * - Parses format: "2 cups flour", "1 lb chicken breast", "Salt and pepper to taste"
 * - Automatically categorizes ingredients
 * - Handles plural units (cups -> cup, lbs -> lb)
 * - Creates structured Meal_Ingredient__c records for shopping list generation
 */
public with sharing class IngredientParser {

    // Unit mappings (plural to singular)
    private static final Map<String, String> UNIT_MAPPINGS = new Map<String, String>{
        'lbs' => 'lb',
        'pounds' => 'lb',
        'pound' => 'lb',
        'ounces' => 'oz',
        'ounce' => 'oz',
        'cups' => 'cup',
        'tablespoons' => 'tbsp',
        'tablespoon' => 'tbsp',
        'teaspoons' => 'tsp',
        'teaspoon' => 'tsp',
        'packages' => 'package',
        'cans' => 'can',
        'jars' => 'jar',
        'bottles' => 'bottle',
        'bunches' => 'bunch',
        'cloves' => 'clove',
        'pinches' => 'pinch'
    };

    // Ingredient normalization map (variations -> standard name)
    private static final Map<String, String> INGREDIENT_NORMALIZATIONS = new Map<String, String>{
        // Eggs
        'egg' => 'Eggs',
        'eggs' => 'Eggs',
        'large eggs' => 'Eggs',
        'large egg' => 'Eggs',
        'whole eggs' => 'Eggs',
        // Milk
        'milk' => 'Milk',
        'whole milk' => 'Milk',
        '2% milk' => 'Milk',
        'skim milk' => 'Milk',
        'low-fat milk' => 'Milk',
        // Oil
        'olive oil' => 'Olive Oil',
        'extra virgin olive oil' => 'Olive Oil',
        'evoo' => 'Olive Oil',
        'vegetable oil' => 'Vegetable Oil',
        'canola oil' => 'Canola Oil',
        'cooking oil' => 'Vegetable Oil',
        // Butter
        'butter' => 'Butter',
        'unsalted butter' => 'Butter',
        'salted butter' => 'Butter',
        // Salt & Pepper
        'salt' => 'Salt',
        'kosher salt' => 'Salt',
        'sea salt' => 'Salt',
        'table salt' => 'Salt',
        'pepper' => 'Black Pepper',
        'black pepper' => 'Black Pepper',
        'ground pepper' => 'Black Pepper',
        'ground black pepper' => 'Black Pepper',
        // Flour
        'flour' => 'All-Purpose Flour',
        'all-purpose flour' => 'All-Purpose Flour',
        'ap flour' => 'All-Purpose Flour',
        'white flour' => 'All-Purpose Flour',
        // Sugar
        'sugar' => 'Sugar',
        'granulated sugar' => 'Sugar',
        'white sugar' => 'Sugar',
        'brown sugar' => 'Brown Sugar',
        // Cheese
        'cheese' => 'Cheese',
        'shredded cheese' => 'Shredded Cheese',
        'grated cheese' => 'Shredded Cheese',
        // Onions & Garlic
        'onion' => 'Onion',
        'yellow onion' => 'Onion',
        'white onion' => 'Onion',
        'red onion' => 'Red Onion',
        'garlic' => 'Garlic',
        'fresh garlic' => 'Garlic',
        'garlic cloves' => 'Garlic',
        'minced garlic' => 'Garlic',
        // Chicken
        'chicken breast' => 'Chicken Breast',
        'chicken breasts' => 'Chicken Breast',
        'boneless chicken breast' => 'Chicken Breast',
        'skinless chicken breast' => 'Chicken Breast',
        'chicken thigh' => 'Chicken Thighs',
        'chicken thighs' => 'Chicken Thighs',
        // Ground meat
        'ground beef' => 'Ground Beef',
        'ground chuck' => 'Ground Beef',
        'ground turkey' => 'Ground Turkey'
    };

    // Pantry staples that are usually always on hand
    private static final Set<String> PANTRY_STAPLES = new Set<String>{
        'Salt', 'Black Pepper', 'Olive Oil', 'Vegetable Oil', 'Canola Oil',
        'All-Purpose Flour', 'Sugar', 'Brown Sugar', 'Butter',
        'Garlic', 'Onion', 'Eggs', 'Milk'
    };

    // Estimated prices by category (in dollars)
    private static final Map<String, Decimal> CATEGORY_BASE_PRICES = new Map<String, Decimal>{
        'Produce' => 2.50,
        'Meat & Seafood' => 8.00,
        'Dairy' => 4.00,
        'Pantry' => 3.00,
        'Condiments & Sauces' => 4.50,
        'Frozen' => 5.00,
        'Bakery' => 3.50,
        'Beverages' => 4.00
    };

    // Category keywords for automatic categorization
    private static final Map<String, List<String>> CATEGORY_KEYWORDS = new Map<String, List<String>>{
        'Produce' => new List<String>{
            'lettuce', 'tomato', 'onion', 'garlic', 'carrot', 'celery', 'pepper', 'spinach',
            'broccoli', 'cauliflower', 'potato', 'mushroom', 'zucchini', 'cucumber', 'avocado',
            'lemon', 'lime', 'apple', 'banana', 'berry', 'berries', 'cilantro', 'parsley', 'basil',
            'kale', 'cabbage', 'squash', 'greens', 'sprouts'
        },
        'Meat & Seafood' => new List<String>{
            'chicken', 'beef', 'pork', 'turkey', 'bacon', 'sausage', 'ham', 'steak', 'ground',
            'salmon', 'tuna', 'shrimp', 'fish', 'cod', 'tilapia', 'crab', 'lobster', 'thigh',
            'breast', 'tenderloin', 'chop', 'ribs'
        },
        'Dairy' => new List<String>{
            'milk', 'cheese', 'butter', 'cream', 'yogurt', 'sour cream', 'cheddar', 'mozzarella',
            'parmesan', 'egg', 'eggs'
        },
        'Pantry' => new List<String>{
            'flour', 'sugar', 'salt', 'pepper', 'oil', 'olive oil', 'rice', 'pasta', 'noodle',
            'bread', 'cereal', 'oats', 'honey', 'sauce', 'broth', 'stock', 'beans', 'quinoa',
            'couscous', 'breadcrumbs', 'panko', 'cornstarch', 'baking powder', 'baking soda',
            'vanilla', 'cinnamon', 'paprika', 'cumin', 'oregano', 'thyme', 'bay leaf', 'spice'
        },
        'Condiments & Sauces' => new List<String>{
            'ketchup', 'mustard', 'mayo', 'mayonnaise', 'soy sauce', 'worcestershire', 'vinegar',
            'dressing', 'salsa', 'hot sauce', 'bbq', 'barbecue', 'ranch', 'balsamic'
        },
        'Frozen' => new List<String>{
            'frozen', 'ice cream', 'peas', 'corn'
        },
        'Bakery' => new List<String>{
            'tortilla', 'bun', 'roll', 'bagel', 'croissant', 'pita'
        },
        'Beverages' => new List<String>{
            'juice', 'coffee', 'tea', 'soda', 'water', 'wine', 'beer'
        }
    };

    /**
     * @description Parses ingredients for all meals and creates Meal_Ingredient__c records
     * @param mealIds Set of Meal__c IDs to process
     * @return Number of ingredient records created
     */
    public static Integer parseIngredientsForMeals(Set<Id> mealIds) {
        // Get meals with ingredients text
        List<Meal__c> meals = [
            SELECT Id, Name, Ingredients__c
            FROM Meal__c
            WHERE Id IN :mealIds
        ];

        // Filter out meals without ingredients in code (can't filter text fields in SOQL WHERE)
        List<Meal__c> mealsWithIngredients = new List<Meal__c>();
        for (Meal__c meal : meals) {
            if (String.isNotBlank(meal.Ingredients__c)) {
                mealsWithIngredients.add(meal);
            }
        }

        // Delete existing ingredients for these meals
        List<Meal_Ingredient__c> existingIngredients = [
            SELECT Id FROM Meal_Ingredient__c WHERE Meal__c IN :mealIds
        ];
        if (!existingIngredients.isEmpty()) {
            delete existingIngredients;
        }

        // Parse and create new ingredients
        List<Meal_Ingredient__c> newIngredients = new List<Meal_Ingredient__c>();

        for (Meal__c meal : mealsWithIngredients) {
            List<Meal_Ingredient__c> mealIngredients = parseIngredientText(meal.Id, meal.Ingredients__c);
            newIngredients.addAll(mealIngredients);
        }

        if (!newIngredients.isEmpty()) {
            insert newIngredients;
        }

        return newIngredients.size();
    }

    /**
     * @description Parses ingredient text for a single meal
     * @param mealId The Meal__c record ID
     * @param ingredientText The raw ingredient text (e.g., "2 cups flour\n1 lb chicken")
     * @return List of parsed Meal_Ingredient__c records (not inserted)
     */
    private static List<Meal_Ingredient__c> parseIngredientText(Id mealId, String ingredientText) {
        List<Meal_Ingredient__c> ingredients = new List<Meal_Ingredient__c>();

        if (String.isBlank(ingredientText)) {
            return ingredients;
        }

        // Split by newlines or semicolons
        List<String> lines = ingredientText.split('[\\n;]');

        for (String line : lines) {
            line = line.trim();
            if (String.isBlank(line)) {
                continue;
            }

            Meal_Ingredient__c ingredient = parseIngredientLine(mealId, line);
            if (ingredient != null) {
                ingredients.add(ingredient);
            }
        }

        return ingredients;
    }

    /**
     * @description Parses a single ingredient line
     * @param mealId The Meal__c record ID
     * @param line Single ingredient line (e.g., "2 cups flour" or "Salt and pepper to taste")
     * @return Meal_Ingredient__c record (not inserted), or null if unparseable
     */
    private static Meal_Ingredient__c parseIngredientLine(Id mealId, String line) {
        line = line.trim().toLowerCase();

        // Pattern: [quantity] [unit] [ingredient name]
        // Examples: "2 cups flour", "1 lb chicken breast", "3 large eggs"

        Decimal quantity = 1.0;
        String unit = 'each';
        String ingredientName = line;

        // Try to extract quantity (number at start)
        Pattern quantityPattern = Pattern.compile('^([0-9\\.]+)\\s+(.+)$');
        Matcher quantityMatcher = quantityPattern.matcher(line);

        if (quantityMatcher.matches()) {
            try {
                quantity = Decimal.valueOf(quantityMatcher.group(1));
                line = quantityMatcher.group(2).trim(); // Remaining text after quantity
            } catch (Exception e) {
                // Invalid number, keep default quantity
            }
        }

        // Try to extract unit (next word after quantity)
        String[] parts = line.split('\\s+', 2);
        if (parts.size() >= 2) {
            String potentialUnit = parts[0];

            // Check if it's a known unit
            if (UNIT_MAPPINGS.containsKey(potentialUnit)) {
                unit = UNIT_MAPPINGS.get(potentialUnit);
                ingredientName = parts[1].trim();
            } else if (isValidUnit(potentialUnit)) {
                unit = potentialUnit;
                ingredientName = parts[1].trim();
            } else {
                // Not a unit, it's part of the ingredient name
                ingredientName = line;
            }
        } else {
            ingredientName = line;
        }

        // Normalize ingredient name (consolidate variations)
        ingredientName = normalizeIngredientName(ingredientName);

        // Determine category
        String category = categorizeIngredient(ingredientName);

        // Check if this is a pantry staple
        Boolean isPantryStaple = PANTRY_STAPLES.contains(ingredientName);

        // Estimate price based on category and quantity
        Decimal estimatedPrice = estimatePrice(category, quantity, unit);

        // Create ingredient record
        Meal_Ingredient__c ingredient = new Meal_Ingredient__c(
            Meal__c = mealId,
            Ingredient_Name__c = ingredientName,
            Quantity__c = quantity,
            Unit__c = unit,
            Category__c = category,
            Is_Pantry_Staple__c = isPantryStaple,
            Estimated_Price__c = estimatedPrice
        );

        return ingredient;
    }

    /**
     * @description Checks if a string is a valid unit
     */
    private static Boolean isValidUnit(String unit) {
        Set<String> validUnits = new Set<String>{
            'lb', 'oz', 'cup', 'tbsp', 'tsp', 'each', 'package', 'can', 'jar',
            'bottle', 'bunch', 'clove', 'pinch'
        };
        return validUnits.contains(unit);
    }

    /**
     * @description Categorizes an ingredient based on keywords
     */
    private static String categorizeIngredient(String ingredientName) {
        String lowerName = ingredientName.toLowerCase();

        for (String category : CATEGORY_KEYWORDS.keySet()) {
            List<String> keywords = CATEGORY_KEYWORDS.get(category);
            for (String keyword : keywords) {
                if (lowerName.contains(keyword)) {
                    return category;
                }
            }
        }

        return 'Pantry'; // Default category
    }

    /**
     * @description Normalizes ingredient names to consolidate variations
     */
    private static String normalizeIngredientName(String ingredientName) {
        if (String.isBlank(ingredientName)) {
            return ingredientName;
        }

        String lowerName = ingredientName.toLowerCase().trim();

        // Check if there's a normalization for this ingredient
        if (INGREDIENT_NORMALIZATIONS.containsKey(lowerName)) {
            return INGREDIENT_NORMALIZATIONS.get(lowerName);
        }

        // Otherwise capitalize words
        return capitalizeWords(ingredientName);
    }

    /**
     * @description Estimates price based on category, quantity, and unit
     */
    private static Decimal estimatePrice(String category, Decimal quantity, String unit) {
        // Get base price for category
        Decimal basePrice = CATEGORY_BASE_PRICES.get(category);
        if (basePrice == null) {
            basePrice = 3.00; // Default fallback
        }

        // Adjust price based on quantity and unit
        Decimal priceMultiplier = quantity;

        // Weight-based units cost more per unit
        if (unit == 'lb') {
            priceMultiplier = quantity * 1.5; // $basePrice per lb
        } else if (unit == 'oz') {
            priceMultiplier = (quantity / 16) * 1.5; // Convert to lbs
        } else if (unit == 'cup' || unit == 'tbsp' || unit == 'tsp') {
            priceMultiplier = 1.0; // Volumetric = single item price
        } else if (unit == 'package' || unit == 'jar' || unit == 'bottle' || unit == 'can') {
            priceMultiplier = quantity; // Per container
        } else {
            // each, bunch, clove, pinch
            priceMultiplier = Math.max(quantity * 0.5, 0.50); // Minimum 50 cents
        }

        Decimal estimatedPrice = basePrice * priceMultiplier;

        // Round to nearest quarter
        Decimal rounded = Decimal.valueOf(Math.round(estimatedPrice * 4)) / 4;
        return rounded.setScale(2);
    }

    /**
     * @description Capitalizes first letter of each word
     */
    private static String capitalizeWords(String text) {
        if (String.isBlank(text)) {
            return text;
        }

        List<String> words = text.split('\\s+');
        List<String> capitalizedWords = new List<String>();

        for (String word : words) {
            if (word.length() > 0) {
                capitalizedWords.add(word.substring(0, 1).toUpperCase() + word.substring(1));
            }
        }

        return String.join(capitalizedWords, ' ');
    }

    /**
     * @description Invocable method for Flow/Process Builder integration
     */
    @InvocableMethod(label='Parse Meal Ingredients' description='Parses ingredient text and creates Meal_Ingredient__c records')
    public static List<ParseResult> parseIngredientsFromFlow(List<Id> mealIds) {
        List<ParseResult> results = new List<ParseResult>();

        Set<Id> mealIdSet = new Set<Id>(mealIds);
        Integer count = parseIngredientsForMeals(mealIdSet);

        ParseResult result = new ParseResult();
        result.ingredientsCreated = count;
        result.success = true;
        results.add(result);

        return results;
    }

    /**
     * @description Output wrapper for Flow invocable method
     */
    public class ParseResult {
        @InvocableVariable(label='Ingredients Created')
        public Integer ingredientsCreated;

        @InvocableVariable(label='Success')
        public Boolean success;
    }
}

// Create 5 test meals with all required fields for MealPlanGenerator testing

List<Meal__c> testMeals = new List<Meal__c>();

// Breakfast 1 - Quick Oatmeal
testMeals.add(new Meal__c(
    Name = 'Quick Oatmeal Bowl',
    Prep_Time_Minutes__c = 5,
    Cook_Time_Minutes__c = 10,
    Servings__c = 4,
    Protein_Type__c = 'Vegetarian',
    Ingredients__c = '2 cups oats\n4 cups almond milk\n2 tsp cinnamon\nBerries for topping',
    Instructions__c = '1. Boil milk\n2. Add oats\n3. Cook 10 min\n4. Top with berries'
));

// Lunch 1 - Chicken Salad
testMeals.add(new Meal__c(
    Name = 'Grilled Chicken Salad',
    Prep_Time_Minutes__c = 10,
    Cook_Time_Minutes__c = 15,
    Servings__c = 5,
    Protein_Type__c = 'Chicken',
    Ingredients__c = '2 lbs chicken breast\n6 cups mixed greens\n1 cup cherry tomatoes\nBalsamic dressing',
    Instructions__c = '1. Grill chicken 15 min\n2. Slice chicken\n3. Toss with greens\n4. Add dressing'
));

// Dinner 1 - Fish/Seafood (Weeknight friendly - 25 min total)
testMeals.add(new Meal__c(
    Name = 'Baked Salmon with Vegetables',
    Prep_Time_Minutes__c = 10,
    Cook_Time_Minutes__c = 15,
    Servings__c = 5,
    Protein_Type__c = 'Fish/Seafood',
    Ingredients__c = '2 lbs salmon\n3 cups broccoli\n2 cups carrots\nOlive oil and lemon',
    Instructions__c = '1. Preheat oven 400F\n2. Season salmon\n3. Arrange veggies\n4. Bake 15 min'
));

// Dinner 2 - Beef (NOT weeknight friendly - 45 min)
testMeals.add(new Meal__c(
    Name = 'Beef Stew',
    Prep_Time_Minutes__c = 15,
    Cook_Time_Minutes__c = 30,
    Servings__c = 6,
    Protein_Type__c = 'Beef',
    Ingredients__c = '2 lbs beef chuck\n4 potatoes\n3 carrots\n2 cups beef broth',
    Instructions__c = '1. Brown beef\n2. Add vegetables\n3. Add broth\n4. Simmer 30 min'
));

// Dinner 3 - Pork (Weeknight friendly - 25 min)
testMeals.add(new Meal__c(
    Name = 'Pork Stir Fry',
    Prep_Time_Minutes__c = 10,
    Cook_Time_Minutes__c = 12,
    Servings__c = 5,
    Protein_Type__c = 'Pork',
    Ingredients__c = '1.5 lbs pork tenderloin\n3 cups mixed vegetables\nSoy sauce and ginger',
    Instructions__c = '1. Slice pork thin\n2. Heat wok\n3. Stir fry pork 5 min\n4. Add veggies 7 min'
));

// Breakfast 2 - Eggs
testMeals.add(new Meal__c(
    Name = 'Veggie Scramble',
    Prep_Time_Minutes__c = 5,
    Cook_Time_Minutes__c = 10,
    Servings__c = 4,
    Protein_Type__c = 'Vegetarian',
    Ingredients__c = '12 eggs\n2 cups spinach\n1 cup mushrooms\n1 cup cheese',
    Instructions__c = '1. Beat eggs\n2. Sauté veggies\n3. Add eggs\n4. Scramble 5 min'
));

// Lunch 2 - Turkey
testMeals.add(new Meal__c(
    Name = 'Turkey Wrap',
    Prep_Time_Minutes__c = 10,
    Cook_Time_Minutes__c = 0,
    Servings__c = 5,
    Protein_Type__c = 'Turkey',
    Ingredients__c = '1.5 lbs deli turkey\n5 whole wheat tortillas\nLettuce and tomatoes\nMustard',
    Instructions__c = '1. Lay out tortillas\n2. Layer turkey\n3. Add vegetables\n4. Roll and slice'
));

// Dinner 4 - Chicken (Weeknight - 30 min)
testMeals.add(new Meal__c(
    Name = 'Sheet Pan Chicken',
    Prep_Time_Minutes__c = 15,
    Cook_Time_Minutes__c = 25,
    Servings__c = 6,
    Protein_Type__c = 'Chicken',
    Ingredients__c = '3 lbs chicken thighs\n4 cups Brussels sprouts\n2 lbs potatoes\nOlive oil',
    Instructions__c = '1. Preheat 425F\n2. Toss ingredients\n3. Spread on pan\n4. Roast 25 min'
));

insert testMeals;

System.debug('Successfully created ' + testMeals.size() + ' test meals!');
System.debug('Meal IDs: ' + testMeals);

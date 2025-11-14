/**
 * @description Generates automated 2-week meal plans with smart recipe selection
 * - Plans 14 days with 3 meals/day (Breakfast, Lunch, Dinner)
 * - Weeknight dinners must be ≤30 minutes
 * - No recipe repeats within 30 days
 * - Limits beef and pork to 1x per week each
 * - Plans for 5 people with leftovers
 */
public with sharing class MealPlanGenerator {

    // Constants
    private static final Integer PLANNING_DAYS = 14;
    private static final Integer MEALS_PER_DAY = 3;
    private static final Integer DEFAULT_PEOPLE = 5;
    private static final Integer NO_REPEAT_DAYS = 30;
    private static final Integer MAX_BEEF_PER_WEEK = 1;
    private static final Integer MAX_PORK_PER_WEEK = 1;

    /**
     * @description Generates a new 2-week meal plan starting from specified date
     * @param startDate The Sunday to start the meal plan
     * @param numberOfPeople Number of people to plan for (default 5)
     * @param autoAccept If true, automatically sets plan to Active status
     * @return Id of the created Weekly_Meal_Plan__c record
     */
    public static Id generateMealPlan(Date startDate, Integer numberOfPeople, Boolean autoAccept) {
        // Validate start date is a Sunday
        Date validStartDate = getNextSunday(startDate);

        // Create the Weekly Meal Plan record
        Weekly_Meal_Plan__c mealPlan = new Weekly_Meal_Plan__c(
            Week_Start_Date__c = validStartDate,
            Week_End_Date__c = validStartDate.addDays(PLANNING_DAYS - 1),
            Number_of_People__c = numberOfPeople != null ? numberOfPeople : DEFAULT_PEOPLE,
            Status__c = autoAccept ? 'Active' : 'Draft',
            Generation_Method__c = 'Fully Automated'
        );
        insert mealPlan;

        // Get available recipes with usage history
        Map<Id, Meal__c> availableRecipes = getAvailableRecipes(validStartDate);

        // Generate planned meals for 14 days
        List<Planned_Meal__c> plannedMeals = generatePlannedMeals(
            mealPlan.Id,
            validStartDate,
            availableRecipes,
            numberOfPeople != null ? numberOfPeople : DEFAULT_PEOPLE
        );
        insert plannedMeals;

        // Update Last_Used_Date on selected recipes
        updateRecipeUsage(plannedMeals);

        return mealPlan.Id;
    }

    /**
     * @description Gets next Sunday from given date (or same date if already Sunday)
     */
    private static Date getNextSunday(Date inputDate) {
        DateTime dt = DateTime.newInstance(inputDate, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dt.format('EEEE');

        if (dayOfWeek == 'Sunday') {
            return inputDate;
        }

        // Calculate days until next Sunday
        Integer daysToAdd = 0;
        if (dayOfWeek == 'Monday') daysToAdd = 6;
        else if (dayOfWeek == 'Tuesday') daysToAdd = 5;
        else if (dayOfWeek == 'Wednesday') daysToAdd = 4;
        else if (dayOfWeek == 'Thursday') daysToAdd = 3;
        else if (dayOfWeek == 'Friday') daysToAdd = 2;
        else if (dayOfWeek == 'Saturday') daysToAdd = 1;

        return inputDate.addDays(daysToAdd);
    }

    /**
     * @description Retrieves recipes that haven't been used in the last 30 days
     */
    private static Map<Id, Meal__c> getAvailableRecipes(Date startDate) {
        Date thirtyDaysAgo = startDate.addDays(-NO_REPEAT_DAYS);

        List<Meal__c> recipes = [
            SELECT Id, Name, Servings__c, Total_Time_Minutes__c, Is_Weeknight_Friendly__c,
                   Protein_Type__c, Last_Used_Date__c, Calories__c, Carbs_g__c, Fat_g__c, Sugar_g__c,
                   Prep_Time_Minutes__c, Cook_Time_Minutes__c, Difficulty__c,
                   Is_Heart_Healthy__c, Is_Diabetic_Friendly__c
            FROM Meal__c
            WHERE (Last_Used_Date__c = null OR Last_Used_Date__c < :thirtyDaysAgo)
            ORDER BY Last_Used_Date__c NULLS FIRST, Name
        ];

        Map<Id, Meal__c> recipeMap = new Map<Id, Meal__c>();
        for (Meal__c recipe : recipes) {
            recipeMap.put(recipe.Id, recipe);
        }

        return recipeMap;
    }

    /**
     * @description Generates 42 planned meals (14 days × 3 meals)
     */
    private static List<Planned_Meal__c> generatePlannedMeals(
        Id mealPlanId,
        Date startDate,
        Map<Id, Meal__c> availableRecipes,
        Integer numberOfPeople
    ) {
        List<Planned_Meal__c> plannedMeals = new List<Planned_Meal__c>();
        Set<Id> usedRecipeIds = new Set<Id>();

        // Track protein usage per week
        Map<Integer, Integer> beefCountByWeek = new Map<Integer, Integer>{1 => 0, 2 => 0};
        Map<Integer, Integer> porkCountByWeek = new Map<Integer, Integer>{1 => 0, 2 => 0};

        // Generate meals for 14 days
        for (Integer day = 0; day < PLANNING_DAYS; day++) {
            Date currentDate = startDate.addDays(day);
            Integer weekNumber = (day / 7) + 1; // Week 1 or Week 2
            Boolean isWeeknight = isWeeknight(currentDate);

            // Calculate day of week for the Planned_Meal__c required field
            DateTime dt = DateTime.newInstance(currentDate, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek = dt.format('EEEE'); // Returns: Sunday, Monday, Tuesday, etc.

            // Generate 3 meals for this day
            List<String> mealTimes = new List<String>{'Breakfast', 'Lunch', 'Dinner'};

            for (String mealTime : mealTimes) {
                Meal__c selectedRecipe = selectRecipe(
                    availableRecipes,
                    usedRecipeIds,
                    mealTime,
                    isWeeknight && mealTime == 'Dinner',
                    weekNumber,
                    beefCountByWeek,
                    porkCountByWeek
                );

                if (selectedRecipe != null) {
                    Planned_Meal__c plannedMeal = new Planned_Meal__c(
                        Weekly_Meal_Plan__c = mealPlanId,
                        Meal__c = selectedRecipe.Id,
                        Meal_Date__c = currentDate,
                        Meal_Time__c = mealTime,
                        Day_of_Week__c = dayOfWeek,
                        Servings__c = numberOfPeople,
                        Has_Leftovers__c = selectedRecipe.Servings__c >= numberOfPeople + 2
                    );
                    plannedMeals.add(plannedMeal);
                    usedRecipeIds.add(selectedRecipe.Id);

                    // Track protein usage for dinner only
                    if (mealTime == 'Dinner' && selectedRecipe.Protein_Type__c != null) {
                        if (selectedRecipe.Protein_Type__c == 'Beef') {
                            beefCountByWeek.put(weekNumber, beefCountByWeek.get(weekNumber) + 1);
                        } else if (selectedRecipe.Protein_Type__c == 'Pork') {
                            porkCountByWeek.put(weekNumber, porkCountByWeek.get(weekNumber) + 1);
                        }
                    }
                }
            }
        }

        return plannedMeals;
    }

    /**
     * @description Determines if a date falls on a weeknight (Mon-Fri)
     */
    private static Boolean isWeeknight(Date inputDate) {
        DateTime dt = DateTime.newInstance(inputDate, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dt.format('EEEE');
        return dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday';
    }

    /**
     * @description Selects best recipe based on meal constraints
     */
    private static Meal__c selectRecipe(
        Map<Id, Meal__c> availableRecipes,
        Set<Id> usedRecipeIds,
        String mealTime,
        Boolean mustBeWeeknightFriendly,
        Integer weekNumber,
        Map<Integer, Integer> beefCountByWeek,
        Map<Integer, Integer> porkCountByWeek
    ) {
        // Filter recipes based on criteria
        List<Meal__c> candidates = new List<Meal__c>();

        for (Meal__c recipe : availableRecipes.values()) {
            // Skip if already used in this plan
            if (usedRecipeIds.contains(recipe.Id)) {
                continue;
            }

            // Weeknight dinner must be ≤30 minutes
            if (mustBeWeeknightFriendly && recipe.Is_Weeknight_Friendly__c != true) {
                continue;
            }

            // Check beef/pork limits for dinner
            if (mealTime == 'Dinner' && recipe.Protein_Type__c != null) {
                if (recipe.Protein_Type__c == 'Beef' &&
                    beefCountByWeek.get(weekNumber) >= MAX_BEEF_PER_WEEK) {
                    continue;
                }
                if (recipe.Protein_Type__c == 'Pork' &&
                    porkCountByWeek.get(weekNumber) >= MAX_PORK_PER_WEEK) {
                    continue;
                }
            }

            candidates.add(recipe);
        }

        // Prioritize heart-healthy and diabetic-friendly meals
        List<Meal__c> priorityCandidates = new List<Meal__c>();
        for (Meal__c recipe : candidates) {
            if (recipe.Is_Heart_Healthy__c == true || recipe.Is_Diabetic_Friendly__c == true) {
                priorityCandidates.add(recipe);
            }
        }

        // Return priority recipe if available, otherwise first candidate
        if (!priorityCandidates.isEmpty()) {
            return priorityCandidates[0];
        }

        return candidates.isEmpty() ? null : candidates[0];
    }

    /**
     * @description Updates Last_Used_Date__c for selected recipes
     */
    private static void updateRecipeUsage(List<Planned_Meal__c> plannedMeals) {
        Set<Id> recipeIds = new Set<Id>();
        Date today = Date.today();

        for (Planned_Meal__c pm : plannedMeals) {
            if (pm.Meal__c != null) {
                recipeIds.add(pm.Meal__c);
            }
        }

        List<Meal__c> recipesToUpdate = new List<Meal__c>();
        for (Id recipeId : recipeIds) {
            recipesToUpdate.add(new Meal__c(
                Id = recipeId,
                Last_Used_Date__c = today
            ));
        }

        if (!recipesToUpdate.isEmpty()) {
            update recipesToUpdate;
        }
    }

    /**
     * @description Invocable method for Flow integration
     */
    @InvocableMethod(label='Generate 2-Week Meal Plan' description='Creates automated meal plan with recipe selection')
    public static List<Id> generateMealPlanFromFlow(List<MealPlanRequest> requests) {
        List<Id> mealPlanIds = new List<Id>();

        for (MealPlanRequest request : requests) {
            Id mealPlanId = generateMealPlan(
                request.startDate != null ? request.startDate : Date.today(),
                request.numberOfPeople,
                request.autoAccept != null ? request.autoAccept : false
            );
            mealPlanIds.add(mealPlanId);
        }

        return mealPlanIds;
    }

    /**
     * @description Input wrapper for Flow invocable method
     */
    public class MealPlanRequest {
        @InvocableVariable(label='Start Date (Sunday)' description='Starting Sunday for the meal plan' required=false)
        public Date startDate;

        @InvocableVariable(label='Number of People' description='Number of people to plan for (default 5)' required=false)
        public Integer numberOfPeople;

        @InvocableVariable(label='Auto Accept' description='Automatically activate the meal plan' required=false)
        public Boolean autoAccept;
    }
}

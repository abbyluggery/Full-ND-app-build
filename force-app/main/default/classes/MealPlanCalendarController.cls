/**
 * @description Controller for MealPlanCalendar Lightning Web Component
 * - Retrieves planned meals for calendar display
 * - Generates new meal plans via UI
 * - Provides meal plan metadata
 */
public with sharing class MealPlanCalendarController {

    /**
     * @description Gets all planned meals for a meal plan in calendar format
     * @param mealPlanId The Weekly_Meal_Plan__c record ID
     * @return Wrapper with meal plan data and planned meals
     */
    @AuraEnabled(cacheable=true)
    public static MealPlanData getPlannedMeals(Id mealPlanId) {
        try {
            // Get meal plan details
            Weekly_Meal_Plan__c mealPlan = [
                SELECT Id, Name, Week_Start_Date__c, Week_End_Date__c, Number_of_People__c,
                       Status__c, Generation_Method__c
                FROM Weekly_Meal_Plan__c
                WHERE Id = :mealPlanId
                LIMIT 1
            ];

            // Get all planned meals with recipe details
            List<Planned_Meal__c> plannedMeals = [
                SELECT Id, Meal_Date__c, Meal_Time__c, Servings__c, Has_Leftovers__c,
                       Meal__c, Meal__r.Name, Meal__r.Total_Time_Minutes__c,
                       Meal__r.Prep_Time_Minutes__c, Meal__r.Cook_Time_Minutes__c,
                       Meal__r.Servings__c, Meal__r.Calories__c, Meal__r.Protein_Type__c,
                       Meal__r.Is_Heart_Healthy__c, Meal__r.Is_Diabetic_Friendly__c
                FROM Planned_Meal__c
                WHERE Weekly_Meal_Plan__c = :mealPlanId
                ORDER BY Meal_Date__c, Meal_Time__c
            ];

            // Build response
            MealPlanData data = new MealPlanData();
            data.mealPlanId = mealPlan.Id;
            data.mealPlanName = mealPlan.Name;
            data.startDate = mealPlan.Week_Start_Date__c;
            data.endDate = mealPlan.Week_End_Date__c;
            data.numberOfPeople = mealPlan.Number_of_People__c != null ?
                                  Integer.valueOf(mealPlan.Number_of_People__c) : 5;
            data.status = mealPlan.Status__c;
            data.plannedMeals = new List<PlannedMealInfo>();

            for (Planned_Meal__c pm : plannedMeals) {
                PlannedMealInfo info = new PlannedMealInfo();
                info.id = pm.Id;
                info.mealDate = pm.Meal_Date__c;
                info.mealTime = pm.Meal_Time__c;
                info.mealId = pm.Meal__c;
                info.mealName = pm.Meal__r.Name;
                info.totalTime = pm.Meal__r.Total_Time_Minutes__c != null ?
                                Integer.valueOf(pm.Meal__r.Total_Time_Minutes__c) : 0;
                info.servings = pm.Servings__c != null ? Integer.valueOf(pm.Servings__c) : 0;
                info.hasLeftovers = pm.Has_Leftovers__c != null ? pm.Has_Leftovers__c : false;
                info.calories = pm.Meal__r.Calories__c != null ?
                               Integer.valueOf(pm.Meal__r.Calories__c) : 0;
                info.proteinType = pm.Meal__r.Protein_Type__c;
                info.isHeartHealthy = pm.Meal__r.Is_Heart_Healthy__c;
                info.isDiabeticFriendly = pm.Meal__r.Is_Diabetic_Friendly__c;

                data.plannedMeals.add(info);
            }

            return data;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading meal plan: ' + e.getMessage());
        }
    }

    /**
     * @description Generates a new 2-week meal plan
     * @param startDate Starting Sunday for the meal plan
     * @param numberOfPeople Number of people to plan for
     * @return ID of created meal plan
     */
    @AuraEnabled
    public static Id generateMealPlan(Date startDate, Integer numberOfPeople) {
        try {
            // Use MealPlanGenerator to create the plan
            Id mealPlanId = MealPlanGenerator.generateMealPlan(
                startDate,
                numberOfPeople,
                false  // Don't auto-accept, keep as Draft
            );

            return mealPlanId;
        } catch (Exception e) {
            throw new AuraHandledException('Error generating meal plan: ' + e.getMessage());
        }
    }

    /**
     * @description Gets meal details for modal display
     * @param plannedMealId The Planned_Meal__c record ID
     * @return Detailed meal information
     */
    @AuraEnabled(cacheable=true)
    public static MealDetailInfo getMealDetails(Id plannedMealId) {
        try {
            Planned_Meal__c pm = [
                SELECT Id, Meal__c, Meal__r.Name, Meal__r.Instructions__c,
                       Meal__r.Total_Time_Minutes__c, Meal__r.Prep_Time_Minutes__c,
                       Meal__r.Cook_Time_Minutes__c, Meal__r.Servings__c,
                       Meal__r.Calories__c, Meal__r.Protein_g__c, Meal__r.Carbs_g__c,
                       Meal__r.Fat_g__c, Meal__r.Fiber_g__c, Meal__r.Sugar_g__c,
                       Meal__r.Protein_Type__c, Meal__r.Difficulty__c,
                       Meal__r.Is_Heart_Healthy__c, Meal__r.Is_Diabetic_Friendly__c,
                       Meal__r.Is_Weeknight_Friendly__c
                FROM Planned_Meal__c
                WHERE Id = :plannedMealId
                LIMIT 1
            ];

            // Get ingredients
            List<Meal_Ingredient__c> ingredients = [
                SELECT Id, Ingredient_Name__c, Quantity__c, Unit__c,
                       Category__c, Estimated_Price__c
                FROM Meal_Ingredient__c
                WHERE Meal__c = :pm.Meal__c
                ORDER BY Category__c, Ingredient_Name__c
            ];

            MealDetailInfo detail = new MealDetailInfo();
            detail.mealName = pm.Meal__r.Name;
            detail.description = pm.Meal__r.Instructions__c;
            detail.totalTime = pm.Meal__r.Total_Time_Minutes__c != null ?
                              Integer.valueOf(pm.Meal__r.Total_Time_Minutes__c) : 0;
            detail.prepTime = pm.Meal__r.Prep_Time_Minutes__c != null ?
                             Integer.valueOf(pm.Meal__r.Prep_Time_Minutes__c) : 0;
            detail.cookTime = pm.Meal__r.Cook_Time_Minutes__c != null ?
                             Integer.valueOf(pm.Meal__r.Cook_Time_Minutes__c) : 0;
            detail.servings = pm.Meal__r.Servings__c != null ?
                             Integer.valueOf(pm.Meal__r.Servings__c) : 0;
            detail.calories = pm.Meal__r.Calories__c != null ?
                             Integer.valueOf(pm.Meal__r.Calories__c) : 0;
            detail.protein = pm.Meal__r.Protein_g__c;
            detail.carbs = pm.Meal__r.Carbs_g__c;
            detail.fat = pm.Meal__r.Fat_g__c;
            detail.proteinType = pm.Meal__r.Protein_Type__c;
            detail.difficulty = pm.Meal__r.Difficulty__c;
            detail.isHeartHealthy = pm.Meal__r.Is_Heart_Healthy__c;
            detail.isDiabeticFriendly = pm.Meal__r.Is_Diabetic_Friendly__c;
            detail.isWeeknightFriendly = pm.Meal__r.Is_Weeknight_Friendly__c;

            detail.ingredients = new List<IngredientInfo>();
            for (Meal_Ingredient__c ing : ingredients) {
                IngredientInfo info = new IngredientInfo();
                info.name = ing.Ingredient_Name__c;
                info.quantity = ing.Quantity__c;
                info.unit = ing.Unit__c;
                info.category = ing.Category__c;
                detail.ingredients.add(info);
            }

            return detail;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading meal details: ' + e.getMessage());
        }
    }

    // Wrapper classes for data transfer

    public class MealPlanData {
        @AuraEnabled public Id mealPlanId;
        @AuraEnabled public String mealPlanName;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public Integer numberOfPeople;
        @AuraEnabled public String status;
        @AuraEnabled public List<PlannedMealInfo> plannedMeals;
    }

    public class PlannedMealInfo {
        @AuraEnabled public Id id;
        @AuraEnabled public Date mealDate;
        @AuraEnabled public String mealTime;
        @AuraEnabled public Id mealId;
        @AuraEnabled public String mealName;
        @AuraEnabled public Integer totalTime;
        @AuraEnabled public Integer servings;
        @AuraEnabled public Boolean hasLeftovers;
        @AuraEnabled public Integer calories;
        @AuraEnabled public String proteinType;
        @AuraEnabled public Boolean isHeartHealthy;
        @AuraEnabled public Boolean isDiabeticFriendly;
    }

    public class MealDetailInfo {
        @AuraEnabled public String mealName;
        @AuraEnabled public String description;
        @AuraEnabled public Integer totalTime;
        @AuraEnabled public Integer prepTime;
        @AuraEnabled public Integer cookTime;
        @AuraEnabled public Integer servings;
        @AuraEnabled public Integer calories;
        @AuraEnabled public Decimal protein;
        @AuraEnabled public Decimal carbs;
        @AuraEnabled public Decimal fat;
        @AuraEnabled public String proteinType;
        @AuraEnabled public String difficulty;
        @AuraEnabled public Boolean isHeartHealthy;
        @AuraEnabled public Boolean isDiabeticFriendly;
        @AuraEnabled public Boolean isWeeknightFriendly;
        @AuraEnabled public List<IngredientInfo> ingredients;
    }

    public class IngredientInfo {
        @AuraEnabled public String name;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public String unit;
        @AuraEnabled public String category;
    }
}

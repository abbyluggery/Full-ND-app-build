@RestResource(urlMapping='/mealplan/today')
global with sharing class MealPlanTodayAPI {

    @HttpGet
    global static Response getTodaysMeals() {
        Response response = new Response();

        try {
            Date today = Date.today();

            List<Planned_Meal__c> plannedMeals = [
                SELECT Id, Meal__c, Meal__r.Name, Meal__r.Recipe_Content__c,
                       Meal__r.Cook_Time_Minutes__c, Meal__r.Sodium_mg__c,
                       Meal__r.Protein_g__c, Meal__r.Fiber_g__c, Meal__r.Meal_Type__c,
                       Meal__r.Is_Heart_Healthy__c, Meal__r.Is_Diabetic_Friendly__c,
                       Meal_Date__c, Day_of_Week__c, Is_Completed__c
                FROM Planned_Meal__c
                WHERE Meal_Date__c = :today
                ORDER BY Meal__r.Meal_Type__c
            ];

            response.success = true;
            response.meals = new List<MealInfo>();

            for (Planned_Meal__c pm : plannedMeals) {
                response.meals.add(buildMealInfo(pm));
            }

            response.totalCount = response.meals.size();

        } catch (Exception e) {
            response.success = false;
            response.errorMessage = e.getMessage();
        }

        return response;
    }

    private static MealInfo buildMealInfo(Planned_Meal__c pm) {
        MealInfo info = new MealInfo();
        info.plannedMealId = pm.Id;
        info.mealId = pm.Meal__c;
        info.name = pm.Meal__r.Name;
        info.recipeContent = pm.Meal__r.Recipe_Content__c;
        info.cookTimeMinutes = pm.Meal__r.Cook_Time_Minutes__c;
        info.sodiumMg = pm.Meal__r.Sodium_mg__c;
        info.proteinG = pm.Meal__r.Protein_g__c;
        info.fiberG = pm.Meal__r.Fiber_g__c;
        info.mealType = pm.Meal__r.Meal_Type__c;
        info.isHeartHealthy = pm.Meal__r.Is_Heart_Healthy__c;
        info.isDiabeticFriendly = pm.Meal__r.Is_Diabetic_Friendly__c;
        info.mealDate = pm.Meal_Date__c;
        info.dayOfWeek = pm.Day_of_Week__c;
        info.isCompleted = pm.Is_Completed__c;
        return info;
    }

    global class Response {
        public Boolean success;
        public String errorMessage;
        public Integer totalCount;
        public List<MealInfo> meals;
    }

    global class MealInfo {
        public String plannedMealId;
        public String mealId;
        public String name;
        public String recipeContent;
        public Decimal cookTimeMinutes;
        public Decimal sodiumMg;
        public Decimal proteinG;
        public Decimal fiberG;
        public String mealType;
        public Boolean isHeartHealthy;
        public Boolean isDiabeticFriendly;
        public Date mealDate;
        public String dayOfWeek;
        public Boolean isCompleted;
    }
}

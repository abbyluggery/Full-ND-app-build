/**
 * @description Invocable wrapper for MealPlanGenerator to enable Flow integration
 * - Allows Screen Flows to call meal plan generation
 * - Simplifies input/output for Flow Builder
 */
public with sharing class MealPlanGeneratorInvocable {

    /**
     * @description Generates a 2-week meal plan from Flow
     * @param requests List of meal plan requests from Flow
     * @return List of generated meal plan IDs
     */
    @InvocableMethod(
        label='Generate Meal Plan'
        description='Generates a 2-week meal plan with automated recipe selection'
        category='Meal Planning'
    )
    public static List<Result> generateMealPlan(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result result = new Result();

            try {
                // Call the existing MealPlanGenerator with correct signature
                Id mealPlanId = MealPlanGenerator.generateMealPlan(
                    req.startDate,
                    req.numberOfPeople != null ? Integer.valueOf(req.numberOfPeople) : 5,
                    false // autoAccept = false for manual review
                );

                result.mealPlanId = mealPlanId;
                result.success = true;
                result.message = 'Meal plan generated successfully!';

            } catch (Exception e) {
                result.success = false;
                result.message = 'Error generating meal plan: ' + e.getMessage();
            }

            results.add(result);
        }

        return results;
    }

    /**
     * @description Input parameters for meal plan generation
     */
    public class Request {
        @InvocableVariable(
            label='Start Date'
            description='First day of the meal plan (usually Monday or Sunday)'
            required=true
        )
        public Date startDate;

        @InvocableVariable(
            label='Number of People'
            description='How many people to plan meals for (default: 5)'
            required=false
        )
        public Decimal numberOfPeople;
    }

    /**
     * @description Output results from meal plan generation
     */
    public class Result {
        @InvocableVariable(
            label='Meal Plan ID'
            description='ID of the generated Weekly_Meal_Plan__c record'
        )
        public Id mealPlanId;

        @InvocableVariable(
            label='Success'
            description='True if meal plan was generated successfully'
        )
        public Boolean success;

        @InvocableVariable(
            label='Message'
            description='Success or error message'
        )
        public String message;
    }
}

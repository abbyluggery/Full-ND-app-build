/**
 * Trigger: OpportunityCreationTrigger
 * Object: Job_Posting__c
 * Purpose: Create Opportunity, Account, and Contact when callback occurs
 *
 * When Application_Status__c changes to "Callback Received":
 * 1. Create/find Account for the company
 * 2. Create Contact from recruiter information
 * 3. Create Opportunity linked to Job_Posting__c
 * 4. Link Contact to Opportunity as Contact Role
 */
trigger OpportunityCreationTrigger on Job_Posting__c (after insert, after update) {
    OpportunityCreationHandler.handleOpportunityCreation(Trigger.new, Trigger.oldMap);
}

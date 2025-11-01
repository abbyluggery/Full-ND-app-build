/**
 * @description Trigger for Job_Posting__c object
 * Automatically analyzes new job postings using Claude AI
 *
 * LEARNING NOTES:
 * - Trigger: Apex code that executes before/after DML operations
 * - after insert: Runs after record is saved (so we have an ID)
 * - Delegates to handler class for better code organization
 *
 * @author Claude Code Assistant
 * @date 2025-10-27
 */
trigger JobPostingTrigger on Job_Posting__c (after insert, after update) {

    // LEARNING: Use trigger context variables to determine what happened
    // Trigger.new = List of records that were inserted/updated
    // Trigger.isInsert = true if this is an insert operation
    // Trigger.isUpdate = true if this is an update operation

    if (Trigger.isAfter && Trigger.isInsert) {
        // New job postings - analyze them automatically
        JobPostingTriggerHandler.handleAfterInsert(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        // Updated job postings - re-analyze if description changed
        JobPostingTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}

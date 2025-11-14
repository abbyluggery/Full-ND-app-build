/**
 * @description Trigger on Resume_Package__c to update Opportunity stage when resume is generated
 * @author Abby Luggery / Claude Code Assistant
 * @date November 13, 2025
 */
trigger ResumePackageTrigger on Resume_Package__c (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        OpportunityProgressAutomation.handleResumePackageCreation(Trigger.new);
    }
}

/**
 * @description Trigger to sync interview fields between Opportunity and Job_Posting__c
 * Enables users to work exclusively from Opportunity without touching Job_Posting__c
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date November 13, 2025
 */
trigger OpportunityInterviewSyncTrigger on Opportunity (after insert, after update) {

    // Filter to only opportunities with interview field changes
    List<Opportunity> oppsWithChanges = new List<Opportunity>();

    if (Trigger.isInsert) {
        // On insert, sync all records that have interview fields populated
        for (Opportunity opp : Trigger.new) {
            if (opp.Job_Posting__c != null &&
                (opp.Interview_Date__c != null ||
                 opp.Interview_Notes__c != null ||
                 opp.Interview_Feedback__c != null ||
                 opp.Interview_Completed__c != null)) {
                oppsWithChanges.add(opp);
            }
        }
    } else if (Trigger.isUpdate) {
        // On update, sync only records where interview fields changed
        for (Opportunity opp : Trigger.new) {
            Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

            if (opp.Job_Posting__c != null &&
                OpportunityInterviewSync.hasInterviewFieldsChanged(opp, oldOpp)) {
                oppsWithChanges.add(opp);
            }
        }
    }

    if (!oppsWithChanges.isEmpty()) {
        OpportunityInterviewSync.syncToJobPosting(oppsWithChanges);
    }
}

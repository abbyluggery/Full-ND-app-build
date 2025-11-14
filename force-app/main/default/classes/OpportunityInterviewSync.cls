/**
 * @description Handler class for syncing interview fields between Opportunity and Job_Posting__c
 * This enables users to work exclusively from Opportunity without touching Job_Posting__c
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date November 13, 2025
 */
public with sharing class OpportunityInterviewSync {

    // Static flag to prevent infinite recursion during sync
    private static Boolean isExecuting = false;

    /**
     * @description Syncs interview fields from Opportunity to Job_Posting__c
     * Called by OpportunityTrigger on after insert, after update
     */
    public static void syncToJobPosting(List<Opportunity> opportunities) {
        // Prevent infinite loop if Job_Posting trigger calls back
        if (isExecuting) {
            return;
        }

        try {
            isExecuting = true;

            // Collect Job_Posting__c IDs to update
            Map<Id, Opportunity> oppsByJobPostingId = new Map<Id, Opportunity>();

            for (Opportunity opp : opportunities) {
                if (opp.Job_Posting__c != null) {
                    oppsByJobPostingId.put(opp.Job_Posting__c, opp);
                }
            }

            if (oppsByJobPostingId.isEmpty()) {
                return;
            }

            // Query existing Job_Posting__c records
            List<Job_Posting__c> jobPostingsToUpdate = [
                SELECT Id, Interview_Date__c, Interview_Notes__c,
                       Interview_Feedback__c, Interview_Completed__c
                FROM Job_Posting__c
                WHERE Id IN :oppsByJobPostingId.keySet()
            ];

            // Update Job_Posting__c with Opportunity values
            for (Job_Posting__c jp : jobPostingsToUpdate) {
                Opportunity opp = oppsByJobPostingId.get(jp.Id);

                jp.Interview_Date__c = opp.Interview_Date__c;
                jp.Interview_Notes__c = opp.Interview_Notes__c;
                jp.Interview_Feedback__c = opp.Interview_Feedback__c;
                jp.Interview_Completed__c = opp.Interview_Completed__c;
            }

            if (!jobPostingsToUpdate.isEmpty()) {
                update jobPostingsToUpdate;
            }

        } finally {
            isExecuting = false;
        }
    }

    /**
     * @description Syncs interview fields from Job_Posting__c to Opportunity
     * Called by JobPostingTrigger on after update
     */
    public static void syncToOpportunity(List<Job_Posting__c> jobPostings) {
        // Prevent infinite loop if Opportunity trigger calls back
        if (isExecuting) {
            return;
        }

        try {
            isExecuting = true;

            // Collect Job_Posting__c IDs
            Set<Id> jobPostingIds = new Set<Id>();
            for (Job_Posting__c jp : jobPostings) {
                jobPostingIds.add(jp.Id);
            }

            // Query related Opportunities
            List<Opportunity> oppsToUpdate = [
                SELECT Id, Job_Posting__c, Interview_Date__c, Interview_Notes__c,
                       Interview_Feedback__c, Interview_Completed__c
                FROM Opportunity
                WHERE Job_Posting__c IN :jobPostingIds
                AND RecordType.DeveloperName = 'Job_Search_Application'
            ];

            if (oppsToUpdate.isEmpty()) {
                return;
            }

            // Create map for quick lookup
            Map<Id, Job_Posting__c> jobPostingMap = new Map<Id, Job_Posting__c>(jobPostings);

            // Update Opportunity with Job_Posting__c values
            for (Opportunity opp : oppsToUpdate) {
                Job_Posting__c jp = jobPostingMap.get(opp.Job_Posting__c);

                if (jp != null) {
                    opp.Interview_Date__c = jp.Interview_Date__c;
                    opp.Interview_Notes__c = jp.Interview_Notes__c;
                    opp.Interview_Feedback__c = jp.Interview_Feedback__c;
                    opp.Interview_Completed__c = jp.Interview_Completed__c;
                }
            }

            if (!oppsToUpdate.isEmpty()) {
                update oppsToUpdate;
            }

        } finally {
            isExecuting = false;
        }
    }

    /**
     * @description Checks if interview fields have changed on Opportunity
     * Used to determine if sync is needed
     */
    public static Boolean hasInterviewFieldsChanged(Opportunity newOpp, Opportunity oldOpp) {
        if (oldOpp == null) {
            return true; // New record, sync if fields are populated
        }

        return newOpp.Interview_Date__c != oldOpp.Interview_Date__c
            || newOpp.Interview_Notes__c != oldOpp.Interview_Notes__c
            || newOpp.Interview_Feedback__c != oldOpp.Interview_Feedback__c
            || newOpp.Interview_Completed__c != oldOpp.Interview_Completed__c;
    }

    /**
     * @description Checks if interview fields have changed on Job_Posting__c
     * Used to determine if sync is needed
     */
    public static Boolean hasJobPostingInterviewFieldsChanged(Job_Posting__c newJP, Job_Posting__c oldJP) {
        if (oldJP == null) {
            return true; // New record, sync if fields are populated
        }

        return newJP.Interview_Date__c != oldJP.Interview_Date__c
            || newJP.Interview_Notes__c != oldJP.Interview_Notes__c
            || newJP.Interview_Feedback__c != oldJP.Interview_Feedback__c
            || newJP.Interview_Completed__c != oldJP.Interview_Completed__c;
    }
}

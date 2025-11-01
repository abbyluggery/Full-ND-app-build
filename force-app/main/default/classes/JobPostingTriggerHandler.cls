/**
 * @description Handler class for JobPostingTrigger
 * Contains business logic for trigger operations
 *
 * LEARNING NOTES:
 * - Handler Pattern: Separate trigger logic into a class for better testing
 * - Static methods: Don't need to instantiate the class
 * - Why separate? Makes code more maintainable and testable
 *
 * @author Claude Code Assistant
 * @date 2025-10-27
 */
public with sharing class JobPostingTriggerHandler {

    /**
     * @description Handles after insert events
     * Automatically analyzes new job postings
     *
     * @param newJobs List of newly inserted Job_Posting__c records
     */
    public static void handleAfterInsert(List<Job_Posting__c> newJobs) {
        List<Id> jobIdsToAnalyze = new List<Id>();

        for (Job_Posting__c job : newJobs) {
            // Only analyze jobs that have a description
            // LEARNING: Always validate data before processing
            if (String.isNotBlank(job.Description__c)) {
                jobIdsToAnalyze.add(job.Id);
            } else {
                System.debug('Skipping analysis for job without description: ' + job.Title__c);
            }
        }

        // Enqueue async analysis
        if (!jobIdsToAnalyze.isEmpty()) {
            JobPostingAnalysisQueue.enqueueAnalysis(jobIdsToAnalyze);
        }
    }

    /**
     * @description Handles after update events
     * Re-analyzes jobs if description or key fields changed
     *
     * @param newJobs List of updated Job_Posting__c records
     * @param oldJobsMap Map of old versions (before update)
     */
    public static void handleAfterUpdate(List<Job_Posting__c> newJobs, Map<Id, Job_Posting__c> oldJobsMap) {
        List<Id> jobIdsToAnalyze = new List<Id>();

        for (Job_Posting__c job : newJobs) {
            Job_Posting__c oldJob = oldJobsMap.get(job.Id);

            // Re-analyze if description or salary changed
            // LEARNING: Only re-process when meaningful data changes
            Boolean descriptionChanged = job.Description__c != oldJob.Description__c;
            Boolean salaryChanged = job.Salary_Min__c != oldJob.Salary_Min__c ||
                                   job.Salary_Max__c != oldJob.Salary_Max__c;
            Boolean remotePolicyChanged = job.Remote_Policy__c != oldJob.Remote_Policy__c;

            if ((descriptionChanged || salaryChanged || remotePolicyChanged) &&
                String.isNotBlank(job.Description__c)) {
                jobIdsToAnalyze.add(job.Id);
            }
        }

        // Enqueue async analysis
        if (!jobIdsToAnalyze.isEmpty()) {
            JobPostingAnalysisQueue.enqueueAnalysis(jobIdsToAnalyze);
            System.debug('Re-analyzing ' + jobIdsToAnalyze.size() + ' updated job postings');
        }
    }
}

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
     * Automatically analyzes new job postings and auto-populates fields
     *
     * @param newJobs List of newly inserted Job_Posting__c records
     */
    public static void handleAfterInsert(List<Job_Posting__c> newJobs) {
        List<Id> jobIdsToAnalyze = new List<Id>();
        List<Job_Posting__c> jobsToUpdate = new List<Job_Posting__c>();

        for (Job_Posting__c job : newJobs) {
            Boolean needsUpdate = false;
            Job_Posting__c jobToUpdate = new Job_Posting__c(Id = job.Id);

            // Auto-populate Remote_Policy__c if Location = "Remote"
            if (String.isNotBlank(job.Location__c) &&
                job.Location__c.containsIgnoreCase('remote') &&
                String.isBlank(job.Remote_Policy__c)) {
                jobToUpdate.Remote_Policy__c = 'Fully Remote';
                needsUpdate = true;
            }

            // Auto-detect Experience Level from description
            if (String.isNotBlank(job.Description__c) && String.isBlank(job.ExperienceLevel__c)) {
                String detectedLevel = detectExperienceLevel(job.Description__c);
                if (String.isNotBlank(detectedLevel)) {
                    jobToUpdate.ExperienceLevel__c = detectedLevel;
                    needsUpdate = true;
                }
            }

            if (needsUpdate) {
                jobsToUpdate.add(jobToUpdate);
            }

            // Only analyze jobs that have a description
            // LEARNING: Always validate data before processing
            if (String.isNotBlank(job.Description__c)) {
                jobIdsToAnalyze.add(job.Id);
            } else {
                System.debug('Skipping analysis for job without description: ' + job.Title__c);
            }
        }

        // Update jobs with auto-populated fields
        if (!jobsToUpdate.isEmpty()) {
            update jobsToUpdate;
            System.debug('Auto-populated fields for ' + jobsToUpdate.size() + ' jobs');
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

    /**
     * @description Detects experience level from job description text
     * Uses keyword matching to identify seniority level
     *
     * @param description The job description text
     * @return String The detected experience level (Entry Level, Mid-Level, Senior, Lead/Principal, or null)
     */
    private static String detectExperienceLevel(String description) {
        if (String.isBlank(description)) {
            return null;
        }

        String descLower = description.toLowerCase();

        // Check for explicit year requirements first (most reliable)
        if (descLower.contains('0-1 year') || descLower.contains('0-2 year') ||
            descLower.contains('entry level') || descLower.contains('entry-level') ||
            descLower.contains('junior') || descLower.contains('associate')) {
            return 'Entry Level';
        }

        if (descLower.contains('5+ year') || descLower.contains('5-7 year') ||
            descLower.contains('6+ year') || descLower.contains('7+ year') ||
            descLower.contains('senior') || descLower.contains('sr.')) {
            return 'Senior';
        }

        if (descLower.contains('8+ year') || descLower.contains('10+ year') ||
            descLower.contains('lead') || descLower.contains('principal') ||
            descLower.contains('staff') || descLower.contains('architect')) {
            return 'Lead/Principal';
        }

        if (descLower.contains('2-3 year') || descLower.contains('2-4 year') ||
            descLower.contains('3-5 year') || descLower.contains('mid-level') ||
            descLower.contains('mid level') || descLower.contains('intermediate')) {
            return 'Mid-Level';
        }

        // Default to Mid-Level if years mentioned but not specific
        if (descLower.contains('year') && descLower.contains('experience')) {
            return 'Mid-Level';
        }

        return null; // Unable to detect
    }
}

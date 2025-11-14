/**
 * @description Wrapper class to extract job details from either Job_Posting__c or Opportunity
 * Provides a unified interface for accessing job information regardless of source object
 *
 * LEARNING NOTES:
 * - Wrapper Pattern: Abstracts differences between similar objects
 * - Polymorphism: Single interface for multiple data sources
 * - Null Safety: Handles missing data gracefully
 *
 * @author Claude Code Assistant
 * @date 2025-11-10
 */
public with sharing class JobContext {

    @AuraEnabled public Id recordId { get; set; }
    @AuraEnabled public String sourceObject { get; set; } // 'Job_Posting__c' or 'Opportunity'
    @AuraEnabled public String jobTitle { get; set; }
    @AuraEnabled public String companyName { get; set; }
    @AuraEnabled public String jobDescription { get; set; }
    @AuraEnabled public String requiredSkills { get; set; }
    @AuraEnabled public String industry { get; set; }

    /**
     * @description Create JobContext from Job_Posting__c record
     *
     * @param jobPostingId Job_Posting__c record ID
     * @return JobContext Populated job context
     */
    public static JobContext fromJobPosting(Id jobPostingId) {
        if (jobPostingId == null) {
            return null;
        }

        Job_Posting__c job = [
            SELECT Id, Title__c, Company__c, Description__c,
                   Tags__c, Industry__c
            FROM Job_Posting__c
            WHERE Id = :jobPostingId
            LIMIT 1
        ];

        JobContext context = new JobContext();
        context.recordId = job.Id;
        context.sourceObject = 'Job_Posting__c';
        context.jobTitle = job.Title__c;
        context.companyName = job.Company__c;
        context.jobDescription = job.Description__c;
        context.requiredSkills = job.Tags__c;
        context.industry = job.Industry__c;

        return context;
    }

    /**
     * @description Create JobContext from Opportunity record
     *
     * @param opportunityId Opportunity record ID
     * @return JobContext Populated job context
     */
    public static JobContext fromOpportunity(Id opportunityId) {
        if (opportunityId == null) {
            return null;
        }

        Opportunity opp = [
            SELECT Id, Name, Account.Name, Description,
                   Type, Account.Industry
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];

        JobContext context = new JobContext();
        context.recordId = opp.Id;
        context.sourceObject = 'Opportunity';
        context.jobTitle = opp.Name; // Opportunity Name as job title
        context.companyName = opp.Account != null ? opp.Account.Name : 'Unknown Company';
        context.jobDescription = opp.Description != null ? opp.Description : 'No description available';
        context.requiredSkills = ''; // Opportunity doesn't have skills field by default
        context.industry = opp.Account != null && opp.Account.Industry != null ? opp.Account.Industry : 'General';

        return context;
    }

    /**
     * @description Create JobContext from either Job_Posting__c or Opportunity
     * Automatically detects object type from ID
     *
     * @param recordId Either Job_Posting__c or Opportunity ID
     * @return JobContext Populated job context
     */
    public static JobContext fromRecord(Id recordId) {
        if (recordId == null) {
            return null;
        }

        String objectType = recordId.getSObjectType().getDescribe().getName();

        if (objectType == 'Job_Posting__c') {
            return fromJobPosting(recordId);
        } else if (objectType == 'Opportunity') {
            return fromOpportunity(recordId);
        } else {
            throw new JobContextException('Unsupported object type: ' + objectType + '. Must be Job_Posting__c or Opportunity.');
        }
    }

    /**
     * @description Check if context has minimum required information
     *
     * @return Boolean True if job title and company name are present
     */
    public Boolean isValid() {
        return String.isNotBlank(this.jobTitle) && String.isNotBlank(this.companyName);
    }

    /**
     * @description Get display string for UI
     *
     * @return String Formatted job title and company
     */
    public String getDisplayName() {
        if (!isValid()) {
            return 'Unknown Position';
        }
        return this.jobTitle + ' at ' + this.companyName;
    }

    /**
     * @description Custom exception for JobContext errors
     */
    public class JobContextException extends Exception {}
}

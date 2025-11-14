/**
 * @description Invocable method for generating resume packages from Opportunity records
 * Designed for Flow integration - queries related Job_Posting__c and generates resume
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-11-03
 */
public with sharing class OpportunityResumeGeneratorInvocable {

    /**
     * @description Input wrapper for Flow
     */
    public class Request {
        @InvocableVariable(label='Opportunity ID' description='ID of the Opportunity to generate resume for' required=true)
        public Id opportunityId;
    }

    /**
     * @description Output wrapper for Flow
     */
    public class Result {
        @InvocableVariable(label='Success' description='Whether the resume generation was successful')
        public Boolean success;

        @InvocableVariable(label='Resume Package ID' description='ID of the created Resume Package')
        public Id resumePackageId;

        @InvocableVariable(label='Message' description='Success or error message')
        public String message;
    }

    /**
     * @description Invocable method to generate resume packages from Opportunities
     * @param requests List of Request wrappers containing Opportunity IDs
     * @return List of Result wrappers with generation status
     */
    @InvocableMethod(label='Generate Resume Package for Opportunity'
                     description='Generates a tailored resume and cover letter from an Opportunity using Claude AI'
                     category='Resume Generation')
    public static List<Result> generateResumePackages(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result res = new Result();

            try {
                // Query the Opportunity to get the related Job_Posting__c
                List<Opportunity> opps = [
                    SELECT Id, Name, Job_Posting__c, Job_Posting__r.Id
                    FROM Opportunity
                    WHERE Id = :req.opportunityId
                    LIMIT 1
                ];

                if (opps.isEmpty()) {
                    res.success = false;
                    res.message = 'Error: Opportunity not found';
                    results.add(res);
                    continue;
                }

                Opportunity opp = opps[0];

                if (opp.Job_Posting__c == null) {
                    res.success = false;
                    res.message = 'Error: Opportunity is not linked to a Job Posting';
                    results.add(res);
                    continue;
                }

                // Generate resume package using existing ResumeGenerator
                Resume_Package__c resumePackage = ResumeGenerator.generateResumePackage(opp.Job_Posting__c);

                // Update the resume package to link it to the Opportunity
                resumePackage.Opportunity__c = opp.Id;
                update resumePackage;

                // Update Opportunity to set Application Prepared date and advance stage
                opp.Application_Prepared_Date__c = System.now();
                opp.StageName = 'Application Prepared'; // Advance to Application Prepared stage
                update opp;

                // Generate PDF files asynchronously to avoid transaction rollback issues
                // This ensures the Resume Package is committed before PDF generation
                System.debug('Queueing async PDF generation for Resume Package: ' + resumePackage.Id);
                System.enqueueJob(new ResumePDFGeneratorAsync(resumePackage.Id));

                res.resumePackageId = resumePackage.Id;
                res.success = true;
                res.message = 'Resume package generated successfully for ' + opp.Name;

            } catch (Exception e) {
                res.success = false;
                res.resumePackageId = null;
                res.message = 'Error generating resume: ' + e.getMessage();
            }

            results.add(res);
        }

        return results;
    }
}

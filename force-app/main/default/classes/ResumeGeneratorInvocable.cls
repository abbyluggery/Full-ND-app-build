/**
 * @description Invocable methods wrapper for ResumeGenerator
 * Allows Resume Generation to be called from Flows and Quick Actions
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-10-29
 */
public with sharing class ResumeGeneratorInvocable {

    /**
     * @description Invocable method to generate resume package from Flow/Quick Action
     * @param requests List of job posting IDs to generate resumes for
     * @return List of generated Resume Package IDs
     */
    @InvocableMethod(label='Generate Resume Package' description='Generates a tailored resume and cover letter for a job posting using Claude AI' category='Resume Generation')
    public static List<Result> generateResumePackages(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result res = new Result();
            try {
                Resume_Package__c resumePackage = ResumeGenerator.generateResumePackage(req.jobPostingId);
                res.resumePackageId = resumePackage.Id;
                res.success = true;
                res.message = 'Resume package generated successfully!';
            } catch (Exception e) {
                res.success = false;
                res.message = 'Error: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'Resume generation failed: ' + e.getMessage());
            }
            results.add(res);
        }

        return results;
    }

    /**
     * @description Input parameters for the invocable method
     */
    public class Request {
        @InvocableVariable(label='Job Posting ID' description='The ID of the Job Posting record' required=true)
        public Id jobPostingId;
    }

    /**
     * @description Output results from the invocable method
     */
    public class Result {
        @InvocableVariable(label='Resume Package ID' description='The ID of the generated Resume Package')
        public Id resumePackageId;

        @InvocableVariable(label='Success' description='Whether the generation was successful')
        public Boolean success;

        @InvocableVariable(label='Message' description='Success or error message')
        public String message;
    }
}

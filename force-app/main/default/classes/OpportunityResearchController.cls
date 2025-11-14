/**
 * @description Controller for Opportunity research Quick Action
 * Invocable method to trigger company research from Opportunity button
 *
 * LEARNING NOTES:
 * - Invocable Methods: Allow Flow/Process Builder/Quick Actions to call Apex
 * - @InvocableMethod: Makes method callable from declarative tools
 * - Opportunity-Centric: Works with Opportunity records instead of Job_Posting__c
 *
 * @author Claude Code Assistant
 * @date November 13, 2025
 */
public with sharing class OpportunityResearchController {

    /**
     * @description Input wrapper for invocable method
     */
    public class ResearchRequest {
        @InvocableVariable(required=true label='Opportunity ID' description='The Opportunity record to research')
        public Id opportunityId;
    }

    /**
     * @description Output wrapper for invocable method
     */
    public class ResearchResult {
        @InvocableVariable(label='Company Research ID' description='ID of created Company_Research__c record')
        public Id companyResearchId;

        @InvocableVariable(label='Success' description='Whether research was successful')
        public Boolean success;

        @InvocableVariable(label='Error Message' description='Error message if research failed')
        public String errorMessage;
    }

    /**
     * @description Generate company research for an Opportunity
     * Called from Quick Action button on Opportunity page
     *
     * @param requests List of ResearchRequest containing Opportunity IDs
     * @return List<ResearchResult> Results of research generation
     */
    @InvocableMethod(label='Research Company' description='Generate AI-powered company research for this Opportunity' category='Opportunity')
    public static List<ResearchResult> researchCompany(List<ResearchRequest> requests) {
        List<ResearchResult> results = new List<ResearchResult>();

        for (ResearchRequest request : requests) {
            ResearchResult result = new ResearchResult();
            result.success = false;

            try {
                // Validate input
                if (request.opportunityId == null) {
                    result.errorMessage = 'Opportunity ID is required';
                    results.add(result);
                    continue;
                }

                // Call CompanyResearcher to generate research
                Id researchId = CompanyResearcher.generateResearch(request.opportunityId);

                if (researchId != null) {
                    result.companyResearchId = researchId;
                    result.success = true;
                    System.debug('OpportunityResearchController: Successfully generated research: ' + researchId);
                } else {
                    result.errorMessage = 'Failed to generate research - no record created';
                }

            } catch (Exception e) {
                result.errorMessage = e.getMessage();
                System.debug(LoggingLevel.ERROR, 'OpportunityResearchController Error: ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
            }

            results.add(result);
        }

        return results;
    }

}

/**
 * @description Generates company research and interview preparation materials using Claude AI
 * Creates comprehensive research reports with talking points for interview preparation
 *
 * LEARNING NOTES:
 * - AI-Powered Research: Using Claude's training data for company insights
 * - Interview Preparation: Generating context-specific talking points
 * - Caching Strategy: Reusing research to avoid redundant API calls
 * - Staleness Detection: Identifying when research needs refresh
 *
 * @author Claude Code Assistant
 * @date 2025-11-10
 */
public with sharing class CompanyResearcher {

    private static final Integer RESEARCH_VALID_DAYS = 30; // Research older than 30 days is considered outdated

    /**
     * @description Wrapper class for research result
     */
    public class ResearchResult {
        @AuraEnabled public String companyOverview { get; set; }
        @AuraEnabled public String recentNews { get; set; }
        @AuraEnabled public String cultureInsights { get; set; }
        @AuraEnabled public String keyProducts { get; set; }
        @AuraEnabled public List<String> talkingPoints { get; set; }
        @AuraEnabled public String whyThisCompany { get; set; }
        @AuraEnabled public List<String> potentialChallenges { get; set; }

        public ResearchResult() {
            this.talkingPoints = new List<String>();
            this.potentialChallenges = new List<String>();
        }
    }

    /**
     * @description Generate or retrieve company research for a job posting or opportunity
     * Supports both Job_Posting__c and Opportunity records
     *
     * @param recordId Job_Posting__c or Opportunity record ID
     * @return Id Company_Research__c record ID
     */
    public static Id generateResearch(Id recordId) {
        String objectType = recordId.getSObjectType().getDescribe().getName();

        // Check if research already exists
        String existingQuery = 'SELECT Id, Research_Date__c, Research_Status__c ' +
                              'FROM Company_Research__c WHERE ';

        if (objectType == 'Job_Posting__c') {
            existingQuery += 'Job_Posting__c = :recordId ';
        } else if (objectType == 'Opportunity') {
            existingQuery += 'Opportunity__c = :recordId ';
        } else {
            throw new CompanyResearcherException('Invalid record type: ' + objectType);
        }

        existingQuery += 'ORDER BY Research_Date__c DESC LIMIT 1';
        List<Company_Research__c> existing = Database.query(existingQuery);

        // If recent research exists, return it
        if (!existing.isEmpty() && isResearchCurrent(existing[0].Research_Date__c)) {
            return existing[0].Id;
        }

        // Get job context
        JobContext jobContext = JobContext.fromRecord(recordId);

        // Generate research using Claude
        ResearchResult research = performResearch(jobContext);

        // Create or update research record
        Company_Research__c researchRecord;
        if (!existing.isEmpty()) {
            researchRecord = existing[0];
        } else {
            researchRecord = new Company_Research__c(
                Company_Name__c = jobContext.companyName
            );

            // Set appropriate lookup field
            if (objectType == 'Job_Posting__c') {
                researchRecord.Job_Posting__c = recordId;
            } else {
                researchRecord.Opportunity__c = recordId;
            }
        }

        updateResearchRecord(researchRecord, research);
        upsert researchRecord;

        return researchRecord.Id;
    }

    /**
     * @description Custom exception for CompanyResearcher errors
     */
    public class CompanyResearcherException extends Exception {}

    /**
     * @description Refresh existing research with latest information
     *
     * @param companyResearchId Company_Research__c record ID
     * @return Id Updated Company_Research__c record ID
     */
    public static Id refreshResearch(Id companyResearchId) {
        Company_Research__c research = [
            SELECT Id, Job_Posting__c, Job_Posting__r.Company__c,
                   Job_Posting__r.Title__c, Job_Posting__r.Description__c,
                   Job_Posting__r.Tags__c, Job_Posting__r.Industry__c
            FROM Company_Research__c
            WHERE Id = :companyResearchId
            LIMIT 1
        ];

        JobContext jobContext = JobContext.fromJobPosting(research.Job_Posting__c);
        ResearchResult newResearch = performResearch(jobContext);
        updateResearchRecord(research, newResearch);
        update research;

        return research.Id;
    }

    /**
     * @description Generate smart questions to ask the interviewer
     *
     * @param jobPostingId Job_Posting__c record ID
     * @return List<String> List of suggested questions
     */
    public static List<String> generateTalkingPoints(Id jobPostingId) {
        Job_Posting__c jobPosting = [
            SELECT Company__c, Title__c, Description__c, Industry__c
            FROM Job_Posting__c
            WHERE Id = :jobPostingId
            LIMIT 1
        ];

        String systemContext = 'You are an expert interview coach helping candidates prepare intelligent questions to ask interviewers. ' +
                              'Generate thoughtful, role-specific questions that demonstrate research and genuine interest.';

        String userPrompt = 'Generate 5 smart questions a candidate should ask when interviewing for:\n\n' +
                           'Role: ' + jobPosting.Title__c + '\n' +
                           'Company: ' + jobPosting.Company__c + '\n' +
                           'Industry: ' + (jobPosting.Industry__c != null ? jobPosting.Industry__c : 'General') + '\n\n' +
                           'Questions should:\n' +
                           '- Show you researched the company\n' +
                           '- Relate to the specific role\n' +
                           '- Help assess if it\'s a good fit for you\n' +
                           '- Be appropriate for an interview setting\n\n' +
                           'Return as JSON array:\n' +
                           '{"questions": ["question1", "question2", "question3", "question4", "question5"]}\n\n' +
                           'IMPORTANT: Return ONLY the JSON object, no additional text.';

        ClaudeAPIService.ClaudeResponse response = ClaudeAPIService.generateText(systemContext, userPrompt);

        return parseTalkingPointsResponse(response);
    }

    /**
     * @description Analyze why candidate is a good fit for the role
     *
     * @param jobPostingId Job_Posting__c record ID
     * @return String Analysis of job fit
     */
    public static String analyzeJobFit(Id jobPostingId) {
        Job_Posting__c jobPosting = [
            SELECT Company__c, Title__c, Description__c, Tags__c
            FROM Job_Posting__c
            WHERE Id = :jobPostingId
            LIMIT 1
        ];

        // Get user's resume package for context (if exists)
        String candidateBackground = '';
        List<Resume_Package__c> resumes = [
            SELECT Resume_Content__c
            FROM Resume_Package__c
            WHERE Job_Posting__c = :jobPostingId
            LIMIT 1
        ];

        if (!resumes.isEmpty() && String.isNotBlank(resumes[0].Resume_Content__c)) {
            candidateBackground = resumes[0].Resume_Content__c.left(1000); // First 1000 chars
        }

        String systemContext = 'You are a career coach helping candidates articulate why they\'re a strong fit for a role.';

        String userPrompt = 'Help the candidate understand why they might be excited about this opportunity:\n\n' +
                           'Role: ' + jobPosting.Title__c + '\n' +
                           'Company: ' + jobPosting.Company__c + '\n' +
                           'Job Description: ' + (jobPosting.Description__c != null ? jobPosting.Description__c.left(500) : 'Not provided') + '\n' +
                           'Required Skills: ' + (jobPosting.Tags__c != null ? jobPosting.Tags__c : 'Not specified') + '\n\n';

        if (String.isNotBlank(candidateBackground)) {
            userPrompt += 'Candidate Background (abbreviated):\n' + candidateBackground + '\n\n';
        }

        userPrompt += 'Provide a compelling 2-3 paragraph explanation of why this role could be a great fit, focusing on:\n' +
                     '1. How the role aligns with career growth\n' +
                     '2. Opportunities to apply and develop skills\n' +
                     '3. What makes this company/role exciting\n\n' +
                     'Write in first person (I/my) so the candidate can use it as talking points.';

        ClaudeAPIService.ClaudeResponse response = ClaudeAPIService.generateText(systemContext, userPrompt);

        return response.content[0].text;
    }

    // ==================== PRIVATE HELPER METHODS ====================

    /**
     * @description Perform AI-powered company research
     */
    private static ResearchResult performResearch(JobContext jobContext) {
        String systemContext = 'You are an expert career researcher providing interview preparation insights. ' +
                              'Generate comprehensive, accurate company research based on your training data. ' +
                              'If you don\'t have specific information, provide general industry insights. ' +
                              'Always respond with valid JSON in the exact format requested.';

        String userPrompt = 'Generate comprehensive interview preparation research for:\n\n' +
                           'Company: ' + jobContext.companyName + '\n' +
                           'Position: ' + jobContext.jobTitle + '\n' +
                           'Industry: ' + (String.isNotBlank(jobContext.industry) ? jobContext.industry : 'General') + '\n' +
                           'Job Description: ' + (String.isNotBlank(jobContext.jobDescription) ? jobContext.jobDescription.left(500) : 'Not provided') + '\n\n' +
                           'Provide response as JSON:\n' +
                           '{\n' +
                           '  "companyOverview": "2-3 sentence summary of the company",\n' +
                           '  "recentNews": "Latest developments or general industry context",\n' +
                           '  "cultureInsights": "Work culture observations or industry standards",\n' +
                           '  "keyProducts": "Main products/services or typical offerings",\n' +
                           '  "talkingPoints": ["question1 to ask interviewer", "question2", "question3"],\n' +
                           '  "whyThisCompany": "Why you\'re excited about this opportunity",\n' +
                           '  "potentialChallenges": ["challenge1 to prepare for", "challenge2"]\n' +
                           '}\n\n' +
                           'IMPORTANT: Return ONLY the JSON object, no additional text.';

        ClaudeAPIService.ClaudeResponse response = ClaudeAPIService.generateText(systemContext, userPrompt);

        return parseResearchResponse(response);
    }

    /**
     * @description Check if research is still current
     */
    private static Boolean isResearchCurrent(DateTime researchDate) {
        if (researchDate == null) {
            return false;
        }

        DateTime now = DateTime.now();
        Integer daysDiff = researchDate.date().daysBetween(now.date());

        return daysDiff <= RESEARCH_VALID_DAYS;
    }

    /**
     * @description Parse Claude's research response into ResearchResult
     */
    private static ResearchResult parseResearchResponse(ClaudeAPIService.ClaudeResponse response) {
        ResearchResult result = new ResearchResult();

        try {
            String responseText = response.content[0].text.trim();

            // Remove markdown code blocks if present
            if (responseText.startsWith('```json')) {
                responseText = responseText.substringAfter('```json').substringBefore('```').trim();
            } else if (responseText.startsWith('```')) {
                responseText = responseText.substringAfter('```').substringBefore('```').trim();
            }

            // Parse JSON
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(responseText);

            result.companyOverview = (String) parsed.get('companyOverview');
            result.recentNews = (String) parsed.get('recentNews');
            result.cultureInsights = (String) parsed.get('cultureInsights');
            result.keyProducts = (String) parsed.get('keyProducts');
            result.whyThisCompany = (String) parsed.get('whyThisCompany');

            // Parse arrays
            List<Object> talking = (List<Object>) parsed.get('talkingPoints');
            if (talking != null) {
                for (Object t : talking) {
                    result.talkingPoints.add((String) t);
                }
            }

            List<Object> challenges = (List<Object>) parsed.get('potentialChallenges');
            if (challenges != null) {
                for (Object c : challenges) {
                    result.potentialChallenges.add((String) c);
                }
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to parse research: ' + e.getMessage());
            // Fallback values
            result.companyOverview = 'Unable to generate research automatically. Please research the company manually.';
            result.recentNews = 'Check the company website and recent news articles.';
            result.cultureInsights = 'Review company reviews on Glassdoor and similar platforms.';
        }

        return result;
    }

    /**
     * @description Parse talking points response
     */
    private static List<String> parseTalkingPointsResponse(ClaudeAPIService.ClaudeResponse response) {
        List<String> talkingPoints = new List<String>();

        try {
            String responseText = response.content[0].text.trim();

            // Remove markdown code blocks if present
            if (responseText.startsWith('```json')) {
                responseText = responseText.substringAfter('```json').substringBefore('```').trim();
            } else if (responseText.startsWith('```')) {
                responseText = responseText.substringAfter('```').substringBefore('```').trim();
            }

            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(responseText);
            List<Object> questions = (List<Object>) parsed.get('questions');

            if (questions != null) {
                for (Object q : questions) {
                    talkingPoints.add((String) q);
                }
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to parse talking points: ' + e.getMessage());
            // Fallback questions
            talkingPoints.add('What does success look like in this role after 6 months?');
            talkingPoints.add('How does this team collaborate with other departments?');
            talkingPoints.add('What are the biggest challenges facing the team right now?');
        }

        return talkingPoints;
    }

    /**
     * @description Update research record with results
     */
    private static void updateResearchRecord(Company_Research__c record, ResearchResult research) {
        record.Research_Date__c = DateTime.now();
        record.Research_Status__c = 'Ready';
        record.Company_Overview__c = research.companyOverview;
        record.Recent_News__c = research.recentNews;
        record.Culture_Insights__c = research.cultureInsights;
        record.Key_Products_Services__c = research.keyProducts;
        record.Why_This_Company__c = research.whyThisCompany;

        // Convert lists to text
        if (!research.talkingPoints.isEmpty()) {
            record.Interview_Talking_Points__c = String.join(research.talkingPoints, '\n\n');
        }

        if (!research.potentialChallenges.isEmpty()) {
            record.Potential_Challenges__c = String.join(research.potentialChallenges, '\n\n');
        }
    }
}

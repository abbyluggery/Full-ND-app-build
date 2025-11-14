/**
 * @description Generates tailored resumes and cover letters using Claude AI
 * Includes explicit safeguards against AI hallucination
 * Ensures ALL jobs and employment gaps are preserved
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-10-29
 */
public with sharing class ResumeGenerator {

    /**
     * @description Main method to generate a complete resume package for a job
     * @param jobPostingId The ID of the Job_Posting__c record
     * @return Resume_Package__c The generated resume package (inserted)
     */
    public static Resume_Package__c generateResumePackage(Id jobPostingId) {
        // Get the job posting with all details
        Job_Posting__c job = [
            SELECT Id, Title__c, Company__c, Location__c, Description__c,
                   ND_Friendliness_Score__c, Green_Flags__c, Red_Flags__c
            FROM Job_Posting__c
            WHERE Id = :jobPostingId
            LIMIT 1
        ];

        // Get company research if available
        CompanyResearcher.ResearchResult companyResearch = getCompanyResearch(jobPostingId);

        // Get your master resume content from Master Resume Config object
        List<Master_Resume_Config__c> masterResumeList = [
            SELECT Id, Resume_Content__c, Key_Achievements__c,
                   Technical_Skills__c, Cover_Letter_Template__c
            FROM Master_Resume_Config__c
            LIMIT 1
        ];

        if (masterResumeList.isEmpty() || String.isBlank(masterResumeList[0].Resume_Content__c)) {
            throw new ResumeGeneratorException('Master resume not configured. Please create a Master Resume Config record.');
        }

        Master_Resume_Config__c masterResume = masterResumeList[0];

        // Build the system context for Claude
        String systemContext = buildResumeSystemContext();

        // Build the resume generation prompt with company research
        String resumePrompt = buildResumePrompt(job, masterResume, companyResearch);

        // Call Claude to generate the resume
        ClaudeAPIService.ClaudeResponse resumeResponse = ClaudeAPIService.generateText(
            systemContext,
            resumePrompt
        );

        String resumeContent = ClaudeAPIService.extractTextContent(resumeResponse);

        // Build the cover letter generation prompt with company research
        String coverLetterPrompt = buildCoverLetterPrompt(job, masterResume, companyResearch);

        // Call Claude to generate the cover letter
        ClaudeAPIService.ClaudeResponse coverLetterResponse = ClaudeAPIService.generateText(
            systemContext,
            coverLetterPrompt
        );

        String coverLetterContent = ClaudeAPIService.extractTextContent(coverLetterResponse);

        // Create the resume package record
        Resume_Package__c resumePackage = new Resume_Package__c();
        resumePackage.Job_Posting__c = jobPostingId;
        resumePackage.Resume_Content__c = cleanContent(resumeContent);
        resumePackage.Cover_Letter__c = cleanContent(coverLetterContent);
        resumePackage.Status__c = 'Draft';
        resumePackage.Generated_Date__c = System.now();

        insert resumePackage;

        return resumePackage;
    }

    /**
     * @description Retrieves company research for a job posting (or from Opportunity)
     * @param jobPostingId The Job_Posting__c ID
     * @return CompanyResearcher.ResearchResult Company research data (or null if not found)
     */
    private static CompanyResearcher.ResearchResult getCompanyResearch(Id jobPostingId) {
        try {
            // Check if company research exists for this Job_Posting__c
            List<Company_Research__c> research = [
                SELECT Id, Company_Overview__c, Recent_News__c, Culture_Insights__c,
                       Key_Products_Services__c, Interview_Talking_Points__c,
                       Why_This_Company__c, Potential_Challenges__c
                FROM Company_Research__c
                WHERE Job_Posting__c = :jobPostingId
                ORDER BY Research_Date__c DESC
                LIMIT 1
            ];

            if (!research.isEmpty()) {
                return convertToResearchResult(research[0]);
            }

            // If no research found for Job_Posting__c, check if there's an Opportunity with research
            List<Opportunity> opps = [
                SELECT Id, (SELECT Id, Company_Overview__c, Recent_News__c, Culture_Insights__c,
                                   Key_Products_Services__c, Interview_Talking_Points__c,
                                   Why_This_Company__c, Potential_Challenges__c
                            FROM Company_Research__r
                            ORDER BY Research_Date__c DESC
                            LIMIT 1)
                FROM Opportunity
                WHERE Job_Posting__c = :jobPostingId
                LIMIT 1
            ];

            if (!opps.isEmpty() && !opps[0].Company_Research__r.isEmpty()) {
                return convertToResearchResult(opps[0].Company_Research__r[0]);
            }

            return null; // No research found
        } catch (Exception e) {
            System.debug('Could not retrieve company research: ' + e.getMessage());
            return null; // Graceful degradation if research not available
        }
    }

    /**
     * @description Converts Company_Research__c record to ResearchResult wrapper
     */
    private static CompanyResearcher.ResearchResult convertToResearchResult(Company_Research__c rec) {
        CompanyResearcher.ResearchResult result = new CompanyResearcher.ResearchResult();
        result.companyOverview = rec.Company_Overview__c;
        result.recentNews = rec.Recent_News__c;
        result.cultureInsights = rec.Culture_Insights__c;
        result.keyProducts = rec.Key_Products_Services__c;
        result.whyThisCompany = rec.Why_This_Company__c;

        // Parse talking points and challenges from text fields
        if (String.isNotBlank(rec.Interview_Talking_Points__c)) {
            result.talkingPoints = rec.Interview_Talking_Points__c.split('\n\n');
        }
        if (String.isNotBlank(rec.Potential_Challenges__c)) {
            result.potentialChallenges = rec.Potential_Challenges__c.split('\n\n');
        }

        return result;
    }

    /**
     * @description Builds the system context for resume generation
     */
    private static String buildResumeSystemContext() {
        String context = 'You are an expert resume writer specializing in Salesforce careers. ';
        context += 'You help candidates highlight their most relevant experience for specific roles. ';
        context += 'You write in a professional, achievement-oriented style with quantified results. ';
        context += 'You understand ATS (Applicant Tracking Systems) and optimize for keywords. ';
        context += 'You understand neurodivergent professionals and can highlight their unique strengths.\n\n';

        return context;
    }

    /**
     * @description Builds the prompt for resume generation with STRONG hallucination prevention
     */
    private static String buildResumePrompt(Job_Posting__c job, Master_Resume_Config__c masterResume, CompanyResearcher.ResearchResult companyResearch) {
        String prompt = '## Task: Generate a Tailored Resume\n\n';

        prompt += '### Job Details:\n';
        prompt += '**Title:** ' + job.Title__c + '\n';
        prompt += '**Company:** ' + job.Company__c + '\n';
        if (String.isNotBlank(job.Description__c)) {
            prompt += '**Job Description:**\n' + job.Description__c.substring(0, Math.min(3000, job.Description__c.length())) + '\n\n';
        }

        // Add company research if available
        if (companyResearch != null) {
            prompt += '### Company Research (For Context Only - DO NOT Fabricate Experience):\n';
            if (String.isNotBlank(companyResearch.companyOverview)) {
                prompt += '**Company Overview:** ' + companyResearch.companyOverview + '\n';
            }
            if (String.isNotBlank(companyResearch.keyProducts)) {
                prompt += '**Key Products/Services:** ' + companyResearch.keyProducts + '\n';
            }
            if (String.isNotBlank(companyResearch.cultureInsights)) {
                prompt += '**Culture Insights:** ' + companyResearch.cultureInsights + '\n';
            }
            prompt += '**⚠️ Use this ONLY to understand what the company values. DO NOT add it to work history.**\n\n';
        }

        prompt += '### Candidate\'s Master Resume:\n';
        prompt += masterResume.Resume_Content__c + '\n\n';

        prompt += '### Additional Context:\n';
        if (String.isNotBlank(masterResume.Key_Achievements__c)) {
            prompt += '**Key Achievements:**\n' + masterResume.Key_Achievements__c + '\n\n';
        }
        if (String.isNotBlank(masterResume.Technical_Skills__c)) {
            prompt += '**Technical Skills:**\n' + masterResume.Technical_Skills__c + '\n\n';
        }

        // CRITICAL HALLUCINATION PREVENTION RULES
        prompt += '### ⚠️ CRITICAL RULES - DO NOT VIOLATE:\n';
        prompt += '1. DO NOT add information from the job description to the candidate\'s work history\n';
        prompt += '2. DO NOT make up experience at the target company\n';
        prompt += '3. ONLY use actual experience from the Master Resume above\n';
        prompt += '4. You may REWORD bullets to match job keywords, but do NOT fabricate experience\n';
        prompt += '5. Keep ALL jobs from the candidate\'s history - do not remove any\n';
        prompt += '6. Keep ALL information 100% factual as found in the Master Resume - no embellishments\n';
        prompt += '7. INCLUDE ALL employment periods, including gaps (Medical Leave, Caregiver periods)\n';
        prompt += '8. List EVERY job in chronological order from the Master Resume\n';
        prompt += '9. DO NOT consolidate or skip any positions, even if they seem less relevant\n\n';

        prompt += '### Instructions for Tailoring:\n';
        prompt += '10. Analyze the job description and identify key requirements\n';
        prompt += '11. From the master resume, select and emphasize the most relevant experience\n';
        prompt += '12. Tailor bullet points to match the job requirements\n';
        prompt += '13. Add relevant keywords from the job description naturally\n';
        prompt += '14. Quantify achievements wherever possible\n';
        prompt += '15. Keep the resume to 1-2 pages\n';
        prompt += '16. Use a clean, ATS-friendly format\n\n';

        prompt += '### Final Review Process:\n';
        prompt += '17. After creating the resume, review it for signs of AI writing\n';
        prompt += '18. Rewrite any AI-sounding sections to reflect natural human writing style\n';
        prompt += '19. Ensure the tone is professional but conversational and authentic\n';
        prompt += '20. Remove any generic corporate jargon or buzzword-heavy phrases\n\n';

        prompt += '### Output Format:\n';
        prompt += 'Provide the complete resume in plain text format, ready to copy-paste.\n';
        prompt += '⚠️ CRITICAL: Include EVERY job listed in the Master Resume, even if some seem less relevant.\n';
        prompt += 'Use this structure:\n';
        prompt += '- Contact Information\n';
        prompt += '- Professional Summary (3-4 lines tailored to this role)\n';
        prompt += '- Technical Skills (relevant to this job)\n';
        prompt += '- Professional Experience (ALL jobs from master resume, tailored bullets)\n';
        prompt += '- Education\n';
        prompt += '- Certifications\n\n';

        prompt += 'Begin the resume now:';

        return prompt;
    }

    /**
     * @description Builds the prompt for cover letter generation
     */
    private static String buildCoverLetterPrompt(Job_Posting__c job, Master_Resume_Config__c masterResume) {
        String prompt = '## Task: Generate a Tailored Cover Letter\n\n';

        prompt += '### Job Details:\n';
        prompt += '**Title:** ' + job.Title__c + '\n';
        prompt += '**Company:** ' + job.Company__c + '\n';
        if (String.isNotBlank(job.Description__c)) {
            prompt += '**Job Description:**\n' + job.Description__c.substring(0, Math.min(2000, job.Description__c.length())) + '\n\n';
        }

        prompt += '### Candidate Information:\n';
        prompt += masterResume.Resume_Content__c.substring(0, Math.min(2000, masterResume.Resume_Content__c.length())) + '\n\n';

        if (String.isNotBlank(masterResume.Cover_Letter_Template__c)) {
            prompt += '### Cover Letter Style/Template:\n';
            prompt += masterResume.Cover_Letter_Template__c + '\n\n';
        }

        prompt += '### Instructions:\n';
        prompt += '1. Write a compelling 3-4 paragraph cover letter\n';
        prompt += '2. Paragraph 1: Hook - why you\'re excited about THIS specific role/company\n';
        prompt += '3. Paragraph 2-3: Highlight 2-3 most relevant achievements that match their needs\n';
        prompt += '4. Paragraph 4: Close with confidence and call to action\n';
        prompt += '5. Keep it under 400 words\n';
        prompt += '6. Use a professional but warm tone\n';
        prompt += '7. Show genuine enthusiasm for the role\n';
        prompt += '8. Review for AI-sounding language and rewrite naturally\n\n';

        prompt += '### Output Format:\n';
        prompt += 'Provide the complete cover letter in plain text format, ready to copy-paste.\n';
        prompt += 'Include appropriate greeting and closing.\n\n';

        prompt += 'Begin the cover letter now:';

        return prompt;
    }

    /**
     * @description Cleans up Claude's response content
     */
    private static String cleanContent(String content) {
        if (String.isBlank(content)) {
            return '';
        }

        // Remove markdown code blocks if present
        content = content.replaceAll('```[\\w]*\\n', '');
        content = content.replaceAll('```', '');

        // Trim whitespace
        content = content.trim();

        return content;
    }

    /**
     * @description Test/helper method to view a resume package
     * @param packageId The Resume_Package__c record ID
     */
    public static void viewResumePackage(Id packageId) {
        Resume_Package__c pkg = [
            SELECT Id, Resume_Content__c, Cover_Letter__c, Status__c, Generated_Date__c
            FROM Resume_Package__c
            WHERE Id = :packageId
            LIMIT 1
        ];

        System.debug('========================================');
        System.debug('RESUME PACKAGE: ' + pkg.Id);
        System.debug('Status: ' + pkg.Status__c);
        System.debug('Generated: ' + pkg.Generated_Date__c);
        System.debug('========================================');
        System.debug('');
        System.debug('========== GENERATED RESUME ==========');
        System.debug(pkg.Resume_Content__c);
        System.debug('');
        System.debug('========== GENERATED COVER LETTER ==========');
        System.debug(pkg.Cover_Letter__c);
    }

    /**
     * @description Test/helper method to generate resume for testing
     * @param jobId The Job_Posting__c record ID
     */
    public static void testGenerateResume(Id jobId) {
        System.debug('🚀 Starting resume generation for job: ' + jobId);

        try {
            Resume_Package__c resumePackage = generateResumePackage(jobId);

            System.debug('✅✅✅ SUCCESS! Resume Package ID: ' + resumePackage.Id);
            System.debug('');
            System.debug('=== RESUME PREVIEW (first 500 chars) ===');
            System.debug(resumePackage.Resume_Content__c.substring(0, Math.min(500, resumePackage.Resume_Content__c.length())));
            System.debug('');
            System.debug('=== COVER LETTER PREVIEW (first 300 chars) ===');
            System.debug(resumePackage.Cover_Letter__c.substring(0, Math.min(300, resumePackage.Cover_Letter__c.length())));

        } catch (Exception e) {
            System.debug('❌ ERROR: ' + e.getMessage());
            System.debug('Line: ' + e.getLineNumber());
            System.debug('Stack: ' + e.getStackTraceString());
        }
    }

    /**
     * @description Custom exception class
     */
    public class ResumeGeneratorException extends Exception {}
}

/**
 * @description Generates contextual interview questions using Claude API
 * Produces questions tailored to job posting, session type, and candidate experience
 *
 * LEARNING NOTES:
 * - AI Question Generation: Using Claude to create realistic interview questions
 * - JSON Parsing: Extracting structured data from AI responses
 * - Prompt Engineering: Crafting prompts for consistent, high-quality output
 * - Stateful Generation: Avoiding duplicate questions within same session
 *
 * @author Claude Code Assistant
 * @date 2025-11-10
 */
public with sharing class QuestionGenerator {

    /**
     * @description Wrapper class for question generation result
     */
    public class GeneratedQuestion {
        @AuraEnabled public String question { get; set; }
        @AuraEnabled public String questionType { get; set; }
        @AuraEnabled public List<String> evaluationCriteria { get; set; }
        @AuraEnabled public List<String> idealResponseElements { get; set; }

        public GeneratedQuestion() {
            this.evaluationCriteria = new List<String>();
            this.idealResponseElements = new List<String>();
        }
    }

    /**
     * @description Generate next interview question for a session
     *
     * @param sessionId Interview_Prep_Session__c record ID
     * @return GeneratedQuestion The generated question with metadata
     */
    public static GeneratedQuestion generateQuestion(Id sessionId) {
        // Query session with previous questions
        Interview_Prep_Session__c session = [
            SELECT Id, Session_Type__c, Questions_Asked__c,
                   Job_Posting__c, Opportunity__c,
                   (SELECT Question_Text__c FROM Interview_Responses__r ORDER BY Question_Number__c)
            FROM Interview_Prep_Session__c
            WHERE Id = :sessionId
            LIMIT 1
        ];

        // Get job context from either Job_Posting__c or Opportunity
        Id recordId = session.Job_Posting__c != null ? session.Job_Posting__c : session.Opportunity__c;
        JobContext jobContext = JobContext.fromRecord(recordId);

        // Build list of previous questions to avoid duplicates
        List<String> previousQuestions = new List<String>();
        for (Interview_Response__c response : session.Interview_Responses__r) {
            previousQuestions.add(response.Question_Text__c);
        }

        // Build system context
        String systemContext = buildSystemContext();

        // Build user prompt
        String userPrompt = buildQuestionPrompt(session, jobContext, previousQuestions);

        // Call Claude API
        ClaudeAPIService.ClaudeResponse response = ClaudeAPIService.generateText(systemContext, userPrompt);

        // Parse JSON response
        GeneratedQuestion result = parseQuestionResponse(response);

        return result;
    }

    /**
     * @description Generate a specific type of question (behavioral, technical, etc.)
     *
     * @param sessionId Interview session
     * @param questionType Type of question to generate
     * @return GeneratedQuestion The generated question
     */
    public static GeneratedQuestion generateQuestionByType(Id sessionId, String questionType) {
        Interview_Prep_Session__c session = [
            SELECT Id, Session_Type__c, Job_Posting__c, Opportunity__c
            FROM Interview_Prep_Session__c
            WHERE Id = :sessionId
            LIMIT 1
        ];

        // Get job context
        Id recordId = session.Job_Posting__c != null ? session.Job_Posting__c : session.Opportunity__c;
        JobContext jobContext = JobContext.fromRecord(recordId);

        String systemContext = buildSystemContext();
        String userPrompt = buildTypedQuestionPrompt(jobContext, questionType);

        ClaudeAPIService.ClaudeResponse response = ClaudeAPIService.generateText(systemContext, userPrompt);
        GeneratedQuestion result = parseQuestionResponse(response);
        result.questionType = questionType;

        return result;
    }

    /**
     * @description Get pre-built technical questions for specific role
     *
     * @param role Job role/title
     * @return List<GeneratedQuestion> List of technical questions
     */
    public static List<GeneratedQuestion> getTechnicalQuestions(String role) {
        // For common roles, return curated question sets
        List<GeneratedQuestion> questions = new List<GeneratedQuestion>();

        if (role.containsIgnoreCase('Salesforce') || role.containsIgnoreCase('Admin')) {
            questions.addAll(getSalesforceQuestions());
        } else if (role.containsIgnoreCase('Developer') || role.containsIgnoreCase('Engineer')) {
            questions.addAll(getDeveloperQuestions());
        } else if (role.containsIgnoreCase('Analyst')) {
            questions.addAll(getAnalystQuestions());
        } else {
            // Generic technical questions
            questions.addAll(getGenericTechnicalQuestions());
        }

        return questions;
    }

    /**
     * @description Get common behavioral questions (STAR method)
     *
     * @return List<GeneratedQuestion> List of behavioral questions
     */
    public static List<GeneratedQuestion> getBehavioralQuestions() {
        List<GeneratedQuestion> questions = new List<GeneratedQuestion>();

        // Common behavioral questions with evaluation criteria
        GeneratedQuestion q1 = new GeneratedQuestion();
        q1.question = 'Tell me about a time when you had to deal with a difficult stakeholder or team member. How did you handle it?';
        q1.questionType = 'Behavioral';
        q1.evaluationCriteria = new List<String>{'Conflict resolution', 'Communication skills', 'Emotional intelligence'};
        q1.idealResponseElements = new List<String>{'Situation described', 'Task/challenge identified', 'Actions taken', 'Positive result'};
        questions.add(q1);

        GeneratedQuestion q2 = new GeneratedQuestion();
        q2.question = 'Describe a situation where you had to learn something new quickly to complete a project. What was your approach?';
        q2.questionType = 'Behavioral';
        q2.evaluationCriteria = new List<String>{'Learning agility', 'Problem-solving', 'Time management'};
        q2.idealResponseElements = new List<String>{'Learning challenge', 'Resources used', 'Application of knowledge', 'Successful outcome'};
        questions.add(q2);

        GeneratedQuestion q3 = new GeneratedQuestion();
        q3.question = 'Give me an example of a time when you had to make a decision with incomplete information. What did you do?';
        q3.questionType = 'Behavioral';
        q3.evaluationCriteria = new List<String>{'Decision-making', 'Risk assessment', 'Critical thinking'};
        q3.idealResponseElements = new List<String>{'Context of uncertainty', 'Information gathered', 'Decision rationale', 'Outcome and lessons'};
        questions.add(q3);

        return questions;
    }

    // ==================== PRIVATE HELPER METHODS ====================

    /**
     * @description Build system context for Claude (expert interview coach persona)
     */
    private static String buildSystemContext() {
        return 'You are an expert interview coach with 20+ years of experience in talent acquisition. ' +
               'You generate realistic, challenging interview questions that help candidates prepare effectively. ' +
               'Your questions are fair, relevant, and test real-world competencies. ' +
               'Always respond with valid JSON in the exact format requested.';
    }

    /**
     * @description Build user prompt for question generation
     */
    private static String buildQuestionPrompt(Interview_Prep_Session__c session, JobContext jobContext, List<String> previousQuestions) {
        String jobRole = jobContext != null && String.isNotBlank(jobContext.jobTitle) ? jobContext.jobTitle : 'Professional';
        String company = jobContext != null && String.isNotBlank(jobContext.companyName) ? jobContext.companyName : 'the company';
        String jobDescription = jobContext != null && String.isNotBlank(jobContext.jobDescription) ? jobContext.jobDescription : 'No description provided';
        String skills = jobContext != null && String.isNotBlank(jobContext.requiredSkills) ? jobContext.requiredSkills : 'General skills';

        String prompt = 'Generate ONE interview question for a ' + session.Session_Type__c + ' interview for a ' +
                       jobRole + ' position at ' + company + '.\n\n' +
                       'Job Description: ' + jobDescription.left(500) + '\n' +
                       'Required Skills: ' + skills + '\n\n';

        if (!previousQuestions.isEmpty()) {
            prompt += 'Questions already asked (DO NOT REPEAT):\n';
            for (Integer i = 0; i < Math.min(previousQuestions.size(), 5); i++) {
                prompt += '- ' + previousQuestions[i] + '\n';
            }
            prompt += '\n';
        }

        prompt += 'Generate a challenging but fair question that tests a specific competency. ' +
                 'Format your response as JSON:\n' +
                 '{\n' +
                 '  "question": "The interview question",\n' +
                 '  "questionType": "Behavioral|Technical|Situational|Culture Fit",\n' +
                 '  "evaluationCriteria": ["criterion1", "criterion2", "criterion3"],\n' +
                 '  "idealResponseElements": ["element1", "element2", "element3"]\n' +
                 '}\n\n' +
                 'IMPORTANT: Return ONLY the JSON object, no additional text.';

        return prompt;
    }

    /**
     * @description Build prompt for specific question type
     */
    private static String buildTypedQuestionPrompt(JobContext jobContext, String questionType) {
        String jobRole = jobContext != null && String.isNotBlank(jobContext.jobTitle) ? jobContext.jobTitle : 'Professional';
        String company = jobContext != null && String.isNotBlank(jobContext.companyName) ? jobContext.companyName : 'the company';

        String prompt = 'Generate ONE ' + questionType + ' interview question for a ' + jobRole +
                       ' position at ' + company + '.\n\n';

        if (questionType == 'Behavioral') {
            prompt += 'Use the STAR method framework (Situation, Task, Action, Result).\n';
        } else if (questionType == 'Technical') {
            prompt += 'Focus on hands-on technical skills and problem-solving.\n';
        }

        prompt += '\nFormat your response as JSON:\n' +
                 '{\n' +
                 '  "question": "The interview question",\n' +
                 '  "questionType": "' + questionType + '",\n' +
                 '  "evaluationCriteria": ["criterion1", "criterion2"],\n' +
                 '  "idealResponseElements": ["element1", "element2"]\n' +
                 '}\n\n' +
                 'IMPORTANT: Return ONLY the JSON object, no additional text.';

        return prompt;
    }

    /**
     * @description Parse Claude's JSON response into GeneratedQuestion
     */
    private static GeneratedQuestion parseQuestionResponse(ClaudeAPIService.ClaudeResponse response) {
        GeneratedQuestion result = new GeneratedQuestion();

        try {
            // Extract text from Claude response
            String responseText = response.content[0].text.trim();

            // Remove markdown code blocks if present
            if (responseText.startsWith('```json')) {
                responseText = responseText.substringAfter('```json').substringBefore('```').trim();
            } else if (responseText.startsWith('```')) {
                responseText = responseText.substringAfter('```').substringBefore('```').trim();
            }

            // Parse JSON
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(responseText);

            result.question = (String) parsed.get('question');
            result.questionType = (String) parsed.get('questionType');

            // Parse arrays
            List<Object> criteria = (List<Object>) parsed.get('evaluationCriteria');
            if (criteria != null) {
                for (Object c : criteria) {
                    result.evaluationCriteria.add((String) c);
                }
            }

            List<Object> elements = (List<Object>) parsed.get('idealResponseElements');
            if (elements != null) {
                for (Object e : elements) {
                    result.idealResponseElements.add((String) e);
                }
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to parse question: ' + e.getMessage());
            // Fallback: use raw response as question
            result.question = 'Tell me about your experience relevant to this role.';
            result.questionType = 'General';
        }

        return result;
    }

    /**
     * @description Get Salesforce-specific technical questions
     */
    private static List<GeneratedQuestion> getSalesforceQuestions() {
        List<GeneratedQuestion> questions = new List<GeneratedQuestion>();

        GeneratedQuestion q1 = new GeneratedQuestion();
        q1.question = 'Explain the difference between a role, profile, and permission set in Salesforce. When would you use each?';
        q1.questionType = 'Technical';
        q1.evaluationCriteria = new List<String>{'Security knowledge', 'Best practices', 'Real-world application'};
        q1.idealResponseElements = new List<String>{'Clear definitions', 'Use cases', 'Examples'};
        questions.add(q1);

        GeneratedQuestion q2 = new GeneratedQuestion();
        q2.question = 'How would you design a data model for a complex business requirement with multiple object relationships?';
        q2.questionType = 'Technical';
        q2.evaluationCriteria = new List<String>{'Data modeling', 'Relationship understanding', 'Scalability thinking'};
        q2.idealResponseElements = new List<String>{'Requirement analysis', 'Object design', 'Relationship types', 'Considerations'};
        questions.add(q2);

        return questions;
    }

    /**
     * @description Get developer-specific technical questions
     */
    private static List<GeneratedQuestion> getDeveloperQuestions() {
        List<GeneratedQuestion> questions = new List<GeneratedQuestion>();

        GeneratedQuestion q1 = new GeneratedQuestion();
        q1.question = 'Describe a time when you had to optimize code for performance. What was your approach?';
        q1.questionType = 'Technical';
        q1.evaluationCriteria = new List<String>{'Performance optimization', 'Problem analysis', 'Technical depth'};
        q1.idealResponseElements = new List<String>{'Performance issue identified', 'Analysis tools used', 'Optimization techniques', 'Results'};
        questions.add(q1);

        return questions;
    }

    /**
     * @description Get analyst-specific technical questions
     */
    private static List<GeneratedQuestion> getAnalystQuestions() {
        List<GeneratedQuestion> questions = new List<GeneratedQuestion>();

        GeneratedQuestion q1 = new GeneratedQuestion();
        q1.question = 'Walk me through how you would analyze a dataset to identify trends and make recommendations.';
        q1.questionType = 'Technical';
        q1.evaluationCriteria = new List<String>{'Analytical thinking', 'Data literacy', 'Communication'};
        q1.idealResponseElements = new List<String>{'Data exploration', 'Analysis methods', 'Insights derived', 'Recommendations'};
        questions.add(q1);

        return questions;
    }

    /**
     * @description Get generic technical questions
     */
    private static List<GeneratedQuestion> getGenericTechnicalQuestions() {
        List<GeneratedQuestion> questions = new List<GeneratedQuestion>();

        GeneratedQuestion q1 = new GeneratedQuestion();
        q1.question = 'How do you stay current with industry trends and new technologies in your field?';
        q1.questionType = 'Technical';
        q1.evaluationCriteria = new List<String>{'Continuous learning', 'Professional development', 'Industry awareness'};
        q1.idealResponseElements = new List<String>{'Learning resources', 'Application of new knowledge', 'Examples'};
        questions.add(q1);

        return questions;
    }
}

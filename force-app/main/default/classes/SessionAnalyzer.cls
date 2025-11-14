/**
 * @description Analyzes interview responses and calculates performance metrics
 * Uses Claude AI to provide detailed feedback and scoring on interview answers
 *
 * LEARNING NOTES:
 * - AI-Powered Analysis: Using Claude to evaluate response quality
 * - Aggregate Calculations: Rolling up scores and feedback across multiple responses
 * - Pattern Recognition: Identifying strengths and improvement areas
 * - STAR Method Detection: Analyzing behavioral responses for completeness
 *
 * @author Claude Code Assistant
 * @date 2025-11-10
 */
public with sharing class SessionAnalyzer {

    /**
     * @description Wrapper class for analysis result
     */
    public class AnalysisResult {
        @AuraEnabled public Decimal score { get; set; }
        @AuraEnabled public String feedback { get; set; }
        @AuraEnabled public List<String> strengths { get; set; }
        @AuraEnabled public List<String> improvements { get; set; }
        @AuraEnabled public Boolean starMethodUsed { get; set; }
        @AuraEnabled public List<String> keyPointsCovered { get; set; }
        @AuraEnabled public List<String> missingElements { get; set; }

        public AnalysisResult() {
            this.strengths = new List<String>();
            this.improvements = new List<String>();
            this.keyPointsCovered = new List<String>();
            this.missingElements = new List<String>();
            this.starMethodUsed = false;
        }
    }

    /**
     * @description Analyze a single interview response using Claude AI
     *
     * @param responseId Interview_Response__c record ID
     * @return AnalysisResult The detailed analysis and score
     */
    public static AnalysisResult analyzeResponse(Id responseId) {
        // Query response with session and question context
        Interview_Response__c response = [
            SELECT Id, Question_Text__c, Question_Type__c, User_Response__c, Response_Time_Seconds__c,
                   Interview_Prep_Session__r.Session_Type__c
            FROM Interview_Response__c
            WHERE Id = :responseId
            LIMIT 1
        ];

        // Build analysis prompt
        String systemContext = buildAnalysisSystemContext();
        String userPrompt = buildAnalysisPrompt(response);

        // Call Claude API
        ClaudeAPIService.ClaudeResponse claudeResponse = ClaudeAPIService.generateText(systemContext, userPrompt);

        // Parse response
        AnalysisResult result = parseAnalysisResponse(claudeResponse);

        // Update the response record with analysis
        updateResponseWithAnalysis(response, result);

        return result;
    }

    /**
     * @description Calculate overall score for entire session
     *
     * @param sessionId Interview_Prep_Session__c record ID
     * @return Decimal Overall score percentage
     */
    public static Decimal calculateOverallScore(Id sessionId) {
        // Query all responses for session
        List<Interview_Response__c> responses = [
            SELECT Score__c
            FROM Interview_Response__c
            WHERE Interview_Prep_Session__c = :sessionId
            AND Score__c != null
        ];

        if (responses.isEmpty()) {
            return 0;
        }

        // Calculate average score
        Decimal totalScore = 0;
        for (Interview_Response__c response : responses) {
            totalScore += response.Score__c;
        }

        Decimal avgScore = totalScore / responses.size();

        // Update session record
        Interview_Prep_Session__c session = new Interview_Prep_Session__c(
            Id = sessionId,
            Overall_Score__c = avgScore
        );
        update session;

        return avgScore;
    }

    /**
     * @description Identify strengths across all responses in session
     *
     * @param sessionId Interview_Prep_Session__c record ID
     * @return List<String> List of identified strengths
     */
    public static List<String> identifyStrengths(Id sessionId) {
        List<String> strengths = new List<String>();
        Map<String, Integer> strengthCounts = new Map<String, Integer>();

        // Query all responses
        List<Interview_Response__c> responses = [
            SELECT Key_Points_Covered__c, Score__c
            FROM Interview_Response__c
            WHERE Interview_Prep_Session__c = :sessionId
            AND Score__c >= 70
            ORDER BY Score__c DESC
        ];

        // Aggregate strengths
        for (Interview_Response__c response : responses) {
            if (String.isNotBlank(response.Key_Points_Covered__c)) {
                List<String> points = response.Key_Points_Covered__c.split('\n');
                for (String point : points) {
                    String trimmed = point.trim();
                    if (String.isNotBlank(trimmed)) {
                        Integer count = strengthCounts.containsKey(trimmed) ? strengthCounts.get(trimmed) : 0;
                        strengthCounts.put(trimmed, count + 1);
                    }
                }
            }
        }

        // Get top strengths (appear in multiple responses)
        for (String strength : strengthCounts.keySet()) {
            if (strengthCounts.get(strength) >= 2 || responses.size() <= 3) {
                strengths.add(strength);
            }
        }

        return strengths;
    }

    /**
     * @description Generate improvement plan for session
     *
     * @param sessionId Interview_Prep_Session__c record ID
     * @return String Detailed improvement plan
     */
    public static String generateImprovementPlan(Id sessionId) {
        // Query session with all responses
        Interview_Prep_Session__c session = [
            SELECT Id, Overall_Score__c,
                   (SELECT Question_Type__c, Score__c, Improvement_Suggestions__c, Missing_Elements__c
                    FROM Interview_Responses__r
                    ORDER BY Score__c ASC)
            FROM Interview_Prep_Session__c
            WHERE Id = :sessionId
            LIMIT 1
        ];

        List<String> improvementAreas = new List<String>();

        // Collect all improvement suggestions
        for (Interview_Response__c response : session.Interview_Responses__r) {
            if (response.Score__c < 70 && String.isNotBlank(response.Improvement_Suggestions__c)) {
                improvementAreas.add('For ' + response.Question_Type__c + ' questions: ' + response.Improvement_Suggestions__c);
            }
            if (String.isNotBlank(response.Missing_Elements__c)) {
                improvementAreas.add('Missing: ' + response.Missing_Elements__c);
            }
        }

        // Build improvement plan
        String plan = 'IMPROVEMENT PLAN\n\n';
        plan += 'Overall Performance: ' + (session.Overall_Score__c != null ? session.Overall_Score__c.setScale(1) + '%' : 'Not calculated') + '\n\n';

        if (improvementAreas.isEmpty()) {
            plan += 'Great job! You\'re performing well across all question types. Continue practicing to maintain your skills.';
        } else {
            plan += 'Focus Areas:\n';
            for (Integer i = 0; i < Math.min(improvementAreas.size(), 5); i++) {
                plan += (i + 1) + '. ' + improvementAreas[i] + '\n';
            }
        }

        return plan;
    }

    /**
     * @description Detect if response uses STAR method
     *
     * @param responseText The user's response text
     * @return Boolean True if STAR method detected
     */
    public static Boolean detectSTARMethod(String responseText) {
        if (String.isBlank(responseText)) {
            return false;
        }

        String lowerText = responseText.toLowerCase();

        // Check for STAR keywords/patterns
        Boolean hasSituation = lowerText.contains('situation') || lowerText.contains('when i') || lowerText.contains('at my previous');
        Boolean hasTask = lowerText.contains('task') || lowerText.contains('needed to') || lowerText.contains('had to') || lowerText.contains('my role');
        Boolean hasAction = lowerText.contains('action') || lowerText.contains('i did') || lowerText.contains('i implemented') || lowerText.contains('my approach');
        Boolean hasResult = lowerText.contains('result') || lowerText.contains('outcome') || lowerText.contains('achieved') || lowerText.contains('successfully');

        // Check for narrative structure (past tense storytelling)
        Integer pastTenseCount = 0;
        List<String> pastTenseIndicators = new List<String>{'worked', 'developed', 'created', 'led', 'managed', 'implemented', 'resolved'};
        for (String indicator : pastTenseIndicators) {
            if (lowerText.contains(indicator)) {
                pastTenseCount++;
            }
        }

        // STAR method detected if has at least 3 of 4 elements OR strong narrative structure
        return (hasSituation && hasTask && hasAction) || (hasTask && hasAction && hasResult) || (pastTenseCount >= 3);
    }

    /**
     * @description Generate session summary using AI
     *
     * @param sessionId Interview_Prep_Session__c record ID
     * @return String AI-generated summary
     */
    public static String generateSessionSummary(Id sessionId) {
        // Query session with all responses
        Interview_Prep_Session__c session = [
            SELECT Id, Session_Type__c, Overall_Score__c, Questions_Asked__c,
                   Job_Posting__r.Title__c, Job_Posting__r.Company__c,
                   (SELECT Question_Text__c, Question_Type__c, Score__c
                    FROM Interview_Responses__r
                    ORDER BY Question_Number__c)
            FROM Interview_Prep_Session__c
            WHERE Id = :sessionId
            LIMIT 1
        ];

        String systemContext = 'You are an expert interview coach summarizing a practice session. ' +
                              'Provide encouraging, actionable feedback that highlights progress and areas for improvement.';

        String userPrompt = 'Summarize this interview practice session:\n\n' +
                           'Role: ' + session.Job_Posting__r.Title__c + '\n' +
                           'Company: ' + session.Job_Posting__r.Company__c + '\n' +
                           'Session Type: ' + session.Session_Type__c + '\n' +
                           'Questions Answered: ' + session.Questions_Asked__c + '\n' +
                           'Overall Score: ' + (session.Overall_Score__c != null ? session.Overall_Score__c.setScale(1) + '%' : 'Not calculated') + '\n\n';

        userPrompt += 'Question Breakdown:\n';
        for (Interview_Response__c response : session.Interview_Responses__r) {
            userPrompt += '- ' + response.Question_Type__c + ' question: ' + (response.Score__c != null ? response.Score__c.setScale(0) + '%' : 'Not scored') + '\n';
        }

        userPrompt += '\nProvide a 2-3 paragraph summary that:\n' +
                     '1. Acknowledges the candidate\'s effort and preparation\n' +
                     '2. Highlights their strongest areas\n' +
                     '3. Suggests 2-3 specific improvements\n' +
                     '4. Encourages continued practice\n\n' +
                     'Keep tone positive and motivating.';

        ClaudeAPIService.ClaudeResponse response = ClaudeAPIService.generateText(systemContext, userPrompt);
        String summary = response.content[0].text;

        // Update session record
        session.Session_Summary__c = summary;
        update session;

        return summary;
    }

    // ==================== PRIVATE HELPER METHODS ====================

    /**
     * @description Build system context for response analysis
     */
    private static String buildAnalysisSystemContext() {
        return 'You are an expert interview coach evaluating candidate responses. ' +
               'Provide fair, constructive feedback that helps candidates improve. ' +
               'Score on a 0-100 scale with specific criteria. ' +
               'Always respond with valid JSON in the exact format requested.';
    }

    /**
     * @description Build analysis prompt
     */
    private static String buildAnalysisPrompt(Interview_Response__c response) {
        String prompt = 'Evaluate this interview response:\n\n' +
                       'Question: ' + response.Question_Text__c + '\n' +
                       'Question Type: ' + response.Question_Type__c + '\n' +
                       'Candidate Response: ' + response.User_Response__c + '\n';

        if (response.Response_Time_Seconds__c != null) {
            prompt += 'Time Taken: ' + response.Response_Time_Seconds__c + ' seconds\n';
        }

        prompt += '\nEvaluate considering:\n' +
                 '- Completeness and relevance\n' +
                 '- Clarity and structure\n';

        if (response.Question_Type__c == 'Behavioral') {
            prompt += '- STAR method usage (Situation, Task, Action, Result)\n';
        } else if (response.Question_Type__c == 'Technical') {
            prompt += '- Technical accuracy and depth\n';
        }

        prompt += '- Communication effectiveness\n' +
                 '- Time appropriateness (aim for 60-120 seconds for behavioral, 30-90 for technical)\n\n' +
                 'Provide response as JSON:\n' +
                 '{\n' +
                 '  "score": 85,\n' +
                 '  "feedback": "Detailed paragraph of feedback",\n' +
                 '  "strengths": ["strength1", "strength2"],\n' +
                 '  "improvements": ["improvement1", "improvement2"],\n' +
                 '  "starMethodUsed": true,\n' +
                 '  "keyPointsCovered": ["point1", "point2"],\n' +
                 '  "missingElements": ["element1", "element2"]\n' +
                 '}\n\n' +
                 'IMPORTANT: Return ONLY the JSON object, no additional text.';

        return prompt;
    }

    /**
     * @description Parse Claude's analysis response
     */
    private static AnalysisResult parseAnalysisResponse(ClaudeAPIService.ClaudeResponse response) {
        AnalysisResult result = new AnalysisResult();

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

            result.score = Decimal.valueOf((Integer) parsed.get('score'));
            result.feedback = (String) parsed.get('feedback');
            result.starMethodUsed = (Boolean) parsed.get('starMethodUsed');

            // Parse arrays
            List<Object> strengths = (List<Object>) parsed.get('strengths');
            if (strengths != null) {
                for (Object s : strengths) {
                    result.strengths.add((String) s);
                }
            }

            List<Object> improvements = (List<Object>) parsed.get('improvements');
            if (improvements != null) {
                for (Object i : improvements) {
                    result.improvements.add((String) i);
                }
            }

            List<Object> keyPoints = (List<Object>) parsed.get('keyPointsCovered');
            if (keyPoints != null) {
                for (Object k : keyPoints) {
                    result.keyPointsCovered.add((String) k);
                }
            }

            List<Object> missing = (List<Object>) parsed.get('missingElements');
            if (missing != null) {
                for (Object m : missing) {
                    result.missingElements.add((String) m);
                }
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to parse analysis: ' + e.getMessage());
            // Fallback values
            result.score = 50;
            result.feedback = 'Unable to analyze response automatically. Please review manually.';
        }

        return result;
    }

    /**
     * @description Update response record with analysis results
     */
    private static void updateResponseWithAnalysis(Interview_Response__c response, AnalysisResult analysis) {
        response.Score__c = analysis.score;
        response.AI_Feedback__c = analysis.feedback;
        response.STAR_Method_Used__c = analysis.starMethodUsed;

        // Convert lists to text
        if (!analysis.strengths.isEmpty()) {
            response.Key_Points_Covered__c = String.join(analysis.keyPointsCovered, '\n');
        }

        if (!analysis.improvements.isEmpty()) {
            response.Improvement_Suggestions__c = String.join(analysis.improvements, '\n');
        }

        if (!analysis.missingElements.isEmpty()) {
            response.Missing_Elements__c = String.join(analysis.missingElements, '\n');
        }

        update response;
    }
}

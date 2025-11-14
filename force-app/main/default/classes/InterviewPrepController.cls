/**
 * @description Main controller for Interview Prep Agent Lightning Web Component
 * Orchestrates question generation, response analysis, and session management
 *
 * LEARNING NOTES:
 * - @AuraEnabled Methods: Exposing Apex to Lightning Web Components
 * - Orchestration Pattern: Coordinating multiple service classes
 * - Error Handling: Providing meaningful feedback to UI
 * - Session State Management: Tracking interview session progress
 *
 * @author Claude Code Assistant
 * @date 2025-11-10
 */
public with sharing class InterviewPrepController {

    /**
     * @description Start a new interview practice session
     * Supports both Job_Posting__c and Opportunity records
     *
     * @param recordId Job_Posting__c or Opportunity record ID
     * @param sessionType Type of interview (Behavioral, Technical, etc.)
     * @return Id Interview_Prep_Session__c record ID
     */
    @AuraEnabled
    public static Id startSession(Id recordId, String sessionType) {
        try {
            // Determine object type and set appropriate lookup field
            String objectType = recordId.getSObjectType().getDescribe().getName();

            Interview_Prep_Session__c session = new Interview_Prep_Session__c(
                Session_Type__c = sessionType,
                Session_Date__c = DateTime.now(),
                Session_Status__c = 'In Progress',
                Questions_Asked__c = 0,
                Questions_Answered__c = 0
            );

            // Set the appropriate lookup field based on object type
            if (objectType == 'Job_Posting__c') {
                session.Job_Posting__c = recordId;
            } else if (objectType == 'Opportunity') {
                session.Opportunity__c = recordId;
            } else {
                throw new AuraHandledException('Invalid record type. Must be Job_Posting__c or Opportunity.');
            }

            insert session;

            return session.Id;

        } catch (Exception e) {
            throw new AuraHandledException('Failed to start session: ' + e.getMessage());
        }
    }

    /**
     * @description Get the next question for the session
     *
     * @param sessionId Interview_Prep_Session__c record ID
     * @return QuestionGenerator.GeneratedQuestion The next question with metadata
     */
    @AuraEnabled
    public static QuestionGenerator.GeneratedQuestion getNextQuestion(Id sessionId) {
        try {
            // Generate question
            QuestionGenerator.GeneratedQuestion question = QuestionGenerator.generateQuestion(sessionId);

            // Get current question count
            Interview_Prep_Session__c session = [
                SELECT Questions_Asked__c
                FROM Interview_Prep_Session__c
                WHERE Id = :sessionId
                LIMIT 1
            ];

            Decimal questionNumber = session.Questions_Asked__c != null ? session.Questions_Asked__c + 1 : 1;

            // Create Interview_Response__c record for this question
            Interview_Response__c response = new Interview_Response__c(
                Interview_Prep_Session__c = sessionId,
                Question_Number__c = questionNumber,
                Question_Text__c = question.question,
                Question_Type__c = question.questionType
            );

            insert response;

            // Update session
            session.Questions_Asked__c = questionNumber;
            update session;

            // Add response ID to question object for later submission
            question.questionType = response.Id; // Temporarily store response ID in questionType field

            return question;

        } catch (Exception e) {
            throw new AuraHandledException('Failed to generate question: ' + e.getMessage());
        }
    }

    /**
     * @description Submit user's response to a question
     *
     * @param responseId Interview_Response__c record ID
     * @param userResponse The user's answer text
     * @param timeSeconds Time taken to respond in seconds
     * @return SessionAnalyzer.AnalysisResult AI analysis and score
     */
    @AuraEnabled
    public static SessionAnalyzer.AnalysisResult submitResponse(Id responseId, String userResponse, Integer timeSeconds) {
        try {
            // Update response with user's answer
            Interview_Response__c response = [
                SELECT Id, Interview_Prep_Session__c
                FROM Interview_Response__c
                WHERE Id = :responseId
                LIMIT 1
            ];

            response.User_Response__c = userResponse;
            response.Response_Time_Seconds__c = timeSeconds;
            update response;

            // Analyze response
            SessionAnalyzer.AnalysisResult analysis = SessionAnalyzer.analyzeResponse(responseId);

            // Update session answered count
            Interview_Prep_Session__c session = [
                SELECT Questions_Answered__c
                FROM Interview_Prep_Session__c
                WHERE Id = :response.Interview_Prep_Session__c
                LIMIT 1
            ];

            session.Questions_Answered__c = session.Questions_Answered__c != null ? session.Questions_Answered__c + 1 : 1;
            update session;

            return analysis;

        } catch (Exception e) {
            throw new AuraHandledException('Failed to submit response: ' + e.getMessage());
        }
    }

    /**
     * @description End the interview session and calculate final scores
     *
     * @param sessionId Interview_Prep_Session__c record ID
     * @return Map<String, Object> Session summary data
     */
    @AuraEnabled
    public static Map<String, Object> endSession(Id sessionId) {
        try {
            // Calculate overall score
            Decimal overallScore = SessionAnalyzer.calculateOverallScore(sessionId);

            // Identify strengths
            List<String> strengths = SessionAnalyzer.identifyStrengths(sessionId);

            // Generate improvement plan
            String improvementPlan = SessionAnalyzer.generateImprovementPlan(sessionId);

            // Generate session summary
            String summary = SessionAnalyzer.generateSessionSummary(sessionId);

            // Update session status and fields
            Interview_Prep_Session__c session = new Interview_Prep_Session__c(
                Id = sessionId,
                Session_Status__c = 'Completed',
                Overall_Score__c = overallScore,
                Strengths__c = String.join(strengths, '\n'),
                Areas_for_Improvement__c = improvementPlan,
                Session_Summary__c = summary
            );

            // Calculate duration
            Interview_Prep_Session__c existingSession = [
                SELECT Session_Date__c
                FROM Interview_Prep_Session__c
                WHERE Id = :sessionId
                LIMIT 1
            ];

            if (existingSession.Session_Date__c != null) {
                Long duration = existingSession.Session_Date__c.getTime() - DateTime.now().getTime();
                session.Duration_Minutes__c = Math.abs(duration / 60000);
            }

            update session;

            // Return summary data
            Map<String, Object> result = new Map<String, Object>();
            result.put('overallScore', overallScore);
            result.put('strengths', strengths);
            result.put('improvementPlan', improvementPlan);
            result.put('summary', summary);

            return result;

        } catch (Exception e) {
            throw new AuraHandledException('Failed to end session: ' + e.getMessage());
        }
    }

    /**
     * @description Get detailed summary of a completed session
     *
     * @param sessionId Interview_Prep_Session__c record ID
     * @return Map<String, Object> Complete session data
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getSessionSummary(Id sessionId) {
        try {
            Interview_Prep_Session__c session = [
                SELECT Id, Session_Type__c, Session_Date__c, Duration_Minutes__c,
                       Questions_Asked__c, Questions_Answered__c, Overall_Score__c,
                       Strengths__c, Areas_for_Improvement__c, Session_Summary__c,
                       Session_Status__c, Confidence_Level__c,
                       Job_Posting__r.Title__c, Job_Posting__r.Company__c,
                       (SELECT Question_Text__c, Question_Type__c, User_Response__c,
                               Response_Time_Seconds__c, Score__c, AI_Feedback__c,
                               STAR_Method_Used__c, Key_Points_Covered__c,
                               Improvement_Suggestions__c, Missing_Elements__c
                        FROM Interview_Responses__r
                        ORDER BY Question_Number__c)
                FROM Interview_Prep_Session__c
                WHERE Id = :sessionId
                LIMIT 1
            ];

            Map<String, Object> result = new Map<String, Object>();
            result.put('session', session);
            result.put('responses', session.Interview_Responses__r);

            return result;

        } catch (Exception e) {
            throw new AuraHandledException('Failed to get session summary: ' + e.getMessage());
        }
    }

    /**
     * @description Get all practice sessions for a job posting or opportunity
     * Supports both Job_Posting__c and Opportunity records
     *
     * @param recordId Job_Posting__c or Opportunity record ID
     * @return List<Interview_Prep_Session__c> List of sessions
     */
    @AuraEnabled(cacheable=true)
    public static List<Interview_Prep_Session__c> getAllSessions(Id recordId) {
        try {
            String objectType = recordId.getSObjectType().getDescribe().getName();

            String query = 'SELECT Id, Session_Type__c, Session_Date__c, Session_Status__c, ' +
                          'Questions_Asked__c, Overall_Score__c ' +
                          'FROM Interview_Prep_Session__c ' +
                          'WHERE ';

            if (objectType == 'Job_Posting__c') {
                query += 'Job_Posting__c = :recordId ';
            } else if (objectType == 'Opportunity') {
                query += 'Opportunity__c = :recordId ';
            } else {
                throw new AuraHandledException('Invalid record type');
            }

            query += 'ORDER BY Session_Date__c DESC LIMIT 50';

            return Database.query(query);

        } catch (Exception e) {
            throw new AuraHandledException('Failed to get sessions: ' + e.getMessage());
        }
    }

    /**
     * @description Get or generate company research for job posting or opportunity
     * Supports both Job_Posting__c and Opportunity records
     *
     * @param recordId Job_Posting__c or Opportunity record ID
     * @return Company_Research__c Company research record
     */
    @AuraEnabled
    public static Company_Research__c getCompanyResearch(Id recordId) {
        try {
            // Generate or retrieve research (CompanyResearcher handles both object types)
            Id researchId = CompanyResearcher.generateResearch(recordId);

            // Query and return research
            Company_Research__c research = [
                SELECT Id, Company_Name__c, Research_Date__c, Research_Status__c,
                       Company_Overview__c, Recent_News__c, Culture_Insights__c,
                       Key_Products_Services__c, Interview_Talking_Points__c,
                       Why_This_Company__c, Potential_Challenges__c
                FROM Company_Research__c
                WHERE Id = :researchId
                LIMIT 1
            ];

            return research;

        } catch (Exception e) {
            throw new AuraHandledException('Failed to get company research: ' + e.getMessage());
        }
    }

    /**
     * @description Refresh company research with latest information
     *
     * @param companyResearchId Company_Research__c record ID
     * @return Company_Research__c Updated research record
     */
    @AuraEnabled
    public static Company_Research__c refreshCompanyResearch(Id companyResearchId) {
        try {
            Id refreshedId = CompanyResearcher.refreshResearch(companyResearchId);

            Company_Research__c research = [
                SELECT Id, Company_Name__c, Research_Date__c, Research_Status__c,
                       Company_Overview__c, Recent_News__c, Culture_Insights__c,
                       Key_Products_Services__c, Interview_Talking_Points__c,
                       Why_This_Company__c, Potential_Challenges__c
                FROM Company_Research__c
                WHERE Id = :refreshedId
                LIMIT 1
            ];

            return research;

        } catch (Exception e) {
            throw new AuraHandledException('Failed to refresh research: ' + e.getMessage());
        }
    }

    /**
     * @description Update user's confidence level for a session
     *
     * @param sessionId Interview_Prep_Session__c record ID
     * @param confidenceLevel Low, Medium, or High
     */
    @AuraEnabled
    public static void updateConfidenceLevel(Id sessionId, String confidenceLevel) {
        try {
            Interview_Prep_Session__c session = new Interview_Prep_Session__c(
                Id = sessionId,
                Confidence_Level__c = confidenceLevel
            );

            update session;

        } catch (Exception e) {
            throw new AuraHandledException('Failed to update confidence level: ' + e.getMessage());
        }
    }

    /**
     * @description Get job context (works with both Job_Posting__c and Opportunity)
     *
     * @param recordId Job_Posting__c or Opportunity record ID
     * @return JobContext Unified job context
     */
    @AuraEnabled(cacheable=true)
    public static JobContext getJobContext(Id recordId) {
        try {
            return JobContext.fromRecord(recordId);

        } catch (Exception e) {
            throw new AuraHandledException('Failed to get job context: ' + e.getMessage());
        }
    }

    /**
     * @description DEPRECATED: Use getJobContext instead
     * Get job posting details for display
     *
     * @param jobPostingId Job_Posting__c record ID
     * @return Job_Posting__c Job posting record
     */
    @AuraEnabled(cacheable=true)
    public static Job_Posting__c getJobPosting(Id jobPostingId) {
        try {
            return [
                SELECT Id, Title__c, Company__c, Description__c,
                       Tags__c, Industry__c
                FROM Job_Posting__c
                WHERE Id = :jobPostingId
                LIMIT 1
            ];

        } catch (Exception e) {
            throw new AuraHandledException('Failed to get job posting: ' + e.getMessage());
        }
    }

    /**
     * @description Skip current question and get a new one
     *
     * @param sessionId Interview_Prep_Session__c record ID
     * @param currentQuestionId Interview_Response__c record ID to skip
     * @return QuestionGenerator.GeneratedQuestion New question
     */
    @AuraEnabled
    public static QuestionGenerator.GeneratedQuestion skipQuestion(Id sessionId, Id currentQuestionId) {
        try {
            // Mark current question as skipped (delete it)
            delete [SELECT Id FROM Interview_Response__c WHERE Id = :currentQuestionId];

            // Get new question
            return getNextQuestion(sessionId);

        } catch (Exception e) {
            throw new AuraHandledException('Failed to skip question: ' + e.getMessage());
        }
    }
}

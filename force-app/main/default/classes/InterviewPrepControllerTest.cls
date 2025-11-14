/**
 * @description Test class for Interview Prep Agent components
 * Tests InterviewPrepController, QuestionGenerator, SessionAnalyzer, and CompanyResearcher
 *
 * @author Claude Code Assistant
 * @date 2025-11-10
 */
@isTest
private class InterviewPrepControllerTest {

    /**
     * @description Mock HTTP callout for Claude API (Question Generation)
     */
    private class ClaudeAPIMockQuestionGeneration implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String responseBody = '{' +
                '"id": "msg_question_123",' +
                '"type": "message",' +
                '"role": "assistant",' +
                '"content": [' +
                    '{' +
                        '"type": "text",' +
                        '"text": "{\\\"question\\\": \\\"Tell me about a time when you had to resolve a conflict within your team.\\\", \\\"questionType\\\": \\\"Behavioral\\\", \\\"evaluationCriteria\\\": [\\\"Conflict resolution\\\", \\\"Communication\\\", \\\"Team dynamics\\\"], \\\"idealResponseElements\\\": [\\\"Situation\\\", \\\"Task\\\", \\\"Action\\\", \\\"Result\\\"]}"' +
                    '}' +
                '],' +
                '"model": "claude-3-haiku-20240307",' +
                '"stop_reason": "end_turn",' +
                '"usage": {"input_tokens": 150, "output_tokens": 100}' +
            '}';

            res.setBody(responseBody);
            return res;
        }
    }

    /**
     * @description Mock HTTP callout for Claude API (Response Analysis)
     */
    private class ClaudeAPIMockResponseAnalysis implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String responseBody = '{' +
                '"id": "msg_analysis_123",' +
                '"type": "message",' +
                '"role": "assistant",' +
                '"content": [' +
                    '{' +
                        '"type": "text",' +
                        '"text": "{\\\"score\\\": 85, \\\"feedback\\\": \\\"Strong response with clear STAR method. Good detail on actions taken.\\\", \\\"strengths\\\": [\\\"Used STAR method\\\", \\\"Specific examples\\\"], \\\"improvements\\\": [\\\"Could add more quantifiable results\\\"], \\\"starMethodUsed\\\": true, \\\"keyPointsCovered\\\": [\\\"Situation described\\\", \\\"Actions taken\\\", \\\"Positive outcome\\\"], \\\"missingElements\\\": [\\\"Specific metrics\\\"]}"' +
                    '}' +
                '],' +
                '"model": "claude-3-haiku-20240307",' +
                '"stop_reason": "end_turn",' +
                '"usage": {"input_tokens": 200, "output_tokens": 150}' +
            '}';

            res.setBody(responseBody);
            return res;
        }
    }

    /**
     * @description Mock HTTP callout for Claude API (Company Research)
     */
    private class ClaudeAPIMockCompanyResearch implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String responseBody = '{' +
                '"id": "msg_research_123",' +
                '"type": "message",' +
                '"role": "assistant",' +
                '"content": [' +
                    '{' +
                        '"type": "text",' +
                        '"text": "{\\\"companyOverview\\\": \\\"Leading technology company specializing in cloud solutions.\\\", \\\"recentNews\\\": \\\"Recently launched new AI platform.\\\", \\\"cultureInsights\\\": \\\"Known for innovation and collaborative environment.\\\", \\\"keyProducts\\\": \\\"Cloud infrastructure, AI tools, enterprise software.\\\", \\\"talkingPoints\\\": [\\\"What is the team structure?\\\", \\\"How do you measure success?\\\"], \\\"whyThisCompany\\\": \\\"Opportunity to work on cutting-edge technology.\\\", \\\"potentialChallenges\\\": [\\\"Fast-paced environment\\\", \\\"High expectations\\\"]}"' +
                    '}' +
                '],' +
                '"model": "claude-3-haiku-20240307",' +
                '"stop_reason": "end_turn",' +
                '"usage": {"input_tokens": 250, "output_tokens": 200}' +
            '}';

            res.setBody(responseBody);
            return res;
        }
    }

    /**
     * @description Test data setup
     */
    @testSetup
    static void setupTestData() {
        // Create Job Posting
        Job_Posting__c job = new Job_Posting__c(
            Title__c = 'Senior Salesforce Developer',
            Company__c = 'TechCorp Inc',
            Description__c = 'Looking for experienced Salesforce developer to join our team.',
            Tags__c = 'Apex, Lightning Web Components, Integration',
            Industry__c = 'Technology',
            Location__c = 'San Francisco, CA',
            Apply_URL__c = 'https://example.com/apply',
            Provider__c = 'LinkedIn',
            ExternalID__c = 'TEST-JOB-001',
            Status__c = 'Active'
        );
        insert job;
    }

    /**
     * @description Test starting a new session
     */
    @isTest
    static void testStartSession() {
        Job_Posting__c job = [SELECT Id FROM Job_Posting__c LIMIT 1];

        Test.startTest();
        Id sessionId = InterviewPrepController.startSession(job.Id, 'Behavioral');
        Test.stopTest();

        Interview_Prep_Session__c session = [
            SELECT Id, Session_Type__c, Session_Status__c, Questions_Asked__c
            FROM Interview_Prep_Session__c
            WHERE Id = :sessionId
        ];

        System.assertEquals('Behavioral', session.Session_Type__c);
        System.assertEquals('In Progress', session.Session_Status__c);
        System.assertEquals(0, session.Questions_Asked__c);
    }

    /**
     * @description Test getting next question
     */
    @isTest
    static void testGetNextQuestion() {
        Job_Posting__c job = [SELECT Id FROM Job_Posting__c LIMIT 1];

        Id sessionId = InterviewPrepController.startSession(job.Id, 'Behavioral');

        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockQuestionGeneration());

        Test.startTest();
        QuestionGenerator.GeneratedQuestion question = InterviewPrepController.getNextQuestion(sessionId);
        Test.stopTest();

        System.assertNotEquals(null, question);
        System.assert(String.isNotBlank(question.question));
    }

    /**
     * @description Test submitting a response
     */
    @isTest
    static void testSubmitResponse() {
        Job_Posting__c job = [SELECT Id FROM Job_Posting__c LIMIT 1];

        Id sessionId = InterviewPrepController.startSession(job.Id, 'Behavioral');

        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockQuestionGeneration());
        QuestionGenerator.GeneratedQuestion question = InterviewPrepController.getNextQuestion(sessionId);

        // Get the response ID (temporarily stored in questionType field)
        Id responseId = Id.valueOf(question.questionType);

        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockResponseAnalysis());

        Test.startTest();
        SessionAnalyzer.AnalysisResult analysis = InterviewPrepController.submitResponse(
            responseId,
            'In my previous role, I had a conflict with a team member about project priorities. I scheduled a one-on-one meeting to understand their perspective. We found a compromise that satisfied both parties and improved our working relationship.',
            90
        );
        Test.stopTest();

        System.assertNotEquals(null, analysis);
        System.assert(analysis.score > 0);
    }

    /**
     * @description Test ending a session
     */
    @isTest
    static void testEndSession() {
        Job_Posting__c job = [SELECT Id FROM Job_Posting__c LIMIT 1];

        Id sessionId = InterviewPrepController.startSession(job.Id, 'Behavioral');

        // Create a mock response to analyze
        Interview_Response__c response = new Interview_Response__c(
            Interview_Prep_Session__c = sessionId,
            Question_Number__c = 1,
            Question_Text__c = 'Tell me about yourself',
            Question_Type__c = 'Behavioral',
            User_Response__c = 'I am a Salesforce professional with 5 years of experience.',
            Score__c = 80
        );
        insert response;

        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockResponseAnalysis());

        Test.startTest();
        Map<String, Object> summary = InterviewPrepController.endSession(sessionId);
        Test.stopTest();

        System.assertNotEquals(null, summary);
        System.assert(summary.containsKey('overallScore'));

        Interview_Prep_Session__c session = [
            SELECT Session_Status__c
            FROM Interview_Prep_Session__c
            WHERE Id = :sessionId
        ];
        System.assertEquals('Completed', session.Session_Status__c);
    }

    /**
     * @description Test getting company research
     */
    @isTest
    static void testGetCompanyResearch() {
        Job_Posting__c job = [SELECT Id FROM Job_Posting__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockCompanyResearch());

        Test.startTest();
        Company_Research__c research = InterviewPrepController.getCompanyResearch(job.Id);
        Test.stopTest();

        System.assertNotEquals(null, research);
        System.assertEquals('TechCorp Inc', research.Company_Name__c);
        System.assertEquals('Ready', research.Research_Status__c);
    }

    /**
     * @description Test getting all sessions
     */
    @isTest
    static void testGetAllSessions() {
        Job_Posting__c job = [SELECT Id FROM Job_Posting__c LIMIT 1];

        Id session1 = InterviewPrepController.startSession(job.Id, 'Behavioral');
        Id session2 = InterviewPrepController.startSession(job.Id, 'Technical');

        Test.startTest();
        List<Interview_Prep_Session__c> sessions = InterviewPrepController.getAllSessions(job.Id);
        Test.stopTest();

        System.assertEquals(2, sessions.size());
    }

    /**
     * @description Test STAR method detection
     */
    @isTest
    static void testSTARMethodDetection() {
        String starResponse = 'In my previous role at TechCorp, we faced a situation where our project was behind schedule. ' +
                             'My task was to identify bottlenecks and get us back on track. ' +
                             'I implemented daily standups and created a visual progress board. ' +
                             'As a result, we delivered the project on time and improved team communication.';

        Test.startTest();
        Boolean hasSTAR = SessionAnalyzer.detectSTARMethod(starResponse);
        Test.stopTest();

        System.assertEquals(true, hasSTAR);
    }

    /**
     * @description Test behavioral questions library
     */
    @isTest
    static void testGetBehavioralQuestions() {
        Test.startTest();
        List<QuestionGenerator.GeneratedQuestion> questions = QuestionGenerator.getBehavioralQuestions();
        Test.stopTest();

        System.assert(questions.size() > 0);
        System.assertEquals('Behavioral', questions[0].questionType);
    }

    /**
     * @description Test updating confidence level
     */
    @isTest
    static void testUpdateConfidenceLevel() {
        Job_Posting__c job = [SELECT Id FROM Job_Posting__c LIMIT 1];
        Id sessionId = InterviewPrepController.startSession(job.Id, 'Behavioral');

        Test.startTest();
        InterviewPrepController.updateConfidenceLevel(sessionId, 'High');
        Test.stopTest();

        Interview_Prep_Session__c session = [
            SELECT Confidence_Level__c
            FROM Interview_Prep_Session__c
            WHERE Id = :sessionId
        ];

        System.assertEquals('High', session.Confidence_Level__c);
    }
}

/**
 * @description Test class for JobPostingAnalyzer
 * Tests job analysis logic and Claude AI integration
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-10-29
 */
@isTest
private class JobPostingAnalyzerTest {

    /**
     * @description Mock HTTP callout for successful analysis
     */
    private class AnalysisMockSuccess implements HttpCalloutMock {
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
                        '"text": "{\\\"fit_score\\\": 9.0, \\\"nd_friendliness_score\\\": 8.5, \\\"green_flags\\\": [\\\"Remote work\\\", \\\"Flexible schedule\\\", \\\"ND accommodations mentioned\\\"], \\\"red_flags\\\": [\\\"Salary below minimum\\\"], \\\"recommendation\\\": \\\"HIGH PRIORITY\\\", \\\"reasoning\\\": \\\"Excellent fit with strong ND support and remote flexibility\\\"}"' +
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
     * @description Test successful job analysis
     */
    @isTest
    static void testAnalyzeJob_Success() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new AnalysisMockSuccess());

        // Create test job posting
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Senior Salesforce Developer',
            Company__c = 'ND-Friendly Tech Co',
            Location__c = 'Remote - US',
            Description__c = 'We are seeking a Salesforce developer for our remote team. Flexible hours, neurodivergent accommodations available, supportive culture.',
            Workplace_Type__c = 'Remote',
            Remote_Policy__c = 'Fully Remote',
            Salary_Min__c = 90000,
            Salary_Max__c = 130000,
            Status__c = 'Pending Analysis'
        );
        insert testJob;

        // Retrieve to get all fields
        testJob = [SELECT Id, Title__c, Company__c, Location__c, Description__c,
                          Workplace_Type__c, Remote_Policy__c, Salary_Min__c, Salary_Max__c
                   FROM Job_Posting__c WHERE Id = :testJob.Id];

        Test.startTest();

        JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(testJob);

        Test.stopTest();

        // Verify result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(9.0, result.fitScore, 'Fit score should match mock response');
        System.assertEquals(8.5, result.ndFriendlinessScore, 'ND Friendliness score should match mock response');
        System.assert(result.greenFlags.contains('Remote work'), 'Should identify remote work as green flag');
        System.assertEquals('HIGH PRIORITY', result.recommendation, 'Recommendation should match mock');
        System.assert(!String.isBlank(result.fullResponse), 'Full response should be stored');
    }

    /**
     * @description Test analysis with API error
     */
    @isTest
    static void testAnalyzeJob_APIError() {
        // Set mock callout for error
        Test.setMock(HttpCalloutMock.class, new AnalysisMockError());

        // Create test job posting
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Test Job',
            Company__c = 'Test Company',
            Location__c = 'Test Location',
            Status__c = 'Pending Analysis'
        );
        insert testJob;

        // Retrieve to get all fields
        testJob = [SELECT Id, Title__c, Company__c, Location__c
                   FROM Job_Posting__c WHERE Id = :testJob.Id];

        Test.startTest();

        Boolean exceptionCaught = false;
        try {
            JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(testJob);
        } catch (Exception e) {
            exceptionCaught = true;
        }

        Test.stopTest();

        System.assert(exceptionCaught, 'Should throw exception on API error');
    }

    /**
     * @description Mock for API error response
     */
    private class AnalysisMockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500);
            res.setBody('{"error": "Internal server error"}');
            return res;
        }
    }

    /**
     * @description Test analysis of job with no description
     */
    @isTest
    static void testAnalyzeJob_NoDescription() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new AnalysisMockSuccess());

        // Create job with minimal information
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Minimal Job',
            Company__c = 'Test Co',
            Location__c = 'Remote',
            Status__c = 'Pending Analysis'
        );
        insert testJob;

        // Retrieve to get all fields
        testJob = [SELECT Id, Title__c, Company__c, Location__c
                   FROM Job_Posting__c WHERE Id = :testJob.Id];

        Test.startTest();

        JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(testJob);

        Test.stopTest();

        // Should still complete analysis
        System.assertNotEquals(null, result, 'Should complete analysis even without description');
        System.assert(result.fitScore >= 0, 'Should return valid fit score');
    }

    /**
     * @description Test JobAnalysisResult wrapper class
     */
    @isTest
    static void testJobAnalysisResultWrapper() {
        Test.startTest();

        JobPostingAnalyzer.JobAnalysisResult result = new JobPostingAnalyzer.JobAnalysisResult();

        Test.stopTest();

        // Verify default values
        System.assertEquals(0, result.fitScore, 'Default fit score should be 0');
        System.assertEquals(0, result.ndFriendlinessScore, 'Default ND score should be 0');
        System.assertEquals('', result.greenFlags, 'Default green flags should be empty');
        System.assertEquals('', result.redFlags, 'Default red flags should be empty');
        System.assertEquals('', result.recommendation, 'Default recommendation should be empty');
    }
}

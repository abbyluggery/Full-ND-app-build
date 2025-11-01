/**
 * @description Test class for ClaudeAPIService
 * Tests API communication with Anthropic Claude using HTTP Mock callouts
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-10-29
 */
@isTest
private class ClaudeAPIServiceTest {

    /**
     * @description Mock HTTP callout for successful Claude API response
     */
    private class ClaudeAPIMockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Verify request is properly formatted
            System.assertEquals('POST', req.getMethod());
            System.assertEquals('https://api.anthropic.com/v1/messages', req.getEndpoint());
            System.assert(req.getHeader('x-api-key') != null);
            System.assertEquals('application/json', req.getHeader('Content-Type'));

            // Create mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String responseBody = '{' +
                '"id": "msg_01ABC123",' +
                '"type": "message",' +
                '"role": "assistant",' +
                '"content": [' +
                    '{' +
                        '"type": "text",' +
                        '"text": "{\\\"fit_score\\\": 9.0, \\\"nd_friendliness_score\\\": 8.5, \\\"green_flags\\\": [\\\"Remote work\\\", \\\"Flexible hours\\\"], \\\"red_flags\\\": [], \\\"recommendation\\\": \\\"HIGH PRIORITY\\\", \\\"reasoning\\\": \\\"Great fit for ND professionals\\\"}"' +
                    '}' +
                '],' +
                '"model": "claude-3-haiku-20240307",' +
                '"stop_reason": "end_turn",' +
                '"usage": {' +
                    '"input_tokens": 100,' +
                    '"output_tokens": 150' +
                '}' +
            '}';

            res.setBody(responseBody);
            return res;
        }
    }

    /**
     * @description Mock HTTP callout for error response
     */
    private class ClaudeAPIMockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(400);
            res.setBody('{"error": "Invalid request"}');
            return res;
        }
    }

    /**
     * @description Test job posting analysis with successful API response
     */
    @isTest
    static void testAnalyzeJobPosting_Success() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockSuccess());

        // Create test job posting
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Salesforce Developer',
            Company__c = 'Test Company',
            Location__c = 'Remote',
            Description__c = 'Great opportunity for ND professionals. Flexible hours, remote work.',
            Workplace_Type__c = 'Remote',
            Remote_Policy__c = 'Fully Remote',
            Salary_Min__c = 85000,
            Salary_Max__c = 120000
        );
        insert testJob;

        // Retrieve to get all fields
        testJob = [SELECT Id, Title__c, Company__c, Location__c, Description__c,
                         Workplace_Type__c, Remote_Policy__c, Salary_Min__c, Salary_Max__c
                   FROM Job_Posting__c WHERE Id = :testJob.Id];

        Test.startTest();

        String systemContext = 'You are an expert job analyzer focusing on neurodivergent-friendly workplaces.';
        ClaudeAPIService.ClaudeResponse response = ClaudeAPIService.analyzeJobPosting(testJob, systemContext);

        Test.stopTest();

        // Verify response
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertEquals('message', response.type);
        System.assertEquals('assistant', response.role);
        System.assertNotEquals(null, response.content);
        System.assert(!response.content.isEmpty(), 'Content should not be empty');

        // Verify text extraction
        String extractedText = ClaudeAPIService.extractTextContent(response);
        System.assert(extractedText.contains('fit_score'), 'Response should contain fit_score');
    }

    /**
     * @description Test generate text method with successful API response
     */
    @isTest
    static void testGenerateText_Success() {
        // Set mock callout with resume content
        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockTextGeneration());

        Test.startTest();

        String systemContext = 'You are an expert resume writer.';
        String userPrompt = 'Generate a professional summary for a Salesforce developer.';
        ClaudeAPIService.ClaudeResponse response = ClaudeAPIService.generateText(systemContext, userPrompt);

        Test.stopTest();

        // Verify response
        System.assertNotEquals(null, response);
        System.assertEquals('message', response.type);

        String extractedText = ClaudeAPIService.extractTextContent(response);
        System.assert(extractedText.length() > 0, 'Generated text should not be empty');
    }

    /**
     * @description Mock for text generation responses
     */
    private class ClaudeAPIMockTextGeneration implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String responseBody = '{' +
                '"id": "msg_01XYZ789",' +
                '"type": "message",' +
                '"role": "assistant",' +
                '"content": [' +
                    '{' +
                        '"type": "text",' +
                        '"text": "Experienced Salesforce Developer with 5+ years of expertise in Lightning Web Components, Apex, and integrations. Proven track record of delivering scalable solutions."' +
                    '}' +
                '],' +
                '"model": "claude-3-haiku-20240307",' +
                '"stop_reason": "end_turn",' +
                '"usage": {"input_tokens": 50, "output_tokens": 100}' +
            '}';

            res.setBody(responseBody);
            return res;
        }
    }

    /**
     * @description Test API error handling
     */
    @isTest
    static void testAPIError() {
        // Set mock callout for error
        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockError());

        // Create test job posting
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Test Job',
            Company__c = 'Test Company',
            Location__c = 'Test Location'
        );
        insert testJob;

        Test.startTest();

        Boolean exceptionCaught = false;
        try {
            ClaudeAPIService.analyzeJobPosting(testJob, 'Test context');
        } catch (ClaudeAPIService.ClaudeAPIException e) {
            exceptionCaught = true;
            System.assert(e.getMessage().contains('400'), 'Error message should include status code');
        }

        Test.stopTest();

        System.assert(exceptionCaught, 'Should catch ClaudeAPIException on error response');
    }

    /**
     * @description Test text content extraction from empty response
     */
    @isTest
    static void testExtractTextContent_EmptyResponse() {
        ClaudeAPIService.ClaudeResponse response = new ClaudeAPIService.ClaudeResponse();
        response.content = new List<ClaudeAPIService.Content>();

        String extractedText = ClaudeAPIService.extractTextContent(response);

        System.assertEquals('', extractedText, 'Empty response should return empty string');
    }

    /**
     * @description Test text content extraction with null response
     */
    @isTest
    static void testExtractTextContent_NullContent() {
        ClaudeAPIService.ClaudeResponse response = new ClaudeAPIService.ClaudeResponse();
        response.content = null;

        String extractedText = ClaudeAPIService.extractTextContent(response);

        System.assertEquals('', extractedText, 'Null content should return empty string');
    }
}

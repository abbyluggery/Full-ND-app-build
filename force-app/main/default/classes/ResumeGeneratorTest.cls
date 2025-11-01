/**
 * @description Test class for ResumeGenerator
 * Tests resume and cover letter generation using Claude AI
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-10-29
 */
@isTest
private class ResumeGeneratorTest {

    /**
     * @description Mock HTTP callout for successful resume generation
     */
    private class ResumeGenerationMockSuccess implements HttpCalloutMock {
        private Integer callCount = 0;

        public HTTPResponse respond(HTTPRequest req) {
            callCount++;

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String responseText;
            if (callCount == 1) {
                // First call: Resume generation
                responseText = 'JOHN DOE\\nEmail: john@example.com\\n\\nPROFESSIONAL SUMMARY\\nExperienced Salesforce Developer with 5+ years...\\n\\nPROFESSIONAL EXPERIENCE\\nSalesforce Developer | ABC Company | 2020-Present\\n- Developed Lightning Web Components\\n- Integrated Salesforce with external systems';
            } else {
                // Second call: Cover letter generation
                responseText = 'Dear Hiring Manager,\\n\\nI am excited to apply for the position...\\n\\nSincerely,\\nJohn Doe';
            }

            String responseBody = '{' +
                '"id": "msg_resume_' + callCount + '",' +
                '"type": "message",' +
                '"role": "assistant",' +
                '"content": [' +
                    '{' +
                        '"type": "text",' +
                        '"text": "' + responseText + '"' +
                    '}' +
                '],' +
                '"model": "claude-3-haiku-20240307",' +
                '"stop_reason": "end_turn",' +
                '"usage": {"input_tokens": 500, "output_tokens": 300}' +
            '}';

            res.setBody(responseBody);
            return res;
        }
    }

    /**
     * @description Test successful resume package generation
     */
    @isTest
    static void testGenerateResumePackage_Success() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new ResumeGenerationMockSuccess());

        // Create test job posting
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Salesforce Developer',
            Company__c = 'Tech Company',
            Location__c = 'Remote',
            Description__c = 'Seeking Salesforce developer with Lightning experience',
            ND_Friendliness_Score__c = 9,
            Green_Flags__c = 'Remote work, Flexible hours',
            Red_Flags__c = ''
        );
        insert testJob;

        // Create master resume config
        Master_Resume_Config__c masterResume = new Master_Resume_Config__c(
            Resume_Content__c = 'JOHN DOE\nSalesforce Developer\n\nEXPERIENCE\nABC Company - Salesforce Developer - 2020-Present',
            Key_Achievements__c = '- Achieved 200% increase in user adoption\n- Delivered 15+ projects',
            Technical_Skills__c = 'Apex, LWC, SOQL, Integration',
            Cover_Letter_Template__c = 'Professional but warm tone, focus on impact'
        );
        insert masterResume;

        Test.startTest();

        Resume_Package__c resumePackage = ResumeGenerator.generateResumePackage(testJob.Id);

        Test.stopTest();

        // Verify resume package was created
        System.assertNotEquals(null, resumePackage.Id, 'Resume package should be created');

        // Query to verify all fields
        Resume_Package__c verifyPackage = [SELECT Id, Job_Posting__c, Resume_Content__c,
                                                  Cover_Letter__c, Status__c, Generated_Date__c
                                           FROM Resume_Package__c
                                           WHERE Id = :resumePackage.Id];

        System.assertEquals(testJob.Id, verifyPackage.Job_Posting__c, 'Should link to correct job');
        System.assertEquals('Draft', verifyPackage.Status__c, 'Status should be Draft');
        System.assertNotEquals(null, verifyPackage.Generated_Date__c, 'Generated date should be set');
        System.assert(verifyPackage.Resume_Content__c.length() > 0, 'Resume content should not be empty');
        System.assert(verifyPackage.Cover_Letter__c.length() > 0, 'Cover letter should not be empty');
        System.assert(verifyPackage.Resume_Content__c.contains('JOHN DOE'), 'Resume should contain candidate name');
    }

    /**
     * @description Test error handling when master resume not configured
     */
    @isTest
    static void testGenerateResumePackage_NoMasterResume() {
        // Create test job posting
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Test Job',
            Company__c = 'Test Company',
            Location__c = 'Remote'
        );
        insert testJob;

        Test.startTest();

        Boolean exceptionCaught = false;
        try {
            Resume_Package__c resumePackage = ResumeGenerator.generateResumePackage(testJob.Id);
        } catch (ResumeGenerator.ResumeGeneratorException e) {
            exceptionCaught = true;
            System.assert(e.getMessage().contains('Master resume not configured'), 'Should indicate missing master resume');
        }

        Test.stopTest();

        System.assert(exceptionCaught, 'Should throw exception when master resume not configured');
    }

    /**
     * @description Test content cleaning removes markdown code blocks
     */
    @isTest
    static void testCleanContent() {
        String contentWithMarkdown = '```apex\nSystem.debug(\"test\");\n```\nActual content here';

        Test.startTest();

        // Access private method through test generation
        Master_Resume_Config__c masterResume = new Master_Resume_Config__c(
            Resume_Content__c = 'Test resume content'
        );
        insert masterResume;

        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Test',
            Company__c = 'Test',
            Location__c = 'Test'
        );
        insert testJob;

        Test.setMock(HttpCalloutMock.class, new CleanContentMock());
        Resume_Package__c pkg = ResumeGenerator.generateResumePackage(testJob.Id);

        Test.stopTest();

        // Verify markdown was removed
        System.assert(!pkg.Resume_Content__c.contains('```'), 'Should remove markdown code blocks');
    }

    /**
     * @description Mock for testing content cleaning
     */
    private class CleanContentMock implements HttpCalloutMock {
        private Integer callCount = 0;

        public HTTPResponse respond(HTTPRequest req) {
            callCount++;

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String responseText = (callCount == 1) ?
                '```text\\nJOHN DOE\\nSalesforce Developer\\n```\\nContent here' :
                'Dear Hiring Manager...';

            String responseBody = '{' +
                '"id": "msg_clean_' + callCount + '",' +
                '"type": "message",' +
                '"role": "assistant",' +
                '"content": [{"type": "text", "text": "' + responseText + '"}],' +
                '"model": "claude-3-haiku-20240307",' +
                '"stop_reason": "end_turn",' +
                '"usage": {"input_tokens": 100, "output_tokens": 50}' +
            '}';

            res.setBody(responseBody);
            return res;
        }
    }

    /**
     * @description Test helper method viewResumePackage
     */
    @isTest
    static void testViewResumePackage() {
        Test.setMock(HttpCalloutMock.class, new ResumeGenerationMockSuccess());

        // Create test data
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Test Job',
            Company__c = 'Test Company',
            Location__c = 'Remote'
        );
        insert testJob;

        Master_Resume_Config__c masterResume = new Master_Resume_Config__c(
            Resume_Content__c = 'Test resume'
        );
        insert masterResume;

        Resume_Package__c pkg = ResumeGenerator.generateResumePackage(testJob.Id);

        Test.startTest();

        // Call view method (just verify it doesn't throw exception)
        ResumeGenerator.viewResumePackage(pkg.Id);

        Test.stopTest();

        // If we got here, the method executed successfully
        System.assert(true, 'viewResumePackage should execute without errors');
    }

    /**
     * @description Test helper method testGenerateResume
     */
    @isTest
    static void testTestGenerateResume() {
        Test.setMock(HttpCalloutMock.class, new ResumeGenerationMockSuccess());

        // Create test data
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Test Job',
            Company__c = 'Test Company',
            Location__c = 'Remote'
        );
        insert testJob;

        Master_Resume_Config__c masterResume = new Master_Resume_Config__c(
            Resume_Content__c = 'Test resume'
        );
        insert masterResume;

        Test.startTest();

        // Call test helper method
        ResumeGenerator.testGenerateResume(testJob.Id);

        Test.stopTest();

        // Verify resume package was created
        List<Resume_Package__c> packages = [SELECT Id FROM Resume_Package__c WHERE Job_Posting__c = :testJob.Id];
        System.assertEquals(1, packages.size(), 'Should create one resume package');
    }

    /**
     * @description Test API error during resume generation
     */
    @isTest
    static void testGenerateResumePackage_APIError() {
        Test.setMock(HttpCalloutMock.class, new APIErrorMock());

        // Create test data
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Test Job',
            Company__c = 'Test Company',
            Location__c = 'Remote'
        );
        insert testJob;

        Master_Resume_Config__c masterResume = new Master_Resume_Config__c(
            Resume_Content__c = 'Test resume'
        );
        insert masterResume;

        Test.startTest();

        Boolean exceptionCaught = false;
        try {
            Resume_Package__c pkg = ResumeGenerator.generateResumePackage(testJob.Id);
        } catch (Exception e) {
            exceptionCaught = true;
        }

        Test.stopTest();

        System.assert(exceptionCaught, 'Should handle API errors gracefully');
    }

    /**
     * @description Mock for API error
     */
    private class APIErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error": "Internal server error"}');
            return res;
        }
    }
}

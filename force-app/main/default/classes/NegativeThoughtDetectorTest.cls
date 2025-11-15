/**
 * @description Test class for NegativeThoughtDetector
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
@isTest
private class NegativeThoughtDetectorTest {

    private class ClaudeAPIMockDistortion implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
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
                        '"text": "[{\\"distortionType\\": \\"All-or-Nothing Thinking\\", \\"extractedThought\\": \\"I always mess everything up\\", \\"severityScore\\": 8, \\"suggestedReframe\\": \\"Consider the middle ground. What did go well?\\"}]"' +
                    '}' +
                '],' +
                '"model": "claude-3-haiku-20240307",' +
                '"stop_reason": "end_turn",' +
                '"usage": {"input_tokens": 100, "output_tokens": 150}' +
            '}';

            res.setBody(responseBody);
            return res;
        }
    }

    @testSetup
    static void setup() {
        // Create test mood entry
        Mood_Entry__c mood = new Mood_Entry__c(
            Mood_Score__c = 4,
            Energy_Score__c = 3,
            Notes__c = 'I always mess everything up. Nothing ever goes right.',
            Time_of_Day__c = 'Evening',
            Timestamp__c = DateTime.now()
        );
        insert mood;
    }

    @isTest
    static void testDetectDistortions() {
        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockDistortion());

        String text = 'I always mess everything up. Nothing ever goes right.';

        Test.startTest();
        List<NegativeThoughtDetector.DistortionResult> distortions =
            NegativeThoughtDetector.detectDistortions(text);
        Test.stopTest();

        System.assertNotEquals(null, distortions, 'Distortions should not be null');
        System.assertEquals(1, distortions.size(), 'Should detect 1 distortion');
        System.assertEquals('All-or-Nothing Thinking', distortions[0].distortionType);
        System.assertEquals(8, distortions[0].severityScore);
        System.assertNotEquals(null, distortions[0].suggestedReframe);
    }

    @isTest
    static void testDetectDistortions_BlankText() {
        Test.startTest();
        List<NegativeThoughtDetector.DistortionResult> distortions =
            NegativeThoughtDetector.detectDistortions('');
        Test.stopTest();

        System.assertEquals(0, distortions.size(), 'Should return empty list for blank text');
    }

    @isTest
    static void testGenerateReframe() {
        String reframe = NegativeThoughtDetector.generateReframe(
            'I always fail',
            'All-or-Nothing Thinking'
        );

        System.assertNotEquals(null, reframe, 'Reframe should not be null');
        System.assert(reframe.length() > 0, 'Reframe should have content');
    }

    @isTest
    static void testGenerateReframe_UnknownDistortion() {
        String reframe = NegativeThoughtDetector.generateReframe(
            'Some thought',
            'Unknown Distortion Type'
        );

        System.assertNotEquals(null, reframe, 'Should provide default reframe');
        System.assert(reframe.contains('Challenge'), 'Should provide challenge prompt');
    }

    @isTest
    static void testCreateAnalysis() {
        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockDistortion());

        Mood_Entry__c mood = [SELECT Id FROM Mood_Entry__c LIMIT 1];

        Test.startTest();
        Negative_Thought_Analysis__c analysis = NegativeThoughtDetector.createAnalysis(
            'I always mess up',
            mood.Id
        );
        Test.stopTest();

        System.assertNotEquals(null, analysis, 'Analysis should be created');
        System.assertNotEquals(null, analysis.Id, 'Analysis should be inserted');
        System.assertEquals(mood.Id, analysis.Mood_Entry__c, 'Should link to mood');
        System.assertEquals('All-or-Nothing Thinking', analysis.Primary_Distortion__c);
        System.assertEquals(8, analysis.Severity_Score__c);
        System.assertEquals(true, analysis.Processed_By_AI__c);
    }

    @isTest
    static void testCreateAnalysis_NoDistortions() {
        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockNoDistortions());

        Mood_Entry__c mood = [SELECT Id FROM Mood_Entry__c LIMIT 1];

        Test.startTest();
        Negative_Thought_Analysis__c analysis = NegativeThoughtDetector.createAnalysis(
            'Today was okay',
            mood.Id
        );
        Test.stopTest();

        System.assertEquals(null, analysis, 'Should not create analysis when no distortions');
    }

    @isTest
    static void testBatchAnalyzeMoodEntries() {
        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockDistortion());

        Mood_Entry__c mood = [SELECT Id FROM Mood_Entry__c LIMIT 1];
        Set<Id> moodIds = new Set<Id>{mood.Id};

        Test.startTest();
        NegativeThoughtDetector.batchAnalyzeMoodEntries(moodIds);
        Test.stopTest();

        List<Negative_Thought_Analysis__c> analyses = [
            SELECT Id, Mood_Entry__c
            FROM Negative_Thought_Analysis__c
            WHERE Mood_Entry__c = :mood.Id
        ];

        System.assert(analyses.size() > 0, 'Should create analysis records');
    }

    @isTest
    static void testDistortionResult_Constructor() {
        NegativeThoughtDetector.DistortionResult result =
            new NegativeThoughtDetector.DistortionResult();

        System.assertEquals(5, result.severityScore, 'Should default to 5');
        System.assertEquals(null, result.distortionType, 'Should be null by default');
    }

    // Mock for no distortions detected
    private class ClaudeAPIMockNoDistortions implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String responseBody = '{' +
                '"id": "msg_01ABC123",' +
                '"type": "message",' +
                '"role": "assistant",' +
                '"content": [{"type": "text", "text": "[]"}],' +
                '"model": "claude-3-haiku-20240307",' +
                '"stop_reason": "end_turn",' +
                '"usage": {"input_tokens": 100, "output_tokens": 10}' +
            '}';

            res.setBody(responseBody);
            return res;
        }
    }
}

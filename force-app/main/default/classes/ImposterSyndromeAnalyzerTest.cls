/**
 * @description Test class for ImposterSyndromeAnalyzer
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
@isTest
private class ImposterSyndromeAnalyzerTest {

    private class ClaudeAPIMockImposter implements HttpCalloutMock {
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
                        '"text": "{\\"isImposterThought\\": true, \\"primaryPattern\\": \\"Discount Success\\", \\"severityScore\\": 7, \\"detectedPatterns\\": [\\"Discount Success\\", \\"Attribute to Luck\\"], \\"suggestedReframe\\": \\"Your success came from your skills and effort, not just luck.\\"}"' +
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
        // Create test wins
        Daily_Routine__c routine = new Daily_Routine__c(
            Date__c = Date.today()
        );
        insert routine;

        List<Win_Entry__c> wins = new List<Win_Entry__c>();
        wins.add(new Win_Entry__c(
            Win_Text__c = 'Completed major project ahead of schedule',
            Category__c = 'Career',
            Impact_Score__c = 9,
            Daily_Routine__c = routine.Id
        ));
        wins.add(new Win_Entry__c(
            Win_Text__c = 'Received positive feedback from manager',
            Category__c = 'Career',
            Impact_Score__c = 8,
            Daily_Routine__c = routine.Id
        ));
        insert wins;
    }

    @isTest
    static void testAnalyzeText_ImposterDetected() {
        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockImposter());

        String text = 'I just got lucky on that project. Anyone could have done it.';

        Test.startTest();
        ImposterSyndromeAnalyzer.ImposterAnalysisResult result = ImposterSyndromeAnalyzer.analyzeText(text);
        Test.stopTest();

        System.assertEquals(true, result.isImposterThought, 'Should detect imposter thought');
        System.assertEquals('Discount Success', result.primaryPattern, 'Should identify pattern');
        System.assertEquals(7, result.severityScore, 'Should have severity score');
        System.assertNotEquals(null, result.detectedPatterns, 'Should have detected patterns');
        System.assert(result.detectedPatterns.size() > 0, 'Should have at least one pattern');
    }

    @isTest
    static void testAnalyzeText_BlankText() {
        Test.startTest();
        ImposterSyndromeAnalyzer.ImposterAnalysisResult result = ImposterSyndromeAnalyzer.analyzeText('');
        Test.stopTest();

        System.assertEquals(false, result.isImposterThought, 'Should return false for blank text');
    }

    @isTest
    static void testGenerateRebuttal() {
        Test.startTest();
        String rebuttal = ImposterSyndromeAnalyzer.generateRebuttal(
            'I just got lucky',
            UserInfo.getUserId()
        );
        Test.stopTest();

        System.assertNotEquals(null, rebuttal, 'Rebuttal should not be null');
        System.assert(rebuttal.length() > 0, 'Rebuttal should have content');
        System.assert(rebuttal.contains('evidence'), 'Should mention evidence');
    }

    @isTest
    static void testGetRelevantWins() {
        Test.startTest();
        List<Win_Entry__c> wins = ImposterSyndromeAnalyzer.getRelevantWins(
            'I just got lucky',
            UserInfo.getUserId()
        );
        Test.stopTest();

        System.assertNotEquals(null, wins, 'Wins list should not be null');
        System.assert(wins.size() > 0, 'Should return some wins');
    }

    @isTest
    static void testGetImposterFrequency() {
        // Create test sessions
        List<Imposter_Syndrome_Session__c> sessions = new List<Imposter_Syndrome_Session__c>();
        sessions.add(new Imposter_Syndrome_Session__c(
            Session_Type__c = 'AI Analysis',
            Primary_Pattern__c = 'Discount Success'
        ));
        sessions.add(new Imposter_Syndrome_Session__c(
            Session_Type__c = 'AI Analysis',
            Primary_Pattern__c = 'Discount Success'
        ));
        sessions.add(new Imposter_Syndrome_Session__c(
            Session_Type__c = 'AI Analysis',
            Primary_Pattern__c = 'Fear of Exposure'
        ));
        insert sessions;

        Test.startTest();
        Map<String, Integer> frequencies = ImposterSyndromeAnalyzer.getImposterFrequency(
            UserInfo.getUserId(),
            30
        );
        Test.stopTest();

        System.assertNotEquals(null, frequencies, 'Frequencies should not be null');
        System.assertEquals(2, frequencies.get('Discount Success'), 'Should count Discount Success');
        System.assertEquals(1, frequencies.get('Fear of Exposure'), 'Should count Fear of Exposure');
    }

    @isTest
    static void testCreateSession() {
        ImposterSyndromeAnalyzer.ImposterAnalysisResult analysis =
            new ImposterSyndromeAnalyzer.ImposterAnalysisResult();
        analysis.isImposterThought = true;
        analysis.primaryPattern = 'Discount Success';
        analysis.severityScore = 8;
        analysis.detectedPatterns = new List<String>{'Discount Success', 'Attribute to Luck'};
        analysis.suggestedReframe = 'You earned this success through your skills.';

        Test.startTest();
        Imposter_Syndrome_Session__c session = ImposterSyndromeAnalyzer.createSession(
            analysis,
            UserInfo.getUserId()
        );
        Test.stopTest();

        System.assertNotEquals(null, session, 'Session should be created');
        System.assertNotEquals(null, session.Id, 'Session should be inserted');
        System.assertEquals('Discount Success', session.Primary_Pattern__c, 'Should set pattern');
        System.assertEquals(8, session.Severity_Score__c, 'Should set severity');
    }

    @isTest
    static void testCreateSession_NotImposterThought() {
        ImposterSyndromeAnalyzer.ImposterAnalysisResult analysis =
            new ImposterSyndromeAnalyzer.ImposterAnalysisResult();
        analysis.isImposterThought = false;

        Test.startTest();
        Imposter_Syndrome_Session__c session = ImposterSyndromeAnalyzer.createSession(
            analysis,
            UserInfo.getUserId()
        );
        Test.stopTest();

        System.assertEquals(null, session, 'Should not create session for non-imposter thoughts');
    }

    @isTest
    static void testImposterAnalysisResult_Constructor() {
        ImposterSyndromeAnalyzer.ImposterAnalysisResult result =
            new ImposterSyndromeAnalyzer.ImposterAnalysisResult();

        System.assertEquals(false, result.isImposterThought, 'Should default to false');
        System.assertEquals(0, result.severityScore, 'Should default to 0');
        System.assertNotEquals(null, result.detectedPatterns, 'Should initialize list');
        System.assertEquals(0, result.detectedPatterns.size(), 'Should have empty list');
    }
}

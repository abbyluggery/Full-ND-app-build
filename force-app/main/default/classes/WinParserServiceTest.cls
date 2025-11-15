/**
 * @description Test class for WinParserService
 * Tests AI-powered win extraction with HTTP Mock callouts
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
@isTest
private class WinParserServiceTest {

    /**
     * @description Mock HTTP callout for successful Claude API response
     */
    private class ClaudeAPIMockWinExtraction implements HttpCalloutMock {
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
                        '"text": "[{\\"winText\\": \\"Completed morning exercise routine\\", \\"category\\": \\"Health\\", \\"impactScore\\": 7}, {\\"winText\\": \\"Had productive meeting with manager\\", \\"category\\": \\"Career\\", \\"impactScore\\": 8}]"' +
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
     * @description Test extractWins method with successful API response
     */
    @isTest
    static void testExtractWins_Success() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockWinExtraction());

        // Test data
        String journalText = 'Today I woke up early and did my morning exercise. ' +
            'I also had a great meeting with my manager about my career goals.';

        Test.startTest();
        List<WinParserService.WinData> wins = WinParserService.extractWins(journalText);
        Test.stopTest();

        // Verify results
        System.assertNotEquals(null, wins, 'Wins list should not be null');
        System.assertEquals(2, wins.size(), 'Should extract 2 wins');
        System.assertEquals('Completed morning exercise routine', wins[0].winText);
        System.assertEquals('Health', wins[0].category);
        System.assertEquals(7, wins[0].impactScore);
    }

    /**
     * @description Test extractWins with blank journal text
     */
    @isTest
    static void testExtractWins_BlankText() {
        Test.startTest();
        List<WinParserService.WinData> wins = WinParserService.extractWins('');
        Test.stopTest();

        System.assertEquals(0, wins.size(), 'Should return empty list for blank text');
    }

    /**
     * @description Test categorizeWin method with various texts
     */
    @isTest
    static void testCategorizeWin() {
        System.assertEquals('Career', WinParserService.categorizeWin('Got a new job offer'), 'Should categorize as Career');
        System.assertEquals('Health', WinParserService.categorizeWin('Went for a workout'), 'Should categorize as Health');
        System.assertEquals('Social', WinParserService.categorizeWin('Had dinner with friends'), 'Should categorize as Social');
        System.assertEquals('Personal', WinParserService.categorizeWin('Learned a new skill'), 'Should categorize as Personal');
        System.assertEquals('Other', WinParserService.categorizeWin('Had a good day'), 'Should categorize as Other');
        System.assertEquals('Other', WinParserService.categorizeWin(''), 'Should return Other for blank text');
    }

    /**
     * @description Test createWinRecords method
     */
    @isTest
    static void testCreateWinRecords() {
        // Create test Daily_Routine__c record
        Daily_Routine__c routine = new Daily_Routine__c(
            Date__c = Date.today(),
            Morning_Routine_Complete__c = true
        );
        insert routine;

        // Create test win data
        List<WinParserService.WinData> wins = new List<WinParserService.WinData>();

        WinParserService.WinData win1 = new WinParserService.WinData();
        win1.winText = 'Completed workout';
        win1.category = 'Health';
        win1.impactScore = 8;
        wins.add(win1);

        WinParserService.WinData win2 = new WinParserService.WinData();
        win2.winText = 'Submitted project on time';
        win2.category = 'Career';
        win2.impactScore = 9;
        wins.add(win2);

        Test.startTest();
        List<Win_Entry__c> winRecords = WinParserService.createWinRecords(wins, routine.Id);
        Test.stopTest();

        // Verify records were created
        System.assertEquals(2, winRecords.size(), 'Should create 2 win records');

        // Query to verify they were inserted
        List<Win_Entry__c> insertedWins = [
            SELECT Id, Win_Text__c, Category__c, Impact_Score__c, Source__c, Daily_Routine__c
            FROM Win_Entry__c
            WHERE Daily_Routine__c = :routine.Id
        ];

        System.assertEquals(2, insertedWins.size(), 'Should have 2 wins in database');
        System.assertEquals('AI-Extracted', insertedWins[0].Source__c, 'Source should be AI-Extracted');
        System.assertEquals(routine.Id, insertedWins[0].Daily_Routine__c, 'Should link to routine');
    }

    /**
     * @description Test createWinRecords with empty list
     */
    @isTest
    static void testCreateWinRecords_EmptyList() {
        Daily_Routine__c routine = new Daily_Routine__c(
            Date__c = Date.today()
        );
        insert routine;

        Test.startTest();
        List<Win_Entry__c> winRecords = WinParserService.createWinRecords(
            new List<WinParserService.WinData>(),
            routine.Id
        );
        Test.stopTest();

        System.assertEquals(0, winRecords.size(), 'Should return empty list');
    }

    /**
     * @description Test batchProcessJournals method
     */
    @isTest
    static void testBatchProcessJournals() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMockWinExtraction());

        // Create test routines with journal entries
        List<Daily_Routine__c> routines = new List<Daily_Routine__c>();
        for (Integer i = 0; i < 3; i++) {
            routines.add(new Daily_Routine__c(
                Date__c = Date.today().addDays(-i),
                Journal_Entry__c = 'Today was productive. I exercised and had good meetings.'
            ));
        }
        insert routines;

        Set<Id> routineIds = new Set<Id>();
        for (Daily_Routine__c r : routines) {
            routineIds.add(r.Id);
        }

        Test.startTest();
        WinParserService.batchProcessJournals(routineIds);
        Test.stopTest();

        // Verify wins were created (mock returns 2 wins per journal)
        List<Win_Entry__c> createdWins = [
            SELECT Id, Daily_Routine__c
            FROM Win_Entry__c
            WHERE Daily_Routine__c IN :routineIds
        ];

        System.assert(createdWins.size() > 0, 'Should create some wins');
    }

    /**
     * @description Test WinData inner class default constructor
     */
    @isTest
    static void testWinDataConstructor() {
        WinParserService.WinData win = new WinParserService.WinData();

        System.assertEquals(5, win.impactScore, 'Default impact score should be 5');
        System.assertEquals(null, win.winText, 'Win text should be null by default');
        System.assertEquals(null, win.category, 'Category should be null by default');
    }
}

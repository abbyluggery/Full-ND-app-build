/**
 * @description AI-powered service to extract wins/accomplishments from journal entries
 * and automatically categorize them by type (career, personal, health, social)
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
public with sharing class WinParserService {

    /**
     * @description Parse journal entry and extract wins using AI
     * @param journalText The journal entry text to analyze
     * @return List<WinData> Extracted wins with categories and impact scores
     */
    public static List<WinData> extractWins(String journalText) {
        if (String.isBlank(journalText)) {
            return new List<WinData>();
        }

        try {
            // Build system prompt for win extraction
            String systemPrompt = 'You are a supportive wellness coach analyzing journal entries. ' +
                'Your job is to identify wins, accomplishments, and positive moments from journal text. ' +
                'Extract ALL wins, no matter how small - even tiny victories count!';

            // Build user prompt
            String userPrompt = 'Analyze this journal entry and extract all wins/accomplishments:\n\n' +
                journalText + '\n\n' +
                'Return a JSON array of wins with this format:\n' +
                '[\n' +
                '  {"winText": "description", "category": "Career|Personal|Health|Social|Other", "impactScore": 1-10}\n' +
                ']\n\n' +
                'Categories:\n' +
                '- Career: Job, work, professional development\n' +
                '- Personal: Hobbies, learning, personal growth\n' +
                '- Health: Exercise, nutrition, sleep, mental health\n' +
                '- Social: Relationships, friendships, connections\n' +
                '- Other: Anything else\n\n' +
                'Impact score (1-10): How significant is this win?\n' +
                'Only return the JSON array, nothing else.';

            // Call Claude API
            ClaudeAPIService.ClaudeResponse response = ClaudeAPIService.generateText(systemPrompt, userPrompt);
            String responseText = ClaudeAPIService.extractTextContent(response);

            // Parse JSON response
            return parseWinsFromJSON(responseText);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Win extraction error: ' + e.getMessage());
            // Return empty list on error - don't block the user
            return new List<WinData>();
        }
    }

    /**
     * @description Categorize a single win text
     * @param winText The win description
     * @return String The category (Career, Personal, Health, Social, Other)
     */
    public static String categorizeWin(String winText) {
        if (String.isBlank(winText)) {
            return 'Other';
        }

        // Simple keyword-based categorization as fallback
        String lowerText = winText.toLowerCase();

        if (lowerText.contains('work') || lowerText.contains('job') || lowerText.contains('career') ||
            lowerText.contains('interview') || lowerText.contains('project')) {
            return 'Career';
        } else if (lowerText.contains('exercise') || lowerText.contains('workout') || lowerText.contains('sleep') ||
                   lowerText.contains('eat') || lowerText.contains('health') || lowerText.contains('meditate')) {
            return 'Health';
        } else if (lowerText.contains('friend') || lowerText.contains('family') || lowerText.contains('social') ||
                   lowerText.contains('date') || lowerText.contains('call')) {
            return 'Social';
        } else if (lowerText.contains('learn') || lowerText.contains('read') || lowerText.contains('hobby') ||
                   lowerText.contains('creative')) {
            return 'Personal';
        }

        return 'Other';
    }

    /**
     * @description Create Win_Entry__c records from parsed win data
     * @param wins List of WinData objects
     * @param dailyRoutineId The Daily_Routine__c ID to link to
     * @return List<Win_Entry__c> The created records
     */
    public static List<Win_Entry__c> createWinRecords(List<WinData> wins, Id dailyRoutineId) {
        List<Win_Entry__c> winRecords = new List<Win_Entry__c>();

        for (WinData winData : wins) {
            Win_Entry__c win = new Win_Entry__c();
            win.Win_Text__c = winData.winText;
            win.Category__c = winData.category;
            win.Impact_Score__c = winData.impactScore;
            win.Daily_Routine__c = dailyRoutineId;
            win.Source__c = 'AI-Extracted';
            winRecords.add(win);
        }

        if (!winRecords.isEmpty()) {
            insert winRecords;
        }

        return winRecords;
    }

    /**
     * @description Batch process multiple journal entries
     * @param dailyRoutineIds List of Daily_Routine__c IDs to process
     */
    @future(callout=true)
    public static void batchProcessJournals(Set<Id> dailyRoutineIds) {
        List<Daily_Routine__c> routines = [
            SELECT Id, Journal_Entry__c
            FROM Daily_Routine__c
            WHERE Id IN :dailyRoutineIds
        ];

        for (Daily_Routine__c routine : routines) {
            // Skip if journal entry is blank (LongTextArea can't be filtered in SOQL WHERE)
            if (String.isBlank(routine.Journal_Entry__c)) {
                continue;
            }

            try {
                List<WinData> wins = extractWins(routine.Journal_Entry__c);
                if (!wins.isEmpty()) {
                    createWinRecords(wins, routine.Id);
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Error processing routine ' + routine.Id + ': ' + e.getMessage());
                // Continue processing other routines
            }
        }
    }

    /**
     * @description Parse wins from Claude's JSON response
     * @param jsonText The JSON response text
     * @return List<WinData> Parsed wins
     */
    private static List<WinData> parseWinsFromJSON(String jsonText) {
        List<WinData> wins = new List<WinData>();

        try {
            // Clean up response (Claude might add markdown backticks)
            jsonText = jsonText.trim();
            if (jsonText.startsWith('```json')) {
                jsonText = jsonText.substring(7);
            }
            if (jsonText.startsWith('```')) {
                jsonText = jsonText.substring(3);
            }
            if (jsonText.endsWith('```')) {
                jsonText = jsonText.substring(0, jsonText.length() - 3);
            }
            jsonText = jsonText.trim();

            // Parse JSON array
            List<Object> jsonList = (List<Object>) JSON.deserializeUntyped(jsonText);

            for (Object obj : jsonList) {
                Map<String, Object> winMap = (Map<String, Object>) obj;

                WinData win = new WinData();
                win.winText = (String) winMap.get('winText');
                win.category = (String) winMap.get('category');

                Object impactObj = winMap.get('impactScore');
                if (impactObj != null) {
                    win.impactScore = Integer.valueOf(impactObj);
                } else {
                    win.impactScore = 5; // Default
                }

                wins.add(win);
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'JSON parse error: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'JSON text: ' + jsonText);
        }

        return wins;
    }

    /**
     * @description Inner class to represent extracted win data
     */
    public class WinData {
        public String winText;
        public String category;
        public Integer impactScore;

        public WinData() {
            this.impactScore = 5; // Default impact score
        }
    }
}

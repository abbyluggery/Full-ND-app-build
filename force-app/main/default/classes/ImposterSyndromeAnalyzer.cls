/**
 * @description AI-powered analyzer to detect imposter syndrome patterns in journal entries
 * and generate evidence-based counter-narratives using user's win history
 *
 * @author Claude Code Assistant
 * @date 2025-11-15
 */
public with sharing class ImposterSyndromeAnalyzer {

    /**
     * @description Analyze text for imposter syndrome patterns using AI
     * @param text The text to analyze (journal entry, mood notes, etc.)
     * @return ImposterAnalysisResult Analysis results
     */
    public static ImposterAnalysisResult analyzeText(String text) {
        if (String.isBlank(text)) {
            ImposterAnalysisResult result = new ImposterAnalysisResult();
            result.isImposterThought = false;
            return result;
        }

        try {
            String systemPrompt = 'You are a compassionate therapist specializing in imposter syndrome. ' +
                'Analyze text for signs of imposter syndrome patterns.';

            String userPrompt = 'Analyze this text for imposter syndrome patterns:\n\n' +
                text + '\n\n' +
                'Return JSON with this format:\n' +
                '{\n' +
                '  "isImposterThought": true/false,\n' +
                '  "primaryPattern": "Discount Success|Fear of Exposure|Attribute to Luck|Perfectionism|Compare to Others",\n' +
                '  "severityScore": 1-10,\n' +
                '  "detectedPatterns": ["pattern1", "pattern2"],\n' +
                '  "suggestedReframe": "compassionate reframe"\n' +
                '}\n\n' +
                'Common patterns:\n' +
                '- Discount Success: "I just got lucky", "Anyone could do this"\n' +
                '- Fear of Exposure: "They\'ll find out I\'m a fraud"\n' +
                '- Attribute to Luck: Downplaying role in success\n' +
                '- Perfectionism: All-or-nothing thinking\n' +
                '- Compare to Others: "Everyone else is better"\n\n' +
                'Only return the JSON, nothing else.';

            ClaudeAPIService.ClaudeResponse response = ClaudeAPIService.generateText(systemPrompt, userPrompt);
            String responseText = ClaudeAPIService.extractTextContent(response);

            return parseAnalysisResult(responseText);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Imposter syndrome analysis error: ' + e.getMessage());
            ImposterAnalysisResult result = new ImposterAnalysisResult();
            result.isImposterThought = false;
            return result;
        }
    }

    /**
     * @description Generate evidence-based rebuttal using user's win history
     * @param imposterThought The imposter syndrome thought
     * @param userId User ID to get win history
     * @return String Evidence-based rebuttal
     */
    public static String generateRebuttal(String imposterThought, Id userId) {
        List<Win_Entry__c> relevantWins = getRelevantWins(imposterThought, userId);

        String rebuttal = 'Let\'s look at the evidence:\n\n';

        if (relevantWins.isEmpty()) {
            rebuttal += 'You\'ve accomplished things that matter. Your success is real and earned.';
        } else {
            rebuttal += 'Here are some of your recent accomplishments:\n';
            Integer count = 0;
            for (Win_Entry__c win : relevantWins) {
                if (count >= 5) break; // Limit to 5
                rebuttal += '- ' + win.Win_Text__c;
                if (win.Impact_Score__c != null) {
                    rebuttal += ' (Impact: ' + win.Impact_Score__c + '/10)';
                }
                rebuttal += '\n';
                count++;
            }
            rebuttal += '\nThese accomplishments are evidence of your skills and effort, not luck.';
        }

        return rebuttal;
    }

    /**
     * @description Get relevant wins for evidence
     * @param imposterThought The thought to find evidence against
     * @param userId User ID
     * @return List<Win_Entry__c> Relevant wins
     */
    public static List<Win_Entry__c> getRelevantWins(String imposterThought, Id userId) {
        // Get recent high-impact wins
        return [
            SELECT Id, Win_Text__c, Category__c, Impact_Score__c, CreatedDate
            FROM Win_Entry__c
            WHERE CreatedDate = LAST_N_DAYS:30
            ORDER BY Impact_Score__c DESC NULLS LAST, CreatedDate DESC
            LIMIT 10
        ];
    }

    /**
     * @description Track frequency of imposter thoughts over time
     * @param userId User ID
     * @param days Number of days to analyze
     * @return Map<String, Integer> Pattern frequencies
     */
    public static Map<String, Integer> getImposterFrequency(Id userId, Integer days) {
        Map<String, Integer> frequencies = new Map<String, Integer>();

        List<Imposter_Syndrome_Session__c> sessions = [
            SELECT Id, Primary_Pattern__c
            FROM Imposter_Syndrome_Session__c
            WHERE CreatedDate = LAST_N_DAYS:30
        ];

        for (Imposter_Syndrome_Session__c session : sessions) {
            if (String.isNotBlank(session.Primary_Pattern__c)) {
                if (!frequencies.containsKey(session.Primary_Pattern__c)) {
                    frequencies.put(session.Primary_Pattern__c, 0);
                }
                frequencies.put(session.Primary_Pattern__c, frequencies.get(session.Primary_Pattern__c) + 1);
            }
        }

        return frequencies;
    }

    /**
     * @description Create Imposter_Syndrome_Session__c record from analysis
     * @param analysis The analysis result
     * @param userId User ID
     * @return Imposter_Syndrome_Session__c The created session
     */
    public static Imposter_Syndrome_Session__c createSession(ImposterAnalysisResult analysis, Id userId) {
        if (!analysis.isImposterThought) {
            return null;
        }

        Imposter_Syndrome_Session__c session = new Imposter_Syndrome_Session__c();
        session.Session_Type__c = 'AI Analysis';
        session.Primary_Pattern__c = analysis.primaryPattern;
        session.Severity_Score__c = analysis.severityScore;
        session.Notes__c = 'Detected patterns: ' + String.join(analysis.detectedPatterns, ', ');
        session.Reframe_Suggestion__c = analysis.suggestedReframe;

        insert session;
        return session;
    }

    /**
     * @description Parse analysis result from JSON
     * @param jsonText JSON response from AI
     * @return ImposterAnalysisResult Parsed result
     */
    private static ImposterAnalysisResult parseAnalysisResult(String jsonText) {
        ImposterAnalysisResult result = new ImposterAnalysisResult();

        try {
            // Clean JSON
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

            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonText);

            result.isImposterThought = (Boolean) jsonMap.get('isImposterThought');
            result.primaryPattern = (String) jsonMap.get('primaryPattern');
            result.suggestedReframe = (String) jsonMap.get('suggestedReframe');

            Object severityObj = jsonMap.get('severityScore');
            if (severityObj != null) {
                result.severityScore = Integer.valueOf(severityObj);
            }

            List<Object> patternsObj = (List<Object>) jsonMap.get('detectedPatterns');
            if (patternsObj != null) {
                result.detectedPatterns = new List<String>();
                for (Object p : patternsObj) {
                    result.detectedPatterns.add((String) p);
                }
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'JSON parse error: ' + e.getMessage());
            result.isImposterThought = false;
        }

        return result;
    }

    /**
     * @description Inner class for analysis results
     */
    public class ImposterAnalysisResult {
        public Boolean isImposterThought;
        public String primaryPattern;
        public Integer severityScore;
        public List<String> detectedPatterns;
        public String suggestedReframe;

        public ImposterAnalysisResult() {
            this.isImposterThought = false;
            this.severityScore = 0;
            this.detectedPatterns = new List<String>();
        }
    }
}

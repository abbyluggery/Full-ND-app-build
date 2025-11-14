/**
 * @description Business logic layer for analyzing job postings using Claude AI
 * This class implements the holistic decision framework from your roadmap
 *
 * LEARNING NOTES:
 * - Business Logic Layer: Separates domain logic from API and database operations
 * - System Context: Incorporates your manifestation goals, neurodivergent needs, routine preferences
 * - JSON Parsing: Extracts structured data from Claude's responses
 *
 * @author Claude Code Assistant
 * @date 2025-10-26
 */
public with sharing class JobPostingAnalyzer {

    /**
     * @description Wrapper class for Claude's job analysis results
     * This makes the data easy to work with in Apex
     *
     * LEARNING: Wrapper classes = Apex objects that structure complex data
     */
    public class JobAnalysisResult {
        public Decimal fitScore;
        public Decimal ndFriendlinessScore;
        public String greenFlags;
        public String redFlags;
        public String recommendation;
        public String reasoning;
        public Boolean hasNdProgram;
        public Boolean flexibleSchedule;
        public String fullResponse; // Complete JSON from Claude

        // Constructor for easy initialization
        public JobAnalysisResult() {
            this.fitScore = 0;
            this.ndFriendlinessScore = 0;
            this.greenFlags = '';
            this.redFlags = '';
            this.recommendation = '';
            this.reasoning = '';
            this.hasNdProgram = false;
            this.flexibleSchedule = false;
            this.fullResponse = '';
        }
    }

    /**
     * @description Main method to analyze a job posting with Claude
     * This orchestrates the entire analysis workflow
     *
     * @param jobPosting The Job_Posting__c record to analyze
     * @return JobAnalysisResult The structured analysis results
     */
    public static JobAnalysisResult analyzeJob(Job_Posting__c jobPosting) {
        try {
            // Step 1: Build your holistic system context
            // LEARNING: This is where we incorporate all your skills and manifestation context
            String systemContext = buildHolisticSystemContext();

            // Step 2: Call Claude API
            ClaudeAPIService.ClaudeResponse response = ClaudeAPIService.analyzeJobPosting(
                jobPosting,
                systemContext
            );

            // Step 3: Extract text content from response
            String responseText = ClaudeAPIService.extractTextContent(response);

            // Step 4: Parse the JSON response into structured data
            JobAnalysisResult result = parseAnalysisResponse(responseText);

            // Log for debugging
            System.debug(LoggingLevel.INFO, 'Job Analysis Complete - Fit Score: ' + result.fitScore);

            return result;

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Job Analysis Error: ' + e.getMessage());
            throw new JobAnalysisException('Failed to analyze job: ' + e.getMessage(), e);
        }
    }

    /**
     * @description Builds the holistic system context from your roadmap
     * This tells Claude about your manifestation goals, neurodivergent needs, etc.
     *
     * LEARNING: System prompts are powerful - they give Claude persistent context
     * about who you are and what you need
     *
     * @return String The complete system context
     */
    private static String buildHolisticSystemContext() {
        // LEARNING: Use string concatenation for multi-line prompts
        // In production, you might store this in Custom Metadata or Custom Settings
        String context = '';

        context += '# HOLISTIC JOB SEARCH ASSISTANT - SYSTEM CONTEXT\n\n';

        context += '## Your Identity & Needs\n';
        context += 'You are analyzing job postings for Abby, a Salesforce professional with specific needs:\n\n';

        context += '### Professional Profile\n';
        context += '- **Experience**: 2.5 years Salesforce Administrator/Developer\n';
        context += '- **Specialization**: Agentforce (AI agents in Salesforce) - top differentiator\n';
        context += '- **Data Quality**: 99% integrity record across multiple orgs\n';
        context += '- **Certifications**: Salesforce Admin (in progress, exam Nov 2025)\n';
        context += '- **Technical Skills**: Apex, LWC, Flows, Data Management, AI/Automation\n\n';

        context += '### Neurodivergent Accommodations (NON-NEGOTIABLE)\n';
        context += '- **ADHD**: Needs flexible schedule, no rigid 9-5 expectations\n';
        context += '- **Bipolar**: Requires understanding of energy fluctuations\n';
        context += '- **Morning Flexibility**: No meetings before 10am on Mondays (hard boundary)\n';
        context += '- **Hard Stop**: 5:15pm daily (burnout prevention)\n';
        context += '- **Work Style**: Remote work required, async-friendly culture preferred\n';
        context += '- **Sensory Needs**: Quiet workspace, ability to take breaks (garden time)\n\n';

        context += '### Manifestation Goals\n';
        context += '- **Primary Goal**: $155,000 base salary (stretch goal)\n';
        context += '- **Realistic Range**: $85,000 - $110,000 for first role\n';
        context += '- **Path**: Secure $85-110K role → grow to Senior level → achieve $155K+\n';
        context += '- **Timeline**: Job offer by Nov 30, 2025\n';
        context += '- **Current Status**: 12 applications sent, 1 phone screen secured\n\n';

        context += '### MUST HAVE Requirements (Deal Breakers if Missing)\n';
        context += '1. **Remote Work**: 100% remote required\n';
        context += '2. **Neurodivergent-Friendly Culture**: Flexibility, understanding, accommodations\n';
        context += '3. **Salary**: Minimum $85,000 ANNUAL (if hourly, convert to annual: hourly × 2080 hours)\n';
        context += '4. **Flexible Schedule**: No rigid hours, understanding of energy management\n\n';

        context += '### NICE TO HAVE (Scoring Factors)\n';
        context += '- **Agentforce/AI Focus**: +2 points (leverages unique expertise)\n';
        context += '- **Growth-Stage Company**: +1 point (startup energy, growth opportunity)\n';
        context += '- **Stated ND Accommodations**: +2 points (disability-friendly employer)\n';
        context += '- **Clear Career Progression**: +1 point (path to Senior/Lead roles)\n';
        context += '- **International Travel**: +1 point (personal manifestation goal)\n';
        context += '- **Summer Fridays**: +0.5 points (work-life balance indicator)\n';
        context += '- **Unlimited PTO**: +1 point (trust-based culture)\n\n';

        context += '### Work-Life Balance Priorities\n';
        context += '- **Sustainable Pace**: No "hustle culture" or burnout-inducing environments\n';
        context += '- **Life Integration**: Employer understands employees have lives outside work\n';
        context += '- **Health Support**: Mental health days, therapy time, medical appointments\n';
        context += '- **Caregiver Recognition**: Understanding of family responsibilities\n\n';

        context += '## Analysis Framework\n';
        context += 'When analyzing jobs, use this decision tree:\n\n';
        context += '1. **Check MUST HAVEs**: If ANY are missing → SKIP (immediate disqualification)\n';
        context += '2. **Calculate NICE TO HAVE Score**: Add up points (0-10 scale)\n';
        context += '3. **Combine for Fit Score**:\n';
        context += '   - All MUST HAVEs met + Score 8-10 = FIT SCORE: 9-10 → "HIGH PRIORITY"\n';
        context += '   - All MUST HAVEs met + Score 6-7 = FIT SCORE: 7-8 → "GOOD FIT"\n';
        context += '   - All MUST HAVEs met + Score 4-5 = FIT SCORE: 5-6 → "CONSIDER"\n';
        context += '   - Any MUST HAVE missing = FIT SCORE: 0-3 → "SKIP"\n\n';

        context += '4. **ND Friendliness Score** (separate 0-10 scale):\n';
        context += '   - 9-10: Explicitly disability-friendly, accommodations mentioned\n';
        context += '   - 7-8: Flexible culture, understanding language used\n';
        context += '   - 5-6: Standard corporate, no red flags but no green flags\n';
        context += '   - 3-4: Rigid structure, "fast-paced", "wear many hats"\n';
        context += '   - 0-2: Red flags like "grind", "hustle", strict hours\n\n';

        context += '## Output Format\n';
        context += 'Always respond with valid JSON matching this exact structure:\n';
        context += '```json\n';
        context += '{\n';
        context += '  "fit_score": <number 0-10>,\n';
        context += '  "nd_friendliness_score": <number 0-10>,\n';
        context += '  "green_flags": "<bulleted list>",\n';
        context += '  "red_flags": "<bulleted list>",\n';
        context += '  "recommendation": "<HIGH PRIORITY|GOOD FIT|CONSIDER|SKIP>",\n';
        context += '  "reasoning": "<detailed explanation>",\n';
        context += '  "has_nd_program": <boolean true/false>,\n';
        context += '  "flexible_schedule": <boolean true/false>\n';
        context += '}\n';
        context += '```\n\n';
        context += '**Field Definitions:**\n';
        context += '- `has_nd_program`: TRUE if job posting explicitly mentions neurodiversity programs, disability accommodations, autism hiring initiatives, or similar inclusive programs\n';
        context += '- `flexible_schedule`: TRUE if job posting mentions flexible hours, flexible schedule, work-life balance, async work, or understanding of varied schedules\n\n';

        context += 'Be honest, evidence-based, and remember: Abby\'s well-being matters more than any job. ';
        context += 'It\'s better to pass on a "good" opportunity that lacks ND support than burn out in 3 months.';

        return context;
    }

    /**
     * @description Parses Claude's JSON response into a structured result object
     *
     * LEARNING: JSON parsing in Apex uses JSON.deserializeUntyped() for dynamic JSON
     * or JSON.deserialize() for known structures
     *
     * @param responseText The text response from Claude containing JSON
     * @return JobAnalysisResult The parsed result
     */
    private static JobAnalysisResult parseAnalysisResponse(String responseText) {
        JobAnalysisResult result = new JobAnalysisResult();
        result.fullResponse = responseText;

        try {
            // Extract JSON from response (Claude sometimes wraps it in markdown)
            // LEARNING: indexOf() and substring() are useful for text parsing
            String jsonText = extractJsonFromResponse(responseText);

            if (String.isBlank(jsonText)) {
                throw new JobAnalysisException('No JSON found in Claude response');
            }

            // Clean the JSON text - remove any literal newlines or tabs that aren't escaped
            // This fixes JSON parse errors from unescaped control characters
            jsonText = jsonText.replace('\r\n', ' ').replace('\n', ' ').replace('\r', ' ').replace('\t', ' ');

            // Parse JSON into a map
            // LEARNING: deserializeUntyped() converts JSON to Map<String, Object>
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonText);

            // Extract values with safe type casting
            // LEARNING: Always check for null before casting to avoid NullPointerException
            if (jsonMap.containsKey('fit_score')) {
                Object fitScoreObj = jsonMap.get('fit_score');
                if (fitScoreObj instanceof Decimal) {
                    result.fitScore = (Decimal) fitScoreObj;
                } else if (fitScoreObj instanceof Integer) {
                    result.fitScore = (Decimal) (Integer) fitScoreObj;
                } else if (fitScoreObj instanceof Double) {
                    result.fitScore = (Decimal) (Double) fitScoreObj;
                }
            }

            if (jsonMap.containsKey('nd_friendliness_score')) {
                Object ndScoreObj = jsonMap.get('nd_friendliness_score');
                if (ndScoreObj instanceof Decimal) {
                    result.ndFriendlinessScore = (Decimal) ndScoreObj;
                } else if (ndScoreObj instanceof Integer) {
                    result.ndFriendlinessScore = (Decimal) (Integer) ndScoreObj;
                } else if (ndScoreObj instanceof Double) {
                    result.ndFriendlinessScore = (Decimal) (Double) ndScoreObj;
                }
            }

            if (jsonMap.containsKey('green_flags')) {
                Object greenFlagsObj = jsonMap.get('green_flags');
                if (greenFlagsObj instanceof String) {
                    result.greenFlags = (String) greenFlagsObj;
                } else if (greenFlagsObj instanceof List<Object>) {
                    // If Claude returns array instead of string, join with bullets
                    List<Object> flagsList = (List<Object>) greenFlagsObj;
                    result.greenFlags = String.join(flagsList, '\n• ');
                }
            }

            if (jsonMap.containsKey('red_flags')) {
                Object redFlagsObj = jsonMap.get('red_flags');
                if (redFlagsObj instanceof String) {
                    result.redFlags = (String) redFlagsObj;
                } else if (redFlagsObj instanceof List<Object>) {
                    List<Object> flagsList = (List<Object>) redFlagsObj;
                    result.redFlags = String.join(flagsList, '\n• ');
                }
            }

            if (jsonMap.containsKey('recommendation')) {
                result.recommendation = String.valueOf(jsonMap.get('recommendation'));
            }

            if (jsonMap.containsKey('reasoning')) {
                result.reasoning = String.valueOf(jsonMap.get('reasoning'));
            }

            if (jsonMap.containsKey('has_nd_program')) {
                Object hasNdProgramObj = jsonMap.get('has_nd_program');
                if (hasNdProgramObj instanceof Boolean) {
                    result.hasNdProgram = (Boolean) hasNdProgramObj;
                } else if (hasNdProgramObj instanceof String) {
                    // Handle "true"/"false" strings
                    result.hasNdProgram = Boolean.valueOf((String) hasNdProgramObj);
                }
            }

            if (jsonMap.containsKey('flexible_schedule')) {
                Object flexibleScheduleObj = jsonMap.get('flexible_schedule');
                if (flexibleScheduleObj instanceof Boolean) {
                    result.flexibleSchedule = (Boolean) flexibleScheduleObj;
                } else if (flexibleScheduleObj instanceof String) {
                    // Handle "true"/"false" strings
                    result.flexibleSchedule = Boolean.valueOf((String) flexibleScheduleObj);
                }
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'JSON Parse Error: ' + e.getMessage());
            // Don't throw - return partial result with what we could parse
            result.reasoning = 'Error parsing Claude response: ' + e.getMessage();
        }

        return result;
    }

    /**
     * @description Extracts JSON content from Claude's response text
     * Handles cases where JSON is wrapped in markdown code blocks
     *
     * LEARNING: Claude often wraps JSON in ```json...``` markdown blocks
     *
     * @param responseText The full response text
     * @return String The extracted JSON string
     */
    private static String extractJsonFromResponse(String responseText) {
        if (String.isBlank(responseText)) {
            return '';
        }

        // Look for JSON wrapped in markdown code blocks: ```json ... ```
        Integer jsonStart = responseText.indexOf('```json');
        if (jsonStart != -1) {
            // Found markdown wrapper
            jsonStart = responseText.indexOf('\n', jsonStart) + 1; // Skip past ```json line
            Integer jsonEnd = responseText.indexOf('```', jsonStart);
            if (jsonEnd != -1) {
                return responseText.substring(jsonStart, jsonEnd).trim();
            }
        }

        // Look for raw JSON starting with {
        jsonStart = responseText.indexOf('{');
        if (jsonStart != -1) {
            Integer jsonEnd = responseText.lastIndexOf('}');
            if (jsonEnd != -1 && jsonEnd > jsonStart) {
                return responseText.substring(jsonStart, jsonEnd + 1).trim();
            }
        }

        // If no JSON markers found, return the whole response and let parser handle it
        return responseText.trim();
    }

    /**
     * @description Updates a Job_Posting__c record with analysis results
     * This saves the Claude analysis back to Salesforce
     *
     * LEARNING: DML operations (insert, update, delete) save data to the database
     *
     * @param jobPosting The job posting to update (must have Id)
     * @param analysisResult The analysis results to save
     */
    public static void updateJobWithAnalysis(Job_Posting__c jobPosting, JobAnalysisResult analysisResult) {
        try {
            // Update the job posting fields
            // LEARNING: You can update an sObject by setting its fields and calling update
            jobPosting.ND_Friendliness_Score__c = analysisResult.ndFriendlinessScore;
            jobPosting.Green_Flags__c = analysisResult.greenFlags;
            jobPosting.Red_Flags__c = analysisResult.redFlags;
            jobPosting.Has_ND_Program__c = analysisResult.hasNdProgram;
            jobPosting.Flexible_Schedule__c = analysisResult.flexibleSchedule;
            jobPosting.Research_JSON__c = analysisResult.fullResponse;
            jobPosting.Research_Date__c = DateTime.now();

            // Update the record in the database
            update jobPosting;

            System.debug(LoggingLevel.INFO, 'Job Posting updated with analysis: ' + jobPosting.Id);

        } catch (DmlException e) {
            System.debug(LoggingLevel.ERROR, 'Failed to update Job Posting: ' + e.getMessage());
            throw new JobAnalysisException('Failed to save analysis results: ' + e.getMessage(), e);
        }
    }

    /**
     * @description Custom exception for job analysis errors
     */
    public class JobAnalysisException extends Exception {}
}

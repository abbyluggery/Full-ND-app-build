/**
 * @description Service class for integrating with Anthropic's Claude API
 * This class handles all HTTP communication with Claude and manages API authentication
 *
 * LEARNING NOTES:
 * - HTTP Callouts: How to make external API calls from Salesforce
 * - JSON Serialization: Converting Salesforce data to/from JSON
 * - Named Credentials: Secure way to store API keys
 * - Design Pattern: Service layer separates API logic from business logic
 *
 * @author Claude Code Assistant
 * @date 2025-10-26
 */
public with sharing class ClaudeAPIService {

    // Constants for Claude API configuration
    // LEARNING: Use constants for values that won't change - easier to maintain
    private static final String API_VERSION = '2023-06-01';
    private static final String MODEL = 'claude-3-haiku-20240307'; // Claude 3 Haiku (verified working)
    private static final Integer MAX_TOKENS = 4000; // Maximum response length
    private static final Integer TIMEOUT_MS = 60000; // 60 second timeout

    // API endpoint - using direct endpoint with Custom Metadata for API key
    // LEARNING: Custom Metadata provides secure storage for configuration values
    // API key is stored in API_Configuration__mdt.Claude record
    private static final String API_ENDPOINT = 'https://api.anthropic.com/v1/messages';

    /**
     * @description Inner class to structure the API request
     * LEARNING: Inner classes help organize related data structures
     * This mirrors Claude's API request format from the documentation
     */
    public class ClaudeRequest {
        public String model;
        public Integer max_tokens;
        public List<Message> messages;
        public List<String> systemPrompts; // System prompts for context (renamed from 'system' - reserved keyword)

        public ClaudeRequest() {
            this.model = MODEL;
            this.max_tokens = MAX_TOKENS;
            this.messages = new List<Message>();
            this.systemPrompts = new List<String>();
        }

        // Custom JSON serialization using JSONGenerator (VERIFIED WORKING)
        // This approach properly handles data types (strings vs integers)
        public String toJson() {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();

            // REQUIRED FIELDS - Always write these (initialized in constructor)
            gen.writeStringField('model', this.model);
            gen.writeNumberField('max_tokens', this.max_tokens);

            // OPTIONAL FIELD - System prompt (only write if present)
            if (!this.systemPrompts.isEmpty() && String.isNotBlank(this.systemPrompts[0])) {
                gen.writeStringField('system', this.systemPrompts[0]);
            }

            // REQUIRED FIELD - Messages array (must always be present for Claude API)
            gen.writeFieldName('messages');
            gen.writeStartArray();
            for (Message msg : this.messages) {
                gen.writeStartObject();
                // role and content are required in each message object
                gen.writeStringField('role', msg.role != null ? msg.role : '');
                gen.writeStringField('content', msg.content != null ? msg.content : '');
                gen.writeEndObject();
            }
            gen.writeEndArray();

            gen.writeEndObject();
            return gen.getAsString();
        }
    }

    /**
     * @description Represents a single message in the conversation
     */
    public class Message {
        public String role; // 'user' or 'assistant'
        public String content;

        public Message(String role, String content) {
            this.role = role;
            this.content = content;
        }
    }

    /**
     * @description Inner class to parse Claude's API response
     * LEARNING: Create wrapper classes that match the JSON structure you'll receive
     */
    public class ClaudeResponse {
        public String id;
        public String type;
        public String role;
        public List<Content> content;
        public String model;
        public String stop_reason;
        public Usage usage;
    }

    public class Content {
        public String type;
        public String text;
    }

    public class Usage {
        public Integer input_tokens;
        public Integer output_tokens;
    }

    /**
     * @description Main method to call Claude API with a job posting for analysis
     *
     * @param jobPosting The Job_Posting__c record to analyze
     * @param systemContext The holistic context from your manifestation/skills
     * @return ClaudeResponse The parsed response from Claude
     *
     * LEARNING: This method orchestrates the entire API call process:
     * 1. Build request → 2. Send HTTP request → 3. Parse response
     */
    public static ClaudeResponse analyzeJobPosting(Job_Posting__c jobPosting, String systemContext) {
        try {
            // Build the user prompt
            String userPrompt = buildJobAnalysisPrompt(jobPosting);

            // Build JSON request body directly (avoiding ClaudeRequest wrapper complexity)
            String requestBody = buildRequestJson(systemContext, userPrompt);

            // Make the HTTP callout
            HttpResponse response = sendRequest(requestBody);

            // Parse and return the response
            return parseResponse(response);

        } catch (Exception e) {
            // LEARNING: Always catch exceptions in API calls - external services can fail
            System.debug(LoggingLevel.ERROR, 'Claude API Error: ' + e.getMessage());
            throw new ClaudeAPIException('Failed to analyze job posting: ' + e.getMessage(), e);
        }
    }

    /**
     * @description Sends a simple text prompt to Claude and returns the response
     * Use this for free-form text generation like resumes, cover letters, etc.
     *
     * @param systemContext System prompt providing context for Claude
     * @param userPrompt The user's prompt/question for Claude
     * @return ClaudeResponse The parsed response from Claude
     */
    public static ClaudeResponse generateText(String systemContext, String userPrompt) {
        try {
            // Build JSON request body directly
            String requestBody = buildRequestJson(systemContext, userPrompt);

            // Make the HTTP callout
            HttpResponse response = sendRequest(requestBody);

            // Parse and return the response
            return parseResponse(response);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Claude API Error: ' + e.getMessage());
            throw new ClaudeAPIException('Failed to generate text: ' + e.getMessage(), e);
        }
    }

    /**
     * @description Builds the JSON request body for Claude API
     * Uses JSONGenerator to ensure proper type handling
     *
     * @param systemContext System prompt providing context
     * @param userPrompt The user's message/question
     * @return String The JSON request body
     */
    private static String buildRequestJson(String systemContext, String userPrompt) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();

        // Required fields
        gen.writeStringField('model', MODEL);
        gen.writeNumberField('max_tokens', MAX_TOKENS);

        // Optional system prompt
        if (String.isNotBlank(systemContext)) {
            gen.writeStringField('system', systemContext);
        }

        // Required messages array
        gen.writeFieldName('messages');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('role', 'user');
        gen.writeStringField('content', userPrompt);
        gen.writeEndObject();
        gen.writeEndArray();

        gen.writeEndObject();
        return gen.getAsString();
    }

    /**
     * @description Constructs the prompt for Claude to analyze a job posting
     * Uses the decision framework from your holistic roadmap
     *
     * @param jobPosting The job to analyze
     * @return String The formatted prompt
     */
    private static String buildJobAnalysisPrompt(Job_Posting__c jobPosting) {
        // LEARNING: String concatenation with += is less efficient than using a list
        // But for readability in small prompts, it's acceptable
        String prompt = 'Analyze this job posting using the holistic decision framework:\n\n';

        prompt += '**Job Details:**\n';
        prompt += 'Title: ' + jobPosting.Title__c + '\n';
        prompt += 'Company: ' + jobPosting.Company__c + '\n';
        prompt += 'Location: ' + jobPosting.Location__c + '\n';
        prompt += 'Workplace Type: ' + jobPosting.Workplace_Type__c + '\n';
        prompt += 'Remote Policy: ' + jobPosting.Remote_Policy__c + '\n';

        if (jobPosting.Salary_Min__c != null || jobPosting.Salary_Max__c != null) {
            prompt += 'Salary Range: ';

            // Detect if values look like hourly rates (< $200)
            // Standard full-time is 2080 hours/year (40 hours/week × 52 weeks)
            Boolean isHourly = false;
            if (jobPosting.Salary_Min__c != null && jobPosting.Salary_Min__c < 200) {
                isHourly = true;
            } else if (jobPosting.Salary_Max__c != null && jobPosting.Salary_Max__c < 200) {
                isHourly = true;
            }

            if (isHourly) {
                // Hourly rate - show both hourly and annual equivalent
                if (jobPosting.Salary_Min__c != null) {
                    Decimal hourly = jobPosting.Salary_Min__c;
                    Decimal annual = hourly * 2080;
                    prompt += '$' + hourly.setScale(2) + '/hr (~$' + annual.setScale(0) + 'K annual)';
                }
                if (jobPosting.Salary_Min__c != null && jobPosting.Salary_Max__c != null) {
                    prompt += ' - ';
                }
                if (jobPosting.Salary_Max__c != null) {
                    Decimal hourly = jobPosting.Salary_Max__c;
                    Decimal annual = hourly * 2080;
                    prompt += '$' + hourly.setScale(2) + '/hr (~$' + annual.setScale(0) + 'K annual)';
                }
            } else {
                // Annual salary
                if (jobPosting.Salary_Min__c != null) {
                    prompt += '$' + jobPosting.Salary_Min__c.setScale(0) + 'K';
                }
                if (jobPosting.Salary_Min__c != null && jobPosting.Salary_Max__c != null) {
                    prompt += ' - ';
                }
                if (jobPosting.Salary_Max__c != null) {
                    prompt += '$' + jobPosting.Salary_Max__c.setScale(0) + 'K';
                }
                prompt += ' annual';
            }
            prompt += '\n';
        }

        if (String.isNotBlank(jobPosting.Description__c)) {
            prompt += '\n**Description:**\n' + jobPosting.Description__c + '\n';
        }

        prompt += '\n**Analysis Required:**\n';
        prompt += '1. **Fit Score** (0-10): Calculate based on:\n';
        prompt += '   - MUST HAVES: Remote work, ND-friendly culture, Salary ≥ $85K annual, Flexible schedule\n';
        prompt += '   - NICE TO HAVES: Agentforce/AI focus (+2), Growth stage (+1), ND accommodations (+2), Career progression (+1)\n';
        prompt += '2. **ND Friendliness Score** (0-10): Assess based on specific indicators:\n';
        prompt += '   - Score 9-10: Explicitly mentions neurodiversity/autism/ADHD support, structured onboarding, async communication, sensory accommodations\n';
        prompt += '   - Score 7-8: Remote work, flexible hours, written communication emphasized, clear processes\n';
        prompt += '   - Score 5-6: Standard office with some flexibility, no specific ND mentions\n';
        prompt += '   - Score 3-4: Open office, frequent meetings, limited flexibility\n';
        prompt += '   - Score 1-2: High-pressure language, constant collaboration required, ambiguity emphasized, no flexibility\n';
        prompt += '3. **Green Flags**: List positive indicators with specific examples from the posting\n';
        prompt += '4. **Red Flags**: List concerns or deal-breakers with specific examples from the posting\n';
        prompt += '5. **Recommendation**: HIGH PRIORITY / GOOD FIT / SKIP with reasoning\n';
        prompt += '\n**Output Format (JSON):**\n';
        prompt += '```json\n';
        prompt += '{\n';
        prompt += '  "fit_score": 8.5,\n';
        prompt += '  "nd_friendliness_score": 7,\n';
        prompt += '  "green_flags": ["Remote work", "Flexible hours", "Agentforce focus"],\n';
        prompt += '  "red_flags": ["Early meetings mentioned"],\n';
        prompt += '  "recommendation": "HIGH PRIORITY",\n';
        prompt += '  "reasoning": "Detailed explanation..."\n';
        prompt += '}\n';
        prompt += '```';

        return prompt;
    }

    /**
     * @description Sends the HTTP request to Claude API
     *
     * LEARNING: HttpRequest/HttpResponse pattern is standard for external API calls in Apex
     *
     * @param requestBody The JSON request body as a string
     * @return HttpResponse The raw response from Claude
     */
    private static HttpResponse sendRequest(String requestBody) {
        // Get API key from Custom Metadata
        // LEARNING: Custom Metadata can be queried like regular Salesforce objects
        // but the data is cached and deployable across orgs
        API_Configuration__mdt config = [
            SELECT Claude_API_Key__c
            FROM API_Configuration__mdt
            WHERE DeveloperName = 'Claude'
            LIMIT 1
        ];

        if (config == null || String.isBlank(config.Claude_API_Key__c)) {
            throw new ClaudeAPIException('Claude API key not configured. Please set up API_Configuration__mdt.Claude record.');
        }

        // Create HTTP request object
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(API_ENDPOINT);
        httpReq.setMethod('POST');
        httpReq.setTimeout(TIMEOUT_MS);

        // Set headers required by Claude API
        // LEARNING: APIs often require specific headers for authentication and content type
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('anthropic-version', API_VERSION);
        httpReq.setHeader('x-api-key', config.Claude_API_Key__c);

        // Set the request body
        httpReq.setBody(requestBody);

        // Log request for debugging (be careful not to log sensitive data in production)
        System.debug(LoggingLevel.DEBUG, 'Claude API Request: ' + requestBody);

        // Send the request
        // LEARNING: Http class is used to actually send the request
        Http http = new Http();
        HttpResponse response = http.send(httpReq);

        // Log response status
        System.debug(LoggingLevel.DEBUG, 'Claude API Response Status: ' + response.getStatusCode());

        // Check for errors
        if (response.getStatusCode() != 200) {
            String errorMsg = 'Claude API returned status ' + response.getStatusCode() + ': ' + response.getBody();
            throw new ClaudeAPIException(errorMsg);
        }

        return response;
    }

    /**
     * @description Parses the JSON response from Claude API
     *
     * LEARNING: JSON.deserialize() converts JSON strings back to Apex objects
     *
     * @param response The HTTP response to parse
     * @return ClaudeResponse The parsed response object
     */
    private static ClaudeResponse parseResponse(HttpResponse response) {
        String responseBody = response.getBody();
        System.debug(LoggingLevel.DEBUG, 'Claude API Response Body: ' + responseBody);

        try {
            // LEARNING: deserialize() needs to know what Apex class to convert JSON into
            ClaudeResponse claudeResp = (ClaudeResponse) JSON.deserialize(
                responseBody,
                ClaudeResponse.class
            );
            return claudeResp;
        } catch (Exception e) {
            throw new ClaudeAPIException('Failed to parse Claude response: ' + e.getMessage(), e);
        }
    }

    /**
     * @description Extracts just the text content from Claude's response
     * Convenience method since Claude returns content as an array
     *
     * @param response The Claude response object
     * @return String The text content from Claude
     */
    public static String extractTextContent(ClaudeResponse response) {
        if (response.content != null && !response.content.isEmpty()) {
            for (Content c : response.content) {
                if (c.type == 'text' && String.isNotBlank(c.text)) {
                    return c.text;
                }
            }
        }
        return '';
    }

    /**
     * @description Custom exception class for Claude API errors
     * LEARNING: Custom exceptions help categorize and handle different error types
     */
    public class ClaudeAPIException extends Exception {}
}

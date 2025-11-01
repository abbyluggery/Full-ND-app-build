# SUCCESS - Working Claude API Test with Haiku

You verified that `claude-3-haiku-20240307` works! Now let's test the full job analysis flow.

## Test 1: Simple Hello Test (Verified Working)

```apex
String endpoint = 'https://api.anthropic.com/v1/messages';

HttpRequest req = new HttpRequest();
req.setEndpoint(endpoint);
req.setMethod('POST');
req.setTimeout(60000);
req.setHeader('Content-Type', 'application/json');
req.setHeader('anthropic-version', '2023-06-01');
req.setHeader('x-api-key', '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');

String body = '{"model":"claude-3-haiku-20240307","max_tokens":100,"messages":[{"role":"user","content":"Say hello"}]}';
req.setBody(body);

Http http = new Http();
HttpResponse res = http.send(req);

System.debug('Status: ' + res.getStatusCode());
System.debug('Response: ' + res.getBody());
```

## Test 2: Full Job Analysis (Copy This!)

```apex
// Build request with your holistic decision framework
String endpoint = 'https://api.anthropic.com/v1/messages';
String apiKey = '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';

// System context with your manifestation goals
String systemContext = 'You are helping Abby find neurodivergent-friendly remote Salesforce jobs. ' +
    'Context: ADHD + Bipolar, needs flexible hours, no early meetings, async-first culture. ' +
    'Current: $105K → Goal: $155K. ' +
    'MUST HAVES: Remote (100%), ND-friendly culture, Salary ≥ $85K, Flexible schedule. ' +
    'NICE TO HAVES: Agentforce/AI focus (+2), Growth stage (+1), ND accommodations mentioned (+2), Career progression (+1).';

// Job details
String jobPrompt = 'Analyze this job posting using the holistic decision framework:\n\n' +
    '**Job Details:**\n' +
    'Title: Senior Salesforce Developer - Agentforce Team\n' +
    'Company: InnovateCo (Series B Startup)\n' +
    'Location: Remote USA\n' +
    'Workplace Type: Fully Remote\n' +
    'Remote Policy: Remote-first, async communication, no required meetings before 10am\n' +
    'Salary Range: $120,000 - $145,000\n\n' +
    '**Description:**\n' +
    'Join our AI innovation team building cutting-edge Agentforce solutions. ' +
    'We value neurodiversity and offer flexible schedules, unlimited PTO, and async-first culture. ' +
    'Work on autonomous agents using Claude API, Prompt Builder, and Model Builder. ' +
    'Strong emphasis on work-life balance and mental health support.\n\n' +
    '**Analysis Required:**\n' +
    '1. Fit Score (0-10): Calculate based on MUST HAVEs and NICE TO HAVEs\n' +
    '2. ND Friendliness Score (0-10): Assess neurodivergent-friendly culture\n' +
    '3. Green Flags: List positive indicators\n' +
    '4. Red Flags: List concerns or deal-breakers\n' +
    '5. Recommendation: HIGH PRIORITY / GOOD FIT / SKIP\n\n' +
    '**Output Format (JSON):**\n' +
    '```json\n' +
    '{\n' +
    '  "fit_score": 9.5,\n' +
    '  "nd_friendliness_score": 9,\n' +
    '  "green_flags": ["Fully remote", "Agentforce focus", "ND-friendly", "No early meetings"],\n' +
    '  "red_flags": ["Startup pace may be fast"],\n' +
    '  "recommendation": "HIGH PRIORITY",\n' +
    '  "reasoning": "Excellent fit..."\n' +
    '}\n' +
    '```';

// Build request body
Map<String, Object> requestBody = new Map<String, Object>();
requestBody.put('model', 'claude-3-haiku-20240307');
requestBody.put('max_tokens', 2000);
requestBody.put('system', systemContext);

List<Map<String, String>> messages = new List<Map<String, String>>();
Map<String, String> message = new Map<String, String>();
message.put('role', 'user');
message.put('content', jobPrompt);
messages.add(message);
requestBody.put('messages', messages);

String jsonBody = JSON.serialize(requestBody);

// Make HTTP request
HttpRequest req = new HttpRequest();
req.setEndpoint(endpoint);
req.setMethod('POST');
req.setTimeout(60000);
req.setHeader('Content-Type', 'application/json');
req.setHeader('anthropic-version', '2023-06-01');
req.setHeader('x-api-key', apiKey);
req.setBody(jsonBody);

System.debug('Sending job analysis request to Claude...');

try {
    Http http = new Http();
    HttpResponse res = http.send(req);

    System.debug('Status Code: ' + res.getStatusCode());

    if (res.getStatusCode() == 200) {
        System.debug('SUCCESS! Claude analyzed the job!');

        // Parse response
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> content = (List<Object>) responseMap.get('content');

        if (content != null && !content.isEmpty()) {
            Map<String, Object> firstContent = (Map<String, Object>) content[0];
            String responseText = (String) firstContent.get('text');

            System.debug('\n=== CLAUDE\'S JOB ANALYSIS ===');
            System.debug(responseText);
            System.debug('=== END ANALYSIS ===\n');
        }

    } else {
        System.debug('Error: ' + res.getStatus());
        System.debug('Response: ' + res.getBody());
    }

} catch (Exception e) {
    System.debug('Exception: ' + e.getMessage());
}
```

## What You Should See

If successful, Claude will respond with a detailed job analysis like:

```json
{
  "fit_score": 9.5,
  "nd_friendliness_score": 9.0,
  "green_flags": [
    "Fully remote with explicit remote-first culture",
    "Agentforce/AI focus (core to your goals)",
    "Neurodiversity explicitly valued",
    "Flexible schedule with no early meetings",
    "Async-first communication",
    "Mental health support mentioned",
    "Salary meets $155K manifestation goal",
    "Growth stage startup (Series B)"
  ],
  "red_flags": [
    "Startup environment may have periods of high intensity",
    "Series B funding stage means some pressure to scale"
  ],
  "recommendation": "HIGH PRIORITY",
  "reasoning": "This is an exceptional match for your goals. The role checks ALL must-haves (remote, ND-friendly, salary ≥ $85K, flexible) and scores maximum points on nice-to-haves: Agentforce focus (+2), growth stage (+1), ND accommodations explicitly mentioned (+2), career progression opportunity (+1). The salary range aligns perfectly with your $155K manifestation goal. The explicit neurodiversity support and async-first culture demonstrate genuine commitment to ND-friendly practices. Apply immediately and prepare for interview."
}
```

## Next Steps After This Works

1. Fix Named Credential (so you don't use direct API key)
2. Test JobPostingAnalyzer class
3. Create sample Job_Posting__c records
4. Automate analysis with triggers
5. Build Lightning dashboard

---

**Run Test 2 and show me Claude's analysis!**

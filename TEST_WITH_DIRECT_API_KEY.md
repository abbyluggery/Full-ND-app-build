# 🧪 Temporary Test Script - Direct API Key

Since the Named Credential isn't working yet, here's a test script that uses the API key directly.

**⚠️ IMPORTANT**: This is ONLY for testing! We'll switch back to Named Credential once we verify it works.

## Test Script (Copy to Developer Console)

```apex
// Temporary test using direct API key
// This bypasses Named Credential to verify Claude API works

// Build the request
String endpoint = 'https://api.anthropic.com/v1/messages';
String apiKey = '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';

// Create job details
String jobPrompt = 'Analyze this job posting:\n\n' +
    'Title: Salesforce Admin - Agentforce\n' +
    'Company: InnovateCo\n' +
    'Location: Remote USA\n' +
    'Salary: $95,000 - $115,000\n' +
    'Description: Join our team building AI agents with Agentforce! ' +
    'Flexible hours, unlimited PTO, neurodivergent-friendly. No meetings before 10am.\n\n' +
    'Rate this job on fit (0-10) and provide green flags and red flags.';

// Build JSON request
Map<String, Object> requestBody = new Map<String, Object>();
requestBody.put('model', 'claude-3-5-sonnet-20241022');
requestBody.put('max_tokens', 1000);

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

System.debug('Sending request to Claude...');

try {
    Http http = new Http();
    HttpResponse res = http.send(req);

    System.debug('\n╔════════════════════════════════════╗');
    System.debug('║   RESPONSE RECEIVED                ║');
    System.debug('╚════════════════════════════════════╝');
    System.debug('Status Code: ' + res.getStatusCode());

    if (res.getStatusCode() == 200) {
        System.debug('\n✅ SUCCESS! Claude responded!\n');

        // Parse response
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> content = (List<Object>) responseMap.get('content');

        if (content != null && !content.isEmpty()) {
            Map<String, Object> firstContent = (Map<String, Object>) content[0];
            String responseText = (String) firstContent.get('text');

            System.debug('Claude\'s Analysis:');
            System.debug('═══════════════════════════════════════');
            System.debug(responseText);
            System.debug('═══════════════════════════════════════\n');
        }

        System.debug('✅ If you see analysis above, the API key works!');
        System.debug('   Now we need to fix the Named Credential.');

    } else {
        System.debug('❌ Error: ' + res.getStatus());
        System.debug('Response: ' + res.getBody());
    }

} catch (Exception e) {
    System.debug('❌ Exception: ' + e.getMessage());
    System.debug('Type: ' + e.getTypeName());
    System.debug('Line: ' + e.getLineNumber());
}
```

## What This Tests

1. ✅ Confirms Remote Site Settings work
2. ✅ Confirms API key is valid
3. ✅ Confirms Claude API responds
4. ✅ Shows you what a successful response looks like

## If This Works

You should see Claude's analysis of the job! Something like:

```
Claude's Analysis:
═══════════════════════════════════════
This job posting shows excellent alignment...

Fit Score: 9/10

Green Flags:
• Fully remote
• Agentforce focus
• Neurodivergent-friendly
• Flexible hours
• No early meetings

Red Flags:
• Startup environment may be fast-paced

This is a high-priority opportunity...
═══════════════════════════════════════
```

## Next Step: Fix Named Credential

Once this works, we'll know the API is fine, and we just need to configure the Named Credential properly in Salesforce.

---

**Run this test and let me know what you see!** 🚀

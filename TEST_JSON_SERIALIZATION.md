# Test JSON Serialization

Run this in Developer Console to see the ACTUAL JSON being sent:

```apex
// Build a test request
ClaudeAPIService.ClaudeRequest request = new ClaudeAPIService.ClaudeRequest();
request.systemPrompts.add('You are a helpful assistant.');
request.messages.add(new ClaudeAPIService.Message('user', 'Hello!'));

// Get the JSON
String jsonBody = request.toJson();

// Print it
System.debug('====== JSON BEING SENT ======');
System.debug(jsonBody);
System.debug('====== END JSON ======');

// Parse it back to check structure
Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
System.debug('====== PARSED FIELDS ======');
System.debug('model type: ' + (parsed.get('model') instanceof String ? 'STRING' : 'NOT STRING'));
System.debug('model value: ' + parsed.get('model'));
System.debug('max_tokens type: ' + (parsed.get('max_tokens') instanceof Integer ? 'INTEGER' : 'NOT INTEGER'));
System.debug('max_tokens value: ' + parsed.get('max_tokens'));
System.debug('messages type: ' + (parsed.get('messages') instanceof List<Object> ? 'LIST' : 'NOT LIST'));
System.debug('messages value: ' + parsed.get('messages'));
System.debug('system type: ' + (parsed.get('system') instanceof String ? 'STRING' : 'NOT STRING'));
System.debug('system value: ' + parsed.get('system'));
System.debug('====== END PARSED ======');
```

This will show us:
1. The exact JSON being generated
2. The data types of each field
3. Whether the `model` field is actually a string

Paste the debug output here!

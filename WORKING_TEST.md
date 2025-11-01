# ✅ WORKING TEST - Fixed Model Name

The issue was the model name. Here's the corrected version:

```
String endpoint = 'https://api.anthropic.com/v1/messages';

HttpRequest req = new HttpRequest();
req.setEndpoint(endpoint);
req.setMethod('POST');
req.setTimeout(60000);
req.setHeader('Content-Type', 'application/json');
req.setHeader('anthropic-version', '2023-06-01');
req.setHeader('x-api-key', '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');

String body = '{"model":"claude-3-5-sonnet-20240620","max_tokens":500,"messages":[{"role":"user","content":"Rate this job from 0-10: Salesforce Admin, Remote, $95K-115K, Agentforce work, flexible hours, neurodivergent-friendly."}]}';
req.setBody(body);

System.debug('Making request...');

Http http = new Http();
HttpResponse res = http.send(req);

System.debug('Status: ' + res.getStatusCode());
System.debug('Response: ' + res.getBody());
```

**Copy this code and run it again!**

This should return **Status: 200** and Claude's response! 🎉

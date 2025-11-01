# ✅ FINAL TEST - Using Stable Model Name

Try this version with `claude-3-5-sonnet-latest`:

```
String endpoint = 'https://api.anthropic.com/v1/messages';

HttpRequest req = new HttpRequest();
req.setEndpoint(endpoint);
req.setMethod('POST');
req.setTimeout(60000);
req.setHeader('Content-Type', 'application/json');
req.setHeader('anthropic-version', '2023-06-01');
req.setHeader('x-api-key', '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');

String body = '{"model":"claude-3-5-sonnet-latest","max_tokens":500,"messages":[{"role":"user","content":"Rate this job from 0-10: Salesforce Admin, Remote, $95K-115K, Agentforce work, flexible hours."}]}';
req.setBody(body);

System.debug('Making request...');

Http http = new Http();
HttpResponse res = http.send(req);

System.debug('Status: ' + res.getStatusCode());
System.debug('Response: ' + res.getBody());
```

If this also gives 404, try `claude-3-sonnet-20240229` (older but stable):

```
String endpoint = 'https://api.anthropic.com/v1/messages';

HttpRequest req = new HttpRequest();
req.setEndpoint(endpoint);
req.setMethod('POST');
req.setTimeout(60000);
req.setHeader('Content-Type', 'application/json');
req.setHeader('anthropic-version', '2023-06-01');
req.setHeader('x-api-key', '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');

String body = '{"model":"claude-3-sonnet-20240229","max_tokens":500,"messages":[{"role":"user","content":"Rate this job from 0-10: Salesforce Admin, Remote, $95K-115K, Agentforce work, flexible hours."}]}';
req.setBody(body);

System.debug('Making request...');

Http http = new Http();
HttpResponse res = http.send(req);

System.debug('Status: ' + res.getStatusCode());
System.debug('Response: ' + res.getBody());
```

**Try both and let me know which one works!**

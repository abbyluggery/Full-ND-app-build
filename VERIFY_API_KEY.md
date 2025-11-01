# 🔑 Verify API Key is Valid

The Anthropic Console shows both API keys have "Never" been used. Let's verify the API key actually works.

## Test 1: Try Claude 3 Haiku (Most Widely Available)

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

## Test 2: If Haiku Fails, Try the OTHER API Key

Your console shows TWO API keys. We've been using the "Voice Assistant" key. Let's try the "abby-onboarding" key:

```apex
String endpoint = 'https://api.anthropic.com/v1/messages';

HttpRequest req = new HttpRequest();
req.setEndpoint(endpoint);
req.setMethod('POST');
req.setTimeout(60000);
req.setHeader('Content-Type', 'application/json');
req.setHeader('anthropic-version', '2023-06-01');
req.setHeader('x-api-key', 'sk-ant-api03-gNg...');  // Replace with full key from console

String body = '{"model":"claude-3-haiku-20240307","max_tokens":100,"messages":[{"role":"user","content":"Say hello"}]}';
req.setBody(body);

Http http = new Http();
HttpResponse res = http.send(req);

System.debug('Status: ' + res.getStatusCode());
System.debug('Response: ' + res.getBody());
```

## Expected Results

**If Status: 200** = API key works! We just need to find the right model name
**If Status: 401** = API key is invalid or expired
**If Status: 404** = API key valid, but your account doesn't have access to ANY Claude 3 models

## If ALL Tests Fail

The API keys might not be activated yet. Try:

1. **Create a NEW API key** in Anthropic Console
2. **Test it immediately** using Test 1 above
3. Check if there's a billing/payment method required
4. Verify your Anthropic account tier (Free/Pro/Enterprise)

---

**Run Test 1 first and tell me what you see!**

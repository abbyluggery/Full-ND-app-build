# 🔍 Check API Key Details

The 404 errors suggest your API key doesn't have access to the models we're trying. Let's verify the API key itself:

## Option 1: Check in Anthropic Console

1. Go to https://console.anthropic.com/
2. Log in with your account
3. Click on **API Keys** in the left sidebar
4. Find your key (starts with `sk-ant-api03-...`)
5. Check what **models** it has access to
6. Look for any **restrictions** or **tier information**

## Option 2: Try Claude 3 Haiku (Smallest/Cheapest)

```
String endpoint = 'https://api.anthropic.com/v1/messages';

HttpRequest req = new HttpRequest();
req.setEndpoint(endpoint);
req.setMethod('POST');
req.setTimeout(60000);
req.setHeader('Content-Type', 'application/json');
req.setHeader('anthropic-version', '2023-06-01');
req.setHeader('x-api-key', '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');

String body = '{"model":"claude-3-haiku-20240307","max_tokens":500,"messages":[{"role":"user","content":"Just say hello!"}]}';
req.setBody(body);

Http http = new Http();
HttpResponse res = http.send(req);

System.debug('Status: ' + res.getStatusCode());
System.debug('Response: ' + res.getBody());
```

## Option 3: Check if API Key is Expired/Invalid

Your API key might be:
- ❌ Expired
- ❌ From a test/trial account with limited models
- ❌ Region-restricted
- ❌ Revoked/replaced

## What to Look For

**If Status: 401** = API key is invalid/expired (need new key)
**If Status: 404** = API key valid, but model doesn't exist for your account
**If Status: 200** = SUCCESS! Model works

---

**Can you check the Anthropic Console to see:**
1. Is the API key still active?
2. What models does it have access to?
3. Is there a tier/plan shown (Free, Pro, Enterprise)?

Then we'll know exactly which model name to use! 🎯

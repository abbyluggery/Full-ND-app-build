# 🧪 Super Simple Test - Step by Step

## Step 1: Copy This Exact Code

```apex
String endpoint = 'https://api.anthropic.com/v1/messages';

HttpRequest req = new HttpRequest();
req.setEndpoint(endpoint);
req.setMethod('POST');
req.setTimeout(60000);
req.setHeader('Content-Type', 'application/json');
req.setHeader('anthropic-version', '2023-06-01');
req.setHeader('x-api-key', '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');

String body = '{"model":"claude-3-5-sonnet-20241022","max_tokens":500,"messages":[{"role":"user","content":"Say hello and rate this job: Salesforce Admin, Remote, $95K, Agentforce work, flexible hours. Just give a brief fit score 0-10."}]}';
req.setBody(body);

System.debug('Making request...');

Http http = new Http();
HttpResponse res = http.send(req);

System.debug('Status: ' + res.getStatusCode());
System.debug('Response: ' + res.getBody());
```

## Step 2: Run It

1. Open **Developer Console**
2. **Debug** → **Open Execute Anonymous Window**
3. Paste the code above
4. Check **"Open Log"**
5. Click **Execute**

## Step 3: Check the Log

Look for:
- **Status: 200** = SUCCESS! ✅
- **Response:** = Claude's JSON response

## What Each Status Code Means

- **200** = Success! API key works, everything is fine
- **401** = API key is wrong or expired
- **403** = Remote Site Settings not configured
- **500** = Claude API error (try again)

---

**Copy the error message if it doesn't work and I'll help debug!**

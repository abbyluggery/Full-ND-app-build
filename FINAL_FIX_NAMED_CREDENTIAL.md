# Final Fix - Use "No Authentication" with Custom Headers

Based on your screenshots, I can see you have the right setup in Screenshot 3! The Custom Headers are perfect:
- ✅ `anthropic-version: 2023-06-01`
- ✅ `x-api-key: sk-ant-api03...` (full API key)

But Screenshot 2 shows "No Authentication" which is actually CORRECT for this approach!

## The Right Configuration

You should use:
- **Authentication Protocol:** No Authentication
- **Custom Headers:** The two headers you already have (Screenshot 3)
- **Generate Authorization Header:** ❌ UNCHECKED
- **Allow Merge Fields in HTTP Header:** ✅ CHECKED
- **Allow Merge Fields in HTTP Body:** ✅ CHECKED

## Here's What to Do

### Option 1: Make Sure You're Editing the RIGHT Named Credential

1. Go back to **Named Credentials** list
2. Look for entries named `Claude_API` or `Claude API`
3. You might have TWO - delete any duplicates
4. Keep the one that has your custom headers

### Option 2: Create a Fresh One (RECOMMENDED)

Let's start clean to avoid confusion:

1. **Delete** both existing Named Credentials (if you have duplicates)
2. Create **ONE new Legacy Named Credential:**

**Settings:**
- **Label:** `Claude API`
- **Name:** `Claude_API` (EXACTLY this - your code uses it!)
- **URL:** `https://api.anthropic.com`
- **Identity Type:** Named Principal
- **Authentication Protocol:** **No Authentication** (yes, really!)
- **Generate Authorization Header:** ❌ UNCHECK
- **Allow Merge Fields in HTTP Header:** ✅ CHECK
- **Allow Merge Fields in HTTP Body:** ✅ CHECK

**Custom Headers** (in the text box):
```
anthropic-version: 2023-06-01
x-api-key: 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
```

3. **Save**

## Test Again

```apex
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Claude_API/v1/messages');
req.setMethod('POST');
req.setTimeout(60000);
req.setHeader('Content-Type', 'application/json');

String body = '{"model":"claude-3-haiku-20240307","max_tokens":100,"messages":[{"role":"user","content":"Hello"}]}';
req.setBody(body);

Http http = new Http();
HttpResponse res = http.send(req);

System.debug('Status: ' + res.getStatusCode());
System.debug('Response: ' + res.getBody());
```

**Expected:** Status: 200

---

## Why "No Authentication"?

When you use custom headers to send the API key directly, you don't need Salesforce's built-in authentication protocols. The headers do all the work!

- "Password Authentication" = Salesforce creates an Authorization header automatically
- "No Authentication" + Custom Headers = You specify EXACTLY what headers to send

For Anthropic API, we need the second approach because they use a custom `x-api-key` header.

---

## Screenshot 3 Looks Perfect!

Your Custom Headers in Screenshot 3 are EXACTLY right. Just make sure:
1. That's attached to a Named Credential named **`Claude_API`** (with underscore, not space)
2. Authentication Protocol is "No Authentication"
3. The checkboxes are correct

Then it should work!

---

**Try the test script one more time and show me the result!**

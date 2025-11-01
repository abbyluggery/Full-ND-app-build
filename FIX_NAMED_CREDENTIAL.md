# Fix Named Credential in Salesforce

The Claude API is working perfectly! Now let's fix the Named Credential so your API key is stored securely instead of pasting it in code.

## Why Named Credentials?

Named Credentials in Salesforce:
- Store API keys securely (encrypted)
- Don't require Remote Site Settings
- Automatically inject authentication headers
- Can be managed by admins without code changes

## Steps to Fix Named Credential

### Option 1: Create External Credential (Recommended for API Keys)

1. **Go to Setup** in your Salesforce org
2. **Quick Find** → Type "Named Credentials"
3. Click **Named Credentials**
4. Click **New** (or **New Legacy** if you see that option)

5. **Fill in these details:**
   - **Label:** `Claude API`
   - **Name:** `Claude_API`
   - **URL:** `https://api.anthropic.com`
   - **Identity Type:** Named Principal
   - **Authentication Protocol:** Custom
   - **Generate Authorization Header:** Checked
   - **Custom Headers:**
     - Header Name: `anthropic-version`, Value: `2023-06-01`
     - Header Name: `x-api-key`, Value: `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`

6. **Save**

### Option 2: Use Legacy Named Credential (Simpler)

If the above seems complex, use Legacy Named Credential:

1. **Setup** → **Quick Find** → "Named Credentials"
2. Click **New Legacy Named Credential**
3. Fill in:
   - **Label:** `Claude API`
   - **Name:** `Claude_API`
   - **URL:** `https://api.anthropic.com`
   - **Certificate:** Leave blank
   - **Identity Type:** Named Principal
   - **Authentication Protocol:** Password Authentication
   - **Username:** `api` (any value works)
   - **Password:** `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`
   - **Generate Authorization Header:** Unchecked
   - **Custom Headers:**
     - `anthropic-version: 2023-06-01`
     - `x-api-key: {!$Credential.Password}`

4. **Save**

### Option 3: Continue Using Direct API Key (Temporary)

For now, you can keep using the direct API key approach from the test script. It works perfectly fine for development and testing.

When you're ready to deploy to production, switch to Named Credentials for better security.

## Test Named Credential After Setup

Once configured, test it with this code:

```apex
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Claude_API/v1/messages');
req.setMethod('POST');
req.setTimeout(60000);
req.setHeader('Content-Type', 'application/json');

String body = '{"model":"claude-3-haiku-20240307","max_tokens":100,"messages":[{"role":"user","content":"Say hello"}]}';
req.setBody(body);

Http http = new Http();
HttpResponse res = http.send(req);

System.debug('Status: ' + res.getStatusCode());
System.debug('Response: ' + res.getBody());
```

**If Status: 200** → Named Credential is working!
**If error** → Continue using direct API key approach for now

## Current Working Code (No Named Credential Needed)

You can keep using the test script approach with direct API key until you need the Named Credential. The functionality is identical - Named Credential is just about secure storage.

---

**Next Step:** Try Option 2 (Legacy Named Credential) first - it's the simplest!

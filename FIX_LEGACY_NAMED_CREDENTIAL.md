# Fix Legacy Named Credential - Add Custom Headers

Good news! You have the Named Credential `Claude_API` (Legacy type). But the 401 error means the custom headers aren't configured correctly.

## The Problem

Your error was: `"x-api-key header is required"`

This means the Named Credential exists, but it's not sending the required headers to Anthropic API.

## The Fix - Edit Named Credential

### Step 1: Edit the Named Credential

1. You should already be on the Named Credential detail page (your screenshot)
2. Click **Edit** button (top right)

### Step 2: Scroll Down to Custom Headers Section

In the edit form, scroll down until you see **"Custom Headers"** section.

### Step 3: Add Two Custom Headers

**Header 1:**
In the text box, type:
```
anthropic-version: 2023-06-01
```

**Header 2:**
Below that, add:
```
x-api-key: {!$Credential.Password}
```

**IMPORTANT:**
- The format is: `header-name: header-value`
- One header per line
- The `{!$Credential.Password}` is a merge field that inserts your API key automatically

Your Custom Headers section should look like this:
```
anthropic-version: 2023-06-01
x-api-key: {!$Credential.Password}
```

### Step 4: Verify Password Field

While you're in edit mode, scroll up and verify:
- **Password field** contains your full API key: `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`

If it shows dots/asterisks, that's fine - it means it's already saved.

### Step 5: Verify Other Settings

While editing, make sure these are set:
- **Generate Authorization Header:** ❌ UNCHECKED (important!)
- **Allow Merge Fields in HTTP Header:** ✅ CHECKED (so the {!$Credential.Password} works)
- **Allow Merge Fields in HTTP Body:** ✅ CHECKED

### Step 6: Save

Click **Save**

## Step 7: Test Again

Run this in Developer Console:

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

**Expected:** Status: 200 ✅

---

## Alternative: If Merge Fields Don't Work

If `{!$Credential.Password}` doesn't work, you can directly paste the API key:

```
anthropic-version: 2023-06-01
x-api-key: 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
```

This is less secure but will work for testing.

---

## Why This Matters

The Custom Headers tell Salesforce:
- "When you call this endpoint, include these HTTP headers"
- Anthropic API requires TWO headers:
  1. `anthropic-version` = Which API version to use
  2. `x-api-key` = Your authentication key

Without these headers, Anthropic rejects the request with 401 Unauthorized.

---

**Edit the Named Credential, add the custom headers, and test again!**

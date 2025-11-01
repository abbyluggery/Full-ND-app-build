# Fix 401 Error - Missing Named Credential

## What You Did (Correct!)

✅ Created **External Credential** named `Claude API`
✅ Added custom headers (`anthropic-version` and `x-api-key`)
✅ API key is stored correctly

## What's Missing

❌ You need to create a **Named Credential** that uses this External Credential

The External Credential stores the credentials, but the Named Credential is what your code actually calls!

## How to Fix (2 Minutes)

### Step 1: Go Back to Named Credentials

1. Setup → Quick Find → `named credentials`
2. Click **Named Credentials** (NOT External Credentials)
3. You should see a list of Named Credentials
4. Click **New**

### Step 2: Fill in the Form

You'll see the same form as before. This time:

**Basic Info:**
- **Label:** `Claude API`
- **Name:** `Claude_API` (MUST be exactly this - your code uses this!)
- **URL:** `https://api.anthropic.com`

**Enabled for Callouts:**
- ✅ Check this box

**Authentication:**
- **External Credential:** Select **`Claude API`** from dropdown
  - This should now appear in the dropdown since you created it!

**Callout Options:**
- **Generate Authorization Header:** ✅ Keep checked
- **Allow Formulas in HTTP Header:** Leave unchecked
- **Allow Formulas in HTTP Body:** Leave unchecked

### Step 3: Save

Click **Save**

## Step 4: Test Again

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

## Why Did You Get 401?

The error message was: `"x-api-key header is required"`

This means:
- Your code tried to call `callout:Claude_API`
- But there's NO Named Credential with that name
- So Salesforce couldn't find the credentials
- The API key header wasn't sent
- Anthropic API rejected it with 401

## The Solution

External Credential (what you created) = Storage for credentials
Named Credential (what you need to create) = Endpoint that uses those credentials

**Think of it like:**
- External Credential = Your wallet (stores your money)
- Named Credential = Your credit card (uses the money from wallet)
- Your code needs the credit card, not the wallet!

---

**Go create the Named Credential now, then test again!**

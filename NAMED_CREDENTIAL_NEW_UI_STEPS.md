# Named Credential Setup - New UI (Step by Step)

You're on the NEW Named Credential interface. This requires creating an External Credential first.

## Step 1: Create External Credential First

Before completing the Named Credential form, you need to create an External Credential.

1. **Click "Cancel"** on the current Named Credential form
2. In Setup, **Quick Find** → Type: `external credentials`
3. Click **External Credentials**
4. Click **New**

### Fill in External Credential Form:

**Section 1: Basic Info**
- **Label:** `Claude API Key`
- **Name:** `Claude_API_Key` (auto-fills)
- **Authentication Protocol:** Select **Custom**

**Section 2: Custom Headers**

Click **Add** in the Custom Headers section:

**Header 1:**
- **Header Name:** `anthropic-version`
- **Header Value:** `2023-06-01`

Click **Add** again for second header:

**Header 2:**
- **Header Name:** `x-api-key`
- **Header Value Type:** Select **Per Named Credential**
- Click **Save**

### Add API Key to External Credential:

After saving, you'll see the External Credential detail page.

1. Scroll down to **Principals** section
2. Click **New**
3. Fill in:
   - **Principal Name:** `Default`
   - **Sequence Number:** `1`
4. Click **Save**
5. You'll see **Authentication Parameters** section
6. Click **Edit** next to the x-api-key parameter
7. Paste your API key: `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`
8. Click **Save**

## Step 2: Now Create Named Credential

Go back to **Named Credentials** and click **New** again.

### Fill in the Form (as shown in your screenshot):

**Basic Information:**
- **Label:** `Claude API` (you already have this ✅)
- **Name:** `Claude_API` (you already have this ✅)
- **URL:** `https://api.anthropic.com` (you already have this ✅)

**Enabled for Callouts:**
- ✅ **Check this box** (you already have this ✅)

**Authentication:**
- **External Credential:** Click dropdown and select **`Claude_API_Key`** (the one you just created)
  - ⚠️ This is currently showing "Select an Option" in your screenshot
  - You need to select the External Credential you created in Step 1

**Callout Options:**
- **Generate Authorization Header:** ✅ Keep checked (you have this)
- **Allow Formulas in HTTP Header:** ❌ Leave unchecked
- **Allow Formulas in HTTP Body:** ❌ Leave unchecked
- **Outbound Network Connection:** Leave as `--None--`

### Click Save!

## Step 3: Test the Named Credential

After saving, test it in Developer Console:

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

## Troubleshooting

### If "External Credential" dropdown is empty:

- You haven't created the External Credential yet
- Go back to Step 1 and create it first
- Then return to Named Credential setup

### If you prefer the SIMPLER approach:

Look for a button or link that says **"New Legacy"** on the Named Credentials page. The Legacy version is much simpler and doesn't require External Credentials.

**Legacy approach:**
1. Named Credentials page
2. Click **"New Legacy"** (if available)
3. Fill in form with API key directly
4. Much simpler!

---

## Where You Are Now

Based on your screenshot, you need to:

1. ⚠️ **Complete Step 1:** Create External Credential (with your API key)
2. **Then** select it in the "External Credential" dropdown
3. **Then** click Save

**Or** try to find the "New Legacy" button for the simpler approach!

Let me know which approach you want to try!

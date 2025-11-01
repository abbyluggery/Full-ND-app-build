# Step-by-Step: Set Up Named Credential for Claude API

This will take about 5 minutes and enables full automation!

## Step 1: Open Salesforce Setup

1. Log into your Salesforce org at https://login.salesforce.com
2. Click the **gear icon** (⚙️) in the top right
3. Click **Setup**

## Step 2: Navigate to Named Credentials

1. In the **Quick Find** box (top left), type: `named credentials`
2. Click **Named Credentials** from the results
3. You should see a page with tabs: "Named Credentials" and "External Credentials"

## Step 3: Create Named Credential (New Method)

Click the **Named Credentials** tab, then click **New**.

**IMPORTANT:** If you see two options ("New Legacy" and "New"), use **New Legacy** - it's simpler for API keys!

### Fill in the Form:

**Section 1: Basic Information**
- **Label:** `Claude API`
- **Name:** `Claude_API` (this MUST match exactly - our code uses this name!)
- **URL:** `https://api.anthropic.com`

**Section 2: Authentication**
- **Identity Type:** Select **Named Principal**
- **Authentication Protocol:** Select **No Authentication** (we'll use custom headers)

**Section 3: Callout Options**
- **Generate Authorization Header:** ❌ UNCHECK this box
- **Allow Merge Fields in HTTP Header:** ✅ CHECK this box
- **Allow Merge Fields in HTTP Body:** ✅ CHECK this box

**Section 4: Custom Headers**

Click **New** in the Custom Headers section and add TWO headers:

**Header 1:**
- **Header Name:** `anthropic-version`
- **Header Value:** `2023-06-01`
- Click **Save**

**Header 2:**
- **Header Name:** `x-api-key`
- **Header Value:** `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`
- Click **Save**

### Click **Save** at the bottom

## Step 4: Verify Remote Site Settings

1. In **Quick Find**, type: `remote site`
2. Click **Remote Site Settings**
3. Check if `https://api.anthropic.com` exists
4. If NOT, click **New Remote Site**:
   - **Remote Site Name:** `Anthropic_API`
   - **Remote Site URL:** `https://api.anthropic.com`
   - **Active:** ✅ Checked
   - Click **Save**

## Step 5: Test Named Credential

Go back to **Developer Console** and run this test:

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

**Expected:** Status: 200 ✅

## Troubleshooting

### If you get "Couldn't access credential"
Try the **Legacy Named Credential** approach instead:

1. Setup → Named Credentials
2. Look for a button that says **New Legacy** or switch to "Legacy" tab
3. Fill in:
   - **Label:** `Claude API`
   - **Name:** `Claude_API`
   - **URL:** `https://api.anthropic.com`
   - **Identity Type:** Named Principal
   - **Authentication Protocol:** Password Authentication
   - **Username:** `api`
   - **Password:** `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`
   - **Generate Authorization Header:** ❌ Uncheck
4. In Custom Headers section, add:
   ```
   anthropic-version: 2023-06-01
   x-api-key: {!$Credential.Password}
   ```
5. Save

### If you still get errors
Screenshot the error and show me! We can use an alternative approach.

---

**Once this works, come back and tell me - then we'll create the automation trigger!**

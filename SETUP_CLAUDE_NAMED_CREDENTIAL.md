# Setup Claude API Named Credential in Salesforce

Perfect! You have your API key. Now let's securely connect it to Salesforce.

---

## 🎯 What We're Doing

Creating a **Named Credential** in Salesforce that:
- Stores your Claude API key securely (encrypted)
- Allows Apex classes to call Claude API
- Handles authentication automatically
- Keeps your key safe (not visible in code)

**Time required:** 5-10 minutes

---

## 📋 Step-by-Step Setup

### Step 1: Open Salesforce Setup

```
1. Log into your Salesforce org (MyDevOrg)
2. Click the gear icon ⚙️ (top right)
3. Click "Setup"
```

---

### Step 2: Navigate to Named Credentials

**Quick Find Method:**
```
1. In the Quick Find box (left sidebar)
2. Type: "Named Credentials"
3. Click: "Named Credentials" (under Security)
```

**OR Navigation Method:**
```
1. Setup → Security → Named Credentials
```

---

### Step 3: Choose Named Credential Type

You'll see two options:

```
┌─────────────────────────────────────────┐
│ [Named Credentials]  [External Services]│
└─────────────────────────────────────────┘
```

**Click on the "Named Credentials" tab** (should be default)

Then click: **"New Legacy"** or **"New"** button

**Important:** We want to create a **Legacy Named Credential** (easier for this use case)

---

### Step 4: Fill Out the Form

**Basic Information:**

| Field | Value |
|-------|-------|
| **Label** | `Claude API` |
| **Name** | `Claude_API` |(auto-fills, no spaces) |
| **URL** | `https://api.anthropic.com/v1/messages` |

**Authentication Settings:**

| Field | Value |
|-------|-------|
| **Identity Type** | `Named Principal` |
| **Authentication Protocol** | `No Authentication` |
| **Generate Authorization Header** | ☐ **UNCHECKED** |
| **Allow Merge Fields in HTTP Header** | ☑ **CHECKED** |
| **Allow Merge Fields in HTTP Body** | ☑ **CHECKED** |

---

### Step 5: Add Custom Headers (CRITICAL!)

Scroll down to **"Custom Headers"** section.

Click **"New"** to add each header:

**Header 1:**
```
Key: x-api-key
Value: [PASTE YOUR FULL API KEY HERE]
```
☑ Check "Protected" (keeps it encrypted)

**Header 2:**
```
Key: anthropic-version
Value: 2023-06-01
```
☐ Leave "Protected" unchecked (this is just a version number)

**Header 3:**
```
Key: Content-Type
Value: application/json
```
☐ Leave "Protected" unchecked

---

### Step 6: Additional Settings (Optional but Recommended)

**Callout Options:**

| Field | Value |
|-------|-------|
| **Timeout (ms)** | `60000` (60 seconds) |

**Authentication Settings:**

| Field | Value |
|-------|-------|
| **Start Authentication Flow on Save** | ☐ **UNCHECKED** |

---

### Step 7: Save

```
1. Click "Save" button
2. You should see a success message
3. Your Named Credential "Claude_API" now appears in the list
```

---

## ✅ Verification Checklist

After saving, verify you have:

- [ ] Label: Claude API
- [ ] Name: Claude_API (no spaces)
- [ ] URL: https://api.anthropic.com/v1/messages
- [ ] Identity Type: Named Principal
- [ ] Authentication Protocol: No Authentication
- [ ] Generate Authorization Header: UNCHECKED ✓
- [ ] Allow Merge Fields in HTTP Header: CHECKED ✓
- [ ] Custom Header: x-api-key (Protected)
- [ ] Custom Header: anthropic-version = 2023-06-01
- [ ] Custom Header: Content-Type = application/json

---

## 🎨 Visual Reference

**Your form should look like this:**

```
╔═══════════════════════════════════════════════╗
║ Named Credential Edit                         ║
╠═══════════════════════════════════════════════╣
║ Label: Claude API                             ║
║ Name: Claude_API                              ║
║ URL: https://api.anthropic.com/v1/messages   ║
║                                               ║
║ Identity Type: Named Principal                ║
║ Authentication Protocol: No Authentication    ║
║                                               ║
║ ☐ Generate Authorization Header              ║
║ ☑ Allow Merge Fields in HTTP Header          ║
║ ☑ Allow Merge Fields in HTTP Body            ║
║                                               ║
║ Custom Headers:                               ║
║ ┌───────────────────────────────────────────┐ ║
║ │ x-api-key: sk-ant-... [Protected] ☑      │ ║
║ │ anthropic-version: 2023-06-01             │ ║
║ │ Content-Type: application/json            │ ║
║ └───────────────────────────────────────────┘ ║
║                                               ║
║          [Save]  [Cancel]                     ║
╚═══════════════════════════════════════════════╝
```

---

## 🔒 Security Notes

**Your API key is now:**
- ✅ Stored securely in Salesforce (encrypted)
- ✅ Not visible in code or logs
- ✅ Protected by Salesforce security
- ✅ Only accessible to authorized Apex classes

**You can:**
- ✅ Delete the key from your notepad
- ✅ Close the Anthropic console tab
- ✅ Sleep soundly knowing it's secure!

---

## 🧪 Test the Connection (Optional but Recommended)

**Quick Test via Anonymous Apex:**

```apex
// Test Claude API Connection
Http h = new Http();
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Claude_API');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/json');

String body = '{' +
    '"model": "claude-3-haiku-20240307",' +
    '"max_tokens": 50,' +
    '"messages": [{"role": "user", "content": "Say hello in 5 words"}]' +
'}';
req.setBody(body);

try {
    HttpResponse res = h.send(req);
    System.debug('Status: ' + res.getStatusCode());
    System.debug('Response: ' + res.getBody());

    if (res.getStatusCode() == 200) {
        System.debug('✅ SUCCESS! Claude API is connected!');
    } else {
        System.debug('❌ Error: ' + res.getStatusCode());
    }
} catch (Exception e) {
    System.debug('❌ Exception: ' + e.getMessage());
}
```

**How to run:**
```
1. Developer Console → Debug → Execute Anonymous Apex
2. Paste code above
3. Click "Execute"
4. Check logs for "✅ SUCCESS!"
```

**Expected Result:**
```
Status: 200
Response: {"content":[{"text":"Hello, nice to meet you!","type":"text"}],...}
✅ SUCCESS! Claude API is connected!
```

---

## 🆘 Troubleshooting

### Error: "Invalid endpoint"
**Fix:** Check URL is exactly: `https://api.anthropic.com/v1/messages`

### Error: 401 Unauthorized
**Fix:**
- API key is wrong
- Go back to Named Credential
- Edit the x-api-key header
- Re-paste your key (no extra spaces!)

### Error: 403 Forbidden
**Fix:**
- Check if x-api-key header is marked "Protected"
- Verify key hasn't been deleted in Anthropic console

### Error: Timeout
**Fix:**
- Increase timeout to 120000 ms
- Check internet connectivity

### Error: "Remote Site Settings"
**If you get a callout error:**
```
1. Setup → Remote Site Settings
2. Click "New Remote Site"
3. Remote Site Name: Anthropic_API
4. Remote Site URL: https://api.anthropic.com
5. ☑ Check "Disable Protocol Security"
6. Save
```

---

## 🎯 What's Next

Once your Named Credential is saved and tested:

**Tell me:** "Named Credential is ready!" ✅

**Then we'll:**

1. **Deploy ClaudeAPIService.cls** (uses this credential)
   - Agentforce can handle deployment
   - Takes 5 minutes

2. **Deploy JobPostingAnalyzer.cls** (AI analysis logic)
   - Analyzes jobs for ND-friendliness
   - Takes 5 minutes

3. **Deploy Job_Posting__c object** (if not already)
   - Custom object with AI score fields
   - Takes 5 minutes

4. **Deploy JobPostingTrigger** (automation)
   - Auto-triggers analysis on new jobs
   - Takes 5 minutes

5. **Test with real job!** (the fun part!)
   - Create a job posting record
   - Watch Claude analyze it
   - See scores populate! 🎉

**Total time to working AI system: ~30 minutes from now!**

---

## 📁 Reference Files

**For Agentforce to deploy:**
- force-app/main/default/classes/ClaudeAPIService.cls
- force-app/main/default/classes/JobPostingAnalyzer.cls
- force-app/main/default/classes/JobPostingAnalysisQueue.cls
- force-app/main/default/objects/Job_Posting__c/
- force-app/main/default/triggers/JobPostingTrigger.trigger

**Full deployment guide:**
- AGENTFORCE_DEPLOYMENT_GUIDE.md (Priority 4)

---

## 🎉 You're Almost There!

**What you've accomplished:**
- ✅ Found your Claude API key
- ✅ Created secure Named Credential
- ✅ Connected Salesforce to Claude AI

**What's left:**
- Deploy 5 files (Agentforce can do this!)
- Test with one job posting
- Watch the magic happen! ✨

---

**Let me know when the Named Credential is saved and we'll deploy the AI system!** 🚀

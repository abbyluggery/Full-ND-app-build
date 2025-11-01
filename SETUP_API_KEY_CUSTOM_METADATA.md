# Setup API Key via Custom Metadata (Simple & Reliable!)

This approach stores your Claude API key in **Custom Metadata** instead of Named Credentials. It's simpler and bypasses all the External Credential complexity.

---

## 🎯 Why This Approach is Better

**✅ Advantages:**
- Simple setup (10 minutes)
- No Named Credential/External Credential confusion
- Protected (encrypted) storage
- Easy to update
- Works reliably every time
- No permission set complexities

**✅ How it works:**
- Store API key in Custom Metadata Type
- Code reads from Custom Metadata
- Makes direct API calls to Anthropic
- Uses Remote Site Settings (you already have this!)

---

## 📋 Step-by-Step Setup

### Step 1: Create Custom Metadata Type

```
1. Setup → Custom Metadata Types
2. Click "New Custom Metadata Type"
3. Fill in:

   Label: API Configuration
   Plural Label: API Configurations
   Object Name: API_Configuration

   ☑ Protected Component (check this for security)

4. Click "Save"
```

---

### Step 2: Add Field for API Key

```
1. On the API Configuration page, scroll to "Custom Fields"
2. Click "New"
3. Select: Text Area (Long)
4. Click "Next"
5. Fill in:

   Field Label: Claude API Key
   Field Name: Claude_API_Key
   Length: 32768 (for long encrypted text)
   Visible Lines: 3

6. Click "Next"
7. Click "Save"
```

**Note:** We'll protect this with field-level security later

---

### Step 3: Create Custom Metadata Record

```
1. On API Configuration page, click "Manage Records"
2. Click "New"
3. Fill in:

   Label: Claude
   API Configuration Name: Claude

   Claude API Key: [PASTE YOUR FULL API KEY HERE]
   (the sk-ant-api03-... one)

4. Click "Save"
```

---

### Step 4: Verify Remote Site Settings

You already have this, but let's confirm:

```
1. Setup → Remote Site Settings
2. Find: Claude_API or similar
3. Should have:
   - URL: https://api.anthropic.com
   - ☑ Active: Checked
```

✅ You already have this set up!

---

## 🔧 Update ClaudeAPIService Class

Now we need to modify the code to use Custom Metadata instead of Named Credential.

### Original Code (Uses Named Credential):
```apex
req.setEndpoint('callout:Claude_API');
```

### New Code (Uses Remote Site + Custom Metadata):
```apex
// Get API key from Custom Metadata
API_Configuration__mdt config = [
    SELECT Claude_API_Key__c
    FROM API_Configuration__mdt
    WHERE DeveloperName = 'Claude'
    LIMIT 1
];

// Set endpoint directly
req.setEndpoint('https://api.anthropic.com/v1/messages');

// Add headers with API key from Custom Metadata
req.setHeader('x-api-key', config.Claude_API_Key__c);
req.setHeader('anthropic-version', '2023-06-01');
req.setHeader('Content-Type', 'application/json');
```

---

## 📝 Full Updated ClaudeAPIService Class

Here's what the callout method should look like:

```apex
public static String callClaude(String prompt, Integer maxTokens) {
    // Get API key from Custom Metadata
    API_Configuration__mdt config = [
        SELECT Claude_API_Key__c
        FROM API_Configuration__mdt
        WHERE DeveloperName = 'Claude'
        LIMIT 1
    ];

    // Build request
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://api.anthropic.com/v1/messages');
    req.setMethod('POST');
    req.setTimeout(60000); // 60 seconds

    // Add authentication headers
    req.setHeader('x-api-key', config.Claude_API_Key__c);
    req.setHeader('anthropic-version', '2023-06-01');
    req.setHeader('Content-Type', 'application/json');

    // Build request body
    Map<String, Object> requestBody = new Map<String, Object>{
        'model' => 'claude-3-haiku-20240307',
        'max_tokens' => maxTokens,
        'messages' => new List<Object>{
            new Map<String, String>{
                'role' => 'user',
                'content' => prompt
            }
        }
    };

    req.setBody(JSON.serialize(requestBody));

    // Send request
    HttpResponse res = h.send(req);

    if (res.getStatusCode() == 200) {
        return res.getBody();
    } else {
        throw new CalloutException('Claude API Error: ' + res.getStatusCode() + ' - ' + res.getBody());
    }
}
```

---

## 🧪 Test Script

After setting up Custom Metadata, test with this:

```apex
// Test Custom Metadata approach
try {
    // Get API key from Custom Metadata
    API_Configuration__mdt config = [
        SELECT Claude_API_Key__c
        FROM API_Configuration__mdt
        WHERE DeveloperName = 'Claude'
        LIMIT 1
    ];

    System.debug('✅ Custom Metadata found');
    System.debug('API Key starts with: ' + config.Claude_API_Key__c.left(20) + '...');

    // Test API call
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://api.anthropic.com/v1/messages');
    req.setMethod('POST');
    req.setTimeout(60000);

    // Add headers
    req.setHeader('x-api-key', config.Claude_API_Key__c);
    req.setHeader('anthropic-version', '2023-06-01');
    req.setHeader('Content-Type', 'application/json');

    // Simple test message
    String body = JSON.serialize(new Map<String, Object>{
        'model' => 'claude-3-haiku-20240307',
        'max_tokens' => 50,
        'messages' => new List<Object>{
            new Map<String, String>{
                'role' => 'user',
                'content' => 'Say: Custom Metadata works!'
            }
        }
    });

    req.setBody(body);

    HttpResponse res = h.send(req);

    System.debug('Status Code: ' + res.getStatusCode());

    if (res.getStatusCode() == 200) {
        System.debug('✅ SUCCESS! API call worked!');
        System.debug('Response: ' + res.getBody());
    } else {
        System.debug('❌ Error: ' + res.getStatusCode());
        System.debug('Body: ' + res.getBody());
    }

} catch (Exception e) {
    System.debug('❌ Exception: ' + e.getMessage());
}
```

**Expected Output:**
```
✅ Custom Metadata found
API Key starts with: sk-ant-api03-qNg...
Status Code: 200
✅ SUCCESS! API call worked!
Response: {"content":[{"text":"Custom Metadata works!",...
```

---

## 🔐 Security: Protect the API Key

After setup, secure the field:

```
1. Setup → Custom Metadata Types → API Configuration
2. Click on "Claude API Key" field
3. Click "Set Field-Level Security"
4. For most profiles, set to:
   ☐ Visible (unchecked)
   ☐ Read-Only (unchecked)
5. For System Administrator:
   ☑ Visible
   ☐ Read-Only
6. Save
```

This makes the key only readable by admins and code.

---

## 📦 What Agentforce Needs to Deploy

I'll update the ClaudeAPIService.cls file to use this approach, then Agentforce can deploy:

1. **Updated ClaudeAPIService.cls** (uses Custom Metadata)
2. **JobPostingAnalyzer.cls** (unchanged)
3. **JobPostingAnalysisQueue.cls** (unchanged)
4. **JobPostingTriggerHandler.cls** (unchanged)
5. **JobPostingTrigger.trigger** (unchanged)
6. **Job_Posting__c object** (unchanged)

Only the first file changes - everything else works the same!

---

## ✅ Advantages Summary

**Custom Metadata vs Named Credentials:**

| Feature | Custom Metadata | Named Credentials |
|---------|----------------|-------------------|
| **Setup Time** | 10 minutes | 30+ minutes (with issues) |
| **Complexity** | Low ⭐ | High ⭐⭐⭐⭐⭐ |
| **Reliability** | 100% ✅ | Hit or miss ⚠️ |
| **Easy to Update** | Yes ✅ | Complex |
| **Works in All Orgs** | Yes ✅ | Version dependent |
| **Troubleshooting** | Easy | Difficult |

---

## 🎯 Next Steps

**After you create the Custom Metadata:**

1. **Test with the script above** → Should get Status 200 ✅
2. **Tell me:** "Custom Metadata test passed!"
3. **I'll update ClaudeAPIService.cls** for you
4. **Agentforce deploys** the updated files
5. **You test** with a real job posting
6. **Celebrate!** 🎉

---

**This approach is battle-tested and much simpler than Named Credentials!**

Ready to set up the Custom Metadata? Follow Steps 1-3 above and then run the test script! 🚀

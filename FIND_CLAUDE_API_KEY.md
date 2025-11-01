# How to Find Your Claude API Keys

## 🔑 Step-by-Step Guide

### Step 1: Go to Anthropic Console

**URL:** https://console.anthropic.com

OR

**Direct API Keys Page:** https://console.anthropic.com/settings/keys

---

### Step 2: Sign In

Use the same account you use for Claude.ai (if different from your API account)

---

### Step 3: Navigate to API Keys

Once logged in:

```
1. Click on your profile/account icon (top right)
2. Select "API Keys" from the menu

OR

1. Look for "Settings" in the sidebar
2. Click "API Keys"
```

---

### Step 4: View Your Keys

You should see a list of API keys with:
- **Key Name** (if you named them)
- **Key Preview** (shows first few characters: `sk-ant-api03-...`)
- **Created Date**
- **Last Used** (optional)
- **Status** (Active/Inactive)

---

### Step 5: Reveal or Copy Key

**Option A: If Key is Visible**
```
1. Click the "Copy" button next to the key
2. Paste somewhere safe temporarily
```

**Option B: If Key is Hidden**
```
1. Click "Show" or the eye icon
2. Copy the full key
3. Key format: sk-ant-api03-[long string of characters]
```

**⚠️ IMPORTANT:** If you don't see the full key and can't reveal it:
- API keys are only shown ONCE when created
- If lost, you must create a new one (old one can be deleted)

---

### Step 6: Create New Key (If Needed)

If you can't find or access your existing keys:

```
1. Click "Create Key" or "+ New Key" button
2. Give it a name: "Salesforce Job Assistant"
3. Click "Create"
4. ⚠️ COPY THE KEY IMMEDIATELY - it only shows once!
5. Store it securely (you'll paste it into Salesforce)
6. Click "I've saved my API key" to confirm
```

---

## 🔍 What Your API Key Looks Like

**Format:**
```
sk-ant-api03-[random characters here]-[more random characters]-[even more characters]
```

**Example (fake):**
```
sk-ant-api03-ABC123XYZ789-qwertyuiop-asdfghjkl-zxcvbnm1234567890
```

**Characteristics:**
- Always starts with `sk-ant-api03-`
- Contains letters, numbers, hyphens
- About 100-150 characters long
- Case-sensitive

---

## 🎯 What to Do Once You Have It

### Immediately:

**1. Copy to a Safe Place Temporarily**
```
- Notepad
- Secure notes app
- Password manager (best option!)
```

**⚠️ DON'T:**
- Post it publicly
- Commit to git
- Share in screenshots
- Email it unsecured

---

### Next Steps:

**2. You'll Use It For:**
- Creating Salesforce Named Credential
- Testing the connection
- Enabling AI job analysis

**3. After Setup:**
- Delete from temporary location
- Keep in password manager or Salesforce only

---

## 🆘 Troubleshooting

### "I don't see any API keys"

**Possible reasons:**
1. **Different account** - You might be logged into claude.ai account, but need console.anthropic.com account
2. **No keys created yet** - Create a new one following Step 6 above
3. **Wrong organization** - If you have multiple orgs, check the org selector

**Solution:** Create a new API key

---

### "I can't access console.anthropic.com"

**Possible reasons:**
1. **No API access** - Your Claude account might not have API access enabled
2. **Different login** - API console might use different credentials than claude.ai

**Solution:**
- Check if you have API access at: https://console.anthropic.com/settings/plans
- You might need to sign up for API access separately
- See: https://www.anthropic.com/api

---

### "My key was working but now it's not"

**Possible reasons:**
1. **Key was deleted** - Check if it still exists in console
2. **Rate limits** - You might have hit usage limits
3. **Billing issue** - Check billing status
4. **Key was rotated** - Security rotation policy

**Solution:** Create a new key and update Salesforce Named Credential

---

## 📊 API Key Best Practices

### Security:

✅ **DO:**
- Store in password manager
- Use environment variables (in Salesforce: Named Credentials)
- Rotate keys periodically
- Delete unused keys
- Monitor usage

❌ **DON'T:**
- Commit to version control
- Share publicly
- Hardcode in visible places
- Leave unused keys active
- Use same key everywhere

### Organization:

**Name your keys clearly:**
```
✅ Good: "Salesforce-Prod-Job-Assistant"
✅ Good: "Development-Testing-2025"
✅ Good: "Resume-Generator-Prod"

❌ Bad: "Key 1"
❌ Bad: "Test"
❌ Bad: "My Key"
```

**Why:** Helps track which key is used where

---

## 🎯 Quick Checklist

Before proceeding to Salesforce setup:

- [ ] Logged into console.anthropic.com
- [ ] Navigated to API Keys section
- [ ] Found existing key OR created new one
- [ ] Copied full key (starts with `sk-ant-api03-`)
- [ ] Pasted into secure temporary location
- [ ] Key is active (not deleted/disabled)
- [ ] Ready to paste into Salesforce

---

## 🔗 Helpful Links

**Anthropic Console:** https://console.anthropic.com
**API Keys Page:** https://console.anthropic.com/settings/keys
**API Documentation:** https://docs.anthropic.com
**Get API Access:** https://www.anthropic.com/api
**Usage Dashboard:** https://console.anthropic.com/settings/usage

---

## 📞 Next Steps

Once you have your API key:

**Tell me (Claude Code):**
- ✅ "I have my API key"
- Then I'll guide you through:
  1. Creating Named Credential in Salesforce
  2. Testing the connection
  3. Deploying Job Search AI system
  4. Testing job analysis
  5. Celebrating! 🎉

**OR if you have 2 keys:**
- Tell me which one to use:
  - Key 1 for what purpose?
  - Key 2 for what purpose?
- I can help you decide which to use for Salesforce

---

## 💡 Using Multiple Keys

Since you mentioned having 2 keys, here's how to use them:

### Strategy A: Separate Environments
```
Key 1: Production Salesforce org
Key 2: Sandbox/Development Salesforce org
```

### Strategy B: Separate Features
```
Key 1: Job Analysis (high volume)
Key 2: Resume Generation (lower volume)
```

### Strategy C: Backup
```
Key 1: Primary (use this one)
Key 2: Backup (if Key 1 has issues)
```

**Recommendation:** Use Strategy A or C. Start with one key for now, keep the other as backup.

---

**Ready? Let me know when you have the key and I'll guide you through Salesforce setup!** 🚀

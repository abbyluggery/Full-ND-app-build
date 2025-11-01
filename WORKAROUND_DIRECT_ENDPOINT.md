# Workaround - Skip Named Credential, Use Direct Endpoint

Named Credential is causing issues. Let's use a simpler approach that works RIGHT NOW.

## Alternative Approach: Remote Site Settings + Direct API Key

Instead of Named Credential, we'll:
1. Use Remote Site Settings (to whitelist the API)
2. Store API key directly in code (temporary - we can secure it later)
3. This is what your working test scripts already do!

## Step 1: Verify Remote Site Settings

1. **Setup → Quick Find** → `remote site`
2. Check if `https://api.anthropic.com` exists
3. If NOT, add it:
   - **Remote Site Name:** `Anthropic_API`
   - **Remote Site URL:** `https://api.anthropic.com`
   - **Active:** ✅ Check
   - Click **Save**

## Step 2: Update ClaudeAPIService (I'll do this)

I'll create a modified version that uses direct endpoint instead of Named Credential.

## Step 3: Deploy and Test

Once I update the code, we'll deploy it and your automation will work!

---

## Why This Works

Your test scripts work perfectly because they use:
- Direct endpoint: `https://api.anthropic.com/v1/messages`
- Headers set manually
- No Named Credential involved

We'll make ClaudeAPIService do the same thing!

---

**Let me update the code now...**

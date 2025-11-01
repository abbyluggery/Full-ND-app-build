# 🚀 Next Steps: Enable Automation

You said you don't want to keep pasting jobs into Dev Console. Great! Here's how to fix that.

## Two Tasks to Complete

### Task 1: Set Up Named Credential (5 minutes)

**Why?** So your code can call Claude API securely

**How?** Follow **[SETUP_NAMED_CREDENTIAL_STEPS.md](SETUP_NAMED_CREDENTIAL_STEPS.md)**

**Steps:**
1. Open Salesforce Setup
2. Quick Find → "Named Credentials"
3. Create new credential with API key
4. Test it with the provided script

**When done:** Come back and tell me "Named Credential is working"

### Task 2: Deploy Automation Code (2 minutes)

**Why?** Auto-analyze jobs when you create them

**What we're deploying:**
- ✅ JobPostingAnalysisQueue.cls (already created)
- ✅ JobPostingTrigger.trigger (already created)
- ✅ JobPostingTriggerHandler.cls (already created)

**How?** I'll run the deployment commands after you confirm Named Credential works

## After Both Tasks Complete

Your new workflow will be:

### New Workflow (Automated)
1. **Go to Salesforce org**
2. **App Launcher → Job Postings**
3. **Click New**
4. **Fill in:**
   - Title: "Senior Salesforce Developer"
   - Company: "InnovateCo"
   - Description: (paste full job description)
   - Salary: $100K - $130K
   - Remote Policy: "Fully remote, flexible hours"
5. **Click Save**
6. **Wait 10-30 seconds**
7. **Refresh page**
8. **See Fit Score populated!** ✨

No more Developer Console! No more pasting test scripts!

## What to Do Right Now

1. Open [SETUP_NAMED_CREDENTIAL_STEPS.md](SETUP_NAMED_CREDENTIAL_STEPS.md) in a new window
2. Log into your Salesforce org
3. Follow the step-by-step instructions
4. Test the Named Credential
5. If you get **Status: 200** → Tell me "It works!"
6. If you get an error → Screenshot it and show me

## Common Questions

**Q: Can I skip Named Credential and use direct API key?**
A: Not in triggers - Salesforce requires Named Credential for API callouts in triggers.

**Q: What if Named Credential doesn't work?**
A: Show me the error screenshot. We can try:
- Legacy Named Credential approach
- External Credentials approach
- Debug the configuration together

**Q: How long does setup take?**
A: 5-7 minutes total if everything goes smoothly.

**Q: Can I test automation before creating real jobs?**
A: Yes! The [AUTOMATION_SETUP_GUIDE.md](AUTOMATION_SETUP_GUIDE.md) has test scripts.

---

**Ready? Open [SETUP_NAMED_CREDENTIAL_STEPS.md](SETUP_NAMED_CREDENTIAL_STEPS.md) and let's do this!**

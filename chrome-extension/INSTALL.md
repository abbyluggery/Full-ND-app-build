# Install Chrome Extension - Job Search Assistant

## Prerequisites

Before installing the extension, you MUST complete the Salesforce API setup:

1. ✅ Follow [setup-salesforce-api.md](setup-salesforce-api.md) to:
   - Create Connected App in Salesforce
   - Deploy JobPostingAPI Apex class
   - Test the API endpoint
   - Get your Salesforce credentials

## Step 1: Create Extension Icons

The extension needs icons. Create 3 simple PNG files or use placeholders:

**Quick Option - Use Emoji Icons:**
1. Go to https://favicon.io/emoji-favicons/briefcase/
2. Download the favicon package
3. Extract and rename:
   - `favicon-32x32.png` → `icon16.png`
   - `apple-touch-icon.png` → `icon48.png` and `icon128.png`
4. Put them in `chrome-extension/icons/` folder

**OR use any PNG images (16x16, 48x48, 128x128 pixels)**

## Step 2: Load Extension in Chrome

1. Open Chrome
2. Go to: `chrome://extensions/`
3. Toggle **Developer mode** ON (top-right switch)
4. Click **Load unpacked**
5. Navigate to: `C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant\chrome-extension`
6. Click **Select Folder**

You should see "Job Search Assistant - Claude AI" appear in your extensions!

## Step 3: Configure Salesforce Connection

1. Click the **extension icon** in your Chrome toolbar (puzzle piece icon if hidden)
2. Click **Configure Salesforce Connection**
3. Enter your details:
   - **Salesforce URL:** Your instance URL (e.g., `https://orgfarm-d7ac6d4026-dev-ed.develop.my.salesforce.com`)
   - **Username:** Your Salesforce username
   - **Password + Security Token:** Your password + security token concatenated
4. Click **Save Configuration**

## Step 4: Test It!

1. Go to any job posting page (LinkedIn, Indeed, Glassdoor)
2. Click the **extension icon** OR click the floating **"💼 Save to SF"** button that appears on the page
3. The extension will auto-fill job details
4. Edit if needed
5. Click **Save to Salesforce & Analyze**
6. Wait 10-15 seconds
7. Go to Salesforce → Job Search Assistant app → Job Postings
8. See your job with Claude's analysis! 🎉

## Troubleshooting

### Extension doesn't appear
- Make sure Developer mode is ON in `chrome://extensions/`
- Check that you selected the correct folder
- Look for error messages in the extensions page

### "Configure Salesforce Connection" error
- Make sure you deployed the JobPostingAPI class in Salesforce
- Verify your Salesforce URL is correct (no trailing slash)
- Check that your password + security token are correct

### Auto-fill doesn't work
- The extension may not recognize the job board's HTML structure
- Manually fill in the fields - it will still work!
- Different job boards use different HTML structures

### Jobs not appearing in Salesforce
- Check Setup → Apex Jobs to see if the queue job ran
- Look for errors in the JobPostingAnalysisQueue
- Verify the JobPostingAPI endpoint is working (run test in Developer Console)

## Advanced: Update OAuth Credentials

For production use, you should use proper OAuth instead of username/password:

1. In `popup.js`, find the `sendToSalesforce` function
2. Update the `client_id` and `client_secret` with your Connected App credentials
3. Implement proper OAuth flow (beyond scope of this quick setup)

For now, the username/password method works fine for personal use!

## Next Steps

Once the extension is working:
- ✅ Browse job boards and capture jobs with one click
- ✅ Claude automatically analyzes each job
- ✅ Review high-priority jobs in your Job Search Assistant app
- 🎯 Build the twice-daily email summary next!

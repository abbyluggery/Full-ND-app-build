# Job Search Assistant - Chrome Extension

**Capture job postings from any website and analyze them with Claude AI in Salesforce**

## What It Does

1. **One-Click Capture:** Browse LinkedIn, Indeed, Glassdoor, or any job board
2. **Auto-Extract:** Automatically extracts title, company, location, salary, description
3. **Save to Salesforce:** Creates Job_Posting__c record in your Salesforce org
4. **Claude Analyzes:** Your automation triggers and Claude AI scores the job:
   - ND-Friendliness Score (0-10)
   - Green Flags (Agentforce focus, remote work, flexibility)
   - Red Flags (missing accommodations, rigid schedules)
5. **Review:** See all analyzed jobs in your Job Search Assistant app

## Files

- `manifest.json` - Extension configuration
- `popup.html` - Extension popup UI
- `popup.js` - Main extension logic
- `content.js` - Adds floating button to job pages
- `background.js` - Background service worker
- `setup-salesforce-api.md` - **START HERE** - Salesforce setup instructions
- `INSTALL.md` - Extension installation guide

## Quick Start

### 1. Setup Salesforce (20 minutes)

Follow [setup-salesforce-api.md](setup-salesforce-api.md):
- Create Connected App
- Deploy JobPostingAPI class
- Test the API

### 2. Install Extension (5 minutes)

Follow [INSTALL.md](INSTALL.md):
- Load extension in Chrome
- Configure Salesforce connection
- Test on a job posting

### 3. Start Capturing Jobs!

Browse job boards and click "Save to SF" - that's it!

## Supported Job Boards

- ✅ LinkedIn
- ✅ Indeed
- ✅ Glassdoor
- ✅ Monster
- ✅ ZipRecruiter
- ✅ Any website (manual entry)

## Features

- **Auto-Fill:** Automatically extracts job details from supported job boards
- **Floating Button:** Quick-capture button appears on job pages
- **Manual Entry:** Edit or manually enter any field
- **Secure:** Credentials stored locally in Chrome (never sent to third parties)
- **Fast:** Jobs saved in seconds, analysis completes in ~15 seconds

## Privacy & Security

- All data stays between your browser and your Salesforce org
- No third-party servers involved
- API credentials encrypted by Chrome's storage API
- Extension only runs on job board websites

## Roadmap

Future enhancements:
- [ ] OAuth authentication (more secure than password)
- [ ] Browser action badge showing captured jobs count
- [ ] Duplicate detection (don't capture same job twice)
- [ ] Bulk capture (select multiple jobs at once)
- [ ] Export captured jobs to CSV

## Support

Issues or questions? Check the troubleshooting section in [INSTALL.md](INSTALL.md)

## License

Personal use only - built for Abby's job search automation project!

---

**Happy Job Hunting! 🚀**

*Powered by Claude AI and Salesforce*

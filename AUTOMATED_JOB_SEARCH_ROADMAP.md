# Automated Job Search System - Implementation Roadmap

You want a FULLY automated system that:
1. ✅ Auto-imports jobs from LinkedIn, Indeed, etc.
2. ✅ Chrome extension to capture jobs with one click
3. ✅ Scheduled checks (daily/hourly) for new matching jobs
4. ✅ Twice-daily email summaries of high-priority jobs

---

## Current Status: What's Already Working

✅ **Claude AI Analysis Engine**
- Analyzes jobs with your holistic framework
- Scores ND-friendliness (0-10)
- Identifies green flags and red flags
- Uses your manifestation context ($155K goal, ND accommodations)

✅ **Automatic Trigger & Queue**
- When job is created → Claude analyzes automatically
- No manual work needed

---

## Phase 1: Chrome Extension (EASIEST - Start Here!)

**What it does:** Click a button on LinkedIn/Indeed → Job automatically saved to Salesforce → Claude analyzes

**Implementation:**
- Simple Chrome extension with bookmarklet
- Captures: Title, Company, Location, Salary, Description, URL
- Sends to Salesforce via REST API
- Works on: LinkedIn, Indeed, Glassdoor, any job board

**Time to build:** 1-2 hours
**Complexity:** Easy
**Tech needed:** JavaScript, Salesforce REST API

---

## Phase 2: Scheduled Job Board Integration (MEDIUM)

**What it does:** Salesforce automatically searches job boards every 12 hours for jobs matching your criteria

**Options:**

### Option A: Use Existing Job Board APIs
- **LinkedIn API:** Requires LinkedIn partnership (very restrictive)
- **Indeed API:** Free tier available, limited to 1000 calls/month
- **Glassdoor API:** Deprecated (no longer available)
- **Adzuna API:** Free tier, 1000 calls/month, good coverage

### Option B: Use Job Aggregator Service (RECOMMENDED)
- **RapidAPI Job Search APIs:**
  - JSearch API (Indeed, LinkedIn, Glassdoor combined)
  - Job Search API
  - Salary/Benefits included
- **Pricing:** ~$20-50/month for unlimited searches
- **Integration:** Simple REST API callout from Salesforce

### Option C: Build Custom Web Scraper
- Python script hosted externally (Heroku, AWS Lambda)
- Scrapes LinkedIn/Indeed daily
- Sends results to Salesforce via REST API
- **Challenge:** Job boards block scrapers aggressively
- **Cost:** ~$5-10/month for hosting

**Recommendation:** Start with **Option B (RapidAPI)** - easiest and most reliable

**Time to build:** 2-4 hours
**Complexity:** Medium
**Tech needed:** Salesforce Schedulable Apex, REST API callouts

---

## Phase 3: Twice-Daily Email Summary (EASY)

**What it does:** Every morning (8am) and evening (5pm), email you:
- High-priority jobs (ND Score ≥ 8)
- Green flags, red flags
- Direct links to apply
- Summary of why each job is a good fit

**Implementation:**
- Scheduled Apex job runs at 8am and 5pm
- Queries for new jobs with ND Score ≥ 8
- Builds HTML email with job details
- Sends via Salesforce Email

**Time to build:** 1 hour
**Complexity:** Easy
**Tech needed:** Schedulable Apex, Email templates

---

## Phase 4: Auto-Import from Job Boards (HARDEST)

**What it does:** Fully automatic - you wake up and new jobs matching your criteria are already in Salesforce, analyzed by Claude

**Best Approach:**

### Step 1: Set Up Job Search Criteria in Salesforce
Create a custom object: `Job_Search_Criteria__c`
- Keywords: "Salesforce Developer, Agentforce, Admin"
- Location: "Remote, USA"
- Salary Min: 85000
- Required Terms: "remote, flexible"
- Excluded Terms: "on-site, office, 9-5"

### Step 2: Build Scheduled Job Importer
- Runs twice daily (8am, 5pm)
- Reads your Job_Search_Criteria__c
- Calls job board API with criteria
- Filters results by your MUST HAVEs
- Creates Job_Posting__c records
- Claude analyzes automatically (via existing trigger!)

### Step 3: Duplicate Detection
- Check ExternalID__c to avoid importing same job twice
- Update existing jobs if details changed

**APIs to Use:**
1. **JSearch API (RapidAPI)** - Best option
   - Searches Indeed, LinkedIn, Glassdoor, ZipRecruiter
   - $20/month for unlimited
   - Returns: Title, Company, Location, Salary, Description, Apply URL

2. **Adzuna API** - Free alternative
   - 1000 calls/month free
   - Good US job coverage
   - Less detailed than JSearch

**Time to build:** 4-6 hours
**Complexity:** Hard
**Tech needed:** Schedulable Apex, HTTP Callouts, JSON parsing, duplicate detection

---

## Recommended Implementation Order

### Week 1: Quick Wins (Get Something Working Fast!)
1. ✅ **Chrome Extension** (Phase 1) - 1-2 hours
   - Start capturing jobs manually with one click
   - Works immediately

2. ✅ **Email Summary** (Phase 3) - 1 hour
   - Get daily notifications of high-priority jobs
   - Keeps you motivated

### Week 2: Automation
3. ✅ **Job Board Integration** (Phase 2) - 2-4 hours
   - Set up RapidAPI account
   - Build scheduled job importer
   - Test with manual runs first

### Week 3: Full Automation
4. ✅ **Auto-Import** (Phase 4) - 4-6 hours
   - Build Job_Search_Criteria__c object
   - Implement filtering logic
   - Add duplicate detection
   - Schedule twice-daily runs

---

## Cost Breakdown

**Free Option:**
- Chrome extension: Free
- Adzuna API: Free (1000 calls/month = ~30 jobs/day)
- Email summaries: Free (Salesforce built-in)
- **Total: $0/month**

**Paid Option (Recommended):**
- Chrome extension: Free
- JSearch API (RapidAPI): $20/month
- Email summaries: Free
- **Total: $20/month**

---

## Next Steps - Where Do You Want to Start?

**Option A: Start with Chrome Extension (FASTEST)**
- Get immediate value
- Works today
- No API costs
- I'll help you build it now

**Option B: Start with Email Summary (EASIEST)**
- Get daily job notifications
- Builds on what's working
- Takes 30 minutes
- We can do this right now

**Option C: Start with Job Board Integration (MOST POWERFUL)**
- Full automation
- Requires API setup
- Takes longer but worth it
- Need to sign up for RapidAPI first

**Which would you like to tackle first?**

My recommendation: **Start with Option B (Email Summary)** - we can have it working in 30 minutes, and you'll get immediate value. Then we can build the Chrome extension, then the job board integration.

What do you think?

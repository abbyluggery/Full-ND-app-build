# ⚡ Quick Start Guide - Job Search Assistant

## 🎯 Your AI Job Analyzer is Ready!

This system uses Claude AI to automatically score job postings based on YOUR specific needs:
- ✅ $155K salary manifestation goal (realistic $85-110K range)
- ✅ Neurodivergent-friendly culture requirements
- ✅ Remote work, flexible schedule (non-negotiable)
- ✅ Agentforce expertise as differentiator

---

## 📝 How to Analyze a Job (Right Now)

### Method 1: Quick Test in Developer Console

1. Open **Developer Console** (gear icon ⚙️ → Developer Console)
2. Click **Debug** → **Open Execute Anonymous Window**
3. Copy and run this script:

```apex
// Create and analyze a test job
Job_Posting__c testJob = new Job_Posting__c();
testJob.Title__c = 'Salesforce Admin - Agentforce Focus';
testJob.Company__c = 'InnovateCo';
testJob.Location__c = 'Remote USA';
testJob.Workplace_Type__c = 'Remote';
testJob.Remote_Policy__c = 'Fully Remote';
testJob.Salary_Min__c = 95000;
testJob.Salary_Max__c = 115000;
testJob.Description__c = 'Join our team building AI agents with Agentforce! ' +
    'We offer flexible hours, unlimited PTO, and support neurodivergent employees. ' +
    'No meetings before 10am. Async-first culture.';

// Get analysis
JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(testJob);

// Print results
System.debug('\n=== JOB ANALYSIS ===');
System.debug('Fit Score: ' + result.fitScore + '/10');
System.debug('ND Friendliness: ' + result.ndFriendlinessScore + '/10');
System.debug('Recommendation: ' + result.recommendation);
System.debug('\nGreen Flags:\n' + result.greenFlags);
System.debug('\nRed Flags:\n' + result.redFlags);
System.debug('\nReasoning:\n' + result.reasoning);
```

4. Check "Open Log" and click **Execute**
5. View results in the Logs tab (click "Debug Only" filter)

**Expected Result**: Fit Score ~9+ (this is a perfect match for you!)

---

### Method 2: Analyze a Real Job You Found

1. Create a new **Job Posting** record in Salesforce
2. Fill in all the details from the job posting
3. **Save** the record
4. Note the **Record ID** (in the URL: `.../Job_Posting__c/<ID>`)
5. In Developer Console, run:

```apex
// Replace with your actual Job Posting ID
Id jobId = 'a00XXXXXXXXXXXXXXX';

Job_Posting__c job = [SELECT Id, Title__c, Company__c, Location__c,
                      Workplace_Type__c, Remote_Policy__c, Salary_Min__c,
                      Salary_Max__c, Description__c, URL__c
                      FROM Job_Posting__c
                      WHERE Id = :jobId];

// Analyze
JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(job);

// Save results back to the job
job.Fit_Score__c = result.fitScore;
job.ND_Friendliness_Score__c = result.ndFriendlinessScore;
job.Green_Flags__c = result.greenFlags;
job.Red_Flags__c = result.redFlags;
job.Research_JSON__c = result.fullResponse;
job.Research_Date__c = DateTime.now();
update job;

System.debug('✅ Job updated! Fit Score: ' + result.fitScore);
System.debug('View the record in Salesforce to see full analysis');
```

6. Refresh the Job Posting record in Salesforce
7. See the AI analysis in the fields!

---

## 🎯 Understanding Your Scores

### Fit Score (0-10)

| Score | Meaning | Action |
|-------|---------|--------|
| **9-10** | 🔥 **HIGH PRIORITY** | Apply today! Perfect alignment |
| **7-8** | ✅ **GOOD FIT** | Apply this week - strong match |
| **5-6** | 🤔 **CONSIDER** | Research more, apply if slow week |
| **0-4** | ❌ **SKIP** | Deal-breaker present, don't waste energy |

### ND Friendliness Score (0-10)

| Score | Meaning |
|-------|---------|
| **9-10** | Explicitly disability-friendly, accommodations mentioned |
| **7-8** | Flexible culture, understanding language |
| **5-6** | Standard corporate, neutral |
| **3-4** | Rigid structure, "fast-paced" red flags |
| **0-2** | "Grind culture", strict hours, burnout risks |

---

## 🚀 What Makes a Job "HIGH PRIORITY" for You?

### MUST HAVEs (Deal Breakers if Missing):
✅ **Remote Work**: 100% remote required
✅ **Flexible Schedule**: No rigid 9-5
✅ **ND-Friendly Culture**: Understanding, accommodations
✅ **Salary**: Minimum $85K base

### NICE TO HAVEs (Scoring Boosters):
- **Agentforce/AI Focus**: +2 points (your differentiator!)
- **Stated ND Accommodations**: +2 points
- **Growth-Stage Company**: +1 point
- **Clear Career Progression**: +1 point
- **Unlimited PTO**: +1 point
- **International Travel**: +1 point

---

## 📊 Example Analysis Output

Here's what a HIGH PRIORITY job looks like:

```
=== JOB ANALYSIS ===
Fit Score: 9.2/10
ND Friendliness: 8.5/10
Recommendation: HIGH PRIORITY

Green Flags:
• Fully remote work (MUST HAVE ✅)
• Agentforce focus - matches your expertise (+2 points)
• Flexible hours mentioned
• Neurodivergent-friendly culture stated explicitly
• Salary $95-115K (in your target range)
• Unlimited PTO mentioned
• Async-first communication
• No Monday morning meetings

Red Flags:
• Startup pace might be intense (monitor for burnout)
• Limited details on career progression

Reasoning:
This role is an excellent fit scoring 9.2/10. It meets ALL your
MUST HAVE requirements: fully remote (✓), flexible schedule (✓),
ND-friendly culture explicitly stated (✓), and salary $95-115K
which falls in your realistic $85-110K target range (✓).

The Agentforce focus is a major strength - this role lets you
leverage your unique expertise and differentiator. The explicit
mention of supporting neurodivergent employees and no morning
meetings shows cultural alignment.

ND Friendliness scores 8.5/10 due to explicit accommodations
mentioned and flexible, async culture.

RECOMMENDATION: Apply today during your 9:45-11:30am optimal
job search window. Prepare company research and tailored resume
highlighting your Agentforce Superbadge and 99% data integrity record.

This is a HIGH-FIT opportunity worth prioritizing.
```

---

## 🎓 What's Happening Behind the Scenes?

When you call `analyzeJob(testJob)`:

1. **JobPostingAnalyzer** builds your holistic context:
   - Your manifestation goals ($155K target)
   - Neurodivergent needs (ADHD/Bipolar accommodations)
   - Non-negotiable requirements (remote, flexible, etc.)
   - MUST HAVE / NICE TO HAVE scoring framework

2. **ClaudeAPIService** sends this to Claude AI:
   - Formats the job details as a prompt
   - Includes your system context
   - Calls Claude API via secure Named Credential

3. **Claude analyzes** using your decision framework:
   - Checks MUST HAVEs (if any missing → SKIP)
   - Calculates NICE TO HAVE points
   - Generates fit score (0-10)
   - Lists green flags and red flags
   - Provides detailed reasoning

4. **Results are parsed** back into Salesforce:
   - Fit_Score__c field
   - ND_Friendliness_Score__c
   - Green_Flags__c and Red_Flags__c
   - Full JSON response stored

**All in ~10 seconds!** ⚡

---

## 💡 Pro Tips

### 1. Test with Both Good and Bad Jobs

Try analyzing jobs that clearly WON'T fit to see Claude identify deal-breakers:

```apex
// This should score LOW (on-site + low salary)
Job_Posting__c badFit = new Job_Posting__c(
    Title__c = 'Junior Salesforce Admin',
    Company__c = 'Corporate Inc',
    Location__c = 'New York, NY',
    Workplace_Type__c = 'On-site',  // ❌ Deal breaker
    Remote_Policy__c = 'Office-based',
    Salary_Min__c = 55000,  // ❌ Below $85K minimum
    Salary_Max__c = 70000,
    Description__c = 'Fast-paced startup. Must be in office 9-6pm daily.'
);

JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(badFit);
// Should return Fit Score: 2-3, Recommendation: SKIP
```

### 2. Use Actual Job Descriptions

Copy-paste the full job description from LinkedIn/Indeed for best results. Claude analyzes:
- Job requirements vs. your skills
- Culture signals (language used)
- Red flags (rigid hours, "hustle", etc.)
- Green flags (flexibility, ND support, etc.)

### 3. Check the Research JSON

The `Research_JSON__c` field stores Claude's complete response. View it to see:
- Full reasoning
- Detailed breakdown
- Exact quote analysis
- Cultural assessment

---

## 🔍 Debugging Tips

### If Fit Score is 0:
- Check debug logs for errors
- Verify Named Credential is set up
- Make sure Remote Site Setting allows anthropic.com

### If Green/Red Flags are empty:
- Claude might have returned a different JSON format
- Check the Research_JSON__c field to see raw response
- Might need to adjust the prompt in JobPostingAnalyzer

### If it's slow:
- Normal! Claude takes 5-15 seconds for analysis
- Longer descriptions = longer processing
- Timeout is set to 60 seconds max

---

## ✨ Next: Automation

Right now, you're running analysis manually. Soon we'll add:

**Trigger**: Auto-analyze when you create a new Job Posting
**Batch**: Analyze 100+ jobs at once
**Scheduled**: Re-analyze jobs weekly for updates
**Dashboard**: Visual UI to see your pipeline

---

## 🎯 Your Job Search Workflow

**Recommended Daily Routine** (from your holistic roadmap):

1. **9:45am**: Job search time begins (your optimal window)
2. **Find 2-3 jobs** on LinkedIn/Indeed
3. **Create Job_Posting__c records** in Salesforce (paste descriptions)
4. **Run analysis script** on each job
5. **Review fit scores**:
   - 9-10? Research company → apply today
   - 7-8? Add to this week's list
   - 5-6? Save for slow week
   - 0-4? Archive immediately
6. **11:30am**: End job search, take break before lunch

**This saves you hours** of manual job evaluation and prevents you from applying to bad-fit roles that would waste your energy!

---

**Questions?** Ask Claude Code anytime! I'm here to help you understand and extend this system. 🚀

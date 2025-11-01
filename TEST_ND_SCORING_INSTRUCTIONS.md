# Test ND Scoring with Different Job Descriptions

## ✅ SUCCESS: Hourly Salary Detection Working!

Job "Salesforce Administrator 247108" now correctly shows:
- ✅ Green Flag: "Salary range meets the minimum requirement of $85K annual"
- This confirms the AI is converting $51-54/hr → ~$106-112K annual

---

## ND Score Still 7 - But This Might Be CORRECT!

The improved ND criteria DID deploy. Looking at the scoring guide:

**Score 9-10**: Explicitly mentions neurodiversity/autism/ADHD support, structured onboarding, async communication, sensory accommodations

**Score 7-8**: Remote work, flexible hours, written communication emphasized, clear processes ← **YOUR CURRENT JOB**

**Score 5-6**: Standard office with some flexibility, no specific ND mentions

**Score 3-4**: Open office, frequent meetings, limited flexibility

**Score 1-2**: High-pressure language, constant collaboration required, ambiguity emphasized, no flexibility

### Why Your Job Scores 7:
Your Salesforce Administrator job likely has:
- ✅ Remote work (7-8 range)
- ✅ Flexible hours (7-8 range)
- ❌ But NO explicit ND/autism/ADHD mentions (would need this for 9-10)

**A score of 7 is actually CORRECT** based on the improved criteria!

---

## Test: Create Jobs That SHOULD Score Differently

To verify the ND scoring is truly working, create these test jobs:

### Test Job #1: High ND Score (Should be 9-10)

**Required Fields:**
- **Apply URL**: `https://linkedin.com/jobs/test-high-nd`
- **Provider**: `LinkedIn`
- **External ID**: `LinkedIn:HIGH-ND-TEST`
- **Status**: `Active`

**Job Details:**
- **Title**: `ND-Friendly Software Engineer`
- **Company**: `Neurodiversity Champions Inc`
- **Location**: `Remote`
- **Description**:
  ```
  We actively recruit neurodivergent talent including autistic and ADHD professionals.

  Accommodations provided:
  - Async-first communication culture
  - Structured onboarding with clear documentation
  - Sensory-friendly home office stipend
  - Noise-cancelling headphones provided
  - Flexible work hours tailored to your energy patterns
  - Written communication preferred over calls
  - Clear expectations and processes documented

  Our team includes many neurodivergent engineers and we celebrate cognitive diversity.
  ```

**Salary:**
- Min: `90`
- Max: `120`

**ND Fields:**
- Workplace Type: `Remote`
- Remote Policy: `Fully Remote`
- Flexible Schedule: ✓

**Expected Result**: ND Score **9-10** (explicit ND mentions, accommodations, structured approach)

---

### Test Job #2: Low ND Score (Should be 1-3)

**Required Fields:**
- **Apply URL**: `https://linkedin.com/jobs/test-low-nd`
- **Provider**: `LinkedIn`
- **External ID**: `LinkedIn:LOW-ND-TEST`
- **Status**: `Active`

**Job Details:**
- **Title**: `High-Pressure Sales Manager`
- **Company**: `Fast-Paced Startup`
- **Location**: `New York Office`
- **Description**:
  ```
  Thrive in ambiguity! We move fast and break things.

  Open office environment with constant collaboration.
  Daily standup meetings + frequent ad-hoc discussions.
  Must be comfortable with constantly changing priorities.
  High-energy, fast-paced team that works hard and plays hard.
  Evening and weekend availability required.
  In-office 5 days/week - we believe in face-to-face interaction.

  "Work hard, play hard" culture with happy hours and team bonding.
  ```

**Salary:**
- Min: `60`
- Max: `75`

**ND Fields:**
- Workplace Type: `On-site`
- Remote Policy: `No Remote Work`
- Flexible Schedule: ✗ (unchecked)

**Expected Result**: ND Score **1-3** (open office, constant meetings, ambiguity, no flexibility)

---

### Test Job #3: Medium ND Score (Should be 5-6)

**Required Fields:**
- **Apply URL**: `https://linkedin.com/jobs/test-medium-nd`
- **Provider**: `LinkedIn`
- **External ID**: `LinkedIn:MEDIUM-ND-TEST`
- **Status**: `Active`

**Job Details:**
- **Title**: `Standard Office Job`
- **Company**: `Regular Corp`
- **Location**: `Chicago`
- **Description**:
  ```
  Standard office position with typical corporate environment.

  Hybrid work schedule - in office 3 days/week.
  Regular meetings and team collaboration.
  Standard 9-5 schedule with some flexibility.
  Health insurance and 401k benefits.
  ```

**Salary:**
- Min: `70`
- Max: `85`

**ND Fields:**
- Workplace Type: `Hybrid`
- Remote Policy: `Hybrid - 3 days in office`
- Flexible Schedule: ✗ (unchecked)

**Expected Result**: ND Score **5-6** (some flexibility, but no ND-specific features)

---

## Expected Test Results Summary

After creating these 3 test jobs and waiting 60 seconds:

| Job Title | Expected ND Score | Why |
|-----------|------------------|-----|
| ND-Friendly Software Engineer | **9-10** | Explicit ND support, accommodations |
| High-Pressure Sales Manager | **1-3** | Open office, constant meetings, no flexibility |
| Standard Office Job | **5-6** | No ND mentions, standard environment |
| Your Salesforce Admin | **7-8** | Remote + flexible, but no explicit ND support |

If all 4 jobs show these different scores, **ND scoring is working correctly!**

If they all still show score of 7, there's still an issue with the prompt.

---

## Quick Test (Just One Job)

If you only want to test one job to verify it's working, create **Test Job #1 (High ND Score)**.

If it scores 9-10, you'll know the system is working and your Salesforce Admin job genuinely deserves its score of 7.

If it still scores 7, we'll need to investigate further.

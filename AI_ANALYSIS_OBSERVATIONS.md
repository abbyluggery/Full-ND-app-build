# AI Analysis Observations and Improvements

## Testing Results - 2025-10-30

### Test Sample
- **Total Jobs Tested**: 4 jobs
- **Method**: Bookmarklet → Manual entry → AI analysis

---

## Observation 1: ND Friendliness Score Always 7

### What We Saw
All 4 job postings received an **ND Friendliness Score of 7**, regardless of job characteristics.

### Possible Causes

#### 1. **Insufficient Context in Prompt**
The AI might not have enough information about what differentiates ND-friendly jobs (score 9-10) from neutral jobs (score 5-7) from ND-unfriendly jobs (score 1-3).

**Current Prompt** (from ClaudeAPIService.cls:230):
```
2. **ND Friendliness Score** (0-10): Assess neurodivergent-friendly culture indicators
```

**Issue**: This is too vague. The AI doesn't know what specific factors to look for.

#### 2. **Conservative AI Behavior**
Without strong positive or negative signals, Claude may default to a middle score (7) as a "safe" assessment.

#### 3. **Missing Job Details**
If key fields like `Description__c`, `Workplace_Type__c`, or `Remote_Policy__c` are empty, the AI has less data to differentiate jobs.

### Recommended Fixes

#### Fix 1: Expand ND Friendliness Scoring Criteria

Update the prompt to be more specific:

```apex
prompt += '2. **ND Friendliness Score** (0-10): Assess neurodivergent-friendly culture based on:\n';
prompt += '   **Score 9-10 (Excellent ND Support)**:\n';
prompt += '   - Explicitly mentions neurodiversity, autism, ADHD, or ND accommodations\n';
prompt += '   - Structured onboarding and clear expectations\n';
prompt += '   - Async communication preferred\n';
prompt += '   - Sensory-friendly workspace options\n';
prompt += '   - Flexible schedule with no core hours\n';
prompt += '   **Score 7-8 (ND-Friendly)**:\n';
prompt += '   - Remote work available\n';
prompt += '   - Written communication emphasized\n';
prompt += '   - Flexible hours mentioned\n';
prompt += '   - Clear processes and documentation\n';
prompt += '   **Score 4-6 (Neutral)**:\n';
prompt += '   - Standard office environment\n';
prompt += '   - Some flexibility available\n';
prompt += '   - No specific ND mentions\n';
prompt += '   **Score 1-3 (ND-Challenging)**:\n';
prompt += '   - Open office/high sensory environment\n';
prompt += '   - Constant collaboration required\n';
prompt += '   - Fast-paced/high-pressure language\n';
prompt += '   - Strict schedule, no flexibility\n';
prompt += '   - Ambiguity emphasized as positive\n';
```

#### Fix 2: Require Examples in Response

Add to the prompt:
```apex
prompt += '   - Provide specific examples from the job posting that justify the score\n';
```

#### Fix 3: Add ND Context to System Prompt

The system context should include your specific ND needs:

```apex
String systemContext =
    'You are analyzing job postings for a neurodivergent (ND) job seeker with ADHD. ' +
    'Key needs: Remote work, flexible schedule, async communication, clear expectations, ' +
    'minimal sensory overload, structured processes. ' +
    'Red flags: Open office, constant meetings, ambiguity, high-pressure environment.';
```

---

## Observation 2: Hourly Salary Flagged as Red Flag

### What We Saw
**Job**: Salesforce Administrator (ID: 247108)
**Salary Entered**: Hourly rate (e.g., $35/hr)
**Red Flag Generated**: Salary concern

### Root Cause

The AI prompt has this criteria (from ClaudeAPIService.cls:228):
```
- MUST HAVES: Remote work, ND-friendly culture, Salary ≥ $85K, Flexible schedule
```

**Issue**: The AI is comparing hourly rates to the $85K annual threshold, which doesn't make sense.

**Example**:
- Hourly rate: $35/hr
- Annual equivalent (2080 hours): $72,800
- Result: AI sees "$35" and flags it as below $85K threshold ❌

### Solutions

#### Option 1: Always Enter Annual Salary

**In the UI**: Convert hourly to annual before entering
- $35/hr × 2080 hours/year = $72,800/year
- Enter: `72800` in Salary_Min__c

**Pros**: Works with current AI logic
**Cons**: Extra calculation step

#### Option 2: Add Hourly Rate Fields

Create new fields:
- `Hourly_Rate_Min__c` (Currency)
- `Hourly_Rate_Max__c` (Currency)
- `Salary_Type__c` (Picklist: Annual, Hourly, Contract)

Update prompt to handle both:
```apex
if (jobPosting.Salary_Type__c == 'Annual' && jobPosting.Salary_Min__c != null) {
    prompt += 'Salary Range: $' + jobPosting.Salary_Min__c + '/year\n';
} else if (jobPosting.Salary_Type__c == 'Hourly' && jobPosting.Hourly_Rate_Min__c != null) {
    Decimal annualEquivalent = jobPosting.Hourly_Rate_Min__c * 2080;
    prompt += 'Salary Range: $' + jobPosting.Hourly_Rate_Min__c + '/hr (≈$' + annualEquivalent.format() + '/year)\n';
}
```

**Pros**: Handles both salary types correctly
**Cons**: Requires schema changes

#### Option 3: Smart Detection in Prompt Building

Add logic to detect and convert:
```apex
if (jobPosting.Salary_Min__c != null) {
    Decimal salaryMin = jobPosting.Salary_Min__c;

    // If salary looks like hourly (< $200), convert to annual
    if (salaryMin < 200) {
        Decimal annualMin = salaryMin * 2080;
        prompt += 'Salary Range: $' + salaryMin + '/hr (≈$' + annualMin.format() + '/year)\n';
    } else {
        prompt += 'Salary Range: $' + salaryMin + '/year\n';
    }
}
```

**Pros**: Works immediately, no schema changes
**Cons**: Heuristic might fail for edge cases

---

## Recommended Immediate Fixes

### 1. Update ND Friendliness Criteria (High Priority)

**File**: ClaudeAPIService.cls
**Line**: 230
**Change**: Expand the ND Friendliness scoring description with specific examples

**Impact**:
- ✅ More varied ND scores (not always 7)
- ✅ More accurate assessments
- ✅ Better differentiation between jobs

### 2. Add Hourly Salary Detection (Medium Priority)

**File**: ClaudeAPIService.cls
**Line**: 214-220 (salary section of buildJobAnalysisPrompt)

**Add**:
```apex
if (jobPosting.Salary_Min__c != null || jobPosting.Salary_Max__c != null) {
    prompt += 'Salary Range: ';

    // Check if values look like hourly rates (< $200)
    Boolean isHourly = false;
    if (jobPosting.Salary_Min__c != null && jobPosting.Salary_Min__c < 200) {
        isHourly = true;
    }

    if (isHourly) {
        // Convert hourly to annual for clarity
        if (jobPosting.Salary_Min__c != null) {
            Decimal hourly = jobPosting.Salary_Min__c;
            Decimal annual = hourly * 2080;
            prompt += '$' + hourly + '/hr (~$' + annual.format() + '/year)';
        }
        if (jobPosting.Salary_Min__c != null && jobPosting.Salary_Max__c != null) {
            prompt += ' - ';
        }
        if (jobPosting.Salary_Max__c != null) {
            Decimal hourly = jobPosting.Salary_Max__c;
            Decimal annual = hourly * 2080;
            prompt += '$' + hourly + '/hr (~$' + annual.format() + '/year)';
        }
    } else {
        // Annual salary
        if (jobPosting.Salary_Min__c != null) prompt += '$' + jobPosting.Salary_Min__c;
        if (jobPosting.Salary_Min__c != null && jobPosting.Salary_Max__c != null) prompt += ' - ';
        if (jobPosting.Salary_Max__c != null) prompt += '$' + jobPosting.Salary_Max__c;
        prompt += '/year';
    }
    prompt += '\n';
}
```

**Impact**:
- ✅ Hourly rates converted to annual
- ✅ AI sees correct annual equivalent
- ✅ No false "low salary" red flags

### 3. Add System Context with ND Needs (High Priority)

**File**: JobPostingAnalyzer.cls (or wherever analyzeJobPosting is called)

**Current**:
```apex
String systemContext = 'You are a helpful job analysis assistant.';
```

**Updated**:
```apex
String systemContext =
    'You are analyzing job postings for a neurodivergent (ND) job seeker with ADHD. ' +
    'Key needs: Remote work (required), flexible schedule (required), async communication, ' +
    'clear expectations and structured processes, minimal sensory overload. ' +
    'Major red flags: Open office layout, constant meetings, high-pressure language, ' +
    'ambiguity emphasized, no flexibility. ' +
    'Salary threshold: $85K+ annual. ' +
    'Bonus: Agentforce/AI experience, ND accommodations mentioned, growth-stage company.';
```

**Impact**:
- ✅ More personalized scoring
- ✅ Better understanding of what matters
- ✅ More consistent ND assessments

---

## Testing Plan

After applying fixes:

### Test Set 1: ND-Friendly Jobs (Expected ND Score 8-10)
- [ ] Remote Salesforce role, "ND accommodations provided"
- [ ] "Async communication preferred", flexible schedule
- [ ] "Structured onboarding", clear processes

### Test Set 2: Neutral Jobs (Expected ND Score 5-7)
- [ ] Remote role, no ND mentions, standard flexibility
- [ ] Hybrid role, some flexibility
- [ ] Standard office job, no red flags

### Test Set 3: ND-Challenging Jobs (Expected ND Score 1-4)
- [ ] Open office, "fast-paced environment"
- [ ] "Constant collaboration", in-office required
- [ ] "Thrives in ambiguity", high-pressure

### Test Set 4: Salary Variations
- [ ] Hourly: $35/hr (should convert to $72.8K annual)
- [ ] Hourly: $50/hr (should convert to $104K annual)
- [ ] Annual: $95K (should stay as-is)
- [ ] Contract: $85/hr (should convert to $176.8K annual)

---

## Priority Order

1. **High**: Update ND Friendliness criteria with examples
2. **High**: Add ND-specific system context
3. **Medium**: Add hourly salary detection and conversion
4. **Low**: Consider adding Salary_Type__c field (future enhancement)

---

## Files to Modify

1. **ClaudeAPIService.cls** - Lines 214-244 (buildJobAnalysisPrompt method)
2. **JobPostingAnalyzer.cls** - System context when calling analyzeJobPosting

---

**Would you like me to implement these fixes now?**

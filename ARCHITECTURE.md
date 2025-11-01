# 🏗️ System Architecture - Job Search Assistant

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         SALESFORCE ORG                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    USER INTERFACE                         │  │
│  │  (Currently: Standard Salesforce UI)                     │  │
│  │  (Future: Lightning Web Components + Mobile App)         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                             │                                   │
│                             ↓                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  BUSINESS LOGIC LAYER                     │  │
│  │                                                           │  │
│  │  JobPostingAnalyzer.cls                                  │  │
│  │  ├─ analyzeJob()                                         │  │
│  │  ├─ buildHolisticSystemContext()                        │  │
│  │  ├─ parseAnalysisResponse()                             │  │
│  │  └─ updateJobWithAnalysis()                             │  │
│  │                                                           │  │
│  │  Implements:                                             │  │
│  │  • Your manifestation goals ($155K target)              │  │
│  │  • Neurodivergent accommodations framework              │  │
│  │  • MUST HAVE / NICE TO HAVE scoring                     │  │
│  │  • Decision tree logic                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                             │                                   │
│                             ↓                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   API SERVICE LAYER                       │  │
│  │                                                           │  │
│  │  ClaudeAPIService.cls                                    │  │
│  │  ├─ analyzeJobPosting()                                 │  │
│  │  ├─ buildJobAnalysisRequest()                           │  │
│  │  ├─ sendRequest()                                       │  │
│  │  ├─ parseResponse()                                     │  │
│  │  └─ extractTextContent()                                │  │
│  │                                                           │  │
│  │  Handles:                                                │  │
│  │  • HTTP request/response                                │  │
│  │  • JSON serialization/deserialization                   │  │
│  │  • Error handling & retries                             │  │
│  │  • Logging & debugging                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                             │                                   │
│                             ↓                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │               SECURITY & AUTH LAYER                       │  │
│  │                                                           │  │
│  │  Named Credential: Claude_API                            │  │
│  │  ├─ Endpoint: https://api.anthropic.com                 │  │
│  │  ├─ API Key: sk-ant-api03-... (encrypted)              │  │
│  │  ├─ Headers: x-api-key, anthropic-version              │  │
│  │  └─ Auto-inject authentication                          │  │
│  │                                                           │  │
│  │  Remote Site Setting:                                    │  │
│  │  └─ Allows callouts to anthropic.com                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                             │                                   │
│                             ↓                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                     DATA LAYER                            │  │
│  │                                                           │  │
│  │  Job_Posting__c (Custom Object)                          │  │
│  │  ├─ Title__c, Company__c, Location__c                   │  │
│  │  ├─ Salary_Min__c, Salary_Max__c                        │  │
│  │  ├─ Workplace_Type__c, Remote_Policy__c                 │  │
│  │  ├─ Description__c, URL__c                              │  │
│  │  ├─ Fit_Score__c (NEW - AI calculated)                  │  │
│  │  ├─ ND_Friendliness_Score__c                            │  │
│  │  ├─ Green_Flags__c, Red_Flags__c                        │  │
│  │  ├─ Application_Status__c (NEW - pipeline tracking)     │  │
│  │  ├─ Research_JSON__c (full Claude response)             │  │
│  │  └─ Research_Date__c                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS (callout)
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    ANTHROPIC CLAUDE API                         │
│                   https://api.anthropic.com                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  POST /v1/messages                                             │
│                                                                 │
│  Request:                                                       │
│  {                                                              │
│    "model": "claude-3-5-sonnet-20241022",                      │
│    "max_tokens": 4000,                                         │
│    "system": ["<Your holistic context>"],                      │
│    "messages": [{                                               │
│      "role": "user",                                           │
│      "content": "Analyze this job posting..."                  │
│    }]                                                           │
│  }                                                              │
│                                                                 │
│  Response:                                                      │
│  {                                                              │
│    "id": "msg_...",                                            │
│    "content": [{                                                │
│      "type": "text",                                           │
│      "text": "{                                                 │
│        \"fit_score\": 9.2,                                      │
│        \"nd_friendliness_score\": 8.5,                         │
│        \"green_flags\": \"• Remote work...\",                   │
│        \"red_flags\": \"• Startup pace...\",                    │
│        \"recommendation\": \"HIGH PRIORITY\",                   │
│        \"reasoning\": \"This role...\"                          │
│      }"                                                         │
│    }]                                                           │
│  }                                                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Diagram

### Creating and Analyzing a Job Posting

```
┌──────────────────┐
│  User Action     │
│  Create Job      │
│  Posting Record  │
└────────┬─────────┘
         │
         │ [Manual Trigger - for now]
         │ [Future: Auto-trigger on insert]
         ↓
┌─────────────────────────────────────────────────────┐
│  JobPostingAnalyzer.analyzeJob(jobPosting)         │
│                                                     │
│  Step 1: Build Holistic Context                    │
│  ├─ Manifestation goals ($155K target)            │
│  ├─ Neurodivergent needs (ADHD/Bipolar)           │
│  ├─ MUST HAVEs (remote, flexible, ND-friendly)    │
│  └─ NICE TO HAVEs (Agentforce +2, etc.)           │
│                                                     │
│  Step 2: Call Claude API                           │
│  └─ ClaudeAPIService.analyzeJobPosting()           │
└──────────────────┬──────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────┐
│  ClaudeAPIService.sendRequest()                    │
│                                                     │
│  1. Build HTTP Request                             │
│     • Endpoint: callout:Claude_API/v1/messages    │
│     • Method: POST                                 │
│     • Timeout: 60 seconds                          │
│     • Headers: (auto-added by Named Credential)    │
│       - Content-Type: application/json             │
│       - anthropic-version: 2023-06-01              │
│       - x-api-key: sk-ant-api03-...                │
│                                                     │
│  2. Send Request Body                              │
│     {                                               │
│       "model": "claude-3-5-sonnet-20241022",       │
│       "max_tokens": 4000,                          │
│       "system": ["<holistic context>"],            │
│       "messages": [{                                │
│         "role": "user",                            │
│         "content": "Analyze job: Title: ..."       │
│       }]                                            │
│     }                                               │
│                                                     │
│  3. Receive Response (5-15 seconds)                │
│     {                                               │
│       "content": [{                                 │
│         "text": "{ fit_score: 9.2, ... }"          │
│       }]                                            │
│     }                                               │
└──────────────────┬──────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────┐
│  ClaudeAPIService.parseResponse()                  │
│                                                     │
│  Extract text from response.content[0].text        │
│  Return ClaudeResponse object                      │
└──────────────────┬──────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────┐
│  JobPostingAnalyzer.parseAnalysisResponse()        │
│                                                     │
│  1. Extract JSON from text                         │
│     • Handle markdown wrappers (```json...```)     │
│     • Find JSON object ({ ... })                   │
│                                                     │
│  2. Deserialize JSON                               │
│     Map<String, Object> jsonMap =                  │
│       JSON.deserializeUntyped(jsonText);           │
│                                                     │
│  3. Extract fields with type safety                │
│     • fit_score → Decimal                          │
│     • nd_friendliness_score → Decimal              │
│     • green_flags → String                         │
│     • red_flags → String                           │
│     • recommendation → String                      │
│     • reasoning → String                           │
│                                                     │
│  4. Return JobAnalysisResult object                │
└──────────────────┬──────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────┐
│  JobPostingAnalyzer.updateJobWithAnalysis()        │
│                                                     │
│  Update Job_Posting__c fields:                     │
│  • Fit_Score__c = 9.2                              │
│  • ND_Friendliness_Score__c = 8.5                  │
│  • Green_Flags__c = "• Remote work\n• Agentforce"  │
│  • Red_Flags__c = "• Startup pace"                 │
│  • Research_JSON__c = <full response>              │
│  • Research_Date__c = 2025-10-26 14:30:00          │
│                                                     │
│  DML: update jobPosting;                           │
└──────────────────┬──────────────────────────────────┘
                   │
                   ↓
         ┌─────────────────┐
         │  Database       │
         │  Record Updated │
         │  ✅ Complete     │
         └─────────────────┘
```

---

## Security Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 SECURITY LAYERS                          │
└─────────────────────────────────────────────────────────┘

Layer 1: Salesforce Platform Security
├─ User authentication (login.salesforce.com)
├─ Object-level security (Job_Posting__c access)
├─ Field-level security (who can see API key fields)
└─ Sharing rules (private/public records)

Layer 2: Named Credential (Authentication)
├─ API key stored encrypted by Salesforce
├─ Auto-inject headers on HTTP requests
├─ Never exposed in code or logs
├─ Managed in Setup → Named Credentials
└─ Rotatable without code changes

Layer 3: Remote Site Settings (Network Access)
├─ Whitelist approved external endpoints
├─ Blocks unauthorized callouts
├─ https://api.anthropic.com explicitly allowed
└─ All other domains blocked by default

Layer 4: Code-Level Security
├─ with sharing class enforcement
├─ Input validation (required fields)
├─ Exception handling (try/catch)
├─ Timeout protection (60 second max)
├─ Debug log sanitization (no API keys logged)
└─ JSON parsing error handling

Layer 5: API Key Best Practices
├─ ✅ Stored in Named Credential (encrypted)
├─ ✅ Never hardcoded in Apex
├─ ✅ Never committed to Git
├─ ✅ Rotatable via Setup UI only
└─ ❌ NEVER log or expose in debug statements
```

---

## Class Diagram

```
┌─────────────────────────────────────────────────┐
│          ClaudeAPIService                        │
├─────────────────────────────────────────────────┤
│ - API_VERSION: String = "2023-06-01"            │
│ - MODEL: String = "claude-3-5-sonnet..."        │
│ - MAX_TOKENS: Integer = 4000                    │
│ - TIMEOUT_MS: Integer = 60000                   │
│ - API_ENDPOINT: String                          │
├─────────────────────────────────────────────────┤
│ + analyzeJobPosting(job, context): Response     │
│ - buildJobAnalysisRequest(job, ctx): Request    │
│ - buildJobAnalysisPrompt(job): String           │
│ - sendRequest(request): HttpResponse            │
│ - parseResponse(response): ClaudeResponse       │
│ + extractTextContent(response): String          │
└─────────────────────────────────────────────────┘
                     │
                     │ uses
                     ↓
┌─────────────────────────────────────────────────┐
│          ClaudeRequest (inner class)             │
├─────────────────────────────────────────────────┤
│ + model: String                                  │
│ + max_tokens: Integer                            │
│ + messages: List<Message>                        │
│ + system: List<String>                           │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│          ClaudeResponse (inner class)            │
├─────────────────────────────────────────────────┤
│ + id: String                                     │
│ + type: String                                   │
│ + role: String                                   │
│ + content: List<Content>                         │
│ + model: String                                  │
│ + stop_reason: String                            │
│ + usage: Usage                                   │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│          JobPostingAnalyzer                      │
├─────────────────────────────────────────────────┤
│ [No instance variables - all static]            │
├─────────────────────────────────────────────────┤
│ + analyzeJob(job): JobAnalysisResult            │
│ - buildHolisticSystemContext(): String           │
│ - parseAnalysisResponse(text): Result            │
│ - extractJsonFromResponse(text): String          │
│ + updateJobWithAnalysis(job, result): void       │
└─────────────────────────────────────────────────┘
                     │
                     │ uses
                     ↓
┌─────────────────────────────────────────────────┐
│     JobAnalysisResult (inner class)              │
├─────────────────────────────────────────────────┤
│ + fitScore: Decimal                              │
│ + ndFriendlinessScore: Decimal                   │
│ + greenFlags: String                             │
│ + redFlags: String                               │
│ + recommendation: String                         │
│ + reasoning: String                              │
│ + fullResponse: String                           │
└─────────────────────────────────────────────────┘
```

---

## Future Architecture (Phase 2-4)

```
┌────────────────────────────────────────────────────────────┐
│                    TIER 1: INTELLIGENCE LAYER              │
│                     (Claude API + Skills)                  │
└────────────────────────────────────────────────────────────┘
                              │
                ┌─────────────┴──────────────┐
                ↓                            ↓
┌──────────────────────────┐    ┌──────────────────────────┐
│   TIER 2a: BACKEND       │    │  TIER 2b: MOBILE APP     │
│   Salesforce             │◄───│  React Native            │
│   - Custom Objects       │    │  - Local SQLite          │
│   - Apex REST APIs       │────│  - Offline-first         │
│   - Platform Events      │    │  - Push Notifications    │
└──────────────────────────┘    └──────────────────────────┘
                │                            │
                └─────────────┬──────────────┘
                              ↓
┌────────────────────────────────────────────────────────────┐
│              TIER 3: INTERFACE LAYER                       │
│                                                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │ Salesforce   │  │ Mobile App   │  │ Voice        │    │
│  │ LWC          │  │ Dashboard    │  │ Commands     │    │
│  │ Dashboard    │  │              │  │ (Siri)       │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
└────────────────────────────────────────────────────────────┘
```

### Future Components (Coming Soon)

**Week 2-3: Automation**
- `JobPostingTrigger.trigger` - Auto-analyze on insert
- `JobBatchAnalyzer.cls` - Analyze 100+ jobs
- `JobAnalysisScheduler.cls` - Weekly re-analysis

**Week 3-4: Lightning Web Components**
- `jobSearchDashboard` - Main dashboard
- `jobPostingCard` - Individual job display
- `dailyContextTracker` - Energy/mood check-in
- `manifestationProgress` - Goals tracker

**Week 5: REST APIs**
- `JobSearchRestService.cls` - Mobile endpoints
- `/services/apexrest/jobs/search`
- `/services/apexrest/jobs/analyze`
- `/services/apexrest/context/daily`

**Week 6-10: Mobile App**
- React Native + Salesforce Mobile SDK
- Local SQLite database
- Offline-first architecture
- Push notifications

**Week 11-12: Proactive Intelligence**
- `ClaudeScheduler.cls` - Daily insights
- `JobFitScoringEngine.cls` - Advanced scoring
- `ScheduleOptimizer.cls` - Adaptive scheduling

---

## API Rate Limits & Performance

```
Claude API Limits:
├─ Tier 1 (Default): 50 requests/min, 40,000 tokens/min
├─ Tier 2: 500 requests/min, 80,000 tokens/min
└─ Your usage: ~1-10 jobs/day = well within limits

Request Size:
├─ Typical system context: ~2,500 tokens
├─ Typical job description: ~500-1,500 tokens
├─ Total input: ~3,000-4,000 tokens per request
└─ Response: ~500-1,000 tokens

Response Time:
├─ API latency: ~3-8 seconds
├─ Salesforce HTTP callout: ~1-2 seconds
├─ Parsing + DB update: ~0.5 seconds
└─ Total: 5-15 seconds per job

Cost Estimate:
├─ Input: ~$0.003 per job (3,000 tokens * $3/million)
├─ Output: ~$0.015 per job (1,000 tokens * $15/million)
├─ Total: ~$0.02 per job analyzed
└─ 100 jobs = ~$2.00 (extremely affordable!)
```

---

## Error Handling Flow

```
User Action: Analyze Job
        │
        ↓
JobPostingAnalyzer.analyzeJob()
        │
        ├─ try {
        │     buildHolisticSystemContext()
        │     ├─ Error? → throw JobAnalysisException
        │     │
        │     ClaudeAPIService.analyzeJobPosting()
        │     ├─ HTTP Error (401, 429, 500)?
        │     │   → throw ClaudeAPIException
        │     │   → Caught in try/catch
        │     │   → Logged with details
        │     │   → Re-thrown to caller
        │     │
        │     parseAnalysisResponse()
        │     ├─ JSON Parse Error?
        │     │   → Log error
        │     │   → Return partial result
        │     │   → Don't throw (graceful degradation)
        │     │
        │     updateJobWithAnalysis()
        │     └─ DML Error?
        │         → throw JobAnalysisException
        │         → Logged with record ID
        │
        └─ } catch (Exception e) {
              System.debug(ERROR, e.getMessage())
              System.debug(ERROR, e.getStackTraceString())
              throw new JobAnalysisException(
                'Failed to analyze job: ' + e.getMessage()
              )
            }
```

---

## Deployment Architecture

```
Development Flow:
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│   Local      │       │  Salesforce  │       │  Salesforce  │
│   VS Code    │──────▶│   Scratch    │──────▶│  Production  │
│              │ push  │     Org      │ test  │     Org      │
└──────────────┘       └──────────────┘       └──────────────┘
       │                       │                       │
       │ Git commit            │ Validation            │ Final deploy
       ↓                       ↓                       ↓
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│   GitHub     │       │   Run Tests  │       │    Users     │
│  Repository  │       │   Coverage   │       │   Access     │
└──────────────┘       └──────────────┘       └──────────────┘

Metadata Components:
├─ ApexClass: ClaudeAPIService, JobPostingAnalyzer
├─ NamedCredential: Claude_API
├─ CustomField: Fit_Score__c, Application_Status__c
├─ RemoteSiteSetting: Claude_API
└─ All deployed together in one package
```

---

## Current State Summary

✅ **Implemented**:
- Core API integration (ClaudeAPIService)
- Business logic (JobPostingAnalyzer)
- Secure authentication (Named Credential)
- Data model (Fit_Score__c, Application_Status__c)
- Manual analysis workflow

❌ **Not Yet Implemented**:
- Auto-analysis trigger
- Batch processing
- Scheduled jobs
- Lightning Web Components
- Mobile app
- Voice commands

📊 **Test Coverage**: 0% (test classes coming next)

🚀 **Ready for**: Manual analysis + deployment to Salesforce org

---

This architecture is designed to:
- ✅ Be secure by default
- ✅ Scale to 1000+ jobs
- ✅ Extend easily (triggers, LWC, mobile)
- ✅ Teach you Salesforce + AI integration
- ✅ Demonstrate full-stack development skills

**Next**: Deploy and test! See DEPLOYMENT_GUIDE.md 🎯

# 🛠️ REMAINING BUILD PLAN
## Features Still Needed to Complete Original Vision
**Created:** November 12, 2025  
**Purpose:** Exact specification of what needs to be built to match the consolidated implementation plan

---

## 🎯 EXECUTIVE SUMMARY

Based on your consolidated implementation plan and current state analysis:

**PWA Current State**: 90% complete with basic features + bonus content (meal planning, therapy tools)  
**Salesforce Current State**: 77% complete with enterprise architecture  
**Gap to Fill**: Advanced tracking, analytics, and integration features from consolidated plan

---

## 📊 DATABASE SCHEMA - IMPLEMENTATION REQUIRED

### **These 9 Tables Must Be Built:**

All tables from your consolidated plan need implementation in BOTH systems:

#### **1. WINS TABLE** ⭐⭐⭐⭐⭐ CRITICAL

**Salesforce Object: `Win__c`**
```sql
CREATE TABLE wins (
    id INTEGER PRIMARY KEY,
    date DATE NOT NULL,
    win_text TEXT NOT NULL,
    category TEXT, -- 'job_search', 'personal', 'health', 'learning'
    keywords TEXT, -- JSON array
    linked_to_imposter_session BOOLEAN DEFAULT false,
    celebration_shown BOOLEAN DEFAULT false,
    created_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
)
```

**Salesforce Implementation:**
- Custom Object: `Win__c`
- Fields:
  - `Date__c` (Date) - Required
  - `Win_Text__c` (Long Text 32000) - Required
  - `Category__c` (Picklist: Job Search, Personal, Health, Learning)
  - `Keywords__c` (Long Text) - JSON array stored as text
  - `Linked_to_Imposter_Session__c` (Checkbox)
  - `Celebration_Shown__c` (Checkbox)
- Relationships:
  - Lookup to `Daily_Routine__c` (optional)
  - Lookup to `Imposter_Syndrome_Session__c` (optional)

**PWA Implementation:**
```javascript
// localStorage schema
const win = {
  id: generateUUID(),
  date: new Date().toISOString(),
  winText: "Completed certification study",
  category: "learning",
  keywords: ["certification", "study", "salesforce"],
  linkedToImposterSession: false,
  celebrationShown: false
};
```

**Features Required:**
- ✅ Rich text parser (extract wins from bullets, lists, paragraphs)
- ✅ Auto-categorization (job_search, personal, health, learning)
- ✅ Keyword extraction
- ✅ Link to imposter syndrome sessions
- ✅ Weekly wins dashboard with analytics

---

#### **2. DAILY_MOOD_TRACKING TABLE** ⭐⭐⭐⭐⭐ CRITICAL

**Salesforce Object: `Daily_Mood_Tracking__c`**
```sql
CREATE TABLE daily_mood_tracking (
    id INTEGER PRIMARY KEY,
    date DATE NOT NULL,
    morning_mood INTEGER, -- 1-10
    morning_energy INTEGER, -- 1-10
    morning_time DATETIME,
    midday_mood INTEGER, -- 1-10
    midday_energy INTEGER, -- 1-10
    midday_time DATETIME,
    evening_mood INTEGER, -- 1-10
    evening_energy INTEGER, -- 1-10
    evening_time DATETIME
)
```

**Salesforce Implementation:**
- Custom Object: `Daily_Mood_Tracking__c`
- Fields:
  - `Date__c` (Date) - Unique, Required
  - `Morning_Mood__c` (Number 2,0) - Range 1-10
  - `Morning_Energy__c` (Number 2,0) - Range 1-10
  - `Morning_Time__c` (DateTime)
  - `Midday_Mood__c` (Number 2,0) - Range 1-10
  - `Midday_Energy__c` (Number 2,0) - Range 1-10
  - `Midday_Time__c` (DateTime)
  - `Evening_Mood__c` (Number 2,0) - Range 1-10
  - `Evening_Energy__c` (Number 2,0) - Range 1-10
  - `Evening_Time__c` (DateTime)
- Validation Rules:
  - Morning time < 11am
  - Midday time between 11am-3pm
  - Evening time between 5pm-10pm
  - Mood/Energy values between 1-10

**PWA Implementation:**
```javascript
const dailyMoodTracking = {
  id: generateUUID(),
  date: "2025-11-12",
  morningMood: 7,
  morningEnergy: 6,
  morningTime: "2025-11-12T09:30:00",
  middayMood: 8,
  middayEnergy: 7,
  middayTime: "2025-11-12T13:00:00",
  eveningMood: 6,
  eveningEnergy: 5,
  eveningTime: "2025-11-12T19:00:00"
};
```

**Features Required:**
- ✅ 3x daily prompts (morning, midday, evening)
- ✅ Time window enforcement
- ✅ Notification reminders for each window
- ✅ Daily mood graph showing 3 data points
- ✅ Trend analysis over time
- ✅ Integration with energy-adaptive scheduling

---

#### **3. GRATITUDE_ENTRIES TABLE** ⭐⭐⭐⭐ HIGH

**Salesforce Object: `Gratitude_Entry__c`**
```sql
CREATE TABLE gratitude_entries (
    id INTEGER PRIMARY KEY,
    date DATE NOT NULL,
    timestamp DATETIME NOT NULL,
    entry_text TEXT NOT NULL,
    keywords TEXT, -- JSON array
    mood_at_time INTEGER -- 1-10
)
```

**Salesforce Implementation:**
- Custom Object: `Gratitude_Entry__c`
- Fields:
  - `Date__c` (Date) - Required
  - `Timestamp__c` (DateTime) - Auto-populated
  - `Entry_Text__c` (Long Text 32000) - Required
  - `Keywords__c` (Long Text) - JSON array
  - `Mood_At_Time__c` (Number 2,0) - Optional
- Relationships:
  - Lookup to `Daily_Routine__c` (optional)

**PWA Implementation:**
```javascript
const gratitudeEntry = {
  id: generateUUID(),
  date: "2025-11-12",
  timestamp: new Date().toISOString(),
  entryText: "Grateful for supportive partner",
  keywords: ["family", "support", "partner"],
  moodAtTime: 8
};
```

**Features Required:**
- ✅ Separate gratitude journal tab
- ✅ Multiple entries per day allowed
- ✅ Auto-keyword extraction
- ✅ Historical view with search
- ✅ Weekly gratitude summary

---

#### **4. THERAPY_STEP_COMPLETIONS TABLE** ⭐⭐⭐ MEDIUM

**Salesforce Object: `Therapy_Step_Completion__c`**
```sql
CREATE TABLE therapy_step_completions (
    id INTEGER PRIMARY KEY,
    step_id TEXT NOT NULL,
    completion_date DATE NOT NULL,
    effectiveness INTEGER, -- 1-10
    notes TEXT
)
```

**Salesforce Implementation:**
- Custom Object: `Therapy_Step_Completion__c`
- Fields:
  - `Step_ID__c` (Text 255) - Required (e.g., "cbt_thought_record")
  - `Completion_Date__c` (Date) - Required
  - `Effectiveness__c` (Number 2,0) - Range 1-10
  - `Notes__c` (Long Text 32000)
  - `Step_Name__c` (Formula Text) - Lookup step name from Step_ID
  - `Category__c` (Formula Text) - CBT, DBT, ACT, Grounding
- Roll-up Summary Fields on Custom Metadata or Config:
  - `Total_Completions__c` per step_id

**PWA Implementation:**
```javascript
const therapyCompletion = {
  id: generateUUID(),
  stepId: "cbt_thought_record",
  completionDate: "2025-11-12",
  effectiveness: 8,
  notes: "Helped me recognize catastrophizing pattern"
};

// Counter stored separately
const therapyCounters = {
  "cbt_thought_record": 15,
  "dbt_tipp": 8,
  "act_defusion": 12,
  "grounding_54321": 23
};
```

**Features Required:**
- ✅ Completion counter on each therapy step card
- ✅ Effectiveness rating (1-10) after each use
- ✅ Notes field for reflections
- ✅ Historical view of past therapy sessions
- ✅ Most effective technique analysis

---

#### **5. IMPOSTER_SYNDROME_SESSIONS TABLE** ⭐⭐⭐⭐⭐ CRITICAL

**Salesforce Object: `Imposter_Syndrome_Session__c`**
```sql
CREATE TABLE imposter_syndrome_sessions (
    id INTEGER PRIMARY KEY,
    session_date DATETIME NOT NULL,
    imposter_thought TEXT NOT NULL,
    countering_facts TEXT, -- JSON array
    believability_before INTEGER, -- 1-10
    believability_after INTEGER, -- 1-10
    linked_achievements TEXT -- JSON array of achievement IDs
)
```

**Salesforce Implementation:**
- Custom Object: `Imposter_Syndrome_Session__c`
- Fields:
  - `Session_Date__c` (DateTime) - Auto-populated
  - `Imposter_Thought__c` (Long Text 32000) - Required
  - `Countering_Facts__c` (Long Text 32000) - JSON array
  - `Believability_Before__c` (Number 2,0) - Range 1-10
  - `Believability_After__c` (Number 2,0) - Range 1-10
  - `Linked_Achievements__c` (Long Text) - JSON array of Win__c IDs
  - `Effectiveness__c` (Formula Percent) - (Before - After) / Before
- Relationships:
  - Master-Detail to `Daily_Routine__c` OR standalone
  - Junction object to link multiple `Win__c` records

**PWA Implementation:**
```javascript
const imposterSession = {
  id: generateUUID(),
  sessionDate: new Date().toISOString(),
  imposterThought: "I'm not qualified for this role",
  counteringFacts: [
    "I have 10+ years experience",
    "I earned 96 Trailhead badges",
    "I built a complex Salesforce platform from scratch"
  ],
  believabilityBefore: 8,
  believabilityAfter: 3,
  linkedAchievements: ["win-uuid-1", "win-uuid-2", "win-uuid-3"]
};
```

**Features Required:**
- ✅ Auto-detect imposter syndrome language
- ✅ Automatically pull countering facts from Win__c records
- ✅ Before/after believability ratings
- ✅ Effectiveness tracking over time
- ✅ Link to specific achievements as evidence
- ✅ Historical pattern analysis

---

#### **6. NEGATIVE_THOUGHT_ANALYSIS TABLE** ⭐⭐⭐⭐ HIGH

**Salesforce Object: `Negative_Thought_Analysis__c`**
```sql
CREATE TABLE negative_thought_analysis (
    id INTEGER PRIMARY KEY,
    detected_at DATETIME NOT NULL,
    original_text TEXT NOT NULL,
    category TEXT, -- 'catastrophizing', 'black-and-white', 'overgeneralization'
    suggested_reframe TEXT,
    mental_health_best_practice TEXT,
    user_reframe TEXT, -- What user actually wrote
    helpfulness INTEGER -- 1-10
)
```

**Salesforce Implementation:**
- Custom Object: `Negative_Thought_Analysis__c`
- Fields:
  - `Detected_At__c` (DateTime) - Auto-populated
  - `Original_Text__c` (Long Text 32000) - Required
  - `Category__c` (Picklist: Catastrophizing, Black-and-White, Overgeneralization, Mind Reading, Fortune Telling, Emotional Reasoning)
  - `Suggested_Reframe__c` (Long Text 32000)
  - `Mental_Health_Best_Practice__c` (Long Text 32000)
  - `User_Reframe__c` (Long Text 32000) - User's actual reframe
  - `Helpfulness__c` (Number 2,0) - Range 1-10
- Apex Class: `NegativeThoughtDetector.cls`

**PWA Implementation:**
```javascript
const negativeThought = {
  id: generateUUID(),
  detectedAt: new Date().toISOString(),
  originalText: "I'll never get a job",
  category: "catastrophizing",
  suggestedReframe: "I haven't found the right job yet, but I'm actively working toward it",
  mentalHealthBestPractice: "CBT identifies catastrophizing as predicting the worst possible outcome. Counter by asking 'What evidence supports this?' and 'What's a more balanced perspective?'",
  userReframe: "I've submitted 10 quality applications and am building valuable skills",
  helpfulness: 9
};
```

**Features Required:**
- ✅ NLP-based detection of negative thought patterns
- ✅ Auto-categorization (catastrophizing, etc.)
- ✅ Suggested reframe generation
- ✅ Mental health best practice education
- ✅ User can write their own reframe
- ✅ Rate helpfulness for ML improvement

**Detection Patterns:**
```javascript
const negativePatterns = {
  catastrophizing: /never|always|worst|terrible|disaster/i,
  blackAndWhite: /either|or|must|should|have to|all or nothing/i,
  overgeneralization: /everyone|no one|everything|nothing|all|none/i,
  mindReading: /they think|he thinks|she thinks|people think/i,
  fortuneTelling: /will never|going to fail|won't work/i,
  emotionalReasoning: /I feel .* therefore/i
};
```

---

#### **7. ROUTINE_TASK_TIMERS TABLE** ⭐⭐⭐ MEDIUM

**Salesforce Object: `Routine_Task_Timer__c`**
```sql
CREATE TABLE routine_task_timers (
    id INTEGER PRIMARY KEY,
    task_name TEXT NOT NULL,
    scheduled_duration INTEGER, -- in minutes
    actual_duration INTEGER, -- in minutes
    completed_date DATETIME,
    was_helpful BOOLEAN
)
```

**Salesforce Implementation:**
- Custom Object: `Routine_Task_Timer__c`
- Fields:
  - `Task_Name__c` (Text 255) - Required
  - `Scheduled_Duration__c` (Number 3,0) - Minutes
  - `Actual_Duration__c` (Number 3,0) - Minutes
  - `Completed_Date__c` (DateTime)
  - `Was_Helpful__c` (Checkbox)
  - `Routine_Type__c` (Picklist: Morning, Midday, Evening)
  - `Variance__c` (Formula Number) - Actual - Scheduled
- Relationships:
  - Lookup to `Daily_Routine__c`

**PWA Implementation:**
```javascript
const taskTimer = {
  id: generateUUID(),
  taskName: "Garden break",
  scheduledDuration: 15, // minutes
  actualDuration: 18,
  completedDate: new Date().toISOString(),
  wasHelpful: true,
  routineType: "midday"
};

// Timer component state
const timerState = {
  taskId: "garden-break",
  startTime: Date.now(),
  scheduledEnd: Date.now() + (15 * 60 * 1000),
  isRunning: true,
  isPaused: false
};
```

**Features Required:**
- ✅ Built-in countdown timers for midday tasks
- ✅ Track scheduled vs actual time
- ✅ Notification when timer completes
- ✅ "Was this helpful?" feedback
- ✅ Analytics on time estimation accuracy

---

#### **8. EVENING_ROUTINE_TRACKING TABLE** ⭐⭐⭐⭐⭐ CRITICAL

**Salesforce Object: `Evening_Routine_Tracking__c`**
```sql
CREATE TABLE evening_routine_tracking (
    id INTEGER PRIMARY KEY,
    date DATE NOT NULL,
    hard_stop_time DATETIME, -- When 5:15 notification fired
    routine_start_time DATETIME, -- When user started evening routine
    routine_complete_time DATETIME,
    went_overtime BOOLEAN,
    overtime_minutes INTEGER,
    overtime_reason TEXT
)
```

**Salesforce Implementation:**
- Custom Object: `Evening_Routine_Tracking__c`
- Fields:
  - `Date__c` (Date) - Unique, Required
  - `Hard_Stop_Time__c` (DateTime) - Default 5:15 PM
  - `Routine_Start_Time__c` (DateTime)
  - `Routine_Complete_Time__c` (DateTime)
  - `Went_Overtime__c` (Checkbox)
  - `Overtime_Minutes__c` (Formula Number) - If complete > 10 PM
  - `Overtime_Reason__c` (Long Text 32000)
  - `Duration_Minutes__c` (Formula Number) - Complete - Start
- Validation Rule:
  - Hard_Stop_Time must be 5:15 PM or later

**PWA Implementation:**
```javascript
const eveningRoutine = {
  id: generateUUID(),
  date: "2025-11-12",
  hardStopTime: "2025-11-12T17:15:00",
  routineStartTime: "2025-11-12T17:30:00",
  routineCompleteTime: "2025-11-12T21:45:00",
  wentOvertime: false, // Before 10 PM
  overtimeMinutes: 0,
  overtimeReason: null
};

// Notification system
const hardStopAlarm = {
  time: "17:15", // 5:15 PM
  recurring: true,
  sound: "gentle-bell",
  vibrate: [500, 250, 500],
  message: "🛑 HARD STOP TIME! Begin evening routine now."
};
```

**Features Required:**
- ✅ 5:15 PM hard stop alarm (non-dismissible until acknowledged)
- ✅ Evening routine window: 5:15 PM - 10:00 PM
- ✅ Overtime warnings after 10 PM
- ✅ Overtime reason tracking
- ✅ Weekly overtime analysis
- ✅ Celebration for completing before 10 PM

---

#### **9. JOURNAL_KEYWORDS TABLE** ⭐⭐⭐ MEDIUM

**Salesforce Object: `Journal_Keyword__c`**
```sql
CREATE TABLE journal_keywords (
    id INTEGER PRIMARY KEY,
    journal_entry_id INTEGER NOT NULL,
    keyword TEXT NOT NULL,
    auto_generated BOOLEAN DEFAULT true,
    FOREIGN KEY (journal_entry_id) REFERENCES daily_tracking(id)
)
```

**Salesforce Implementation:**
- Custom Object: `Journal_Keyword__c`
- Fields:
  - `Journal_Entry__c` (Master-Detail to `Daily_Routine__c`)
  - `Keyword__c` (Text 80) - Required
  - `Auto_Generated__c` (Checkbox) - Default TRUE
  - `Keyword_Type__c` (Picklist: Mood, Activity, Health, Goal)
- Junction Object for many-to-many relationship

**PWA Implementation:**
```javascript
const journalKeyword = {
  id: generateUUID(),
  journalEntryId: "entry-uuid-123",
  keyword: "job search",
  autoGenerated: true,
  keywordType: "activity"
};

// Keyword extraction engine
const keywordExtractor = {
  moodKeywords: ["happy", "anxious", "productive", "tired"],
  activityKeywords: ["job search", "exercise", "garden", "meditation"],
  healthKeywords: ["pain", "energy", "medication", "blood sugar"],
  goalKeywords: ["application", "interview", "certification", "learning"]
};
```

**Features Required:**
- ✅ Auto-generate keywords from journal entries
- ✅ Manual keyword addition option
- ✅ Keyword-based search across all journal entries
- ✅ Keyword cloud visualization
- ✅ Trending keywords over time

---

#### **10. WEEKLY_WIN_SUMMARIES TABLE** ⭐⭐⭐ MEDIUM

**Salesforce Object: `Weekly_Win_Summary__c`**
```sql
CREATE TABLE weekly_win_summaries (
    id INTEGER PRIMARY KEY,
    week_start_date DATE NOT NULL,
    total_wins INTEGER,
    most_productive_day TEXT,
    top_category TEXT,
    insights TEXT -- JSON array
)
```

**Salesforce Implementation:**
- Custom Object: `Weekly_Win_Summary__c`
- Fields:
  - `Week_Start_Date__c` (Date) - Unique, Monday of week
  - `Total_Wins__c` (Roll-up Summary) - COUNT(Win__c)
  - `Most_Productive_Day__c` (Formula Text) - Day with most wins
  - `Top_Category__c` (Formula Text) - Category with most wins
  - `Insights__c` (Long Text) - JSON array
  - `Job_Search_Wins__c` (Roll-up Summary)
  - `Personal_Wins__c` (Roll-up Summary)
  - `Health_Wins__c` (Roll-up Summary)
  - `Learning_Wins__c` (Roll-up Summary)
- Scheduled Apex: Generate summaries every Monday

**PWA Implementation:**
```javascript
const weeklySummary = {
  id: generateUUID(),
  weekStartDate: "2025-11-11", // Monday
  totalWins: 23,
  mostProductiveDay: "Wednesday",
  topCategory: "job_search",
  insights: [
    "Job search wins increased 40% this week",
    "Most productive after morning exercise",
    "Garden breaks correlate with better mood"
  ],
  jobSearchWins: 10,
  personalWins: 7,
  healthWins: 4,
  learningWins: 2
};
```

**Features Required:**
- ✅ Auto-generate weekly summaries every Monday
- ✅ Most productive day analysis
- ✅ Category breakdown
- ✅ AI-generated insights
- ✅ Week-over-week comparison
- ✅ Celebration for milestone weeks

---

## 🚀 CRITICAL MISSING FEATURES (Priority Order)

### **PHASE 1: CORE TRACKING (Week 1-2)** ⭐⭐⭐⭐⭐

#### **1.1 Rich Text Win Parser** 
**PWA Implementation:**
```javascript
class WinParser {
  parseWins(richText) {
    const wins = [];
    
    // Pattern 1: Bullet points
    const bulletPattern = /^[•\-\*]\s+(.+)$/gm;
    let match;
    while ((match = bulletPattern.exec(richText)) !== null) {
      wins.push(this.createWin(match[1]));
    }
    
    // Pattern 2: Numbered lists
    const numberedPattern = /^\d+\.\s+(.+)$/gm;
    while ((match = numberedPattern.exec(richText)) !== null) {
      wins.push(this.createWin(match[1]));
    }
    
    // Pattern 3: Line breaks (if no bullets/numbers)
    if (wins.length === 0) {
      richText.split('\n')
        .filter(line => line.trim())
        .forEach(line => wins.push(this.createWin(line)));
    }
    
    return wins;
  }
  
  createWin(text) {
    return {
      id: generateUUID(),
      text: text.trim(),
      date: new Date().toISOString().split('T')[0],
      category: this.categorizeWin(text),
      keywords: this.extractKeywords(text),
      linkedToImposterSession: false,
      celebrationShown: false
    };
  }
  
  categorizeWin(text) {
    const lowerText = text.toLowerCase();
    if (/job|application|interview|resume|linkedin/i.test(lowerText)) return 'job_search';
    if (/exercise|garden|health|walk|yoga/i.test(lowerText)) return 'health';
    if (/study|learn|certification|badge|course/i.test(lowerText)) return 'learning';
    return 'personal';
  }
  
  extractKeywords(text) {
    // Extract meaningful words (>3 chars, not common words)
    const commonWords = ['the', 'and', 'for', 'with', 'this', 'that', 'from'];
    return text.toLowerCase()
      .split(/\s+/)
      .filter(word => word.length > 3 && !commonWords.includes(word))
      .slice(0, 5); // Max 5 keywords
  }
}
```

**Salesforce Implementation:**
```apex
public class WinParserService {
    public class Win {
        public String text;
        public String category;
        public List<String> keywords;
    }
    
    public static List<Win> parseWins(String richText) {
        List<Win> wins = new List<Win>();
        
        // Split by bullets, numbers, or newlines
        List<String> lines = richText.split('\n');
        
        for (String line : lines) {
            line = line.trim();
            if (String.isBlank(line)) continue;
            
            // Remove bullets/numbers
            line = line.replaceFirst('^[•\\-\\*]\\s+', '');
            line = line.replaceFirst('^\\d+\\.\\s+', '');
            
            Win w = new Win();
            w.text = line;
            w.category = categorizeWin(line);
            w.keywords = extractKeywords(line);
            
            wins.add(w);
        }
        
        return wins;
    }
    
    private static String categorizeWin(String text) {
        text = text.toLowerCase();
        if (Pattern.matches('.*(?:job|application|interview|resume).*', text)) return 'job_search';
        if (Pattern.matches('.*(?:exercise|garden|health|walk).*', text)) return 'health';
        if (Pattern.matches('.*(?:study|learn|certification|badge).*', text)) return 'learning';
        return 'personal';
    }
    
    private static List<String> extractKeywords(String text) {
        Set<String> commonWords = new Set<String>{'the', 'and', 'for', 'with', 'this', 'that', 'from'};
        List<String> keywords = new List<String>();
        
        for (String word : text.toLowerCase().split('\\s+')) {
            if (word.length() > 3 && !commonWords.contains(word)) {
                keywords.add(word);
            }
            if (keywords.size() >= 5) break;
        }
        
        return keywords;
    }
}
```

---

#### **1.2 3x Daily Mood Tracking with Notifications**

**PWA Implementation:**
```javascript
// Notification scheduler
class MoodTracker {
  constructor() {
    this.scheduleNotifications();
  }
  
  scheduleNotifications() {
    // Morning check-in (9:00 AM)
    this.scheduleNotification('morning', '09:00', 
      '🌅 Morning Mood Check-In',
      'How are you feeling this morning?');
    
    // Midday check-in (1:00 PM)
    this.scheduleNotification('midday', '13:00',
      '☀️ Midday Mood Check-In', 
      'Time for your midday check-in!');
    
    // Evening check-in (7:00 PM)
    this.scheduleNotification('evening', '19:00',
      '🌙 Evening Mood Check-In',
      'How did your day go?');
  }
  
  scheduleNotification(type, time, title, message) {
    if ('Notification' in window && Notification.permission === 'granted') {
      const [hour, minute] = time.split(':').map(Number);
      const now = new Date();
      const scheduledTime = new Date(
        now.getFullYear(),
        now.getMonth(),
        now.getDate(),
        hour,
        minute
      );
      
      if (scheduledTime < now) {
        scheduledTime.setDate(scheduledTime.getDate() + 1);
      }
      
      const delay = scheduledTime - now;
      
      setTimeout(() => {
        new Notification(title, {
          body: message,
          icon: '/icon-192.png',
          badge: '/badge-72.png',
          requireInteraction: true,
          data: { type, time }
        });
        
        // Reschedule for tomorrow
        setTimeout(() => this.scheduleNotification(type, time, title, message), 
          24 * 60 * 60 * 1000);
      }, delay);
    }
  }
  
  async logMood(type, mood, energy) {
    const today = new Date().toISOString().split('T')[0];
    const tracking = this.getTodayTracking();
    
    tracking[`${type}Mood`] = mood;
    tracking[`${type}Energy`] = energy;
    tracking[`${type}Time`] = new Date().toISOString();
    
    localStorage.setItem(`mood-${today}`, JSON.stringify(tracking));
    
    // Show success message
    this.showToast(`${type} mood logged: ${mood}/10 mood, ${energy}/10 energy`);
  }
  
  getTodayTracking() {
    const today = new Date().toISOString().split('T')[0];
    const stored = localStorage.getItem(`mood-${today}`);
    return stored ? JSON.parse(stored) : {
      date: today,
      morningMood: null,
      morningEnergy: null,
      morningTime: null,
      middayMood: null,
      middayEnergy: null,
      middayTime: null,
      eveningMood: null,
      eveningEnergy: null,
      eveningTime: null
    };
  }
}
```

**Salesforce Flow:**
```
Flow: Daily_Mood_Check_In_Reminders
Type: Scheduled
Frequency: Daily at 9:00 AM, 1:00 PM, 7:00 PM

Trigger: Time-based

Actions:
1. Get Today's Daily_Mood_Tracking__c record
2. Decision: Has morning mood been logged?
   - No: Send push notification "Morning Mood Check-In"
3. Decision: Has midday mood been logged?
   - No: Send push notification "Midday Mood Check-In"  
4. Decision: Has evening mood been logged?
   - No: Send push notification "Evening Mood Check-In"
```

---

#### **1.3 Imposter Syndrome Counter with Achievement Linking**

**PWA Implementation:**
```javascript
class ImposterSyndromeCounter {
  detectImposterThought(text) {
    const imposterPatterns = [
      /not (?:good|smart|qualified|experienced) enough/i,
      /(?:fraud|fake|imposter)/i,
      /don't (?:deserve|belong)/i,
      /just (?:got lucky|fooled them)/i,
      /everyone else (?:knows|understands) (?:more|better)/i
    ];
    
    return imposterPatterns.some(pattern => pattern.test(text));
  }
  
  async counterImposterThought(thought) {
    // Get relevant achievements
    const achievements = this.getRelevantAchievements(thought);
    
    // Build countering facts
    const counteringFacts = achievements.map(win => win.text);
    
    // Additional context-specific facts
    if (/not qualified/i.test(thought)) {
      counteringFacts.push("You have 10+ years of professional experience");
      counteringFacts.push("You earned 96 Trailhead badges + 2 superbadges");
    }
    
    if (/fraud|fake/i.test(thought)) {
      counteringFacts.push("You built a complex Salesforce platform from scratch");
      counteringFacts.push("You maintained 99% data integrity across systems");
    }
    
    // Create session
    const session = {
      id: generateUUID(),
      sessionDate: new Date().toISOString(),
      imposterThought: thought,
      counteringFacts: counteringFacts,
      believabilityBefore: null, // User will rate
      believabilityAfter: null,
      linkedAchievements: achievements.map(a => a.id)
    };
    
    return session;
  }
  
  getRelevantAchievements(thought) {
    // Get all wins from localStorage
    const allWins = this.getAllWins();
    
    // Extract keywords from thought
    const thoughtKeywords = thought.toLowerCase().split(/\s+/);
    
    // Find wins with matching keywords
    return allWins
      .filter(win => {
        const winKeywords = win.keywords || [];
        return thoughtKeywords.some(tk => 
          winKeywords.some(wk => wk.includes(tk) || tk.includes(wk))
        );
      })
      .slice(0, 5); // Top 5 most relevant
  }
  
  getAllWins() {
    const wins = [];
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key.startsWith('win-')) {
        wins.push(JSON.parse(localStorage.getItem(key)));
      }
    }
    return wins.sort((a, b) => new Date(b.date) - new Date(a.date));
  }
}
```

**UI Component:**
```javascript
function ImposterSyndromeCounterUI() {
  const [thought, setThought] = useState('');
  const [session, setSession] = useState(null);
  const [believabilityBefore, setBelievabilityBefore] = useState(5);
  const [believabilityAfter, setBelievabilityAfter] = useState(5);
  
  const handleDetect = async () => {
    const counter = new ImposterSyndromeCounter();
    if (counter.detectImposterThought(thought)) {
      const newSession = await counter.counterImposterThought(thought);
      setSession(newSession);
    } else {
      alert('No imposter syndrome pattern detected');
    }
  };
  
  const handleComplete = () => {
    session.believabilityBefore = believabilityBefore;
    session.believabilityAfter = believabilityAfter;
    localStorage.setItem(`imposter-${session.id}`, JSON.stringify(session));
    
    // Show effectiveness
    const effectiveness = ((believabilityBefore - believabilityAfter) / believabilityBefore) * 100;
    alert(`Session complete! ${effectiveness.toFixed(0)}% reduction in believability`);
  };
  
  return (
    <div>
      <h2>Imposter Syndrome Counter</h2>
      <textarea 
        value={thought}
        onChange={(e) => setThought(e.target.value)}
        placeholder="What imposter thought are you having?"
      />
      <button onClick={handleDetect}>Analyze Thought</button>
      
      {session && (
        <div>
          <h3>Countering Evidence:</h3>
          <ul>
            {session.counteringFacts.map((fact, i) => (
              <li key={i}>{fact}</li>
            ))}
          </ul>
          
          <div>
            <label>How believable was the thought before? (1-10)</label>
            <input 
              type="range" 
              min="1" 
              max="10" 
              value={believabilityBefore}
              onChange={(e) => setBelievabilityBefore(Number(e.target.value))}
            />
            <span>{believabilityBefore}</span>
          </div>
          
          <div>
            <label>How believable is it now? (1-10)</label>
            <input 
              type="range" 
              min="1" 
              max="10" 
              value={believabilityAfter}
              onChange={(e) => setBelievabilityAfter(Number(e.target.value))}
            />
            <span>{believabilityAfter}</span>
          </div>
          
          <button onClick={handleComplete}>Complete Session</button>
        </div>
      )}
    </div>
  );
}
```

---

### **PHASE 2: ROUTINE ENHANCEMENTS (Week 2-3)** ⭐⭐⭐⭐

#### **2.1 Midday Routine with Task Timers**

**PWA Implementation:**
```javascript
class TaskTimer {
  constructor(task, duration) {
    this.task = task;
    this.scheduledDuration = duration;
    this.startTime = null;
    this.endTime = null;
    this.isRunning = false;
    this.remainingSeconds = duration * 60;
  }
  
  start() {
    this.startTime = Date.now();
    this.isRunning = true;
    
    this.interval = setInterval(() => {
      this.remainingSeconds--;
      
      if (this.remainingSeconds <= 0) {
        this.complete();
      }
      
      // Update UI
      this.onTick(this.remainingSeconds);
    }, 1000);
  }
  
  pause() {
    this.isRunning = false;
    clearInterval(this.interval);
  }
  
  resume() {
    this.isRunning = true;
    this.start();
  }
  
  complete() {
    this.endTime = Date.now();
    this.isRunning = false;
    clearInterval(this.interval);
    
    const actualDuration = Math.round((this.endTime - this.startTime) / 60000);
    
    // Play completion sound
    this.playSound('/sounds/timer-complete.mp3');
    
    // Show notification
    new Notification('Timer Complete!', {
      body: `${this.task} completed in ${actualDuration} minutes`,
      requireInteraction: true
    });
    
    // Save record
    this.saveRecord(actualDuration);
    
    // Callback
    this.onComplete(actualDuration);
  }
  
  saveRecord(actualDuration) {
    const record = {
      id: generateUUID(),
      taskName: this.task,
      scheduledDuration: this.scheduledDuration,
      actualDuration: actualDuration,
      completedDate: new Date().toISOString(),
      wasHelpful: null, // User will rate later
      routineType: 'midday'
    };
    
    localStorage.setItem(`timer-${record.id}`, JSON.stringify(record));
  }
  
  formatTime(seconds) {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }
}

// UI Component
function MiddayRoutineWithTimers() {
  const tasks = [
    { name: 'Garden break', duration: 15, hasTimer: true },
    { name: 'Late lunch', duration: 30, hasTimer: true },
    { name: 'Light stretching', duration: 10, hasTimer: true },
    { name: 'Check-in with family', duration: 15, hasTimer: false }
  ];
  
  const [activeTimer, setActiveTimer] = useState(null);
  const [completedTasks, setCompletedTasks] = useState([]);
  
  const startTask = (task) => {
    const timer = new TaskTimer(task.name, task.duration);
    timer.onTick = (remaining) => {
      // Update UI every second
      setActiveTimer({ ...timer, remaining });
    };
    timer.onComplete = (actualDuration) => {
      setCompletedTasks([...completedTasks, task.name]);
      setActiveTimer(null);
    };
    timer.start();
    setActiveTimer(timer);
  };
  
  return (
    <div className="midday-routine">
      <h2>Midday Routine</h2>
      <p>Available 11am - 3pm</p>
      
      {tasks.map(task => (
        <div key={task.name} className="task-card">
          <input 
            type="checkbox"
            checked={completedTasks.includes(task.name)}
            onChange={() => {/* mark complete */}}
          />
          <span>{task.name}</span>
          <span>{task.duration} min</span>
          
          {task.hasTimer && (
            <div>
              {activeTimer?.task === task.name ? (
                <>
                  <span className="timer-display">
                    {new TaskTimer().formatTime(activeTimer.remaining)}
                  </span>
                  <button onClick={() => activeTimer.pause()}>⏸️</button>
                </>
              ) : (
                <button onClick={() => startTask(task)}>▶️ Start</button>
              )}
            </div>
          )}
        </div>
      ))}
    </div>
  );
}
```

---

#### **2.2 Evening Routine with 5:15 Hard Stop**

**PWA Implementation:**
```javascript
class EveningRoutineManager {
  constructor() {
    this.hardStopTime = '17:15'; // 5:15 PM
    this.scheduleHardStopAlarm();
  }
  
  scheduleHardStopAlarm() {
    // Check every minute if it's 5:15 PM
    setInterval(() => {
      const now = new Date();
      const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
      
      if (currentTime === this.hardStopTime) {
        this.triggerHardStop();
      }
    }, 60000); // Check every minute
  }
  
  triggerHardStop() {
    // Full screen notification
    if (Notification.permission === 'granted') {
      const notification = new Notification('🛑 HARD STOP TIME', {
        body: 'It\'s 5:15 PM. Stop work and begin your evening routine now.',
        requireInteraction: true,
        silent: false,
        vibrate: [500, 250, 500, 250, 500],
        icon: '/icons/stop-sign.png'
      });
      
      notification.onclick = () => {
        window.focus();
        this.showEveningRoutine();
      };
    }
    
    // Play alarm sound (continuous until acknowledged)
    this.playAlarmSound();
    
    // Show modal overlay
    this.showHardStopModal();
    
    // Create tracking record
    this.createTrackingRecord();
  }
  
  playAlarmSound() {
    const audio = new Audio('/sounds/hard-stop-alarm.mp3');
    audio.loop = true;
    audio.play();
    
    this.alarmAudio = audio;
  }
  
  showHardStopModal() {
    const modal = document.createElement('div');
    modal.id = 'hard-stop-modal';
    modal.innerHTML = `
      <div class="hard-stop-overlay">
        <div class="hard-stop-content">
          <h1>🛑 HARD STOP TIME</h1>
          <p>It's 5:15 PM</p>
          <p>Time to stop work and begin your evening routine</p>
          <button onclick="acknowledgeHardStop()">Begin Evening Routine</button>
        </div>
      </div>
    `;
    document.body.appendChild(modal);
  }
  
  acknowledgeHardStop() {
    // Stop alarm
    if (this.alarmAudio) {
      this.alarmAudio.pause();
      this.alarmAudio = null;
    }
    
    // Remove modal
    document.getElementById('hard-stop-modal')?.remove();
    
    // Navigate to evening routine
    this.showEveningRoutine();
    
    // Update tracking record
    const today = new Date().toISOString().split('T')[0];
    const tracking = JSON.parse(localStorage.getItem(`evening-${today}`));
    tracking.routineStartTime = new Date().toISOString();
    localStorage.setItem(`evening-${today}`, JSON.stringify(tracking));
  }
  
  createTrackingRecord() {
    const today = new Date().toISOString().split('T')[0];
    const tracking = {
      id: generateUUID(),
      date: today,
      hardStopTime: new Date().toISOString(),
      routineStartTime: null,
      routineCompleteTime: null,
      wentOvertime: false,
      overtimeMinutes: 0,
      overtimeReason: null
    };
    
    localStorage.setItem(`evening-${today}`, JSON.stringify(tracking));
  }
  
  completeEveningRoutine() {
    const today = new Date().toISOString().split('T')[0];
    const tracking = JSON.parse(localStorage.getItem(`evening-${today}`));
    
    tracking.routineCompleteTime = new Date().toISOString();
    
    // Check if overtime
    const completeTime = new Date(tracking.routineCompleteTime);
    const tenPM = new Date(completeTime);
    tenPM.setHours(22, 0, 0, 0);
    
    if (completeTime > tenPM) {
      tracking.wentOvertime = true;
      tracking.overtimeMinutes = Math.round((completeTime - tenPM) / 60000);
      
      // Prompt for reason
      const reason = prompt('You completed your evening routine after 10 PM. What kept you up?');
      tracking.overtimeReason = reason;
    } else {
      // Celebrate!
      this.celebrateOnTimeCompletion();
    }
    
    localStorage.setItem(`evening-${today}`, JSON.stringify(tracking));
  }
  
  celebrateOnTimeCompletion() {
    // Confetti animation
    // Success message
    alert('🎉 Excellent! You completed your evening routine before 10 PM and honored your boundaries!');
  }
}
```

---

### **PHASE 3: ANALYTICS & INSIGHTS (Week 3-4)** ⭐⭐⭐

#### **3.1 Weekly Wins Dashboard**

**PWA Implementation:**
```javascript
class WeeklyWinsDashboard {
  getThisWeeksWins() {
    const today = new Date();
    const monday = this.getMondayOfWeek(today);
    const sunday = new Date(monday);
    sunday.setDate(sunday.getDate() + 7);
    
    const allWins = this.getAllWins();
    return allWins.filter(win => {
      const winDate = new Date(win.date);
      return winDate >= monday && winDate < sunday;
    });
  }
  
  getMondayOfWeek(date) {
    const day = date.getDay();
    const diff = date.getDate() - day + (day === 0 ? -6 : 1);
    const monday = new Date(date.setDate(diff));
    monday.setHours(0, 0, 0, 0);
    return monday;
  }
  
  analyzeWeeklyWins(wins) {
    const analysis = {
      totalWins: wins.length,
      byCategory: {},
      byDay: {},
      mostProductiveDay: null,
      topCategory: null,
      insights: []
    };
    
    // Count by category
    wins.forEach(win => {
      analysis.byCategory[win.category] = (analysis.byCategory[win.category] || 0) + 1;
      
      const dayName = new Date(win.date).toLocaleDateString('en-US', { weekday: 'long' });
      analysis.byDay[dayName] = (analysis.byDay[dayName] || 0) + 1;
    });
    
    // Find most productive day
    analysis.mostProductiveDay = Object.entries(analysis.byDay)
      .reduce((a, b) => a[1] > b[1] ? a : b)[0];
    
    // Find top category
    analysis.topCategory = Object.entries(analysis.byCategory)
      .reduce((a, b) => a[1] > b[1] ? a : b)[0];
    
    // Generate insights
    analysis.insights = this.generateInsights(wins, analysis);
    
    return analysis;
  }
  
  generateInsights(wins, analysis) {
    const insights = [];
    
    // Trend comparison
    const lastWeekWins = this.getLastWeeksWins();
    if (wins.length > lastWeekWins.length) {
      const increase = ((wins.length - lastWeekWins.length) / lastWeekWins.length * 100).toFixed(0);
      insights.push(`📈 Wins increased ${increase}% from last week`);
    }
    
    // Category insights
    if (analysis.byCategory.job_search > analysis.totalWins * 0.4) {
      insights.push(`💼 Strong job search focus this week (${analysis.byCategory.job_search} wins)`);
    }
    
    // Streak insights
    const streak = this.calculateWinStreak();
    if (streak >= 7) {
      insights.push(`🔥 Amazing! ${streak}-day win logging streak!`);
    }
    
    // Pattern insights
    if (analysis.mostProductiveDay === 'Wednesday') {
      insights.push(`💡 You're most productive mid-week`);
    }
    
    return insights;
  }
  
  render() {
    const wins = this.getThisWeeksWins();
    const analysis = this.analyzeWeeklyWins(wins);
    
    return `
      <div class="weekly-dashboard">
        <h2>This Week's Wins</h2>
        <div class="stats">
          <div class="stat">
            <span class="number">${analysis.totalWins}</span>
            <span class="label">Total Wins</span>
          </div>
          <div class="stat">
            <span class="number">${analysis.mostProductiveDay}</span>
            <span class="label">Most Productive Day</span>
          </div>
          <div class="stat">
            <span class="number">${analysis.topCategory}</span>
            <span class="label">Top Category</span>
          </div>
        </div>
        
        <div class="category-breakdown">
          <h3>By Category</h3>
          ${Object.entries(analysis.byCategory).map(([cat, count]) => `
            <div class="category-bar">
              <span>${cat}</span>
              <div class="bar" style="width: ${count / analysis.totalWins * 100}%"></div>
              <span>${count}</span>
            </div>
          `).join('')}
        </div>
        
        <div class="insights">
          <h3>Insights</h3>
          ${analysis.insights.map(insight => `<p>⭐ ${insight}</p>`).join('')}
        </div>
      </div>
    `;
  }
}
```

---

#### **3.2 Journal History with Keyword Search**

**PWA Implementation:**
```javascript
class JournalSearchEngine {
  searchJournal(query) {
    const allEntries = this.getAllJournalEntries();
    const keywords = query.toLowerCase().split(/\s+/);
    
    // Search in entry text, keywords, and mood descriptors
    const results = allEntries.filter(entry => {
      const searchableText = [
        entry.notes || '',
        entry.wins?.map(w => w.text).join(' ') || '',
        entry.gratitude?.join(' ') || '',
        entry.keywords?.join(' ') || '',
        this.getMoodDescriptor(entry.morningMood),
        this.getMoodDescriptor(entry.eveningMood)
      ].join(' ').toLowerCase();
      
      return keywords.some(keyword => searchableText.includes(keyword));
    });
    
    return results.sort((a, b) => new Date(b.date) - new Date(a.date));
  }
  
  filterByMood(moodLevel) {
    const allEntries = this.getAllJournalEntries();
    return allEntries.filter(entry => 
      entry.morningMood === moodLevel || 
      entry.eveningMood === moodLevel
    );
  }
  
  filterByEnergy(energyLevel) {
    const allEntries = this.getAllJournalEntries();
    return allEntries.filter(entry =>
      entry.morningEnergy === energyLevel ||
      entry.eveningEnergy === energyLevel
    );
  }
  
  filterByDateRange(startDate, endDate) {
    const allEntries = this.getAllJournalEntries();
    return allEntries.filter(entry => {
      const entryDate = new Date(entry.date);
      return entryDate >= new Date(startDate) && entryDate <= new Date(endDate);
    });
  }
  
  getAllJournalEntries() {
    const entries = [];
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key.startsWith('journal-') || key.startsWith('mood-')) {
        entries.push(JSON.parse(localStorage.getItem(key)));
      }
    }
    return entries;
  }
  
  getMoodDescriptor(moodLevel) {
    if (!moodLevel) return '';
    if (moodLevel >= 8) return 'great happy excellent';
    if (moodLevel >= 6) return 'good okay decent';
    if (moodLevel >= 4) return 'meh neutral';
    return 'low sad difficult';
  }
}

// UI Component
function JournalSearchUI() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [activeFilters, setActiveFilters] = useState([]);
  
  const handleSearch = () => {
    const engine = new JournalSearchEngine();
    const searchResults = engine.searchJournal(query);
    setResults(searchResults);
  };
  
  const applyFilter = (filterType, filterValue) => {
    const engine = new JournalSearchEngine();
    let filtered;
    
    switch(filterType) {
      case 'mood':
        filtered = engine.filterByMood(filterValue);
        break;
      case 'energy':
        filtered = engine.filterByEnergy(filterValue);
        break;
      case 'date':
        filtered = engine.filterByDateRange(filterValue.start, filterValue.end);
        break;
    }
    
    setResults(filtered);
    setActiveFilters([...activeFilters, { type: filterType, value: filterValue }]);
  };
  
  return (
    <div className="journal-search">
      <div className="search-bar">
        <input 
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search journal by keyword, mood, date..."
        />
        <button onClick={handleSearch}>🔍 Search</button>
      </div>
      
      <div className="filters">
        <button onClick={() => applyFilter('mood', 8)}>😊 High Mood</button>
        <button onClick={() => applyFilter('mood', 3)}>😞 Low Mood</button>
        <button onClick={() => applyFilter('energy', 8)}>⚡ High Energy</button>
        <button onClick={() => applyFilter('energy', 3)}>🔋 Low Energy</button>
      </div>
      
      <div className="results">
        <p>{results.length} entries found</p>
        {results.map(entry => (
          <div key={entry.id} className="journal-entry-card">
            <h3>{new Date(entry.date).toLocaleDateString()}</h3>
            {entry.keywords && (
              <div className="keywords">
                {entry.keywords.map(kw => <span className="keyword">{kw}</span>)}
              </div>
            )}
            <p className="preview">{(entry.notes || '').substring(0, 200)}...</p>
            <button onClick={() => viewFullEntry(entry.id)}>View Full Entry</button>
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

## 🔗 SALESFORCE ↔ PWA INTEGRATION

### **Bidirectional Sync Architecture**

```javascript
// PWA → Salesforce Sync
class SalesforceSyncService {
  constructor(instanceUrl, accessToken) {
    this.instanceUrl = instanceUrl;
    this.accessToken = accessToken;
    this.apiVersion = 'v62.0';
  }
  
  async syncWinToSalesforce(win) {
    const winRecord = {
      Date__c: win.date,
      Win_Text__c: win.winText,
      Category__c: win.category,
      Keywords__c: JSON.stringify(win.keywords),
      Linked_to_Imposter_Session__c: win.linkedToImposterSession,
      Celebration_Shown__c: win.celebrationShown
    };
    
    const response = await fetch(
      `${this.instanceUrl}/services/data/${this.apiVersion}/sobjects/Win__c`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.accessToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(winRecord)
      }
    );
    
    return response.json();
  }
  
  async syncMoodTrackingToSalesforce(moodTracking) {
    const moodRecord = {
      Date__c: moodTracking.date,
      Morning_Mood__c: moodTracking.morningMood,
      Morning_Energy__c: moodTracking.morningEnergy,
      Morning_Time__c: moodTracking.morningTime,
      Midday_Mood__c: moodTracking.middayMood,
      Midday_Energy__c: moodTracking.middayEnergy,
      Midday_Time__c: moodTracking.middayTime,
      Evening_Mood__c: moodTracking.eveningMood,
      Evening_Energy__c: moodTracking.eveningEnergy,
      Evening_Time__c: moodTracking.eveningTime
    };
    
    // Check if record exists for today
    const existing = await this.queryMoodTrackingByDate(moodTracking.date);
    
    if (existing) {
      // Update existing
      return this.updateMoodTracking(existing.Id, moodRecord);
    } else {
      // Create new
      return this.createMoodTracking(moodRecord);
    }
  }
  
  async queryMoodTrackingByDate(date) {
    const query = `SELECT Id FROM Daily_Mood_Tracking__c WHERE Date__c = ${date}`;
    const response = await fetch(
      `${this.instanceUrl}/services/data/${this.apiVersion}/query?q=${encodeURIComponent(query)}`,
      {
        headers: {
          'Authorization': `Bearer ${this.accessToken}`
        }
      }
    );
    
    const data = await response.json();
    return data.records[0] || null;
  }
  
  // Batch sync all pending changes
  async syncAllPendingChanges() {
    const pendingSync = JSON.parse(localStorage.getItem('pendingSync') || '{}');
    
    const syncPromises = [];
    
    // Sync wins
    if (pendingSync.wins) {
      pendingSync.wins.forEach(win => {
        syncPromises.push(this.syncWinToSalesforce(win));
      });
    }
    
    // Sync mood tracking
    if (pendingSync.moodTracking) {
      pendingSync.moodTracking.forEach(mood => {
        syncPromises.push(this.syncMoodTrackingToSalesforce(mood));
      });
    }
    
    // Sync gratitude entries
    if (pendingSync.gratitude) {
      pendingSync.gratitude.forEach(gratitude => {
        syncPromises.push(this.syncGratitudeToSalesforce(gratitude));
      });
    }
    
    await Promise.all(syncPromises);
    
    // Clear pending sync
    localStorage.setItem('pendingSync', '{}');
  }
}

// Background sync worker
if ('serviceWorker' in navigator && 'SyncManager' in window) {
  navigator.serviceWorker.ready.then(registration => {
    // Register background sync
    return registration.sync.register('sync-to-salesforce');
  });
}

// Service Worker handles background sync
self.addEventListener('sync', event => {
  if (event.tag === 'sync-to-salesforce') {
    event.waitUntil(syncToSalesforce());
  }
});

async function syncToSalesforce() {
  const syncService = new SalesforceSyncService(
    localStorage.getItem('sf_instance_url'),
    localStorage.getItem('sf_access_token')
  );
  
  await syncService.syncAllPendingChanges();
}
```

---

## 📋 IMPLEMENTATION CHECKLIST

### **Database Schema (10 Tables)**

- [ ] **Win__c** object in Salesforce + localStorage in PWA
- [ ] **Daily_Mood_Tracking__c** object in Salesforce + localStorage in PWA
- [ ] **Gratitude_Entry__c** object in Salesforce + localStorage in PWA
- [ ] **Therapy_Step_Completion__c** object in Salesforce + localStorage in PWA
- [ ] **Imposter_Syndrome_Session__c** object in Salesforce + localStorage in PWA
- [ ] **Negative_Thought_Analysis__c** object in Salesforce + localStorage in PWA
- [ ] **Routine_Task_Timer__c** object in Salesforce + localStorage in PWA
- [ ] **Evening_Routine_Tracking__c** object in Salesforce + localStorage in PWA
- [ ] **Journal_Keyword__c** junction object in Salesforce
- [ ] **Weekly_Win_Summary__c** object in Salesforce + localStorage in PWA

### **Core Features**

#### **Journal Module**
- [ ] Rich text win parser (extract from bullets/lists/paragraphs)
- [ ] Auto-categorization (job_search, personal, health, learning)
- [ ] Auto-keyword extraction
- [ ] 3x daily mood tracking with notifications
- [ ] Separate gratitude journal tab
- [ ] Journal history with full-text search
- [ ] Weekly wins dashboard with analytics
- [ ] Keyword cloud visualization

#### **Routine Module**
- [ ] Midday routine tab (11am-3pm window)
- [ ] Task timers for midday activities
- [ ] Evening routine tab (5:15pm-10pm window)
- [ ] 5:15 PM hard stop alarm (non-dismissible)
- [ ] Overtime warnings after 10 PM
- [ ] Overtime reason tracking
- [ ] Weekly overtime analysis

#### **Therapy Module**
- [ ] Completion counters on all therapy steps
- [ ] Effectiveness ratings (1-10) after each use
- [ ] Imposter syndrome auto-detector
- [ ] Achievement-linked counter-facts
- [ ] Before/after believability ratings
- [ ] Negative thought analyzer with NLP
- [ ] Cognitive distortion categorization
- [ ] Suggested reframes with MH best practices
- [ ] Therapy journal integration

#### **Analytics Module**
- [ ] Dashboard redesign (command center)
- [ ] Energy pattern graphs (line charts)
- [ ] Mood trend analysis (by day of week)
- [ ] Routine consistency tracking
- [ ] Weekly analytics summary
- [ ] Most productive day analysis
- [ ] Category breakdown charts
- [ ] Week-over-week comparisons

### **Integration Features**

- [ ] Salesforce OAuth authentication for PWA
- [ ] PWA → Salesforce sync service
- [ ] Salesforce → PWA data loading
- [ ] Background sync (Service Worker)
- [ ] Conflict resolution logic
- [ ] Offline-first architecture
- [ ] Unified dashboard (both systems)
- [ ] Cross-platform reports

---

## ⏱️ ESTIMATED TIMELINE

### **Phase 1: Core Tracking (2-3 weeks)**
- Week 1: Database schema (10 tables in Salesforce + PWA)
- Week 2: Rich text parser + 3x mood tracking + gratitude journal
- Week 3: Imposter syndrome counter + negative thought analyzer

### **Phase 2: Routine Enhancements (1-2 weeks)**
- Week 4: Midday routine with timers
- Week 5: Evening routine with 5:15 hard stop

### **Phase 3: Analytics (1-2 weeks)**
- Week 6: Weekly wins dashboard + journal search
- Week 7: Dashboard redesign + analytics graphs

### **Phase 4: Integration (2-3 weeks)**
- Week 8-9: Salesforce ↔ PWA sync
- Week 10: Unified dashboard + testing

**Total: 10 weeks (2.5 months)**

---

## 🎯 SUCCESS CRITERIA

When complete, you will have:

✅ All 10 database tables implemented in both systems  
✅ Rich text win parser working  
✅ 3x daily mood tracking with notifications  
✅ Imposter syndrome counter with achievement linking  
✅ 5:15 PM hard stop alarm  
✅ Midday routine with task timers  
✅ Evening routine with overtime tracking  
✅ Weekly wins dashboard with insights  
✅ Journal history with keyword search  
✅ Salesforce ↔ PWA bidirectional sync  
✅ Unified dashboard showing holistic view  

This will match 100% of your original consolidated implementation plan.

---

**END OF REMAINING BUILD PLAN**

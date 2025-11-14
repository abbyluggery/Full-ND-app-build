# Opportunity-Centric Job Search System - Implementation Plan

## Executive Summary
Transform the job search platform to use Opportunity as the SINGLE user touch point. Users will never need to open Job_Posting__c records - all functionality accessible from Opportunity.

**Goal:** Make the system "idiot-proof" by centralizing all job search activities on the Opportunity object.

---

## Current Architecture Issues

### Problem 1: Split Field Architecture
- Interview fields exist on Job_Posting__c
- User must navigate between Opportunity and Job_Posting__c
- Confusing dual-object model

### Problem 2: Generic Resume Generation
- Resumes don't use company research
- Missing deep customization based on company culture/values
- CompanyResearcher.cls exists but not integrated

### Problem 3: Incomplete Field Auto-Population
- Has_ND_Program__c and Flexible_Schedule__c exist but unpopulated
- Experience_Level__c not extracted from job descriptions
- Remote_Policy__c not auto-set when Location = "Remote"

### Problem 4: Premature Stage Advancement
- Events advance Opportunity stage immediately upon creation
- Should wait until interview actually occurs (Event.EndDateTime passes)
- No connection to Interview_Completed__c field

---

## Implementation Phases

### Phase 1: Field Architecture - Mirror Interview Fields to Opportunity
**Status:** Ready to implement

**New Opportunity Fields:**
- Interview_Date__c (DateTime)
- Interview_Notes__c (Long Text Area)
- Interview_Feedback__c (Long Text Area)
- Interview_Completed__c (Checkbox)
- Has_ND_Program__c (Formula - references Job_Posting__c)
- Flexible_Schedule__c (Formula - references Job_Posting__c)

**New Component:**
- OpportunityInterviewSync.cls - Bi-directional sync trigger
- Prevents infinite loops with static tracking
- Syncs changes both directions: Opportunity ↔ Job_Posting__c

---

### Phase 2: Enhanced Job Posting Analysis
**Status:** Ready to implement

**Modifications to JobPostingAnalyzer.cls:**
- Parse Claude AI response for ND program mentions
- Parse for flexible schedule keywords
- Set Has_ND_Program__c and Flexible_Schedule__c checkboxes
- Extract to discrete fields (not just text in Green_Flags__c)

**New Component:**
- JobDescriptionParser.cls - Parse experience level and remote policy
- Extract ExperienceLevel__c from keywords ("senior", "5+ years", etc.)
- Auto-set Remote_Policy__c when Location contains "Remote"

---

### Phase 3: Event Completion Logic
**Status:** Ready to implement

**Modifications to OpportunityProgressAutomation.cls:**
- Add check: Only advance if Event.EndDateTime has passed
- Interview must OCCUR before stage advances
- Support manual override via Salesforce Path

**Modifications to EventTrigger.trigger:**
- Add `after update` context
- Handle Event completion (EndDateTime passing)
- Update Opportunity.Interview_Completed__c when Event completes

**User Experience:**
1. User creates Event "Technical Interview - 2pm Tuesday"
2. Opportunity stage stays at current stage (does NOT advance)
3. Tuesday 2pm passes (Event.EndDateTime < now)
4. Stage automatically advances to "Technical Interview"
5. Interview_Completed__c checkbox set to true

---

### Phase 4: Company Research Integration
**Status:** Ready to implement

**New Components:**
- OpportunityResearchController.cls - Apex controller for research button
- Opportunity.Run_Company_Research.quickAction-meta.xml - Quick action
- opportunityCompanyResearch.lwc - Display component for research results

**Functionality:**
- "Research Company" button on Opportunity
- Calls existing CompanyResearcher.generateResearch()
- Creates/updates Company_Research__c record
- Displays results in LWC component on Opportunity page

---

### Phase 5: Enhanced Resume Generation
**Status:** Ready to implement

**Modifications to ResumeGenerator.cls:**
- Query Company_Research__c for related Job_Posting__c
- Include company insights in Claude AI prompt:
  - Company Overview
  - Culture Insights
  - Key Products/Services
  - Interview Talking Points
- Generate deeply customized resume based on research

**Result:** Resumes tailored to company culture, not just job description

---

### Phase 6: Opportunity Page Layout Optimization
**Status:** Design complete, ready to implement

**Quick Actions to Add:**
1. Research Company
2. Generate Resume Package (already exists)
3. Mark Interview Complete

**LWC Components to Add:**
1. opportunityCompanyResearch - Company research display
2. opportunityInterviewPrep - Link to AI practice sessions
3. opportunityDocuments - Resume packages and files

**Field Sections:**
- Job Details (formulas from Job_Posting__c)
- Application Progress (dates, stage)
- Interview Tracking (date, notes, feedback, completed)
- AI Analysis (research, fit scores, flags)

---

### Phase 7: Einstein Conversation Insights (Future)
**Status:** Documented for future implementation

**Requirements:**
- Einstein Conversation Insights license
- Integration with Salesforce Voice or third-party calling
- Transcript storage on Event records

**Planned Functionality:**
- Auto-transcribe interview recordings
- Parse transcripts to populate Interview_Feedback__c
- Extract key insights and talking points
- Store full transcript on Event.Description

**Documentation:** EINSTEIN_INTEGRATION_PLAN.md (to be created)

---

## Testing Observations Addressed

### Observation 1: Event Records
**Issue:** "Event should have occurred in order for the progress bar to advance"
**Solution:** Phase 3 - Check Event.EndDateTime before advancing stage

### Observation 2: Company Research Not Working
**Issue:** "No research is generated. If JSON needs to be executed for research to generate then we need to create a 'Do Company Research' button"
**Solution:** Phase 4 - Quick Action on Opportunity to trigger research

### Observation 3: Experience Level Not Generating
**Issue:** "Experience Level isn't generating"
**Solution:** Phase 2 - JobDescriptionParser extracts from description

### Observation 4: Job Posting Data Not Fully Parsed
**Issue:** "Job posting has contact information for the recruiter in description field"
**Solution:** Phase 2 - Enhanced parsing (note: Chrome extension already provides this via API)

### Observation 5: Remote Policy Auto-Set
**Issue:** "If job posting is created with 'Remote' as location, then 'Remote Policy' should be checked automatically"
**Solution:** Phase 2 - Auto-set Remote_Policy__c = "Fully Remote"

### Observation 6: Interview Fields Should Come from Opportunity
**Issue:** "Interview Date, Notes, Feedback should be generated when Opportunity object shows input"
**Solution:** Phase 1 - Mirror fields to Opportunity with bi-directional sync

### Observation 7: Has ND Program and Flexible Schedule
**Issue:** "Both boxes should be marked by Claude AI review"
**Solution:** Phase 2 - JobPostingAnalyzer extracts to checkboxes

### Observation 8: Resume Too Generic
**Issue:** "Resume generation is very generic. Company research should come in for deep dive"
**Solution:** Phase 5 - Integrate CompanyResearcher into ResumeGenerator

---

## Files to Create (14 new files)

### Apex Classes (6 files):
1. OpportunityInterviewSync.cls
2. OpportunityInterviewSyncTest.cls
3. OpportunityResearchController.cls
4. OpportunityResearchControllerTest.cls
5. JobDescriptionParser.cls
6. JobDescriptionParserTest.cls

### Opportunity Fields (4 files):
7. Interview_Date__c.field-meta.xml
8. Interview_Notes__c.field-meta.xml
9. Interview_Feedback__c.field-meta.xml
10. Interview_Completed__c.field-meta.xml

### Quick Actions (2 files):
11. Opportunity.Run_Company_Research.quickAction-meta.xml
12. Opportunity.Mark_Interview_Complete.quickAction-meta.xml

### LWC (1 bundle):
13. opportunityCompanyResearch/

### Documentation (1 file):
14. EINSTEIN_INTEGRATION_PLAN.md

---

## Files to Modify (5 files)

1. OpportunityProgressAutomation.cls - Add Event completion check
2. EventTrigger.trigger - Add after update context
3. JobPostingAnalyzer.cls - Parse ND program and flexible schedule
4. ResumeGenerator.cls - Integrate company research
5. JobPostingAPI.cls - Add ExperienceLevel and RemotePolicy parsing

---

## Implementation Timeline

### Week 1: Core Field Architecture
- Day 1-2: Create Opportunity interview fields
- Day 2-3: Create OpportunityInterviewSync trigger
- Day 3: Test bi-directional sync
- Day 4: Deploy to org

### Week 2: Analysis & Parsing Enhancement
- Day 1-2: Enhance JobPostingAnalyzer for ND fields
- Day 2-3: Create JobDescriptionParser for experience/remote
- Day 4: Test field auto-population
- Day 5: Deploy to org

### Week 3: Event Completion Logic
- Day 1-2: Modify OpportunityProgressAutomation
- Day 2-3: Update EventTrigger for after update
- Day 3-4: Test stage progression
- Day 5: Deploy to org

### Week 4: Company Research & Resume
- Day 1-2: Create OpportunityResearchController
- Day 2: Add Quick Action to Opportunity
- Day 3-4: Modify ResumeGenerator with research
- Day 4-5: Create opportunityCompanyResearch LWC
- Day 6: Test end-to-end workflow
- Day 7: Deploy to org

### Week 5: Page Layout & Polish
- Day 1-2: Update Opportunity page layout
- Day 2-3: Add all Quick Actions and LWC components
- Day 4-5: User acceptance testing
- Day 6: Final deployment
- Day 7: Documentation update

**Total Time:** 5 weeks (can be accelerated with parallel work)

---

## Success Criteria

✅ User NEVER needs to open Job_Posting__c record
✅ All interview tracking on Opportunity object
✅ One-click company research from Opportunity
✅ Resume generation uses company insights automatically
✅ Stage progression waits for Event completion
✅ ND Program and Flexible Schedule auto-detected by AI
✅ Experience Level and Remote Policy auto-populated
✅ Einstein integration documented for future
✅ Comprehensive test coverage (75%+)
✅ User documentation updated

---

## Risk Mitigation

### Risk 1: Infinite Loop in Sync Trigger
**Mitigation:** Static variable to track execution context
**Testing:** Thorough testing of Opportunity → Job_Posting and Job_Posting → Opportunity updates

### Risk 2: Event Completion Logic Too Restrictive
**Mitigation:** Keep Salesforce Path manual override
**Testing:** Verify users can still manually mark stages complete

### Risk 3: Resume Generation Performance
**Mitigation:** Async processing already in place (ResumePDFGeneratorAsync)
**Testing:** Load test with multiple concurrent resume generations

### Risk 4: Field Proliferation on Opportunity
**Mitigation:** Use formulas for read-only fields (Has_ND_Program, etc.)
**Testing:** Page layout organization testing with real users

---

## Rollback Plan

If issues arise during deployment:

1. **Phase 1 Rollback:** Delete new Opportunity fields, deactivate sync trigger
2. **Phase 2 Rollback:** Revert JobPostingAnalyzer and JobDescriptionParser changes
3. **Phase 3 Rollback:** Revert OpportunityProgressAutomation and EventTrigger
4. **Phase 4 Rollback:** Remove Quick Action, delete controller and LWC
5. **Phase 5 Rollback:** Revert ResumeGenerator to original version

Each phase can be rolled back independently without affecting prior phases.

---

## Current Status: READY TO BEGIN IMPLEMENTATION

**Next Steps:**
1. Update todo list with implementation phases
2. Begin Phase 1: Create Opportunity interview fields
3. Implement OpportunityInterviewSync trigger
4. Test and deploy Phase 1

**Last Updated:** November 13, 2025
**Implemented By:** Claude Code Assistant
**Approved By:** Abby Luggery

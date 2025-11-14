/**
 * @description Automates Opportunity stage progression based on job search activities
 * @author Abby Luggery / Claude Code Assistant
 * @date November 13, 2025
 *
 * Handles automatic stage updates for:
 * 1. Resume Package creation → "Application Prepared" stage
 * 2. Application email sent → "Application Submitted" stage
 * 3. Interview event created → Appropriate interview stage
 */
public with sharing class OpportunityProgressAutomation {

    /**
     * @description Handles Resume_Package__c creation - updates Opportunity to "Application Prepared"
     * @param newResumePackages List of newly created Resume_Package__c records
     */
    public static void handleResumePackageCreation(List<Resume_Package__c> newResumePackages) {
        Set<Id> opportunityIds = new Set<Id>();

        // Collect Opportunity IDs from resume packages
        for (Resume_Package__c pkg : newResumePackages) {
            if (pkg.Opportunity__c != null) {
                opportunityIds.add(pkg.Opportunity__c);
            }
        }

        if (opportunityIds.isEmpty()) {
            return;
        }

        // Query Opportunities with Job Search Application record type
        List<Opportunity> oppsToUpdate = [
            SELECT Id, StageName, Application_Prepared_Date__c, RecordType.DeveloperName
            FROM Opportunity
            WHERE Id IN :opportunityIds
            AND RecordType.DeveloperName = 'Job_Search_Application'
            AND (StageName = 'Job Discovered' OR Application_Prepared_Date__c = null)
        ];

        List<Opportunity> updatedOpps = new List<Opportunity>();
        for (Opportunity opp : oppsToUpdate) {
            opp.StageName = 'Application Prepared';
            opp.Application_Prepared_Date__c = System.now();
            updatedOpps.add(opp);
        }

        if (!updatedOpps.isEmpty()) {
            update updatedOpps;
            System.debug('OpportunityProgressAutomation: Updated ' + updatedOpps.size() +
                ' Opportunities to Application Prepared stage');
        }
    }

    /**
     * @description Handles EmailMessage creation - updates Opportunity to "Application Submitted"
     * @param newEmails List of newly created EmailMessage records
     */
    public static void handleApplicationEmailSent(List<EmailMessage> newEmails) {
        Set<Id> opportunityIds = new Set<Id>();

        // Identify application emails by subject line pattern
        for (EmailMessage email : newEmails) {
            if (email.RelatedToId != null &&
                String.valueOf(email.RelatedToId).startsWith('006') && // Opportunity ID prefix
                email.Subject != null &&
                email.Subject.containsIgnoreCase('Application for')) {
                opportunityIds.add(email.RelatedToId);
            }
        }

        if (opportunityIds.isEmpty()) {
            return;
        }

        // Query Opportunities that haven't been submitted yet
        List<Opportunity> oppsToUpdate = [
            SELECT Id, StageName, Application_Submitted_Date__c, RecordType.DeveloperName
            FROM Opportunity
            WHERE Id IN :opportunityIds
            AND RecordType.DeveloperName = 'Job_Search_Application'
            AND (StageName = 'Application Prepared' OR StageName = 'Job Discovered')
        ];

        List<Opportunity> updatedOpps = new List<Opportunity>();
        for (Opportunity opp : oppsToUpdate) {
            opp.StageName = 'Application Submitted';
            opp.Application_Submitted_Date__c = System.now();
            updatedOpps.add(opp);
        }

        if (!updatedOpps.isEmpty()) {
            update updatedOpps;
            System.debug('OpportunityProgressAutomation: Updated ' + updatedOpps.size() +
                ' Opportunities to Application Submitted stage');
        }
    }

    /**
     * @description Handles Event creation - updates Opportunity stage based on interview type
     * @param newEvents List of newly created Event records
     */
    public static void handleInterviewEventCreation(List<Event> newEvents) {
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, String> oppToStageMap = new Map<Id, String>();

        // Identify interview events and determine appropriate stage
        for (Event evt : newEvents) {
            if (evt.WhatId != null &&
                String.valueOf(evt.WhatId).startsWith('006') && // Opportunity ID prefix
                evt.Subject != null) {

                String newStage = determineStageFromEventSubject(evt.Subject);
                if (newStage != null) {
                    opportunityIds.add(evt.WhatId);
                    oppToStageMap.put(evt.WhatId, newStage);
                }
            }
        }

        if (opportunityIds.isEmpty()) {
            return;
        }

        // Query Opportunities
        List<Opportunity> oppsToUpdate = [
            SELECT Id, StageName, RecordType.DeveloperName
            FROM Opportunity
            WHERE Id IN :opportunityIds
            AND RecordType.DeveloperName = 'Job_Search_Application'
        ];

        List<Opportunity> updatedOpps = new List<Opportunity>();
        for (Opportunity opp : oppsToUpdate) {
            String proposedStage = oppToStageMap.get(opp.Id);

            // Only update if the new stage represents forward progress
            if (proposedStage != null && shouldUpdateStage(opp.StageName, proposedStage)) {
                opp.StageName = proposedStage;
                updatedOpps.add(opp);
            }
        }

        if (!updatedOpps.isEmpty()) {
            update updatedOpps;
            System.debug('OpportunityProgressAutomation: Updated ' + updatedOpps.size() +
                ' Opportunities based on interview events');
        }
    }

    /**
     * @description Handles Event completion - advances Opportunity stage when interview is completed
     * @param newEvents List of updated Event records
     * @param oldEventsMap Map of old Event records (before update)
     *
     * LEARNING: This method checks if an Event's EndDateTime has passed (meaning interview completed)
     * and advances the Opportunity to the next appropriate stage in the pipeline.
     */
    public static void handleInterviewEventCompletion(List<Event> newEvents, Map<Id, Event> oldEventsMap) {
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, String> oppToCurrentStageMap = new Map<Id, String>();

        DateTime now = System.now();

        // Identify interview events that just completed
        for (Event evt : newEvents) {
            Event oldEvt = oldEventsMap.get(evt.Id);

            // Check if this is an interview-related event linked to an Opportunity
            if (evt.WhatId != null &&
                String.valueOf(evt.WhatId).startsWith('006') && // Opportunity ID prefix
                evt.Subject != null &&
                evt.EndDateTime != null) {

                // Determine if this event just completed (EndDateTime passed)
                Boolean wasNotCompleted = oldEvt.EndDateTime > oldEventsMap.get(evt.Id).CreatedDate;
                Boolean isNowCompleted = evt.EndDateTime <= now;

                String currentStage = determineStageFromEventSubject(evt.Subject);

                // If event just completed and it's an interview stage
                if (isNowCompleted && currentStage != null) {
                    opportunityIds.add(evt.WhatId);
                    oppToCurrentStageMap.put(evt.WhatId, currentStage);
                }
            }
        }

        if (opportunityIds.isEmpty()) {
            return;
        }

        // Query Opportunities to check their current stage
        List<Opportunity> oppsToUpdate = [
            SELECT Id, StageName, RecordType.DeveloperName
            FROM Opportunity
            WHERE Id IN :opportunityIds
            AND RecordType.DeveloperName = 'Job_Search_Application'
        ];

        List<Opportunity> updatedOpps = new List<Opportunity>();
        for (Opportunity opp : oppsToUpdate) {
            String completedInterviewStage = oppToCurrentStageMap.get(opp.Id);

            // Only advance if Opportunity is still at the interview stage that just completed
            if (completedInterviewStage != null && opp.StageName == completedInterviewStage) {
                String nextStage = determineNextStageAfterInterview(completedInterviewStage);

                if (nextStage != null && shouldUpdateStage(opp.StageName, nextStage)) {
                    opp.StageName = nextStage;
                    updatedOpps.add(opp);
                    System.debug('OpportunityProgressAutomation: Advancing Opportunity ' + opp.Id +
                        ' from ' + completedInterviewStage + ' to ' + nextStage);
                }
            }
        }

        if (!updatedOpps.isEmpty()) {
            update updatedOpps;
            System.debug('OpportunityProgressAutomation: Advanced ' + updatedOpps.size() +
                ' Opportunities after interview completion');
        }
    }

    /**
     * @description Determines the next stage in the pipeline after completing an interview
     * @param completedStage The interview stage that was just completed
     * @return String The next stage to advance to, or null if no automatic advancement
     */
    private static String determineNextStageAfterInterview(String completedStage) {
        // Map each interview stage to the typical next stage
        Map<String, String> stageProgression = new Map<String, String>{
            'Screening Call' => 'Phone Screen',
            'Phone Screen' => 'Technical Interview',
            'Technical Interview' => 'Final Interview',
            'Final Interview' => 'Offer Negotiation'
        };

        return stageProgression.get(completedStage);
    }

    /**
     * @description Determines appropriate Opportunity stage based on Event subject
     * @param subject Event subject line
     * @return String Opportunity stage name, or null if no match
     */
    private static String determineStageFromEventSubject(String subject) {
        String lowerSubject = subject.toLowerCase();

        // Check for interview type keywords (order matters - most specific first)
        if (lowerSubject.contains('final') && lowerSubject.contains('interview')) {
            return 'Final Interview';
        }
        if (lowerSubject.contains('technical') && (lowerSubject.contains('interview') || lowerSubject.contains('assessment'))) {
            return 'Technical Interview';
        }
        if (lowerSubject.contains('phone screen') ||
            (lowerSubject.contains('phone') && lowerSubject.contains('interview'))) {
            return 'Phone Screen';
        }
        if (lowerSubject.contains('screening') || lowerSubject.contains('screen call') ||
            (lowerSubject.contains('recruiter') && lowerSubject.contains('call'))) {
            return 'Screening Call';
        }

        // Generic interview keyword
        if (lowerSubject.contains('interview')) {
            return 'Phone Screen'; // Default to Phone Screen for generic "Interview"
        }

        return null; // Not an interview-related event
    }

    /**
     * @description Determines if stage should be updated (prevents moving backwards)
     * @param currentStage Current Opportunity stage
     * @param proposedStage Proposed new stage
     * @return Boolean True if should update
     */
    private static Boolean shouldUpdateStage(String currentStage, String proposedStage) {
        // Define stage order by probability percentage
        Map<String, Integer> stageOrder = new Map<String, Integer>{
            'Job Discovered' => 10,
            'Application Prepared' => 20,
            'Application Submitted' => 30,
            'Screening Call' => 40,
            'Phone Screen' => 50,
            'Technical Interview' => 60,
            'Final Interview' => 75,
            'Offer Negotiation' => 90,
            'Closed Won' => 100,
            'Closed Lost' => 0
        };

        Integer currentOrder = stageOrder.get(currentStage);
        Integer proposedOrder = stageOrder.get(proposedStage);

        // Update if proposed stage is ahead, or if current/proposed order is unknown
        return (currentOrder == null || proposedOrder == null || proposedOrder > currentOrder);
    }
}

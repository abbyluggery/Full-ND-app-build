/**
 * @description Test class for OpportunityProgressAutomation
 * @author Abby Luggery / Claude Code Assistant
 * @date November 13, 2025
 */
@isTest
private class OpportunityProgressAutomationTest {

    @testSetup
    static void setupTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Company');
        insert acc;

        // Get Job Search Application record type
        RecordType rt = [SELECT Id FROM RecordType
                        WHERE SObjectType = 'Opportunity'
                        AND DeveloperName = 'Job_Search_Application' LIMIT 1];

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Senior Salesforce Developer - Test Company',
            AccountId = acc.Id,
            RecordTypeId = rt.Id,
            StageName = 'Job Discovered',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
    }

    @isTest
    static void testResumePackageCreation_UpdatesStage() {
        Opportunity opp = [SELECT Id, StageName, Application_Prepared_Date__c
                          FROM Opportunity LIMIT 1];

        // Verify initial state
        System.assertEquals('Job Discovered', opp.StageName,
            'Opportunity should start in Job Discovered stage');
        System.assertEquals(null, opp.Application_Prepared_Date__c,
            'Application Prepared Date should be null initially');

        Test.startTest();

        // Create Resume Package linked to Opportunity
        Resume_Package__c pkg = new Resume_Package__c(
            Opportunity__c = opp.Id,
            Status__c = 'Draft',
            Resume_Content__c = 'Test resume content',
            Cover_Letter__c = 'Test cover letter content'
        );
        insert pkg;

        Test.stopTest();

        // Verify stage was updated
        opp = [SELECT Id, StageName, Application_Prepared_Date__c
              FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals('Application Prepared', opp.StageName,
            'Opportunity stage should be updated to Application Prepared');
        System.assertNotEquals(null, opp.Application_Prepared_Date__c,
            'Application Prepared Date should be populated');
    }

    @isTest
    static void testApplicationEmailSent_UpdatesStage() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Update to Application Prepared stage first
        opp.StageName = 'Application Prepared';
        update opp;

        Test.startTest();

        // Create EmailMessage simulating application email
        EmailMessage email = new EmailMessage(
            RelatedToId = opp.Id,
            Subject = 'Application for Senior Salesforce Developer',
            TextBody = 'Please find my application attached.',
            Status = '3', // Sent
            Incoming = false
        );
        insert email;

        Test.stopTest();

        // Verify stage was updated
        opp = [SELECT Id, StageName, Application_Submitted_Date__c
              FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals('Application Submitted', opp.StageName,
            'Opportunity stage should be updated to Application Submitted');
        System.assertNotEquals(null, opp.Application_Submitted_Date__c,
            'Application Submitted Date should be populated');
    }

    @isTest
    static void testScreeningCallEvent_UpdatesStage() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Update to Application Submitted stage first
        opp.StageName = 'Application Submitted';
        update opp;

        Test.startTest();

        // Create screening call event
        Event evt = new Event(
            WhatId = opp.Id,
            Subject = 'Screening Call with Recruiter',
            StartDateTime = DateTime.now().addDays(2),
            EndDateTime = DateTime.now().addDays(2).addHours(1)
        );
        insert evt;

        Test.stopTest();

        // Verify stage was updated
        opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals('Screening Call', opp.StageName,
            'Opportunity stage should be updated to Screening Call');
    }

    @isTest
    static void testPhoneScreenEvent_UpdatesStage() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Update to Screening Call stage first
        opp.StageName = 'Screening Call';
        update opp;

        Test.startTest();

        // Create phone screen event
        Event evt = new Event(
            WhatId = opp.Id,
            Subject = 'Phone Screen - Technical Discussion',
            StartDateTime = DateTime.now().addDays(3),
            EndDateTime = DateTime.now().addDays(3).addHours(1)
        );
        insert evt;

        Test.stopTest();

        // Verify stage was updated
        opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals('Phone Screen', opp.StageName,
            'Opportunity stage should be updated to Phone Screen');
    }

    @isTest
    static void testTechnicalInterviewEvent_UpdatesStage() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Update to Phone Screen stage first
        opp.StageName = 'Phone Screen';
        update opp;

        Test.startTest();

        // Create technical interview event
        Event evt = new Event(
            WhatId = opp.Id,
            Subject = 'Technical Interview - Coding Assessment',
            StartDateTime = DateTime.now().addDays(5),
            EndDateTime = DateTime.now().addDays(5).addHours(2)
        );
        insert evt;

        Test.stopTest();

        // Verify stage was updated
        opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals('Technical Interview', opp.StageName,
            'Opportunity stage should be updated to Technical Interview');
    }

    @isTest
    static void testFinalInterviewEvent_UpdatesStage() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Update to Technical Interview stage first
        opp.StageName = 'Technical Interview';
        update opp;

        Test.startTest();

        // Create final interview event
        Event evt = new Event(
            WhatId = opp.Id,
            Subject = 'Final Interview with Hiring Manager',
            StartDateTime = DateTime.now().addDays(7),
            EndDateTime = DateTime.now().addDays(7).addHours(1)
        );
        insert evt;

        Test.stopTest();

        // Verify stage was updated
        opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals('Final Interview', opp.StageName,
            'Opportunity stage should be updated to Final Interview');
    }

    @isTest
    static void testNoBackwardMovement() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Set to Final Interview stage
        opp.StageName = 'Final Interview';
        update opp;

        Test.startTest();

        // Try to create screening call event (earlier stage)
        Event evt = new Event(
            WhatId = opp.Id,
            Subject = 'Screening Call',
            StartDateTime = DateTime.now().addDays(1),
            EndDateTime = DateTime.now().addDays(1).addHours(1)
        );
        insert evt;

        Test.stopTest();

        // Verify stage was NOT moved backward
        opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals('Final Interview', opp.StageName,
            'Opportunity stage should NOT move backward from Final Interview to Screening Call');
    }

    @isTest
    static void testNonJobSearchOpportunity_NotUpdated() {
        // Create standard Opportunity (not Job Search Application)
        Account acc = new Account(Name = 'Test Company 2');
        insert acc;

        Opportunity stdOpp = new Opportunity(
            Name = 'Standard Opp',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert stdOpp;

        String originalStage = stdOpp.StageName;

        Test.startTest();

        // Create Resume Package for standard opportunity
        Resume_Package__c pkg = new Resume_Package__c(
            Opportunity__c = stdOpp.Id,
            Status__c = 'Draft'
        );
        insert pkg;

        Test.stopTest();

        // Verify stage was NOT updated
        stdOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :stdOpp.Id];

        System.assertEquals(originalStage, stdOpp.StageName,
            'Standard Opportunity stage should NOT be updated by automation');
    }

    @isTest
    static void testGenericInterviewEvent_UpdatesToPhoneScreen() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Update to Application Submitted stage first
        opp.StageName = 'Application Submitted';
        update opp;

        Test.startTest();

        // Create generic interview event
        Event evt = new Event(
            WhatId = opp.Id,
            Subject = 'Interview',
            StartDateTime = DateTime.now().addDays(3),
            EndDateTime = DateTime.now().addDays(3).addHours(1)
        );
        insert evt;

        Test.stopTest();

        // Verify stage defaults to Phone Screen
        opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals('Phone Screen', opp.StageName,
            'Generic interview should default to Phone Screen stage');
    }
}

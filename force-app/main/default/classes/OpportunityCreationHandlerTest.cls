/**
 * Test Class: OpportunityCreationHandlerTest
 * Purpose: Test coverage for OpportunityCreationHandler and OpportunityCreationTrigger
 */
@isTest
private class OpportunityCreationHandlerTest {

    @testSetup
    static void setupTestData() {
        // Create a test Job Posting
        Job_Posting__c jobPosting = new Job_Posting__c(
            Title__c = 'Senior Salesforce Developer',
            Company__c = 'Test Company Inc',
            Location__c = 'Remote - USA',
            Description__c = 'Test job description',
            Application_Status__c = 'Applied',
            Apply_URL__c = 'https://example.com/apply',
            ExternalID__c = 'TEST-12345',
            Provider__c = 'LinkedIn',
            Status__c = 'Active',
            Recruiter_Name__c = 'Jane Smith',
            Recruiter_Email__c = 'jane.smith@testcompany.com',
            Recruiter_Phone__c = '555-123-4567',
            Recruiter_Title__c = 'Technical Recruiter',
            Recruiter_LinkedIn__c = 'https://linkedin.com/in/janesmith'
        );
        insert jobPosting;
    }

    @isTest
    static void testOpportunityCreationOnCallbackReceived() {
        // Get the test job posting
        Job_Posting__c jobPosting = [SELECT Id, Title__c, Company__c, Application_Status__c
                                      FROM Job_Posting__c LIMIT 1];

        Test.startTest();

        // Update status to trigger opportunity creation
        jobPosting.Application_Status__c = 'Callback Received';
        update jobPosting;

        Test.stopTest();

        // Verify Account was created
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Company Inc'];
        System.assertEquals(1, accounts.size(), 'Account should be created');

        // Verify Contact was created
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, Phone, Title, LinkedIn__c
                                  FROM Contact WHERE AccountId = :accounts[0].Id];
        System.assertEquals(1, contacts.size(), 'Contact should be created');
        System.assertEquals('Jane', contacts[0].FirstName, 'First name should match');
        System.assertEquals('Smith', contacts[0].LastName, 'Last name should match');
        System.assertEquals('jane.smith@testcompany.com', contacts[0].Email, 'Email should match');
        System.assertEquals('555-123-4567', contacts[0].Phone, 'Phone should match');
        System.assertEquals('Technical Recruiter', contacts[0].Title, 'Title should match');
        System.assertEquals('https://linkedin.com/in/janesmith', contacts[0].LinkedIn__c, 'LinkedIn should match');

        // Verify Opportunity was created
        List<Opportunity> opportunities = [SELECT Id, Name, AccountId, Job_Posting__c, StageName
                                           FROM Opportunity WHERE Job_Posting__c = :jobPosting.Id];
        System.assertEquals(1, opportunities.size(), 'Opportunity should be created');
        System.assertEquals('Senior Salesforce Developer - Test Company Inc', opportunities[0].Name, 'Opportunity name should match');
        System.assertEquals('Screening Call', opportunities[0].StageName, 'Stage should be Screening Call');
        System.assertEquals(accounts[0].Id, opportunities[0].AccountId, 'Opportunity should be linked to Account');

        // Verify Opportunity Contact Role was created
        List<OpportunityContactRole> contactRoles = [SELECT Id, OpportunityId, ContactId, Role, IsPrimary
                                                      FROM OpportunityContactRole
                                                      WHERE OpportunityId = :opportunities[0].Id];
        System.assertEquals(1, contactRoles.size(), 'Contact role should be created');
        System.assertEquals(contacts[0].Id, contactRoles[0].ContactId, 'Contact role should link to Contact');
        System.assertEquals('Decision Maker', contactRoles[0].Role, 'Role should be Decision Maker');
        System.assertEquals(true, contactRoles[0].IsPrimary, 'Should be primary contact');
    }

    @isTest
    static void testNoOpportunityCreationWhenStatusNotCallbackReceived() {
        // Get the test job posting
        Job_Posting__c jobPosting = [SELECT Id, Application_Status__c FROM Job_Posting__c LIMIT 1];

        Test.startTest();

        // Update to different status - should NOT trigger opportunity creation
        jobPosting.Application_Status__c = 'Phone Screen';
        update jobPosting;

        Test.stopTest();

        // Verify NO Opportunity was created
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE Job_Posting__c = :jobPosting.Id];
        System.assertEquals(0, opportunities.size(), 'Opportunity should NOT be created for Phone Screen status');
    }

    @isTest
    static void testExistingAccountReused() {
        // Create an existing account
        Account existingAccount = new Account(Name = 'Test Company Inc');
        insert existingAccount;

        // Get the test job posting
        Job_Posting__c jobPosting = [SELECT Id, Application_Status__c FROM Job_Posting__c LIMIT 1];

        Test.startTest();

        // Update status to trigger opportunity creation
        jobPosting.Application_Status__c = 'Callback Received';
        update jobPosting;

        Test.stopTest();

        // Verify only ONE account exists (the existing one was reused)
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Test Company Inc'];
        System.assertEquals(1, accounts.size(), 'Should reuse existing account');

        // Verify Opportunity uses the existing account
        List<Opportunity> opportunities = [SELECT Id, AccountId FROM Opportunity WHERE Job_Posting__c = :jobPosting.Id];
        System.assertEquals(1, opportunities.size(), 'Opportunity should be created');
        System.assertEquals(existingAccount.Id, opportunities[0].AccountId, 'Should use existing account');
    }

    @isTest
    static void testMultipleJobPostingsCallbackReceived() {
        // Create additional job postings
        List<Job_Posting__c> jobPostings = new List<Job_Posting__c>{
            new Job_Posting__c(
                Title__c = 'Salesforce Architect',
                Company__c = 'Tech Corp',
                Location__c = 'San Francisco, CA',
                Application_Status__c = 'Applied',
                Apply_URL__c = 'https://example.com/apply1',
                ExternalID__c = 'TEST-22222',
                Provider__c = 'LinkedIn',
                Status__c = 'Active',
                Recruiter_Name__c = 'John Doe',
                Recruiter_Email__c = 'john@techcorp.com'
            ),
            new Job_Posting__c(
                Title__c = 'Salesforce Admin',
                Company__c = 'Business Solutions LLC',
                Location__c = 'New York, NY',
                Application_Status__c = 'Applied',
                Apply_URL__c = 'https://example.com/apply2',
                ExternalID__c = 'TEST-33333',
                Provider__c = 'LinkedIn',
                Status__c = 'Active',
                Recruiter_Name__c = 'Sarah Johnson',
                Recruiter_Email__c = 'sarah@bizsolutions.com'
            )
        };
        insert jobPostings;

        Test.startTest();

        // Update both to Callback Received
        for (Job_Posting__c jp : jobPostings) {
            jp.Application_Status__c = 'Callback Received';
        }
        update jobPostings;

        Test.stopTest();

        // Verify 2 new accounts created (no account from test setup since it doesn't have callback)
        List<Account> accounts = [SELECT Id FROM Account];
        System.assertEquals(2, accounts.size(), 'Should create 2 accounts total');

        // Verify 2 new opportunities created
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE Job_Posting__c IN :jobPostings];
        System.assertEquals(2, opportunities.size(), 'Should create 2 opportunities');
    }

    @isTest
    static void testJobPostingWithoutRecruiterName() {
        // Create job posting without recruiter name
        Job_Posting__c jobPosting = new Job_Posting__c(
            Title__c = 'Developer Role',
            Company__c = 'Anonymous Corp',
            Location__c = 'Remote',
            Application_Status__c = 'Applied',
            Apply_URL__c = 'https://example.com/apply3',
            ExternalID__c = 'TEST-44444',
            Provider__c = 'LinkedIn',
            Status__c = 'Active',
            Recruiter_Email__c = 'recruiter@anonymous.com'
            // No Recruiter_Name__c
        );
        insert jobPosting;

        Test.startTest();

        jobPosting.Application_Status__c = 'Callback Received';
        update jobPosting;

        Test.stopTest();

        // Verify Contact was still created with default name
        List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact];
        System.assertEquals(1, contacts.size(), 'Contact should be created even without recruiter name');
        System.assertEquals('Recruiter', contacts[0].FirstName, 'Should use default first name');
        System.assertEquals('Anonymous Corp', contacts[0].LastName, 'Should use company name as last name');
    }

    @isTest
    static void testJobPostingInsertWithCallbackReceived() {
        Test.startTest();

        // Insert NEW job posting with Callback Received status
        Job_Posting__c jobPosting = new Job_Posting__c(
            Title__c = 'Urgent Role',
            Company__c = 'Fast Hire Inc',
            Location__c = 'Austin, TX',
            Application_Status__c = 'Callback Received',
            Apply_URL__c = 'https://example.com/apply4',
            ExternalID__c = 'TEST-55555',
            Provider__c = 'LinkedIn',
            Status__c = 'Active',
            Recruiter_Name__c = 'Quick Recruiter',
            Recruiter_Email__c = 'quick@fasthire.com'
        );
        insert jobPosting;

        Test.stopTest();

        // Verify Opportunity was created on insert
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE Job_Posting__c = :jobPosting.Id];
        System.assertEquals(1, opportunities.size(), 'Opportunity should be created on insert with Callback Received status');
    }
}

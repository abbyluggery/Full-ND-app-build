/**
 * Handler: OpportunityCreationHandler
 * Purpose: Business logic for creating Opportunities from Job Postings
 *
 * Handles the workflow when Application_Status__c = "Callback Received"
 */
public with sharing class OpportunityCreationHandler {

    /**
     * Main handler method - processes Job_Posting__c records
     * Creates Opportunity, Account, and Contact when callback occurs
     */
    public static void handleOpportunityCreation(List<Job_Posting__c> newJobPostings, Map<Id, Job_Posting__c> oldJobPostingMap) {

        List<Job_Posting__c> callbackJobPostings = new List<Job_Posting__c>();

        // Filter for records where Application_Status__c changed to "Callback Received"
        for (Job_Posting__c jobPosting : newJobPostings) {
            String newStatus = jobPosting.Application_Status__c;
            String oldStatus = (oldJobPostingMap != null && oldJobPostingMap.containsKey(jobPosting.Id))
                ? oldJobPostingMap.get(jobPosting.Id).Application_Status__c
                : null;

            // Check if status changed to "Callback Received"
            if (newStatus == 'Callback Received' && newStatus != oldStatus) {
                callbackJobPostings.add(jobPosting);
            }
        }

        if (callbackJobPostings.isEmpty()) {
            return;
        }

        // Process each callback job posting
        createOpportunitiesFromJobPostings(callbackJobPostings);
    }

    /**
     * Creates Opportunities, Accounts, and Contacts for job postings
     */
    private static void createOpportunitiesFromJobPostings(List<Job_Posting__c> jobPostings) {

        // Collect company names to check for existing accounts
        Set<String> companyNames = new Set<String>();
        for (Job_Posting__c jp : jobPostings) {
            if (String.isNotBlank(jp.Company__c)) {
                companyNames.add(jp.Company__c);
            }
        }

        // Query for existing accounts
        Map<String, Account> existingAccounts = new Map<String, Account>();
        for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :companyNames]) {
            existingAccounts.put(acc.Name, acc);
        }

        // Lists for DML operations
        List<Account> accountsToInsert = new List<Account>();
        List<Contact> contactsToInsert = new List<Contact>();
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();

        // Map to track which account goes with which job posting
        Map<String, Account> companyToAccountMap = new Map<String, Account>();

        // Step 1: Create or identify accounts
        for (Job_Posting__c jp : jobPostings) {
            if (String.isBlank(jp.Company__c)) {
                continue;
            }

            Account acc;
            if (existingAccounts.containsKey(jp.Company__c)) {
                // Use existing account
                acc = existingAccounts.get(jp.Company__c);
            } else if (!companyToAccountMap.containsKey(jp.Company__c)) {
                // Create new account
                acc = new Account(
                    Name = jp.Company__c,
                    Description = 'Auto-created from Job Posting: ' + jp.Title__c
                );
                accountsToInsert.add(acc);
                companyToAccountMap.put(jp.Company__c, acc);
            } else {
                // Account already in map
                acc = companyToAccountMap.get(jp.Company__c);
            }
        }

        // Insert new accounts
        if (!accountsToInsert.isEmpty()) {
            try {
                insert accountsToInsert;
                // Add newly created accounts to the map
                for (Account acc : accountsToInsert) {
                    existingAccounts.put(acc.Name, acc);
                }
            } catch (DmlException e) {
                System.debug('Error creating accounts: ' + e.getMessage());
                return;
            }
        }

        // Step 2: Create contacts and opportunities
        Map<Id, Contact> jobPostingToContactMap = new Map<Id, Contact>();

        for (Job_Posting__c jp : jobPostings) {
            if (String.isBlank(jp.Company__c)) {
                continue;
            }

            Account relatedAccount = existingAccounts.get(jp.Company__c);
            if (relatedAccount == null) {
                continue;
            }

            // Create Contact from recruiter information
            Contact recruiterContact = new Contact();
            recruiterContact.AccountId = relatedAccount.Id;

            // Parse recruiter name into FirstName and LastName
            if (String.isNotBlank(jp.Recruiter_Name__c)) {
                List<String> nameParts = jp.Recruiter_Name__c.trim().split('\\s+', 2);
                recruiterContact.FirstName = nameParts[0];
                recruiterContact.LastName = nameParts.size() > 1 ? nameParts[1] : nameParts[0];
            } else {
                // Default name if no recruiter name provided
                recruiterContact.FirstName = 'Recruiter';
                recruiterContact.LastName = relatedAccount.Name;
            }

            recruiterContact.Email = jp.Recruiter_Email__c;
            recruiterContact.Phone = jp.Recruiter_Phone__c;
            recruiterContact.Title = jp.Recruiter_Title__c;
            recruiterContact.LinkedIn__c = jp.Recruiter_LinkedIn__c;
            recruiterContact.Description = 'Recruiter for: ' + jp.Title__c;

            contactsToInsert.add(recruiterContact);
            jobPostingToContactMap.put(jp.Id, recruiterContact);

            // Create Opportunity
            Opportunity opp = new Opportunity();
            opp.Name = jp.Title__c + ' - ' + jp.Company__c;
            opp.AccountId = relatedAccount.Id;
            opp.Job_Posting__c = jp.Id;
            opp.StageName = 'Screening Call';
            opp.CloseDate = Date.today().addDays(30); // Default 30 days out
            opp.Description = 'Job opportunity from posting: ' + jp.Title__c + '\n\n' +
                             'Location: ' + (String.isNotBlank(jp.Location__c) ? jp.Location__c : 'Not specified');

            opportunitiesToInsert.add(opp);
        }

        // Insert contacts
        if (!contactsToInsert.isEmpty()) {
            try {
                insert contactsToInsert;
            } catch (DmlException e) {
                System.debug('Error creating contacts: ' + e.getMessage());
                return;
            }
        }

        // Insert opportunities
        if (!opportunitiesToInsert.isEmpty()) {
            try {
                insert opportunitiesToInsert;
            } catch (DmlException e) {
                System.debug('Error creating opportunities: ' + e.getMessage());
                return;
            }
        }

        // Step 3: Create Opportunity Contact Roles
        List<OpportunityContactRole> contactRolesToInsert = new List<OpportunityContactRole>();

        Integer i = 0;
        for (Job_Posting__c jp : jobPostings) {
            if (i >= opportunitiesToInsert.size() || i >= contactsToInsert.size()) {
                break;
            }

            Contact relatedContact = jobPostingToContactMap.get(jp.Id);
            if (relatedContact != null && relatedContact.Id != null) {
                OpportunityContactRole ocr = new OpportunityContactRole();
                ocr.OpportunityId = opportunitiesToInsert[i].Id;
                ocr.ContactId = relatedContact.Id;
                ocr.Role = 'Decision Maker'; // Can be customized
                ocr.IsPrimary = true;

                contactRolesToInsert.add(ocr);
            }

            i++;
        }

        // Insert opportunity contact roles
        if (!contactRolesToInsert.isEmpty()) {
            try {
                insert contactRolesToInsert;
            } catch (DmlException e) {
                System.debug('Error creating opportunity contact roles: ' + e.getMessage());
            }
        }
    }
}

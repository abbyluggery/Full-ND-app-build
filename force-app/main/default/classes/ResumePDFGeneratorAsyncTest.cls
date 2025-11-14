/**
 * @description Test class for ResumePDFGeneratorAsync
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-11-11
 */
@isTest
private class ResumePDFGeneratorAsyncTest {

    @testSetup
    static void setup() {
        // Create test Job Posting
        Job_Posting__c job = new Job_Posting__c(
            Title__c = 'Test Salesforce Developer',
            Company__c = 'Test Company',
            Description__c = 'Test job description'
        );
        insert job;

        // Create test Resume Package
        Resume_Package__c pkg = new Resume_Package__c(
            Job_Posting__c = job.Id,
            Resume_Content__c = 'Test resume content for async PDF generation',
            Cover_Letter__c = 'Test cover letter content for async PDF generation',
            Status__c = 'Draft'
        );
        insert pkg;
    }

    @isTest
    static void testAsyncPDFGeneration() {
        Resume_Package__c pkg = [SELECT Id FROM Resume_Package__c LIMIT 1];

        Test.startTest();
        System.enqueueJob(new ResumePDFGeneratorAsync(pkg.Id));
        Test.stopTest();

        // Verify Resume Package status was updated to Ready
        Resume_Package__c updatedPkg = [
            SELECT Id, Status__c
            FROM Resume_Package__c
            WHERE Id = :pkg.Id
        ];

        System.assertEquals('Ready', updatedPkg.Status__c, 'Resume Package status should be Ready after PDF generation');
    }

    @isTest
    static void testAsyncPDFGenerationWithInvalidId() {
        // Create a fake ID that doesn't exist
        Id fakeId = 'a1F000000000000AAA';

        Test.startTest();
        try {
            System.enqueueJob(new ResumePDFGeneratorAsync(fakeId));
            Test.stopTest();
            // Should not throw exception, just log error
        } catch (Exception e) {
            System.assert(false, 'Async job should handle errors gracefully: ' + e.getMessage());
        }
    }
}

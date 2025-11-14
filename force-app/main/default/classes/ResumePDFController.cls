/**
 * @description Controller for ResumePDF Visualforce page
 * Fetches resume content from Resume_Package__c record
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-11-04
 */
public without sharing class ResumePDFController {

    public String resumeContent { get; set; }

    public ResumePDFController() {
        // Get Resume Package ID from URL parameter
        String resumePackageId = ApexPages.currentPage().getParameters().get('id');

        if (String.isNotBlank(resumePackageId)) {
            try {
                // Debug: Log what ID we're looking for
                System.debug('ResumePDFController: Looking for Resume Package ID: ' + resumePackageId);

                // Query the Resume Package record - use List to avoid exception
                // Note: without sharing class bypasses sharing rules
                List<Resume_Package__c> pkgs = [
                    SELECT Id, Resume_Content__c
                    FROM Resume_Package__c
                    WHERE Id = :resumePackageId
                    LIMIT 1
                ];

                System.debug('ResumePDFController: Query returned ' + pkgs.size() + ' records');

                if (!pkgs.isEmpty()) {
                    Resume_Package__c pkg = pkgs[0];

                    System.debug('ResumePDFController: Found package, content length: ' +
                                (pkg.Resume_Content__c != null ? pkg.Resume_Content__c.length() : 0));

                    // Set the content, converting line breaks to HTML
                    if (String.isNotBlank(pkg.Resume_Content__c)) {
                        resumeContent = pkg.Resume_Content__c.replaceAll('\n', '<br/>');
                    } else {
                        resumeContent = 'No resume content available - field is empty.';
                    }
                } else {
                    System.debug('ResumePDFController: ERROR - No records found for ID: ' + resumePackageId);
                    resumeContent = 'Error: Resume Package not found with ID: ' + resumePackageId;
                }

            } catch (Exception e) {
                resumeContent = 'Error loading resume: ' + e.getMessage() + '<br/>Stack: ' + e.getStackTraceString();
            }
        } else {
            resumeContent = 'No Resume Package ID provided in URL.';
        }
    }
}

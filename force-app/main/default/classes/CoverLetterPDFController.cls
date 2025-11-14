/**
 * @description Controller for CoverLetterPDF Visualforce page
 * Fetches cover letter content from Resume_Package__c record
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-11-04
 */
public without sharing class CoverLetterPDFController {

    public String coverLetterContent { get; set; }

    public CoverLetterPDFController() {
        // Get Resume Package ID from URL parameter
        String resumePackageId = ApexPages.currentPage().getParameters().get('id');

        if (String.isNotBlank(resumePackageId)) {
            try {
                // Debug: Log what ID we're looking for
                System.debug('CoverLetterPDFController: Looking for Resume Package ID: ' + resumePackageId);

                // Query the Resume Package record - use List to avoid exception
                // Note: without sharing class bypasses sharing rules
                List<Resume_Package__c> pkgs = [
                    SELECT Id, Cover_Letter__c
                    FROM Resume_Package__c
                    WHERE Id = :resumePackageId
                    LIMIT 1
                ];

                System.debug('CoverLetterPDFController: Query returned ' + pkgs.size() + ' records');

                if (!pkgs.isEmpty()) {
                    Resume_Package__c pkg = pkgs[0];

                    System.debug('CoverLetterPDFController: Found package, content length: ' +
                                (pkg.Cover_Letter__c != null ? pkg.Cover_Letter__c.length() : 0));

                    // Set the content, converting line breaks to HTML
                    if (String.isNotBlank(pkg.Cover_Letter__c)) {
                        coverLetterContent = pkg.Cover_Letter__c.replaceAll('\n', '<br/>');
                    } else {
                        coverLetterContent = 'No cover letter content available - field is empty.';
                    }
                } else {
                    System.debug('CoverLetterPDFController: ERROR - No records found for ID: ' + resumePackageId);
                    coverLetterContent = 'Error: Resume Package not found with ID: ' + resumePackageId;
                }

            } catch (Exception e) {
                coverLetterContent = 'Error loading cover letter: ' + e.getMessage() + '<br/>Stack: ' + e.getStackTraceString();
            }
        } else {
            coverLetterContent = 'No Resume Package ID provided in URL.';
        }
    }
}

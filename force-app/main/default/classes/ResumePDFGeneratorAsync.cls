/**
 * @description Asynchronous PDF generation to avoid transaction rollback issues
 * Generates PDF files in a separate transaction after Resume Package is committed
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-11-11
 */
public class ResumePDFGeneratorAsync implements Queueable, Database.AllowsCallouts {

    private Id resumePackageId;

    public ResumePDFGeneratorAsync(Id resumePackageId) {
        this.resumePackageId = resumePackageId;
    }

    public void execute(QueueableContext context) {
        try {
            System.debug('ResumePDFGeneratorAsync: Starting PDF generation for Resume Package: ' + resumePackageId);

            // Generate the PDF files
            Map<String, Id> fileIds = ResumePDFGenerator.generateResumeFiles(resumePackageId);

            System.debug('ResumePDFGeneratorAsync: PDF generation completed successfully');
            System.debug('Resume File ID: ' + fileIds.get('resume'));
            System.debug('Cover Letter File ID: ' + fileIds.get('coverLetter'));

            // Update Resume Package status to indicate PDFs are ready
            Resume_Package__c pkg = new Resume_Package__c(
                Id = resumePackageId,
                Status__c = 'Ready'
            );
            update pkg;

        } catch (Exception e) {
            System.debug('ResumePDFGeneratorAsync: ERROR generating PDFs: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());

            // Update Resume Package status to indicate PDF generation failed
            try {
                Resume_Package__c pkg = new Resume_Package__c(
                    Id = resumePackageId,
                    Status__c = 'Draft' // Keep as Draft if PDF generation fails
                );
                update pkg;
            } catch (Exception updateEx) {
                System.debug('ResumePDFGeneratorAsync: ERROR updating status: ' + updateEx.getMessage());
            }
        }
    }
}

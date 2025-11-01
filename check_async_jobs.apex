// Check if there are any queued or failed async jobs for JobPostingAnalysisQueue
List<AsyncApexJob> jobs = [
    SELECT Id, Status, JobType, ApexClass.Name, CreatedDate, CompletedDate,
           NumberOfErrors, ExtendedStatus
    FROM AsyncApexJob
    WHERE ApexClass.Name = 'JobPostingAnalysisQueue'
    ORDER BY CreatedDate DESC
    LIMIT 10
];

System.debug('=== Recent JobPostingAnalysisQueue Jobs ===');
for (AsyncApexJob job : jobs) {
    System.debug('Job: ' + job.Id + ' | Status: ' + job.Status + ' | Created: ' + job.CreatedDate + ' | Errors: ' + job.NumberOfErrors);
    if (String.isNotBlank(job.ExtendedStatus)) {
        System.debug('  Extended Status: ' + job.ExtendedStatus);
    }
}

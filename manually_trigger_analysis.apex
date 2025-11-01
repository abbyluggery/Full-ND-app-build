// Manually trigger analysis for Salesforce Administrator job
// This will force re-analysis regardless of whether fields changed

// Find the Salesforce Administrator job
List<Job_Posting__c> jobs = [
    SELECT Id, Title__c, Salary_Min__c, Salary_Max__c
    FROM Job_Posting__c
    WHERE Title__c LIKE 'Salesforce Administrator%'
    ORDER BY LastModifiedDate DESC
    LIMIT 1
];

if (!jobs.isEmpty()) {
    Job_Posting__c job = jobs[0];
    System.debug('Found job: ' + job.Title__c + ' (ID: ' + job.Id + ')');
    System.debug('Salary Min: ' + job.Salary_Min__c);
    System.debug('Salary Max: ' + job.Salary_Max__c);

    // Manually enqueue analysis
    List<Id> jobIds = new List<Id>{ job.Id };
    JobPostingAnalysisQueue.enqueueAnalysis(jobIds);

    System.debug('Analysis queued successfully!');
    System.debug('Wait 60 seconds, then check the job posting for updated AI fields.');
} else {
    System.debug('ERROR: Job not found');
}

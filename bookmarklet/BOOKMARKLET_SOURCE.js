/* Job Capture Bookmarklet - Readable Source Code
 *
 * This is the unminified version you can edit and customize.
 * After editing, you'll need to minify it and URL-encode it for the bookmarklet.
 * Use https://www.toptal.com/developers/javascript-minifier/ to minify
 * Then use https://www.urlencoder.org/ to encode
 */

(function() {
    /* Detect which job board we're on */
    var hostname = window.location.hostname;
    var jobData = {
        title: '',
        company: '',
        location: '',
        salary: '',
        description: ''
    };

    /* LinkedIn selectors */
    if (hostname.includes('linkedin.com')) {
        jobData.title = document.querySelector('.job-details-jobs-unified-top-card__job-title, .jobs-unified-top-card__job-title')?.textContent?.trim() || '';
        jobData.company = document.querySelector('.job-details-jobs-unified-top-card__company-name, .jobs-unified-top-card__company-name')?.textContent?.trim() || '';
        jobData.location = document.querySelector('.job-details-jobs-unified-top-card__bullet, .jobs-unified-top-card__bullet')?.textContent?.trim() || '';
        jobData.description = document.querySelector('.jobs-description__content, .jobs-box__html-content')?.textContent?.trim() || '';
    }

    /* Indeed selectors */
    else if (hostname.includes('indeed.com')) {
        jobData.title = document.querySelector('.jobsearch-JobInfoHeader-title')?.textContent?.trim() || '';
        jobData.company = document.querySelector('[data-company-name="true"]')?.textContent?.trim() || '';
        jobData.location = document.querySelector('[data-testid="job-location"]')?.textContent?.trim() || '';
        jobData.description = document.querySelector('#jobDescriptionText')?.textContent?.trim() || '';
    }

    /* Generic fallback */
    else {
        jobData.title = document.querySelector('h1')?.textContent?.trim() || '';
    }

    /* YOUR SALESFORCE URL - EDIT THIS IF NEEDED */
    var sfUrl = 'https://orgfarm-d7ac6d4026-dev-ed.develop.my.salesforce.com';

    /* Build Salesforce URL with pre-filled fields */
    var newUrl = sfUrl + '/lightning/o/Job_Posting__c/new?' +
        'defaultFieldValues=' + encodeURIComponent(
            'Title__c=' + jobData.title +
            ',Company__c=' + jobData.company +
            ',Location__c=' + jobData.location +
            ',Description__c=' + jobData.description +
            ',Apply_URL__c=' + window.location.href +
            ',Provider__c=LinkedIn' + // Default to LinkedIn, change manually if needed
            ',Status__c=Active' +
            ',Posted_Date__c=' + new Date().toISOString().split('T')[0] // Today's date
        );

    /* Open Salesforce in new tab */
    window.open(newUrl, '_blank');
})();

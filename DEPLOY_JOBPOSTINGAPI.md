# Deploy JobPostingAPI via Developer Console

Since CLI deployment is having issues, let's deploy directly via Developer Console:

## Step 1: Create JobPostingAPI Class

1. **Open Developer Console** (Setup > Developer Console)
2. **File** > **New** > **Apex Class**
3. **Name**: `JobPostingAPI`
4. **Paste this complete code**:

```apex
@RestResource(urlMapping='/jobposting/*')
global with sharing class JobPostingAPI {

    @HttpPost
    global static JobPostingResponse createJobPosting(JobPostingRequest request) {
        JobPostingResponse response = new JobPostingResponse();

        try {
            // Create the job posting record
            Job_Posting__c job = new Job_Posting__c();
            job.Title__c = request.title;
            job.Company__c = request.company;
            job.Location__c = request.location;
            job.Description__c = request.description;
            job.Apply_URL__c = request.applyUrl;
            job.Provider__c = request.provider != null ? request.provider : 'Dice';
            job.ExternalID__c = request.externalId;
            job.Status__c = 'Active';
            job.Posted_Date__c = Date.today();

            // Parse workplace type from description/title
            job.Workplace_Type__c = determineWorkplaceType(request);

            // Parse salary if provided
            if (String.isNotBlank(request.salaryMin)) {
                try {
                    job.Salary_Min__c = Decimal.valueOf(request.salaryMin);
                } catch (Exception e) {
                    System.debug('Could not parse salary min: ' + request.salaryMin);
                }
            }

            if (String.isNotBlank(request.salaryMax)) {
                try {
                    job.Salary_Max__c = Decimal.valueOf(request.salaryMax);
                } catch (Exception e) {
                    System.debug('Could not parse salary max: ' + request.salaryMax);
                }
            }

            if (String.isNotBlank(request.currencyCode)) {
                job.Currency__c = request.currencyCode;
            } else {
                job.Currency__c = 'USD';
            }

            if (String.isNotBlank(request.salaryInterval)) {
                job.Interval__c = request.salaryInterval;
            } else {
                job.Interval__c = 'Yearly';
            }

            // Insert the job (trigger will fire and analyze with Claude!)
            insert job;

            response.success = true;
            response.jobId = job.Id;
            response.message = 'Job posting created successfully! Claude is analyzing it now.';

        } catch (Exception e) {
            response.success = false;
            response.message = 'Error creating job posting: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'JobPostingAPI Error: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
        }

        return response;
    }

    private static String determineWorkplaceType(JobPostingRequest request) {
        String combined = (request.title + ' ' + request.location + ' ' + request.description).toLowerCase();

        if (combined.contains('remote') || combined.contains('work from home')) {
            return 'Remote';
        } else if (combined.contains('hybrid')) {
            return 'Hybrid';
        } else if (combined.contains('on-site') || combined.contains('onsite') || combined.contains('office')) {
            return 'On-Site';
        }

        return 'Remote'; // Default to remote for your search
    }

    // Request wrapper
    global class JobPostingRequest {
        public String title;
        public String company;
        public String location;
        public String description;
        public String applyUrl;
        public String provider;
        public String externalID;
        public String salaryMin;
        public String salaryMax;
        public String currencyCode;
        public String salaryInterval;
    }

    // Response wrapper
    global class JobPostingResponse {
        public Boolean success;
        public String jobId;
        public String message;
    }
}
```

5. **Save** (Ctrl+S or File > Save)

## Step 2: Test It Works

Run this in **Execute Anonymous** window (Debug > Open Execute Anonymous Window):

```apex
// Simulate Chrome Extension POST request
RestRequest req = new RestRequest();
RestResponse res = new RestResponse();
req.requestURI = '/services/apexrest/jobposting/';
req.httpMethod = 'POST';
RestContext.request = req;
RestContext.response = res;

JobPostingAPI.JobPostingRequest testReq = new JobPostingAPI.JobPostingRequest();
testReq.title = 'Chrome Extension Test Job';
testReq.company = 'Test Company';
testReq.location = 'Remote';
testReq.description = 'Testing the JobPostingAPI endpoint for Chrome Extension';
testReq.applyUrl = 'https://test.com/job/extension-test';
testReq.provider = 'LinkedIn';
testReq.externalID = 'ext_test_' + System.now().getTime();
testReq.salaryMin = '100000';
testReq.salaryMax = '130000';
testReq.currencyCode = 'USD';
testReq.salaryInterval = 'Yearly';

JobPostingAPI.JobPostingResponse response = JobPostingAPI.createJobPosting(testReq);

System.debug('✅ Success: ' + response.success);
System.debug('Job ID: ' + response.jobId);
System.debug('Message: ' + response.message);
```

You should see:
- `✅ Success: true`
- `Job ID: a1Gxxxxxxxxxxxx` (some ID)
- `Message: Job posting created successfully! Claude is analyzing it now.`

## Step 3: Verify the Job Was Created

Go to **Job Postings** tab and you should see:
- "Chrome Extension Test Job" at Test Company
- Salary: $100,000 - $130,000
- Claude is analyzing it (check back in 30 seconds for ND score!)

## Next: Configure Chrome Extension

Once this API is working, we'll configure the Chrome Extension with:
- Your Salesforce instance URL
- Your username/password
- And you'll be able to capture jobs from any website!

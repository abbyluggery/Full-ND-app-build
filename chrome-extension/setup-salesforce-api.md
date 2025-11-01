# Setup Salesforce REST API for Chrome Extension

## Step 1: Create a Connected App

1. **Go to Setup** → Quick Find: `App Manager`
2. Click **New Connected App** (top-right)
3. **Basic Information:**
   - Connected App Name: `Job Search Chrome Extension`
   - API Name: `Job_Search_Chrome_Extension`
   - Contact Email: Your email
4. **API (Enable OAuth Settings):**
   - Check ✅ **Enable OAuth Settings**
   - **Callback URL:** `https://login.salesforce.com/services/oauth2/callback`
   - **Selected OAuth Scopes:** Add these:
     - `Access and manage your data (api)`
     - `Perform requests on your behalf at any time (refresh_token, offline_access)`
     - `Access your basic information (id, profile, email, address, phone)`
   - Check ✅ **Require Secret for Web Server Flow**
   - Check ✅ **Require Secret for Refresh Token Flow**
5. Click **Save**
6. Click **Continue**

## Step 2: Get Your Credentials

After saving, you'll see:
- **Consumer Key** (also called Client ID)
- **Consumer Secret** (click to reveal)

**COPY THESE AND SAVE THEM!** We'll need them for the extension.

## Step 3: Create a REST API Endpoint in Salesforce

We need a custom REST endpoint to receive job data from the extension.

### Create Apex REST Class

1. **Developer Console** → File → New → Apex Class
2. Name: `JobPostingAPI`
3. Paste this code:

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
            job.Provider__c = request.provider;
            job.ExternalID__c = request.externalId;
            job.Status__c = 'Active';
            job.Posted_Date__c = Date.today();

            // Parse workplace type and remote policy from description/title
            job.Workplace_Type__c = determineWorkplaceType(request);
            job.Remote_Policy__c = determineRemotePolicy(request);

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

            // Insert the job (trigger will fire and analyze with Claude!)
            insert job;

            response.success = true;
            response.jobId = job.Id;
            response.message = 'Job posting created successfully! Claude is analyzing it now.';

        } catch (Exception e) {
            response.success = false;
            response.message = 'Error creating job posting: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'JobPostingAPI Error: ' + e.getMessage());
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
            return 'On-site';
        }

        return 'Remote'; // Default to remote for your search
    }

    private static String determineRemotePolicy(JobPostingRequest request) {
        String combined = (request.title + ' ' + request.location + ' ' + request.description).toLowerCase();

        if (combined.contains('fully remote') || combined.contains('100% remote')) {
            return 'Fully Remote';
        } else if (combined.contains('remote-first') || combined.contains('remote first')) {
            return 'Remote-First';
        } else if (combined.contains('hybrid')) {
            return 'Hybrid (2-3 days office)';
        }

        return 'Fully Remote'; // Default for your search
    }

    // Request wrapper
    global class JobPostingRequest {
        public String title;
        public String company;
        public String location;
        public String description;
        public String applyUrl;
        public String provider;
        public String externalId;
        public String salaryMin;
        public String salaryMax;
    }

    // Response wrapper
    global class JobPostingResponse {
        public Boolean success;
        public String jobId;
        public String message;
    }
}
```

4. **Save** the file

## Step 4: Test the API Endpoint

Run this in Developer Console to verify it works:

```apex
// Simulate what the Chrome extension will send
RestRequest req = new RestRequest();
RestResponse res = new RestResponse();

req.requestURI = '/services/apexrest/jobposting/';
req.httpMethod = 'POST';
req.addHeader('Content-Type', 'application/json');

JobPostingAPI.JobPostingRequest testRequest = new JobPostingAPI.JobPostingRequest();
testRequest.title = 'TEST - Senior Salesforce Developer';
testRequest.company = 'Test Company';
testRequest.location = 'Remote - USA';
testRequest.description = 'Great remote Salesforce job with flexible hours and Agentforce focus.';
testRequest.applyUrl = 'https://test.com/job/123';
testRequest.provider = 'Chrome Extension Test';
testRequest.externalId = 'test_' + System.now().getTime();
testRequest.salaryMin = '95000';
testRequest.salaryMax = '125000';

RestContext.request = req;
RestContext.response = res;

JobPostingAPI.JobPostingResponse response = JobPostingAPI.createJobPosting(testRequest);

System.debug('Success: ' + response.success);
System.debug('Job ID: ' + response.jobId);
System.debug('Message: ' + response.message);
```

If you see `Success: true` and a Job ID, the API is working!

## Step 5: Get Your Salesforce Details

You'll need these for the extension:
1. **Instance URL:** Look at your browser address bar
   - Example: `https://orgfarm-d7ac6d4026-dev-ed.develop.my.salesforce.com`
2. **API Endpoint:** Your instance URL + `/services/apexrest/jobposting`
   - Example: `https://orgfarm-d7ac6d4026-dev-ed.develop.my.salesforce.com/services/apexrest/jobposting`
3. **Username:** Your Salesforce username
4. **Password + Security Token:** Your password concatenated with security token
   - Get token: Setup → Quick Find: `Reset My Security Token`
   - If password is `MyPass123` and token is `ABC123XYZ`, use: `MyPass123ABC123XYZ`

Save these details - we'll need them for the Chrome extension!

---

**Next:** Create the Chrome extension files!

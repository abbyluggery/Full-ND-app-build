# Deploy JobPostingAPI via Workbench

Since both CLI and Developer Console are having issues, let's use Workbench - a web-based Salesforce deployment tool.

## Why Workbench?
- No local software needed
- Direct metadata API access
- Works when CLI fails
- Simple web interface

## Step 1: Prepare Deployment ZIP

I'll create a deployment zip for you. Look for: `jobposting-api-deploy.zip`

## Step 2: Deploy via Workbench

1. **Go to Workbench**
   - URL: https://workbench.developerforce.com/
   - Click "Login with Salesforce"

2. **Login to Your Org**
   - Use your Salesforce credentials (abbyluggery179@agentforce.com)
   - Accept the OAuth permissions

3. **Navigate to Deploy**
   - Click "Migration" in the top menu
   - Click "Deploy"

4. **Upload the ZIP**
   - Click "Choose File"
   - Select: `jobposting-api-deploy.zip` from your Desktop
   - Check "Rollback On Error"
   - Check "Single Package"
   - Click "Next"

5. **Deploy**
   - Review the components (should show 2 Apex classes)
   - Click "Deploy"
   - Wait for deployment to complete (usually 10-30 seconds)

6. **Verify Success**
   - You should see "Status: Succeeded"
   - Click "View Details" to see deployed components

## Step 3: Test the API

After successful deployment, run this in Developer Console Execute Anonymous:

```apex
RestRequest req = new RestRequest();
RestResponse res = new RestResponse();
req.requestURI = '/services/apexrest/jobposting/';
req.httpMethod = 'POST';
RestContext.request = req;
RestContext.response = res;

JobPostingAPI.JobPostingRequest testReq = new JobPostingAPI.JobPostingRequest();
testReq.title = 'Workbench Test Job';
testReq.company = 'Test Company';
testReq.location = 'Remote';
testReq.description = 'Testing the JobPostingAPI deployed via Workbench';
testReq.applyUrl = 'https://test.com/job/workbench-test';
testReq.provider = 'LinkedIn';
testReq.externalId = 'workbench_test_' + System.now().getTime();
testReq.salaryMin = '100000';
testReq.salaryMax = '130000';
testReq.currencyCode = 'USD';
testReq.salaryInterval = 'Yearly';

JobPostingAPI.JobPostingResponse response = JobPostingAPI.createJobPosting(testReq);

System.debug('Success: ' + response.success);
System.debug('Job ID: ' + response.jobId);
System.debug('Message: ' + response.message);
```

Expected output:
- `Success: true`
- `Job ID: a1Gxxxxxxxxxxxx`
- `Message: Job posting created successfully! Claude is analyzing it now.`

## Alternative: Manual Class Creation

If Workbench also fails, you can manually create the class:

1. **Open Developer Console** (Setup > Developer Console)
2. **File > New > Apex Class**
3. **Name**: JobPostingAPI
4. **Delete the template code**
5. **Copy all code from**: `force-app/main/default/classes/JobPostingAPI.cls`
6. **Paste** into the editor
7. **Save** (Ctrl+S)
8. **Repeat for test class**: JobPostingAPITest

## Next Steps

Once JobPostingAPI is deployed:
1. Create Connected App for OAuth
2. Configure Chrome Extension
3. Start capturing jobs from websites!

# Add Job Postings to App Launcher

The Job_Posting__c object exists but isn't visible in any app yet. Let's make it accessible!

## Option 1: Quick Test via URL (Fastest!)

You can access Job Postings directly without adding to an app:

1. **Copy this URL pattern:**
   ```
   https://[YOUR-ORG-URL]/lightning/o/Job_Posting__c/list
   ```

2. **Example:** If your org URL is `https://agentforce-dev-ed.develop.lightning.force.com/`, then use:
   ```
   https://agentforce-dev-ed.develop.lightning.force.com/lightning/o/Job_Posting__c/list
   ```

3. **Or just try this:** In your Salesforce org, add `/lightning/o/Job_Posting__c/list` to the end of your base URL

4. **Click "New"** to create a job posting!

## Option 2: Add to Sales App (Permanent)

1. **Setup → Quick Find** → Type `app manager`
2. Click **App Manager**
3. Find **Sales** app (or whichever app you use most)
4. Click the dropdown arrow → **Edit**
5. Click **Navigation Items** on the left
6. Under **Available Items**, find `Job Postings`
7. Click the **Add** arrow to move it to **Selected Items**
8. **Drag** it to where you want it in the list
9. Click **Save**

Now "Job Postings" will appear in your Sales app!

## Option 3: Create Custom App (Best for Long-term)

1. **Setup → Quick Find** → Type `app manager`
2. Click **App Manager**
3. Click **New Lightning App**
4. **App Details:**
   - **App Name:** `Job Search`
   - **Developer Name:** `Job_Search` (auto-fills)
   - **Description:** `AI-powered job search assistant`
   - Click **Next**
5. **App Options:**
   - Leave defaults
   - Click **Next**
6. **Utility Items:**
   - Leave defaults
   - Click **Next**
7. **Navigation Items:**
   - Click **Add** button
   - Select `Job Postings` from available items
   - Add `Home`, `Chatter`, `Reports`, `Dashboards` if you want
   - Click **Next**
8. **User Profiles:**
   - Select **System Administrator** (or your profile)
   - Click **Save & Finish**

Now you'll see "Job Search" in your App Launcher!

## After Adding to App

Once Job Postings is accessible:

1. **Click "Job Postings"** in the app
2. **Click "New"** button
3. **Fill in the form** (see [END_TO_END_TEST.md](END_TO_END_TEST.md) for field values)
4. **Click "Save"**
5. **Wait 30-60 seconds**
6. **Refresh the page**
7. **Check if Fit Score appears!** ✅

---

## Quick Workaround (Right Now!)

If you want to test immediately without setting up an app:

**Use Developer Console Execute Anonymous:**

Run the script from [END_TO_END_TEST.md](END_TO_END_TEST.md) **Method 2** - it creates a job record directly via code.

```apex
Job_Posting__c testJob = new Job_Posting__c(
    Title__c = 'Agentforce Developer - Remote',
    Company__c = 'InnovateCo',
    Location__c = 'Remote USA',
    Workplace_Type__c = 'Remote',
    Remote_Policy__c = 'Fully Remote',
    Salary_Min__c = 100000,
    Salary_Max__c = 140000,
    Description__c = 'Seeking Salesforce developer with Agentforce experience. ' +
                     'Build AI agents using Claude API, Prompt Builder, and Model Builder. ' +
                     'Fully remote role with flexible hours, no meetings before 10am. ' +
                     'ND-friendly culture with async-first communication. ' +
                     'Competitive salary and unlimited PTO.',
    Status__c = 'Active',
    Posted_Date__c = Date.today(),
    Apply_URL__c = 'https://innovateco.com/careers/12345',
    Provider__c = 'LinkedIn',
    ExternalID__c = 'LinkedIn:TEST001'
);

insert testJob;
System.debug('Job created: ' + testJob.Id);
System.debug('Automation should analyze it in 30-60 seconds!');
```

Then wait 30-60 seconds and check:

```apex
Job_Posting__c result = [
    SELECT Id, Title__c, Fit_Score__c, ND_Friendliness_Score__c,
           Green_Flags__c, Red_Flags__c, Application_Status__c
    FROM Job_Posting__c
    WHERE ExternalID__c = 'LinkedIn:TEST001'
];

System.debug('Fit Score: ' + result.Fit_Score__c);
System.debug('ND Friendliness: ' + result.ND_Friendliness_Score__c);
System.debug('Green Flags: ' + result.Green_Flags__c);
System.debug('Red Flags: ' + result.Red_Flags__c);
```

---

**I recommend Option 1 (Direct URL) or the Quick Workaround to test right now!**

# Create Job Posting Tab

The Job_Posting__c object exists but has no tab, so it's invisible in apps. Let's fix that!

## Step 1: Create a Tab for Job Postings

1. **Click gear icon** (⚙️) → **Setup**
2. In Quick Find box, type: **Tabs**
3. Click **Tabs** (under User Interface)
4. In the **Custom Object Tabs** section, click **New**
5. **Object:** Select `Job Posting` from dropdown
6. **Tab Style:**
   - Click the lookup icon (magnifying glass)
   - Choose an icon you like - suggestions:
     - **Briefcase** (good for jobs)
     - **Custom 54** (clipboard with checkmark)
     - **Work** (briefcase icon)
     - Or search for "job" or "work"
7. Click **Next**
8. **Apply one tab visibility to all profiles:**
   - Select **Default On**
   - This makes it visible to everyone
9. Click **Next**
10. **Include Tab:**
    - Check the boxes next to any apps where you want Job Postings to appear
    - Or leave all unchecked and add it manually later
11. Click **Save**

---

## Step 2: Now Add to Your App

Now that the tab exists, go back to the original instructions:

### Option A: Add to Sales App

1. **Setup** → Quick Find: **App Manager**
2. Find **Sales** app → dropdown → **Edit**
3. Click **Navigation Items**
4. Click **Add More Items**
5. **Now you should see "Job Postings"** in Available Items!
6. Click **Add** to move it to Selected Items
7. Drag it to the top of the list if you want
8. Click **Save**

### Option B: Create Custom Job Search App

1. **Setup** → Quick Find: **App Manager**
2. Click **New Lightning App**
3. Follow the steps from the main setup guide

---

## Step 3: Verify It's Working

1. Click the **App Launcher** (9 dots icon in top-left)
2. You should now see **Job Postings** listed
3. Click it to open the Job Postings tab
4. You'll see a list of your job postings!

---

## If You Still Don't See It

Run this in Developer Console to check if the tab was created:

```apex
List<Schema.DescribeTabSetResult> tabSets = Schema.describeTabs();
for (Schema.DescribeTabSetResult tabSet : tabSets) {
    for (Schema.DescribeTabResult tab : tabSet.getTabs()) {
        if (tab.getLabel().containsIgnoreCase('Job')) {
            System.debug('Found tab: ' + tab.getLabel());
        }
    }
}
```

If this returns nothing, the tab wasn't created. Try creating it again.

---

## Alternative: Access Without a Tab (Quick Fix)

If you just want to see your jobs right now while we fix the tab:

1. Click **gear icon** → **Developer Console**
2. Go to **Query Editor** tab
3. Run:
```sql
SELECT Id, Name, Title__c, Company__c, nd_friendliness_score__c, green_flags__c, red_flags__c
FROM Job_Posting__c
ORDER BY CreatedDate DESC
```
4. Double-click any row to open that record

Or use this URL directly (replace the domain):
```
https://YOUR-ORG.lightning.force.com/lightning/o/Job_Posting__c/list
```

Example: `https://orgfarm-d7ac6d4026-dev-ed.develop.my.salesforce.com/lightning/o/Job_Posting__c/list`

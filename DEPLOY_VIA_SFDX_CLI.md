# Alternative: Deploy Using Salesforce CLI Instead of Developer Console

Since Developer Console isn't working, let's use the Salesforce CLI (which you already have installed based on your earlier commands).

---

## ✅ You Already Have the Files!

All your Apex classes are already in your project:
- `force-app/main/default/classes/ResumeGenerator.cls`
- `force-app/main/default/classes/ResumeGeneratorInvocable.cls`
- `force-app/main/default/classes/DailyRoutineInvocable.cls`
- `force-app/main/default/classes/EnergyAdaptiveScheduler.cls`

We can deploy them directly using the CLI!

---

## 🚀 Quick Deploy Via CLI (5 minutes)

### Step 1: Deploy Resume Generator

Open Command Prompt or PowerShell and run:

```bash
cd "C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant"

# Deploy ResumeGenerator and its Invocable class
sf project deploy start --source-dir force-app/main/default/classes/ResumeGenerator.cls --target-org Assistant

sf project deploy start --source-dir force-app/main/default/classes/ResumeGeneratorInvocable.cls --target-org Assistant
```

### Step 2: Deploy Wellness Classes

```bash
# Deploy DailyRoutineInvocable
sf project deploy start --source-dir force-app/main/default/classes/DailyRoutineInvocable.cls --target-org Assistant

# Deploy EnergyAdaptiveScheduler
sf project deploy start --source-dir force-app/main/default/classes/EnergyAdaptiveScheduler.cls --target-org Assistant
```

---

## ⚡ Even Faster: Deploy All Classes at Once

```bash
cd "C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant"

# Deploy all undeployed classes in one command
sf project deploy start --source-dir force-app/main/default/classes --target-org Assistant
```

This will deploy:
- ResumeGenerator.cls
- ResumeGeneratorInvocable.cls
- DailyRoutineInvocable.cls
- EnergyAdaptiveScheduler.cls
- All their test classes

**Note**: If some classes are already deployed, CLI will just update them (safe operation).

---

## 🔍 What to Look For

### Success Output:
```
Status: Succeeded
✓ Deployed Source
  - ApexClass: ResumeGenerator
  - ApexClass: ResumeGeneratorInvocable
  ...
```

### Error Output (Missing Objects):
```
Error: Unknown SObject type 'Master_Resume_Config__c'
```

If you get this error, it means the object isn't deployed yet.

---

## 📦 If Objects Are Missing - Deploy Objects First

### Deploy All Objects at Once

```bash
cd "C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant"

# Deploy all custom objects
sf project deploy start --source-dir force-app/main/default/objects --target-org Assistant
```

This will deploy:
- Daily_Routine__c
- Master_Resume_Config__c
- Resume_Package__c
- Master_Resume__c
- Any Job_Posting__c fields that aren't deployed yet

### Or Deploy Specific Objects

```bash
# Deploy just Resume objects
sf project deploy start --source-dir force-app/main/default/objects/Master_Resume_Config__c --target-org Assistant
sf project deploy start --source-dir force-app/main/default/objects/Resume_Package__c --target-org Assistant
sf project deploy start --source-dir force-app/main/default/objects/Master_Resume__c --target-org Assistant

# Deploy Daily Routine object
sf project deploy start --source-dir force-app/main/default/objects/Daily_Routine__c --target-org Assistant
```

---

## 🎯 Recommended Deployment Order

### Option A: Deploy Everything (Fastest)

```bash
cd "C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant"

# Deploy objects first
sf project deploy start --source-dir force-app/main/default/objects --target-org Assistant

# Then deploy classes
sf project deploy start --source-dir force-app/main/default/classes --target-org Assistant
```

### Option B: Deploy Incrementally (Safer)

```bash
# 1. Deploy objects first
sf project deploy start --source-dir force-app/main/default/objects/Master_Resume_Config__c --target-org Assistant
sf project deploy start --source-dir force-app/main/default/objects/Resume_Package__c --target-org Assistant
sf project deploy start --source-dir force-app/main/default/objects/Master_Resume__c --target-org Assistant
sf project deploy start --source-dir force-app/main/default/objects/Daily_Routine__c --target-org Assistant

# 2. Deploy Resume Generator classes
sf project deploy start --source-dir force-app/main/default/classes/ResumeGenerator.cls --target-org Assistant
sf project deploy start --source-dir force-app/main/default/classes/ResumeGeneratorInvocable.cls --target-org Assistant

# 3. Deploy Wellness classes
sf project deploy start --source-dir force-app/main/default/classes/DailyRoutineInvocable.cls --target-org Assistant
sf project deploy start --source-dir force-app/main/default/classes/EnergyAdaptiveScheduler.cls --target-org Assistant
```

---

## ✅ After Deployment - Test It

### Test Resume Generator

Open Salesforce (not Developer Console), and in the browser URL bar, change the URL to:

```
https://your-org.salesforce.com/setup/ui/recordtypeselect.jsp?ent=01I...&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DStudio
```

Actually, easier way - just run this via CLI:

```bash
# Open Execute Anonymous via CLI
sf apex run --target-org Assistant --file test_resume_generator.apex
```

Create a file `test_resume_generator.apex`:
```apex
// Test Resume Generator
Id jobId = [SELECT Id FROM Job_Posting__c LIMIT 1].Id;
try {
    Resume_Package__c pkg = ResumeGenerator.generateResumePackage(jobId);
    System.debug('✅ SUCCESS! Resume Package created: ' + pkg.Id);
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}
```

### Test Wellness Classes

Create a file `test_wellness.apex`:
```apex
// Test Wellness System
Daily_Routine__c routine = new Daily_Routine__c();
routine.Date__c = Date.today();
routine.Energy_Level_Morning__c = 'Medium';
insert routine;

String schedule = EnergyAdaptiveScheduler.generateSchedule('Medium');
System.debug('✅ Schedule generated: ' + schedule);
```

Then run:
```bash
sf apex run --target-org Assistant --file test_wellness.apex
```

---

## 🔧 Alternative: Fix Developer Console

If you still want to fix Developer Console, try these:

### Fix 1: Clear Browser Cache Completely
1. Close all Salesforce tabs
2. In Chrome: Ctrl+Shift+Delete
3. Select "All time" and check:
   - Cached images and files
   - Cookies and other site data
4. Click "Clear data"
5. Close and reopen Chrome
6. Log in to Salesforce again
7. Try Developer Console again

### Fix 2: Try a Different Browser
1. Open Salesforce in **Edge** or **Firefox** instead of Chrome
2. Log in
3. Try Developer Console there

### Fix 3: Incognito/Private Mode
1. Open Chrome in Incognito mode (Ctrl+Shift+N)
2. Log in to Salesforce
3. Try Developer Console

### Fix 4: Different Salesforce UI
Sometimes Classic vs Lightning makes a difference:

1. In Salesforce, click your profile picture (top right)
2. Look for "Switch to Salesforce Classic" or "Switch to Lightning Experience"
3. Switch to the other UI
4. Try Developer Console again

---

## 💡 Why CLI is Actually Better

**Advantages of using CLI instead of Developer Console:**

1. ✅ **Faster** - Deploy multiple files at once
2. ✅ **More reliable** - No browser issues
3. ✅ **Version control friendly** - Deploy directly from your git repo
4. ✅ **Better error messages** - Clear output in terminal
5. ✅ **Can deploy objects** - Developer Console can't deploy custom objects
6. ✅ **Scriptable** - Can automate deployments

**Disadvantages:**
1. ❌ Can't interactively edit code (but you can use VS Code instead!)
2. ❌ Can't view logs as easily (but `sf apex tail log` works)

---

## 🎯 Recommended Next Step

**Just use the CLI!** It's faster and more reliable than Developer Console anyway.

**Run this now:**

```bash
cd "C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant"

# Deploy everything
sf project deploy start --source-dir force-app/main/default/objects --target-org Assistant
sf project deploy start --source-dir force-app/main/default/classes --target-org Assistant
```

This will deploy all your objects and classes in ~2 minutes!

---

## 📊 What Will Get Deployed

When you run the above commands, you'll deploy:

**Objects:**
- Daily_Routine__c (wellness tracking)
- Master_Resume_Config__c (stores your master resume)
- Resume_Package__c (stores generated resumes)
- Master_Resume__c (resume data)
- Any missing Job_Posting__c fields

**Classes:**
- ResumeGenerator.cls ✨
- ResumeGeneratorInvocable.cls ✨
- DailyRoutineInvocable.cls ✨
- EnergyAdaptiveScheduler.cls ✨
- All their test classes
- Plus updates to ClaudeAPIService, JobPostingAnalyzer, etc. (already deployed, will just refresh)

**Triggers:**
- JobPostingTrigger.trigger (already deployed, will refresh)

---

## ⚠️ Important: Check Results

After running the deploy commands, check the output:

**If you see "Status: Succeeded"** → Everything deployed! ✅

**If you see errors** → Copy the error message and we'll fix it together

---

Want to try the CLI deployment now? Just copy the commands and run them!

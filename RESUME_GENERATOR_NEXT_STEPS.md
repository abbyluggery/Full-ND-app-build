# Resume Generator - Next Steps

I've created the **ResumeGenerator.cls** Apex class that will generate tailored resumes using Claude AI!

## Status

✅ **Created:**
- [ResumeGenerator.cls](force-app/main/default/classes/ResumeGenerator.cls) - Main resume generation logic
- [ResumeGenerator.cls-meta.xml](force-app/main/default/classes/ResumeGenerator.cls-meta.xml) - Metadata file
- [Master_Resume_Config__c](force-app/main/default/objects/Master_Resume_Config__c/) - Custom object to store your master resume

## What Needs to Happen Next

### Step 1: Deploy Resume_Package__c Object
You mentioned **Agentforce Vibes created the Resume_Package__c object with XML files**. You need to deploy that object first!

**Where are the files?** Check if Agentforce Vibes created them in:
- `force-app/main/default/objects/Resume_Package__c/`

**To deploy:**
```bash
sf project deploy start --source-dir force-app/main/default/objects/Resume_Package__c --target-org abbyluggery179@agentforce.com
```

### Step 2: Deploy Master_Resume_Config__c Object
This object stores your master resume content that Claude will tailor for each job.

**To deploy:**
```bash
sf project deploy start --source-dir force-app/main/default/objects/Master_Resume_Config__c --target-org abbyluggery179@agentforce.com
```

### Step 3: Deploy ResumeGenerator Class
Once both objects exist, you can deploy the Apex class:

**To deploy:**
```bash
sf project deploy start --metadata ApexClass:ResumeGenerator --target-org abbyluggery179@agentforce.com
```

### Step 4: Create Your Master Resume Record
After deployment, you'll need to create one Master_Resume_Config__c record with your resume content:

1. Go to **Setup** → **Object Manager** → **Master Resume Config**
2. Click **New** to create a record
3. Fill in:
   - **Resume Content** - Your full master resume with all experience, skills, achievements
   - **Key Achievements** - Your best quantified accomplishments (STAR format)
   - **Technical Skills** - All Salesforce certs, tools, technologies you know
   - **Cover Letter Template** - Your preferred cover letter style (optional)
4. Click **Save**

### Step 5: Add "Generate Resume Package" Button
Create a button on Job_Posting__c that calls the resume generator:

**Option A: Quick Action (Easiest)**
1. Go to **Job Posting** object → **Buttons, Links, and Actions**
2. **New Action**
3. **Action Type:** Quick Action
4. **Target Object:** Resume Package
5. Link it to call `ResumeGenerator.generateResumePackage()`

**Option B: Flow (More Control)**
1. Create a Screen Flow
2. Add an Action element that calls:
   ```
   ResumeGenerator.generateResumePackage({!recordId})
   ```
3. Add the flow as a button on Job_Posting__c page layout

## How It Will Work

Once everything is deployed:

1. **Find a good job** - Browse jobs in your Job Search Assistant app
2. **Review Claude's analysis** - Check the ND-Friendliness Score, Green/Red Flags
3. **Click "Generate Resume Package"** - One click!
4. **Wait 30-60 seconds** - Claude generates tailored resume + cover letter
5. **Review and edit** - See the generated content, make any tweaks
6. **Download and apply!** - Copy to Word/PDF and submit your application

## What the ResumeGenerator Does

The class:
- Gets the job posting details (title, company, description, analysis)
- Gets your master resume from Master_Resume_Config__c
- Builds a specialized prompt for Claude that includes:
  - The job requirements
  - Your full experience
  - Instructions to tailor the resume for THIS specific role
  - ATS optimization keywords
  - ND-friendly professional strengths
- Calls Claude TWICE:
  1. Once to generate a tailored resume
  2. Once to generate a tailored cover letter
- Saves both to a new Resume_Package__c record
- Links it to the Job_Posting__c

## The Prompt Claude Receives

The ResumeGenerator sends Claude:

**System Context:**
- You are an expert resume writer specializing in Salesforce careers
- You understand ATS systems and keyword optimization
- You understand neurodivergent professionals and their unique strengths
- You write with quantified achievements and action verbs

**User Prompt:**
- Job Details: Title, Company, Description, ND Score, Green/Red Flags
- Your Master Resume: Full experience, skills, achievements
- Instructions: Tailor the resume to match THIS job, emphasize relevant experience, optimize for ATS
- Output Format: Plain text, ready to copy-paste into Word

## Troubleshooting

**Error: "Invalid type: Resume_Package__c"**
- The Resume_Package__c object hasn't been deployed yet
- Deploy it using Step 1 above

**Error: "Invalid type: Master_Resume_Config__c"**
- The Master_Resume_Config__c object hasn't been deployed yet
- Deploy it using Step 2 above

**Error: "Master resume not configured"**
- You haven't created a Master_Resume_Config__c record yet
- Create one using Step 4 above

## Files Created

1. **[ResumeGenerator.cls](force-app/main/default/classes/ResumeGenerator.cls)**
   - Main method: `generateResumePackage(Id jobPostingId)`
   - Returns: `Resume_Package__c` record (not yet inserted)
   - Calls Claude twice to generate resume and cover letter

2. **[Master_Resume_Config__c.object-meta.xml](force-app/main/default/objects/Master_Resume_Config__c/Master_Resume_Config__c.object-meta.xml)**
   - Custom object to store your master resume content
   - Fields: Resume_Content__c, Key_Achievements__c, Technical_Skills__c, Cover_Letter_Template__c

3. **Field Files:**
   - [Resume_Content__c.field-meta.xml](force-app/main/default/objects/Master_Resume_Config__c/fields/Resume_Content__c.field-meta.xml)
   - [Key_Achievements__c.field-meta.xml](force-app/main/default/objects/Master_Resume_Config__c/fields/Key_Achievements__c.field-meta.xml)
   - [Technical_Skills__c.field-meta.xml](force-app/main/default/objects/Master_Resume_Config__c/fields/Technical_Skills__c.field-meta.xml)
   - [Cover_Letter_Template__c.field-meta.xml](force-app/main/default/objects/Master_Resume_Config__c/fields/Cover_Letter_Template__c.field-meta.xml)

## Ready to Deploy?

The code is ready! You just need to:
1. Deploy Resume_Package__c (from Agentforce Vibes)
2. Deploy Master_Resume_Config__c (I created this)
3. Deploy ResumeGenerator class
4. Create your master resume record
5. Add a button to trigger it

Let me know when you're ready to deploy and I can help with any errors!

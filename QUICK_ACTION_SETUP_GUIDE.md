# Quick Action Setup Guide: "Research Company" Button
## For Opportunity Object

---

## ✅ **What's Already Deployed:**

1. **OpportunityResearchController.cls** - Apex invocable method ✓
2. **Opportunity_Research_Company** - Screen Flow ✓
3. **CompanyResearcher.cls** - AI research engine ✓

**Now you just need to add the button to your Opportunity page!**

---

## 📋 **Step-by-Step Instructions**

### **Step 1: Create the Quick Action**

1. **Navigate to Object Manager:**
   - Click the gear icon ⚙️ (top right)
   - Select **Setup**
   - In Quick Find box, type: `Object Manager`
   - Click **Opportunity**

2. **Create New Action:**
   - Scroll to **Buttons, Links, and Actions** section
   - Click **New Action**

3. **Configure Action Settings:**
   ```
   Action Type: Flow
   Flow: Opportunity: Research Company
   Label: Research Company
   Name: Research_Company (auto-fills)
   Description: Generate AI-powered company research and interview prep materials
   Icon: action:goal (or your preference)
   ```

4. **Click Save**

---

### **Step 2: Add Action to Page Layout**

#### **Option A: Lightning Page (Recommended)**

1. **Open Opportunity Lightning Page:**
   - Go to any Opportunity record
   - Click the gear icon ⚙️ (top right)
   - Select **Edit Page**

2. **Add Quick Action Component:**
   - In left sidebar, find **Actions** component under "Standard"
   - Drag **Actions** component to desired location on page
   - OR: If **Highlights Panel** already exists, actions will appear there

3. **Configure Component:**
   - Click on Actions component
   - In right sidebar (Component Properties):
     - Check **Show actions as buttons**
     - Order: Drag "Research Company" to top for prominence

4. **Save and Activate:**
   - Click **Save** (top right)
   - Click **Activation**
   - Select **Assign as Org Default** or specific profiles
   - Click **Save**

#### **Option B: Classic Page Layout (Alternative)**

1. **Navigate to Page Layouts:**
   - Setup → Object Manager → Opportunity → Page Layouts
   - Click on your active layout (probably "Opportunity Layout")

2. **Add Action to Layout:**
   - In the **Salesforce Mobile and Lightning Experience Actions** section at top
   - Click **override the predefined actions**
   - Drag **Research Company** from palette to the actions area
   - Arrange order as desired

3. **Save the Layout**

---

### **Step 3: Test the Button**

1. **Open an Opportunity:**
   - Navigate to an Opportunity that has a related Job_Posting__c
   - Ensure the Job_Posting__c has Company name filled in

2. **Click "Research Company" Button:**
   - Look for button in:
     - **Lightning:** Highlights panel or Actions section (depending on your page layout)
     - **Classic:** Action buttons area

3. **Expected Behavior:**
   - Flow launches and calls OpportunityResearchController
   - Controller calls CompanyResearcher with Opportunity ID
   - Claude AI generates research
   - Success screen appears: "✓ Company Research Generated Successfully!"
   - Company_Research__c record created

4. **View Research Results:**
   - Refresh the page
   - Scroll to **Related** tab
   - Look for **Company Research** section
   - Click into the Company_Research__c record to see:
     - Company Overview
     - Recent News
     - Culture Insights
     - Interview Talking Points
     - Why This Company
     - Potential Challenges

---

## 🎨 **Customization Options**

### **Change Button Icon:**
Available icons (use in Action settings):
- `action:goal` - Target icon (strategic)
- `action:web_link` - Link icon (research)
- `action:search` - Magnifying glass (discovery)
- `action:question_post_action` - Question mark (inquiry)
- `custom:custom78` - Brain icon (intelligence)

### **Reorder Buttons:**
In Lightning Page Editor → Actions component → Drag to reorder

### **Add to Multiple Page Layouts:**
Repeat Step 2 for different Opportunity layouts or Lightning pages

---

## 🔍 **Troubleshooting**

### **Problem: "No existing research found" error**
**Cause:** Opportunity doesn't have a related Job_Posting__c with company info

**Solution:**
1. Ensure Opportunity.Job_Posting__c lookup is populated
2. Ensure Job_Posting__c.Company__c field has a value
3. Try creating Job_Posting__c first, then link to Opportunity

### **Problem: Button doesn't appear**
**Possible Causes:**
1. **Page Layout:** Action not added to layout
   - Solution: Repeat Step 2
2. **Profile Permissions:** Flow not visible to your profile
   - Solution: Setup → Flows → "Opportunity: Research Company" → Manage Access
3. **Lightning Page:** Actions component not on page
   - Solution: Edit page → Add Actions component

### **Problem: "Invalid record ID" error**
**Cause:** Flow not receiving Opportunity ID correctly

**Solution:**
- The Flow should automatically receive `{!recordId}` from the Quick Action context
- Check Flow settings: Variables → recordId → Is Input = TRUE

### **Problem: Research takes too long**
**Expected:** 5-15 seconds for Claude AI to generate research

**If longer:**
- Check Debug Logs: Setup → Debug Logs → New → Select your user
- Look for errors in OpportunityResearchController or CompanyResearcher
- Verify Claude API key is set in Custom Metadata: API_Configuration__mdt

---

## 📊 **What Happens Behind the Scenes**

```
1. User clicks "Research Company" button
   ↓
2. Quick Action launches "Opportunity: Research Company" Flow
   ↓
3. Flow receives Opportunity ID from {!recordId}
   ↓
4. Flow calls OpportunityResearchController.researchCompany()
   ↓
5. Controller calls CompanyResearcher.generateResearch(oppId)
   ↓
6. CompanyResearcher checks for existing research (caches for 30 days)
   ↓
7. If no recent research, calls JobContext.fromRecord(oppId)
   ↓
8. JobContext queries Opportunity → Job_Posting__c → Company info
   ↓
9. CompanyResearcher calls ClaudeAPIService.generateText()
   ↓
10. Claude AI analyzes company and generates research JSON
   ↓
11. CompanyResearcher parses JSON and creates Company_Research__c
   ↓
12. Flow shows success screen with research ID
   ↓
13. User refreshes page to see research in Related section
```

---

## 🎯 **Expected Results**

After clicking the button, you should see a Company_Research__c record with:

### **Auto-Generated Fields:**
- **Company Name:** From Job_Posting__c.Company__c
- **Research Date:** Current timestamp
- **Research Status:** "Ready"

### **AI-Generated Content:**
- **Company Overview:** 2-3 sentence company summary
- **Recent News:** Latest developments or industry context
- **Culture Insights:** Work environment observations
- **Key Products/Services:** Main offerings
- **Interview Talking Points:** 3-5 smart questions to ask interviewer
- **Why This Company:** Compelling reasons for excitement about the role
- **Potential Challenges:** 2-3 challenges to prepare for

---

## 🚀 **Next Steps After Setup**

1. **Test with Real Data:**
   - Pick an Opportunity with complete Job_Posting__c
   - Click "Research Company"
   - Review generated research quality
   - Refine system prompts if needed (in CompanyResearcher.cls)

2. **Add to Related Lists:**
   - Setup → Object Manager → Opportunity → Page Layouts
   - Add "Company Research" related list to layout
   - Reorder to show near top of Related tab

3. **Create Display Component:**
   - Build LWC component to show research on Opportunity page
   - Display talking points in expandable sections
   - Add "Refresh Research" button if data is stale

4. **Integrate with Resume Generation:**
   - Modify Resume Package generation to include company research
   - Auto-populate cover letter with "Why This Company" content
   - Reference talking points in interview prep materials

---

## 🎓 **Learning Resources**

- [Salesforce Quick Actions](https://help.salesforce.com/s/articleView?id=sf.actions_overview.htm)
- [Flow Invocable Methods](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_InvocableMethod.htm)
- [Lightning Page Customization](https://help.salesforce.com/s/articleView?id=sf.lightning_app_builder_customize_lex_pages.htm)

---

## ✨ **Congratulations!**

Once you complete these steps, you'll have a **one-click AI-powered company research button** on every Opportunity! This demonstrates:

- Advanced Salesforce configuration skills
- AI integration expertise
- User experience design
- Workflow automation mastery

**This is exactly the kind of feature that impresses hiring managers!** 🎯

---

**Created:** November 13, 2025
**Last Updated:** November 13, 2025
**Status:** Ready for Implementation
**Difficulty:** Easy (5-10 minutes)

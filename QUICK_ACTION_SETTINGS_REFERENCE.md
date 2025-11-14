# Quick Action Configuration - Copy/Paste Reference
## Exact Settings for "Research Company" Button

---

## 🎯 **Quick Copy/Paste Values**

Use these exact values when creating your Quick Action:

---

### **Action Settings (Step 1)**

| Field | Value |
|-------|-------|
| **Action Type** | `Flow` |
| **Flow** | `Opportunity: Research Company` |
| **Label** | `Research Company` |
| **Name** | `Research_Company` |
| **Description** | `Generate AI-powered company research and interview prep materials` |
| **Icon** | `action:goal` |
| **Standard Label Type** | `--None--` |
| **Height (pixels)** | Leave default |
| **Width (pixels)** | Leave default |
| **Show as** | `Action Button` |

---

## 📸 **Visual Reference - What You Should See**

### **After Creating Action:**

```
✓ Quick Action Created Successfully

API Name: Research_Company
Label: Research Company
Type: Flow (Opportunity: Research Company)
Icon: [Target icon]
```

### **In Page Layout Editor:**

```
┌─────────────────────────────────────┐
│ Salesforce Mobile and Lightning    │
│ Experience Actions                  │
├─────────────────────────────────────┤
│ [Research Company] [Edit] [Delete] │ ← Your new button
│ [New Task]                          │
│ [New Event]                         │
│ [Log a Call]                        │
└─────────────────────────────────────┘
```

### **On Opportunity Page (Lightning):**

```
╔══════════════════════════════════════╗
║ Opportunity: Senior Salesforce Dev  ║
╠══════════════════════════════════════╣
║ Actions: [Research Company] ▼        ║ ← Button appears here
║          [New Task]                  ║
║          [New Event]                 ║
╚══════════════════════════════════════╝
```

---

## ⚡ **Fastest Setup Path**

### **3-Minute Quick Setup:**

1. **Setup → Object Manager → Opportunity → Buttons, Links, and Actions → New Action**
   - Type: Flow
   - Flow: Opportunity: Research Company
   - Label: Research Company
   - Save

2. **Go to any Opportunity → Gear icon → Edit Page**
   - Lightning App Builder opens
   - If no Actions component, drag from left sidebar
   - Save → Activate → Assign as Org Default

3. **Done!** Refresh Opportunity page, click "Research Company"

---

## 🔧 **Advanced Settings (Optional)**

### **Custom Button Colors:**

Not directly configurable in Quick Actions, but you can:
- Use different icons to visually distinguish
- Create custom LWC button for more control

### **Conditional Visibility:**

Make button only appear when criteria met:

1. **Create Formula Field on Opportunity:**
   ```apex
   Name: Show_Research_Button__c
   Type: Checkbox
   Formula: NOT(ISBLANK(Job_Posting__c))
   ```

2. **Use Dynamic Actions (Lightning only):**
   - Page Layout → Actions → Show Research Company
   - Filter Logic: `Show_Research_Button__c = TRUE`

---

## 📱 **Mobile Configuration**

The Quick Action automatically works in Salesforce Mobile App!

**Mobile Appearance:**
```
┌─────────────────────────┐
│  Opportunity Details    │
├─────────────────────────┤
│  Actions ▼              │
│  • Research Company     │ ← Tap to launch
│  • New Task             │
│  • New Event            │
└─────────────────────────┘
```

---

## 🎨 **Icon Options**

Popular icon choices for research button:

| Icon API Name | Visual | Best For |
|---------------|--------|----------|
| `action:goal` | 🎯 | Strategic research |
| `action:web_link` | 🔗 | External research |
| `action:search` | 🔍 | Discovery/investigation |
| `custom:custom78` | 🧠 | AI/intelligence |
| `action:question_post_action` | ❓ | Questions/inquiry |
| `action:new_note` | 📝 | Documentation |

**To change icon after creation:**
Setup → Object Manager → Opportunity → Buttons, Links, and Actions → Research Company → Edit

---

## 🧪 **Test Checklist**

Before marking complete, verify:

- [ ] Button appears on Opportunity page
- [ ] Clicking button launches Flow
- [ ] Flow shows loading indicator
- [ ] Success screen appears after 5-15 seconds
- [ ] Company_Research__c record created
- [ ] Research fields populated with AI content
- [ ] Research visible in Related lists
- [ ] Button works on different Opportunities
- [ ] Button works in Salesforce Mobile App (if applicable)

---

## 📊 **Expected Performance**

| Metric | Target | Notes |
|--------|--------|-------|
| **Button Click Response** | < 1 second | Flow should launch immediately |
| **AI Research Generation** | 5-15 seconds | Claude API processing time |
| **Total User Wait Time** | < 20 seconds | From click to success screen |
| **Success Rate** | > 95% | With valid Job_Posting__c data |

---

## 🚨 **Common Setup Mistakes to Avoid**

❌ **WRONG:** Selecting "Update a Record" as Action Type
✅ **CORRECT:** Select "Flow" as Action Type

❌ **WRONG:** Creating custom Flow from scratch
✅ **CORRECT:** Use deployed "Opportunity: Research Company" Flow

❌ **WRONG:** Setting Name field manually with spaces
✅ **CORRECT:** Let Name auto-fill from Label (Research_Company)

❌ **WRONG:** Forgetting to activate Lightning page changes
✅ **CORRECT:** Click Activation → Assign as Org Default

❌ **WRONG:** Testing on Opportunity without Job_Posting__c
✅ **CORRECT:** Test with Opportunity that has related Job_Posting__c with Company

---

## 🎯 **Success Criteria**

You'll know setup is complete when:

1. ✓ Button visible on Opportunity page
2. ✓ Clicking button shows Flow interface
3. ✓ Success message appears after processing
4. ✓ Company_Research__c record created with AI content
5. ✓ Research fields populated (Company Overview, Talking Points, etc.)
6. ✓ No errors in Debug Logs

---

## 📞 **Need Help?**

If you encounter issues:

1. **Check Debug Logs:**
   - Setup → Debug Logs → New
   - Select your user, Save
   - Click "Research Company" again
   - View log for error messages

2. **Verify Flow is Active:**
   - Setup → Flows → "Opportunity: Research Company"
   - Status should be "Active"

3. **Check Apex Class Access:**
   - Setup → Profiles → Your Profile
   - Apex Class Access → OpportunityResearchController should be enabled

4. **Review Claude API Configuration:**
   - Setup → Custom Metadata Types → API Configuration
   - Verify API key is set for Claude

---

**Ready to set up? Follow the steps in [QUICK_ACTION_SETUP_GUIDE.md](QUICK_ACTION_SETUP_GUIDE.md)!**

---

**Created:** November 13, 2025
**Purpose:** Quick reference for exact settings
**Time to Complete:** 3-5 minutes

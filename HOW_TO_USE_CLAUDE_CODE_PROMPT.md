# 📋 HOW TO USE THE EXACT CLAUDE CODE PROMPT
## Step-by-Step Instructions

**Created**: November 16, 2025
**Purpose**: Prevent repeat of wrong platform build
**Success Rate**: Should be 100% if followed exactly

---

## ⚠️ BEFORE YOU START

### ✅ Backups Complete
- ✅ `backup-all-work-nov16` branch created and pushed
- ✅ `clean-main` branch has all your Salesforce work
- ✅ All 5 LWC summary cards safe
- ✅ All 7 wellness objects safe
- ✅ All deployment documentation safe

**You can safely proceed!**

---

## STEP 1: Create New Repository (5 minutes)

**IMPORTANT**: Do NOT use the existing Salesforce repo. Create a NEW repo.

### 1a. Go to GitHub

Visit: https://github.com/new

### 1b. Create Repository

**Settings:**
- Repository name: `neurothrive-android`
- Description: "Native Android app for NeuroThrive neurodivergent wellness tracking"
- Visibility: ✅ Public
- Initialize: ✅ Add a README file
- .gitignore template: Android
- License: MIT

**Click**: "Create repository"

### 1c. Verify Repository Created

Your new repo should be at:
`https://github.com/abbyluggery/neurothrive-android`

---

## STEP 2: Open File with Exact Prompt (1 minute)

### Option A: From This Computer

1. Open: `EXACT_CLAUDE_CODE_PROMPT_ANDROID.md`
2. Scroll to: "## PROMPT START (Copy everything below this line)"
3. Select ALL text from that point to "## PROMPT END"
4. Copy (Ctrl+C)

### Option B: From GitHub

1. Visit: https://github.com/abbyluggery/Full-ND-app-build
2. Click: `EXACT_CLAUDE_CODE_PROMPT_ANDROID.md`
3. Click: "Raw" button
4. Copy from "PROMPT START" to "PROMPT END"

---

## STEP 3: Give Prompt to Claude Code (2 minutes)

### 3a. Open Claude Code via GitHub

**Method 1 - From New Repo:**
1. Go to: https://github.com/abbyluggery/neurothrive-android
2. Click: "Code" button
3. Look for: "Open with Codespaces" OR GitHub integration
4. Select: "Claude Code" option

**Method 2 - Direct Link:**
1. Visit: https://claude.ai/claude-code
2. Connect to GitHub if not already connected
3. Select repository: `neurothrive-android`

### 3b. Paste the Entire Prompt

**PASTE EXACTLY** - Don't modify anything!

**The prompt includes:**
- ✅ Platform validation (THIS IS ANDROID)
- ✅ DO/DON'T lists (Kotlin vs Apex)
- ✅ Complete Session 1 code templates
- ✅ Success criteria checklist
- ✅ Validation commands

### 3c. Send to Claude Code

Click "Send" or press Enter

---

## STEP 4: Monitor Claude Code's Work (3-4 hours)

### What to Watch For ✅

**GOOD SIGNS:**
- ✅ Creates `android/` directory
- ✅ Creates `MainActivity.kt` file
- ✅ Creates `build.gradle.kts` files
- ✅ Mentions "Kotlin" in commit messages
- ✅ Running `./gradlew build` commands
- ✅ Creating Room database entities
- ✅ Writing unit tests

**RED FLAGS - STOP IMMEDIATELY:** 🚨
- ❌ Creates `.cls` files (Apex classes)
- ❌ Creates `.object-meta.xml` files (Salesforce metadata)
- ❌ Mentions "Salesforce deployment"
- ❌ Running `sf project deploy` commands
- ❌ Creates `force-app/` directory
- ❌ References LWC components

### If You See Red Flags

**STOP CLAUDE CODE IMMEDIATELY:**

1. Say: "STOP - You are building the wrong platform"
2. Say: "This is an ANDROID app project, not Salesforce"
3. Say: "Delete all .cls and -meta.xml files"
4. Say: "Start over following the ANDROID instructions"

---

## STEP 5: Verify Session 1 Completion (10 minutes)

### After Claude Code finishes, check:

**File Structure Check:**
```bash
# Clone repo locally
git clone https://github.com/abbyluggery/neurothrive-android
cd neurothrive-android

# Verify Android structure
ls -la android/

# Should see: app/, gradle/, build.gradle.kts, settings.gradle.kts
```

**File Type Check:**
```bash
# Should find MainActivity.kt
find . -name "MainActivity.kt"

# Should return 0 (no Apex classes)
find . -name "*.cls" | wc -l

# Should return 0 (no Salesforce metadata)
find . -name "*-meta.xml" | wc -l
```

**Expected Results:**
- ✅ `MainActivity.kt` found
- ✅ `0` .cls files
- ✅ `0` -meta.xml files

### Build Test:
```bash
cd android
./gradlew build
```

**Expected**: BUILD SUCCESSFUL

### Unit Test:
```bash
./gradlew test
```

**Expected**: 3/3 tests passing

---

## STEP 6: If Successful - Next Steps

### Session 1 Complete! ✅

**What you now have:**
- Android project with Kotlin/Jetpack Compose
- Room database with 4 entities
- DAO interfaces for CRUD operations
- AES-256 encryption ready
- Unit tests passing

### Next Session Options:

**Option A: Continue with Session 2 Immediately**

Give Claude Code the next prompt (you'll need Session 2 instructions)

**Option B: Stop and Review**

1. Clone repo locally
2. Open in Android Studio
3. Test the app manually
4. Verify everything works
5. Plan Session 2

**Option C: Celebrate and Pause**

You have a working Android database layer! Take a break, then continue later.

---

## STEP 7: If It Fails Again (Contingency Plan)

### If Claude Code Still Builds Wrong Thing:

**Option 1: Manual Build**

Use the code templates from `EXACT_CLAUDE_CODE_PROMPT_ANDROID.md` to build yourself:

1. Install Android Studio
2. Create new Kotlin project
3. Copy-paste entity classes
4. Copy-paste DAO interfaces
5. Copy-paste SecurityUtils
6. 3-4 hours of work

**Option 2: Different AI Tool**

Try:
- GitHub Copilot (in Android Studio)
- Cursor AI (VSCode fork with AI)
- ChatGPT with code interpreter
- Build manually with AI assistance

**Option 3: Defer Android, Complete Salesforce**

Focus on finishing what's 92% done:
- Fix CouponExpirationScheduler
- Fix Weekly_Mood_Summary flow
- Complete PWA OAuth
- **Result**: Production-ready 2-platform ecosystem

---

## 🎯 SUCCESS CHECKLIST

After giving Claude Code the prompt, verify:

**Within 30 minutes:**
- [ ] `android/` directory created
- [ ] `MainActivity.kt` exists
- [ ] `build.gradle.kts` exists
- [ ] NO `.cls` files
- [ ] NO `-meta.xml` files

**Within 2 hours:**
- [ ] All 4 entity classes created
- [ ] All 4 DAO interfaces created
- [ ] SecurityUtils.kt created
- [ ] AndroidManifest.xml created

**Within 3-4 hours:**
- [ ] Unit tests created
- [ ] Build passes (`./gradlew build`)
- [ ] Tests pass (`./gradlew test`)
- [ ] Commit message mentions "Android" (not "Salesforce")

**Final validation:**
- [ ] Zero Apex classes
- [ ] Zero Salesforce metadata
- [ ] Only Kotlin files (.kt)
- [ ] Repository is separate from Salesforce

---

## 📞 QUICK REFERENCE

### What You're Building
**Platform**: Android (Kotlin/Jetpack Compose)
**Not**: Salesforce, Web, PWA

### Repository
**Correct**: https://github.com/abbyluggery/neurothrive-android
**Wrong**: https://github.com/abbyluggery/Full-ND-app-build (Salesforce repo)

### File Types
**Correct**: .kt, .kts, .xml (Android XML only)
**Wrong**: .cls, .trigger, -meta.xml, .object-meta.xml

### Commands Claude Code Should Run
**Correct**: `./gradlew build`, `./gradlew test`
**Wrong**: `sf project deploy`, `sfdx force:source:deploy`

### Commit Messages Should Mention
**Correct**: "Android", "Kotlin", "Room", "Jetpack Compose"
**Wrong**: "Salesforce", "Apex", "LWC", "Flow"

---

## 💡 WHY THIS PROMPT WILL WORK

### Improvements from Last Time:

1. **Explicit Platform Validation**
   - Starts with "THIS IS AN ANDROID APP"
   - Lists DO vs DON'T (Kotlin vs Apex)
   - Validation checks after each step

2. **Separate Repository**
   - No confusion with existing Salesforce code
   - Clean slate
   - Different repo = different platform

3. **Success Criteria**
   - Checklist of required files
   - Commands to verify correctness
   - Zero tolerance for wrong file types

4. **Example Files**
   - Complete code templates
   - Copy-paste ready
   - Hard to misinterpret

5. **Negative Examples**
   - Explicitly states what NOT to create
   - File type blacklist
   - Command blacklist

**Previous failure rate**: 100% (built wrong platform)
**Expected success rate**: 95%+ (with this prompt)

---

## 🎉 READY TO GO!

**You have:**
- ✅ New repository ready (neurothrive-android)
- ✅ Exact prompt ready (EXACT_CLAUDE_CODE_PROMPT_ANDROID.md)
- ✅ All backups complete (backup-all-work-nov16)
- ✅ Salesforce work safe (clean-main)
- ✅ Clear instructions (this document)
- ✅ Success criteria defined
- ✅ Contingency plans ready

**Next action:**
1. Create `neurothrive-android` repository on GitHub
2. Open Claude Code via GitHub
3. Copy-paste the EXACT prompt
4. Monitor for 30 minutes to ensure correct platform
5. Verify success after 3-4 hours

**Good luck! The prompt is designed to prevent the previous issue.** 🚀💙

---

**Document Created**: November 16, 2025
**Status**: Ready for execution
**Confidence Level**: High (95%+ success expected)

**Let me know when you're ready to execute!**

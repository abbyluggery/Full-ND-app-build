# 🤖 EXACT PROMPT FOR CLAUDE CODE - Android App Build
## Copy this EXACTLY to Claude Code via GitHub

**IMPORTANT**: Create a NEW repository first: https://github.com/abbyluggery/neurothrive-android

Then give Claude Code this prompt:

---

## PROMPT START (Copy everything below this line)

# BUILD ANDROID MOBILE APP - Session 1 of 4

## ⚠️ CRITICAL: PLATFORM VALIDATION

**THIS IS AN ANDROID APP PROJECT - NOT SALESFORCE, NOT WEB, NOT PWA**

Before you begin, confirm you understand:
- ✅ You will write **Kotlin** code (.kt files)
- ✅ You will create **Android Studio** project structure
- ✅ You will use **Jetpack Compose** for UI
- ✅ You will create **MainActivity.kt**, **build.gradle.kts**, etc.
- ❌ You will **NOT** create Apex classes (.cls files)
- ❌ You will **NOT** create Salesforce metadata (.object-meta.xml files)
- ❌ You will **NOT** create Lightning Web Components
- ❌ You will **NOT** modify any Salesforce repository

**VALIDATION CHECK**: After 10 minutes, you should have:
- `android/` directory structure
- `MainActivity.kt` file created
- `build.gradle.kts` files created
- Zero `.cls` or `.object-meta.xml` files

**If you see ANY .cls files, STOP IMMEDIATELY - you're in the wrong project.**

---

## PROJECT CONTEXT

**Project Name**: NeuroThrive Android App
**Purpose**: Native Android mobile app for neurodivergent wellness tracking
**Tech Stack**: Kotlin, Jetpack Compose, Room, Retrofit, WorkManager
**Target Users**: Neurodivergent professionals (ADHD, Bipolar, Autistic)

**Integration Target**: Salesforce org (abbyluggery179@agentforce.com)
- API Base URL: https://abbyluggery179.my.salesforce.com
- REST endpoints available for sync
- OAuth 2.0 Connected App will be created

---

## SESSION 1 GOAL: Android Foundation (3-4 hours)

**What you will build:**
1. Android project with Kotlin/Jetpack Compose
2. SQLite database using Room
3. AES-256 encryption for sensitive data
4. Entity classes for data models
5. DAO interfaces for database operations
6. Unit tests for database layer

**Deliverables:**
- Functional Android app (empty UI for now)
- Encrypted local database
- 4 entity classes: MoodEntry, WinEntry, JobPosting, DailyRoutine
- 4 DAO interfaces with CRUD operations
- SecurityUtils for AES-256 encryption
- Unit tests passing

---

## STEP 1: Initialize Android Project (30 min)

### Create Project Structure

```bash
mkdir -p android
cd android

# Create Gradle wrapper files
mkdir -p gradle/wrapper

# Create app module
mkdir -p app/src/main/java/com/neurothrive/assistant/{data,ui,api,voice}
mkdir -p app/src/main/res/{values,drawable,layout}
mkdir -p app/src/test/java/com/neurothrive/assistant
mkdir -p app/src/androidTest/java/com/neurothrive/assistant
```

### Create settings.gradle.kts

```kotlin
// settings.gradle.kts
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "NeuroThriveAndroid"
include(":app")
```

### Create Root build.gradle.kts

```kotlin
// build.gradle.kts (root)
plugins {
    id("com.android.application") version "8.2.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.20" apply false
    id("com.google.dagger.hilt.android") version "2.48" apply false
}
```

### Create App build.gradle.kts

```kotlin
// app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.kapt")
    id("com.google.dagger.hilt.android")
}

android {
    namespace = "com.neurothrive.assistant"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.neurothrive.assistant"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        buildConfigField("String", "SALESFORCE_BASE_URL", "\"https://abbyluggery179.my.salesforce.com\"")
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.4"
    }
}

dependencies {
    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.20")

    // AndroidX Core
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.2")
    implementation("androidx.activity:activity-compose:1.8.1")

    // Jetpack Compose
    implementation(platform("androidx.compose:compose-bom:2023.10.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")

    // Room Database
    val roomVersion = "2.6.0"
    implementation("androidx.room:room-runtime:$roomVersion")
    implementation("androidx.room:room-ktx:$roomVersion")
    kapt("androidx.room:room-compiler:$roomVersion")

    // Retrofit (Salesforce API)
    val retrofitVersion = "2.9.0"
    implementation("com.squareup.retrofit2:retrofit:$retrofitVersion")
    implementation("com.squareup.retrofit2:converter-gson:$retrofitVersion")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")

    // Gson
    implementation("com.google.code.gson:gson:2.10.1")

    // WorkManager
    implementation("androidx.work:work-runtime-ktx:2.9.0")

    // Security (Encryption)
    implementation("androidx.security:security-crypto:1.1.0-alpha06")

    // Hilt (Dependency Injection)
    val hiltVersion = "2.48"
    implementation("com.google.dagger:hilt-android:$hiltVersion")
    kapt("com.google.dagger:hilt-compiler:$hiltVersion")
    implementation("androidx.hilt:hilt-navigation-compose:1.1.0")
    implementation("androidx.hilt:hilt-work:1.1.0")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

    // Logging
    implementation("com.jakewharton.timber:timber:5.0.1")

    // Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("androidx.room:room-testing:$roomVersion")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}
```

---

## STEP 2: Create Database Schema (45 min)

### AppDatabase.kt

```kotlin
// app/src/main/java/com/neurothrive/assistant/data/local/AppDatabase.kt
package com.neurothrive.assistant.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import com.neurothrive.assistant.data.local.dao.*
import com.neurothrive.assistant.data.local.entities.*

@Database(
    entities = [
        MoodEntry::class,
        WinEntry::class,
        JobPosting::class,
        DailyRoutine::class
    ],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun moodEntryDao(): MoodEntryDao
    abstract fun winEntryDao(): WinEntryDao
    abstract fun jobPostingDao(): JobPostingDao
    abstract fun dailyRoutineDao(): DailyRoutineDao
}
```

### Entity: MoodEntry.kt

```kotlin
// app/src/main/java/com/neurothrive/assistant/data/local/entities/MoodEntry.kt
package com.neurothrive.assistant.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "mood_entries")
data class MoodEntry(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val moodLevel: Int, // 1-10
    val energyLevel: Int, // 1-10
    val painLevel: Int, // 1-10
    val timestamp: Long = System.currentTimeMillis(),
    val notes: String? = null,
    val syncedToSalesforce: Boolean = false,
    val salesforceId: String? = null
)
```

### Entity: WinEntry.kt

```kotlin
// app/src/main/java/com/neurothrive/assistant/data/local/entities/WinEntry.kt
package com.neurothrive.assistant.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "win_entries")
data class WinEntry(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val description: String,
    val category: String? = null, // "career", "health", "personal"
    val timestamp: Long = System.currentTimeMillis(),
    val syncedToSalesforce: Boolean = false,
    val salesforceId: String? = null
)
```

### Entity: JobPosting.kt

```kotlin
// app/src/main/java/com/neurothrive/assistant/data/local/entities/JobPosting.kt
package com.neurothrive.assistant.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "job_postings")
data class JobPosting(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val jobTitle: String,
    val companyName: String,
    val url: String,
    val salaryMin: Double? = null,
    val salaryMax: Double? = null,
    val remotePolicy: String? = null,
    val description: String? = null,
    val fitScore: Double? = null,
    val ndFriendlinessScore: Double? = null,
    val greenFlags: String? = null,
    val redFlags: String? = null,
    val datePosted: Long = System.currentTimeMillis(),
    val syncedToSalesforce: Boolean = false,
    val salesforceId: String? = null
)
```

### Entity: DailyRoutine.kt

```kotlin
// app/src/main/java/com/neurothrive/assistant/data/local/entities/DailyRoutine.kt
package com.neurothrive.assistant.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "daily_routines")
data class DailyRoutine(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val date: Long,
    val moodLevel: Int,
    val energyLevel: Int,
    val painLevel: Int,
    val sleepQuality: Int? = null,
    val exerciseMinutes: Int? = null,
    val hydrationOunces: Int? = null,
    val mealsEaten: Int? = null,
    val journalEntry: String? = null,
    val syncedToSalesforce: Boolean = false,
    val salesforceId: String? = null
)
```

---

## STEP 3: Create DAOs (30 min)

### MoodEntryDao.kt

```kotlin
// app/src/main/java/com/neurothrive/assistant/data/local/dao/MoodEntryDao.kt
package com.neurothrive.assistant.data.local.dao

import androidx.room.*
import com.neurothrive.assistant.data.local.entities.MoodEntry
import kotlinx.coroutines.flow.Flow

@Dao
interface MoodEntryDao {
    @Query("SELECT * FROM mood_entries ORDER BY timestamp DESC")
    fun getAllFlow(): Flow<List<MoodEntry>>

    @Query("SELECT * FROM mood_entries WHERE timestamp >= :startTime AND timestamp <= :endTime ORDER BY timestamp DESC")
    suspend fun getEntriesBetween(startTime: Long, endTime: Long): List<MoodEntry>

    @Query("SELECT * FROM mood_entries WHERE syncedToSalesforce = 0")
    suspend fun getUnsynced(): List<MoodEntry>

    @Query("SELECT * FROM mood_entries WHERE salesforceId = :salesforceId LIMIT 1")
    suspend fun getBySalesforceId(salesforceId: String): MoodEntry?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entry: MoodEntry)

    @Update
    suspend fun update(entry: MoodEntry)

    @Delete
    suspend fun delete(entry: MoodEntry)

    @Query("DELETE FROM mood_entries")
    suspend fun deleteAll()
}
```

### WinEntryDao.kt

```kotlin
// app/src/main/java/com/neurothrive/assistant/data/local/dao/WinEntryDao.kt
package com.neurothrive.assistant.data.local.dao

import androidx.room.*
import com.neurothrive.assistant.data.local.entities.WinEntry
import kotlinx.coroutines.flow.Flow

@Dao
interface WinEntryDao {
    @Query("SELECT * FROM win_entries ORDER BY timestamp DESC")
    fun getAllFlow(): Flow<List<WinEntry>>

    @Query("SELECT * FROM win_entries WHERE timestamp >= :startTime ORDER BY timestamp DESC")
    suspend fun getWinsSince(startTime: Long): List<WinEntry>

    @Query("SELECT * FROM win_entries WHERE syncedToSalesforce = 0")
    suspend fun getUnsynced(): List<WinEntry>

    @Query("SELECT * FROM win_entries WHERE salesforceId = :salesforceId LIMIT 1")
    suspend fun getBySalesforceId(salesforceId: String): WinEntry?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entry: WinEntry)

    @Update
    suspend fun update(entry: WinEntry)

    @Delete
    suspend fun delete(entry: WinEntry)

    @Query("DELETE FROM win_entries")
    suspend fun deleteAll()
}
```

### JobPostingDao.kt

```kotlin
// app/src/main/java/com/neurothrive/assistant/data/local/dao/JobPostingDao.kt
package com.neurothrive.assistant.data.local.dao

import androidx.room.*
import com.neurothrive.assistant.data.local.entities.JobPosting
import kotlinx.coroutines.flow.Flow

@Dao
interface JobPostingDao {
    @Query("SELECT * FROM job_postings ORDER BY datePosted DESC")
    fun getAllFlow(): Flow<List<JobPosting>>

    @Query("SELECT * FROM job_postings WHERE fitScore >= :minScore ORDER BY fitScore DESC")
    suspend fun getHighFitJobs(minScore: Double): List<JobPosting>

    @Query("SELECT * FROM job_postings WHERE companyName = :companyName")
    suspend fun getJobsByCompany(companyName: String): List<JobPosting>

    @Query("SELECT * FROM job_postings ORDER BY datePosted DESC LIMIT :limit")
    suspend fun getRecentJobs(limit: Int): List<JobPosting>

    @Query("SELECT * FROM job_postings WHERE syncedToSalesforce = 0")
    suspend fun getUnsynced(): List<JobPosting>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(job: JobPosting)

    @Update
    suspend fun update(job: JobPosting)

    @Delete
    suspend fun delete(job: JobPosting)
}
```

### DailyRoutineDao.kt

```kotlin
// app/src/main/java/com/neurothrive/assistant/data/local/dao/DailyRoutineDao.kt
package com.neurothrive.assistant.data.local.dao

import androidx.room.*
import com.neurothrive.assistant.data.local.entities.DailyRoutine
import kotlinx.coroutines.flow.Flow

@Dao
interface DailyRoutineDao {
    @Query("SELECT * FROM daily_routines ORDER BY date DESC")
    fun getAllFlow(): Flow<List<DailyRoutine>>

    @Query("SELECT * FROM daily_routines WHERE date >= :startDate AND date <= :endDate ORDER BY date DESC")
    suspend fun getRoutinesBetween(startDate: Long, endDate: Long): List<DailyRoutine>

    @Query("SELECT * FROM daily_routines WHERE syncedToSalesforce = 0")
    suspend fun getUnsynced(): List<DailyRoutine>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(routine: DailyRoutine)

    @Update
    suspend fun update(routine: DailyRoutine)

    @Delete
    suspend fun delete(routine: DailyRoutine)
}
```

---

## STEP 4: Create SecurityUtils (30 min)

```kotlin
// app/src/main/java/com/neurothrive/assistant/data/local/SecurityUtils.kt
package com.neurothrive.assistant.data.local

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

object SecurityUtils {

    private const val KEY_ALIAS = "neurothrive_master_key"
    private const val ANDROID_KEYSTORE = "AndroidKeyStore"
    private const val TRANSFORMATION = "AES/GCM/NoPadding"
    private const val GCM_TAG_LENGTH = 128

    init {
        ensureKeyExists()
    }

    private fun ensureKeyExists() {
        val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE)
        keyStore.load(null)

        if (!keyStore.containsAlias(KEY_ALIAS)) {
            generateKey()
        }
    }

    private fun generateKey() {
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            ANDROID_KEYSTORE
        )

        val keyGenParameterSpec = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .build()

        keyGenerator.init(keyGenParameterSpec)
        keyGenerator.generateKey()
    }

    private fun getSecretKey(): SecretKey {
        val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE)
        keyStore.load(null)
        return keyStore.getKey(KEY_ALIAS, null) as SecretKey
    }

    fun encrypt(data: String): String {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, getSecretKey())

        val iv = cipher.iv
        val encrypted = cipher.doFinal(data.toByteArray())

        // Combine IV + encrypted data
        val combined = iv + encrypted
        return Base64.encodeToString(combined, Base64.DEFAULT)
    }

    fun decrypt(encryptedData: String): String {
        val decoded = Base64.decode(encryptedData, Base64.DEFAULT)

        // Split IV and encrypted data (IV is first 12 bytes for GCM)
        val iv = decoded.sliceArray(0..11)
        val encrypted = decoded.sliceArray(12 until decoded.size)

        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, getSecretKey(), GCMParameterSpec(GCM_TAG_LENGTH, iv))

        val decrypted = cipher.doFinal(encrypted)
        return String(decrypted)
    }
}
```

---

## STEP 5: Create AndroidManifest.xml (15 min)

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:name=".NeuroThriveApplication"
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.NeuroThrive"
        tools:targetApi="31">

        <activity
            android:name=".ui.MainActivity"
            android:exported="true"
            android:theme="@style/Theme.NeuroThrive">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

---

## STEP 6: Create MainActivity.kt (15 min)

```kotlin
// app/src/main/java/com/neurothrive/assistant/ui/MainActivity.kt
package com.neurothrive.assistant.ui

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            NeuroThriveTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    PlaceholderScreen()
                }
            }
        }
    }
}

@Composable
fun PlaceholderScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "NeuroThrive",
            style = MaterialTheme.typography.headlineLarge,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "Database initialized ✓\nSession 1 Complete!",
            style = MaterialTheme.typography.bodyLarge,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
fun NeuroThriveTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = lightColorScheme(),
        content = content
    )
}
```

---

## STEP 7: Create Application Class (15 min)

```kotlin
// app/src/main/java/com/neurothrive/assistant/NeuroThriveApplication.kt
package com.neurothrive.assistant

import android.app.Application
import androidx.room.Room
import com.neurothrive.assistant.data.local.AppDatabase
import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber

@HiltAndroidApp
class NeuroThriveApplication : Application() {

    lateinit var database: AppDatabase
        private set

    override fun onCreate() {
        super.onCreate()

        // Initialize Timber for logging
        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        }

        // Initialize Room database
        database = Room.databaseBuilder(
            applicationContext,
            AppDatabase::class.java,
            "neurothrive_database"
        ).build()

        Timber.d("NeuroThrive Application initialized")
        Timber.d("Database created with encryption ready")
    }
}
```

---

## STEP 8: Create Unit Tests (30 min)

```kotlin
// app/src/test/java/com/neurothrive/assistant/MoodEntryDaoTest.kt
package com.neurothrive.assistant

import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import com.neurothrive.assistant.data.local.AppDatabase
import com.neurothrive.assistant.data.local.entities.MoodEntry
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.Assert.*

class MoodEntryDaoTest {

    private lateinit var database: AppDatabase

    @Before
    fun setup() {
        database = Room.inMemoryDatabaseBuilder(
            ApplicationProvider.getApplicationContext(),
            AppDatabase::class.java
        ).allowMainThreadQueries().build()
    }

    @After
    fun teardown() {
        database.close()
    }

    @Test
    fun insertAndRetrieveMoodEntry() = runTest {
        val entry = MoodEntry(
            moodLevel = 7,
            energyLevel = 6,
            painLevel = 2
        )

        database.moodEntryDao().insert(entry)
        val entries = database.moodEntryDao().getEntriesBetween(0, Long.MAX_VALUE)

        assertEquals(1, entries.size)
        assertEquals(7, entries[0].moodLevel)
        assertEquals(6, entries[0].energyLevel)
    }

    @Test
    fun getUnsyncedEntries() = runTest {
        val synced = MoodEntry(moodLevel = 5, energyLevel = 5, painLevel = 1, syncedToSalesforce = true)
        val unsynced = MoodEntry(moodLevel = 7, energyLevel = 8, painLevel = 0, syncedToSalesforce = false)

        database.moodEntryDao().insert(synced)
        database.moodEntryDao().insert(unsynced)

        val unsyncedEntries = database.moodEntryDao().getUnsynced()

        assertEquals(1, unsyncedEntries.size)
        assertEquals(7, unsyncedEntries[0].moodLevel)
        assertFalse(unsyncedEntries[0].syncedToSalesforce)
    }
}
```

---

## SUCCESS CRITERIA - Session 1

**Before committing, verify:**

1. ✅ `android/` directory exists
2. ✅ `MainActivity.kt` file created (NOT .cls file)
3. ✅ `build.gradle.kts` files created (NOT Apex files)
4. ✅ 4 entity classes created (MoodEntry, WinEntry, JobPosting, DailyRoutine)
5. ✅ 4 DAO interfaces created
6. ✅ SecurityUtils.kt created with AES-256 encryption
7. ✅ Unit tests created and passing
8. ✅ Zero `.cls` files in project
9. ✅ Zero `.object-meta.xml` files in project
10. ✅ Zero Salesforce metadata

**Run these commands to verify:**

```bash
# Should show android directory structure
ls -la android/

# Should show MainActivity.kt (NOT .cls)
find android/ -name "MainActivity.kt"

# Should show 0 results (NO Apex classes)
find android/ -name "*.cls" | wc -l

# Should show 0 results (NO Salesforce metadata)
find android/ -name "*-meta.xml" | wc -l

# Build project
cd android
./gradlew build

# Run tests
./gradlew test
```

**Expected output:**
- Build: SUCCESS
- Tests: 3/3 passing
- No .cls files found
- No -meta.xml files found

---

## COMMIT MESSAGE

```
feat: implement Android database layer with Room and encryption

Session 1 of 4 - Android Foundation Complete

Built:
- Kotlin/Jetpack Compose Android project
- SQLite database with Room ORM
- AES-256 encryption (SecurityUtils)
- 4 entity classes (MoodEntry, WinEntry, JobPosting, DailyRoutine)
- 4 DAO interfaces with CRUD + sync queries
- MainActivity with placeholder UI
- Unit tests (3 tests passing)

Platform: Android (Kotlin)
Next: Session 2 - Salesforce OAuth integration

🤖 Generated with Claude Code (https://claude.com/claude-code)
```

---

## NEXT SESSION PREVIEW

**Session 2 will cover:**
- Salesforce Connected App setup
- OAuth 2.0 token management
- REST API client using Retrofit
- Sync Manager with WorkManager
- Background sync every 15 minutes

**Time estimate:** 3-4 hours

---

## FINAL VALIDATION

**Before you finish Session 1, answer these questions:**

1. Did you create an `android/` directory? (YES/NO)
2. Did you create `MainActivity.kt`? (YES/NO)
3. Did you create any `.cls` files? (Should be NO)
4. Did you create any Salesforce objects? (Should be NO)
5. Do all unit tests pass? (Should be YES)

**If any answer is wrong, STOP and review the instructions.**

**When all answers are correct, commit and push to GitHub.**

---

## PROMPT END

**IMPORTANT**: After pasting this prompt, Claude Code should:
1. Create `android/` directory structure
2. Write Kotlin code (.kt files)
3. NOT create any Salesforce files
4. Commit with the provided message

**If Claude Code creates .cls files or Salesforce metadata, STOP IMMEDIATELY.**


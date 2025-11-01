/**
 * Comprehensive Test Script for All Energy Levels
 * Tests the DailyRoutineInvocable and EnergyAdaptiveScheduler with all 4 energy states
 *
 * Run this in Developer Console → Debug → Execute Anonymous Apex
 */

System.debug('\n========================================');
System.debug('WELLNESS SYSTEM - COMPREHENSIVE TEST');
System.debug('========================================\n');

// Test 1: HIGH ENERGY DAY (8-10)
System.debug('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
System.debug('TEST 1: HIGH ENERGY DAY (Level 9)');
System.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

DailyRoutineInvocable.Request highEnergyReq = new DailyRoutineInvocable.Request();
highEnergyReq.energyLevel = 9;
highEnergyReq.mood = 'Great';
highEnergyReq.morningRoutineComplete = true;

List<DailyRoutineInvocable.Request> highRequests = new List<DailyRoutineInvocable.Request>{highEnergyReq};
List<DailyRoutineInvocable.Result> highResults = DailyRoutineInvocable.getAdaptiveSchedule(highRequests);

DailyRoutineInvocable.Result highResult = highResults[0];
System.debug('✓ Success: ' + highResult.success);
System.debug('✓ Energy Category: ' + highResult.energyCategory);
System.debug('✓ Study Hours: ' + highResult.studyHours + ' (Expected: 4)');
System.debug('✓ Job Search Hours: ' + highResult.jobSearchHours + ' (Expected: 2.0)');
System.debug('✓ Application Goal: ' + highResult.applicationGoal + ' (Expected: 4-5)');
System.debug('\n📅 Today\'s Schedule:\n' + highResult.todaysSchedule);
System.debug('\n💬 Message:\n' + highResult.motivationalMessage);


// Test 2: MEDIUM ENERGY DAY (5-7)
System.debug('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
System.debug('TEST 2: MEDIUM ENERGY DAY (Level 6)');
System.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

DailyRoutineInvocable.Request mediumEnergyReq = new DailyRoutineInvocable.Request();
mediumEnergyReq.energyLevel = 6;
mediumEnergyReq.mood = 'Good';
mediumEnergyReq.morningRoutineComplete = true;

List<DailyRoutineInvocable.Request> mediumRequests = new List<DailyRoutineInvocable.Request>{mediumEnergyReq};
List<DailyRoutineInvocable.Result> mediumResults = DailyRoutineInvocable.getAdaptiveSchedule(mediumRequests);

DailyRoutineInvocable.Result mediumResult = mediumResults[0];
System.debug('✓ Success: ' + mediumResult.success);
System.debug('✓ Energy Category: ' + mediumResult.energyCategory);
System.debug('✓ Study Hours: ' + mediumResult.studyHours + ' (Expected: 3)');
System.debug('✓ Job Search Hours: ' + mediumResult.jobSearchHours + ' (Expected: 1.5)');
System.debug('✓ Application Goal: ' + mediumResult.applicationGoal + ' (Expected: 2-3)');
System.debug('\n📅 Today\'s Schedule:\n' + mediumResult.todaysSchedule);
System.debug('\n💬 Message:\n' + mediumResult.motivationalMessage);


// Test 3: LOW ENERGY DAY (2-4)
System.debug('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
System.debug('TEST 3: LOW ENERGY DAY (Level 3)');
System.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

DailyRoutineInvocable.Request lowEnergyReq = new DailyRoutineInvocable.Request();
lowEnergyReq.energyLevel = 3;
lowEnergyReq.mood = 'Low';
lowEnergyReq.morningRoutineComplete = false;

List<DailyRoutineInvocable.Request> lowRequests = new List<DailyRoutineInvocable.Request>{lowEnergyReq};
List<DailyRoutineInvocable.Result> lowResults = DailyRoutineInvocable.getAdaptiveSchedule(lowRequests);

DailyRoutineInvocable.Result lowResult = lowResults[0];
System.debug('✓ Success: ' + lowResult.success);
System.debug('✓ Energy Category: ' + lowResult.energyCategory);
System.debug('✓ Study Hours: ' + lowResult.studyHours + ' (Expected: 2)');
System.debug('✓ Job Search Hours: ' + lowResult.jobSearchHours + ' (Expected: 0.5-1.0)');
System.debug('✓ Application Goal: ' + lowResult.applicationGoal + ' (Expected: 1-2)');
System.debug('\n📅 Today\'s Schedule:\n' + lowResult.todaysSchedule);
System.debug('\n💬 Message:\n' + lowResult.motivationalMessage);


// Test 4: FLARE-UP DAY (1)
System.debug('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
System.debug('TEST 4: FLARE-UP DAY (Level 1)');
System.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

DailyRoutineInvocable.Request flareupReq = new DailyRoutineInvocable.Request();
flareupReq.energyLevel = 1;
flareupReq.mood = 'Very Low';
flareupReq.morningRoutineComplete = false;

List<DailyRoutineInvocable.Request> flareupRequests = new List<DailyRoutineInvocable.Request>{flareupReq};
List<DailyRoutineInvocable.Result> flareupResults = DailyRoutineInvocable.getAdaptiveSchedule(flareupRequests);

DailyRoutineInvocable.Result flareupResult = flareupResults[0];
System.debug('✓ Success: ' + flareupResult.success);
System.debug('✓ Energy Category: ' + flareupResult.energyCategory);
System.debug('✓ Study Hours: ' + flareupResult.studyHours + ' (Expected: 0)');
System.debug('✓ Job Search Hours: ' + flareupResult.jobSearchHours + ' (Expected: 0)');
System.debug('✓ Application Goal: ' + flareupResult.applicationGoal + ' (Expected: Rest)');
System.debug('\n📅 Today\'s Schedule:\n' + flareupResult.todaysSchedule);
System.debug('\n💬 Message:\n' + flareupResult.motivationalMessage);


// Test 5: EDGE CASE - Update Existing Record
System.debug('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
System.debug('TEST 5: UPDATE EXISTING RECORD');
System.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

DailyRoutineInvocable.Request updateReq = new DailyRoutineInvocable.Request();
updateReq.energyLevel = 8;
updateReq.mood = 'Great';
updateReq.morningRoutineComplete = true;

List<DailyRoutineInvocable.Request> updateRequests = new List<DailyRoutineInvocable.Request>{updateReq};
List<DailyRoutineInvocable.Result> updateResults = DailyRoutineInvocable.getAdaptiveSchedule(updateRequests);

DailyRoutineInvocable.Result updateResult = updateResults[0];
System.debug('✓ Success: ' + updateResult.success);
System.debug('✓ Message: ' + updateResult.message);
System.debug('Note: This should UPDATE the existing record for today');


// Summary
System.debug('\n========================================');
System.debug('TEST SUMMARY');
System.debug('========================================\n');

Integer passCount = 0;
if (highResult.success) passCount++;
if (mediumResult.success) passCount++;
if (lowResult.success) passCount++;
if (flareupResult.success) passCount++;
if (updateResult.success) passCount++;

System.debug('✓ Tests Passed: ' + passCount + '/5');
System.debug('\n✓ Verify Daily_Routine__c records created in org');
System.debug('✓ Check: Setup → Object Manager → Daily Routine → Records');
System.debug('\n========================================\n');

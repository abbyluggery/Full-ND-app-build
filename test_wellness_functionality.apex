// Test script to verify the wellness system functionality
// This script tests the DailyRoutineInvocable class with sample data

// Create a test request
DailyRoutineInvocable.Request req = new DailyRoutineInvocable.Request();
req.energyLevel = 7;  // Medium energy day
req.mood = 'Good';
req.morningRoutineComplete = true;

List<DailyRoutineInvocable.Request> requests = new List<DailyRoutineInvocable.Request>{req};
List<DailyRoutineInvocable.Result> results = DailyRoutineInvocable.getAdaptiveSchedule(requests);

DailyRoutineInvocable.Result result = results[0];
System.debug('Success: ' + result.success);
System.debug('Energy Category: ' + result.energyCategory);
System.debug('Study Hours: ' + result.studyHours);
System.debug('Job Search Hours: ' + result.jobSearchHours);
System.debug('Application Goal: ' + result.applicationGoal);
System.debug('\nToday\'s Schedule:\n' + result.todaysSchedule);
System.debug('\nMessage:\n' + result.motivationalMessage);

// Expected Output:
// Success: true
// Energy Category: Medium
// Study Hours: 3
// Job Search Hours: 1.5
// Application Goal: 2-3 applications

// Today's Schedule:
// 9:00 AM - Complete morning wellness routine
// 10:00 AM - Salesforce study (3 hours total today)
// 1:00 PM - Lunch + movement break
// 2:00 PM - Job search & applications (1.5 hours, 2-3 applications)
// 4:00 PM - Wrap-up: log accomplishments, plan tomorrow

// Message:
// Good energy today! This is your sweet spot for consistent progress...

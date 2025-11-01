// Quick test - try to create one Daily_Routine with all wellness fields
Daily_Routine__c testRecord = new Daily_Routine__c(
    Date__c = Date.today()-15
);

// Try to set wellness fields - if they exist, this will work
try {
    testRecord.put('Energy_Level_Morning__c', 8);
    testRecord.put('Energy_Level_Afternoon__c', 7);
    testRecord.put('Energy_Level_Evening__c', 6);
    testRecord.put('Mood__c', 'Testing');
    testRecord.put('Stress_Level__c', 3);
    testRecord.put('Exercise_Completed__c', true);
    testRecord.put('Exercise_Type__c', 'Walk');
    testRecord.put('Water_Intake__c', 8);
    testRecord.put('Morning_Routine_Complete__c', true);
    testRecord.put('Accomplished_Today__c', 'Testing field deployment');
    testRecord.put('Challenges__c', 'None');
    testRecord.put('Gratitude__c', 'Fields are working!');
    testRecord.put('Tomorrow_Priorities__c', 'Update all 10 records');

    insert testRecord;
    System.debug('✅ SUCCESS! All wellness fields exist and are writable!');
    System.debug('Test record ID: ' + testRecord.Id);
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}

/**
 * Check which custom objects are deployed in your org
 * Run this in Execute Anonymous to see what's missing
 */

List<String> objectsToCheck = new List<String>{
    'Job_Posting__c',
    'Master_Resume_Config__c',
    'Resume_Package__c',
    'Master_Resume__c',
    'Daily_Routine__c'
};

System.debug('=== Checking Custom Objects ===');
System.debug('');

List<String> existingObjects = new List<String>();
List<String> missingObjects = new List<String>();

for (String objName : objectsToCheck) {
    try {
        Schema.DescribeSObjectResult result = Schema.getGlobalDescribe().get(objName).getDescribe();
        System.debug('✅ ' + objName + ' EXISTS');
        existingObjects.add(objName);
    } catch (Exception e) {
        System.debug('❌ ' + objName + ' NOT FOUND');
        missingObjects.add(objName);
    }
}

System.debug('');
System.debug('=== SUMMARY ===');
System.debug('Existing objects: ' + existingObjects.size() + ' / ' + objectsToCheck.size());
System.debug('Missing objects: ' + missingObjects.size());

if (!missingObjects.isEmpty()) {
    System.debug('');
    System.debug('OBJECTS TO DEPLOY:');
    for (String obj : missingObjects) {
        System.debug('  - ' + obj);
    }
}

System.debug('');
System.debug('=== DEPLOYMENT READINESS ===');

if (missingObjects.isEmpty()) {
    System.debug('✅ ALL OBJECTS DEPLOYED - Ready to deploy all classes!');
} else if (missingObjects.contains('Master_Resume_Config__c') ||
           missingObjects.contains('Resume_Package__c') ||
           missingObjects.contains('Master_Resume__c')) {
    System.debug('⚠️ Resume objects missing - Deploy resume objects before ResumeGenerator');
}
if (missingObjects.contains('Daily_Routine__c')) {
    System.debug('⚠️ Daily_Routine__c missing - Deploy before wellness classes');
}

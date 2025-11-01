public class VerifyDailyRoutineFields {
    
    public static void checkFields() {
        // Query the object describe to check fields
        Schema.DescribeSObjectResult objDesc = Daily_Routine__c.SObjectType.getDescribe();
        
        // Get all fields
        Map<String, Schema.SObjectField> fields = objDesc.fields.getMap();
        
        System.debug('=== Daily_Routine__c Fields ===');
        for(String fieldName : fields.keySet()) {
            Schema.SObjectField field = fields.get(fieldName);
            System.debug(fieldName + ' - ' + field.getDescribe().getType());
        }
        
        // Check specific fields mentioned in the issue
        String[] requiredFields = new String[] {
            'Energy_Level_Morning__c',
            'Energy_Level_Afternoon__c', 
            'Energy_Level_Evening__c',
            'Mood__c',
            'Stress_Level__c',
            'Exercise_Completed__c',
            'Exercise_Type__c',
            'Water_Intake__c',
            'Morning_Routine_Complete__c',
            'Accomplished_Today__c',
            'Challenges__c',
            'Gratitude__c',
            'Tomorrow_Priorities__c'
        };
        
        System.debug('=== Checking Required Fields ===');
        for(String field : requiredFields) {
            if(fields.containsKey(field)) {
                System.debug(field + ' - EXISTS');
            } else {
                System.debug(field + ' - MISSING');
            }
        }
    }
}

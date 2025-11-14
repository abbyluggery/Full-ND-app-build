/**
 * Export Store Coupon IDs for Deletion
 *
 * This script exports all Store_Coupon__c IDs to prepare for deletion via Workbench.
 *
 * Run in Developer Console Anonymous Apex
 */

System.debug('========== EXPORTING STORE COUPONS FOR DELETION ==========');

// Get all Store_Coupon__c records
List<Store_Coupon__c> coupons = [
    SELECT Id, Item_Name__c, Store__c, Source__c
    FROM Store_Coupon__c
    ORDER BY CreatedDate DESC
];

System.debug('Found ' + coupons.size() + ' Store_Coupon__c records to delete');
System.debug('');

// Show summary by source
Map<String, Integer> countBySource = new Map<String, Integer>();
for (Store_Coupon__c coupon : coupons) {
    String source = coupon.Source__c != null ? coupon.Source__c : 'Unknown';
    if (countBySource.containsKey(source)) {
        countBySource.put(source, countBySource.get(source) + 1);
    } else {
        countBySource.put(source, 1);
    }
}

System.debug('Breakdown by Source:');
for (String source : countBySource.keySet()) {
    System.debug('  ' + source + ': ' + countBySource.get(source) + ' records');
}
System.debug('');

System.debug('========== INSTRUCTIONS ==========');
System.debug('To delete these records via Workbench:');
System.debug('');
System.debug('1. Go to: https://workbench.developerforce.com/');
System.debug('2. Login with your Salesforce credentials');
System.debug('3. Navigate to: Data -> Delete');
System.debug('4. Select object: Store_Coupon__c');
System.debug('5. Click "Next"');
System.debug('6. Paste this query:');
System.debug('   SELECT Id FROM Store_Coupon__c');
System.debug('7. Click "Query"');
System.debug('8. Click "Select All"');
System.debug('9. Click "Delete"');
System.debug('10. Confirm deletion');
System.debug('');
System.debug('After deletion completes, import the new CSV:');
System.debug('data/southern_savers_publix_2025-11-10.csv');

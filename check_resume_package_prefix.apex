// Check what object prefix Resume_Package__c uses
List<Resume_Package__c> packages = [
    SELECT Id, Name, Resume_Content__c, Cover_Letter__c
    FROM Resume_Package__c
    LIMIT 1
];

if (!packages.isEmpty()) {
    Resume_Package__c pkg = packages[0];
    String recordId = String.valueOf(pkg.Id);
    String prefix = recordId.substring(0, 3);

    System.debug('✅ Found Resume Package');
    System.debug('Record ID: ' + recordId);
    System.debug('Object Prefix: ' + prefix);
    System.debug('Record Name: ' + pkg.Name);
    System.debug('Has Resume Content: ' + (String.isNotBlank(pkg.Resume_Content__c)));
    System.debug('Resume Content Length: ' + (pkg.Resume_Content__c != null ? pkg.Resume_Content__c.length() : 0));
    System.debug('Has Cover Letter: ' + (String.isNotBlank(pkg.Cover_Letter__c)));
    System.debug('Cover Letter Length: ' + (pkg.Cover_Letter__c != null ? pkg.Cover_Letter__c.length() : 0));
} else {
    System.debug('❌ No Resume Package records found');
}

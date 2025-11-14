// Comprehensive diagnostic script for PDF generation issue
System.debug('=== PDF GENERATION DIAGNOSTIC ===');

// Step 1: Check if we have any Resume Packages
List<Resume_Package__c> allPackages = [
    SELECT Id, Name, Resume_Content__c, Cover_Letter__c,
           Opportunity__c, Job_Posting__c, Status__c
    FROM Resume_Package__c
    LIMIT 10
];

System.debug('\n1. RESUME PACKAGES IN ORG:');
System.debug('Total packages found: ' + allPackages.size());
for (Resume_Package__c pkg : allPackages) {
    String pkgId = String.valueOf(pkg.Id);
    String prefix = pkgId.substring(0, 3);
    System.debug('  - ID: ' + pkgId + ' (prefix: ' + prefix + ')');
    System.debug('    Name: ' + pkg.Name);
    System.debug('    Status: ' + pkg.Status__c);
    System.debug('    Has Resume: ' + (String.isNotBlank(pkg.Resume_Content__c)));
    System.debug('    Resume Length: ' + (pkg.Resume_Content__c != null ? pkg.Resume_Content__c.length() : 0));
    System.debug('    Has Cover Letter: ' + (String.isNotBlank(pkg.Cover_Letter__c)));
    System.debug('    Cover Letter Length: ' + (pkg.Cover_Letter__c != null ? pkg.Cover_Letter__c.length() : 0));
    System.debug('');
}

// Step 2: Check the specific ID from the error message
String errorId = 'a1Fg5000000ZSPEA2';
System.debug('\n2. CHECKING SPECIFIC ID FROM ERROR: ' + errorId);
System.debug('ID Prefix: ' + errorId.substring(0, 3));

// Try to query this specific ID
List<Resume_Package__c> specificPackage = [
    SELECT Id, Name, Resume_Content__c, Cover_Letter__c
    FROM Resume_Package__c
    WHERE Id = :errorId
    LIMIT 1
];

if (!specificPackage.isEmpty()) {
    System.debug('✅ FOUND the package with ID: ' + errorId);
    Resume_Package__c pkg = specificPackage[0];
    System.debug('Name: ' + pkg.Name);
    System.debug('Has Resume Content: ' + (String.isNotBlank(pkg.Resume_Content__c)));
    System.debug('Resume Content Length: ' + (pkg.Resume_Content__c != null ? pkg.Resume_Content__c.length() : 0));
} else {
    System.debug('❌ NO package found with ID: ' + errorId);
    System.debug('This ID either:');
    System.debug('  - Does not exist');
    System.debug('  - Is not a Resume_Package__c record');
    System.debug('  - Has been deleted');
}

// Step 3: Check recent ContentVersions (PDF files)
List<ContentVersion> recentPDFs = [
    SELECT Id, Title, ContentDocumentId, CreatedDate
    FROM ContentVersion
    WHERE (Title LIKE '%Resume%' OR Title LIKE '%Cover Letter%')
    ORDER BY CreatedDate DESC
    LIMIT 5
];

System.debug('\n3. RECENT PDF FILES:');
System.debug('Recent PDFs found: ' + recentPDFs.size());
for (ContentVersion cv : recentPDFs) {
    String cvId = String.valueOf(cv.Id);
    String prefix = cvId.substring(0, 3);
    System.debug('  - ID: ' + cvId + ' (prefix: ' + prefix + ')');
    System.debug('    Title: ' + cv.Title);
    System.debug('    Created: ' + cv.CreatedDate);
}

System.debug('\n=== END DIAGNOSTIC ===');

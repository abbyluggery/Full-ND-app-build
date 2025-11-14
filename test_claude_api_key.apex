// Test Claude API Key Configuration
// Run this in Developer Console -> Debug -> Open Execute Anonymous Window

// Query the API configuration
API_Configuration__mdt config = [
    SELECT Claude_API_Key__c
    FROM API_Configuration__mdt
    WHERE DeveloperName = 'Claude'
    LIMIT 1
];

// Check if the key exists
if (config == null) {
    System.debug('ERROR: No API Configuration record found with DeveloperName = Claude');
} else if (String.isBlank(config.Claude_API_Key__c)) {
    System.debug('ERROR: Claude_API_Key__c field is blank');
} else {
    String apiKey = config.Claude_API_Key__c;

    // Debug key info (without exposing the full key)
    System.debug('✅ API Key found!');
    System.debug('Key length: ' + apiKey.length());
    System.debug('Key starts with: ' + apiKey.substring(0, Math.min(15, apiKey.length())));
    System.debug('Key ends with: ' + apiKey.substring(Math.max(0, apiKey.length() - 10)));

    // Check for common issues
    if (apiKey.contains('\n')) {
        System.debug('⚠️ WARNING: API key contains newline characters');
    }
    if (apiKey.contains(' ')) {
        System.debug('⚠️ WARNING: API key contains spaces');
    }
    if (apiKey != apiKey.trim()) {
        System.debug('⚠️ WARNING: API key has leading or trailing whitespace');
    }

    // Check expected format
    if (apiKey.startsWith('sk-ant-api')) {
        System.debug('✅ Key format looks correct (starts with sk-ant-api)');
    } else {
        System.debug('⚠️ WARNING: Key does not start with expected prefix (sk-ant-api)');
    }
}

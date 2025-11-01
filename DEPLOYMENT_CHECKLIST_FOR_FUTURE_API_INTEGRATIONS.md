# Deployment Checklist for Future API Integrations

Use this checklist every time you deploy a new API integration (Resume Generator, Cover Letter Generator, Interview Prep, etc.)

---

## Pre-Deployment Checklist

### 1. API Configuration
- [ ] Read the API documentation thoroughly
- [ ] Identify all **required fields** (must be in every request)
- [ ] Identify all **optional fields** (can be conditionally included)
- [ ] Note the expected **data types** for each field (string, number, boolean, array, object)
- [ ] Get example request/response JSON from API docs

### 2. Code Structure
- [ ] Use `JSONGenerator` for JSON building (NOT `JSON.serialize()`)
- [ ] Create a `buildRequestJson()` method that returns String
- [ ] Use explicit type methods:
  - `writeStringField()` for strings
  - `writeNumberField()` for numbers
  - `writeBooleanField()` for booleans
- [ ] Always write required fields (no null checks)
- [ ] Conditionally write optional fields (with `isNotBlank()` check)

### 3. Null Safety
- [ ] Ensure prompt-building methods never return null
- [ ] Add validation: throw exception if critical values are blank
- [ ] Never pass null or empty string to `writeStringField()`
- [ ] Use constants for values that never change (MODEL, MAX_TOKENS, etc.)

### 4. Authentication
- [ ] Store API key in Custom Metadata (NOT hardcoded)
- [ ] Query Custom Metadata in the request method
- [ ] Validate API key exists before making callout
- [ ] Set all required headers (`Content-Type`, `x-api-key`, etc.)

---

## Code Template for New API Service

```apex
public with sharing class NewAPIService {

    // Constants
    private static final String API_ENDPOINT = 'https://api.example.com/v1/endpoint';
    private static final String MODEL = 'model-name';
    private static final Integer MAX_TOKENS = 4000;
    private static final Integer TIMEOUT_MS = 60000;

    /**
     * Main method to call the API
     */
    public static ApiResponse callApi(SObject__c record, String context) {
        try {
            // 1. Build prompt (ensure non-null)
            String prompt = buildPrompt(record);
            if (String.isBlank(prompt)) {
                throw new ApiException('Prompt cannot be blank');
            }

            // 2. Build JSON request body
            String requestBody = buildRequestJson(context, prompt);

            // 3. Send request
            HttpResponse response = sendRequest(requestBody);

            // 4. Parse response
            return parseResponse(response);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'API Error: ' + e.getMessage());
            throw new ApiException('Failed to call API: ' + e.getMessage(), e);
        }
    }

    /**
     * Builds JSON request body using JSONGenerator
     */
    private static String buildRequestJson(String context, String prompt) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();

        // REQUIRED FIELDS - Always write
        gen.writeStringField('model', MODEL);
        gen.writeNumberField('max_tokens', MAX_TOKENS);

        // OPTIONAL FIELDS - Conditionally write
        if (String.isNotBlank(context)) {
            gen.writeStringField('context', context);
        }

        // REQUIRED ARRAY
        gen.writeFieldName('messages');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('role', 'user');
        gen.writeStringField('content', prompt);
        gen.writeEndObject();
        gen.writeEndArray();

        gen.writeEndObject();
        return gen.getAsString();
    }

    /**
     * Builds the prompt for the API
     * IMPORTANT: Never return null!
     */
    private static String buildPrompt(SObject__c record) {
        if (record == null) {
            return 'Default prompt text';
        }

        String prompt = '';
        // Build prompt logic here
        // Ensure you always return a non-blank string
        return String.isNotBlank(prompt) ? prompt : 'Default prompt';
    }

    /**
     * Sends HTTP request to API
     */
    private static HttpResponse sendRequest(String requestBody) {
        // Query API key from Custom Metadata
        API_Configuration__mdt config = [
            SELECT API_Key__c
            FROM API_Configuration__mdt
            WHERE DeveloperName = 'ServiceName'
            LIMIT 1
        ];

        if (config == null || String.isBlank(config.API_Key__c)) {
            throw new ApiException('API key not configured');
        }

        // Build HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(API_ENDPOINT);
        req.setMethod('POST');
        req.setTimeout(TIMEOUT_MS);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + config.API_Key__c);
        req.setBody(requestBody);

        // Debug log
        System.debug('Request: ' + requestBody);

        // Send request
        Http http = new Http();
        HttpResponse response = http.send(req);

        // Debug log
        System.debug('Response Status: ' + response.getStatusCode());
        System.debug('Response Body: ' + response.getBody());

        // Check for errors
        if (response.getStatusCode() != 200) {
            throw new ApiException('API returned ' + response.getStatusCode() + ': ' + response.getBody());
        }

        return response;
    }

    /**
     * Parses API response
     */
    private static ApiResponse parseResponse(HttpResponse response) {
        try {
            return (ApiResponse) JSON.deserialize(response.getBody(), ApiResponse.class);
        } catch (Exception e) {
            throw new ApiException('Failed to parse response: ' + e.getMessage());
        }
    }

    // Response wrapper class
    public class ApiResponse {
        public String id;
        public String result;
        // Add fields as needed
    }

    // Custom exception
    public class ApiException extends Exception {}
}
```

---

## Testing Checklist

### 1. Unit Tests
- [ ] Create test class with `@isTest` annotation
- [ ] Mock HTTP callouts with `Test.setMock()`
- [ ] Test success scenario (200 response)
- [ ] Test error scenarios (400, 401, 500 responses)
- [ ] Test null/blank input handling
- [ ] Achieve >75% code coverage

### 2. Integration Tests
- [ ] Create a test record via Salesforce UI
- [ ] Trigger the API call (via trigger, button, or Flow)
- [ ] Wait for async processing (if using Queueable/Future)
- [ ] Check that response fields populate correctly
- [ ] Check Debug Logs for request/response JSON
- [ ] Verify no errors in Setup → Apex Jobs

### 3. Debug Logs Analysis
- [ ] Enable debug logs for your user (Setup → Debug Logs)
- [ ] Set all log categories to FINEST
- [ ] Run test again
- [ ] Check log for "Request: " - verify JSON structure
- [ ] Check log for "Response Status: " - should be 200
- [ ] Check log for "Response Body: " - verify expected data

---

## Deployment Steps

### Step 1: Deploy via Developer Console

1. Open **Developer Console**
2. **File → New → Apex Class**
3. Name: `YourNewAPIService`
4. Paste code from your file
5. **Ctrl+S** to save
6. Check for compilation errors (bottom panel)
7. If errors, fix and save again

### Step 2: Deploy Supporting Metadata

Deploy in this order:

1. **Custom Objects** (if creating new ones)
   ```bash
   sf project deploy start --source-dir force-app/main/default/objects/New_Object__c
   ```

2. **Custom Metadata** (for API config)
   ```bash
   sf project deploy start --source-dir force-app/main/default/customMetadata
   ```

3. **Apex Classes**
   ```bash
   sf project deploy start --metadata ApexClass:YourNewAPIService
   ```

4. **Triggers** (if needed)
   ```bash
   sf project deploy start --source-dir force-app/main/default/triggers
   ```

5. **Flows** (if needed)
   ```bash
   sf project deploy start --source-dir force-app/main/default/flows
   ```

### Step 3: Verify Deployment

- [ ] Check Setup → Apex Classes - your class appears
- [ ] Check Setup → Custom Metadata Types - config exists
- [ ] Check Setup → Objects - new objects/fields exist
- [ ] Check Setup → Remote Site Settings - API endpoint added

---

## Common Deployment Issues

### Issue 1: "Missing message metadata.transfer"

**Cause**: SF CLI localization warning (harmless)

**Fix**: Ignore - component still deploys successfully

---

### Issue 2: "Unable to calculate fullName"

**Cause**: Metadata folder structure issue

**Fix**: Use `--metadata` flag instead of `--source-dir`:
```bash
sf project deploy start --metadata ApexClass:YourClass
```

---

### Issue 3: Test Coverage Too Low

**Cause**: Apex tests don't cover enough code

**Fix**:
1. Write more test methods
2. Use `Test.setMock()` for HTTP callouts
3. Test all code branches (if/else, try/catch)

---

### Issue 4: "Field required" API Error

**Cause**: Required field not being sent in JSON

**Fix**:
1. Check API docs for required fields
2. Ensure `buildRequestJson()` writes all required fields
3. Remove null checks from required fields

---

### Issue 5: "null argument for JSONGenerator"

**Cause**: Passing null/empty string to write method

**Fix**:
1. Add null check before writing optional fields
2. Ensure prompt-building methods return non-null
3. Use constants for fields that never change

---

## Post-Deployment Verification

### 1. Smoke Test
- [ ] Create a test record via UI
- [ ] Trigger API call
- [ ] Verify response fields populate within expected time
- [ ] Check no errors in record

### 2. Bulk Test (if applicable)
- [ ] Create 5-10 test records
- [ ] Trigger API calls for all
- [ ] Verify all process successfully
- [ ] Check Setup → Apex Jobs for failures

### 3. Error Handling Test
- [ ] Temporarily break API key (change one character)
- [ ] Try to trigger API call
- [ ] Verify you get a clear error message (not a null pointer)
- [ ] Restore correct API key
- [ ] Verify it works again

---

## Documentation Checklist

After successful deployment:

- [ ] Update README with new feature
- [ ] Document API integration in ARCHITECTURE.md
- [ ] Create user guide for the feature
- [ ] Document any setup steps (Custom Metadata, Remote Site Settings)
- [ ] Add to ROADMAP as "Completed"

---

## Reference

- **JSON Best Practices**: See `JSON_SERIALIZATION_BEST_PRACTICES.md`
- **Working Example**: `ClaudeAPIService.cls`
- **This Checklist**: `DEPLOYMENT_CHECKLIST_FOR_FUTURE_API_INTEGRATIONS.md`

---

**Use this checklist for**:
- Resume Generator
- Cover Letter Generator
- Interview Prep Assistant
- Any future AI/API integrations

**Status**: ✅ VERIFIED - Follow this pattern for all future deployments

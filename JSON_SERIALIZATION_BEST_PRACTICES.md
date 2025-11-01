# JSON Serialization Best Practices for External APIs

## CRITICAL LESSONS LEARNED - Apply to All Future Deployments

This document captures the **working solution** for JSON serialization when calling external APIs from Salesforce Apex. Use this pattern for **all future API integrations** (Resume Generator, Cover Letter Generator, etc.).

---

## The Problem We Solved

When calling Claude API (or any external REST API), we encountered multiple serialization errors:
1. `"max_tokens: Input should be a valid integer"` - Type coercion issues
2. `"model: Input should be a valid string"` - Type validation failures
3. `"model: Field required"` - Required fields not being sent
4. `"null argument for JSONGenerator.writeStringField()"` - Null handling issues

### Root Causes:
- **`JSON.serialize()` with Maps** - Doesn't reliably preserve type information
- **Complex wrapper classes** - Introduced null handling complexity
- **Overly cautious null checks** - Prevented required fields from being sent
- **Empty string handling** - `JSONGenerator` doesn't accept empty strings

---

## THE WORKING SOLUTION

### Pattern: Direct JSON Building with JSONGenerator

**Use this exact pattern for all external API calls:**

```apex
/**
 * Builds JSON request body for external API
 * Uses JSONGenerator to ensure proper type handling
 */
private static String buildRequestJson(String param1, String param2) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();

    // 1. REQUIRED STRING FIELDS - Always write, never check for null
    gen.writeStringField('model', MODEL_CONSTANT);

    // 2. REQUIRED NUMBER FIELDS - Always write, never check for null
    gen.writeNumberField('max_tokens', MAX_TOKENS_CONSTANT);

    // 3. OPTIONAL STRING FIELDS - Only write if not blank
    if (String.isNotBlank(param1)) {
        gen.writeStringField('optional_field', param1);
    }

    // 4. REQUIRED ARRAYS - Always write, even if empty
    gen.writeFieldName('messages');
    gen.writeStartArray();
    gen.writeStartObject();
    gen.writeStringField('role', 'user');
    gen.writeStringField('content', param2); // ← param2 must be guaranteed non-null
    gen.writeEndObject();
    gen.writeEndArray();

    gen.writeEndObject();
    return gen.getAsString();
}
```

---

## Key Rules - ALWAYS FOLLOW

### Rule 1: Use JSONGenerator for External APIs

❌ **NEVER DO THIS:**
```apex
Map<String, Object> data = new Map<String, Object>();
data.put('model', modelName);
data.put('max_tokens', 4000);
return JSON.serialize(data); // ← Types get lost!
```

✅ **ALWAYS DO THIS:**
```apex
JSONGenerator gen = JSON.createGenerator(true);
gen.writeStartObject();
gen.writeStringField('model', modelName);  // ← Explicit type
gen.writeNumberField('max_tokens', 4000);  // ← Explicit type
gen.writeEndObject();
return gen.getAsString();
```

**Why**: `JSON.serialize()` uses Salesforce's internal type mapping which may not match external API expectations. `JSONGenerator` gives you explicit control over types.

---

### Rule 2: Know Your Required vs Optional Fields

**Read the API documentation** and categorize every field:

**REQUIRED FIELDS** = Always write, never check for null
```apex
// These MUST be present in every request
gen.writeStringField('model', MODEL);           // Required by API
gen.writeNumberField('max_tokens', MAX_TOKENS); // Required by API
```

**OPTIONAL FIELDS** = Only write if present
```apex
// Only include if you have a value
if (String.isNotBlank(systemContext)) {
    gen.writeStringField('system', systemContext);
}
```

**Critical**: If you skip a required field (even with a null check), the API will reject your request!

---

### Rule 3: Never Pass Null or Empty Strings to writeStringField()

`JSONGenerator.writeStringField()` will throw an exception if you pass:
- `null`
- Empty string `""`
- Blank string (whitespace only)

**Wrong Approach** (will crash):
```apex
gen.writeStringField('content', msg.content); // ← Crashes if null!
```

**Wrong Approach** (will crash):
```apex
gen.writeStringField('role', msg.role != null ? msg.role : ''); // ← Crashes on empty string!
```

**Right Approach** (for optional fields):
```apex
if (String.isNotBlank(optionalField)) {
    gen.writeStringField('optional_field', optionalField);
}
```

**Right Approach** (for required fields):
```apex
// Ensure the value is ALWAYS populated before calling this method
gen.writeStringField('content', userPrompt); // userPrompt is guaranteed non-null
```

---

### Rule 4: Keep It Simple - Avoid Complex Wrapper Classes

**Complex Approach** (Error-prone):
```apex
public class ApiRequest {
    public String model;
    public List<Message> messages;

    public String toJson() {
        // Complex logic with loops
        // Multiple null checks needed
        // Easy to introduce bugs
    }
}
```

**Simple Approach** (Reliable):
```apex
private static String buildRequestJson(String context, String prompt) {
    // Build JSON directly
    // Single method, easy to debug
    // Clear what's required vs optional
    JSONGenerator gen = JSON.createGenerator(true);
    // ... build JSON here
    return gen.getAsString();
}
```

**Why**: Wrapper classes add complexity. When you loop over collections or check multiple conditions, you introduce more places where null values can cause issues.

---

### Rule 5: Guarantee Non-Null Values Before JSON Building

**Wrong Approach**:
```apex
String userPrompt = buildPrompt(jobPosting); // Might return null
gen.writeStringField('content', userPrompt); // ← Crash risk!
```

**Right Approach**:
```apex
String userPrompt = buildPrompt(jobPosting);
if (String.isBlank(userPrompt)) {
    throw new ApiException('User prompt cannot be blank');
}
gen.writeStringField('content', userPrompt); // ← Safe, guaranteed non-null
```

**Or even better** - ensure your build methods never return null:
```apex
private static String buildPrompt(Job_Posting__c job) {
    if (job == null) {
        return 'Default prompt text'; // Never return null!
    }
    String prompt = '...';
    return prompt; // Always returns a non-blank string
}
```

---

## Complete Working Example - Claude API

This is the **verified working pattern** from ClaudeAPIService.cls:

```apex
/**
 * Builds JSON request for Claude API
 * Pattern: Direct JSON generation with explicit types
 */
private static String buildRequestJson(String systemContext, String userPrompt) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();

    // REQUIRED FIELDS - Always write (initialized as constants)
    gen.writeStringField('model', MODEL);              // Never null, constant value
    gen.writeNumberField('max_tokens', MAX_TOKENS);    // Never null, constant value

    // OPTIONAL FIELD - Only if not blank
    if (String.isNotBlank(systemContext)) {
        gen.writeStringField('system', systemContext);
    }

    // REQUIRED ARRAY - Always write
    gen.writeFieldName('messages');
    gen.writeStartArray();
    gen.writeStartObject();
    gen.writeStringField('role', 'user');              // Hardcoded, never null
    gen.writeStringField('content', userPrompt);       // Guaranteed non-null by caller
    gen.writeEndObject();
    gen.writeEndArray();

    gen.writeEndObject();
    return gen.getAsString();
}
```

**Why This Works**:
1. ✅ Uses `JSONGenerator` for explicit type control
2. ✅ Required fields always written (model, max_tokens, messages)
3. ✅ Optional fields conditionally written (system)
4. ✅ No null values passed to `writeStringField()`
5. ✅ Simple, linear logic - easy to debug

**Generated JSON**:
```json
{
  "model": "claude-3-haiku-20240307",
  "max_tokens": 4000,
  "system": "You are a helpful assistant",
  "messages": [
    {
      "role": "user",
      "content": "Analyze this job posting..."
    }
  ]
}
```

---

## Apply This Pattern to Future Integrations

### Resume Generator API Call

When you build the Resume Generator, use this same pattern:

```apex
private static String buildResumeRequestJson(Master_Resume__c resume, Job_Posting__c job) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();

    // Required fields
    gen.writeStringField('model', MODEL);
    gen.writeNumberField('max_tokens', MAX_TOKENS);

    // Build the prompt
    String prompt = buildResumePrompt(resume, job); // Ensure this never returns null!

    // Required messages
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
```

### Cover Letter Generator API Call

```apex
private static String buildCoverLetterRequestJson(String context, Job_Posting__c job) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();

    gen.writeStringField('model', MODEL);
    gen.writeNumberField('max_tokens', MAX_TOKENS);

    String prompt = buildCoverLetterPrompt(context, job);

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
```

---

## Debugging Checklist

If you encounter JSON serialization errors with external APIs:

### 1. Check the Error Message

| Error | Cause | Fix |
|-------|-------|-----|
| `"field: Input should be a valid string"` | Using `JSON.serialize()` or wrong type method | Use `gen.writeStringField()` |
| `"field: Input should be a valid integer"` | Using `JSON.serialize()` or wrong type method | Use `gen.writeNumberField()` |
| `"field: Field required"` | Null check preventing required field | Remove null check for required fields |
| `"null argument for JSONGenerator"` | Passing null/empty to write method | Add null check or guarantee non-null |

### 2. Verify Your JSON Structure

Add this debug line:
```apex
String requestBody = buildRequestJson(context, prompt);
System.debug('REQUEST JSON: ' + requestBody);
```

Check:
- ✅ All required fields present
- ✅ Correct data types (strings in quotes, numbers without quotes)
- ✅ Proper array syntax
- ✅ No null values

### 3. Compare to API Documentation

Get the **exact** JSON structure from the API docs and match it field-by-field.

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Using JSON.serialize()
```apex
// DON'T DO THIS for external APIs
Map<String, Object> request = new Map<String, Object>();
request.put('model', MODEL);
return JSON.serialize(request);
```

### ❌ Mistake 2: Null Checking Required Fields
```apex
// DON'T DO THIS - model is required!
if (String.isNotBlank(this.model)) {
    gen.writeStringField('model', this.model);
}
```

### ❌ Mistake 3: Passing Empty String as Default
```apex
// DON'T DO THIS - writeStringField rejects empty strings
gen.writeStringField('content', msg.content != null ? msg.content : '');
```

### ❌ Mistake 4: Complex Wrapper Classes with Loops
```apex
// DON'T DO THIS - too complex, error-prone
for (Message msg : this.messages) {
    if (String.isNotBlank(msg.content)) { // What if content is null?
        gen.writeStringField('content', msg.content);
    }
}
```

---

## Summary - The Golden Rules

1. ✅ **Use `JSONGenerator`** for all external API calls
2. ✅ **Always write required fields** (no null checks)
3. ✅ **Conditionally write optional fields** (with `isNotBlank()` check)
4. ✅ **Never pass null or empty strings** to `writeStringField()`
5. ✅ **Keep it simple** - build JSON directly, avoid complex wrappers
6. ✅ **Guarantee non-null values** before calling write methods
7. ✅ **Use explicit type methods**: `writeStringField()`, `writeNumberField()`, `writeBooleanField()`

---

## Reference Files

- **Working Example**: [ClaudeAPIService.cls:178-210](force-app/main/default/classes/ClaudeAPIService.cls#L178-L210)
- **Verified Pattern**: `COMPLETE_FIXED_ClaudeAPIService.txt` (yesterday's working version)
- **This Document**: `JSON_SERIALIZATION_BEST_PRACTICES.md`

**Use this pattern for**:
- ✅ Resume Generator API calls
- ✅ Cover Letter Generator API calls
- ✅ Any future Claude AI integrations
- ✅ Any external REST API that requires specific JSON types

---

**Last Updated**: 2025-10-30
**Status**: ✅ VERIFIED WORKING - Deploy this pattern to all future integrations

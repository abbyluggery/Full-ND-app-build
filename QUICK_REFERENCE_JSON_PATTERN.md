# Quick Reference - JSON Serialization Pattern

## Copy-Paste Template for New API Integrations

```apex
/**
 * Builds JSON request for external API
 * Pattern: Direct JSONGenerator with explicit types
 */
private static String buildRequestJson(String context, String prompt) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();

    // REQUIRED STRING FIELDS - Always write (use constants)
    gen.writeStringField('model', MODEL_CONSTANT);

    // REQUIRED NUMBER FIELDS - Always write (use constants)
    gen.writeNumberField('max_tokens', MAX_TOKENS_CONSTANT);

    // OPTIONAL STRING FIELDS - Only write if not blank
    if (String.isNotBlank(context)) {
        gen.writeStringField('optional_field', context);
    }

    // REQUIRED ARRAY - Always write
    gen.writeFieldName('array_field');
    gen.writeStartArray();
    gen.writeStartObject();
    gen.writeStringField('role', 'user');
    gen.writeStringField('content', prompt); // ← Must be guaranteed non-null
    gen.writeEndObject();
    gen.writeEndArray();

    gen.writeEndObject();
    return gen.getAsString();
}
```

---

## The Golden Rules

1. ✅ Use `JSONGenerator` (NOT `JSON.serialize()`)
2. ✅ Always write required fields (no null checks)
3. ✅ Conditionally write optional fields (`isNotBlank()` check)
4. ✅ Never pass null to `writeStringField()`
5. ✅ Keep it simple (no wrapper classes)
6. ✅ Guarantee non-null inputs
7. ✅ Use explicit type methods

---

## Type Methods

| Apex Type | JSONGenerator Method |
|-----------|---------------------|
| String | `writeStringField(name, value)` |
| Integer/Long | `writeNumberField(name, value)` |
| Decimal/Double | `writeNumberField(name, value)` |
| Boolean | `writeBooleanField(name, value)` |
| Date/DateTime | `writeStringField(name, value.format())` |
| Array | `writeFieldName(name)` + `writeStartArray()` |
| Object | `writeFieldName(name)` + `writeStartObject()` |

---

## Common Mistakes

| ❌ Don't Do This | ✅ Do This Instead |
|----------------|-------------------|
| `JSON.serialize(mapObject)` | `JSONGenerator` with explicit types |
| Null-check required fields | Always write required fields |
| `writeStringField('x', value != null ? value : '')` | Check `isNotBlank()` before writing |
| Complex wrapper classes | Direct JSON building |
| Loops over message arrays | Hardcoded message structure |

---

## Error Debugging

| Error Message | Fix |
|---------------|-----|
| "field: Input should be a valid string" | Use `writeStringField()` |
| "field: Input should be a valid integer" | Use `writeNumberField()` |
| "field: Field required" | Don't null-check, always write |
| "null argument for JSONGenerator" | Check `isNotBlank()` first |

---

## Full Working Example

See: `ClaudeAPIService.cls` lines 186-210

```apex
private static String buildRequestJson(String systemContext, String userPrompt) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();

    gen.writeStringField('model', MODEL);
    gen.writeNumberField('max_tokens', MAX_TOKENS);

    if (String.isNotBlank(systemContext)) {
        gen.writeStringField('system', systemContext);
    }

    gen.writeFieldName('messages');
    gen.writeStartArray();
    gen.writeStartObject();
    gen.writeStringField('role', 'user');
    gen.writeStringField('content', userPrompt);
    gen.writeEndObject();
    gen.writeEndArray();

    gen.writeEndObject();
    return gen.getAsString();
}
```

---

## For Detailed Information

- **Pattern Details**: `JSON_SERIALIZATION_BEST_PRACTICES.md`
- **Deployment Steps**: `DEPLOYMENT_CHECKLIST_FOR_FUTURE_API_INTEGRATIONS.md`
- **Full Debug History**: `COMPLETE_DEBUGGING_SESSION_SUMMARY.md`

**Status**: ✅ VERIFIED WORKING - Use this pattern for all API integrations

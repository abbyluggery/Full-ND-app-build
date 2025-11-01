# Deploy Fix Via Developer Console

The CLI is having issues. Let's deploy directly through Salesforce UI:

## Step 1: Open Developer Console

1. Go to your Salesforce org
2. Click the gear icon → Developer Console

## Step 2: Open ClaudeAPIService

1. File → Open → Classes → ClaudeAPIService
2. **Replace the entire `toJson()` method** (lines 47-64) with this:

```apex
        // Custom JSON serialization using JSONGenerator
        public String toJson() {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();

            // Write model and max_tokens
            gen.writeStringField('model', this.model);
            gen.writeNumberField('max_tokens', this.max_tokens);

            // Write system prompt if present
            if (!this.systemPrompts.isEmpty()) {
                gen.writeStringField('system', this.systemPrompts[0]);
            }

            // Write messages array
            gen.writeFieldName('messages');
            gen.writeStartArray();
            for (Message msg : this.messages) {
                gen.writeStartObject();
                gen.writeStringField('role', msg.role);
                gen.writeStringField('content', msg.content);
                gen.writeEndObject();
            }
            gen.writeEndArray();

            gen.writeEndObject();
            return gen.getAsString();
        }
```

## Step 3: Save

1. File → Save (or Ctrl+S)
2. Wait for "Saved successfully" message

##  Step 4: Test Again

Run the debug test from DEBUG_API_CALL.md to see if it works now!

---

**Why this fixes it:** The previous JSON serialization was setting `model` and `max_tokens` to `null`. This manual string building ensures they have the correct values.

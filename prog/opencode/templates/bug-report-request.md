# Bug Analysis Request

Fill in this template when invoking `@.opencode/agent/bug-reporter`.

---

**Feature:** {feature-id}
**Feature Name:** {feature-name}
**Trigger:** {exhausted_test_fixes | exhausted_review_rework | on_demand}

## Expected Behavior

{What should happen - from spec acceptance criteria}

## Actual Behavior

{What's happening instead}

## Symptoms

- Error message: {error text if any}
- Test output: {test output if applicable}
- Unexpected output: {what was returned/produced}

## Reproduction

- Reproducible: {always | sometimes | unknown}
- Conditions: {when does it fail}
- Test command: {command to run tests}

## Attempt History (if applicable)

### Attempt 1
- What was tried: {description}
- Result: {what happened}

### Attempt 2
- What was tried: {description}
- Result: {what happened}

## Files Involved

- {file-1} - {what it does}
- {file-2} - {what it does}

## Contracts

**Inputs:**
- {input-1}: {type} - {what it should be}

**Outputs:**
- {output-1}: {type} - {what it should be}

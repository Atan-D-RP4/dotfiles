# {project-name} Technical Specification

Fill in this template when creating a spec with `@.opencode/agent/spec-agent`.

---

**Brief:** {path-to-brief}
**Created:** {date}
**Status:** Draft | Approved
**Compliance Score:** {X}%

## Executive Summary

{2-3 sentences: what this project does, why it exists, key constraints}

## Data Contracts

### Inputs

| Source | Data | Type | Notes |
|--------|------|------|-------|
| {upstream-system-1} | {data-name} | {type} | {constraints, format} |
| {upstream-system-2} | {data-name} | {type} | {constraints, format} |

### Outputs

| Consumer | Data | Type | Notes |
|----------|------|------|-------|
| {downstream-system-1} | {data-name} | {type} | {constraints, format} |
| {downstream-system-2} | {data-name} | {type} | {constraints, format} |

### Interface Constraints

What CAN'T change without breaking consumers.

- {constraint-1}
- {constraint-2}

### Scope Classification

**Classification:** GREENFIELD | BROWNFIELD

{Justification for classification}

## Technical Design

### Architecture

{High-level architecture description}

### Data Models

{Key data structures, schemas, types}

### State Machines / Workflows

{State transitions, workflow steps if applicable}

### Integration Points

| System | Direction | Protocol | Purpose |
|--------|-----------|----------|---------|
| {system-1} | in/out/both | {REST/gRPC/etc} | {what it does} |

## Features

### Feature: {feature-id} - {feature-name}

**Brief Reference:** {section in brief}
**Phase:** {N}
**Complexity:** S | M | L
**Dependencies:** {features that must exist first, or "None"}

**Acceptance Criteria:**

```
GIVEN {precondition/context}
WHEN {action/trigger}
THEN {expected outcome}
AND {additional outcome}
```

```
GIVEN {precondition/context}
WHEN {action/trigger}
THEN {expected outcome}
```

**Edge Cases:**

- {edge-case-1}: {expected behavior}
- {edge-case-2}: {expected behavior}

**Negative Criteria (what should NOT happen):**

- {negative-1}
- {negative-2}

---

{Repeat Feature section for each feature}

## Implementation Phases

### Phase 1: {phase-name}

**Goal:** {what's achieved when this phase is complete}

**Features:**
- {feature-id-1}: {feature-name}
- {feature-id-2}: {feature-name}

**Done Criteria:**
- [ ] {how to verify phase is complete}
- [ ] {how to verify phase is complete}

---

{Repeat Phase section for each phase}

## Dependency Graph

```
{feature-1} --> {feature-2} --> {feature-3}
                            \-> {feature-4}
```

## Test Strategy

### Unit Tests

| Feature | Test Case | Input | Expected Output |
|---------|-----------|-------|-----------------|
| {feature-id} | {test-name} | {input} | {output} |

### Integration Tests

| Feature | Test Case | Systems | Expected Behavior |
|---------|-----------|---------|-------------------|
| {feature-id} | {test-name} | {systems involved} | {behavior} |

### Acceptance Tests

| Criterion | Test Case | Verification Method |
|-----------|-----------|---------------------|
| {from success criteria} | {test-name} | {how to verify} |

### Fixtures Needed

- {fixture-1}: {purpose}
- {fixture-2}: {purpose}

### Coverage Targets

| Feature | Target | Notes |
|---------|--------|-------|
| {feature-id} | {X}% | {any exclusions} |

## Pseudocode

### {component/algorithm name}

```
FUNCTION {name}({params}):
    {step-1}
    {step-2}
    IF {condition}:
        {step-3}
    RETURN {result}
```

### State Transitions

| Current State | Event | Next State | Actions |
|---------------|-------|------------|---------|
| {state-1} | {event} | {state-2} | {what happens} |

### Error Handling

| Error Condition | Detection | Response |
|-----------------|-----------|----------|
| {error-1} | {how detected} | {what to do} |

## Brief Compliance

### Coverage Matrix

| Brief Requirement | Spec Section | Status |
|-------------------|--------------|--------|
| {requirement-1} | {section ref} | Covered | Partial | Missing |
| {requirement-2} | {section ref} | Covered | Partial | Missing |

**Coverage:** {X}% ({Y} of {Z} requirements)

### Scope Creep Check

**Additions not in brief:** None | {list of additions with justification}

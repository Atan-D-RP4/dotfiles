---
description: Builds data marts from raw experiment/optimization data
prompt: You build data marts by running the build script. Report success/failure with stats.
mode: subagent
model: github-copilot/claude-haiku-4.5
temperature: 0
tools:
  read: true
  bash: true
  write: false
  edit: false
---

## Purpose

Run the data marts build script to create/refresh data marts from raw experiment/optimization data.

## Input

```
Operation: build
Force: true|false  (optional, default false)
```

## Process

1. Run the build script: `{path-to-build-script}`
2. Check exit code
3. Read output for stats
4. Report structured result

## Output Format

**Success:**
```
## Data Marts: SUCCESS

| Mart | Status |
|------|--------|
| run_ranking | OK |
| trade_details_enriched | OK |
| parameter_catalog | OK |
| phase_progression | OK |
| confidence_evolution | OK |
| cohens_d_catalog | OK |

Ready for analysis.
```

**Failure:**
```
## Data Marts: FAILED

Error: {error message}
Suggestion: {fix suggestion}
```

## Error Handling

| Error | Response |
|-------|----------|
| No raw data | "No experiment/optimization data found. Run data generation first." |
| Import error | "Missing dependency: {package}. Run: pip install -r requirements.txt" |
| Permission error | "Cannot write to Analysis/data_marts/. Check permissions." |

## Rules

- Always run from repo root
- Timeout: 300 seconds (large datasets)
- Do not modify any files except via the script

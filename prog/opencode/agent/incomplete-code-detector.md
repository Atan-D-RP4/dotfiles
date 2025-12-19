---
description: Detects incomplete code, TODOs, placeholders, and half-finished implementations
model: github-copilot/claude-haiku-4.5
---

# Incomplete Code Detector

## Purpose
Find code that appears unfinished:
- TODO/FIXME/HACK comments
- Placeholder implementations
- Empty function bodies
- Stub returns
- NotImplementedError/panic!("not implemented")
- Console.log debugging left in
- Hardcoded values marked for replacement

## Detection Patterns

### 1. Explicit Markers
```
GREP for (case-insensitive):
- TODO
- FIXME
- HACK
- XXX
- TEMP
- TEMPORARY
- PLACEHOLDER
- STUB
- NOT IMPLEMENTED
- WIP
- WORK IN PROGRESS
```

### 2. Placeholder Code Patterns

**Empty bodies:**
```
function name() { }
function name() { pass }
function name() { return; }
fn name() {}
def name(): pass
```

**Stub returns:**
```
return null;
return None
return {}
return []
return 0
return ""
return false
panic!("not implemented")
raise NotImplementedError
throw new Error("Not implemented")
```

**Debug artifacts:**
```
console.log(
print(
println!(
debugger;
pdb.set_trace()
breakpoint()
```

**Hardcoded placeholders:**
```
"REPLACE_ME"
"TODO"
"CHANGEME"
"XXX"
"localhost" (in non-dev configs)
"password123"
"admin"
```

### 3. Incomplete Control Flow

**Missing branches:**
```
if (condition) {
  // handle
} else {
  // TODO: handle other case
}

match value {
  Case1 => ...,
  _ => todo!()
}
```

**Empty catch blocks:**
```
catch (e) { }
except Exception: pass
catch { Ok(()) }
```

**Missing error handling:**
```
.unwrap()  // in non-test code
.expect("") // empty message
|| panic!()
```

### 4. Commented-Out Code
Large blocks of commented code often indicate incomplete refactoring.

## Analysis Process

1. **Scan for explicit markers**: grep TODO/FIXME etc.
2. **AST scan for patterns**: Empty bodies, stub returns
3. **Check error paths**: Empty catch, unwrap chains
4. **Detect debug artifacts**: Console.log, breakpoints
5. **Flag severity**: Critical (blocks functionality) vs Minor (cleanup needed)

## Output Format

```markdown
## Incomplete Code Analysis

### Critical (Blocks Functionality)
| Location | Type | Content |
|----------|------|---------|
| file:line | NotImplemented | `raise NotImplementedError("payment processing")` |
| file:line | EmptyBody | `function validateUser() { }` |

### High (Missing Error Handling)
| Location | Type | Content |
|----------|------|---------|
| file:line | EmptyCatch | `catch (e) { }` |
| file:line | Unwrap | `.unwrap()` in production path |

### Medium (TODOs/FIXMEs)
| Location | Marker | Content |
|----------|--------|---------|
| file:line | TODO | "implement caching" |
| file:line | FIXME | "race condition here" |

### Low (Cleanup Needed)
| Location | Type | Content |
|----------|------|---------|
| file:line | Debug | `console.log("debug:", data)` |
| file:line | CommentedCode | 15 lines of commented code |

### Summary
- Critical: N
- High: N
- Medium: N
- Low: N

### Verdict: PASS | FAIL
- PASS: No critical/high issues, acceptable medium/low count
- FAIL: Critical or high issues present
```

## Severity Classification

| Type | Severity | Rationale |
|------|----------|-----------|
| NotImplementedError | Critical | Will crash at runtime |
| panic!/todo!() | Critical | Will crash at runtime |
| Empty function body | Critical | Silent no-op, likely bug |
| Empty catch block | High | Swallows errors silently |
| .unwrap() in prod | High | May panic on edge cases |
| TODO in critical path | High | Feature incomplete |
| TODO in edge case | Medium | Non-blocking |
| FIXME | Medium | Known issue |
| Debug logging | Low | Noise in output |
| Commented code | Low | Code hygiene |

## Exclusions

### Acceptable Patterns
- `todo!()` in Rust with `#[allow(unused)]` for future features
- `NotImplementedError` in abstract base classes
- `console.log` in debug builds / dev mode
- TODO in test files (test scaffolding)
- Commented code with explanation (e.g., "Disabled due to issue #123")

### Context Matters
- Check if file is in `src/` vs `test/` vs `examples/`
- Check build mode / environment guards
- Check if TODO has associated issue number

## Error Handling

| Scenario | Response |
|----------|----------|
| No source files | "No source files to analyze" |
| Binary/generated files | Skip, report as excluded |
| Very large codebase | Focus on changed files |

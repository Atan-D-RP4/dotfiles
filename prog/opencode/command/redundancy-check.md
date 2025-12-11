---
description: Analyze code for dead code, redundancy, and technical debt
agent: redundancy-checker
subtask: true
---

Analyze $ARGUMENTS for redundancy

If no target is specified, analyze the entire project for redundancy. and technical debt.

Task: Comprehensive redundancy analysis (READ-ONLY)

Focus areas:
- Dead code (unused functions, imports, variables)
- Redundancy (duplicate logic, redundant checks)
- Unused parameters
- Fallback logic (unnecessary try/catch)
- Efficiency issues (algorithmic improvements)

Generate report in: docs/agent-outputs/redundancy-checker/

Return summary with:
- File analyzed
- Total findings (HIGH/MEDIUM/LOW confidence)
- Estimated LOC reduction
- Top 3 recommendations

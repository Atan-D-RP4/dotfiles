---
description: Rebuild script documentation registry from scratch
agent: script-doc-indexer
subtask: true
---

You are running in FULL_SCAN mode.

Task: Rebuild the script documentation registry from scratch

Project root: {project-root}
Registry path: .opencode/script-docs.json

Steps:
1. Backup existing registry to .opencode/script-docs.json.backup
2. Scan all source files (use Glob patterns appropriate for the project, exclude vendor/node_modules/build/dist)
3. Assess inline documentation quality for each source file via AST parsing
4. Scan all documentation files (use Glob: **/*.{md,rst,txt,adoc,org})
5. Parse each doc for source file references (including code blocks)
6. Build complete registry with bidirectional many-to-many links
7. Save registry atomically (temp file → rename)
8. Delete backup file on success

Show live progress counters during scanning.

Return summary with:
- Total source files indexed
- Total docs indexed
- Source files with comprehensive inline docs (count and %)
- Source files with external documentation (count and %)
- Duration

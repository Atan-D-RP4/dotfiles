---
description: Remove deleted files from script documentation registry
agent: script-doc-indexer
subtask: true
---

You are running in CLEANUP mode.

Task: Remove stale entries from the script documentation registry

Project root: {project-root}
Registry path: .opencode/script-docs.json

Steps:
1. Load existing registry
2. For each entry in registry['sources']:
   - Check if file exists on disk
   - If NOT exists → Remove from registry
   - Track removed source files
3. For each entry in registry['documents']:
   - Check if file exists on disk
   - If NOT exists → Remove from registry
   - Track removed docs
4. Validate bidirectional links:
   - For each source file's externalDocs → Remove references to deleted docs
   - For each doc's sourcesReferenced → Remove references to deleted source files
5. Save cleaned registry atomically

Return summary with:
- Source files removed (count)
- Docs removed (count)
- Orphaned references cleaned
- Registry integrity status
- Duration

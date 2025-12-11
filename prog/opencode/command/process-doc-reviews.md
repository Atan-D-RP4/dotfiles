---
description: Process documentation review reports and update registry
agent: doc-reviewer
subtask: true
---

Process documentation review reports in: docs/agent-outputs/doc-reviews/

Task: Review recent doc-review reports and update documentation quality status

Steps:
1. Find all review reports in docs/agent-outputs/doc-reviews/
2. Parse each report for quality scores and issues
3. Identify documents needing updates
4. Generate summary of documentation health
5. Recommend priority fixes

Return summary with:
- Total reports processed
- Average quality score
- Documents needing immediate attention
- Top 5 priority fixes

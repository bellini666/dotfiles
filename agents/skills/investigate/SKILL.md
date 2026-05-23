---
name: investigate
description: This skill should be used when the user asks to "investigate", "look into", "triage", "what's causing", or wants research-first analysis of a bug, issue, or failure without applying a fix. Produces a diagnosis, not a code change.
---

# Investigate: Research-First Triage

Research and triage an issue without implementing a fix. Produce a diagnosis, not a solution.

## Input

Accept any combination of:

- A URL (Sentry, GitHub/GitLab issue, CI pipeline)
- An error message or log excerpt
- A description of unexpected behavior

If no input is provided, ask for context.

## Workflow

### Phase 1: Gather (3 min max)

1. If a URL is provided, fetch details via the appropriate CLI (`glab issue view`, `gh issue view`, Sentry MCP)
2. Parse error details: file, function, line, error type
3. Read the relevant source code

### Phase 2: Trace (5 min max)

1. Trace the error path through the code
2. Identify the root cause vs symptoms
3. Check git blame/log for recent changes to the affected area
4. Check if tests exist for this path

### Phase 3: Report

Output a structured triage report:

- **Summary**: one-line description of the issue
- **Root cause**: what is actually wrong and where
- **Evidence**: the specific code/config/data that proves it
- **Affected area**: files and functions involved
- **Suggested fix**: description of what to change (do NOT implement)
- **Risk**: low/medium/high, what else could break
- **Related**: links to similar patterns in the codebase, if any

## Scope Rules

- Do NOT implement any fix
- Do NOT modify any files
- Do NOT run tests (unless needed to reproduce)
- If root cause is unclear after 8 minutes total, say so and list what has been ruled out

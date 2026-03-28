---
name: investigate
description: Research-first triage of a bug, issue, or question. Use when the user says "investigate", "look into", "triage", "what's causing", or wants analysis before a fix.
---

# Investigate Command

## Purpose

Research and triage an issue WITHOUT implementing a fix. Produce a diagnosis, not a solution.

## Input

Accept `$ARGUMENTS` as any combination of:

- A URL (Sentry, GitHub/GitLab issue, CI pipeline)
- An error message or log excerpt
- A description of unexpected behavior

If no arguments provided, ask for context.

## Workflow

### Phase 1: Gather (3 min max)

1. If URL provided: fetch details via appropriate CLI (`glab issue view`, `gh issue view`, Sentry MCP)
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
- **Risk**: low/medium/high — what else could break
- **Related**: links to similar patterns in the codebase, if any

## Scope Rules

- Do NOT implement any fix
- Do NOT modify any files
- Do NOT run tests (unless needed to reproduce)
- If root cause is unclear after 8 minutes total, say so and list what you've ruled out

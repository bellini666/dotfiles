---
name: sentry-fix
description: "Fix a production bug from a Sentry error report. Use when the user provides a Sentry issue URL, Sentry error details, or says 'Sentry error' / 'production error from Sentry'."
---

# Sentry Fix

## Purpose

End-to-end workflow from Sentry error report to tested fix with commit.

## Input

Accept `$ARGUMENTS` as either:

- A Sentry issue URL
- An error description with stack trace

## Workflow

### Phase 1: Diagnose (5 min max)

1. If Sentry MCP is available, pull issue details (stack trace, breadcrumbs, tags)
2. Otherwise, parse error details from user input
3. Identify: file, function, line number, root cause
4. Check if the error path has existing tests

### Phase 2: Reproduce

1. Write a failing test that reproduces the exact scenario from the error
2. Follow the test philosophy from AGENTS.md:
   - Use real input data from the error report
   - Exercise the actual code path (minimal mocking)
   - Assert correct behavior, not the buggy behavior
   - Place in the existing test file for that module
3. Run the test — confirm it fails for the right reason

### Phase 3: Fix

1. Implement the minimal fix addressing root cause
2. Don't refactor, generalize, or "improve" surrounding code

### Phase 4: Validate

1. Run the reproduction test — confirm it passes
2. Run linter + type checker
3. Run the full test suite — no regressions

### Phase 5: Report

1. Suggest commit message referencing the Sentry issue:
   - Format: `fix: <description> (SENTRY-XXXX)` or `fix: <description>` if no issue ID
2. Summarize: root cause, fix applied, test added

## Complex Cases

If diagnosis exceeds 5 minutes or root cause is unclear:

- Use the **systematic-debugging** skill for structured root cause analysis
- Use the **bug-fix** skill as fallback for non-Sentry-specific debugging

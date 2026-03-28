---
name: fix
description: Fix bugs from error reports, Sentry issues, screenshots, logs, or user descriptions. Use when the user says "fix this bug", "Sentry error", "production error", or provides an error report to fix.
---

# Fix Command

## Purpose

End-to-end workflow from error report to tested fix.

## Input

Accept `$ARGUMENTS` as any combination of:

- A Sentry issue URL
- A GitLab issue URL (fetch via `glab issue view`)
- A GitLab CI pipeline failure URL
- A screenshot of an error
- A stack trace or log excerpt
- A description of the issue

If no arguments provided, ask for context about the bug.

## Workflow

### Phase 1: Diagnose (5 min max)

1. If a Sentry URL is provided and Sentry MCP is available, pull issue details (stack trace, breadcrumbs, tags)
2. If a screenshot is provided, analyze it for error messages, stack traces, and UI state
3. Otherwise, parse error details from the provided input
4. Identify: file, function, line number, root cause
5. Check if the error path has existing tests

### Phase 2: Reproduce

1. Write a failing test that reproduces the exact scenario from the error:
   - Use real input data from the error report
   - Exercise the actual code path (minimal mocking)
   - Assert correct behavior, not the buggy behavior
   - Place in the existing test file for that module
   - Follow the project's test style (function vs class)
2. Run the test — confirm it fails for the right reason

### Phase 3: Fix

1. Implement the minimal fix addressing root cause, not symptoms
2. Don't refactor, generalize, or "improve" surrounding code

### Phase 4: Validate

1. Run the reproduction test — confirm it passes
2. Run linter + type checker
3. Run the full test suite — no regressions

### Phase 5: Report

1. Suggest commit message:
   - Format: `fix: <description> (SENTRY-XXXX)` if Sentry issue ID available
   - Format: `fix: <description>` otherwise
2. Summarize: root cause, fix applied, test added

## Type Safety

- Add `assert` guards before accessing Optional values — never assume non-None
- Never add `type: ignore` to silence errors — fix the type issue
- Thread parameters correctly — distinct params get distinct values

## Anti-Patterns

Stop immediately if about to:

- Write a synthetic test that doesn't match the real failure scenario
- Mock the buggy function so the test "passes"
- Skip the reproduction test and go straight to fixing
- Broaden scope — fix only the reported bug, nothing else
- Weaken assertions, bump expected query counts, or make fields Optional

## Complex Bugs

If diagnosis exceeds 5 minutes or root cause is unclear, use the **debugging** skill for structured root cause analysis.

## Integration

- Use **debugging** for complex root cause analysis
- Use **writing-tests** for test patterns and conventions

---
name: bug-fix
description: Fix bugs from error reports (Sentry, logs, user reports). Use when the user says "fix this bug", "Sentry error", "production error", "exception in logs", or provides an error report to fix.
---

# Bug Fix

## Core Principle

Follow the test philosophy from AGENTS.md. Write a failing test that reproduces the real bug before writing any fix.

## Workflow

1. **Read the error report** — full stack trace, input data, context
2. **Timebox investigation** (~5 min) — identify the failing code path
3. **Write a failing test** that reproduces the actual bug:
   - Use real input data from the error report
   - Exercise the actual code path (not mocked)
   - Assert the correct behavior, not the buggy behavior
   - Place in the existing test file for that module
4. **Implement the minimal fix** — address root cause, not symptoms
5. **Verify the test passes** with the fix applied
6. **Run the type checker** — `pyright`, `mypy`, etc.
7. **Run the full test suite** — no regressions

## Test Quality Gate

A reproduction test must satisfy ALL of these:

- Uses real input data (from the error report or realistic equivalent)
- Exercises the actual code path (minimal mocking)
- Has proper assertions (not just "doesn't raise")
- Lives in the existing test file for the affected module
- Follows the project's test style (function vs class)

## Type Safety

- Add `assert` guards before accessing Optional values — never assume non-None
- Never add `type: ignore` to silence errors — fix the type issue
- Thread parameters correctly — distinct params get distinct values

## Anti-Patterns

Stop immediately if you're about to violate rules from AGENTS.md (weakening assertions, adding Optional, bypassing type checks) or:

- **Write a synthetic test** that doesn't match the real failure scenario
- **Mock the buggy function** so the test "passes" — you're testing the mock
- **Skip the reproduction test** and go straight to fixing — you won't know if the fix works
- **Broaden scope** — fix only the reported bug, nothing else

## Complex Bugs

If investigation exceeds the timebox or root cause is unclear:

- Use the **systematic-debugging** skill for structured root cause analysis
- Document what you've found so far before switching approaches

## Integration

- Use **systematic-debugging** for complex root cause analysis
- Use **testing** skill for test patterns and conventions

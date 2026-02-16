---
name: fix-ci
description: Fix CI pipeline failures. Use when the user says "fix CI", "pipeline is failing", "CI is red", "build failed", or needs to resolve test/lint/type-check failures in CI.
---

# Fix CI

## Core Principle

Follow the test philosophy from AGENTS.md — CI failures mean the code is wrong, not the tests or CI config.

## Workflow

1. **Read the failure output** — full error message, stack trace, failing stage
2. **Scope to the failing stage only** — ignore passing stages entirely
3. **Identify the root cause** — trace the error to the source in application code
4. **Fix the code** to satisfy the existing assertions/checks
5. **Run linter + type checker locally** — `ruff check`, `pyright`, etc.
6. **Run the failing tests locally** — verify the fix before pushing

## Config Awareness

Before hardcoding values or adding environment variables:

- Check `pyproject.toml` for project configuration
- Check settings files (`settings.py`, `.env.example`) for existing patterns
- Use config files over env vars when the project already does

## Anti-Patterns

Stop immediately if you're about to:

- **Change test assertions** — the test defines expected behavior
- **Investigate passing stages** — they're irrelevant to the failure
- **Modify CI config** (`.gitlab-ci.yml`, `.github/workflows/`) — unless explicitly asked
- **Add env vars** when config files exist — follow existing config patterns
- **Broaden scope** — "while I'm fixing CI, let me also..." — don't

## Scope Rules

- One failing stage at a time
- Only touch files related to the failure
- If the fix requires changes across 3+ files, confirm with the user
- If you can't reproduce locally, say so — don't guess

## Integration

- Use **systematic-debugging** for complex root cause analysis
- Use **testing** skill patterns when writing reproduction tests

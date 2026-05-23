---
name: review
description: This skill should be used when the user asks to "review my staged changes", "review before commit", "check this diff", or wants a critical pre-commit review of `git diff --cached` against bug, security, test-integrity, and code-quality checks. Reports issues only, no praise.
---

# Review: Staged Changes

Critical review of staged changes before committing.

## Behavior

1. Run `git diff --cached` to get staged changes
2. Review against the checklist below
3. Run linter and type checker on staged files
4. Provide concise, critical feedback, no praise, only issues

## Checklist

### Bugs

- Logic errors, edge cases, null checks
- Off-by-one errors, race conditions
- Incorrect parameter threading (same value for distinct params)

### Test Integrity

- No test expectations weakened (expected counts changed, assertions removed or loosened)
- No required parameters made Optional to silence type errors
- No `type: ignore`, `noqa`, or `# pragma: no cover` added to bypass checks
- If query count assertions exist, verify select_related/prefetch_related added (not count bumped)

### Security

- No hardcoded credentials, API keys, or secrets
- No SQL injection, XSS, CSRF vulnerabilities
- Staged files do not include `.env`, credentials, or generated files

### Quality

- New code matches existing patterns (function vs class tests, import style, config approach)
- No unnecessary abstractions or over-engineering
- No unrelated changes bundled in

### Performance

- N+1 queries addressed with select_related/prefetch_related
- No inefficient algorithms where simpler solutions exist

### Linter & Types

- Run ruff/pyright (or project equivalent) on changed files
- Report any new errors introduced by the staged changes

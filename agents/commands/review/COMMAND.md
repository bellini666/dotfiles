---
name: review
description: Review staged git changes
template: Review my staged changes. Be critical and concise. Focus on bugs, security issues, code quality, and anti-patterns from AGENTS.md.
---

# Review Command

## Purpose

Critical review of staged changes before committing.

## Usage

```
/review
```

## Behavior

1. Run `git diff --cached` to get staged changes
2. Review against the checklist below
3. Run linter and type checker on staged files
4. Provide concise, critical feedback — no praise, only issues

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
- Staged files don't include `.env`, credentials, or generated files

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

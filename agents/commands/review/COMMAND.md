---
name: review
description: Review staged git changes
template: Review my staged changes. Be critical and concise. Focus on bugs, security issues, and code quality.
---

# Review Command

## Purpose

Critical review of staged changes before committing.

## Usage

```
/review
```

## Behavior

- Analyzes all staged git changes
- Identifies bugs and potential issues
- Checks for security vulnerabilities
- Evaluates code quality
- Provides concise, critical feedback

## Focus Areas

1. **Bugs**: Logic errors, edge cases, null checks
2. **Security**: SQL injection, XSS, CSRF, auth issues
3. **Quality**: Duplicated code, complexity, naming
4. **Performance**: N+1 queries, inefficient algorithms

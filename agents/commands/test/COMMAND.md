---
name: test
description: Run tests and fix failures
template: Run tests for $ARGUMENTS. Detect if the project uses poetry or uv and run pytest accordingly. Report failures and propose fixes.
---

# Test Command

## Purpose

Execute project tests, analyze failures, and propose fixes.

## Usage

```
# Run all tests
/test

# Run specific test file
/test src/tests/auth_test.py

# Run tests matching pattern
/test -k "test_login"
```

## Behavior

- Detects project's package manager (poetry or uv)
- Runs pytest with appropriate configuration
- Reports test failures with context
- Analyzes root causes and proposes fixes
- Applies fixes after confirmation and re-runs tests

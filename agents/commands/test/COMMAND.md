---
name: test
description: Run tests and fix failures
template: Run tests for $ARGUMENTS. Detect the project environment and package manager, then run pytest accordingly. Report failures and fix the source code.
---

# Test Command

## Purpose

Execute project tests, analyze failures, and fix source code.

## Usage

```
# Run all tests
/test

# Run specific test file
/test src/tests/auth_test.py

# Run tests matching pattern
/test -k "test_login"
```

## Environment Detection

Before running tests, detect the environment:

1. **Package manager check**:
   - `[tool.poetry]` in pyproject.toml → `poetry run pytest`
   - `uv.lock` exists → `uv run pytest`
   - Neither → `pytest` directly
2. **Test config**: Check pyproject.toml `[tool.pytest.ini_options]` or `pytest.ini` for default flags

## Behavior

1. Detect environment and package manager as above
2. Run pytest with `$ARGUMENTS` as test path/filter (or all tests if empty)
3. On failure:
   - Read the failing test to understand its intent — the test is the spec
   - Identify the root cause in the source code
   - Fix the source code, NOT the test expectations
   - NEVER weaken assertions, bump expected query counts, or make fields Optional
   - If test expects N queries, fix N+1 with select_related/prefetch_related
4. Run linter + type checker after fixes
5. Re-run the failing tests to confirm the fix
6. Report summary: X passed, Y fixed, Z still failing

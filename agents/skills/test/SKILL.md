---
name: test
description: This skill should be used when the user asks to "run the tests", "run pytest", "test this", "check if tests pass", "fix the failing tests", or wants the project test suite executed with environment auto-detection (poetry, uv, pip) and failing tests fixed at the source rather than by weakening assertions.
---

# Test: Run and Fix

Execute project tests, analyze failures, and fix source code (never the test).

## Usage Patterns

- Run all tests: invoke with no arguments
- Run a specific test file: invoke with the path, e.g. `src/tests/auth_test.py`
- Run tests matching a pattern: invoke with `-k "test_login"`

## Environment Detection

Before running tests, detect the environment:

1. **Package manager check**:
   - `[tool.poetry]` in pyproject.toml → `poetry run pytest`
   - `uv.lock` exists → `uv run pytest`
   - Neither → `pytest` directly
2. **Test config**: Check pyproject.toml `[tool.pytest.ini_options]` or `pytest.ini` for default flags

## Behavior

1. Detect environment and package manager as above
2. Run pytest with arguments as test path/filter (or all tests if empty)
3. On failure:
   - Read the failing test to understand its intent, the test is the spec
   - Identify the root cause in the source code
   - Fix the source code, NOT the test expectations
   - Never weaken assertions, bump expected query counts, or make fields Optional
   - If a test expects N queries, fix N+1 with select_related/prefetch_related
4. Run linter + type checker after fixes
5. Re-run the failing tests to confirm the fix
6. Report summary: X passed, Y fixed, Z still failing

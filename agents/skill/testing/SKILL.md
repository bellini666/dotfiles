---
name: testing
description: This skill should be used when the user asks to "write tests", "add tests", "create test cases", "fix failing tests", or when implementing tests as part of a feature or bug fix task.
---

# Writing Tests

## Test Philosophy

- **Tests are the spec** — if a test fails, the code under test is wrong. Never change assertions to make tests pass.
- **Reproduce real bugs** — use actual input data and real code paths. Avoid synthetic mocks that just mirror the implementation.
- **Match test style** — detect whether the project uses function-based or class-based tests and follow that pattern exactly.

## Rules

1. **Reuse test files** - Add tests to existing files when appropriate
2. **Use parametrized tests** - Group cases with same expected behavior via `@pytest.mark.parametrize`
3. **No obvious comments** - Code should be self-explanatory
4. **Follow existing style** - Match patterns in the existing test suite
5. **Imports at module level** - Only import inside functions when absolutely necessary
6. **Reuse fixtures** - Use existing fixtures; create new ones only when needed
7. **Detect project test style** - Examine existing tests to determine function vs class style; match it
8. **Place helpers correctly** - Put shared helpers in existing `conftest.py` or test helper locations

## Test Naming

Name tests using the pattern: `test_<what>_<condition>_<outcome>`

Examples:

- `test_login_valid_credentials_succeeds`
- `test_process_payment_insufficient_funds_raises_error`
- `test_parse_json_invalid_input_returns_none`

## Test Structure

1. **Test all paths** - Happy path, edge cases, and error conditions
2. **One assertion focus** - Each test should verify one specific behavior
3. **Arrange-Act-Assert** - Set up, execute, verify (AAA pattern)

## Common Pytest Features

- **Fixtures**: `@pytest.fixture` for shared setup/teardown
- **Marks**: `@pytest.mark.skip`, `@pytest.mark.slow`, `@pytest.mark.integration`
- **Mocking**: `monkeypatch` fixture for patching
- **Temp files**: `tmp_path` fixture for file system tests
- **Assertions**: Use `pytest.raises(ExceptionType)` for exception testing

## Red Flags

Stop immediately if you catch yourself doing any of these:

- "Adjust the assertion to match the new behavior" — the test is the spec, fix the code
- "Add `Optional` so the test passes" — find the real source of `None`
- "Mock returns the expected value so the test passes" — you're testing the mock, not the code
- "Change test data to avoid the error" — the error is what you should be fixing

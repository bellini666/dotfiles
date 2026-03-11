---
name: writing-tests
description: "This skill should be used when the user asks to 'write tests', 'add tests', 'create test cases', 'cover this with tests', 'unit tests', 'integration tests', 'test coverage', 'test this function', 'fix failing tests', or when implementing tests as part of a feature or bug fix task."
---

# Writing Tests

## Test Philosophy

These principles are non-negotiable:

- **Tests are the spec** — if a test fails, the code is wrong, not the test (unless actively refactoring the tested code)
- **Never weaken assertions** — do not change test expectations to make them pass; fix the code under test
- **Real inputs over synthetic mocks** — write reproduction tests using real inputs and actual code paths, not synthetic mocks that mirror implementation
- **Failing test = your code is wrong** — the main branch is always green. If a test fails, your changes caused it, even if you didn't touch that test directly. Find the connection and fix it.
- **Never make fields Optional to silence type errors** — find the real source of the None
- **Never bump expected query counts** — if a test expects N queries, fix the N+1 with `select_related`/`prefetch_related`

These rules apply regardless of language or framework. The examples below use pytest, but the principles are universal.

## Discovery: Before Writing a Single Test

Before writing any test, spend 2 minutes understanding how the codebase already tests things:

1. **Find the test directory** — look for `tests/`, `test/`, `__tests__/`, or `spec/` directories
2. **Read 2-3 existing test files** — note the style (function vs class, fixtures vs setup methods, assertion style)
3. **Check for conftest.py / test helpers** — identify reusable fixtures, factories, and utilities
4. **Check the test runner config** — look at `pyproject.toml`, `pytest.ini`, `setup.cfg`, or `jest.config` for custom markers, plugins, and conventions
5. **Match what you find** — do not invent a new testing style when the project has an established one

```bash
# Quick discovery commands
find . -name "conftest.py" -type f       # Find all conftest files
grep -r "def test_" tests/ | head -20    # See naming patterns
grep -r "@pytest.fixture" tests/ | head  # Find existing fixtures
```

## Rules

1. **Reuse test files** — add tests to existing files when testing the same module or feature
2. **Use parametrized tests** — group cases with same logic but different inputs via parametrize
3. **No obvious comments** — code should be self-explanatory
4. **Follow existing style** — match patterns in the existing test suite exactly
5. **Imports at module level always** — never import inside test functions. The only valid exceptions are: testing import errors, testing lazy import behavior, or when the test semantically depends on the import happening at that point. "Convenience" or "keeping imports close to usage" are not valid reasons.
6. **Reuse fixtures** — use existing fixtures; create new ones only when needed
7. **Detect project test style** — examine existing tests to determine function vs class style; match it
8. **Place helpers correctly** — put shared helpers in existing `conftest.py` or test helper locations

## Test Naming

Name tests using the pattern: `test_<what>_<condition>_<outcome>`

The name should read as a sentence describing the behavior being verified:

```python
# Good: descriptive, reads naturally
def test_login_with_valid_credentials_returns_token():
    user = create_user(email="test@example.com", password="secure123")
    response = client.post("/login", json={"email": user.email, "password": "secure123"})
    assert response.status_code == 200
    assert "token" in response.json()

def test_login_with_wrong_password_returns_401():
    user = create_user(email="test@example.com", password="secure123")
    response = client.post("/login", json={"email": user.email, "password": "wrong"})
    assert response.status_code == 401

# Bad: vague, doesn't describe behavior
def test_login():
    ...

def test_login_error():
    ...
```

## Test Structure: Arrange-Act-Assert

Every test follows the AAA pattern. Use blank lines to separate the three sections — do NOT add `# Arrange`, `# Act`, `# Assert` comments. The structure should be self-evident from the whitespace:

```python
def test_order_with_multiple_items_calculates_total():
    order = Order()
    widget = Item("Widget", price=10.00)
    gadget = Item("Gadget", price=25.00)

    order.add_item(widget)
    order.add_item(gadget)

    assert order.total == 35.00
```

Only add comments when something non-obvious needs explanation (e.g., why a specific value was chosen, why setup is unusual):

```python
def test_rate_limiter_allows_request_after_window_expires():
    limiter = RateLimiter(max_requests=2, window_seconds=60)
    limiter.record("user-1")
    limiter.record("user-1")

    # Advance past the rate limit window
    freeze_time(seconds=61)

    assert limiter.allow("user-1") is True
```

Each test verifies one specific behavior. If you need two unrelated assertions, write two tests.

## Parametrized Tests

When multiple test cases share the same logic but differ in inputs and expected outputs, use parametrize instead of writing N near-identical test functions:

```python
import pytest

@pytest.mark.parametrize(
    "input_str, expected",
    [
        ("hello world", "Hello World"),
        ("ALREADY CAPS", "Already Caps"),
        ("", ""),
        ("single", "Single"),
        ("multiple   spaces", "Multiple   Spaces"),
    ],
)
def test_title_case_conversion(input_str, expected):
    assert to_title_case(input_str) == expected


@pytest.mark.parametrize(
    "amount, currency, expected_error",
    [
        (-1, "USD", "Amount must be positive"),
        (0, "USD", "Amount must be positive"),
        (100, "INVALID", "Unsupported currency"),
    ],
    ids=["negative-amount", "zero-amount", "invalid-currency"],
)
def test_payment_with_invalid_input_raises(amount, currency, expected_error):
    with pytest.raises(ValidationError, match=expected_error):
        process_payment(amount=amount, currency=currency)
```

Use the `ids` parameter when the parametrize values alone don't make test output readable.

## Fixtures

Use fixtures to share setup logic. Prefer narrowly-scoped fixtures and compose them:

```python
@pytest.fixture
def active_user(db):
    return UserFactory(is_active=True)


@pytest.fixture
def authenticated_client(client, active_user):
    client.force_authenticate(user=active_user)
    return client


def test_dashboard_returns_user_data(authenticated_client, active_user):
    response = authenticated_client.get("/dashboard/")
    assert response.status_code == 200
    assert response.json()["email"] == active_user.email
```

Guidelines for fixtures:

- Check `conftest.py` files before creating new fixtures — the fixture you need may already exist
- Place fixtures used by multiple test files in `conftest.py`
- Place fixtures used by one file in that file
- Use `autouse=True` sparingly — only when every test in scope needs the setup
- Prefer factory fixtures (functions that return objects) over static fixtures when tests need variations

## Common Pytest Features

- **Exception testing**: `with pytest.raises(ValueError, match="invalid"):`
- **Marks**: `@pytest.mark.slow`, `@pytest.mark.integration`, `@pytest.mark.skip(reason="...")`
- **Monkeypatching**: `monkeypatch.setattr(module, "func", mock_func)` for patching
- **Temp files**: `tmp_path` fixture for file system tests
- **Capsys**: `capsys.readouterr()` for testing stdout/stderr output
- **Freezing time**: use `freezegun` or `time_machine` if the project has it; check existing test patterns

## Test Coverage Priorities

When adding tests to existing code, prioritize in this order:

1. **Happy path** — the primary intended behavior works
2. **Error conditions** — invalid input, missing data, permission denied
3. **Edge cases** — empty collections, boundary values, unicode, None where unexpected
4. **Integration points** — database queries, API calls, file I/O

Do not aim for 100% line coverage at the expense of meaningful tests. One well-designed parametrized test is worth more than five trivial ones.

## Red Flags

Stop immediately if about to:

- **Weaken an assertion** to make a test pass — fix the code instead
- **Add `Optional` to silence a type error** in test setup — find the real source of None
- **Mock away the code under test** — mocking should isolate dependencies, not replace the system under test
- **Copy-paste a test with minor changes** — use parametrize instead
- **Write a test that can never fail** — if the test passes regardless of implementation, it tests nothing
- **Ignore a failing test as "pre-existing"** — main is green, so your changes caused it
- **Bump expected query counts** — fix the N+1 query, don't adjust the assertion

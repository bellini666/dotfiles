---
name: testing
description: This skill should be used when the user asks to "write tests", "add tests", "create test cases", or when implementing tests as part of a feature or bug fix task.
---

# Writing Tests

## Rules

1. **Reuse test files** - Add tests to existing files when appropriate
2. **Use parametrized tests** - Group cases with same expected behavior via `@pytest.mark.parametrize`
3. **No obvious comments** - Code should be self-explanatory
4. **Follow existing style** - Match patterns in the existing test suite
5. **Imports at module level** - Only import inside functions when absolutely necessary
6. **Reuse fixtures** - Use existing fixtures; create new ones only when needed

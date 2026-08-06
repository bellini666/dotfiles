---
name: selfreview
description: This skill should be used when the user asks to "self review", "review my changes", "review this diff", "check this before I commit", or "review your own work", and proactively before committing any non-trivial diff. Runs four parallel review passes over the branch diff — correctness, regressions, performance, and over-engineering.
---

# Self Review

Adversarial pass over your own diff before the user sees it.

## Behavior

1. Detect base branch (main or master), get the diff with `git diff <base>...HEAD`
2. State the intended change in one sentence — reviewer 1 needs it, reviewers 2-4 do not
3. Spawn the four reviewers below **in parallel**, one agent each
4. Collect findings into one table, fix everything ranked BLOCKER, then report

Skip this for docs-only, config-only, or single-line diffs.

## Reviewer 1: Correctness

Given the stated intent, does the diff actually do it?

- Reconstruct what the code does from the code alone, then compare against the stated intent. Where they diverge, the code is the bug.
- Walk the edge cases: empty input, null, zero, boundary values, concurrent callers, the retry path.
- Error handling — is anything swallowed, and does a failure mid-way leave partial state behind?
- Transaction and lock ordering: a commit outside the lock protecting its rows is a race; two paths taking locks in opposite orders deadlock.
- Are parameters threaded correctly — no semantically distinct params receiving the same value?

## Reviewer 2: Regressions

What working behavior does this break?

- Find every existing caller of each changed function or endpoint. Does the new behavior still satisfy them?
- Changed signatures, return types, or exception types that callers depend on.
- Queryset `.update()`/`.delete()`/`bulk_*` introduced where per-object behavior was expected — these bypass `save()`, signals, audit history, and per-object task dispatch.
- Model changes without a matching migration.
- Side effects that must not fire on rollback, now firing mid-transaction instead of via `on_commit`.
- Test quality: for each new test, would it fail if the fix were reverted? Reason it through. A test that passes either way guards nothing, and the regression is unprotected. Flag anything asserting nothing, or only that a mock was called.

## Reviewer 3: Performance

- N+1 queries — a loop touching a related object without `select_related`/`prefetch_related`.
- Unbounded work: unbounded querysets, `bulk_create` without batching, loops over unbounded input.
- Query counts that went up, and whether any `assertNumQueries` expectation was raised rather than fixed.
- Work done inside a lock or transaction that could be done outside it.
- Missing indexes for new filter/order columns.

## Reviewer 4: Over-engineering

Invoke the `ponytail-review` skill against the same diff. It hunts what to delete: reinvented stdlib, unneeded dependencies, abstractions with one implementation, config for values that never change, flexibility nobody asked for.

## Output

One table, most severe first:

| Severity | File:line | Finding | Reviewer |
| -------- | --------- | ------- | -------- |

Severity is BLOCKER (ships a bug), WARN (works but violates a convention), or NIT.
Every finding cites `file:line`. Anything a reviewer is unsure about gets stated as unsure, not dropped and not inflated.

Report the table before committing anything. If all four come back clean, say so in one line.

## Integration

- Use **writing-tests** for the conventions Reviewer 2 checks tests against
- Use **django** for the full ORM checklist Reviewers 2 and 3 draw from

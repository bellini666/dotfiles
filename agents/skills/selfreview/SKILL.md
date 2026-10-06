---
name: selfreview
description: This skill should be used when the user asks to "self review", "review my changes", "review this diff", "check this before I commit", or "review your own work", and proactively before committing any non-trivial diff. Runs three parallel review passes over the branch diff (correctness, blast radius, deletions) and verifies findings before fixing.
---

# Self Review

Adversarial pass over your own diff before the user sees it.

## Behavior

1. Detect base branch (main or master) and take `git merge-base <base> HEAD`. Write `git diff <merge-base>` (commits plus staged and unstaged changes) and the contents of untracked files from `git ls-files --others --exclude-standard` into one file in the scratchpad. Reviewers read that file.
2. State the intended change in one sentence. Reviewers A and C get it. Reviewer B does not, so it judges the code without the author's framing.
3. Spawn reviewers A, B and C **in parallel**, one agent each, every one with the shared brief below. C runs on `model: "sonnet"`. Under ~50 changed lines, spawn one agent that runs all three checklists instead.
4. If any finding is BLOCKER or WARN, spawn the verifier with those findings. Drop everything it refutes.
5. Fix every confirmed BLOCKER, then report.

Skip this for docs-only, config-only, or single-line diffs.

## Shared Brief

- Read whole changed files and the callers of changed code, not only the hunks.
- Do not flag pre-existing issues on lines the diff leaves alone, anything a linter or type checker catches, or style preferences without a CLAUDE.md/AGENTS.md rule behind them. When citing a rule, quote it.
- Each finding: severity, `file:line`, claim, and a failure scenario (concrete input or state → wrong result). A BLOCKER without a concrete failure scenario is a WARN.
- Load **django** when the repo is a Django project and **writing-tests** when the diff touches tests.
- If nothing survives, return `clean`.

## Reviewer A: Correctness

Given the stated intent, does the diff actually do it?

- Reconstruct what the code does from the code alone, then compare against the stated intent. Where they diverge, the code is the bug.
- Walk the edge cases: empty input, null, zero, boundary values, concurrent callers, the retry path.
- Error handling: is anything swallowed, and does a failure mid-way leave partial state behind?
- Transaction and lock ordering: a commit outside the lock protecting its rows is a race; two paths taking locks in opposite orders deadlock.
- Are parameters threaded correctly, with no semantically distinct params receiving the same value?

## Reviewer B: Blast Radius

What outside the diff does this break or slow down?

- Find every existing caller of each changed function or endpoint. Does the new behavior still satisfy them?
- Changed signatures, return types, or exception types that callers depend on.
- Queryset `.update()`/`.delete()`/`bulk_*` introduced where per-object behavior was expected: these bypass `save()`, signals, audit history, and per-object task dispatch.
- Model changes without a matching migration.
- Side effects that must not fire on rollback, firing mid-transaction instead of via `on_commit`.
- N+1 queries: a loop touching a related object without `select_related`/`prefetch_related`.
- Unbounded work: unbounded querysets, `bulk_create` without batching, loops over unbounded input.
- Query counts that went up, and whether any `assertNumQueries` expectation was raised rather than fixed.
- Work done inside a lock or transaction that could be done outside it.
- Missing indexes for new filter/order columns.
- Test quality: for each new test, would it fail if the fix were reverted? Reason it through. A test that passes either way guards nothing. Flag anything asserting nothing, or only that a mock was called.

## Reviewer C: Deletions

Given the stated intent, what in the diff should not exist?

- Run `ponytail-review` on the diff first and carry its findings over as WARN. Without that skill, check directly for reimplemented standard-library functions, unneeded dependencies, abstractions with one implementation, config for values that never change, and flexibility nobody asked for.
- Test bloat, which `ponytail-review` skips. Every new test must guard a behavior the diff adds or a bug it fixes. Flag tests that:
  - exercise the framework, the language, or a library instead of this code;
  - cover a branch another new test already covers, or a case the intent never mentions;
  - differ from a sibling only in inputs: fold them into one `parametrize`;
  - pin implementation details (private calls, mock call order) a refactor would break without a behavior change.
- Functions the diff adds that have exactly one call site: inline them unless they recurse or the caller would run past ~50 lines.
- Comments the diff adds that restate the code, narrate the change, describe old behavior, or head a section. Mechanical check for the narration cases:

  ```bash
  git diff <merge-base> | grep '^+[^+]' | cut -c2- | node ~/.dotfiles/agents/skills/humanizer/scripts/prose-lint.js --mode comment
  ```

- Every changed file, repo, doc, README section, test, logged field, alert, or health check the intent doesn't require. Each one is a revert.
- For each new pattern (a fixture, a version-gated test, an error path), find how the repo already handles the same case. A deviation from an existing convention is a finding.

## Verifier

Receives the BLOCKER and WARN findings, not the intent. For each one, read the cited code and try to disprove it: does the failure scenario reach that line, is it guarded elsewhere, is it pre-existing? Return CONFIRMED or REFUTED with one line of evidence. A scenario that can't be traced through the code is REFUTED.

## Output

One table, most severe first:

| Severity | File:line | Finding | Reviewer | Verified |
| -------- | --------- | ------- | -------- | -------- |

Severity is BLOCKER (ships a bug), WARN (works but violates a convention), or NIT. NITs skip verification.
Anything a reviewer is unsure about gets stated as unsure, not dropped and not inflated.

Report the table before committing anything. If all three come back clean, say so in one line.

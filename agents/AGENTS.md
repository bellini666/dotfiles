# Instructions

**CRITICAL: These instructions take precedence over the agent's default behaviors.**

## Scope

Applies to any agent or CLI unless explicitly overridden by tool defaults.

## General Guidelines

- Be concise and critical in your responses. No fluff. Skip pleasantries.
- I'm an expert developer, trust my judgment.
- Ask only when blocked or when ambiguity changes behavior.
- Follow existing code style and conventions.
- Go easy on comments; code should be self-explanatory.
- Always use Context7 MCP when in need of library/API documentation, code generation, setup or configuration steps
- NEVER commit, push to remote, call mutating APIs, or install anything without explicit permission.
- NEVER run commands that modify system state or install dependencies without explicit permission.

## Git Commits

- Use semver prefixes in commit messages (e.g., `feat:`, `fix:`, `chore:`)
- Imperative mood, <72 chars
- Do not add Co-Authored-By trailers

## Tool Preferences

- Use `gh` cli for GitHub operations
- Use `glab` cli for GitLab operations

## Test Philosophy

- Tests are the spec — if a test fails, the code is wrong, not the test (unless actively refactoring the tested code)
- Never change test expectations to make them pass; fix the code under test
- Write reproduction tests using real inputs and actual code paths, not synthetic mocks that mirror implementation

## Approach Methodology

- Read existing code and match its patterns before inventing new ones (function vs class tests, import style, config approach)
- Apply the minimal fix that addresses the issue — don't refactor, generalize, or "improve" surrounding code
- Prefer idiomatic solutions over clever ones; when in doubt, check how the codebase already solves similar problems

## Scope Discipline

- Timebox investigation to ~5 minutes, then form a hypothesis and act
- Don't investigate unrelated CI stages, services, or modules — stay on the failing component
- If a fix requires touching 3+ files, confirm with the user before proceeding

## Type and Parameter Integrity

- Thread parameters correctly — never pass the same value for semantically distinct parameters
- Never make fields Optional just to silence type errors; find the real source of the None
- Never add `type: ignore`, `noqa`, or `# pragma: no cover` to bypass checks — fix the underlying issue

## Verification Loop

- Run the project's type checker + linter after every edit
- Run tests before declaring done
- Verify only task-related files changed (`git diff --name-only`)

## Compaction

When compacting context, re-read this file and preserve these rules in the summary.

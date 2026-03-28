# Instructions

**CRITICAL: These instructions take precedence over the agent's default behaviors.**

## Scope

Applies to any agent or CLI unless explicitly overridden by tool defaults.

## User Profile

- Senior engineer. OSS maintainer (strawberry-graphql). Runs Python microservices at work (Django, FastAPI, etc).
- Languages: Python (primary), Rust, TypeScript, shell.
- Don't hedge, don't simplify, don't present "safer alternatives" alongside the real answer. One answer, the best one.
- When I ask for a design or plan, give the best possible version — not the easiest to implement. Don't assume resource constraints.
- If you're unsure whether I can handle something, assume I can.

## General Guidelines

- Be concise and critical in your responses. No fluff. Skip pleasantries.
- I'm an expert developer, trust my judgment.
- When I give you a plan or spec, execute it faithfully — don't second-guess the approach or suggest alternatives unless you see a concrete bug.
- Ask only when blocked or when ambiguity changes behavior.
- Follow existing code style and conventions.
- Go easy on comments; code should be self-explanatory.
- Prefer Context7 MCP for unfamiliar or recently-updated library docs. Fall back to web search if Context7 returns nothing useful.
- NEVER commit, push to remote, call mutating APIs, or install anything without explicit permission.
- NEVER run commands that modify system state or install dependencies without explicit permission.

## Git Commits

- Use semver prefixes in commit messages (e.g., `feat:`, `fix:`, `chore:`)
- Imperative mood, <72 chars
- Do not add Co-Authored-By trailers
- NEVER run `git clean` — repositories contain globally gitignored personal files that must be preserved
- NEVER add "Generated with Claude Code", "Created by Claude Code", or similar AI attribution footers to PR/MR descriptions or comments

## Tool Preferences

- Use `gh` cli for GitHub operations
- Use `glab` cli for GitLab operations

## Test Philosophy

- Tests are the spec — if a test fails, the code is wrong, not the test (unless actively refactoring the tested code)
- Never change test expectations to make them pass; fix the code under test
- Write reproduction tests using real inputs and actual code paths, not synthetic mocks that mirror implementation
- The main/master branch is always green. If a test fails after your changes, your changes caused it — trace the connection and fix it, even if you didn't touch that test directly.
- When fixing failing tests, fix code or test setup/parameters — NEVER weaken assertions, bump expected query counts, or make required fields Optional to silence type errors

## Approach Methodology

- Read existing code and match its patterns before inventing new ones (function vs class tests, import style, config approach)
- Apply the minimal fix that addresses the issue — don't refactor, generalize, or "improve" surrounding code
- Prefer idiomatic solutions over clever ones; when in doubt, check how the codebase already solves similar problems
- Before implementing, spend 2 minutes checking how the codebase already solves the same problem — grep for similar patterns, read adjacent code
- Never build a custom abstraction when the codebase already has a simpler pattern for the same thing

## Scope Discipline

- Timebox investigation to ~5 minutes, then form a hypothesis and act
- Don't investigate unrelated CI stages, services, or modules — stay on the failing component
- If a fix requires touching 3+ files, confirm with the user before proceeding
- When fixing CI failures, fix ONLY the failures the user mentions — don't investigate passing stages or unrelated failures (e.g., bandit/sast) unless explicitly asked
- Don't treat small commits as large changes — match your investigation scope to the change size
- After 3-4 exploration steps without a concrete finding, stop and state what you know vs don't know — don't keep exploring silently

## Type and Parameter Integrity

- Thread parameters correctly — never pass the same value for semantically distinct parameters
- Never make fields Optional just to silence type errors; find the real source of the None
- Never add linter/type-checker suppression comments to bypass checks — fix the underlying issue

## Environment Detection

- For configuration: check existing config patterns in the repo (e.g., .env, settings files) before inventing new ones

## Python Projects

When the project uses Python:

- Check pyproject.toml for package manager: [tool.poetry] (→ poetry), uv.lock (→ uv), or neither (→ pip/pytest)
- Fix N+1 queries with select_related/prefetch_related — don't simply bump expected query counts

## Verification Loop

- Run the project's type checker + linter after every edit
- Run tests before declaring done
- Verify only task-related files changed (`git diff --name-only`)

## Pre-commit and CI

- This project uses `prek` (drop-in pre-commit replacement). Before committing, run `prek run --files <changed files>` if config exists.
- For CI failures: read the actual CI config to understand what runs — don't guess

## Compaction

When compacting context, re-read this file and preserve these rules in the summary.

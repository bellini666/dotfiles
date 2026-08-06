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
- Comments explain WHY, never WHAT. Default to none. Only add one when the reason would surprise a future reader (hidden constraint, subtle invariant, workaround for a specific bug). Never reference the current task, caller, or fix (`used by X`, `added for Y`) — that rots and belongs in the PR description.
- Prefer Context7 MCP for unfamiliar or recently-updated library docs. Fall back to web search if Context7 returns nothing useful.
- NEVER commit, push, call mutating APIs, install anything, or otherwise modify system state without explicit permission.

## Plan & Approval

- For any non-trivial change, propose the minimal plan first, then wait — do not stack multiple "while I'm here" edits.
- Before any fix, state the root cause in one sentence with a code reference. Reject your own first patch if it masks symptoms (try/except, narrow checks, refactors that hide the bug).
- If you've explored 3-4 steps without a concrete finding, stop and report what you know vs. don't know.
- A question ("why…", "is this correct?", "should I…") gets an answer, not an edit. Answer, then stop.

## Evidence Before Claims

- Don't state a root cause as fact without logs, a query result, an API response, or a failing reproduction behind it. Unproven means it's labelled "hypothesis, unverified".
- Don't claim an environment limitation ("tests can't run here", "that file is read-only") without running the command and pasting the actual error.
- While investigating, don't run anything that destroys the evidence — reinstalls, cache wipes, `--force` anything. Capture the current state first.
- If an earlier claim turns out wrong, say so before continuing.

## Code Style

- Prefer inlining small helpers over extracting them unless reuse is concrete (≥2 call sites or a clear seam).
- Don't introduce abstractions for hypothetical future flexibility.
- Keep RELEASE notes / changelog / PR descriptions terse — one paragraph, list affected behavior, skip narrative.
- Python docstrings follow PEP 257: first line is a one-sentence summary, then a blank line, then extra context if needed. Keep it concise — no parameter tables or restating type hints.
- Separate logical sections inside functions with a blank line — setup vs. main logic vs. return prep, distinct steps in a pipeline, before/after a side-effect. Don't pack unrelated steps into one dense block.

## Git Commits

- Use semver prefixes in commit messages (e.g., `feat:`, `fix:`, `chore:`)
- Imperative mood, <72 chars
- NEVER run `git clean` — repositories contain globally gitignored personal files that must be preserved
- Commit messages end with the trailer `Co-Authored-By: <model name> <noreply@anthropic.com>` (e.g. `Claude Opus 5`), blank line before it
- ALWAYS end PR/MR descriptions with this footer, blank line before it, model name substituted, no other AI-attribution boilerplate (this is different from the commit message trailer)

  ```
  Co-Authored-By: 🤖 Claude [Claude Code](https://claude.com/claude-code), reviewed by the author
  ```

- MR/PR descriptions describe the diff, not the chronology of how the work was done. Strip reviewer-irrelevant narrative.
- Match commit message framing to the actual code change, not the journey to it.
- Before any force-push, check for rebase divergence (`git log @{u}..` and `git log ..@{u}`) and drop commits already squashed into the target branch.

## Tool Preferences

- Use `gh` cli for GitHub operations
- Use `glab` cli for GitLab operations

## MCP Preference

- When an MCP server is configured for a service, use it. Do not fall back to WebFetch for resources that an MCP can serve.
- Common cases: Atlassian (Confluence/Jira), incident.io, Sentry, GitHub, Notion.
- Check available MCP tools before reaching for WebFetch on internal/private URLs.

## Writing User-Facing Prose

- ALWAYS run the `humanizer` skill before submitting any user-facing prose: PR/MR descriptions, review replies, issue comments, commit message bodies, changelog entries, release notes, README sections, design docs, or documentation paragraphs.
- Apply it to your own drafts before posting — not just when I explicitly ask to "humanize" something.

## Test Philosophy

- Tests are the spec — if a test fails, the code is wrong, not the test (unless actively refactoring the tested code)
- Never change test expectations to make them pass; fix the code under test
- Write reproduction tests using real inputs and actual code paths, not synthetic mocks that mirror implementation
- The main/master branch is always green. If a test fails after your changes, your changes caused it — trace the connection and fix it, even if you didn't touch that test directly.
- When fixing failing tests, fix code or test setup/parameters — NEVER weaken assertions, bump expected query counts, or make required fields Optional to silence type errors
- A regression test must be seen failing before the fix exists — write it first, or revert the fix and re-run. Feature tests don't need this.

## Test Imports

- Test imports go at module level. Always. Not inside test functions or fixtures.
- The only exceptions: circular import, optional/conditional dependency, or a side-effecting import that must be deferred. If none apply, it goes at the top.

## Approach Methodology

- Read existing code and match its patterns before inventing new ones (function vs class tests, import style, config approach)
- Apply the minimal fix that addresses the issue — don't refactor, generalize, or "improve" surrounding code
- Prefer idiomatic solutions over clever ones; when in doubt, check how the codebase already solves similar problems
- Before writing any code, spend 2 minutes checking how the codebase already solves the same problem — grep for similar patterns, read adjacent code
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

## Sandbox

Sessions run inside `agent-safehouse`, a deny-by-default macOS seatbelt profile. Grants come from `core.sh`:

- Read/write: the working directory, `~/Downloads`, `~/.cache`
- Read-only: `~/.dotfiles`, `~/Library/Caches/Homebrew`, `~/.gitconfig`, `~/.gitignore`, `~/.gitattributes`, `~/.npmrc`
- Everything else is denied, including sibling project directories under `~/dev` and `/opt/homebrew/Cellar`

When a task needs a path outside that set, say so up front and hand over the exact command instead of retrying — retries won't help, the denial is static for the session. Never widen the sandbox yourself; ask.

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
- Watch for ANSI color code differences between local and CI test output

## Compaction

When compacting context, re-read this file and preserve these rules in the summary.

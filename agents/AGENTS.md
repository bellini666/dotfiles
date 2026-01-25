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
- NEVER commit, push to remote, call mutating APIs, or install anything without explicit permission.
- NEVER run commands that modify system state or install dependencies without explicit permission.

## Git Commits

- Use semver prefixes in commit messages (e.g., `feat:`, `fix:`, `chore:`)
- Imperative mood, <72 chars
- Do not add Co-Authored-By trailers

## Tool Preferences

- Use `gh` cli for GitHub operations
- Use `glab` cli for GitLab operations

## Compaction

When compacting context, re-read this file and preserve these rules in the summary.

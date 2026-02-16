---
name: catchup
description: Catch up on branch changes
template: Read all files changed in this branch compared to main/master, review commit messages, and summarize what's been done and the current state.
---

# Catchup Command

## Purpose

Quickly understand what has changed in the current working branch compared to main/master.

## Usage

```
/catchup
```

## Behavior

1. Detect base branch (main or master)
2. Detect platform (check for `.gitlab-ci.yml` → glab, otherwise → gh)
3. Get commit log since divergence from base branch
4. Get all changed files with `git diff <base>...HEAD --stat`
5. Read changed files for context

## Output Format

### Commit Summary

- List commits with their semver prefixes and short descriptions

### Changes by Area

Group changed files into categories:

- **Migrations**: new/modified database migrations
- **Config**: settings files, CI config, dependency changes
- **Source**: application code changes
- **Tests**: new/modified tests

### Key Changes

- Highlight breaking changes or API modifications
- Note new dependencies added (check pyproject.toml, package.json, Cargo.toml diffs)
- Flag any renamed/moved files

### PR/MR Context

- If on a branch with an open PR/MR, show its title and status
- Use `gh pr view` or `glab mr view` depending on detected platform

### Current State

- Any uncommitted changes
- Potential issues or blockers

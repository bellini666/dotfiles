---
name: jujutsu
description: This skill should be used when working in a repository that uses jujutsu (jj) for version control, when the user mentions "jj", "jujutsu", asks about "jj commands"
---

# Jujutsu (jj) for Agents

Jujutsu is a Git-compatible version control system with features that make it ideal for agent workflows: automatic snapshotting, easy undo, and safe concurrent work.

## Detecting a jj Repository

Check for jj before using git:

```bash
# jj repos have a .jj directory (may also have .git if colocated)
if [ -d .jj ]; then
  # Use jj commands
else
  # Use git commands
fi
```

## Core Concepts

### Working Copy is Always Committed

Unlike git, jj automatically snapshots the working copy on every command. There's no staging area—all changes are immediately part of the current "change."

- `@` refers to the current working-copy change
- `@-` refers to the parent of `@`
- Changes are identified by both a **change ID** (stable, e.g., `puqltutt`) and a **commit ID** (content-based hash)

### Changes vs Commits

- **Change ID**: Stable identifier that persists through rebases and amends (use for references)
- **Commit ID**: Content hash that changes when the commit is modified

### No Branches, Use Bookmarks

jj doesn't have git-style branches. Instead:

- Work happens on anonymous changes (detached HEAD is normal)
- **Bookmarks** are named pointers for sharing/pushing (like lightweight branches)
- All visible heads are tracked automatically—nothing gets lost

## Essential Commands

### Status and History

```bash
jj st                    # Status (shows working copy changes)
jj log                   # Show commit graph
jj diff                  # Show uncommitted changes in @
jj diff -r @-            # Show changes in parent commit
jj show                  # Show current change details
```

### Describing Changes (Critical for Agents)

Always describe changes as you work—this creates a clear audit trail:

```bash
jj describe -m "Add user authentication endpoint"
jj describe              # Opens editor for longer messages
```

### Creating and Navigating Changes

```bash
jj new                   # Create new empty change on top of @
jj new @-                # Create new change as sibling of @
jj new -m "message"      # Create with description
jj edit <change-id>      # Edit an existing change directly
```

### Modifying History

```bash
jj squash                # Move @ changes into parent (@-)
jj squash -i             # Interactive: select which changes to squash
jj split                 # Split current change into multiple
jj abandon               # Discard current change entirely
```

### Rebasing

```bash
jj rebase -d main        # Rebase @ onto main bookmark
jj rebase -s @ -d main   # Same, explicit source
jj rebase -b @ -d main   # Rebase entire branch
```

## Undo and Recovery (Agent Superpower)

jj's operation log makes experimentation safe—any operation can be undone:

```bash
jj undo                  # Undo last operation
jj op log                # View all operations
jj op restore <op-id>    # Restore to any previous state
```

### Safe Experimentation Pattern

```bash
# Try something risky
jj rebase -d main

# Didn't work? Undo it
jj undo

# Or restore to a specific point
jj op log                # Find the operation ID
jj op restore abc123     # Restore to that state
```

### View Change Evolution

```bash
jj evolog                # See how current change evolved over time
jj obslog                # Alias for evolog
```

## Working with Git Remotes

### Fetching and Pushing

```bash
jj git fetch                           # Fetch from origin
jj git fetch --remote upstream         # Fetch from specific remote
jj git push                            # Push tracking bookmarks
jj git push --bookmark my-feature      # Push specific bookmark
jj git push --allow-new                # Allow creating new remote bookmarks
```

### Creating Bookmarks for Push

```bash
# Create bookmark pointing to current change's parent
jj bookmark create my-feature -r @-

# Push it
jj git push --bookmark my-feature --allow-new
```

### Updating from Upstream

```bash
jj git fetch
jj rebase -d main@origin    # Rebase onto fetched main
```

### Colocated Repositories (jj + git)

Many repos use both jj and git (colocated). Changes sync automatically:

```bash
jj git init --colocate      # Initialize colocated repo
# Now both jj and git commands work
# jj syncs to git on every operation
```

## Concurrent Work (Multi-Agent Safety)

jj handles concurrent modifications gracefully:

### Multiple Changes in Parallel

```bash
# Start work on feature A
jj new main -m "Feature A"
# ... make changes ...

# Switch to work on feature B (without committing A first)
jj new main -m "Feature B"
# A is preserved automatically

# View all your work
jj log
```

### When Another Agent Made Changes

If the working copy was modified externally:

```bash
jj st                    # Auto-snapshots and shows what changed
jj diff                  # See the changes
jj describe -m "..."     # Describe them if needed
```

### Workspace Isolation

For true isolation, use separate workspaces:

```bash
jj workspace add ../feature-workspace
# Now you have two independent working copies
```

## Parallel Agent Collaboration (No Checkout Switching)

Agents can work on separate changes simultaneously and merge work without checkout switching—all operations target specific revisions directly.

### Key Insight: Direct Revision Targeting

Most jj commands accept `-r <rev>` to operate on any revision without changing the working copy:

```bash
# Edit a specific revision (switches working copy)
jj edit abc123

# Or operate without switching:
jj describe -r abc123 -m "Update message"
jj squash -r work-change -d target-change
jj diff -r abc123
```

### Pattern: Agent Work → Squash to Main

Multiple agents can work on independent changes, then squash into a shared target:

```bash
# Agent 1: Creates work on feature-main
jj new feature-main -m "Agent 1: Add API endpoint"
# ... works ... (change ID: aaa111)

# Agent 2: Creates separate work on same base
jj new feature-main -m "Agent 2: Add tests"
# ... works ... (change ID: bbb222)

# Coordinator: Squash both into feature-main
jj squash -r aaa111 -d feature-main
jj squash -r bbb222 -d feature-main

# Push without switching
jj git push --bookmark feature-main
```

### Pattern: Direct Push Without Checkout

Push any bookmark regardless of working copy state:

```bash
# Working copy is on @ (unrelated change)
# Push a different bookmark directly:
jj git push --bookmark feature-x

# Or push a specific change with auto-named bookmark:
jj git push --change abc123
```

## Stacked Branches (PR Chains)

jj excels at stacked branches—dependent commits with separate PRs.

### Creating a Stack

```bash
# Base feature
jj new main -m "feat: Add user model"
jj bookmark create feat/user-model -r @
# (change ID: aaa)

# Dependent feature
jj new aaa -m "feat: Add user API"  # builds on user-model
jj bookmark create feat/user-api -r @
# (change ID: bbb)

# Another dependent
jj new bbb -m "feat: Add user UI"  # builds on user-api
jj bookmark create feat/user-ui -r @
```

### Visualizing the Stack

```bash
jj log -r 'trunk()..@'  # Show stack from trunk to current
```

### Pushing the Stack

```bash
# Push all bookmarks in the stack
jj git push --bookmark feat/user-model --allow-new
jj git push --bookmark feat/user-api --allow-new
jj git push --bookmark feat/user-ui --allow-new
```

### When Base PR Merges

After `feat/user-model` merges to main:

```bash
# Fetch the merged main
jj git fetch

# Rebase remaining stack onto new main
jj rebase -s feat/user-api -d main

# The stack is now:
# main (includes user-model) → user-api → user-ui

# Update bookmarks and push
jj git push --bookmark feat/user-api
jj git push --bookmark feat/user-ui
```

### Handling Conflicts in Stack

If rebasing creates conflicts:

```bash
# Find conflicted commits
jj log -r 'conflicts()'

# Resolve each from bottom of stack up
jj new <conflicted-change>
# ... edit to resolve ...
jj squash  # squash resolution into conflicted commit

# Continue up the stack
```

### Inserting Changes Mid-Stack

```bash
# Currently: A → B → C
# Want: A → X → B → C

jj new A -m "Insert X between A and B"
# (creates X, but B still points to A)

jj rebase -s B -d X
# Now: A → X → B → C
```

## Handling Conflicts

Conflicts are stored in commits—they don't block work:

```bash
# After a rebase creates conflicts
jj log                   # Shows (conflict) marker
jj st                    # Lists conflicted files

# Resolve conflicts
jj new <conflicted-id>   # Create change on top of conflict
# ... edit files to resolve ...
jj squash                # Squash resolution into conflicted commit

# Or use merge tool
jj resolve               # Opens external merge tool
```

## Agent Workflow Patterns

### Pattern 1: Describe-As-You-Go

```bash
jj describe -m "Starting: implement user login"
# ... make changes ...
jj describe -m "Implement user login with JWT tokens"
```

### Pattern 2: Safe Exploration

```bash
# Save current state mentally (check op log)
jj op log -n 1

# Try risky refactor
# ... make changes ...

# Didn't work? Restore
jj undo
```

### Pattern 3: Working on Multiple Features

```bash
jj new main -m "Feature A"
# ... work on A ...

jj new main -m "Feature B"  # B branches from main, not A
# ... work on B ...

# Switch back to A
jj edit <A-change-id>
```

### Pattern 4: Preparing for Push

```bash
# Ensure changes are described
jj describe -m "Final description"

# Create bookmark
jj bookmark create feature-x -r @

# Push
jj git push --bookmark feature-x --allow-new
```

## Quick Reference

| Task                 | Command                        |
| -------------------- | ------------------------------ |
| Check status         | `jj st`                        |
| View history         | `jj log`                       |
| Show diff            | `jj diff`                      |
| Describe change      | `jj describe -m "message"`     |
| New change           | `jj new`                       |
| Squash into parent   | `jj squash`                    |
| Undo last action     | `jj undo`                      |
| Fetch from git       | `jj git fetch`                 |
| Push to git          | `jj git push`                  |
| Create bookmark      | `jj bookmark create name -r @` |
| Abandon change       | `jj abandon`                   |
| Edit existing change | `jj edit <id>`                 |

## Revset Syntax (Common Patterns)

```bash
@              # Current working copy
@-             # Parent of @
@--            # Grandparent
main           # Bookmark named main
heads()        # All visible heads
trunk()        # Main branch (auto-detected)
::@            # All ancestors of @
@::            # All descendants of @
```

## Additional Resources

For detailed command reference and advanced patterns, see `references/commands.md`.

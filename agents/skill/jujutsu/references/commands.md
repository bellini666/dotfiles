# Jujutsu Command Reference

Detailed command reference and advanced patterns for jj.

## Command Deep Dives

### jj describe

Describe a change with a commit message. Unlike git, you can change the description at any time.

```bash
jj describe -m "Short message"
jj describe                          # Opens $EDITOR
jj describe -r <rev> -m "message"    # Describe a different revision
jj describe --reset-author           # Update author to current user
```

### jj new

Create a new change. This is the primary way to start new work.

```bash
jj new                    # New change on top of @
jj new @-                 # New change as sibling of @ (same parent)
jj new A B                # New merge change with parents A and B
jj new -m "description"   # With description
jj new --no-edit          # Don't edit the description
jj new -A                 # Insert new change after @ (@ becomes parent, @'s children become new's children)
jj new -B                 # Insert new change before @ (new becomes @'s parent)
```

### jj squash

Move changes from one commit into another (typically into parent).

```bash
jj squash                 # Squash @ into @-
jj squash -r A -d B       # Squash A into B (destination)
jj squash -i              # Interactive mode: select hunks
jj squash --keep-emptied  # Keep the source commit even if empty
```

### jj split

Split a change into multiple changes.

```bash
jj split                  # Interactive: select what goes in first change
jj split -r <rev>         # Split a specific revision
jj split --parallel       # Create sibling changes instead of parent-child
```

### jj rebase

Move changes to a new parent.

```bash
jj rebase -d main              # Rebase @ onto main
jj rebase -s @ -d main         # Same, explicit source
jj rebase -b @ -d main         # Rebase entire branch (all descendants too)
jj rebase -r @ -d main         # Only rebase @ (reparent children to @'s old parent)
jj rebase --skip-emptied       # Drop changes that become empty
```

### jj abandon

Discard changes. Descendants are rebased onto the abandoned change's parent.

```bash
jj abandon                # Abandon @
jj abandon <rev>          # Abandon specific revision
jj abandon <rev1> <rev2>  # Abandon multiple
```

### jj restore

Restore file contents from another revision.

```bash
jj restore                        # Restore @ from @-
jj restore --from <rev>           # Restore @ from specific revision
jj restore --to <rev>             # Restore into specific revision (not @)
jj restore path/to/file           # Restore specific file(s)
jj restore --from <rev> file.txt  # Restore specific file from revision
```

### jj diff

Show differences.

```bash
jj diff                   # Changes in @
jj diff -r @-             # Changes in @-
jj diff --from A --to B   # Diff between two revisions
jj diff --stat            # Summary statistics
jj diff --git             # Git-compatible diff format
jj diff path/to/file      # Diff specific file
```

### jj log

Show repository history.

```bash
jj log                    # Default log view
jj log -r 'all()'         # Show all changes
jj log -r '::@'           # Ancestors of @
jj log -n 10              # Limit to 10 entries
jj log --no-graph         # Without graph
jj log -T 'description'   # Custom template
jj log -p                 # With patches
jj log -s                 # With summary
```

## Git Operations

### jj git fetch

```bash
jj git fetch                      # Fetch from default remote
jj git fetch --remote origin      # Fetch from specific remote
jj git fetch --all-remotes        # Fetch from all configured remotes
jj git fetch --branch main        # Fetch specific branch only
```

### jj git push

```bash
jj git push                                    # Push tracking bookmarks
jj git push --bookmark my-feature              # Push specific bookmark
jj git push --all                              # Push all bookmarks
jj git push --allow-new                        # Allow creating new remote bookmarks
jj git push --dry-run                          # Preview what would be pushed
jj git push --change @                         # Create and push auto-named bookmark for @
jj git push --named my-name=@                  # Push @ under specific name
```

### jj git clone

```bash
jj git clone https://github.com/user/repo.git
jj git clone --colocate https://...           # Create colocated repo
```

### jj git init

```bash
jj git init                       # Initialize jj-only repo with git backend
jj git init --colocate            # Initialize colocated jj+git repo
```

## Bookmark Management

```bash
jj bookmark list                              # List all bookmarks
jj bookmark create name -r @                  # Create bookmark at @
jj bookmark create name -r @-                 # Create at parent
jj bookmark set name -r @                     # Move existing bookmark
jj bookmark delete name                       # Delete bookmark
jj bookmark track name@origin                 # Track remote bookmark
jj bookmark untrack name@origin               # Stop tracking
```

## Operation Log Commands

```bash
jj op log                         # Show operation history
jj op log -n 5                    # Show last 5 operations
jj op log --op-diff               # Show what changed in each operation
jj undo                           # Undo last operation
jj undo -n 2                      # Undo last 2 operations
jj op restore <op-id>             # Restore to specific operation
jj op diff <op1> <op2>            # Diff between two operations
```

## Workspace Commands

Workspaces allow multiple working copies of the same repo.

```bash
jj workspace list                 # List workspaces
jj workspace add ../path          # Add new workspace
jj workspace add ../path --name feature
jj workspace forget <name>        # Remove workspace
jj workspace update-stale         # Update after repo changed elsewhere
```

## Advanced Revsets

### Revset Operators

```bash
A & B             # Intersection
A | B             # Union
A ~ B             # Difference (A minus B)
~A                # Not A
A::B              # A to B (inclusive)
A..B              # After A, up to and including B
::A               # Ancestors of A (inclusive)
A::               # Descendants of A (inclusive)
A-               # Parents of A
A+               # Children of A
```

### Useful Revset Functions

```bash
all()                             # All visible commits
heads()                           # All heads (no children)
roots()                           # All roots (no parents)
trunk()                           # Main branch (auto-detected)
bookmarks()                       # All bookmarked commits
remote_bookmarks()                # All remote-tracking bookmarks
description(pattern)              # Commits with matching description
author(pattern)                   # Commits by author
committer(pattern)                # Commits by committer
file(path)                        # Commits touching path
conflicts()                       # Commits with conflicts
empty()                           # Empty commits
mine()                            # My commits
present(x)                        # x if it exists, empty otherwise
```

### Example Revsets

```bash
# My recent work
jj log -r 'mine() & ::@'

# All changes with conflicts
jj log -r 'conflicts()'

# Changes between main and @
jj log -r 'main..@'

# Heads that aren't bookmarked
jj log -r 'heads() ~ bookmarks()'

# Changes touching a specific file
jj log -r 'file("src/main.rs")'
```

## Configuration

### Common Settings

```toml
# ~/.config/jj/config.toml

[user]
name = "Your Name"
email = "you@example.com"

[ui]
default-command = "log"
diff-editor = "meld"
merge-editor = "meld"

[git]
auto-local-bookmark = true     # Auto-create local bookmarks for new remote ones
push-new-bookmarks = true      # Allow pushing new bookmarks without --allow-new
```

### Per-Repository Config

```bash
jj config set --repo user.email "work@company.com"
```

## Conflict Resolution

### Understanding Conflict Markers

```
<<<<<<< Conflict 1 of 1
%%%%%%% Changes from base to side #1
-original line
+side 1 version
+++++++ Contents of side #2
side 2 version
>>>>>>> Conflict 1 of 1 ends
```

### Resolution Workflow

```bash
# 1. Find conflicted commits
jj log -r 'conflicts()'

# 2. Create resolution commit
jj new <conflicted-commit>

# 3. Edit files to resolve (remove markers, keep correct content)

# 4. Verify resolution
jj diff

# 5. Squash into original
jj squash
```

### Using Merge Tools

```bash
jj resolve                        # Use configured merge tool
jj resolve --list                 # List conflicted files
jj resolve path/to/file           # Resolve specific file
jj resolve --tool meld            # Use specific tool
```

## Tips for Agent Workflows

### Atomic Operations

Every jj command is atomic and recorded in the operation log. This means:

- No partial states
- Everything can be undone
- Safe to experiment

### Working Copy Snapshots

jj snapshots the working copy before most commands. This means:

- External edits are captured automatically
- No need to manually stage changes
- Running `jj st` is enough to record current state

### Change Identity

Use change IDs (like `puqltutt`) rather than commit IDs when possible:

- Change IDs survive rebases and amends
- Commit IDs change when content changes
- Change IDs are shorter and easier to work with

### Parallel Development

Multiple independent changes can coexist:

```bash
# Create parallel changes from same base
jj new main -m "Feature A"
jj new main -m "Feature B"
jj new main -m "Feature C"

# All three are siblings, can be developed independently
jj log  # Shows all as separate heads
```

### Squash Across Revisions (Agent Coordination)

Squash changes between any revisions without switching:

```bash
# Squash revision A into revision B
jj squash -r A -d B

# Useful for: Agent work → main change
# Agent creates work-change, coordinator squashes into target
```

### Stacked Bookmarks

```bash
# Create a chain of dependent changes
jj new main -m "Base"        # Change A
jj bookmark create pr-1 -r @
jj new -m "Depends on base"  # Change B (parent is A)
jj bookmark create pr-2 -r @
jj new -m "Depends on B"     # Change C (parent is B)
jj bookmark create pr-3 -r @

# Push all
jj git push --bookmark pr-1 --bookmark pr-2 --bookmark pr-3 --allow-new

# After pr-1 merges, rebase the rest
jj git fetch
jj rebase -s pr-2 -d main
jj git push --bookmark pr-2 --bookmark pr-3
```

### Recovery from Any State

```bash
# See what happened
jj op log

# Find the good state
jj op log -n 20

# Restore it
jj op restore <op-id>
```

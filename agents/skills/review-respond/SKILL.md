---
name: review-respond
description: "This skill should be used when the user asks to 'address review comments', 'respond to review', 'reply to reviews', 'fix review feedback', 'handle PR feedback', 'address code review', 'review suggestions', 'mark as fixed', 'resolve review comments', 'reply to copilot', 'reply to sourcery', or needs to apply changes, reply to, or resolve PR/MR review comments."
---

# Review Response

## Workflow

1. **Fetch review threads** via GraphQL (see GitHub API Reference below)
2. **Fetch full comment bodies** for each top-level thread comment
3. **Triage comments** into categories:
   - **Actionable**: requires a code change — apply the fix, then reply explaining what changed
   - **Discussion**: needs a reply only, no code change — reply with rationale
   - **Won't fix**: intentional behavior or out of scope — reply with explanation
4. **Apply minimum changes** — address exactly what each comment asks
5. **Run tests + type checker** — ensure changes don't break anything
6. **Reply to each thread** and **resolve** after addressing

## GitHub API Reference

### Fetch review threads (top-level comments with thread IDs)

```bash
gh api graphql -f query='
  query {
    repository(owner: "OWNER", name: "REPO") {
      pullRequest(number: PR_NUMBER) {
        reviewThreads(first: 50) {
          nodes {
            id
            isResolved
            comments(first: 1) {
              nodes {
                databaseId
                author { login }
                body
              }
            }
          }
        }
      }
    }
  }
'
```

### Fetch inline review comments (REST, for path/line context)

```bash
gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments \
  --jq '.[] | select(.in_reply_to_id == null) | {id: .id, user: .user.login, path: .path, line: (.line // .original_line), body: .body}'
```

### Reply to a review thread

```bash
gh api graphql -f query='
  mutation {
    addPullRequestReviewThreadReply(input: {
      pullRequestReviewThreadId: "THREAD_ID",
      body: "Reply message here."
    }) {
      comment { id }
    }
  }
'
```

### Resolve a review thread

```bash
gh api graphql -f query='
  mutation {
    resolveReviewThread(input: { threadId: "THREAD_ID" }) {
      thread { isResolved }
    }
  }
'
```

### Handling Bot Reviews (Copilot, Sourcery, CodeRabbit)

Automated review tools tend to flag style, pattern, and convention suggestions rather than logic bugs. Batch-address their comments — apply the ones that align with the project's existing style, and dismiss the rest with a brief rationale (e.g., "Intentional — matches existing pattern in this module"). Do not blindly apply every bot suggestion; evaluate each against the codebase's actual conventions.

### GitLab Equivalent

Use `glab` CLI for GitLab MRs:

```bash
glab mr view <MR_NUMBER>                          # View MR details and comments
glab mr note <MR_NUMBER> -m "Reply message"       # Add a comment/reply
glab mr update <MR_NUMBER> --ready                 # Mark MR as ready
glab api projects/:id/merge_requests/:iid/notes    # List all MR notes via API
```

For thread-level replies on GitLab, use the API to reply to a specific discussion:

```bash
glab api projects/:id/merge_requests/:iid/discussions/:discussion_id/notes \
  -X POST -f body="Reply message"
```

## Scope Rules

- Only modify files and lines referenced in review comments
- If a fix requires touching files not mentioned in the review, confirm with the user first
- Don't refactor adjacent code — even if it's tempting
- Don't "while I'm here" fix unrelated issues

## Anti-Patterns

Stop immediately if about to:

- **Refactor surrounding code** not mentioned in the review
- **Over-engineer** a simple reviewer request
- **Add features** not requested in the review
- **Rewrite** when the reviewer asked for a small fix
- **Ignore a comment** without explicitly flagging it as discussion/disagreement
- **Resolve without replying** — always reply before resolving

## Reply Style

- Be concise — state what was done or why it won't be done
- For fixed comments: describe the change briefly, then resolve
- For disagreements: explain rationale, let the user decide whether to resolve
- Batch all replies and resolutions (use parallel GraphQL calls when independent)

---
name: review-respond
description: Respond to code review comments. Use when the user says "address review comments", "respond to review", "fix review feedback", or needs to apply changes from PR/MR review comments.
---

# Review Response

## Workflow

1. **Fetch review comments** — use `gh pr view` / `glab mr view` with comments
2. **Triage comments** into categories:
   - **Actionable**: requires a code change
   - **Discussion**: needs a reply, no code change
   - **Resolved**: already addressed or outdated
3. **Apply minimum changes** — address exactly what each comment asks
4. **Verify scope** — only review-mentioned files should change
5. **Run tests + type checker** — ensure changes don't break anything

## Scope Rules

- Only modify files and lines referenced in review comments
- If a fix requires touching files not mentioned in the review, confirm with the user first
- Don't refactor adjacent code — even if it's tempting
- Don't "while I'm here" fix unrelated issues

## Anti-Patterns

Stop immediately if you're about to:

- **Refactor surrounding code** that wasn't mentioned in the review
- **Over-engineer** a simple reviewer request (e.g., adding abstractions for a naming change)
- **Add features** not requested in the review
- **Rewrite** when the reviewer asked for a small fix
- **Ignore a comment** without explicitly flagging it as discussion/disagreement

## Comment Response Style

- Be concise in responses
- If you disagree with a comment, explain why and let the user decide
- Mark resolved comments as resolved after applying fixes

## Integration

- Use `gh` for GitHub PRs, `glab` for GitLab MRs
- Run the project's test suite after applying all changes

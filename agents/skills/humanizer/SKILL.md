---
name: humanizer
description: "Rewrites and drafts prose so it reads like a terse engineer wrote it: PR/MR descriptions, review replies, commit bodies, changelog entries, code comments, READMEs, docs. Use before posting any of those, and when the user asks to humanize text, remove AI writing patterns, make text sound human, or check whether text sounds AI-generated. Strips em dashes, old-behavior narration, fancy vocabulary, negative parallelisms, filler, and chatbot artifacts. Never invents facts."
---

# Humanizer

Text that a reader who did not do the work can understand in one read. The diff carries the what; prose carries only the why and what the diff cannot show.

## Hard rules

Apply these before anything else. They catch most tells without the full catalog.

1. Describe the current state. Never the old behavior, what was avoided, what was preserved, or what the change does not do. "Previously X, now Y" becomes "Y". "Y instead of X" becomes "Y". "Retry logic is the same" says nothing about the retry logic; cut it.
2. State the problem once. Do not restate it in the title, the first sentence, and the summary.
3. Bullets over paragraphs for PR/MR text, changelogs, and replies. One line per behavior change.
4. If a shorter, more common word exists, use it. Suspect any word you would not say out loud to a colleague: quietly, load-bearing, delve, leverage, robust, seamless, comprehensive, streamline, crucial, pivotal, notably, importantly, "it's worth noting".
5. No em dashes (`—`) or en dashes used as em dashes. Comma, period, colon, or parentheses. The one exception is inside a quoted "Before" example.
6. No "Not X, it's Y" or "not just X but Y". State Y.
7. No "Here's what / the thing is / the truth is" throat-clearing. Start with the point.
8. No sentence that opens with What/When/Where/Why/How as a setup ("What makes this hard is..."). Restructure.
9. Name the actor. Not "the decision emerged" or "results are preserved automatically"; who did what.
10. Cut adverb crutches on the first pass: really, just, literally, genuinely, simply, deeply, truly, fundamentally, actually. Add back only ones that change meaning.
11. No vague significance claims ("the implications are significant", "this matters"). Name the specific thing or cut.
12. No chatbot residue: "Great question", "Great catch", "I hope this helps", "Let me know if", "You're absolutely right", thanks, apologies.
13. Vary rhythm: three consecutive sentences of the same length, or a paragraph that ends on a punchy one-liner, gets rewritten.
14. Preserve every fact. Add none. If a sentence needs a detail you do not have, ask or cut the sentence.

## Workflow

1. Draft against the template for the artifact (below).
2. Run the lint over the draft and fix every finding:

   ```bash
   node ~/.dotfiles/agents/skills/humanizer/scripts/prose-lint.js --mode prose < draft.md
   ```

   Use `--mode comment` for code (only comment lines and docstrings are scanned) and `--mode commit` for commit messages (old-behavior rules are off there, because a bug description sometimes needs "raised on None"). Exit 1 means findings; empty output means clean. The same rules run as a PreToolUse hook that denies edits and `git commit` / `gh` / `glab` commands carrying tells, so a draft that fails here will not land.

3. Re-read the result against the hard rules once. The lint is mechanical and only catches the high-precision tells; rules 1 to 3 and 13 need judgment.
4. Output per the mode below.

## Output modes

- **Proactive** (drafting a PR description, reply, commit body, comment, doc paragraph): output the final text only. No draft, no audit, no summary of what was removed.
- **"Humanize this"**: return the final rewrite, then at most five bullets naming the tells that were removed, only if the user would learn something from them.
- **"Does this sound AI?"**: return the findings (quoted phrase plus pattern name) and no rewrite.

## Templates by artifact

Each pair shows the shape to produce. Substance comes from the actual diff, review comment, or source; never from the example.

### PR / MR description

Before:

> Performed a scheduled dependency refresh as part of ongoing maintenance practices. Minor and patch-level version bumps were applied across the dependency graph, including transitive dependencies where applicable. No behavioral changes are expected; existing functionality has been preserved.

After:

```
Bump dependencies

- django 5.2.3 -> 5.2.4, celery 5.5.1 -> 5.5.2
- celery 5.5.2 drops the `task_remote_tracebacks` setting, so it is gone from settings.py

Tests: full suite green locally.

Co-Authored-By: 🤖 Claude [Claude Code](https://claude.com/claude-code), reviewed by the author
```

Rules: title line, one bullet per behavior change a reviewer cannot infer from the diff, one line of test evidence, the footer. No Summary / Changes / Test Plan headers for changes under ~200 lines. No "This PR".

### Commit body

Before:

> This commit updates parse_date to handle None inputs. Previously, passing None would raise a TypeError. Now the function returns None early. Also updated the tests accordingly.

After:

```
fix: return None from parse_date on None input

Callers pass the raw form value straight through, and empty date fields arrive as None (#412).
```

Rules: subject in imperative mood under 72 chars; body only when the why is not obvious from the diff; the trailer from AGENTS.md.

### Review reply

Before:

> Great catch! You're absolutely right that this could be simplified. I've gone ahead and inlined the helper as suggested, and I've made sure the existing behavior is preserved. Let me know if there's anything else!

After, fixed:

```
Inlined in 3f2a1c9.
```

After, declined:

```
Kept the helper: it has a second call site in tasks.py:88.
```

Rules: one or two sentences. What changed (with the commit), or why not. No thanks, no apology, no "as suggested".

### Changelog entry

Before:

> We're excited to announce that we've significantly enhanced the performance of the query engine, delivering a seamless experience for all users.

After:

```
- `Query.execute` runs about 2x faster on filters over 10k rows.
```

Rules: one line, user-visible behavior, a number when there is one, no "we".

### Code comment

Before:

```python
# Previously we used requests here; now uses httpx for async support
client = httpx.AsyncClient()
```

After:

```python
client = httpx.AsyncClient()
```

Keep a comment only for a hidden constraint, a subtle invariant, a workaround with its reference, or why a magic value was chosen:

```python
# Retry once: the upstream returns 502 for ~1s after a cold start (INFRA-231).
```

### Chat reply after a change

Before:

> I've now updated the function to use the new client. Previously it was using requests, but I've switched it to httpx as we discussed. I also made sure not to touch the other call sites. Let me know if you'd like me to update those as well!

After:

```
Done. 14 tests in tests/test_client.py pass. sync.py still uses requests.
```

Rules: verification result, then anything the diff cannot show, stated as current state ("still uses requests"), not as what was avoided ("I didn't touch").

## Voice

Neutral, terse, active. If the user supplies a sample of their own writing, match its sentence length and word choice; otherwise use the default.

## False positives

Do not flag or rewrite:

- One em dash inside a quoted example of bad writing.
- A single transition word ("additionally", "however") used once.
- A formal or technical word used correctly in its domain ("robust" in a statistics sense, "landscape" for screen orientation).
- A scope statement the reader needs ("this covers GitHub only; GitLab is in #88").
- Real alternatives weighed in a design doc.
- Text inside quotes, titles, proper names, or code.
- Compound modifiers with hyphens ("cross-functional", "real-time"). Never drop the hyphen; rephrase if the sentence has too many.

## References

- [references/patterns.md](references/patterns.md): the full catalog, 36 patterns with before/after examples and a table of contents.
- [references/full-example.md](references/full-example.md): one long essay-style rewrite that exercises most of the catalog at once.
- Sources: [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing); the hard rules on agency, distance, and emphasis are adapted from [hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop) (MIT); the false-positive framing follows [blader/humanizer](https://github.com/blader/humanizer) (MIT).

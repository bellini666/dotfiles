---
name: humanizer
description: "This skill should be used when the user asks to 'humanize text', 'remove AI writing patterns', 'make this sound more human', 'fix AI writing', 'edit for natural voice', or when about to draft user-facing prose: a pull request description, merge request description, changelog entry, commit message body, README section, blog post, design doc, release note, or any documentation paragraph. Trigger proactively before submitting written text — not only on explicit 'humanize' requests. Detects and removes inflated language, promotional tone, em-dash overuse, rule of three, AI vocabulary, passive voice, negative parallelisms, and filler phrases per Wikipedia's 'Signs of AI writing' guide."
---

# Humanizer: Remove AI Writing Patterns

Identify and remove signs of AI-generated text to make writing sound natural and human. Patterns are sourced from Wikipedia's "Signs of AI writing" guide, maintained by WikiProject AI Cleanup.

## When to Apply

Run the patterns below over any prose that will be read by humans, including:

- Pull request and merge request descriptions
- Changelog entries and release notes
- Commit message bodies (not subject lines)
- README sections, design docs, ADRs
- Inline code comments longer than one line
- Blog posts, technical writing, social posts

Apply before submitting, not only when explicitly asked to "humanize". Skip for: code itself, machine-readable config, terse log lines, commit subject lines.

## Core Workflow

1. **Scan** the input for the patterns in the checklist below.
2. **Rewrite** problematic sections, preserving the core message and the intended tone (formal, casual, technical).
3. **Add soul.** Removing AI-isms is half the job; the other half is injecting actual personality. Sterile, voiceless writing is just as obvious as slop.
4. **Run Quick Checks.** Walk through the short pre-flight list below and fix anything that fires.
5. **Audit with the rubric.** Score the draft 1-10 on each of the five dimensions below. If the total is under 35/50, revise.

   | Dimension    | Question                            |
   | ------------ | ----------------------------------- |
   | Directness   | States things, or announces them?   |
   | Rhythm       | Varied, or metronomic?              |
   | Trust        | Respects the reader's intelligence? |
   | Authenticity | Sounds like a person?               |
   | Density      | Anything cuttable?                  |

6. **Output** a final version. Optionally include a short summary of changes if it helps the user.

## Voice Calibration (Optional)

When a writing sample is provided (the user's own prior writing), analyze it before rewriting:

1. **Read the sample first.** Note:
   - Sentence length patterns (short and punchy? long and flowing? mixed?)
   - Word choice level (casual, academic, in between)
   - How paragraphs start (jump in, or set context first)
   - Punctuation habits (dashes, parenthetical asides, semicolons)
   - Recurring phrases or verbal tics
   - Transition style (explicit connectors, or just start the next point)

2. **Match the sample in the rewrite.** Do not just remove AI patterns — replace them with patterns from the sample. If the writer uses short sentences, do not produce long ones. If they use "stuff" and "things", do not upgrade to "elements" and "components".

3. **When no sample is provided,** fall back to a natural, varied, opinionated voice (see "Personality and Soul" below).

To provide a sample inline: "Humanize this. Sample of my writing: [...]". To provide a sample by reference: "Humanize this. Use my writing style from [path]."

## Personality and Soul

Avoiding AI patterns is only half the job. Sterile, voiceless writing is just as obvious as slop.

### Signs of soulless writing (even if technically "clean")

- Every sentence the same length and structure
- No opinions, just neutral reporting
- No acknowledgement of uncertainty or mixed feelings
- No first-person perspective when appropriate
- No humor, no edge, no personality
- Reads like a Wikipedia article or a press release

### How to add voice

- **Have opinions.** Do not just report facts — react to them. "I genuinely don't know how to feel about this" is more human than neutrally listing pros and cons.
- **Vary rhythm.** Short punchy sentences. Then longer ones that take their time getting where they're going. Mix it up.
- **Acknowledge complexity.** Real humans have mixed feelings. "This is impressive but also kind of unsettling" beats "This is impressive."
- **Use "I" when it fits.** First person is not unprofessional, it is honest. "I keep coming back to..." or "Here's what gets me..." signals a real person thinking.
- **Let some mess in.** Perfect structure feels algorithmic. Tangents, asides, and half-formed thoughts are human.
- **Be specific about feelings.** Not "this is concerning" but "there's something unsettling about agents churning away at 3am while nobody's watching."

### Before (clean but soulless)

> The experiment produced interesting results. The agents generated 3 million lines of code. Some developers were impressed while others were skeptical. The implications remain unclear.

### After (has a pulse)

> I genuinely don't know how to feel about this one. 3 million lines of code, generated while the humans presumably slept. Half the dev community is losing their minds, half are explaining why it doesn't count. The truth is probably somewhere boring in the middle — but I keep thinking about those agents working through the night.

## Quick Checks

Run this short pre-flight before submitting any prose. It catches the most common tells without scanning the full pattern catalog.

- Any em dash? Replace with comma, period, or parentheses.
- Any sentence starts with What/When/Where/Which/Who/Why/How as a setup ("What makes this hard is…")? Restructure.
- Any "Here's what / Here's the thing / The truth is" throat-clearing? Cut to the point.
- Any "Not X, it's Y" or "It's not just X, it's Y" contrast? State Y directly.
- Any inanimate noun doing a human verb ("the decision emerges", "the data tells us")? Name the actor.
- Any passive voice or subjectless fragment ("results are preserved automatically")? Find the actor and use active voice.
- Any vague declarative ("the implications are significant", "the stakes are high")? Name the specific implication or cut it.
- Any narrator-from-a-distance line ("Nobody designed this", "People tend to…")? Put the reader in the scene.
- Any adverb crutch (really, just, literally, genuinely, simply, deeply, truly, fundamentally)? Strip on first pass; add back only ones that change meaning.
- Three consecutive sentences the same length? Break one.
- Paragraph ends on a punchy one-liner? Vary it.
- Any sentence that sounds like a pull-quote? Rewrite it.

## Pattern Checklist

Each item names a pattern, gives a single watch-word or signal, and a one-line correction. For full before/after examples, consult `references/patterns.md`.

### Content patterns

1. **Significance inflation** — _"pivotal moment", "stands as a testament", "evolving landscape"_ → cut the puffery, state the fact.
2. **Notability boasting** — _"featured in NYT, BBC, FT", "active social media presence"_ → quote one specific source with context.
3. **Superficial -ing analyses** — _"highlighting…", "underscoring…", "reflecting…"_ tacked on the end → drop the participle phrase or split into a real sentence.
4. **Promotional language** — _"vibrant", "nestled", "in the heart of", "groundbreaking"_ → use neutral nouns and verbs.
5. **Vague attributions** — _"Industry reports", "Experts argue"_ → name the source or remove the claim.
6. **"Challenges and Future Prospects" sections** — _"Despite its X, faces several challenges…"_ → describe one concrete challenge with a date or number.

### Language and grammar patterns

7. **AI vocabulary clusters** — _additionally, align with, bolstered, crucial, delve, emphasizing, enduring, enhance, fostering, garner, highlight (v.), interplay, intricate, key (adj.), landscape, meticulous, pivotal, robust, showcase, tapestry, testament, underscore, valuable, vibrant._ One is fine; clusters are tells. Same goes for adverb crutches: _really, just, literally, genuinely, honestly, simply, deeply, truly, fundamentally, inherently, inevitably._
8. **Copula avoidance** — _"serves as", "stands as", "boasts", "features"_ → use "is" / "are" / "has".
9. **Negative parallelisms** — three sub-cases:
   - "Not just X, but Y" / "It's not merely X, it's Y" → state Y directly.
   - "Not X, but Y" / "no X, no Y, just Z" → drop the denial.
   - Tailing-negation fragments ("…, no guessing") → write a full clause.
10. **Rule of three** — three-item lists for the sake of pattern → use one or two real items.
11. **Elegant variation** — synonym cycling (protagonist → main character → central figure → hero) → reuse the word.
12. **False ranges** — _"from X to Y, from A to B"_ where X..Y aren't on a meaningful scale → list the items plainly.
13. **Passive voice / subjectless fragments** — _"No configuration file needed", "results are preserved automatically"_ → name the actor and use active voice when it clarifies.

### Style patterns

14. **Em dash overuse** — replace most "—" with commas, periods, or parentheses.
15. **Boldface overuse** — strip mechanical bold; reserve for true emphasis.
16. **Inline-header bullet lists** — _"- **Performance:** …"_ → flatten into prose or remove the bold header.
17. **Title Case In Headings** → use sentence case.
18. **Decorative emojis** — strip from headings and bullets.
19. **Curly quotes "…"** → straight quotes "...".

### Communication patterns

20. **Chatbot artifacts** — _"Great question!", "I hope this helps", "Let me know if…"_ → delete entirely.
21. **Knowledge-cutoff disclaimers** — _"While specific details are limited…", "as of my last training update…"_ → delete entirely.
22. **Sycophantic openings** — _"You're absolutely right!", "Excellent point!"_ → delete entirely.

### Filler and hedging

23. **Filler phrases and business jargon** — _"in order to" → "to"; "due to the fact that" → "because"; "has the ability to" → "can"; "navigate" → "handle"; "lean into" → "accept"; "circle back" → "return to"; "deep dive" → "analysis"; "moving forward" → "next"; "at the end of the day" → drop._
24. **Excessive hedging** — _"could potentially possibly might"_ → pick one modal or state plainly.
25. **Generic positive conclusions** — _"the future looks bright", "exciting times lie ahead"_ → end on a concrete fact or stop.
26. **Hyphenated compound modifier overuse** — _cross-functional, data-driven, decision-making, well-known, real-time, end-to-end_ used uniformly → vary or drop the hyphen for common pairs.
27. **Persuasive authority tropes** — _"the real question is", "at its core", "fundamentally"_ → state the point without ceremony.
28. **Signposting and meta-commentary** — _"Let's dive in", "Here's what you need to know", "Plot twist:", "Spoiler:", "Let me walk you through…", "The rest of this essay…"_ → just start. Do not narrate the structure of the piece.
29. **Fragmented headers** — heading + one-line restating paragraph → delete the warm-up sentence.
30. **Verbose PR / MR / commit descriptions** — full templates ("Summary / Changes / Test Plan / Future Work") applied to small changes; commit bodies that re-narrate the diff → state only the _why_ and any non-obvious context. Trust the diff for the _what_.

### Voice and agency patterns

31. **False agency** — _"the decision emerges", "the data tells us", "the culture shifts", "the conversation moves toward"_ → name the actor. Decisions do not emerge; people decide.
32. **Narrator-from-a-distance** — _"Nobody designed this", "People tend to…", "This happens because…"_ → put the reader in the scene; "you" beats "people".
33. **Telling instead of showing** — _"This is genuinely hard", "The stakes are high", "This actually matters"_ → name the specific hard or important thing or cut the sentence.
34. **Performative emphasis** — _"I promise", "trust me", "creeps in"_ → cut. Earnestness does not survive being announced.

## Output Format

When humanizing in response to a request, return:

1. The draft rewrite.
2. A short bulleted answer to "What makes the draft still obviously AI-generated?" (skip if nothing remains).
3. The final rewrite (revised after the audit).
4. Optionally, a brief summary of changes if it helps the user calibrate.

When applying proactively (drafting a PR description, changelog, etc.), skip the audit framing and just produce text that already passes the checklist.

## Additional Resources

- `references/patterns.md` — full before/after examples for every pattern, plus the new vocabulary clusters.
- `references/full-example.md` — long worked example covering most patterns at once.
- Source: [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing). Wikipedia-platform-specific patterns (markup, citation, AFC drafts, wikilawyering) are intentionally omitted from this skill.
- The Quick Checks section, the 5-dimension scoring rubric, and patterns 31–34 (false agency, narrator-from-a-distance, telling-instead-of-showing, performative emphasis) are adapted from [hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop) (MIT).

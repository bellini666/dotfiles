# AI Writing Patterns: Detailed Reference

This file contains the full pattern catalog with before/after examples. SKILL.md keeps a condensed checklist; consult this file when more context, more examples, or more watch-words are needed.

**Scope note:** Wikipedia's "Signs of AI writing" page also documents Wikipedia-platform-specific patterns (markup, citations, AFC drafts, wikilawyering, talk-page artifacts). Those are intentionally omitted here because they do not apply to general prose, PRs, MRs, changelogs, or technical documentation. Do not try to "complete" the list with those.

---

## CONTENT PATTERNS

### 1. Undue Emphasis on Significance, Legacy, and Broader Trends

**Watch words:** stands/serves as, is a testament/reminder, a vital/significant/crucial/pivotal/key role/moment, underscores/highlights its importance/significance, reflects broader, symbolizing its ongoing/enduring/lasting, contributing to the, setting the stage for, marking/shaping the, represents/marks a shift, key turning point, evolving landscape, focal point, indelible mark, deeply rooted

**Problem:** LLM writing puffs up importance by adding statements about how arbitrary aspects represent or contribute to a broader topic.

**Before:**

> The Statistical Institute of Catalonia was officially established in 1989, marking a pivotal moment in the evolution of regional statistics in Spain. This initiative was part of a broader movement across Spain to decentralize administrative functions and enhance regional governance.

**After:**

> The Statistical Institute of Catalonia was established in 1989 to collect and publish regional statistics independently from Spain's national statistics office.

### 2. Undue Emphasis on Notability and Media Coverage

**Watch words:** independent coverage, local/regional/national media outlets, written by a leading expert, active social media presence

**Problem:** LLMs hit readers over the head with claims of notability, often listing sources without context.

**Before:**

> Her views have been cited in The New York Times, BBC, Financial Times, and The Hindu. She maintains an active social media presence with over 500,000 followers.

**After:**

> In a 2024 New York Times interview, she argued that AI regulation should focus on outcomes rather than methods.

### 3. Superficial Analyses with -ing Endings

**Watch words:** highlighting/underscoring/emphasizing..., ensuring..., reflecting/symbolizing..., contributing to..., cultivating/fostering..., encompassing..., showcasing...

**Problem:** AI chatbots tack present participle ("-ing") phrases onto sentences to add fake depth.

**Before:**

> The temple's color palette of blue, green, and gold resonates with the region's natural beauty, symbolizing Texas bluebonnets, the Gulf of Mexico, and the diverse Texan landscapes, reflecting the community's deep connection to the land.

**After:**

> The temple uses blue, green, and gold colors. The architect said these were chosen to reference local bluebonnets and the Gulf coast.

### 4. Promotional and Advertisement-like Language

**Watch words:** boasts a, vibrant, rich (figurative), profound, enhancing its, showcasing, exemplifies, commitment to, natural beauty, nestled, in the heart of, groundbreaking (figurative), renowned, breathtaking, must-visit, stunning

**Problem:** LLMs have serious problems keeping a neutral tone, especially for "cultural heritage" topics.

**Before:**

> Nestled within the breathtaking region of Gonder in Ethiopia, Alamata Raya Kobo stands as a vibrant town with a rich cultural heritage and stunning natural beauty.

**After:**

> Alamata Raya Kobo is a town in the Gonder region of Ethiopia, known for its weekly market and 18th-century church.

### 5. Vague Attributions and Weasel Words

**Watch words:** Industry reports, Observers have cited, Experts argue, Some critics argue, several sources/publications (when few cited)

**Problem:** AI chatbots attribute opinions to vague authorities without specific sources.

**Before:**

> Due to its unique characteristics, the Haolai River is of interest to researchers and conservationists. Experts believe it plays a crucial role in the regional ecosystem.

**After:**

> The Haolai River supports several endemic fish species, according to a 2019 survey by the Chinese Academy of Sciences.

### 6. Outline-like "Challenges and Future Prospects" Sections

**Watch words:** Despite its... faces several challenges..., Despite these challenges, Challenges and Legacy, Future Outlook

**Problem:** Many LLM-generated articles include formulaic "Challenges" sections.

**Before:**

> Despite its industrial prosperity, Korattur faces challenges typical of urban areas, including traffic congestion and water scarcity. Despite these challenges, with its strategic location and ongoing initiatives, Korattur continues to thrive as an integral part of Chennai's growth.

**After:**

> Traffic congestion increased after 2015 when three new IT parks opened. The municipal corporation began a stormwater drainage project in 2022 to address recurring floods.

---

## LANGUAGE AND GRAMMAR PATTERNS

### 7. Overused "AI Vocabulary" Words

**High-frequency AI words:** actually, additionally, align with, bolstered, crucial, delve, emphasizing, enduring, enhance, fostering, garner, highlight (verb), interplay, intricate/intricacies, key (adjective), landscape (abstract noun), meticulous, pivotal, robust, showcase, tapestry (abstract noun), testament, underscore (verb), valuable, vibrant

**Adverb crutches (a tighter sub-cluster):** really, just, literally, genuinely, honestly, simply, deeply, truly, fundamentally, inherently, inevitably, interestingly, importantly, crucially. Adverbs are not banned outright, but in AI text they almost always carry no information. Strip them on a first pass, then add back any that genuinely change meaning.

**Problem:** These words appear far more frequently in post-2023 text. They often co-occur. One or two are coincidence; clusters indicate AI writing. Wikipedia tracks shifts in this vocabulary by model generation, so the list rotates over time.

**Before:**

> Additionally, a distinctive feature of Somali cuisine is the incorporation of camel meat. An enduring testament to Italian colonial influence is the widespread adoption of pasta in the local culinary landscape, showcasing how these dishes have integrated into the traditional diet.

**After:**

> Somali cuisine also includes camel meat, which is considered a delicacy. Pasta dishes, introduced during Italian colonization, remain common, especially in the south.

### 8. Avoidance of "is"/"are" (Copula Avoidance)

**Watch words:** serves as/stands as/marks/represents [a], boasts/features/offers [a]

**Problem:** LLMs substitute elaborate constructions for simple copulas.

**Before:**

> Gallery 825 serves as LAAA's exhibition space for contemporary art. The gallery features four separate spaces and boasts over 3,000 square feet.

**After:**

> Gallery 825 is LAAA's exhibition space for contemporary art. The gallery has four rooms totaling 3,000 square feet.

### 9. Negative Parallelisms and Tailing Negations

Two distinct sub-patterns Wikipedia documents separately.

#### 9a. "Not just X, but Y" / "It's not merely X, it's Y"

**Problem:** Constructions that pretend to clear up an implied misconception nobody had.

**Before:**

> It's not just about the beat riding under the vocals; it's part of the aggression and atmosphere. It's not merely a song, it's a statement.

**After:**

> The heavy beat adds to the aggressive tone.

#### 9b. "Not X, but Y" / "no X, no Y, just Z"

**Problem:** Explicitly denies a property only to assert another, often paired in lists of three. Reads like sales copy.

**Before:**

> No fluff, no filler, just results. The tool isn't a wrapper, it's an engine.

**After:**

> The tool is fast and produces useful output without extra ceremony.

#### 9c. Tailing-negation fragments

**Problem:** Clipped fragments like "no guessing" or "no wasted motion" tacked onto a sentence instead of written as a real clause.

**Before:**

> The options come from the selected item, no guessing.

**After:**

> The options come from the selected item without forcing the user to guess.

### 10. Rule of Three Overuse

**Problem:** LLMs force ideas into groups of three to appear comprehensive.

**Before:**

> The event features keynote sessions, panel discussions, and networking opportunities. Attendees can expect innovation, inspiration, and industry insights.

**After:**

> The event includes talks and panels. There's also time for informal networking between sessions.

### 11. Elegant Variation (Synonym Cycling)

**Problem:** AI has repetition-penalty code causing excessive synonym substitution.

**Before:**

> The protagonist faces many challenges. The main character must overcome obstacles. The central figure eventually triumphs. The hero returns home.

**After:**

> The protagonist faces many challenges but eventually triumphs and returns home.

### 12. False Ranges

**Problem:** LLMs use "from X to Y" constructions where X and Y aren't on a meaningful scale.

**Before:**

> Our journey through the universe has taken us from the singularity of the Big Bang to the grand cosmic web, from the birth and death of stars to the enigmatic dance of dark matter.

**After:**

> The book covers the Big Bang, star formation, and current theories about dark matter.

### 13. Passive Voice and Subjectless Fragments

**Problem:** LLMs often hide the actor or drop the subject entirely with lines like "No configuration file needed" or "The results are preserved automatically." Rewrite these when active voice makes the sentence clearer and more direct.

**Before:**

> No configuration file needed. The results are preserved automatically.

**After:**

> You do not need a configuration file. The system preserves the results automatically.

---

## STYLE PATTERNS

### 14. Em Dash Overuse

**Problem:** LLMs use em dashes (—) more than humans, mimicking "punchy" sales writing. In practice, most of these can be rewritten more cleanly with commas, periods, or parentheses.

**Before:**

> The term is primarily promoted by Dutch institutions—not by the people themselves. You don't say "Netherlands, Europe" as an address—yet this mislabeling continues—even in official documents.

**After:**

> The term is primarily promoted by Dutch institutions, not by the people themselves. You don't say "Netherlands, Europe" as an address, yet this mislabeling continues in official documents.

### 15. Overuse of Boldface

**Problem:** AI chatbots emphasize phrases in boldface mechanically.

**Before:**

> It blends **OKRs (Objectives and Key Results)**, **KPIs (Key Performance Indicators)**, and visual strategy tools such as the **Business Model Canvas (BMC)** and **Balanced Scorecard (BSC)**.

**After:**

> It blends OKRs, KPIs, and visual strategy tools like the Business Model Canvas and Balanced Scorecard.

### 16. Inline-Header Vertical Lists

**Problem:** AI outputs lists where items start with bolded headers followed by colons.

**Before:**

> - **User Experience:** The user experience has been significantly improved with a new interface.
> - **Performance:** Performance has been enhanced through optimized algorithms.
> - **Security:** Security has been strengthened with end-to-end encryption.

**After:**

> The update improves the interface, speeds up load times through optimized algorithms, and adds end-to-end encryption.

### 17. Title Case in Headings

**Problem:** AI chatbots capitalize all main words in headings.

**Before:**

> ## Strategic Negotiations And Global Partnerships

**After:**

> ## Strategic negotiations and global partnerships

### 18. Emojis

**Problem:** AI chatbots often decorate headings or bullet points with emojis.

**Before:**

> 🚀 **Launch Phase:** The product launches in Q3
> 💡 **Key Insight:** Users prefer simplicity
> ✅ **Next Steps:** Schedule follow-up meeting

**After:**

> The product launches in Q3. User research showed a preference for simplicity. Next step: schedule a follow-up meeting.

### 19. Curly Quotation Marks

**Problem:** ChatGPT uses curly quotes ("...") instead of straight quotes ("...").

**Before:**

> He said "the project is on track" but others disagreed.

**After:**

> He said "the project is on track" but others disagreed.

---

## COMMUNICATION PATTERNS

### 20. Collaborative Communication Artifacts

**Watch words:** I hope this helps, Of course!, Certainly!, You're absolutely right!, Would you like..., let me know, here is a...

**Problem:** Text meant as chatbot correspondence gets pasted as content.

**Before:**

> Here is an overview of the French Revolution. I hope this helps! Let me know if you'd like me to expand on any section.

**After:**

> The French Revolution began in 1789 when financial crisis and food shortages led to widespread unrest.

### 21. Knowledge-Cutoff Disclaimers

**Watch words:** as of [date], Up to my last training update, While specific details are limited/scarce..., based on available information...

**Problem:** AI disclaimers about incomplete information get left in text.

**Before:**

> While specific details about the company's founding are not extensively documented in readily available sources, it appears to have been established sometime in the 1990s.

**After:**

> The company was founded in 1994, according to its registration documents.

### 22. Sycophantic/Servile Tone

**Problem:** Overly positive, people-pleasing language.

**Before:**

> Great question! You're absolutely right that this is a complex topic. That's an excellent point about the economic factors.

**After:**

> The economic factors mentioned earlier are relevant here.

---

## FILLER AND HEDGING

### 23. Filler Phrases and Business Jargon

**Before → After (filler phrases):**

- "In order to achieve this goal" → "To achieve this"
- "Due to the fact that it was raining" → "Because it was raining"
- "At this point in time" → "Now"
- "In the event that you need help" → "If you need help"
- "The system has the ability to process" → "The system can process"
- "It is important to note that the data shows" → "The data shows"

**Business jargon → plain language:**

| Avoid                 | Use instead            |
| --------------------- | ---------------------- |
| Navigate (challenges) | Handle, address        |
| Unpack (analysis)     | Explain, examine       |
| Lean into             | Accept, embrace        |
| Landscape (context)   | Situation, field       |
| Game-changer          | Significant, important |
| Double down           | Commit, increase       |
| Deep dive             | Analysis, examination  |
| Take a step back      | Reconsider             |
| Moving forward        | Next, from now         |
| Circle back           | Return to, revisit     |
| On the same page      | Aligned, agreed        |
| At the end of the day | (delete)               |
| When it comes to      | (delete)               |
| In a world where      | (delete)               |
| The reality is        | (delete)               |

### 24. Excessive Hedging

**Problem:** Over-qualifying statements.

**Before:**

> It could potentially possibly be argued that the policy might have some effect on outcomes.

**After:**

> The policy may affect outcomes.

### 25. Generic Positive Conclusions

**Problem:** Vague upbeat endings.

**Before:**

> The future looks bright for the company. Exciting times lie ahead as they continue their journey toward excellence. This represents a major step in the right direction.

**After:**

> The company plans to open two more locations next year.

### 26. Hyphenated Word Pair Overuse

**Watch words:** third-party, cross-functional, client-facing, data-driven, decision-making, well-known, high-quality, real-time, long-term, end-to-end

**Problem:** AI hyphenates common word pairs with perfect consistency. Humans rarely hyphenate these uniformly, and when they do, it's inconsistent. Less common or technical compound modifiers are fine to hyphenate.

**Before:**

> The cross-functional team delivered a high-quality, data-driven report on our client-facing tools. Their decision-making process was well-known for being thorough and detail-oriented.

**After:**

> The cross functional team delivered a high quality, data driven report on our client facing tools. Their decision making process was known for being thorough and detail oriented.

### 27. Persuasive Authority Tropes

**Phrases to watch:** The real question is, at its core, in reality, what really matters, fundamentally, the deeper issue, the heart of the matter

**Problem:** LLMs use these phrases to pretend they are cutting through noise to some deeper truth, when the sentence that follows usually just restates an ordinary point with extra ceremony.

**Before:**

> The real question is whether teams can adapt. At its core, what really matters is organizational readiness.

**After:**

> The question is whether teams can adapt. That mostly depends on whether the organization is ready to change its habits.

### 28. Signposting, Announcements, and Meta-Commentary

**Phrases to watch (signposting):** Let's dive in, let's explore, let's break this down, here's what you need to know, now let's look at, without further ado

**Phrases to watch (meta-commentary):** Plot twist:, Spoiler:, Hint:, But that's another post, The rest of this essay…, Let me walk you through…, In this section, we'll…, As we'll see…, You already know this, but…, I want to explore…

**Problem:** LLMs announce what they are about to do instead of doing it, or comment on the structure of the piece itself. This slows the writing down and gives it a tutorial-script feel. The piece should move under its own momentum, not narrate its own table of contents.

**Before:**

> Let's dive into how caching works in Next.js. Here's what you need to know. Spoiler: it's more complex than you think. Let me walk you through it.

**After:**

> Next.js caches data at multiple layers, including request memoization, the data cache, and the router cache.

### 29. Fragmented Headers

**Signs to watch:** A heading followed by a one-line paragraph that simply restates the heading before the real content begins.

**Problem:** LLMs often add a generic sentence after a heading as a rhetorical warm-up. It usually adds nothing and makes the prose feel padded.

**Before:**

> ## Performance
>
> Speed matters.
>
> When users hit a slow page, they leave.

**After:**

> ## Performance
>
> When users hit a slow page, they leave.

### 30. Verbose / Exhaustive PR, MR, and Commit Descriptions

**Signs to watch:** A 3-line code change with a 12-bullet PR description; a "Summary / Changes / Test Plan / Notes / Future Work" four-section template applied to a typo fix; a commit body that re-narrates the diff in prose ("This commit adds a new function called `foo` that takes one argument...").

**Problem:** Wikipedia documents this as "Overwhelmingly Exhaustive Edit Summaries". The LLM tendency is to expand any change into a structured, complete-looking artifact regardless of the change size. Reviewers get noise, the diff already shows the what, and the description should carry only the why and any non-obvious context.

**Before:**

> ## Summary
>
> This pull request introduces a comprehensive enhancement to the user authentication module.
>
> ## Changes
>
> - Updated `auth.py` to import the new `validate_token` helper
> - Added a call to `validate_token` in the `login` function
> - Updated the corresponding unit test to cover the new behavior
> - Ensured backward compatibility is maintained
>
> ## Test Plan
>
> - [x] Ran the existing test suite
> - [x] Added a new test case for the validation flow
> - [x] Verified manually in a local environment
>
> ## Future Work
>
> Further improvements to token rotation may be considered.

**After:**

> Reject expired tokens at login. Previously the session would refresh silently, which masked a bug in `refresh_token` we are fixing in #1284.

### 31. False Agency

**Watch words:** complaint becomes a fix, decision emerges, culture shifts, conversation moves toward, data tells us, market rewards, idea takes shape, problem reveals itself

**Problem:** Inanimate nouns get human verbs, hiding the actor. Decisions do not emerge — someone decides. Cultures do not shift on their own — people change behavior. Data does not tell anyone anything — someone reads it and draws a conclusion. AI loves this construction because it lets the sentence sound profound without committing to who did what.

**Before:**

> Once the team adopted the new process, the decision emerged that ownership should sit with engineering. The culture shifted, and the data told us we were on the right track.

**After:**

> The team adopted the new process and gave ownership to engineering. Within a quarter, on-call escalations dropped 40% — that is what convinced us it was working.

### 32. Narrator-from-a-Distance

**Watch words:** Nobody designed this, People tend to, This happens because, This is why, In general, society…

**Problem:** A disembodied lecturer voice that floats above the scene instead of putting the reader in it. Often paired with sweeping generalities about "people" or "society".

**Before:**

> Nobody designed this. People tend to optimize for the metric in front of them, and this is why teams drift toward the wrong outcomes.

**After:**

> You do not sit down on Monday and decide to optimize for the wrong thing. You pick up a dashboard, ship against the green number, and a quarter later notice the customers you were supposed to help are quieter.

### 33. Telling Instead of Showing

**Watch words:** This is genuinely hard, This is what X actually looks like, This actually matters, The stakes are high, The implications are profound

**Problem:** Sentences that announce significance, difficulty, or authenticity instead of demonstrating it. Distinct from generic positive conclusions (#25) — those puff up endings; this puffs up the body. If a sentence claims something is hard or important without naming the specific hard or important thing, cut it or replace it with the specific thing.

**Before:**

> Migrating off the legacy auth service is genuinely hard. This is what real platform work actually looks like. The stakes are high.

**After:**

> Migrating off the legacy auth service touches every service that calls `verify_session`, and three of them have no test coverage. We will be reading prod traffic to figure out what they actually do.

### 34. Performative Emphasis and Manufactured Sincerity

**Watch words:** I promise, They exist, I promise, creeps in, trust me, you have to believe me, I'm not kidding

**Problem:** Phrases that simulate intimacy or earnestness. They appear when the writing has nothing concrete to offer and tries to compensate with tone. The reader either trusts the writer or does not — repeating "I promise" does not move the needle and reads as AI hedging dressed up as voice.

**Before:**

> There are real benefits to this approach, I promise. The complexity creeps in slowly, but trust me, the payoff is worth it.

**After:**

> The approach pays off once the test suite is in place. Without tests, the same complexity will eat any team alive within six months — I have watched it happen twice.

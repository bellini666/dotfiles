---
name: debugging
description: "This skill should be used when the user asks to 'debug this', 'fix this bug', 'why is this broken', 'fix CI', 'pipeline failure', 'fix failing tests', 'investigate this error', 'not working', or when troubleshooting unexpected behavior, exceptions, or runtime errors."
---

# Systematic Debugging

## Core Principle

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

Never apply symptom-focused patches that mask underlying problems. Understand WHY something fails before attempting to fix it.

## The Four-Phase Framework

### Phase 1: Root Cause Investigation

Before touching any code:

1. **Read error messages thoroughly** - Every word matters
2. **Reproduce the issue consistently** - Without reproduction, verification is impossible
3. **Examine recent changes** - What changed before this started failing?
4. **Gather diagnostic evidence** - Logs, stack traces, state dumps
5. **Trace data flow** - Follow the call chain to find where bad values originate
6. **Timebox** - Spend ~5 minutes max investigating, then form a hypothesis and proceed to Phase 3

**Root Cause Tracing Technique:**

```
1. Observe the symptom - Where does the error manifest?
2. Find immediate cause - Which code directly produces the error?
3. Ask "What called this?" - Map the call chain upward
4. Keep tracing up - Follow invalid data backward through the stack
5. Find original trigger - Where did the problem actually start?
```

**Key principle:** Never fix problems solely where errors appear—always trace to the original trigger.

### Scope Guards

- Investigate only the failing component — don't trace into unrelated services or modules
- When a test fails, assume the test is correct until proven otherwise
- Don't explore "the full architecture" — focus on the specific failure path

### Phase 2: Pattern Analysis

1. **Locate working examples** - Find similar code that works correctly
2. **Compare implementations completely** - Don't just skim
3. **Identify differences** - What's different between working and broken?
4. **Understand dependencies** - What does this code depend on?

### Phase 3: Hypothesis and Testing

Apply the scientific method:

1. **Formulate ONE clear hypothesis** - "The error occurs because X"
2. **Design minimal test** - Change ONE variable at a time
3. **Predict the outcome** - What should happen if hypothesis is correct?
4. **Run the test** - Execute and observe
5. **Verify results** - Did it behave as predicted?
6. **Iterate or proceed** - Refine hypothesis if wrong, implement if right

### Phase 4: Implementation

1. **Create failing test case** - Captures the bug behavior
2. **Implement single fix** - Address root cause, not symptoms
3. **Verify test passes** - Confirms fix works
4. **Run full test suite** - Ensure no regressions
5. **If fix fails, STOP** - Re-evaluate hypothesis

**Critical rule:** If THREE or more fixes fail consecutively, STOP. This signals architectural problems requiring discussion, not more patches.

## Red Flags - Process Violations

Red flags to watch for:

- "Quick fix for now, investigate later"
- "One more fix attempt" (after multiple failures)
- "This should work" (without understanding why)
- "Let me just try..." (without hypothesis)
- "It works on my machine" (without investigating difference)
- "Let me adjust the test to match the new behavior"
- "Let me check this other service/stage too"
- "Let me understand the full architecture first"

## Warning Signs of Deeper Problems

**Consecutive fixes revealing new problems in different areas** indicates architectural issues:

- Stop patching
- Document what you've found
- Discuss with team before proceeding
- Consider if the design needs rethinking

## Common Debugging Scenarios

### Test Failures

Start by reading the FULL error message and stack trace — every word matters, especially the assertion diff and the specific line that failed. Identify which assertion failed and what the actual vs expected values were. Often the assertion message alone points to the root cause.

Next, verify the test environment: check that fixtures are returning the expected data, mocks are configured correctly, and any database state or factory setup matches what the test assumes. A common pitfall is a fixture that was modified for another test, silently breaking downstream tests.

Finally, trace the unexpected value backward through the code. If the test expected `200` but got `403`, don't just check the view — trace through middleware, authentication, and permissions to find where the request gets rejected.

### Runtime Errors

Capture the full stack trace and identify the exact line that throws. Check what values are `None`, undefined, or otherwise unexpected at the point of failure.

Trace backward from the crash site: where was the bad value assigned? Where was it passed from? Follow the chain until you find the original source — this is where the fix belongs. Never add a `None` check at the crash site as a band-aid; fix the code that produced the `None` in the first place.

### "It worked before"

Use `git bisect` (or `jj` equivalent) to find the breaking commit. This is faster than guessing — even a 1,000-commit range narrows to the culprit in ~10 steps.

Compare the breaking change with the previous working version. The bug is in the difference between the two. Identify what assumption changed (API contract, data shape, configuration default) and fix at the source of the assumption violation, not at the symptom.

### Intermittent Failures

Intermittent failures almost always stem from one of four causes: race conditions, shared mutable state, async ordering assumptions, or timing dependencies. Investigate in that order.

Look for shared state between tests (class variables, module-level caches, database rows not cleaned up). Check for async operations that assume execution order. Examine whether tests depend on wall-clock time or external service availability.

Fix with deterministic synchronization (locks, barriers, proper `await`) rather than `sleep()` — sleep-based fixes are fragile and slow down the test suite.

## Debugging Checklist

Before claiming a bug is fixed:

- [ ] Root cause identified and documented
- [ ] Hypothesis formed and tested
- [ ] Fix addresses root cause, not symptoms
- [ ] Failing test created that reproduces bug
- [ ] Test now passes with fix
- [ ] Full test suite passes
- [ ] No "quick fix" rationalization used
- [ ] Fix is minimal and focused

## Success Metrics

Systematic debugging achieves ~95% first-time fix rate vs ~40% with ad-hoc approaches.

Signs of effective debugging:

- Fixes don't create new bugs
- The root cause can be clearly explained
- Similar bugs don't recur
- Code is better after the fix, not just "working"

## Integration

- Use **/fix** command for end-to-end bug fix workflow
- Use **writing-tests** for test patterns and conventions

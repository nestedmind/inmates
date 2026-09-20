---
name: systematic-debugging
description: Use when you meet any bug, test failure, or unexpected behavior, before you propose a fix.
---

# Systematic Debugging

Adapted from `skills/systematic-debugging/` in obra/superpowers (MIT, Jesse Vincent). See `THIRD_PARTY.md`.

Guessing at fixes wastes time and creates new bugs. Find the root cause first.

## The rule

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

Until you finish Phase 1, do not propose a fix.

## When to use

Use it for every technical problem: test failures, production bugs, unexpected behavior, performance problems, build failures, integration issues.

Use it most when you are under time pressure, when a quick fix looks obvious, when you have already tried a fix that failed, or when you do not understand the problem. Simple bugs have root causes too, and rushing produces rework.

## The four phases

Finish each phase before you start the next.

### Phase 1: Root cause investigation

Before you try any fix:

1. **Read the errors.** Read every error message, warning, and stack trace to the end. Note line numbers, file paths, and error codes. They often name the cause.
2. **Reproduce it.** Find exact steps that trigger the problem every time. If you cannot reproduce it, gather more data before you guess.
3. **Check recent changes.** Look at the git diff, recent commits, new dependencies, config changes, and differences in environment.
4. **Instrument component boundaries.** If the system has several components (CI, build, signing; or API, service, database), log what enters and leaves each one and check that config and environment reach each layer. Run once, see where the data goes wrong, then investigate that component.
5. **Trace the data flow.** When the error sits deep in a call stack, ask where the bad value starts and what passed it in, and keep going up until you reach the source. Fix the source.

### Phase 2: Pattern analysis

1. Find similar code that works in the same codebase.
2. If you are following a reference implementation, read all of it.
3. List every difference between the working and the broken case, however small.
4. Note what the code depends on: other components, settings, environment, assumptions.

### Phase 3: Hypothesis and testing

1. State one hypothesis in writing: "I think X is the root cause because Y."
2. Make the smallest change that tests it, and change one variable at a time.
3. If it worked, go to Phase 4. If it did not, form a new hypothesis and do not stack more fixes on top.
4. If you do not understand something, say so, research it, or ask for help.

### Phase 4: Implementation

1. **Write a failing test** that reproduces the bug in the simplest way. Use an automated test if the project has a framework and a one-off script if it does not. Write it before the fix.
2. **Make one fix** for the root cause. Skip the "while I'm here" cleanups and the bundled refactoring.
3. **Verify.** The new test passes, no other test breaks, and the original problem is gone. Run the checks and read their output before you say it works.
4. **If the fix fails,** stop and count your attempts. Under three, return to Phase 1 with what you learned. At three, go to the next section and make no fourth attempt.

### After three failed fixes

Three failed fixes point to a design problem. Watch for these signs:

- Each fix exposes shared state or coupling somewhere else.
- Each fix needs a large refactor.
- Each fix creates a new symptom elsewhere.

Ask whether the pattern is sound or whether you keep it out of inertia. Take the question to the person you work with before you try anything more. This is a wrong design, and a new hypothesis will not fix it.

## Red flags

If you think any of these, stop and return to Phase 1:

- "Quick fix now, investigate later."
- "Just try changing X and see."
- "Change several things and run the tests."
- "Skip the test, I'll check by hand."
- "It's probably X."
- "I don't fully understand it, but this might work."
- "One more attempt" after two failures.
- A proposed solution before you traced the data flow.

Signals from the person you work with mean the same thing. "Is that not happening?" means you assumed without checking. "Stop guessing" means you proposed a fix without understanding. "We're stuck?" means your approach is not working.

## Common excuses

| Excuse | Reality |
|--------|---------|
| "The issue is simple." | Simple issues have root causes, and the process is quick for them. |
| "It's an emergency." | Systematic debugging is faster than guessing and rechecking. |
| "Try this first, then investigate." | The first fix sets the pattern. Start right. |
| "I'll write the test after the fix works." | Untested fixes do not last, and a test written first proves the fix. |
| "Several fixes at once saves time." | You cannot tell which one worked, and you may add bugs. |
| "I'll adapt the pattern without reading it all." | Partial understanding produces bugs. |
| "I see the problem." | Seeing a symptom is not knowing the cause. |

## When there is no root cause

Sometimes the cause is environmental, timing-dependent, or external. Then document what you investigated, add handling (a retry, a timeout, a clear error message), and add logging so the next occurrence carries more evidence. Most "no root cause" cases are unfinished investigations, so check before you settle on this.

## Quick reference

| Phase | Activities | Done when |
|-------|-----------|-----------|
| 1. Root cause | Read errors, reproduce, check changes, gather evidence | You know what fails and why |
| 2. Pattern | Find working examples, compare | You have listed the differences |
| 3. Hypothesis | Form a theory, test it minimally | It is confirmed or replaced |
| 4. Implementation | Write test, fix, verify | Bug gone, tests pass |

---
name: code-review
description: Use when requesting or performing a balanced, cooperative code review of finished work against its requirements, such as after completing a feature, before merging, or when asked to review a diff.---

# Code Review (requesting and giving)

Adapted from `skills/requesting-code-review/` in obra/superpowers (MIT, Jesse Vincent). See `THIRD_PARTY.md`.

Catch problems before they cascade into more work. The reviewer gets precisely crafted context about the change, never the author's session history.

**Scope of this skill:** this is the balanced, cooperative reviewer. It grades by real severity, credits what is good, and gives a clear verdict. An adversarial, evidence-hunting reviewer is a different procedure and is not covered here. Handling the feedback you get back is the companion skill `receiving-code-review`.

**Core principle:** review early, review often.

## Part 1: Requesting a review

### When to request

Mandatory:
- After each task when work is split into tasks
- After completing a major feature
- Before merging to the main branch

Optional but valuable:
- When stuck (a fresh perspective)
- Before a refactor (a baseline check)
- After fixing a complex bug

### How to request

1. Pin the range under review:

```bash
BASE_SHA=$(git merge-base origin/main HEAD)   # or the commit before your work started
HEAD_SHA=$(git rev-parse HEAD)
```

2. Give the reviewer (a subagent, or a person) the review brief in Part 2, filled in:
   - `[DESCRIPTION]`: brief summary of what you built
   - `[PLAN_OR_REQUIREMENTS]`: what it should do (ticket text, plan path, or task text)
   - `[BASE_SHA]` and `[HEAD_SHA]`: the range

   Pass the work product and the requirements, not your reasoning or session history. That keeps the reviewer judging the change, not your thought process.

3. Act on the feedback (see `receiving-code-review` for how to evaluate it):
   - Fix Critical issues immediately
   - Fix Important issues before proceeding
   - Note Minor issues for later
   - Push back, with reasoning, if the reviewer is wrong

### Red flags

Never:
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

If the reviewer is wrong: push back with technical reasoning, show code or tests that prove it works, and ask for clarification.

## Part 2: Giving a review (the reviewer's brief)

Fill in and follow this brief when you are the reviewer.

```
You are a senior code reviewer with expertise in software architecture,
design patterns and best practices. Review completed work against its plan
or requirements and identify issues before they cascade.

## What was implemented
[DESCRIPTION]

## Requirements / plan
[PLAN_OR_REQUIREMENTS]

## Git range to review
Base: [BASE_SHA]
Head: [HEAD_SHA]

    git diff --stat [BASE_SHA]..[HEAD_SHA]
    git diff [BASE_SHA]..[HEAD_SHA]
```

### The spec is a vision document

The spec says what the software must do. It does not list every input, environment or condition the software will meet. For behavior the spec is silent on, judge by what a reasonable person using the software would expect. A reasonable person's expectation is a requirement, and a spec's silence is not permission. Grade such findings by their effect on that person, not by whether the spec mentions the trigger.

### Declined to judge

Before your verdict, list every behavior you considered and set aside as outside the plan or spec, one line each, with the reason. The author rules on each line, so nothing you set aside is dropped silently. An empty list means you set nothing aside.

### Read-only review

Your review is read-only on the checkout. Do not change the working tree, the index, HEAD or branch state. Inspect history with `git show`, `git diff` and `git log`. If you need a working copy of another revision, create it in a separate temporary directory (for example `git worktree add <tmpdir>/review-<sha> <sha>`) and never move HEAD on the reviewed checkout.

### You do not dispatch subagents

Do the whole review yourself. Never spawn a subagent to review part of the diff, and never spawn another reviewer for a second opinion. The process already provides every review seat the work gets. A reviewer you spawn duplicates one of them at full cost, and its verdict counts for nothing. If the diff is too large for one pass, review it in passes yourself and say so in your report.

### What to check

Plan alignment:
- Does the implementation match the requirements?
- Are deviations justified improvements or problematic departures?
- Is all the planned functionality present?

Code quality:
- Clean separation of concerns?
- Proper error handling?
- Type safety where applicable?
- DRY without premature abstraction?
- Edge cases handled?

Architecture:
- Sound design decisions?
- Reasonable scalability and performance?
- Security concerns?
- Integrates cleanly with surrounding code?

Testing:
- Do tests verify real behavior, not mocks?
- Are edge cases covered?
- Are there integration tests where they matter?
- Do all tests pass?

Production readiness:
- Migration strategy if a schema changed?
- Backward compatibility considered?
- Documentation complete?
- No obvious bugs?

### Calibration

Categorize issues by actual severity. Not everything is Critical. Acknowledge what was done well before listing issues, because accurate praise helps the author trust the rest of the feedback.

If you find significant deviations from the plan, flag them so the author can confirm whether they were intentional. If the problem is with the plan itself rather than the implementation, say so.

### Output format

```
### Strengths
[What is done well. Be specific.]

### Issues

#### Critical (must fix)
[Bugs, security issues, data loss risks, broken functionality]

#### Important (should fix)
[Architecture problems, missing features, poor error handling, test gaps]

#### Minor (nice to have)
[Style, optimization opportunities, documentation polish]

For each issue:
- File:line reference
- What is wrong
- Why it matters
- How to fix (if not obvious)

### Declined to judge
[One line per set-aside behavior, with the reason. Empty if none.]

### Recommendations
[Improvements to code quality, architecture or process]

### Assessment
Ready to merge? [Yes | No | With fixes]
Reasoning: [1-2 sentence technical assessment]
```

Rules:
- Do: categorize by real severity, cite file:line, explain why each issue matters, acknowledge strengths, give a clear verdict.
- Do not: say "looks good" without checking, mark nitpicks Critical, comment on code you did not read, be vague ("improve error handling"), or avoid a verdict.

### Example output

```
### Strengths
- Clean database schema with proper migrations (db.ts:15-42)
- Comprehensive test coverage (18 tests, all edge cases)

### Issues

#### Important
1. Missing help text in CLI wrapper
   - File: index-conversations:1-31
   - Issue: no --help flag, so users will not discover --concurrency
   - Fix: add a --help case with usage examples

2. Date validation missing
   - File: search.ts:25-27
   - Issue: invalid dates silently return no results
   - Fix: validate ISO format, throw an error with an example

#### Minor
1. Progress indicators
   - File: indexer.ts:130
   - Issue: no "X of Y" counter for long operations
   - Impact: users cannot tell how long to wait

### Declined to judge
- Choice of SQLite over Postgres: an architecture decision the plan fixed.

### Assessment
Ready to merge? With fixes
Reasoning: The core implementation is solid with good tests. The Important
issues are easy fixes and do not affect the core functionality.
```

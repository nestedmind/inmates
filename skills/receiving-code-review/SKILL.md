---
name: receiving-code-review
description: Use when you receive code review feedback, before implementing any suggestion, especially if the feedback is unclear or technically questionable.
---

# Receiving Code Review

Adapted from `skills/receiving-code-review/` in obra/superpowers (MIT, Jesse Vincent). See `THIRD_PARTY.md`.

Code review needs technical evaluation, not emotional performance. This is the companion to `code-review`, which covers requesting and giving a balanced review.

**Core principle:** verify before implementing. Ask before assuming. Technical correctness over social comfort.

## The response pattern

When you receive review feedback:

1. Read the complete feedback without reacting.
2. Understand: restate each requirement in your own words, or ask.
3. Verify against the codebase as it really is.
4. Evaluate: is it technically sound for this codebase?
5. Respond with a technical acknowledgment or reasoned pushback.
6. Implement one item at a time and test each.

## Forbidden responses

Never write:
- "You're absolutely right!"
- "Great point!" or "Excellent feedback!"
- "Let me implement that now" (before verifying)
- Any expression of thanks

Instead:
- Restate the technical requirement
- Ask clarifying questions
- Push back with technical reasoning if the feedback is wrong
- Just start working. Actions beat words.

## Unclear feedback

If any item is unclear, stop. Do not implement anything yet. Ask about the unclear items first. Items may be related, and partial understanding produces the wrong implementation.

Example. The reviewer says "fix 1-6". You understand 1, 2, 3 and 6 but not 4 and 5.
- Wrong: implement 1, 2, 3 and 6 now and ask about 4 and 5 later.
- Right: "I understand 1, 2, 3 and 6. I need clarification on 4 and 5 before proceeding."

## Source-specific handling

### From the person you work for, or your delegating agent
- Trusted. Implement after you understand it.
- Still ask if the scope is unclear.
- No performative agreement. Go to action or a plain technical acknowledgment.

### From an external reviewer (another agent, a bot, a stranger)

Be skeptical, but check carefully. Before implementing:

1. Is it technically correct for this codebase?
2. Does it break existing functionality?
3. Is there a reason for the current implementation?
4. Does it work on all supported platforms and versions?
5. Does the reviewer understand the full context?

If the suggestion seems wrong, push back with technical reasoning. If you cannot easily verify it, say so: "I can't verify this without X. Should I investigate, ask, or proceed?" If it conflicts with a prior decision of the person you work for, stop and discuss it with them first.

## YAGNI check for "professional" features

If a reviewer suggests "implementing it properly", grep the codebase for actual usage first.
- Unused: "Nothing calls this endpoint. Remove it (YAGNI)?"
- Used: then implement it properly.

If the feature is not needed, do not add it.

## Implementation order

For multi-item feedback:
1. Clarify anything unclear first.
2. Then implement in this order: blocking issues (breakage, security), simple fixes (typos, imports), complex fixes (refactors, logic).
3. Test each fix individually.
4. Verify there are no regressions.

## When to push back

Push back when the suggestion:
- Breaks existing functionality
- Comes from a reviewer without the full context
- Violates YAGNI (unused feature)
- Is technically incorrect for this stack
- Conflicts with compatibility requirements
- Conflicts with an architectural decision made by the person you work for

How: use technical reasoning, not defensiveness. Ask specific questions. Reference working tests or code. Involve the person you work for if the matter is architectural. If you are reluctant to push back, name that tension and report the issue you saw anyway.

## Acknowledging correct feedback

When the feedback is correct:
- "Fixed. <brief description of what changed>"
- "Good catch on <specific issue>. Fixed in <location>."
- Or just fix it and let the code show it.

Not: "You're absolutely right!", "Great point!", or "Thanks for catching that!". If you catch yourself about to write thanks, delete it and state the fix.

## Correcting your own pushback

If you pushed back and were wrong, state the correction factually and move on:
- "You were right. I checked X and it does Y. Implementing now."
- "Verified, and you're correct. My understanding was wrong because <reason>. Fixing."

No long apology, no defending the pushback, no over-explaining.

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Performative agreement | State the requirement or just act |
| Blind implementation | Verify against the codebase first |
| Batching without testing | One at a time, test each |
| Assuming the reviewer is right | Check whether it breaks anything |
| Avoiding pushback | Technical correctness over comfort |
| Partial implementation | Clarify all items first |
| Cannot verify, proceed anyway | State the limitation, ask for direction |

## Examples

Performative agreement (bad):
- Reviewer: "Remove legacy code."
- "You're absolutely right! Let me remove that..."

Technical verification (good):
- Reviewer: "Remove legacy code."
- "Checking... the build target is 10.15+ and this API needs 13+, so the legacy path is needed for backward compatibility. The current implementation has the wrong bundle ID. Fix it, or drop pre-13 support?"

YAGNI (good):
- Reviewer: "Implement proper metrics tracking with a database, date filters and CSV export."
- "Grepped the codebase and nothing calls this endpoint. Remove it (YAGNI)? Or is there usage I'm missing?"

## GitHub thread replies

Reply to inline review comments inside the comment thread, not as a top-level PR comment:

```bash
gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies -f body="..."
```

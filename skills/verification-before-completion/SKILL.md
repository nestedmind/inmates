---
name: verification-before-completion
description: Use before claiming work is complete, fixed or passing, and before committing or opening a PR. Requires running the verifying command and reading its output first.
---

# Verification Before Completion

Adapted from `skills/verification-before-completion/` in obra/superpowers (MIT, Jesse Vincent). See `THIRD_PARTY.md`.

Claiming work is done without checking it wastes the reviewer's time and erodes trust. Run the check, read the output, then make the claim.

## The rule

No completion claim without fresh verification evidence. If you have not run the verifying command in this turn, you cannot say it passes. The rule covers exact phrases, paraphrases and any wording that implies success.

## The gate

Before you claim a status or express satisfaction:

1. Identify the command that proves the claim.
2. Run the full command, fresh.
3. Read all the output, check the exit code and count the failures.
4. Compare the output to the claim. If it does not confirm the claim, report the actual status with the evidence.
5. If it confirms, state the claim together with the evidence.

## What each claim needs

| Claim | Requires | Does not suffice |
|-------|----------|------------------|
| Tests pass | Test command output showing 0 failures | An earlier run, "should pass" |
| Linter clean | Linter output showing 0 errors | A partial check, extrapolation |
| Build succeeds | Build command exits 0 | Passing lint, plausible logs |
| Bug fixed | The original symptom re-tested and gone | Code changed, fix assumed |
| Regression test works | Red-green cycle verified (below) | One passing run |
| Delegated work done | The VCS diff shows the changes | The agent reports success |
| Requirements met | A line-by-line check against the ticket | Passing tests |

## Red-green for regression tests

Write the test and run it (pass). Revert the fix and run it again (it must fail). Restore the fix and run it (pass). A test that never failed proves nothing.

## Red flags

Stop and verify if you catch yourself:

- writing "should", "probably" or "seems to"
- saying "Great!", "Perfect!" or "Done!" before checking
- about to commit, push or open a PR without a fresh run
- trusting an agent's success report
- relying on a partial check
- thinking "just this once", or feeling tired and wanting to finish

## Excuses

| Excuse | Reality |
|--------|---------|
| "Should work now" | Run the check. |
| "I'm confident" | Confidence is not evidence. |
| "The linter passed" | A linter does not compile. |
| "The agent said it worked" | Check the diff yourself. |
| "A partial check is enough" | A partial check covers only part. |
| "I used different words" | The rule covers the meaning. |

## When to apply

Before any success or completion claim, any positive statement about the state of the work, a commit, a PR, moving to the next task, or handing work to another agent.

## Related skills

`receiving-code-review` applies the same habit to feedback: check a reviewer's claim against the code before you accept or dismiss it. The "Verify before you dismiss, and before you accept" section of `copilot-pr-review` applies this gate to automated review findings and points back here.

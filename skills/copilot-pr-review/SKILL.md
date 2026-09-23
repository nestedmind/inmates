---
name: copilot-pr-review
description: Use when the owner asks for a GitHub Copilot code review on a pull request, to request it, wait for the posted review, and handle its findings before merging.
---

# Copilot PR review coordination

**Default: Copilot review runs only when the owner asks for it.** Earlier versions of this skill had coders run Copilot rounds 1 and 2 on every pull request. That rule is removed. Without a request from the owner, do not request Copilot review, and do not wait for one. The reviewer persona's approval, described in the `coordinator` skill, is the normal gate.

When the owner does ask, this skill covers the mechanics, how the rounds are handled, and how to judge Copilot's findings.

Copilot can be requested, checked too early, and wrongly written off as unavailable. This skill exists so that mistake does not repeat: a review that was skipped in that way had missed a real concurrency bug.

## The mechanism

- The reviewer login is `copilot-pull-request-reviewer`, not `copilot`. Requesting `copilot` fails.
- Copilot reviews merged and closed pull requests too, which allows a retroactive pass.
- It is not automatic. It reviews a pull request only when asked.
- It takes time to post, about 90 to 120 seconds from request to a submitted review.

## The wrong way to check

```bash
gh pr edit <n> --repo <owner>/<repo> --add-reviewer copilot-pull-request-reviewer
gh pr view <n> --repo <owner>/<repo> --json reviewRequests --jq '.reviewRequests'
# => [] almost at once. Copilot picked up the request and left the pending
#    list before it posted anything.
```

An empty `reviewRequests` list means "not pending", and says nothing about whether a review is coming. Reading it as "Copilot is not available here" is the mistake to avoid.

## The right way

1. Request review when the owner asks and the pull request is ready:
   ```bash
   gh pr edit <n> --repo <owner>/<repo> --add-reviewer copilot-pull-request-reviewer
   ```

2. Wait for a posted review, and ignore the request state. Poll the `reviews` list for an entry from that login and budget about 2 minutes:
   ```bash
   for i in $(seq 1 36); do   # 36 x 5 s = 3 minutes at most
     gh pr view <n> --repo <owner>/<repo> --json reviews \
       --jq '.reviews[] | select(.author.login == "copilot-pull-request-reviewer")' \
       2>/dev/null | grep -q . && break
     sleep 5
   done
   ```
   The loop stops after 3 minutes. If no review has posted by then, say so and ask the owner whether to wait longer. Do not conclude Copilot is unavailable. Run the poll in the background if you have other work while it posts, and leave no poll running when you finish.

3. Read Copilot's findings before you finalize your own review. The review body carries a verdict line and inline comments on specific lines. Treat them as input, the way you would read a colleague's review before adding yours.

4. Review the diff yourself on top of it. Copilot at its lightest effort level yields about one real finding per pull request, and it does not replace a careful read of concurrency, security and cross-file consistency.

5. If any review requests changes, fix them and request again from step 2.

6. Cap review cycles at 5 in total, counted across every round, whoever ran it and whether the reviewer was Copilot or the reviewer persona. Past the cap, make the call yourself and say so, or escalate for a decision.

## Who handles which round

The rounds follow the same ladder as the reviewer protocol in the `coordinator` skill. They apply only after the owner has requested Copilot.

- Rounds 1 and 2: the coder handles Copilot's findings directly against the false-positive list below, fixes what is real and requests again. Escalate sooner when a finding might be a false positive that is not on the list, touches a security or concurrency property, or conflicts with a project convention the coder is unsure of.
- Round 3 to 5: the coordinator takes over. When escalating, state the round number so the running count stays accurate.
- Past round 5: the coordinator escalates to the owner.

Whoever reviews at any round still reads the actual diff. This split decides who answers Copilot and skips nothing else.

## Known false-positive patterns

Keep a running list for your project. When a Copilot finding turns out to be wrong, add it, so the next round does not argue the same point again. A list entry does not settle a finding. Confirm that this instance fits before dismissing it (see the next section).

The entries below are worked examples from one project, and each rests on that project's own conventions. They are not universal. Check whether the convention holds in your project before you borrow one.

- **"This needs a database migration."** In the example project, migrations are generated at deploy time and not shipped as files, so Copilot raised this on every schema change. The dismissal cited the generation step. In a project that does ship migration files, this finding is usually right.
- **"This will break at class setup"** for a forward-referenced type in an ORM model. In the example project the file already deferred annotation evaluation and guarded the import for type checking, so the reference resolved when the ORM needed it. The evidence was a passing test that built and queried the model, since a real setup error would have failed it.
- **A generic "needs a closer look" verdict with zero new inline comments**, mostly on security-adjacent code. In the example project this canned caveat fired regardless of diff quality. The count of new comments (zero) was the signal, and the prose verdict was not a finding.

## Verify before you dismiss, and before you accept

This section is the review-specific form of the general rule in `verification-before-completion`: claims need fresh evidence before you act on them. If that skill is installed, follow it, and read this section as its application to review findings. If it is not installed, this section stands alone.

- Before dismissing a finding, including one that matches the list above, verify it against the current code. If you say the project generates migrations at deploy time, confirm the generation step exists. If you say an annotation pattern is fine, point to a passing test that exercises it. A dismissal reply cites the evidence and does more than name the pattern.
- Before accepting a finding, especially one that says something is "already broken", "pre-existing" or "also affects X elsewhere", check the claim. Confirm a bug on the main branch with `git show origin/main:<path>` before folding an unrelated fix into your pull request. For a described race or ordering bug, trace the code path by hand or write the regression test first, because a scenario can sound plausible and still not match the code.
- If you are unsure on something that matters (security, data loss, auth bypass, concurrency), escalate it and do not guess.

## Skip the review after a zero-risk fix

A purely cosmetic fix (a docstring, a rename, a comment) does not need a new Copilot round. Run the tests and move on, and batch the fix with the next substantive push. Request Copilot again only after a push that changed behavior.

## Check for human comments too

A poll for `copilot-pull-request-reviewer` misses a comment that a person left on the diff, because that is a different reviewer. A pull request can pass Copilot while a human question sits unanswered.

Before merging, on every pull request, list the non-Copilot review comments:

```bash
gh api repos/<owner>/<repo>/pulls/<n>/comments \
  --jq '.[] | select(.user.login != "Copilot") | "\(.user.login): \(.body)"'
```

Answer each one before merging. Reply on the thread (`gh api ... /replies` with `-f body=...`) the way you would for a Copilot finding. A missed comment leaves no trace, so make the check routine.

## Retroactive recovery

If Copilot review was skipped on already-merged pull requests, the owner can ask for a pass on each. It works on merged pull requests and can surface findings worth filing as follow-up issues.

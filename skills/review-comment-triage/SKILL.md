---
name: review-comment-triage
description: Use when a pull request has received review comments from a human or an automated reviewer and you are about to act on them.
---

# Review comment triage

Use this when a pull request has review comments from any reviewer, human or automated, and you are the one responding. It covers how to read, sort, fix, disagree and reply. It does not cover how to request or wait for a specific automated reviewer.

## Relation to the Copilot review skill

This skill and `copilot-pr-review` cover different layers and do not conflict.

- `copilot-pr-review` owns the Copilot mechanics: the reviewer login, requesting the review, polling until a real review is posted, and the playbook for Copilot false positives. None of that is repeated here.
- This skill owns what happens once comments exist: the triage order, the authority hierarchy, the reply and commit conventions.

When Copilot's findings arrive, apply this skill to them like any other reviewer's comments. Use the Copilot skill's false-positive playbook to judge whether a finding is real, then use the disagreement rules below to push back if it is not. Round caps and escalation rules for Copilot rounds live in the Copilot skill; do not restate or override them here.

## Step 1: Read everything before touching any file

```bash
gh pr view <PR> --comments
gh api repos/<owner>/<repo>/pulls/<PR>/comments   # inline review comments
gh pr view <PR> --json reviews                    # review bodies and verdicts
```

Read the whole set first. Comments often overlap or contradict, and a fix made before reading everything may need undoing.

## Step 2: Categorise every comment before writing code

**BLOCKER** - must be fixed before merge:
- Violates a rule in the project rules file
- Security vulnerability
- Functional bug or incorrect logic
- Missing or failing test
- Breaks a convention set in the product spec or scaffolding docs
- Hardcoded credentials or secrets

**SUGGESTION** - worth fixing, not blocking:
- Style improvement the project rules do not cover
- Readability improvement
- Minor refactor with no behaviour change

**QUESTION** - needs a reply, not a code change:
- A request for clarification
- A "why did you do X?" comment

Write the categorised list out, with each comment's ID beside it. Where a human owns the decision, share the list and wait for confirmation before writing code. Where you are working autonomously, record the list in your notes or in a PR comment and proceed.

## Step 3: Fix blockers first, suggestions second

- Fix one comment at a time.
- Run the project's tests after every blocker fix.
- After each fix, search the codebase for the same pattern and fix every occurrence, not only the flagged line.
- Never batch fixes and test once at the end.

## Step 4: Handle disagreements

You do not have to agree with every comment, but you must not ignore one.

Fix without discussion:
- Anything that violates the project rules file
- Security vulnerabilities
- Confirmed functional bugs
- Missing tests

You may push back, with reasoning, on:
- Stylistic preferences the project rules do not cover
- Alternatives that are not clearly better
- Suggestions that contradict an explicit decision in the product spec
- Refactors outside the scope of the ticket

When you push back, reply on the comment thread with your reasoning:

```
Disagree, because <reason>. <Why the current approach is correct.>
Happy to discuss if you see it differently.
```

When in doubt, flag it to the person who owns the decision instead of deciding alone.

### Hierarchy of authority

When sources conflict, the higher tier wins:

1. Project rules file (the standing rules for the repo, whatever the project calls it, such as AGENTS.md or CONTRIBUTING.md): always followed.
2. Product spec or ticket decisions: product decisions, followed.
3. Human reviewer comments: followed unless they contradict tier 1 or 2. If they do, say so in the reply and escalate.
4. Automated reviewer suggestions: followed if valid, pushed back on if not.
5. Your own judgment: defer to the tiers above when unsure.

The project's owner has the final say on any disagreement.

## Step 5: Reply to every comment

After fixing, reply on each thread, including suggestions and questions:

```bash
gh api repos/<owner>/<repo>/pulls/<PR>/comments/<ID>/replies \
  -f body="Fixed in <commit-hash>. <One sentence on what changed.>"
```

Never leave a comment without a reply, and never make a change you do not understand the reason for.

## Step 6: Commit and re-request review

- One commit per fix. Do not bundle fixes.
- Message format: `fix: <what was fixed> - address PR review comment`.
- After pushing, re-request review from the reviewer whose comments you addressed, then wait for their response.

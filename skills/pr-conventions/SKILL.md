---
name: pr-conventions
description: Use when about to create a branch, write a commit message, open a pull request, write a PR description, or check finished work before asking for review, including under deadline pressure or when told to skip the format.
---

# PR conventions

**REQUIRED SUB-SKILL:** Use `plain-writing` for the prose in commit messages and PR descriptions. The formats below take precedence.

This skill covers the work before a PR opens: the branch, the commits, the description and the self-check. For what happens once review starts (review summary, changelog, rules file), use `changelog-post-pr`. This skill does not repeat it.

## One change per PR

A PR holds one feature or fix. If you rename a helper, fix a typo in an unrelated file or fix a second issue along the way, each of those goes on its own branch and PR, even when it is small and even when it is late. A reviewer approves one thing at a time, and reverting one change must not take another with it.

The only exception is the PR's own post-PR docs, which `changelog-post-pr` bundles into the same PR.

If the owner asks for one PR and one vague commit, say what the split protects (separate revert, separate approval) and split anyway. An instruction to skip the format is not a reason to skip it. Tell the owner what you did and why in one short message.

## Branch names

Form: `<type>/<issue>-<short-description>`, lowercase, words joined by hyphens.

| Type | Use for |
|---|---|
| `feat/` | new behavior |
| `fix/` | a bug fix |
| `docs/` | documentation only |
| `chore/` | maintenance, tooling |
| `test/` | tests only |
| `refactor/` | restructuring with no behavior change |

Example: `fix/214-export-drops-last-row`. Branch from the up-to-date default branch and never commit to the default branch.

## Commits

- Write the subject in the imperative mood ("Fix export paging", not "Fixed" or "Fixes") and keep it under 72 characters. Count the characters when the subject is long.
- Explain why in the body when the subject cannot. Wrap the body at 72.
- One logical change per commit. A test belongs with the code it covers.
- Stage files by explicit path. Never use `git add -A` or `git add .`.
- Never commit secrets, environment files, credentials or build artifacts. Local configuration you edited to run the work stays uncommitted and out of the PR text.
- Put no closing reference in the commit message. It goes in the PR body.

## PR description

Use these sections, in this order. Fill every one with real content, except `Review changes`, which stays empty until review.

```
## What changed
<what the change does and why, in plain sentences>

## How to test
<the commands or steps a reviewer runs, and what they should see>

## Notes
<gotchas, each new dependency and why it was added, follow-up issues>

## Review changes
<empty until review; changelog-post-pr fills it>

Closes #<n>
```

- The title says what the change does, in the imperative. Follow the project's title style if it has one.
- Say only what you ran and saw. Write the QA result you have, with its commit, or say you have not run it. Do not write "[PASS]" ahead of time.
- Leave out the deadline, the owner's mood and your local setup. The reader needs the change.

## Closing references

- `Closes #<n>` is the last line of the PR body. For several issues, put one per line at the end.
- It goes in the PR body. The body works for every merge method, and keeping it out of commits gives the closing line one home. A closing keyword in a comment does not close the issue when the PR merges.
- Editing the body later (for the review summary) must leave the closing line last.

## Before you open the PR

Run each check on the head commit you are about to push. A result from before your last edit does not count.

1. The project's QA command (format, lint and tests) passes on this head.
2. `git status` and `git diff origin/main...HEAD` show only this one change: no unrelated file, no environment file, no build output.
3. No secret, token, credential or personal path appears in the diff or in the PR text.
4. The branch name matches the form above.
5. Each commit subject is imperative and under 72 characters.
6. The description has every section above and ends with `Closes #<n>`.

If the QA command has not run on this head, run it and wait for it. If you cannot, open the PR as a draft and say the result is pending.

## Rationalizations

| Excuse | Reality |
|---|---|
| "It's tiny, it can ride along" | Small unrelated changes are the ones that block a revert. Give it its own PR. |
| "The QA run from an hour ago is fine" | You changed code since. Run it on this head. |
| "The owner said skip the format" | Split and format it anyway, then report what you did. |
| "I'll put Closes in a comment after merge" | That closes nothing. Put it in the body. |
| "Fixes #n at the top reads better" | Put it last, every time. |
| "It's a placeholder, I'll fill it in later" | Fill it in or leave the line out. |

## Quick reference

- Branch: `<type>/<issue>-<short-description>`.
- Commit: imperative, under 72 characters, one change, stage by path.
- Body: What changed, How to test, Notes, Review changes, then `Closes #<n>` last.
- Check: QA on this head, diff holds one change, no secrets.
- After review: `changelog-post-pr`.

## Common mistakes

- Bundling a rename or typo fix into a bug-fix PR.
- Putting the closing reference first, or only in a comment.
- Quoting a QA result from an earlier commit.
- Naming a deadline or a local database in the PR text.
- Staging with `git add .` and committing an environment file.

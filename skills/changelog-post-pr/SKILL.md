---
name: changelog-post-pr
description: Use when a pull request has its approvals and is about to merge, when writing or reviewing a CHANGELOG.md entry, when asked to record what a PR changed and why, or at the start of a session to check that recently merged PRs did not skip their changelog entry.
---

# Changelog and post-PR process

**REQUIRED SUB-SKILL:** Use `plain-writing` for the prose inside changelog entries and review summaries. The entry format below takes precedence.

A merged PR is not finished until the project's written record reflects it. This skill is the procedure for closing that gap: which files to update, in what order, and why it all belongs in the PR being merged rather than in a follow-up.

## The one rule that matters

Do the post-PR docs inside the same PR, before merging. Push them as extra commits to the open PR branch, let CI and review settle, then merge.

Do not merge first and circle back. Do not open a separate `chore/` PR for it. The split is how these updates go missing: once the PR is merged the urgency is gone, the next ticket starts, and the entry never gets written.

This is a standing exception to "one change per PR". Docs that describe a PR belong to that PR and need no separate ticket or PR. If your process approves a specific head, the docs commits change the head, so re-confirm approval before merging (see step 4).

Do this without being asked. A review loop is not complete until it is done.

## Steps

Run these once the PR has the approvals it needs and before you merge.

### 1. Update the rules file

The rules file is whatever your project keeps standing instructions in (`CLAUDE.md`, `AGENTS.md`, a contributing guide).

For each mistake caught in review that is a recurring pattern, not a one-off, add a rule. Check it is genuinely new first:

```bash
grep -n "<keyword>" CLAUDE.md
```

No duplicates. If review caught nothing recurring, change nothing and say so in the review summary. Do not invent rules to have something to add.

### 2. Add a review summary to the PR description

Add a `Review changes` section to the PR body, above any closing reference such as `Closes #<n>`:

```
## Review changes
- <commit-sha> - <what was fixed and why>
- <commit-sha> - <what was fixed and why>
- <what was pushed back on, and the reason>
```

List pushbacks as well as fixes. A reader should see what the reviewer raised and what you did about each item. Update the body with `gh pr edit <n> --body "<full body>"`, and confirm the closing reference is still the last line afterward, because a closing keyword only works from the PR body.

### 3. Update CHANGELOG.md

If there is no `CHANGELOG.md`, create one at the project root. Add entries under the current release or milestone heading, in the format below.

### 4. Commit each doc file separately, then merge

One commit per file, so each is easy to review and revert on its own:

```bash
git add CLAUDE.md
git commit -m "chore: update CLAUDE.md with rules from PR #<n> review"

git add CHANGELOG.md
git commit -m "chore: update CHANGELOG with PR #<n> changes and decisions"

git push
```

Wait for CI to pass on the new head, then merge. If your process requires a fresh approval on the current head, the docs commits count as new commits, so get that approval before merging.

## Changelog format

The base is [Keep a Changelog](https://keepachangelog.com/en/1.0.0/): sections named `Added`, `Changed`, `Fixed`, grouped under a release or milestone heading, one bullet per change, newest first.

This process adds one section: **Decisions recorded**.

```
## <release or milestone heading>

### PR #<n> - <title>

#### Added
- <new features or files introduced in this PR>

#### Changed
- <things changed, including from review feedback; always cite the PR number>

#### Fixed
- <bugs or security issues, including ones caught in review>

#### Decisions recorded
- <a design or architecture decision, with the reasoning, not only the outcome>
```

Omit any section that has nothing in it.

### Why "Decisions recorded" exists

Plain Keep a Changelog records what changed. Six months later the question is almost never "what changed" (the diff says that) but "why did we do it this way, and what did we reject". That reasoning lives in review threads and chat, and it is lost when they are.

Each entry in this section is a decision plus its reason. If you can only write the outcome, you have not recorded a decision yet.

Weak:

```
- Used a transaction for the job publish.
```

Strong:

```
- Commit the job row before publishing to the queue. The reverse order let
  a fast consumer look the job up before the row was visible and drop it
  silently. The cost is that a publish failure now leaves a committed but
  unpublished row, which is visible and recoverable, unlike a silent drop.
```

Good candidates: a choice between two real options, a tradeoff you accepted knowingly, a rule that is now enforced and why, a review finding you declined and the reasoning. Cross-reference an entry from `Fixed` or `Changed` when the reasoning is long (for example "see Decisions recorded").

### Writing entries

- Say what a reader would notice or need to know, not which files moved.
- Cite the PR or issue number on every bullet you can.
- Record findings from automated review as well as human review, and mark them, so the trail shows what each pass caught.
- Use only real PR numbers and real history. When adapting this skill, never carry over example numbers, milestones or names from another project as if they were literal.

## Session-start safety net

Bundling the docs into each PR should make gaps rare, but work merged before this process existed, or merged elsewhere, can still be missing entries. At the start of a session, after the usual `git fetch origin` and worktree cleanup:

```bash
gh pr list --state merged --limit 5
```

For each recently merged PR, check:

- `CHANGELOG.md` has an entry for it.
- The rules file was updated if review found a recurring pattern.
- The PR description has a `Review changes` section.

If something is missing, do the catch-up as its own small `chore/` PR before starting new work. This is the one case where a separate docs PR is right, because the original PR is already merged and cannot carry it. Then create or confirm the issue for the task you are about to start, so the new PR has something to close.

## Relation to the product-update pattern

A separate pattern exists for a coordinator: a `PRODUCT_UPDATE.md` running log, kept by a coordinator on a multi-ticket backlog. It is a close cousin of the changelog, and the two are related competencies, not one.

| | Changelog (this skill) | Product update |
|---|---|---|
| Written by | The engineer who authored the PR | The coordinator |
| Cadence | One entry per PR, at merge time | Periodic, timestamped roll-up across many PRs |
| Unit | A single change | A stretch of work: counts, themes, what was found |
| Audience | Anyone reading the repo's history | Whoever decides what happens next |
| Answers | What changed in this PR, and why | Where the whole effort stands, what surprised us, what is still open |
| Lives | In the PR that made the change | Alongside the project, newest entry first |

What they share: both record the why and not only the what, both name open gaps honestly, and both exist because the record decays if it is written later.

How they fit together: the changelog is the ground-level record, and the product update is built on top of it. A coordinator writing a product update should draw on the changelogs' "Decisions recorded" entries and the tracker instead of re-deriving events from memory. The product update adds what no single PR can hold: cross-PR discoveries (an issue closed on the tracker while a sibling code path never got the fix), process changes, and known open gaps.

Decision: keep them as two skills. This one covers the per-PR changelog and post-PR bundling, and is complete on its own. A product-update skill, if added, would reference this one and would not duplicate it. It is out of scope here.

## Checklist

- [ ] Rules file: new recurring-pattern rules added, or explicitly none.
- [ ] PR description has `Review changes`, including pushbacks, and the closing reference is still last.
- [ ] `CHANGELOG.md` entry added with real PR numbers, including `Decisions recorded` where a decision was made.
- [ ] Each doc file is its own commit, pushed to the open PR branch.
- [ ] CI is green and approval covers the current head, then merge.

---
name: worktree-parallel-work
description: Use when starting any task that changes code, when dispatching parallel subagents, or when finishing a branch. Covers worktree isolation, the session-start checklist, when parallel work is safe, and how to integrate and clean up.
---

# Worktree and Parallel Work

The isolation-detection, parallel-dispatch and finishing parts adapt `skills/using-git-worktrees/`, `skills/dispatching-parallel-agents/` and `skills/finishing-a-development-branch/` in obra/superpowers (MIT, Jesse Vincent). See `THIRD_PARTY.md`. The session-start checklist, one-worktree-per-issue rule and removal discipline come from the project's own worktree habits.

Assume someone else may be working in the main checkout right now, whether a developer or another session. Do your work in a worktree of your own so the main checkout stays free.

## 1. Detect existing isolation (from superpowers)

Check before you create anything, because you may already be in a worktree.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" && pwd -P)
git rev-parse --show-superproject-working-tree
```

- If the last command prints a path, you are inside a submodule. Its `GIT_DIR` and `GIT_COMMON` are equal, so it looks like a main checkout, and this check comes first. Treat it as an ordinary checkout and create a worktree only if the task needs one.
- Otherwise, if `GIT_DIR` differs from `GIT_COMMON`, you are in a linked worktree. Work here and create no other.
- Otherwise they match and you are in the main checkout. Make a worktree before you change any file.

A harness may have placed you in a worktree already. Trust that, and do not nest another inside it.

## 2. Create the worktree

Prefer the harness's native tool (for example a worktree-entering tool or an isolation option on the agent) over raw git, because the harness then tracks and cleans it up. Fall back to git only when no native tool exists.

Session-start checklist, in this order, before you touch a file:

```bash
git fetch origin
git worktree list
git worktree prune
git worktree add ../<repo>-<branch-slug> -b <type>/<issue>-<slug> origin/main
```

1. Fetch, so the branch starts from current work.
2. List, to see worktrees left by earlier sessions.
3. Prune, to drop entries whose directories are gone.
4. Start from an issue. Name the branch for it (`feat/12-login-retry`).
5. Add the worktree, outside the main checkout.

Rules:

- One worktree per issue. Never reuse a worktree for a different issue.
- If a worktree already exists for the branch, use it. Never create a duplicate.
- If the worktree lives inside the repository, confirm its directory is git-ignored before you create it.
- Run the project's setup step inside the new worktree, then run the tests once to get a clean baseline. If the baseline fails, report that before you change anything.
- Do all work, commits and pushes from inside the worktree. Do not `cd` back to the main checkout mid-task.

## 3. Parallel dispatch

Several agents can each take a worktree and work at once. That helps only when the work is independent.

Dispatch in parallel when:

- The tasks touch different files or subsystems.
- Each task can be understood without the results of the others.
- The tasks share no state: no database, port, cache, container name or generated file.

Work serially, or investigate together first, when:

- One failure may cause the others, so fixing one may fix all.
- The tasks edit the same files or depend on each other's output.
- You do not yet know what is broken.

Give each agent one focused scope, the constraints it must respect (what not to touch), and the output you expect back. Give each its own worktree. After the agents return, read each summary, check for conflicts, and run the full suite before you trust the combination.

### Shared state outside git

A worktree isolates files and nothing else. Two worktrees still share the machine, and that is where parallel work goes wrong.

A concrete case: parallel streams of work each ran a Docker Compose stack, and one stream never set its own Compose project name. Its stack collided with another stream's stack on the same machine, because Compose derives container, network and volume names from the project name. The tasks were independent on paper and still interfered. Give each worktree its own project name (`COMPOSE_PROJECT_NAME=<repo>-<branch-slug>`) and its own host ports before any stack starts.

Before you dispatch, list what each task starts or writes outside the tree (containers, ports, local databases, caches, temp paths) and give each worktree its own value for every item.

## 4. Finish the branch (from superpowers)

Run the project's tests first. If they fail, fix them before you offer options.

Then choose one path:

1. Push and open a pull request. This is the default when the project uses review.
2. Merge locally into the base branch, then run the tests again on the merged result.
3. Keep the branch as it is, and leave the worktree in place.

Do not merge locally when the project requires review, and never push to the default branch unless told to.

## 5. Remove the worktree

After the pull request merges, and only then, you may leave the worktree for the main checkout. Remove the worktree and confirm it is gone:

```bash
cd <main checkout>
git worktree remove ../<repo>-<branch-slug>
git worktree list
```

- Remove it only after the merge. Keep the worktree if you chose option 3, or if review may send you back to it.
- If `git worktree remove` refuses because of uncommitted or untracked files, stop and look at them. Never add `--force` to get past the refusal. Commit or deliberately discard the files first, and remove the worktree only when you know nothing is lost.
- Delete the local branch after removal. A squash merge leaves the branch "not fully merged" to git, so `git branch -d` refuses. Confirm the pull request merged, then use `git branch -D <branch>`. The remote branch is separate; delete it only if the host has not already.
- Prune at the next session start to catch anything a crash left behind.

## Quick reference

| Situation | Action |
|-----------|--------|
| In a linked worktree already | Work there, create none |
| In the main checkout | Run the checklist, add a worktree |
| Worktree exists for the branch | Use it |
| Tasks share state or files | Work serially |
| Tasks are independent | One worktree each, separate ports and names |
| Merged | Remove the worktree, delete the branch |
| Remove refuses | Inspect the files, never force |

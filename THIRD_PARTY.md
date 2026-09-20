# Third-party attribution

This file lists skills adapted from other projects. Each adapted skill also carries an "adapted from X (MIT)" note in its own body.

Update this file whenever a skill lands that comes from an outside source.

## obra/superpowers

Source: https://github.com/obra/superpowers
Author: Jesse Vincent
License: MIT
Copyright: Copyright (c) 2025 Jesse Vincent

Skills adapted from this project are listed below.

- `skills/writing-skills`, adapted from `skills/writing-skills/SKILL.md` upstream. Changes: removed the superpowers namespace and cross-skill references, dropped the multi-runtime path references (Claude Code and Codex only), and folded the testing methodology into the skill body.
- `skills/code-review/`, adapted from `skills/requesting-code-review/` and its `code-reviewer.md` template. Changes: merged the reviewer template into the skill body, removed superpowers plan paths and the coordinator-dispatch rationalization, and added a note that this is the balanced reviewer.
- `skills/receiving-code-review/`, adapted from `skills/receiving-code-review/`. Changes: replaced "your human partner" with role-neutral wording and dropped the instruction-file reference.
- `skills/systematic-debugging/`, adapted from `skills/systematic-debugging/SKILL.md` upstream. Changes: replaced superpowers skill references and "your human partner" with role-neutral wording, condensed the body into one file, and left out the supporting technique files (root-cause tracing, defense in depth, condition-based waiting) and the pressure-test files.
- `skills/test-driven-development/`, adapted from `skills/test-driven-development/SKILL.md` upstream. Changes: swapped the TypeScript examples for Python with pytest, replaced the flowchart with a numbered list, replaced "your human partner" with role-neutral wording, and folded the key rules of upstream `writing-good-tests.md` into a short "Good tests" section.
- `skills/verification-before-completion/`, adapted from `skills/verification-before-completion/SKILL.md` upstream. Changes: removed the emphasis and code-fence formatting, tightened the tables, and added a related-skills note that ties it to `receiving-code-review` and `copilot-pr-review`.
- `skills/worktree-parallel-work/`, adapted from `skills/using-git-worktrees/`, `skills/dispatching-parallel-agents/` and `skills/finishing-a-development-branch/` upstream. Changes: merged the three into one skill, kept the isolation-detection step and the finishing menu, added a session-start checklist and removal discipline from the project's own worktree habits, and added a shared-state warning with a Docker Compose example.
- `skills/planning-and-reporting/`, adapted from `skills/brainstorming/`, `skills/writing-plans/`, `skills/executing-plans/` and `skills/subagent-driven-development/` upstream. Changes: consolidated four skills into one and kept the spike/bounded/architectural classification with approval gates, the plan quality rules, the ledger with `Ruling:` lines and the final whole-branch review. Dropped per-step subagent dispatch, step-level plans with pasted code, the five-round fix loop, model selection and the never-pause rule, because the coordinator flow in `skills/scofield` already covers dispatch and review. The reasoning is recorded in the skill body.

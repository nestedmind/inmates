---
name: planning-and-reporting
description: Use when turning an idea or request into signed-off tickets, writing a plan that spans several tickets, tracking multi-ticket progress across context loss, or reporting results to the owner.
---

# Planning and Reporting

Adapted from `skills/brainstorming/`, `skills/writing-plans/`, `skills/executing-plans/` and `skills/subagent-driven-development/` in obra/superpowers (MIT, Jesse Vincent). See `THIRD_PARTY.md`.

This skill covers the coordinator's planning and reporting work: deciding how much design a request needs, writing the plan as tickets, keeping progress in a file that survives context loss, and reporting to the owner. Dispatch, review rounds and merging stay in `coordinator`. Roles (owner, coordinator, coder, reviewer) are the ones that skill defines.

## Why this is one skill with a subset of upstream

Upstream ships four skills that form one machine: brainstorm, write a plan of 2 to 5 minute steps with full code, then either run it inline or dispatch a fresh implementer and a task reviewer for every step, all without stopping to ask the owner. I compared it with the flow in `coordinator` and kept the parts that add something.

Kept:

- The three-path classification and its approval gates. `coordinator` starts from tickets the owner has signed off on but says nothing about how a request becomes a ticket.
- Plan quality rules: right-sized tasks, no placeholders, a self-review pass.
- The ledger with `Ruling:` lines, adapted to the status file `coordinator` already asks for.
- The final whole-branch review, with severity re-grading and Minor findings deferred to the ledger.
- The "Rulings I made" and "Deferred minors" lists in the closing report.

Left out, with the reason:

- Fresh implementer plus task reviewer per plan step. In this team a ticket is the unit of dispatch, and each ticket's pull request already gets a full review from the reviewer. A second review per step would repeat it at several times the cost.
- Plans written as 2 to 5 minute steps with the code included. The coder reads the ticket itself and works test first under `test-driven-development`. Code pasted into a ticket goes stale, and the coder cannot check it against the codebase it lands in.
- Inline plan execution as its own skill. A coder working one ticket is already executing inline, and `test-driven-development` and `verification-before-completion` are the per-step gates.
- The five-round fix loop with resumed implementers and model escalation. `coordinator` already has its own review-round ladder (coder and reviewer for rounds 1 and 2, coordinator for 3 to 5, then the owner).
- Upstream's ban on parallel implementers. Here each ticket has its own worktree and branch, so independent tickets run side by side.
- Never pausing for the owner, and deciding conflicts alone. `coordinator` confirms with the owner before each new round of spawned work, and scope and architecture belong to the owner. Rulings here cover only what a ticket leaves open (see "The ledger").

Revisit this choice if the team moves to plans of many small steps executed by one long-lived agent. Upstream's per-step review and resumable execution would then earn their cost.

## 1. Classify the request

Decide the path before any implementation, and tell the owner which one you chose so they can override it. If hidden complexity shows up once work starts, upgrade the path and say so. Never downgrade it.

**Spike.** The question is "can we do X?", and the output is an answer, not code that ships. Write a probe of 2 or 3 sentences (the question, how you will test it, what result ends it). Get the owner's approval, investigate cheaply, then report what you found. Throwaway code stays out of the main branch.

**Bounded.** A well-scoped change to existing code, such as a new flag, a small endpoint or a one-file fix. Ask the clarifying questions the request leaves open, write a short design in chat, and get explicit approval. Then write one ticket.

**Architectural.** A new project, or a change that restructures how components relate. Work through these in order:

1. Read the existing code, docs and recent history.
2. Ask clarifying questions, one at a time.
3. Propose 2 or 3 approaches with their tradeoffs and a recommendation.
4. Present the design in sections and check each with the owner.
5. Write the spec, run the self-review below, and get the owner's approval of the written spec.
6. Write the plan.

Each gate needs the owner's explicit sign-off. Silence, or agreement with a different question, does not count. Follow the patterns already in the codebase, and give each component one job and a clear interface.

## 2. Write the plan as tickets

For a bounded request the plan is one ticket. For an architectural one it is a short plan document (or an epic ticket) that lists the tickets in order, followed by the tickets themselves.

A plan document opens with the goal in one sentence, the spec it argues from, the constraints that bind every ticket (exact values, formats, conventions), and a map of which files each ticket creates or changes. Two tickets that touch the same file or interface say what one produces and the other consumes, and the second depends on the first.

Each ticket:

- Delivers something that can be tested and reviewed on its own. If it needs two pull requests, split it. If it is a two-line change that always ships with a neighbor, merge them.
- States acceptance criteria a reviewer can check against the diff.
- Names its dependencies. A ticket whose blocker has not merged does not start.
- Leaves the implementation steps to the coder.

No placeholders. "TBD", "handle errors appropriately", "add validation" and "similar to ticket 3" all push a decision onto the coder that the plan was supposed to make. Write the exact value, error case or rule. If the owner has not decided it yet, say so and stop.

### Self-review before sign-off

1. Every requirement in the spec maps to a ticket. List any that do not.
2. No placeholders remain.
3. Names, interfaces and values agree across tickets (a function called one thing in ticket 2 and another in ticket 4 is a bug in the plan).
4. Each ticket's acceptance criteria can be tested.
5. Name five inputs or situations the tests will probably miss (empty, huge, concurrent, malformed, repeated) and check that some ticket covers each one that matters.

Fix what you find, then send the plan to the owner.

## 3. The ledger

Conversation memory does not survive compaction, and a coordinator that lost its place has re-dispatched work that already merged. Keep a ledger file outside your context. It can be the status file `coordinator` describes, kept in a git-ignored path and never committed.

- Line one names the plan (`# Ledger: <plan or epic>`).
- One line per ticket when it changes state: ticket, pull request, review round, what it waits on. A merged ticket gets `Ticket <n>: complete (PR <m>)`.
- After compaction, trust the ledger and `git log` over memory. Resume at the first ticket without a completion line, and do not re-dispatch a completed one.

### Rulings

A ticket will leave some things open. When the answer is inside the ticket's scope and cheap to undo, decide it and write a line:

`Ruling: <what you decided> - <why> - <what it costs if wrong>`

The spec is the binding authority, the plan argues from it, and your judgment covers what neither settles. A ruling never changes scope, architecture, a public interface or the acceptance criteria. Those go to the owner, as does anything irreversible, security-sensitive, or with effects outside the worktree that would normally need asking first (a merge to a shared branch, a publish).

## 4. Final review of a multi-ticket plan

Each ticket's pull request is already reviewed. When the last ticket of a plan merges, run one more review of the combined result, since problems can sit between tickets.

1. Review the whole range from the commit before the first ticket to the current head, using `code-review`. Point the reviewer at the ledger's `Ruling:` and deferred lines.
2. Re-grade each finding by what a reasonable user gets if it ships. A reviewer who rates a finding Minor because the spec did not name the input has graded the spec.
3. Put Critical and Important findings into one fix ticket, each with a test that fails first. Do not open one ticket per finding.
4. Minor findings go to the ledger as `minor (deferred): <one line>` and to the owner in the report. Do not fix them silently.
5. A finding you decide not to fix gets a `Ruling:` line saying why the code stands.

## 5. Reporting to the owner

Report at merges, escalations and blockers, as `coordinator` says. The closing report for a plan carries these, all drawn from the ledger:

- What shipped: tickets and pull request numbers.
- Rulings I made: every `Ruling:` line in order, each with its cost if wrong. The owner reads this list to find and undo what you got wrong, so it must be complete.
- Deferred minors: every deferred line.
- Open items: parked findings and anything waiting on the owner.

Write it in plain sentences. Lead with the number of tickets merged, then the lists. Say what was verified and how (see `verification-before-completion`), and claim only states you checked.

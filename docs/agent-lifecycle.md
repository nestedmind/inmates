# Agent lifecycle: persistent or fresh dispatch

When you stand up a team of agents, you decide for each role whether to start it once and keep it alive, or to start a new agent for every task. The choice follows how the role gets used. A role's importance does not enter into it.

This page gives the rule, the reasons behind it, and a worked example using the team from `skills/scofield/SKILL.md`. If your team uses other names, map your roles onto the example by their usage.

## The rule

Ask how the role is called on.

- Other agents or people call on it repeatedly, at unpredictable times, and remembering earlier context helps. Make it a **persistent, named agent**.
- It does one bounded piece of work per dispatch and reports back. Make it a **fresh dispatch per task**, and put anything worth remembering in its skill file.

## Persistent, named agent

Start the agent once through your harness's persistent or named-agent mechanism. Address it by name from then on, and keep it alive for the life of the project.

This fits a role whose value builds up over many exchanges:

- A standing reviewer reviews pull request after pull request. It already knows what adversarial review means on this project, so each review starts from that shared understanding.
- An advisor or teacher is consulted directly by the human. The value is in the back-and-forth, and it depends on the agent remembering what it already explained or was already asked.

Both roles get pinged by several parties at times nobody can predict. A fresh agent would need the same background restated on every call, and a persistent one keeps it.

## Fresh dispatch per task

Start a new agent for each task, hand it the task, collect its report, and let it end. This fits implementers, whose work comes one ticket at a time. Four reasons favor it.

**It starts with no inherited history.** The coder reads the ticket itself, from the source, on every dispatch. A coordinator's summary of a ticket can be wrong, and a coder that carries no assumptions checks the summary against the ticket and the code. This is a safety property of the design. A fresh coder has caught a mistake in a coordinator's issue text and overridden it because the codebase said otherwise. A long-lived coder that had absorbed the coordinator's framing would be less likely to notice.

**Context stays bounded.** A single process that handles dozens of tasks accumulates history until the harness compacts it, and compaction loses detail. A coordinator that runs for a long time eventually hits this. Fresh dispatch spares every coder from it.

**Each task can be audited alone.** One dispatch yields one worktree, one pull request and one report. Nothing blends into a long running history that someone must untangle later.

**Replacement costs nothing.** If a coder fails, times out or gets swapped for another model, the next dispatch loses nothing, because the agent never held anything the repo did not.

### Where cross-task knowledge goes

Sometimes it would help if a coder learned a codebase's idioms over time. Write that knowledge into a skill or conventions file that every dispatch reads. A file is portable, reviewable in a pull request, and survives the loss of any one agent. This is also the premise of this whole repo: reusable knowledge lives in skills, and no single running agent holds it.

## Worked example

The example team maps onto the rule like this.

| Persona | Role | Lifecycle | Why |
|---|---|---|---|
| Tbag | Standing reviewer | Persistent | Reviews every pull request and gains from keeping its standards and the project's history |
| Linc | Advisor | Persistent | The human consults it repeatedly, and it remembers earlier advice |
| Sara | Teacher | Persistent | Its explanations build on what the learner already covered |
| Sucre, Mahone, Sheba, Whip | Coders | Fresh dispatch | One ticket each, read from source, isolated, reported once |
| Scofield | Coordinator | Your call | See below |

The coordinator sits between the two patterns. It lives across the whole project, so it usually runs as the main session, and it has to protect its context from filling up. `skills/scofield/SKILL.md` covers this by keeping coordination state in a status file outside the session, so a compaction does not lose it.

To map your own team, sort each role by its usage. A role that several agents or people address over time, and that gains from memory, goes with Tbag, Linc and Sara. A role that takes one bounded task and reports goes with the coders.

## Roles that could go either way

A role can change pattern as its use changes. A reviewer that a project calls on twice a month gains little from staying alive, and a fresh dispatch that reads the review skill each time costs less. A coder that a human starts to consult daily about one codebase behaves like an advisor. When a role's usage changes, move it.

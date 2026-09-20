# Limitations

This page lists what is untested or does not work yet. Experimentation continues, and contributions are welcome. See [CONTRIBUTING.md](../CONTRIBUTING.md).

## Tested on one machine

Everything here was tried on a single Linux machine with Claude Code. Nobody has run it on macOS, Windows, a virtual machine, a container or a remote development setup, so any of those may fail in ways this repo does not describe. If you try one, open an issue with what you did and what happened.

## Codex path is unverified

The repo ships a Codex manifest at `.codex-plugin/plugin.json`, and it points at the same `skills/` directory that Claude Code reads. Codex was not installed on the machine that wrote it, so the load step has never been run. The README says the same.

## Live agents end with the session

An agent you start inside a Claude Code session lives as long as that session. When the session closes, the agent is gone, along with anything it remembered. Work that has to outlast a session belongs in the repo, in an issue, or in a status file that a new session can read.

## Persistent agents are addressed by id, not name

A persistent agent, such as a standing reviewer, receives messages through `SendMessage` with its agent id. A persona's name does not route a message to it. Record each id when you start the agent, and pass it to whoever needs to reach it. See [agent-lifecycle.md](agent-lifecycle.md) for which roles should persist.

## GitHub comments do not reach a running session

An @-mention in an issue or pull request does not wake a session on your machine. See the Limitations section of the README for the workarounds.

## Approvals go stale on every push

The repo's ruleset dismisses a pull request approval each time someone pushes to the branch. After every push, ask the reviewer to review again, and merge only on an approval for the current head.

## Merges can be blocked by a permission check

Claude Code can refuse a coder's `gh pr merge` even after the reviewer has approved. When that happens, the coder stops and reports the block to whoever coordinates the work, and that person merges or changes the permission. The coder does not retry the command or look for another way to merge.

## Spawn commands

`/inmates:spawn-tbag`, `/inmates:spawn-linc` and `/inmates:spawn-sara` start a persona as a background agent. In the Claude Code version we tested, the Agent tool has no name option, so you reach the agent by its id, not by name. Ask the main session to relay: "Ask Tbag <id>: ...". The commands set a name only when the tool accepts one.

## Onboarding

The onboarding skill has been pressure-tested with subagents that answer for the person, and it has not been run end to end on a clean machine with a real person. The steps for that run are in the pull request that added it. The onboarding skill writes a project-local file the agent definitions read on their own initiative. Nothing enforces that a coder reads it, so the coordinator puts the commands in each dispatch prompt.

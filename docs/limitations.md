# Limitations

This page lists what is untested or does not work yet. Experimentation continues, and contributions are welcome. See [CONTRIBUTING.md](../CONTRIBUTING.md).

## Tested on one machine

Everything here was tried on a single Linux machine with Claude Code. Nobody has run it on macOS, Windows, a virtual machine, a container or a remote development setup, so any of those may fail in ways this repo does not describe. If you try one, open an issue with what you did and what happened.

## Codex path is unverified

The repo ships a Codex manifest at `.codex-plugin/plugin.json`, and it points at the same `skills/` directory that Claude Code reads. Codex was not installed on the machine that wrote it, so the load step has never been run. The README says the same.

## Live agents end with the session

An agent you start inside a Claude Code session lives as long as that session. When the session closes, the agent is gone, along with anything it remembered. Work that has to outlast a session belongs in the repo, in an issue, or in a status file that a new session can read.

## GitHub comments do not reach a running session

An @-mention in an issue or pull request does not wake a session on your machine. See the Limitations section of the README for the workarounds.

## Approvals go stale on every push

The repo's ruleset dismisses a pull request approval each time someone pushes to the branch. After every push, ask the reviewer to review again, and merge only on an approval for the current head.

## Merges can be blocked by a permission check

Claude Code can refuse a coder's `gh pr merge` even after the reviewer has approved. When that happens, the coder stops and reports the block to whoever coordinates the work, and that person merges or changes the permission. The coder does not retry the command or look for another way to merge.

## Spawn commands

`/larceny:spawn-tbag`, `/larceny:spawn-linc` and `/larceny:spawn-sara` start a persona as a background agent. See "Addressing a persona" and "Auto-spawn on first mention" in [agent-lifecycle.md](agent-lifecycle.md) for how to reach one afterward.

## Install and default agent are untested on a clean machine

The plugin loads and its agents resolve under `claude -p --plugin-dir`. Nobody has yet run `/plugin install` on a clean machine, checked a fresh interactive session, or piloted the team in a second project. Those runs are the checklist in [smoke-test.md](smoke-test.md). The plugin does not make Scofield the default agent. See the README for how to opt in.

## Agents and commands are Claude Code only

Codex reads `skills/`. It has no path here for the agents or the spawn commands.

## The full team needs a git repository

The project must be a git repository with at least one commit, because each coder works in its own worktree. Nobody has yet dispatched a coder in a folder that is not a repository or in a repository with no commits, so this page does not say what you would see.

## Only GitHub Projects boards are tested

Every board step in the plugin uses GitHub Projects. Linear through its MCP server is untested; the spike in [#72](https://github.com/nestedmind/larceny/issues/72) will test it.

## Onboarding

The onboarding skill has been pressure-tested with subagents that answer for the person, and it has not been run end to end on a clean machine with a real person. The steps for that run are in [smoke-test.md](smoke-test.md), Part 3. The onboarding skill writes a project-local file the agent definitions read on their own initiative. Nothing enforces that a coder reads it, so the coordinator puts the commands in each dispatch prompt.

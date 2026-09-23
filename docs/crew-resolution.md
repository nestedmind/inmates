# Crew resolution

This page is the one place that says how Larceny finds the value of a person-level or crew-level setting. Every path that reads one of these keys follows this page and does not restate the rule: coder dispatch, the reviewer, advisor and teacher spawn commands, the auto-spawn path in [agent-lifecycle.md](agent-lifecycle.md), and the coordinator's own identity resolution in `commands/wake-up.md` and `agents/coordinator.md`. A new agent type that needs one of these keys follows this page too. `scripts/resolve-crew.sh <key> [project-dir]` is a reference implementation of it, and `scripts/check-crew-resolution.sh` tests it.

## The two files

- The project file, `.larceny/config.md` in the main checkout (`git worktree list` shows where; a fresh worktree lacks the gitignored folder).
- The global file, `global-config.md` in `~/.config/larceny/`, or in `LARCENY_CONFIG_DIR` when that is set (the same directory as the persona tokens). Find it with `"${LARCENY_CONFIG_DIR:-$HOME/.config/larceny}/global-config.md"` in a shell command, since the variable is set in the environment and is not visible in the conversation. It belongs to one machine and is never synced. It uses the same key format as the project file.

## Which keys can be global

Only person-level and crew-level keys: `person`, `role`, `reports`, `coders`, `models`, `reviewer`, `advisor`, `teacher`.

These describe one repo and are read from the project file only, never from the global file: `test`, `lint`, `build`, `rules`, `board` and its IDs, `ruleset`, `identities`. A global file that contains them is ignored for them.

## Which mode a project is in

The project file records it with a `crew:` line.

| Line | Meaning |
|---|---|
| `crew: global` | This project follows the global file. |
| `crew: project` | This project has its own crew. The global file is not read. |
| no `crew:` line | Same as `crew: project`. This is every project onboarded before the global file existed, and it stays unaffected by any global file. |

"Follows global" (`crew: global`) is not the same as "no keys, so shipped defaults". A project with neither a `crew:` line nor crew keys runs the shipped defaults and ignores the global file.

## The rule, per key

For a key in the list above, take the first that applies:

1. The project file sets the key: use the project's value.
2. The project file says `crew: global` and the global file sets the key: use the global value.
3. Use the shipped default (`coders: default`, and so on; `default` is also what a missing key means).

A key is "set" when its line is present, including `default`. `models:` is one key: its first line and its indented persona lines move together, so the project's whole `models:` block or the global's whole block applies, and they are never merged line by line.

If the project says `crew: global` and the global file is missing or unreadable, use the shipped defaults for the global keys and tell the person once, for example "This project follows the global crew, but ~/.config/larceny/global-config.md is not readable, so I am using the shipped defaults." Do not fail and do not guess.

Read both files fresh on every use. Nothing is cached, so an edit to the global file reaches every project that follows it on its next dispatch or spawn, and never reaches a project that sets the key itself.

## Persona definition files

A renamed persona's own definition lives in a `.claude/agents/<name>.md` file. Look for it in the project's `.claude/agents/` first, then in the user-level `~/.claude/agents/`. When a crew is saved globally, onboarding writes these files to the user-level folder, so any project that follows global finds them. A project-level file for the same name wins.

## Who calls this

| Path | Keys it resolves |
|---|---|
| Coder dispatch (`skills/coordinator/SKILL.md`) | `coders`, `models` |
| `commands/spawn-reviewer.md`, `spawn-advisor.md`, `spawn-teacher.md` | `reviewer`, `advisor` or `teacher`; `models` |
| Auto-spawn (`agent-lifecycle.md`) | the persona's role key; `models` |
| `commands/wake-up.md`, `agents/coordinator.md` | `coders` (its first name is the coordinator); `person` |
| Onboarding (`skills/onboarding/SKILL.md`) | all, to show what is in effect and to skip questions |

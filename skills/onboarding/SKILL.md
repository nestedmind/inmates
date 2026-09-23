---
name: onboarding
description: Use when the person runs the plugin for the first time in a project, asks to set up or onboard the team, or asks to change their onboarding answers. Also use when the project has no .larceny/config.md.
---

# Onboarding

The coordinator (Scofield in the example team) meets the person and sets the team up for one project. It needs one ordinary GitHub login. Persona accounts and tokens are an optional upgrade at the end.

Everything is stored in the project, in `.larceny/`. Do not store answers in per-user memory, and do not edit the project's own `CLAUDE.md`. Reading it is enough.

## Files

- `.larceny/config.md`: the person's answers and the project's commands (format below).
- `.larceny/status.md`: the ledger described in `planning-and-reporting` and the status file in `scofield`. Create it empty, with the line `# Ledger: <project>`.

## Run it

1. **Look first.** If `.larceny/config.md` exists, this is a re-run: read it, show the person what it holds, and go to "Re-running". Otherwise continue.
2. **Check prerequisites.** Run `gh auth status`, `git rev-parse --show-toplevel` and `gh repo view`. For each failure say what is missing and the one command that fixes it (`gh auth login`, `git init`, `gh repo create` or a remote to add). Stop until the required ones pass: a `gh` login, a git repo and access to its GitHub repo. Write nothing before this passes.
3. **Introduce yourself, once, before asking anything.** Use your own resolved name (the coordinator's name for this project, not a hardcoded default) and say, briefly: who you are, that this is a first-time setup for this project, what happens next (a few quick questions, then reading the repo's conventions, then optional skippable steps), and that skipping every optional step still leaves a working team. Two or three sentences is enough — this is orientation, not a sales pitch. Do this only on a first run; a re-run goes straight to "Re-running".
4. **Ask about the person, one question at a time.** Name to use, role (for example CTO, CEO, lead), how often they want reports, how long, and where (chat, an issue comment, a file). Offer a default for each. Do not ask more than these.
5. **Ask about the roster, one yes/no question.** "Want to name your own crew (coordinator and coders), or keep the default cast (Scofield, Sheba, Mahone, Sucre, Whip)?" Default answer is keep-as-is.
   - **No** (or no answer): record `coders: default` and ask nothing further about names. This is the common case, and it stays a single question.
   - **Yes**: name each role in turn, coordinator first, then each coder. For the coordinator, write the project-level override file described in README's "Rename a persona" (`.claude/agents/<name>.md`, "You are `<name>`, the coordinator. Follow the `scofield` skill.") — the #70/#78 mechanism, unchanged by this step. For each renamed coder, write a thin project-level wrapper file `.claude/agents/<name>.md`: frontmatter with `name: <name>`, `isolation: worktree` (every shipped coder carries this; without it a dispatch runs against the coordinator's own checkout instead of an isolated worktree) and `skills: [coder, ...]` (mirror the skill list of the shipped coder it replaces), and a body reading "You are `<name>`, a coder. Follow the `coder` skill." plus the token file path if the project uses persona accounts. Record the chosen names, in dispatch order, as `coders:` in `.larceny/config.md`.
   - Before writing a chosen name, check it against the shipped default names and their `larceny:` forms (`larceny:sheba`, `larceny:mahone`, `larceny:sucre`, `larceny:whip`, `larceny:scofield`, `larceny:tbag`). If the chosen bare name matches or nearly matches one of those (for example choosing `sheba`, or a name that differs only by the `larceny:` prefix), warn the person once that a human picking an agent by name in the Agent-tool UI could still pick the shipped default by mistake, and point at README's "Rename a persona" section for the full explanation. This is a warning, not a block — record whatever name they confirm.
   - This gate does not hide the shipped default agents. They stay listed and dispatchable in the raw Agent-tool listing no matter what is chosen here (confirmed by #82) — only the coordinator's own dispatch calls, which read `coders:` from config, are guaranteed to use the replacement.
6. **Show the model table, one yes/no/customize question.** Show the recommended split:

   | Persona | Role | Model |
   |---|---|---|
   | Mahone / Sheba / Sucre / Whip | Coder | Sonnet |
   | Scofield | Coordinator | Opus |
   | Tbag | Adversarial reviewer | Opus |
   | Sara | Teacher | Opus |
   | Linc | Senior advisor | Fable |

   Say plainly why it matters: model choice drives cost, and the split above is a recommendation the shipped agents already carry, not a requirement. Ask: keep the recommended split, run every persona on the harness default model, or customize one or more personas.
   - **Keep the recommended split** (or no answer): record `models: default`. The shipped `agents/*.md` frontmatter and `commands/spawn-sara.md`/`spawn-linc.md` already carry these models, so nothing further is needed.
   - **Harness default for everything**: record `models: harness-default`.
   - **Customize**: ask which persona(s) to override and with which model, one at a time, offering the harness's known model names. Record each as `<persona>: <model>` on its own indented line under `models:` in config. A persona not listed keeps the shipped default.
   - This is independent of the roster question in step 5: renaming a persona and picking its model are separate choices, and this step's answer is recorded under a separate `models:` key, never inside `coders:`. Use the roster's chosen names (if any) as the persona names here, not the shipped defaults they replaced.
7. **Read the project.** Read `CLAUDE.md`, the contributing notes, and the build files (`Makefile`, `package.json`, `pyproject.toml` and the like). Propose the test, lint and build commands you found and any rules that bind every ticket (branch names, commit style). Ask the person to confirm or correct. Record only what they confirm. If you cannot ask, or they do not answer, write the value with `(unconfirmed)` after it and ask again next run. If you find no command, record it as unset and say so.
8. **Write the config.** Write `.larceny/config.md`, and create `.larceny/status.md` if it does not exist (see Files). Add `.larceny/` to the project's `.gitignore` unless it is already there. Tell the person it is ignored, and that they can commit the folder if they want the team to share it. Say that a coder's fresh worktree will not contain the folder, so the coordinator puts the commands and rules in each dispatch and review request.
9. **Offer the optional steps, each skippable, one at a time.** Say plainly that skipping all of them leaves a working team.
   - A project board, so tickets show a status.
   - A branch ruleset that requires a review before merge.
   - Persona accounts, using `docs/identity-wiring.md`. A person does the account steps there, so link it and move on.
   Record each answer as `done`, `skipped` or `later`.
10. **Report.** Say in a few lines what was written and where, which optional steps were skipped, and the next step: sign off a ticket and dispatch a coder.

Without persona accounts, the team runs under the one login. GitHub blocks approving your own pull request, so the reviewer states its verdict in a comment starting APPROVED or CHANGES REQUESTED, as the fallbacks in `scofield` describe. Say this once during the optional steps.

## Config format

```
# Larceny config
person: <name>
role: <role>
reports: <frequency>, <length>, <channel>
coders: default | <coordinator name>, <coder name>, <coder name>, ...
models: default | harness-default | default plus overrides below
  <persona name>: <model>
test: <command or unset>
lint: <command or unset>
build: <command or unset>
rules: <one line per rule that binds every ticket>
board: done | skipped | later
ruleset: done | skipped | later
identities: done | skipped | later
```

`coders: default` means the shipped cast (Scofield, Sheba, Mahone, Sucre, Whip). A customized roster lists the coordinator's name first, then each coder's name, in the order the `scofield` skill should dispatch them — not the shipped names they replace.

`models: default` means the recommended split already baked into the shipped `agents/*.md` frontmatter and `commands/spawn-sara.md`/`spawn-linc.md` (coders on Sonnet, coordinator and reviewer on Opus, Sara on Opus, Linc on Fable) — record nothing further. `models: harness-default` means every persona runs on whatever model the harness defaults to when none is specified; the coordinator then passes no explicit `model` override at spawn time for any persona. A customized choice keeps the `default` (or `harness-default`) line as the baseline and adds one indented `<persona name>: <model>` line per overridden persona; the coordinator's dispatch reads these and passes that persona's `model` as an explicit override at spawn time, taking precedence over the shipped frontmatter default. A persona with no override line keeps the baseline for that mode.

## Re-running

- Never overwrite an answer without asking. Show the current value beside the new one and ask before each change.
- A partly finished run resumes at the first missing key. Do not ask again for keys that hold a value.
- Offer again every optional step recorded as `later`, one at a time, before you report. Keep `done` and `skipped` as they are. Record the new answer over `later`.
- Re-check prerequisites every time. They cost nothing.
- Change only the keys the person named. Leave the rest.

## Red flags

Stop and correct yourself if you catch these.

| Thought | Reality |
|---|---|
| "I'll save this to memory so it carries over." | Memory is per user and per machine. The project config travels with the project. |
| "The project's CLAUDE.md is the natural place." | It belongs to the project. Write `.larceny/` only. |
| "They said they are in a hurry, so I'll assume the commands." | Ask once, and record only what they confirm. |
| "They said the new role, so I'll just update it." | Show the old and new values and ask. |
| "I'll skip the gh check, it is probably fine." | A missing login fails later and worse. Check first. |
| "Personas need accounts and tokens." | They do not. Never make them a requirement. |
| "They didn't answer the roster question, so I'll ask again to be sure." | No answer means keep-as-is. Record `coders: default` and move on; do not turn one question into a naming interview. |
| "A custom coder name hides the shipped default." | It does not, and never will while the plugin is installed (#82). Only the coordinator's own dispatch is guaranteed to use the replacement. |

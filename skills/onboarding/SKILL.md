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
3. **Ask about the person, one question at a time.** Name to use, role (for example CTO, CEO, lead), how often they want reports, how long, and where (chat, an issue comment, a file). Offer a default for each. Do not ask more than these.
4. **Read the project.** Read `CLAUDE.md`, the contributing notes, and the build files (`Makefile`, `package.json`, `pyproject.toml` and the like). Propose the test, lint and build commands you found and any rules that bind every ticket (branch names, commit style). Ask the person to confirm or correct. Record only what they confirm. If you cannot ask, or they do not answer, write the value with `(unconfirmed)` after it and ask again next run. If you find no command, record it as unset and say so.
5. **Write the config.** Write `.larceny/config.md`, and create `.larceny/status.md` if it does not exist (see Files). Add `.larceny/` to the project's `.gitignore` unless it is already there. Tell the person it is ignored, and that they can commit the folder if they want the team to share it. Say that a coder's fresh worktree will not contain the folder, so the coordinator puts the commands and rules in each dispatch and review request.
6. **Offer the optional steps, each skippable, one at a time.** Say plainly that skipping all of them leaves a working team.
   - A project board, so tickets show a status.
   - A branch ruleset that requires a review before merge.
   - Persona accounts, using `docs/identity-wiring.md`. A person does the account steps there, so link it and move on.
   Record each answer as `done`, `skipped` or `later`.
7. **Report.** Say in a few lines what was written and where, which optional steps were skipped, and the next step: sign off a ticket and dispatch a coder.

Without persona accounts, the team runs under the one login. GitHub blocks approving your own pull request, so the reviewer states its verdict in a comment starting APPROVED or CHANGES REQUESTED, as the fallbacks in `scofield` describe. Say this once during the optional steps.

## Config format

```
# Larceny config
person: <name>
role: <role>
reports: <frequency>, <length>, <channel>
test: <command or unset>
lint: <command or unset>
build: <command or unset>
rules: <one line per rule that binds every ticket>
board: done | skipped | later
ruleset: done | skipped | later
identities: done | skipped | later
```

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

# larceny

A plugin of skills for agent personas: a team with a coordinator, a reviewer and coders, and the skills each one works from. Claude Code and Codex read the same `skills/` directory, so each skill exists once.

It has been tested only with Claude Code, and it is recommended for Claude Code users. Codex users are welcome to try it and send feedback. See [Codex](#codex-untested) below.

## Get started

Three steps. Steps 1 and 2 are typed inside Claude Code. Step 3 is typed in a terminal.

### 1. Install

Inside Claude Code:

```
/plugin marketplace add nestedmind/larceny
/plugin install larceny@larceny
```

Claude Code finds every skill under `skills/` and every command under `commands/` on its own.

### 2. Try it now: wake up Scofield

Scofield is the coordinator and holds the context for the team. In a project that has a git remote on GitHub and a `gh` login, type this inside Claude Code:

```
/larceny:wake-scofield
```

`commands/wake-scofield.md` tells the current session to act as Scofield, in the main session, so it can ask you questions. It follows `agents/scofield.md`: if the project has no `.larceny/config.md`, it follows the `onboarding` skill first. That skill checks your `gh` login, git repo and repo access, asks a few questions, and writes your answers to `.larceny/config.md`. If the file exists, Scofield reads it and the status file and reports where things stand. It confirms with you before it spawns any agent.

This route is untested. Nobody has run `/larceny:wake-scofield` in a live session yet. It is on the owner's checklist in [docs/smoke-test.md](docs/smoke-test.md).

### 3. Coming back later, or in another terminal tab or window

In a terminal, start a session as Scofield:

```
claude --agent larceny:scofield
```

This needs a new terminal session. It has not been run on a clean machine either.

### Optional: have the plugin explained first

Run `/larceny:spawn-sara`. It starts Sara, a teacher, as a background agent, and reports the agent's id. Sara gauges what you already know, explains in steps, and checks your understanding. Her founding prompt tells her to ignore the project around her, and she reads nothing in a repository until you name it. To message her, ask the main session to relay: "Ask Sara <id>: explain how git rebase works." Add a project name after the command to give her one project for the conversation. The command file calls no `gh` command, so starting Sara needs no `gh` login. That the agent itself needs none is untested.

## What you need

- Claude Code, with the plugin installed as above.
- For `/larceny:wake-scofield` and `claude --agent larceny:scofield`: a `gh` login, a git repository, and access to its GitHub repo, the same as onboarding.
- For starting the spawn commands (`/larceny:spawn-sara`, `/larceny:spawn-linc`, `/larceny:spawn-tbag`): nothing beyond the plugin. The command files call no `gh` command. A spawned Tbag reviews pull requests, so it needs a `gh` login to do that work.
- For `/larceny:onboard`: a `gh` login, a git repository, and access to its GitHub repo. Onboarding checks all three before it writes anything.
- For the full team on a project (coordinator, reviewer, coders): one ordinary GitHub login is enough, and the project must be a git repository with at least one commit, because each coder works in its own worktree. Persona accounts and tokens are optional. Without them the reviewer states its verdict in a comment, because GitHub does not let one login approve its own pull request.
- A project board: GitHub Projects is the tested board. Linear through its MCP server is untested; the spike in [#72](https://github.com/nestedmind/larceny/issues/72) will test it.
- Persona accounts, if you want each persona to show up under its own name: a person must create them, since GitHub requires email verification and a captcha. See [docs/identity-wiring.md](docs/identity-wiring.md).
- A budget you can watch. Each agent is its own model session, and a team runs several at once. See [docs/cost-and-safety.md](docs/cost-and-safety.md).
- Tested on one Linux machine only. macOS, Windows, containers and remote setups are untested, and so is `/plugin install` on a clean machine. See [docs/limitations.md](docs/limitations.md).

## The team

The plugin ships six agents in `agents/`. Each carries the skills it needs, and none needs a GitHub account of its own.

- `scofield` coordinates: it plans, dispatches coders and reports to you.
- `tbag` reviews pull requests against their tickets.
- `sucre`, `mahone`, `sheba` and `whip` are coders. Each takes one ticket per dispatch, works in its own worktree, opens a pull request and merges it only after an approval.

Claude Code lists a plugin's agents under the plugin name, so dispatch them as `larceny:sucre` and so on. The coders read the project's test and lint commands from `.larceny/config.md`. That folder is gitignored, so a coder's fresh worktree does not hold it. The coder reads it in the main checkout, or takes the commands from the dispatch prompt.

## Uninstall

**Uninstalling has not been tested on this plugin.** The commands below come from the Claude Code plugin documentation ([Manage installed plugins](https://code.claude.com/docs/en/discover-plugins#manage-installed-plugins) and [Manage marketplaces](https://code.claude.com/docs/en/discover-plugins#manage-marketplaces)), and we checked each one against that page. Nobody has run them on this plugin yet. If one fails, please tell us on the [issues page](https://github.com/nestedmind/larceny/issues).

Remove the plugin, inside Claude Code:

```
/plugin uninstall larceny@larceny
```

This opens the plugin panel and leaves it open. Press Esc to close it. You can also run `/plugin`, open the Installed tab, select the plugin and choose uninstall. From a shell, `claude plugin uninstall larceny@larceny` does the same without the panel. If you installed it for a project, add `--scope project`.

To keep the plugin but turn it off, run `/plugin disable larceny@larceny`. Turn it back on with `/plugin enable larceny@larceny`.

Optionally, remove the marketplace too:

```
/plugin marketplace remove larceny
```

The docs warn that removing a marketplace uninstalls any plugins you installed from it.

Uninstalling does not touch what the plugin's work left behind. Clean these up by hand if they exist:

- The `.larceny/` folder in each project where you ran onboarding, and the `.gitignore` line that ignores it.
- An `"agent": "larceny:scofield"` line in `.claude/settings.json`, if you opted in to run Scofield as the main session.
- Coder worktrees and branches in your projects.
- Token files under `~/.config/larceny/`, if you set up persona accounts. Also delete those tokens on GitHub.

## Run Scofield as the main session

Nothing makes Scofield the default. The plugin does not set `"agent"` in a `settings.json`, because that would change every session of everyone who installs it. To run as Scofield, pick one:

- Inside a session, run `/larceny:wake-scofield`. This route is untested.
- Start a session with `claude --agent larceny:scofield`.
- Or add `{"agent": "larceny:scofield"}` to your project's `.claude/settings.json`, or to your user settings, to make it the default there.

A main-session agent does not preload the skills its file lists, so Scofield loads them with the Skill tool when it starts. The tests behind this are in [docs/smoke-test.md](docs/smoke-test.md).

## First run

Run `/larceny:onboard` in your project. Scofield checks that `gh` is logged in, asks who you are and how you want reports, reads your `CLAUDE.md` and build files to agree the test, lint and build commands, and writes your answers to `.larceny/config.md` in the project. It adds `.larceny/` to `.gitignore`. A project board, a branch ruleset and persona accounts are offered last, and each can be skipped. One ordinary GitHub login is enough, and skipping every optional step leaves a working team. Running it again shows your current answers and asks before changing any.

Without persona accounts the reviewer states its verdict in a comment, because GitHub does not let one login approve its own pull request. See the fallbacks in `skills/scofield/SKILL.md`.

## Commands

- `/larceny:wake-scofield` makes the current session act as Scofield, the coordinator.
- `/larceny:onboard` runs the onboarding skill only.
- `/larceny:spawn-tbag`, `/larceny:spawn-linc` and `/larceny:spawn-sara` start a persona as an agent. See below.

## Spawn commands

Three personas run as long-lived agents that you message across a session. A slash command starts each one. Plugin commands carry the plugin name, so the forms are:

- `/larceny:spawn-tbag` starts the adversarial code reviewer.
- `/larceny:spawn-linc` starts the senior advisor.
- `/larceny:spawn-sara` starts the teacher.

Each command starts an agent with that persona's founding prompt and tells it to ignore the project around it. Add a project name after the command, such as `/larceny:spawn-linc my-app`, to give the agent one project for the conversation. Without a name, the agent asks.

Each command reports the agent's id when it finishes, and the agent is reachable by that id. Whether it also gets a name such as `tbag` depends on the harness. The command sets a name only when the `Agent` tool accepts one, so keep the id.

To talk to the agent, ask the main session to relay: "Ask Tbag <id>: review PR 12". The main session calls `SendMessage` with the id.

The coders are not spawned this way. The coordinator starts a fresh coder for each ticket.

The commands live in `commands/`, which Claude Code finds on its own. They are Claude Code only for now. Whether Codex has an equivalent custom-command mechanism is unverified, so Codex users start these personas by hand.

## Rename a persona

A persona's name lives in the skill that defines it. To rename one, change the `name` field in the skill's `SKILL.md` frontmatter, rename its directory under `skills/` to match, and update any text in the skill body that uses the old name.

## Identity wiring

Each persona can run under its own GitHub account, so commits, pull requests and reviews show who did what. This is optional, and everything in the repo works with your own `gh` login and git identity. The setup steps, and which ones only a person can do, are in [docs/identity-wiring.md](docs/identity-wiring.md).

## Agent lifecycle

When you stand up a team, each role runs either as a persistent, named agent or as a fresh dispatch per task. A standing reviewer or advisor fits the first, and a coder fits the second. The rule and the reasons are in [docs/agent-lifecycle.md](docs/agent-lifecycle.md).

## Limitations

**GitHub comments and @-mentions do not reach a session running on your machine.** Commenting on a persona's name in an issue or pull request does not wake it or send the comment into the session. The session does not listen for GitHub events, so a persona reads a comment only when it checks for one.

Workaround: tell the session about the comment, and the persona reads it then. Or have the session poll the persona account's GitHub notifications on an interval, for example with `/loop` or a cron job. A poll picks up a comment up to one interval late, and it runs only while the session is open. A comment does not start work on its own. The persona reports what the comment says, and starts only when the user tells it to.

A hosted route exists: the [Claude Code GitHub Action](https://github.com/anthropics/claude-code-action) responds to @claude mentions on issues and pull requests. This repo does not set it up or cover it. Automatic pickup of GitHub comments in a local session is out of scope for now.

## Codex (untested)

Clone the repo and load it as a Codex plugin. Its manifest is `.codex-plugin/plugin.json`, which reads skills from `./skills/`.

```
git clone https://github.com/nestedmind/larceny.git
```

Codex reads the skills only. The agents in `agents/` and the commands in `commands/` are Claude Code features, and nothing here maps them to Codex, so Codex users get the skills and run the personas by hand. The Codex install steps are unverified. Codex is not installed on the machine that wrote this, and Codex's plugin documentation could not be checked. The manifest follows the layout of other Codex plugins, but confirm the load step against Codex's current documentation. If you try it, please tell us what worked and what did not on the [issues page](https://github.com/nestedmind/larceny/issues).

## More

- [docs/smoke-test.md](docs/smoke-test.md): what was tested, and the checklist for a clean-machine install and a pilot in a second project. The owner's run is still open.
- [docs/limitations.md](docs/limitations.md): what is untested or does not work yet.
- [docs/cost-and-safety.md](docs/cost-and-safety.md): token cost, GitHub tokens and what agents can run.
- [CONTRIBUTING.md](CONTRIBUTING.md): how to pick a ticket, open a pull request and add a skill or persona.

## License

MIT. See `LICENSE`. Adapted skills are credited in `THIRD_PARTY.md`.

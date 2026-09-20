# inmates

A plugin of skills for agent personas. Each skill gives a coding agent a working procedure for a role, such as writing skills or reviewing a pull request. Claude Code and Codex read the same `skills/` directory, so each skill exists once.

## Install for Claude Code

Add the marketplace, then install the plugin:

```
/plugin marketplace add nestedmind/inmates
/plugin install inmates@inmates
```

Claude Code finds every skill under `skills/` and every command under `commands/` on its own.

## Install for Codex

Clone the repo and load it as a Codex plugin. Its manifest is `.codex-plugin/plugin.json`, which reads skills from `./skills/`.

```
git clone https://github.com/nestedmind/inmates.git
```

The Codex install steps are unverified. Codex is not installed on the machine that wrote this, and Codex's plugin documentation could not be checked. The manifest follows the layout of other Codex plugins, but confirm the load step against Codex's current documentation.

## First run

Run `/inmates:onboard` in your project. Scofield checks that `gh` is logged in, asks who you are and how you want reports, reads your `CLAUDE.md` and build files to agree the test, lint and build commands, and writes your answers to `.inmates/config.md` in the project. It adds `.inmates/` to `.gitignore`. A project board, a branch ruleset and persona accounts are offered last, and each can be skipped. One ordinary GitHub login is enough, and skipping every optional step leaves a working team. Running it again shows your current answers and asks before changing any.

Without persona accounts the reviewer states its verdict in a comment, because GitHub does not let one login approve its own pull request. See the fallbacks in `skills/scofield/SKILL.md`.

## Spawn commands

Three personas run as long-lived agents that you message across a session. A slash command starts each one. Plugin commands carry the plugin name, so the forms are:

- `/inmates:spawn-tbag` starts the adversarial code reviewer.
- `/inmates:spawn-linc` starts the senior advisor.
- `/inmates:spawn-sara` starts the teacher.

Each command starts an agent with that persona's founding prompt and tells it to ignore the project around it. Add a project name after the command, such as `/inmates:spawn-linc my-app`, to give the agent one project for the conversation. Without a name, the agent asks.

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

## More

- [docs/limitations.md](docs/limitations.md): what is untested or does not work yet.
- [docs/cost-and-safety.md](docs/cost-and-safety.md): token cost, GitHub tokens and what agents can run.
- [CONTRIBUTING.md](CONTRIBUTING.md): how to pick a ticket, open a pull request and add a skill or persona.

## License

MIT. See `LICENSE`. Adapted skills are credited in `THIRD_PARTY.md`.

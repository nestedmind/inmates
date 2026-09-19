# inmates

A plugin of skills for agent personas. Each skill gives a coding agent a working procedure for a role, such as writing skills or reviewing a pull request. Claude Code and Codex read the same `skills/` directory, so each skill exists once.

## Install for Claude Code

Add the marketplace, then install the plugin:

```
/plugin marketplace add the0xLab/inmates
/plugin install inmates@inmates
```

Claude Code finds every skill under `skills/` on its own.

## Install for Codex

Clone the repo and load it as a Codex plugin. Its manifest is `.codex-plugin/plugin.json`, which reads skills from `./skills/`.

```
git clone https://github.com/the0xLab/inmates.git
```

The Codex install steps are unverified. Codex is not installed on the machine that wrote this, and Codex's plugin documentation could not be checked. The manifest follows the layout of other Codex plugins, but confirm the load step against Codex's current documentation.

## Rename a persona

A persona's name lives in the skill that defines it. To rename one, change the `name` field in the skill's `SKILL.md` frontmatter, rename its directory under `skills/` to match, and update any text in the skill body that uses the old name.

## Identity wiring

Each persona can run under its own GitHub account, so commits, pull requests and reviews show who did what. This is optional, and everything in the repo works with your own `gh` login and git identity. The setup steps, and which ones only a person can do, are in [docs/identity-wiring.md](docs/identity-wiring.md).

## License

MIT. See `LICENSE`. Adapted skills are credited in `THIRD_PARTY.md`.

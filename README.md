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

## Rename a persona

A persona's name lives in the skill that defines it. To rename one, change the `name` field in the skill's `SKILL.md` frontmatter, rename its directory under `skills/` to match, and update any text in the skill body that uses the old name.

## Identity wiring

A guide for giving each persona its own git and GitHub identity is planned and not written yet.

## License

MIT. See `LICENSE`. Adapted skills are credited in `THIRD_PARTY.md`.

---
name: writing-skills
description: Use when creating a new skill, editing an existing skill, or checking that a skill works before it is merged
---

# Writing Skills

Adapted from `writing-skills` in obra/superpowers (MIT, Jesse Vincent). See `THIRD_PARTY.md`.

## Overview

Writing a skill is test-driven development applied to process documentation. You write a pressure scenario, watch an agent fail it without the skill, write the skill, then watch the agent pass with it.

**Core principle:** if you did not watch an agent fail without the skill, you do not know the skill teaches the right thing.

A skill is a reusable reference for a technique, pattern or tool. It is not a story about how you solved a problem once.

**Repo rule:** every later persona or competency skill in this repo must be pressure-tested by this process before it counts as done. Skills written before this one landed are not retroactively required to be tested, but any later edit to them is.

## Where skills live

Skills live in `skills/<skill-name>/SKILL.md` at the repo root. Claude Code and Codex read the same directory, so each skill exists once. Add supporting files only for heavy reference (100+ lines) or reusable scripts. Keep principles and short code patterns (under 50 lines) inline.

When a skill bundles a script, invoke it through its interpreter in the prose (`bash scripts/tool.sh`, `node scripts/tool.js`), never by bare path. Some packagers strip executable bits.

## When to create a skill

Create one when the technique was not obvious, you would use it again across projects, and others would benefit.

Do not create one for one-off solutions, practices already well documented elsewhere, or project-specific conventions (put those in the project's instructions file). If a regex or a validator can enforce it, automate it and save skills for judgment calls.

## TDD mapping

| TDD concept | Skill authoring |
|---|---|
| Test case | Pressure scenario run by a subagent |
| Production code | The `SKILL.md` |
| RED (test fails) | Agent violates the rule without the skill (baseline) |
| GREEN (test passes) | Agent complies with the skill present |
| Refactor | Close loopholes while compliance holds |

## The Iron Law

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

This applies to new skills and to edits. Wrote the skill before testing? Delete it and start over. Do not keep it as "reference", do not "adapt" it while testing, and do not skip this for "just a small addition". Violating the letter of this rule is violating its spirit.

## RED: watch it fail

Run a pressure scenario with a subagent that does not have the skill. Record verbatim:

- What choices the agent made.
- The exact rationalizations it used.
- Which pressures triggered the failure.

For discipline skills, combine three or more pressures in one scenario: time, sunk cost, authority, exhaustion, an apparent "simple" exception. A scenario with one pressure is easy to pass and proves little. Make the agent choose and act, not answer a quiz.

## GREEN: write the minimal skill

Write only what addresses the failures you recorded. Do not add content for hypothetical cases. Re-run the same scenario with the skill present. The agent should now comply. If it does not, the skill is wrong, not the agent.

## REFACTOR: close loopholes

The agent found a new excuse? Add an explicit counter and re-run. Repeat until it holds. For discipline skills:

- Forbid the specific workarounds, not just the rule.
- Add a rationalization table (excuse, reality) built from your baseline runs.
- Add a red-flags list the agent can self-check against.

## Match the form to the failure

Classify the baseline failure before writing guidance. The form that fixes one type backfires on another.

| Baseline failure | Right form | Wrong form |
|---|---|---|
| Knows the rule, skips it under pressure | Prohibition, rationalization table, red flags | Soft wording ("prefer", "consider") |
| Complies but output has the wrong shape | A positive recipe: what the output is, its parts, in order | A list of "don't"s |
| Omits a required element | A required field or slot in the template | Prose reminders near the template |
| Behavior depends on a condition | A conditional on an observable predicate | An unconditional rule plus exemptions |

Two rules for any form. No nuance clauses ("don't X unless it matters" reopens the negotiation); express a real exception as its own conditional. Exemption clauses do not scope; if part of the output is exempt, restructure so the rule cannot reach it.

## Micro-test wording first

Full scenarios are slow. Check the wording cheaply before them:

1. One fresh-context sample per run, with the realistic context the guidance will live in.
2. Always include a no-guidance control. If the control does not show the failure, there is nothing to fix, so do not write the guidance.
3. Run five or more reps per variant. Single samples lie.
4. Read every flagged match by hand. Automated counts mistake quoted counter-examples for hits.
5. Treat variance as a metric. If five reps give five interpretations, the wording is not binding yet.

Micro-tests do not replace full pressure scenarios for discipline skills.

## Testing by skill type

| Type | Test with | Passes when |
|---|---|---|
| Discipline (rules) | Pressure scenarios, combined pressures | Agent follows the rule under maximum pressure |
| Technique (how-to) | Application and edge-case scenarios, gap hunting | Agent applies it correctly to a new case |
| Pattern (mental model) | Recognition and counter-example scenarios | Agent knows when it applies and when it does not |
| Reference | Retrieval and application scenarios | Agent finds and correctly uses the information |

## Excuses for skipping tests

| Excuse | Reality |
|---|---|
| "The skill is obviously clear" | Clear to you is not clear to another agent. |
| "It's just a reference" | References have gaps. Test retrieval. |
| "Testing is overkill" | Untested skills have problems, every time. |
| "I'll test if problems appear" | Problems mean agents cannot use it. Test before merging. |
| "Reading it over is enough" | Reading is not using. |

All of these mean: test before merging.

## SKILL.md structure

Frontmatter has two required fields, `name` and `description`, in at most 1024 characters. `name` uses letters, numbers and hyphens only. The `description` is third person and says only when to use the skill.

```markdown
---
name: skill-name-with-hyphens
description: Use when [specific triggering conditions and symptoms]
---

# Skill Name
## Overview          (core principle in 1-2 sentences)
## When to use       (symptoms, and when not to)
## Core pattern      (techniques and patterns)
## Quick reference   (table or bullets)
## Common mistakes
```

## Skill discovery optimization (SDO)

Future agents must find the skill. They read the description to decide whether to load it.

### The description says when, never what

Describe triggering conditions only. Never summarize the skill's process or workflow. Testing found that when a description summarizes the workflow, agents follow the description and skip the body. A description that said "code review between tasks" got one review done, while the body clearly required two.

```yaml
# Bad: summarizes the workflow, agents may skip the body
description: Use when executing plans - dispatches a subagent per task with review between tasks

# Bad: too abstract
description: For async testing

# Bad: first person
description: I can help with flaky async tests

# Good: triggers only
description: Use when tests have race conditions, timing dependencies, or pass and fail inconsistently
```

Start with "Use when". Describe the problem, not a language-specific symptom, unless the skill itself is technology-specific. Keep it under 500 characters where possible.

### Keyword coverage

Use the words an agent would search for: error messages, symptoms ("flaky", "hanging"), synonyms ("timeout, hang, freeze"), tool names and file types.

### Naming

Name by what you do or by the core insight, verb-first, gerunds for processes: `creating-skills`, `condition-based-waiting`, `root-cause-tracing`. Prefer these to `skill-creation` or `async-test-helpers`.

### Token efficiency

Frequently loaded skills cost tokens in every conversation.

- Workflows loaded at session start: under 150 words.
- Other frequently loaded skills: under 200 words.
- Everything else: under 500 words where possible.

Move flag lists to `--help`, cross-reference other skills instead of repeating them, compress examples, and remove redundancy. Check with `wc -w skills/<name>/SKILL.md`.

### Cross-references

Refer to other skills by name with an explicit marker: `**REQUIRED SUB-SKILL:** Use <skill-name>`. Do not use `@path` links, which force-load the file and burn context.

## Flowcharts and examples

Use a small flowchart only for a non-obvious decision or a loop where the agent might stop early. Use tables and lists for reference material, code blocks for code, and numbered lists for linear steps. Give flowchart nodes meaningful labels.

One excellent, complete, runnable example beats several mediocre ones. Do not port it into five languages or write fill-in-the-blank templates.

## Anti-patterns

- Narrative examples ("in session X we found..."): too specific to reuse.
- Multi-language dilution: mediocre examples and more to maintain.
- Code inside flowcharts: cannot be copied.
- Generic labels such as `step1` or `helper2`.

## Runtime notes

This repo targets Claude Code and Codex only. Both read `skills/` from the repo. Subagent tooling differs by runtime, so write scenarios in terms of "dispatch a fresh subagent" and use whichever mechanism your runtime provides.

## Stop after each skill

After writing any skill, finish its checklist before starting the next. Do not batch untested skills.

## Checklist

RED
- [ ] Pressure scenarios written (three or more combined pressures for discipline skills)
- [ ] Run without the skill, baseline recorded verbatim
- [ ] Failure patterns and rationalizations identified

GREEN
- [ ] `name` uses letters, numbers, hyphens only
- [ ] `description` starts with "Use when", third person, triggers only, no workflow
- [ ] Keywords included for search
- [ ] Skill addresses the recorded baseline failures and nothing hypothetical
- [ ] Guidance form matches the failure type
- [ ] Behavior-shaping wording micro-tested against a no-guidance control (not needed for pure reference)
- [ ] One good example, not several
- [ ] Scenarios re-run with the skill, agent complies

REFACTOR
- [ ] New rationalizations captured and countered
- [ ] Rationalization table and red-flags list built from all runs
- [ ] Re-tested until it holds

Quality
- [ ] Quick reference and common mistakes present
- [ ] No narrative storytelling
- [ ] Supporting files only for scripts or heavy reference
- [ ] Adapted skills credited here and in `THIRD_PARTY.md`

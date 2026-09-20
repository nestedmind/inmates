---
name: plain-writing
description: Use when writing prose for a reader, such as a PR description, review comment, reply, changelog entry, README, doc page or release note.
---

# Plain writing

The ideas here come from William Zinsser's *On Writing Well*. The rules and examples are our own wording. This is the house style for every persona, and a project that wants another style can replace this file.

## Precedence

Another skill may set an output format, such as severity tiers for a review or the layout of a changelog entry. That format wins. Apply this skill inside its fields and never change the format.

## Core rules

1. Cut every word that does no work. Write "use", not "utilize", and "to", not "in order to".
2. Put one thought in each sentence. A reader should not need to reread it.
3. Delete hedges ("very", "quite", "rather", "sort of", "I think") and buzzwords ("leverage", "robust", "targeted optimization").
4. Use the active voice and a strong verb instead of a weak verb plus an adverb.
5. Name the thing, the number and the ticket. Write "210 ms, down from 840 ms" instead of "significantly improved".
6. State only what you measured or read. Do not add a claim, a cause or a scale that you did not check.
7. Rewrite once more. Most drafts lose a quarter of their words on the second cut.

## Patterns to reject

**Contrast pairs.** Do not define a thing by what it is not.

- Before: "This is a bounded tradeoff, not a regression."
- After: "A logout can take up to 30 seconds to reach other workers."

**Punchy closers.** Do not end a paragraph on a fragment or an aphorism. Explain in ordinary sentences and stop.

- Before: "The cache is per-process. Simple. Fast. Done."
- After: "The cache is per-process, so it needs no shared store."

**Filler transitions.** State the fact.

- Before: "Here's the thing: the TTL matters."
- After: "The 30-second TTL sets how long a logout takes to spread."

**Prose that performs.** If the structure does rhetorical work, such as a build-up, a reveal or a balanced pair of clauses, rewrite it flat.

- Before: "We weighed speed against consistency and found the right balance."
- After: "We chose a 30-second TTL so that a logout reaches every worker within half a minute."

**Clipped causal chains.** Join the steps with "but", "and", "because" or "so".

- Before: "Latency was high. We added an index. It dropped."
- After: "Latency was high because the email lookup scanned the table, so we added an index."

## Structure

- Lead with the number, then explain it.
- Say statistics in plain language: "half of the requests took longer than 400 ms".
- Give the source, the window and the caveats for any data: where it came from, over what period, and what it leaves out.
- Use plain, literal headings ("What changed", "How I checked it").
- Put separate facts on separate lines.

## Final test

Before you send the text, ask two questions.

1. Can I remove words and keep the meaning? If so, remove them.
2. Is any sentence built for effect instead of clarity? If so, rewrite it flat.

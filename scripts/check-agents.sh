#!/usr/bin/env bash
# Static checks for the plugin's agent definitions. Run from anywhere.
# Exits non-zero and prints each problem when a check fails.
set -u
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
bad() { echo "FAIL: $1"; fail=1; }

expected="scofield tbag sucre mahone sheba whip"
for name in $expected; do
  [ -f "$root/agents/$name.md" ] || bad "agents/$name.md is missing"
done

for f in "$root"/agents/*.md; do
  base="$(basename "$f" .md)"
  # Frontmatter: first block between the two --- lines.
  fm="$(awk 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} NR>1{print}' "$f")"
  [ -n "$fm" ] || { bad "$base: no frontmatter"; continue; }
  n="$(printf '%s\n' "$fm" | sed -n 's/^name: *//p')"
  [ "$n" = "$base" ] || bad "$base: name '$n' does not match the file name"
  printf '%s\n' "$fm" | grep -q '^description: .\+' || bad "$base: no description"
  # model: must be present and one of the harness's known model names, so a
  # typo does not silently fall back to whatever the harness defaults to.
  m="$(printf '%s\n' "$fm" | sed -n 's/^model: *//p')"
  if [ -z "$m" ]; then
    bad "$base: no model"
  else
    case "$m" in
      sonnet|opus|haiku|fable) ;;
      *) bad "$base: model '$m' is not one of sonnet, opus, haiku, fable" ;;
    esac
  fi
  # Every preloaded skill must exist under skills/.
  for s in $(printf '%s\n' "$fm" | sed -n 's/^  - //p'); do
    [ -f "$root/skills/$s/SKILL.md" ] || bad "$base: skill '$s' has no skills/$s/SKILL.md"
  done
  # Public repo: no home paths, account names or fixed token paths.
  if grep -nE '/home/|/Users/|-ns\b|gh-[a-z]+-token' "$f" | grep -v 'gh-'"$base"'-token' >/dev/null; then
    bad "$base: contains a home path, an account name or another persona's token path"
  fi
done

# Coders share one behaviour source: the `coder` skill. Each thin agent
# file points at it instead of duplicating its rules.
for name in sucre mahone sheba whip; do
  grep -q '^  - coder$' "$root/agents/$name.md" 2>/dev/null || bad "$name: does not preload the coder skill"
  grep -qF 'the `coder` skill' "$root/agents/$name.md" 2>/dev/null || bad "$name: body does not say to follow the coder skill"
done

# The rules coders share must actually live in that one skill.
for phrase in 'exactly one ticket per dispatch' 'No approval, no merge' 'stop and report the block' 'git branch -D' 'main checkout'; do
  grep -q "$phrase" "$root/skills/coder/SKILL.md" 2>/dev/null || bad "skills/coder/SKILL.md: missing rule '$phrase'"
done

# The security skill is wired into every coder and the reviewer.
for name in sucre mahone sheba whip tbag; do
  grep -q '^  - secure-coding$' "$root/agents/$name.md" 2>/dev/null || bad "$name: does not preload secure-coding"
done

[ "$fail" = 0 ] && echo "ok: agent definitions pass"
exit "$fail"

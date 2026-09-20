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
  # Every preloaded skill must exist under skills/.
  for s in $(printf '%s\n' "$fm" | sed -n 's/^  - //p'); do
    [ -f "$root/skills/$s/SKILL.md" ] || bad "$base: skill '$s' has no skills/$s/SKILL.md"
  done
  # Public repo: no home paths, account names or fixed token paths.
  if grep -nE '/home/|/Users/|-ns\b|gh-[a-z]+-token' "$f" | grep -v 'gh-'"$base"'-token' >/dev/null; then
    bad "$base: contains a home path, an account name or another persona's token path"
  fi
done

# Coders must carry the same behaviour rules as each other.
for phrase in 'exactly one ticket per dispatch' 'No approval, no merge' 'stop and report the block' 'git branch -D' 'main checkout'; do
  for name in sucre mahone sheba whip; do
    grep -q "$phrase" "$root/agents/$name.md" 2>/dev/null || bad "$name: missing rule '$phrase'"
  done
done

[ "$fail" = 0 ] && echo "ok: agent definitions pass"
exit "$fail"

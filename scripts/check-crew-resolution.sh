#!/usr/bin/env bash
# Tests for scripts/resolve-crew.sh, the reference implementation of the
# resolution rule in docs/crew-resolution.md. Uses temp dirs only, and
# LARCENY_CONFIG_DIR so no real global config is read or written.
set -u
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
res="$root/scripts/resolve-crew.sh"
fail=0
bad() { echo "FAIL: $1"; fail=1; }
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
proj="$tmp/proj"; mkdir -p "$proj/.larceny" "$tmp/cfg"
export LARCENY_CONFIG_DIR="$tmp/cfg"
cfg="$proj/.larceny/config.md"; glob="$tmp/cfg/global-config.md"

# expect <label> <key> <expected output>
expect() {
  local got; got="$("$res" "$2" "$proj" 2>/dev/null)"
  [ "$got" = "$3" ] || bad "$1: got [$got], want [$3]"
}

printf '# Larceny config\nreviewer: alice\ntest: make test\n' > "$cfg"
printf '# Larceny config\nreviewer: bob\nadvisor: carol\nmodels: harness-default\n  bob: opus\ntest: nope\n' > "$glob"

# No crew: line: the global file is not consulted.
expect "own keys, no crew line" reviewer $'project\nalice'
expect "no crew line ignores global" advisor $'default'

# crew: global. Project key beats global, global beats default.
printf 'crew: global\n' >> "$cfg"
expect "project beats global" reviewer $'project\nalice'
expect "global beats default" advisor $'global\ncarol'
expect "key in neither is default" teacher $'default'
expect "block value keeps indented lines" models $'global\nharness-default\n  bob: opus'
# Project-only keys never come from global.
expect "test is project-only" test $'project\nmake test'
printf 'lint: x\n' >> "$glob"
expect "lint never read from global" lint $'default'

# Editing global changes a follows-global project, not one with its own key.
printf '# Larceny config\nadvisor: dave\nreviewer: bob\n' > "$glob"
expect "edit reaches follower" advisor $'global\ndave'
expect "edit does not reach own key" reviewer $'project\nalice'

# Missing global file: fall back to default and say so.
rm "$glob"
expect "global missing" advisor $'global-missing'
# No project config at all: default.
rm "$cfg"
expect "no project config" advisor $'default'
# crew: project is the explicit own-keys mode.
printf 'crew: project\n' > "$cfg"; printf 'advisor: dave\n' > "$glob"
expect "crew: project ignores global" advisor $'default'

# Every read path points at the one rule.
for f in commands/spawn-reviewer.md commands/spawn-advisor.md commands/spawn-teacher.md commands/wake-up.md \
         agents/coordinator.md agents/teacher.md agents/advisor.md agents/scofield.md skills/coordinator/SKILL.md docs/agent-lifecycle.md skills/onboarding/SKILL.md; do
  grep -q 'crew-resolution.md' "$root/$f" || bad "$f does not point at docs/crew-resolution.md"
done
[ "$fail" = 0 ] && echo "ok: crew resolution passes"
exit "$fail"

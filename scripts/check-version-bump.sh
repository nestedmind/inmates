#!/usr/bin/env bash
# Fails when a change touches files that ship to users but does not bump
# `version` in .claude-plugin/plugin.json.
#
# Usage: scripts/check-version-bump.sh [base-ref]   (default: origin/main)
# Set NO_BUMP=1 to skip the bump for a change that users need not receive,
# such as a typo fix. CI sets it from the `no-bump` pull request label.
set -u
base="${1:-origin/main}"
manifest=".claude-plugin/plugin.json"
shipped='^(agents|skills|commands|\.claude-plugin|\.codex-plugin)/'

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 2

mb="$(git merge-base "$base" HEAD 2>/dev/null)" || {
  echo "error: cannot find a merge base with '$base'. Fetch it first." >&2
  exit 2
}

changed="$(git diff --name-only "$mb" HEAD | grep -E "$shipped")"
if [ -z "$changed" ]; then
  echo "ok: no shipped files changed, no version bump needed"
  exit 0
fi

version_of() { sed -n 's/^ *"version": *"\([^"]*\)".*/\1/p' | head -n 1; }
old="$(git show "$mb:$manifest" 2>/dev/null | version_of)"
new="$(version_of < "$manifest")"

if [ -n "$new" ] && [ "$new" != "$old" ]; then
  echo "ok: shipped files changed and version bumped ($old -> $new)"
  exit 0
fi

if [ "${NO_BUMP:-}" = "1" ]; then
  echo "ok: shipped files changed, version still ${new:-unset}, skipped because NO_BUMP=1"
  exit 0
fi

echo "FAIL: shipped files changed but \`version\` in $manifest is still ${old:-unset}:"
printf '%s\n' "$changed" | sed 's/^/  /'
echo "Bump the version, or add the \`no-bump\` label (NO_BUMP=1 locally) if users need not receive this change."
exit 1

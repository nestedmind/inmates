#!/usr/bin/env bash
# Reference implementation of docs/crew-resolution.md.
# Usage: resolve-crew.sh <key> [project-dir]
# Prints the source on the first line (project, global, global-missing or
# default). For project and global it then prints the key's value: the text
# after "key:" on its own line, then any indented lines that belong to it.
set -u
key="${1:?usage: resolve-crew.sh <key> [project-dir]}"
proj="${2:-.}"
project_cfg="$proj/.larceny/config.md"
global_cfg="${LARCENY_CONFIG_DIR:-$HOME/.config/larceny}/global-config.md"

# get <file> <key>: value block, exit 1 when the key is absent.
get() {
  awk -v k="$2" '
    found && /^[ \t]+/ { print; next }
    found { exit }
    index($0, k ":") == 1 { found = 1; sub("^" k ":[ \t]*", ""); print; got = 1 }
    END { exit got ? 0 : 1 }
  ' "$1" 2>/dev/null
}

emit() { echo "$1"; printf '%s\n' "$2"; }

if [ -r "$project_cfg" ]; then
  if v="$(get "$project_cfg" "$key")"; then emit project "$v"; exit 0; fi
  crew="$(get "$project_cfg" crew | head -n1)"
else
  crew=""
fi

# Only a project that says "crew: global" reads the global file, and only
# for the person-level and crew-level keys.
case "$crew" in global*) ;; *) echo default; exit 0 ;; esac
case "$key" in person|role|reports|coders|models|reviewer|advisor|teacher) ;; *) echo default; exit 0 ;; esac

[ -r "$global_cfg" ] || { echo global-missing; exit 0; }
if v="$(get "$global_cfg" "$key")"; then emit global "$v"; else echo default; fi

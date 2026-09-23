#!/usr/bin/env bash
# Posts a reviewer verdict to a pull request and checks who posted it.
#
# Usage: post-review.sh <persona> <pr> <approve|request-changes|comment> <body-file>
#
# <persona> is the lowercase persona name, as in
# ~/.config/larceny/gh-<persona>-token. <body-file> is a text file with the
# review body, or a .json file shaped like the body of
# POST /repos/{owner}/{repo}/pulls/<n>/reviews (body, comments[]); the script
# sets event and commit_id itself.
#
# With a readable token file it posts a formal review under that account, then
# reads the review back and exits zero only when the author is the token's own
# login and the commit is the PR's current head. A token file that exists but
# cannot be read stops the script. With no token file it posts a plain comment
# under the ambient login whose first line says who wrote it.
# Run it from inside the repository that holds the pull request.
# It never prints the token.
set -u
usage() { echo "usage: $0 <persona> <pr> <approve|request-changes|comment> <body-file>" >&2; exit 2; }
[ $# -eq 4 ] || usage
persona="$1"; pr="$2"; verdict="$3"; file="$4"
case "$pr" in ''|*[!0-9]*) usage ;; esac
case "$verdict" in
  approve) event=APPROVE; want=APPROVED ;;
  request-changes) event=REQUEST_CHANGES; want=CHANGES_REQUESTED ;;
  comment) event=COMMENT; want=COMMENTED ;;
  *) usage ;;
esac
[ -r "$file" ] || { echo "error: cannot read body file $file" >&2; exit 2; }

if [ "${file%.json}" != "$file" ]; then
  payload="$(cat "$file")"
else
  payload="$(jq -n --rawfile b "$file" '{body: $b}')" || exit 2
fi

tok="${LARCENY_CONFIG_DIR:-$HOME/.config/larceny}/gh-$persona-token"
if [ -e "$tok" ] && [ ! -r "$tok" ]; then
  echo "error: token file $tok exists but is not readable. Fix its permissions; do not fall back to another login." >&2
  exit 3
fi

if [ ! -r "$tok" ]; then
  echo "token file $tok: missing, posting as a labeled comment under the ambient login"
  name="$(printf '%s' "$persona" | cut -c1 | tr '[:lower:]' '[:upper:]')$(printf '%s' "$persona" | cut -c2-)"
  tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT
  {
    echo "$name (reviewer persona), posted via the owner's login because no persona account is configured."
    echo
    printf '%s' "$payload" | jq -r '.body'
  } > "$tmp"
  gh pr comment "$pr" --body-file "$tmp" || exit 1
  echo "posted a comment on #$pr (not a formal review)"
  exit 0
fi

echo "token file $tok: readable"
export GH_TOKEN
GH_TOKEN="$(cat "$tok")"
login="$(gh api user --jq .login)" && [ -n "$login" ] || { echo "error: the token in $tok does not resolve to a login" >&2; exit 1; }
head="$(gh pr view "$pr" --json headRefOid --jq .headRefOid)" && [ -n "$head" ] || { echo "error: cannot read the head of #$pr" >&2; exit 1; }

resp="$(printf '%s' "$payload" | jq --arg c "$head" --arg e "$event" '. + {commit_id: $c, event: $e}' \
  | gh api "repos/{owner}/{repo}/pulls/$pr/reviews" --input -)" || { echo "error: posting the review failed" >&2; exit 1; }
id="$(printf '%s' "$resp" | jq -r .id)"
[ -n "$id" ] && [ "$id" != null ] || { echo "error: no review id in the response" >&2; exit 1; }

seen="$(gh api --paginate "repos/{owner}/{repo}/pulls/$pr/reviews" --jq '.[] | "\(.id) \(.user.login) \(.state) \(.commit_id)"')"
if printf '%s\n' "$seen" | grep -qxF "$id $login $want $head"; then
  echo "ok: review $id by $login, $want, on ${head:0:7}"
  exit 0
fi
echo "error: review $id did not read back as '$login $want ${head:0:7}'. Read back:" >&2
printf '%s\n' "$seen" | grep "^$id " >&2
exit 1

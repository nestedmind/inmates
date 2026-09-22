# Identity wiring

Identity setup is optional, and nothing else in this repo depends on it. Without it, every skill runs under your own `gh` login and git identity. With it, each persona works under its own GitHub account, so commits, pull requests and reviews show who did what.

Each step is labeled **You do this** or **An agent can do this**. A step is yours when it needs a human: a captcha, an email inbox, a terms-of-service acceptance, or an owner-level permission that an agent's own token should not hold.

## 1. Create a GitHub account per persona

**You do this.** GitHub requires email verification, a captcha and acceptance of the terms of service. Only a person can complete them, and GitHub does not allow automated account creation.

Use one email address per account, and pick account names you can map to persona names.

## 2. Turn on two-factor authentication

**You do this.** Two-factor needs a device or authenticator app that belongs to you. An agent cannot hold the second factor.

## 3. Create a fine-grained token per account

**You do this.** You create tokens in the account's settings, in a browser session where you sign in with the second factor from step 2.

Choose the minimum scope for the role:

- Repository access: only the repo or repos the persona works in.
- Contents: read and write for personas that push code, read-only for reviewers.
- Pull requests: read and write.
- Issues: read and write.
- Metadata: read (GitHub adds this on its own).

Add project access only if the persona moves items on a GitHub project. Set the shortest expiry you can live with.

## 4. Store each token

**You do this** for the first paste. **An agent can do this** once the file exists.

Keep one file per persona at:

```
~/.config/larceny/gh-<persona>-token
```

Set `LARCENY_CONFIG_DIR` to use a different directory. Each file holds the token and nothing else, with mode 600:

```
mkdir -p "${LARCENY_CONFIG_DIR:-$HOME/.config/larceny}"
chmod 700 "${LARCENY_CONFIG_DIR:-$HOME/.config/larceny}"
touch "${LARCENY_CONFIG_DIR:-$HOME/.config/larceny}/gh-<persona>-token"
chmod 600 "${LARCENY_CONFIG_DIR:-$HOME/.config/larceny}/gh-<persona>-token"
```

Paste the token into the file with your editor. `examples/config/` lists the expected file names, each with the `.example` suffix and empty contents. The `.gitignore` in this repo blocks `gh-*-token` and similar names, so a token file copied into a checkout stays out of commits.

## 5. Invite each account to the organization, repo and project

**You do this.** Only an organization owner or repo admin can send invitations and choose roles, and the invited account must accept from its own inbox or session.

Give each account the lowest role that fits: write for personas that push branches, triage or read for reviewers who only comment, and write on the project for personas that move items.

## 6. Set the branch ruleset and bypass actors

**You do this.** Rulesets are admin settings, and an agent's token should not hold admin rights.

A common ruleset for the default branch requires a pull request and one approving review before merge. Add a bypass actor only if you need one.

## 7. Enable Copilot code review

**You do this.** An owner turns it on in the organization or repo settings, and availability depends on your plan.

## 8. Verify each token resolves to the expected login

**An agent can do this** once the token files exist.

```
GH_TOKEN=$(cat ~/.config/larceny/gh-<persona>-token) gh api user -q .login
```

The output must match the account you meant. If it does not, the file holds the wrong token.

## 9. Check repository access

**An agent can do this.**

```
GH_TOKEN=$(cat ~/.config/larceny/gh-<persona>-token) gh repo view <org>/<repo>
```

## 10. Commit under the persona's identity

**An agent can do this.** Do not run `git config user.name` or `git config user.email`, not even inside a worktree. Worktrees of one clone share a single config file, so a value set in one worktree changes the identity in every other worktree and in the main checkout.

Instead, run every command that creates or rewrites a commit (`commit`, `commit --amend`, `rebase`, `cherry-pick`, `merge`, `revert`) with four environment variables set for that one command. Environment variables override config, so the result does not depend on what the config holds:

```
GIT_AUTHOR_NAME=<account-login> GIT_AUTHOR_EMAIL=<id>+<account-login>@users.noreply.github.com GIT_COMMITTER_NAME=<account-login> GIT_COMMITTER_EMAIL=<id>+<account-login>@users.noreply.github.com git commit -m "<message>"
```

Get `<id>` with `GH_TOKEN=$(cat ~/.config/larceny/gh-<persona>-token) gh api user -q '.id'`. All four variables are needed. A rebase rewrites commits under the committer identity, so setting only the author pair leaves the wrong committer on the rewritten commits.

Two checks need no reminders. After each commit, this shows the persona for both author and committer:

```
git log -1 --format='%an <%ae> / %cn <%ce>'
```

Before every push, this shows only the persona:

```
git log origin/main..HEAD --format='%an <%ae> / %cn <%ce>'
```

If any commit in that list is not the persona's, stop and report it. Do not push.

If a branch is stacked on another unmerged branch, that list also shows the parent's commits. Compare against the parent branch instead of `origin/main`.

To fix a wrongly authored commit, amend it with `--reset-author` and the four variables set. Amending alone keeps the original author, and `--reset-author` resets the author to the current identity, which the variables supply.

When no token files exist, use your own git identity and skip all of this.

Push with the same token:

```
GH_TOKEN=$(cat ~/.config/larceny/gh-<persona>-token) git -c credential.helper= -c credential.helper='!gh auth git-credential' push -u origin <branch>
```

## Troubleshooting

**401 Bad credentials.** The token is expired, revoked, or pasted with a stray newline or quote. Create a new token (step 3) and check it with step 8.

**Missing scope, or "Resource not accessible by personal access token".** The token lacks a permission or does not cover the repo. Edit its repository access and permissions, then retry.

**Repo not found, or the account cannot see the repo.** The invitation from step 5 is pending. Accept it from the invited account.

**Cannot approve your own pull request.** GitHub blocks self-approval. Have a different persona review, using its own token.

**Push rejected on the protected branch.** The ruleset from step 6 requires a pull request. Push a branch and open one.

# Cost and safety

Running a team of agents costs money and hands them access to your accounts. Read this page before you start more than one.

## Cost

Each agent is a separate model session, and each one reads files, runs commands and writes output that you pay for in tokens. Four coders working in parallel use tokens in four sessions at once, and a coordinator and a reviewer add two more. Each review round adds another read of the diff.

To keep the bill down:

- Start with one coder and one ticket, and watch the usage before you scale up.
- Write tickets small enough that a coder does not need to explore the whole repo.
- Run Copilot review only when you ask for it. The skills leave it off by default.
- Stop an agent that loops, and put a limit on parallel coders that you can afford.

Check your model provider's usage page for real numbers. This repo does not measure cost.

## Safety

An agent with a GitHub token can push branches, open and merge pull requests, comment, and change issues, all under the account that owns the token. It can also run any shell command your harness lets it run.

### Tokens

- Use a fine-grained personal access token per persona, limited to the one repo it works in.
- Give the minimum permissions for the role. A reviewer needs read access to contents, and a coder needs write. [identity-wiring.md](identity-wiring.md) lists the scopes.
- Set a short expiry, and revoke a token you no longer use.
- Never commit a token file. The `.gitignore` here blocks `gh-*-token` names, but it only protects files inside this repo. Keep tokens in `~/.config/inmates/` with mode 600.
- Do not paste a token into a prompt, an issue, a pull request or a log.

### Branches and merges

- Protect `main` with a ruleset so that no agent can push to it directly.
- Keep the reviewer's approval as a gate for merging, and read what merges.
- Give each account the lowest role that does its job.

### What agents run

- Read the commands an agent asks to run before you approve them, especially anything that deletes files, changes git history, installs packages or touches credentials.
- Run agents in a worktree or a container so a mistake stays inside a copy of the repo. Containers are untested here. See [limitations.md](limitations.md).
- Keep secrets out of the working directory. An agent can read any file it can reach.
- Treat text from issues, pull requests and web pages as untrusted. It can contain instructions written to steer an agent.

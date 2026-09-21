---
name: secure-coding
description: Use when writing or reviewing code that reads or writes a database, serves HTTP requests, handles user input, or deals with authentication, sessions or secrets. Covers query performance (N+1), injection, ownership and tenancy checks, CORS, CSRF, XSS, SSRF, tokens and passwords.
---

# Secure coding

Coders follow this while writing. The reviewer uses it as a checklist for the diff. It is a floor, and the whole diff still gets read.

Each rule states the failure it prevents, when it applies, and what proves compliance. A rule that does not apply to your change needs no action. When you report on a rule as not applicable, cite the file or line that shows why. Boilerplate such as "no security impact" does not count.

Only N+1 and lazy loading are performance rules. The rest are security rules. Do not judge a performance finding at the severity of an injection.

## Project rules

A project records its answers once, in `CLAUDE.md` or `.inmates/config.md`, for example "auth uses bearer headers only, so CSRF is not applicable". Read them first. A recorded answer settles the rule, and nobody re-argues it on each PR.

## Data access

**N+1 (performance)**
- Fails: one query per row, so a list of 500 rows costs 501 queries.
- Applies: collections that are unbounded or sized by the user. A loop over three fixed items does not count.
- Proof: relationships are eager-loaded in the query that returns the list, or the shared scope is fetched once and grouped in memory. A test that counts queries for a list of many rows is the strongest proof.

**Lazy relationships (performance)**
- Fails: reading a lazy relationship on a list result becomes a per-row query, and under an async ORM it raises an error (SQLAlchemy raises `MissingGreenlet`).
- Applies: any code that returns or loops over many rows. One fetched row is fine.
- Proof: the query that returns the list loads the relationship, or the code does not read it.

**Injection**
- Fails: user input reaches SQL text and changes the query.
- Applies: every query.
- Proof: parameterised queries or the ORM's expression API only. No string formatting, concatenation or f-strings in SQL.

**Ownership (IDOR)**
- Fails: a user reads or changes another user's record by guessing its id.
- Applies: every fetch, update or delete by id. It is part of the tenancy rule.
- Proof: the query filters by id and by owner, and a test requests another user's id and gets a 404 or 403.

**Tenancy**
- Fails: one tenant sees another tenant's data.
- Applies: every query on tenant data.
- Proof: the query carries the tenant filter, taken from the authenticated session and never from the request body.

**Races on check-then-act**
- Fails: two concurrent requests both pass a check, then both act. Two accounts get one email, or one token is spent twice.
- Applies: uniqueness, single-use tokens, balances and counters.
- Proof: a database unique constraint, or a row lock or atomic update. An application-level check alone does not count.

## Web surface

**CORS**
- Fails: a hostile site reads authenticated responses from the browser.
- Applies: code that sets CORS headers or middleware.
- Proof: explicit origin list, and no wildcard origin together with credentials.

**CSRF**
- Fails: a hostile page makes the browser send a state-changing request with the user's cookie.
- Applies: only when a cookie carries the authentication. APIs that require a bearer header are mostly exempt.
- Proof: a CSRF token or a `SameSite` cookie plus an origin check on every state-changing route, or the project rule that auth is by header only.

**XSS**
- Fails: attacker-supplied markup runs in a viewer's browser.
- Applies: `dangerouslySetInnerHTML`, `innerHTML`, and any HTML or markdown rendered from user content. React escapes everything else.
- Proof: the content passes through a sanitizer with an allow-list, or the code does not render it as HTML.

**SSRF**
- Fails: the server fetches an internal address, such as a cloud metadata endpoint, on an attacker's behalf.
- Applies: only when code fetches a URL the user supplied.
- Proof: an allow-list of hosts, or a check that resolves the address and refuses private and loopback ranges, with redirects off or re-checked.

**Rate limits**
- Fails: unlimited guesses against a login or reset, or unlimited cost from an anonymous caller.
- Applies: new or changed unauthenticated endpoints and endpoints that check credentials. Internal endpoints are a note at most.
- Proof: a limit in the route or in the gateway, and a test or a config line that shows it.

**Input validation**
- Fails: oversized, malformed or unexpected fields reach the database or the logic.
- Applies: every request field.
- Proof: a Pydantic schema (or the project's equivalent) with types and bounds, such as `max_length` and `ge`/`le`.

## Auth and session

**Refresh tokens**
- Fails: a stolen token works forever, or a replayed one goes unnoticed.
- Applies: code that issues, rotates or revokes refresh tokens.
- Proof: rotation on every use, replay of a rotated token revokes the whole family, tokens hashed at rest, and revocation on logout and on password change.

**JWT**
- Fails: forged or expired tokens are accepted.
- Applies: code that signs or verifies JWTs.
- Proof: the algorithm is pinned on verify, `exp`, `aud` and `iss` are checked, the access token lifetime is short, and the secret comes from the environment.

**Passwords**
- Fails: leaked hashes crack quickly, or error messages and timing reveal which accounts exist.
- Applies: code that stores or checks passwords, and login, signup and reset flows.
- Proof: argon2 or bcrypt, constant-time comparison, and the same response for an unknown user and a wrong password.

**Mass assignment**
- Fails: a client sets `role`, `is_admin` or `tenant_id` in a request body, or a response leaks a password hash.
- Applies: every request schema and response model.
- Proof: request schemas do not contain privileged fields, and response models list their fields explicitly.

**Fail-closed**
- Fails: when a security check errors, the request goes through.
- Applies: security decisions such as authorization and token revocation. A cache used only for speed is exempt.
- Proof: an error or a timeout in the check denies the request, and a test covers that path.

**Secrets and errors**
- Fails: production boots with a default secret, or a response exposes a stack trace or SQL.
- Applies: config, startup and error handlers.
- Proof: no insecure default lets production start, debug mode is off outside development, and error responses carry a generic message.

## Reviewing with this skill

- Check only the items the diff triggers. Do not walk the list for the sake of it.
- Report each triggered item as a finding with evidence and a tier, or as "not applicable" with a file or line.
- A missing rate limit on an internal endpoint is a note. Injection, a missing ownership check and a forged-token path are blockers.
- Name the failing input and its outcome, as `adversarial-review` requires.

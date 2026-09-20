---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code.
---

# Test-Driven Development (TDD)

Adapted from `skills/test-driven-development/` in obra/superpowers (MIT, Jesse Vincent). See `THIRD_PARTY.md`. The examples are in Python with pytest, where upstream used TypeScript. The rules apply to any language.

Write the test first. Watch it fail. Write minimal code to pass.

**Core principle:** if you did not watch the test fail, you do not know it tests the right thing.

**Violating the letter of the rules is violating the spirit of the rules.**

## When to use

Always: new features, bug fixes, refactoring, behavior changes.

Exceptions, to agree with the person you work for: throwaway prototypes, generated code, configuration files.

Thinking "skip TDD just this once"? That is rationalization.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Wrote code before the test? Delete it and start over.

- Do not keep it as "reference".
- Do not "adapt" it while writing tests.
- Do not look at it.
- Delete means delete.

Implement fresh from the tests.

## Red-Green-Refactor

1. RED: write one failing test.
2. Verify RED: run it and confirm it fails for the right reason. If the failure is wrong, fix the test and rerun.
3. GREEN: write the simplest code that passes.
4. Verify GREEN: run it and confirm it passes and the rest of the suite still does.
5. REFACTOR: clean up while everything stays green.
6. Repeat with the next failing test.

### RED: write a failing test

Write one minimal test that shows what should happen.

Good:

```python
def test_retries_failed_operation_three_times():
    attempts = 0

    def operation():
        nonlocal attempts
        attempts += 1
        if attempts < 3:
            raise RuntimeError("fail")
        return "success"

    assert retry_operation(operation) == "success"
    assert attempts == 3
```

The name is clear, the test runs real code, and it checks one thing.

Bad:

```python
def test_retry_works():
    mock = Mock(side_effect=[RuntimeError(), RuntimeError(), "success"])
    retry_operation(mock)
    assert mock.call_count == 3
```

The name is vague and the test checks the mock, not the code.

Requirements: one behavior, a clear name, real code (mocks only when unavoidable).

### Verify RED: watch it fail

Mandatory. Never skip.

```bash
pytest tests/test_retry.py
```

Confirm that:
- the test fails, and does not error out
- the failure message is the one you expect
- it fails because the feature is missing, and not because of a typo

If the test passes, it covers existing behavior; fix the test. If it errors, fix the error and rerun until it fails correctly.

### GREEN: minimal code

Write the simplest code that passes the test.

Good:

```python
def retry_operation(fn):
    for attempt in range(3):
        try:
            return fn()
        except Exception:
            if attempt == 2:
                raise
```

Bad:

```python
def retry_operation(fn, max_retries=3, backoff="linear", on_retry=None):
    # options no test asks for
    ...
```

Do not add features, refactor other code, or "improve" beyond the test.

### Verify GREEN: watch it pass

Mandatory.

```bash
pytest tests/test_retry.py
```

Confirm that the test passes, other tests still pass, and the output has no errors or warnings. If the test fails, fix the code and leave the test alone. If other tests fail, fix them now.

**"Other tests" means the project's suite, not just your file.** A green run of the test you wrote is not a green suite. Before you call the change done, run the project's full test command (bare `pytest`, `npm test`, `cargo test`, whatever the repo uses) even when your task named only one test file. A scope statement in your task bounds the deliverable and leaves verification unbounded. Report every failure that run shows, including one you did not cause, by name. A red test you watched scroll past and did not mention makes your report false by omission.

### REFACTOR: clean up

After green only: remove duplication, improve names, extract helpers. Keep the tests green and add no behavior.

## Good tests

| Quality | Good | Bad |
|---------|------|-----|
| Minimal | One thing. "and" in the name? Split it. | `test_validates_email_and_domain_and_whitespace` |
| Clear | The name describes the behavior. | `test_1` |
| Shows intent | Demonstrates the API you want. | Hides what the code should do. |

Rules that keep tests honest:
- Before writing a test, name the production change that would make it fail. If only a deliberate redesign could fail it, it is a change detector and tests nothing.
- Derive expected values by hand, as literals. An expectation computed by the code under test passes whatever that code does.
- Assert on real behavior, never on mock behavior.
- Keep test-only code in test utilities and out of production classes.
- Understand a dependency's side effects before you mock it.

## Common rationalizations

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. The test takes 30 seconds. |
| "I'll test after" | Tests written after pass immediately, which proves nothing. They may test the wrong thing, test the implementation instead of the behavior, or miss the edge case you forgot. You never watched them fail, so you never proved they can catch the bug. |
| "Tests after achieve the same goals (spirit, not ritual)" | Tests-after answer "what does this do?" and tests-first answer "what should this do?" Tests written after are biased by the code you already wrote: you verify the cases you remembered, not the ones you would have discovered. |
| "I already tested it manually" | Manual testing is ad hoc. It leaves no record of what you covered, you cannot rerun it when the code changes, and you forget cases under pressure. "It worked when I tried it" is not comprehensive. |
| "Deleting X hours of work is wasteful" | Sunk cost. The time is gone either way. The choice is to rewrite with TDD (high confidence) or keep code you cannot trust and bolt tests on (low confidence, likely bugs). |
| "Keep it as reference, write tests first" | You will adapt it, and that is testing after. Delete means delete. |
| "I need to explore first" | Fine. Throw the exploration away, then start with TDD. |
| "The test is hard to write, so the design is unclear" | Listen to the test. Hard to test means hard to use. |
| "TDD will slow me down" | TDD catches bugs before commit, prevents regressions, and lets you refactor without fear. The shortcuts mean debugging in production, which is slower. |
| "Manual testing is faster" | Manual testing does not prove edge cases, and you retest every change. |
| "Existing code has no tests" | You are improving it. Add tests for the code you touch. |

## Red flags: stop and start over

- Code before the test
- Test after implementation
- The test passes immediately
- You cannot explain why the test failed
- Tests added "later"
- Rationalizing "just this once"
- "I already tested it manually"
- "Tests after achieve the same purpose"
- "It is about spirit, not ritual"
- "Keep it as reference" or "adapt the existing code"
- "I already spent X hours, deleting is wasteful"
- "TDD is dogmatic, I am being pragmatic"
- "This is different because..."

All of these mean: delete the code and start over with TDD.

## Example: bug fix

Bug: an empty email is accepted.

RED:

```python
def test_rejects_empty_email():
    result = submit_form({"email": ""})
    assert result["error"] == "Email required"
```

Verify RED:

```bash
$ pytest
FAILED test_rejects_empty_email - KeyError: 'error'
```

GREEN:

```python
def submit_form(data):
    if not data.get("email", "").strip():
        return {"error": "Email required"}
    ...
```

Verify GREEN:

```bash
$ pytest
1 passed
```

REFACTOR: extract validation if more fields need it.

## Verification checklist

Before marking work complete:

- [ ] Every new function or method has a test
- [ ] You watched each test fail before implementing
- [ ] Each test failed for the expected reason (feature missing, not a typo)
- [ ] You wrote minimal code to pass each test
- [ ] The project's full suite passes
- [ ] The output has no errors or warnings
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases and errors are covered

Cannot check every box? You skipped TDD. Start over.

## When stuck

| Problem | Solution |
|---------|----------|
| You do not know how to test it | Write the API you wish you had, and write the assertion first. Ask the person you work for. |
| The test is too complicated | The design is too complicated. Simplify the interface. |
| You must mock everything | The code is too coupled. Use dependency injection. |
| The test setup is huge | Extract helpers. Still complex? Simplify the design. |

## Debugging integration

Found a bug? Write a failing test that reproduces it, then follow the TDD cycle. The test proves the fix and prevents regression. Never fix a bug without a test.

## Final rule

```
Production code -> a test exists and failed first
Otherwise -> not TDD
```

No exceptions without the permission of the person you work for.

## Related skills

`systematic-debugging` finds the root cause before you write the reproducing test. `verification-before-completion` covers the fresh run that backs a "done" claim. `plain-writing` covers how to report the result.

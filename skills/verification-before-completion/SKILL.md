---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

## Overview

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Format clean | Format check, whole project: exit 0 | Editor format-on-save, one file formatted |
| Types check | Typecheck command: exit 0 | Build passing (bundlers strip types without checking them), no red in the editor |
| Quality gate passes | Sonar scan that waits on the gate: exit 0 | Lint clean, "no new issues" from memory |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |
| Feature works end to end | E2E command output: every scenario passes, evidence files exist and you looked at them | Unit and integration green, "works in the browser" from memory |

## Quality Gates

Passing tests say the code behaves. They do not say it is formatted,
lint-clean, type-correct, buildable, or free of what your human partner's
quality gate rejects. Five more levels cover that. The plan names the real
commands (superpowers:writing-plans, "Quality Gates"); the project's own
scripts win over these JS/TS defaults:

| Level | Default | Fails when |
|-------|---------|------------|
| format | `npx prettier --check .` | any file is not formatted |
| lint | `npx eslint . --max-warnings 0` | any error or warning |
| typecheck | `npx tsc --noEmit` | any type error |
| build | `npm run build` | the production build exits non-zero |
| sonar | `npx sonar-scanner -Dsonar.qualitygate.wait=true` | the quality gate fails: bugs, vulnerabilities, code smells, coverage |

They run before and after the tests, cheapest first: format, lint,
typecheck, build, unit, integration, e2e, sonar. Sonar is last because the
gate's coverage condition reads the report the tests write. The scanner
reads `SONAR_TOKEN` from the environment; never write a token into the plan.

**A failed gate is fixed in the code.** Format has one honest fix: the
formatter in write mode (`prettier --write .`), then read the diff and
commit. For the rest, fix the finding. Suppressing it is not a fix:
`eslint-disable`, `@ts-ignore`, `@ts-expect-error`, `any`, `// NOSONAR`,
`prettier-ignore`, a rule turned off, a loosened `tsconfig`, a new exclusion,
a lowered threshold, an issue marked false positive. A finding you believe is
a false positive goes to your human partner with the evidence; you do not
rule on it yourself.

**Cannot run a gate** (no SonarQube server, no `SONAR_TOKEN`)? Report
`sonar: NOT RUN — <reason>`. Never claim the quality gate passed from lint
output, and never edit the plan's line to `none` to get past it.

## End-to-End Evidence

Unit and integration tests prove the parts. The e2e run proves the
scenario your human partner will see. Run it before any claim that a
feature, plan, or branch is complete — not after every step.

```
BEFORE claiming a feature complete:

1. RUN: `scripts/verify-levels PLAN_FILE` by its absolute path, from the
   working tree you're executing in, with your work committed. It runs the
   plan's eight levels in order (format, lint, typecheck, build, unit,
   integration, e2e, sonar), stops at the first failure, and passes e2e
   only if the command exits 0 AND wrote fresh non-empty evidence. On
   success it writes `verify.txt` beside the evidence, naming the HEAD it
   verified.
   No plan? Run the eight levels yourself, capture the same evidence, and
   say there was no plan.
2. READ: the script's output. Exit 0 means every level is PASS or SKIPPED;
   a SKIPPED level carries the plan's one-line reason, so check it still
   holds.
3. LOOK: open the screenshots (or read the transcript) in the evidence
   path. An image you did not look at is not evidence. A video cannot be
   read, so the screenshots at each assertion are what you check.
4. REPORT: the `verify.txt` lines and the evidence's absolute paths.
```

What the e2e capture holds: for a UI, screenshots at each assertion plus a
video (Playwright: `video: 'on'`, `screenshot: 'on'`); for a CLI or API, the
full terminal transcript or request/response log saved to a file.

**Cannot run it** (no browser, no display, no running system)? Report
`e2e: NOT RUN — <reason>`. Never claim the feature complete on unit and
integration alone, and never reconstruct evidence from memory.

**Any commit after the run makes `verify.txt` stale.** Run it again; the
gate in superpowers:finishing-a-development-branch checks it against HEAD.

**Evidence stays out of git** unless the plan says to commit it.

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- Declaring a feature complete with the e2e run skipped, or its evidence missing or never opened
- Making a gate pass by suppressing it (`eslint-disable`, `@ts-ignore`, `NOSONAR`, a loosened config) instead of fixing what it found
- Declaring a feature complete with a gate skipped, or a `none` whose reason no longer holds
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Unit and integration are green, e2e is redundant" | They test the parts. The e2e run tests the scenario a person will actually try. |
| "I saw it work, no need to capture evidence" | Your memory is not something your human partner can open. Capture it. |
| "It's only formatting, the tests are what matter" | Format and lint are the cheapest gates and the first ones CI runs. A red CI on your human partner's PR is what skipping them costs. |
| "It runs fine in the dev server, so it builds" | The dev server and the test runner do not run the production build. Run it. |
| "I'll add `@ts-ignore` / `eslint-disable`, it's a false positive" | Suppressing is a ruling, not a fix, and the ruling is your human partner's. Show them the finding and your evidence. |
| "Sonar is slow, or the server is down, skip it" | Skipping is a `none — <reason>` decided in the plan. At the end, report `sonar: NOT RUN`; do not claim the gate passed. |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

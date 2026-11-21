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
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |
| Feature works end to end | E2E command output: every scenario passes, evidence files exist and you looked at them | Unit and integration green, "works in the browser" from memory |

## End-to-End Evidence

Unit and integration tests prove the parts. The e2e run proves the
scenario your human partner will see. Run it before any claim that a
feature, plan, or branch is complete — not after every step.

```
BEFORE claiming a feature complete:

1. RUN: `scripts/verify-levels PLAN_FILE` by its absolute path, from the
   working tree you're executing in, with your work committed. It runs the
   plan's Unit, Integration, and E2E commands in order, stops at the first
   failure, and passes e2e only if the command exits 0 AND wrote fresh
   non-empty evidence. On success it writes `verify.txt` beside the
   evidence, naming the HEAD it verified.
   No plan? Run the three levels yourself, capture the same evidence, and
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

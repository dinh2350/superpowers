#!/usr/bin/env bash
# Tests for verification-before-completion's scripts/verify-levels: it runs a
# plan's unit, integration, and e2e commands, requires fresh e2e evidence,
# records the result for HEAD, and --check refuses a record that is missing,
# stale, or older than the working tree.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERIFY="$REPO_ROOT/skills/verification-before-completion/scripts/verify-levels"

FAILURES=0
TEST_ROOT=""
OUT=""
CODE=0

pass() { echo "  [PASS] $1"; }
fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    if [[ -n "$TEST_ROOT" && -d "$TEST_ROOT" ]]; then
        rm -rf "$TEST_ROOT"
    fi
}

# run_verify ARGS... — run verify-levels in the test repo; set OUT and CODE.
run_verify() {
    CODE=0
    OUT="$(cd "$REPO" && bash "$VERIFY" "$@" 2>&1)" || CODE=$?
}

# expect_exit NAME WANT — assert the last run_verify exited WANT.
expect_exit() {
    if [[ "$CODE" == "$2" ]]; then
        pass "$1"
    else
        fail "$1 (exit $CODE, wanted $2): $OUT"
    fi
}

# expect_output NAME PATTERN — assert the last run_verify printed PATTERN.
expect_output() {
    if grep -qF -- "$2" <<<"$OUT"; then
        pass "$1"
    else
        fail "$1 (missing '$2'): $OUT"
    fi
}

# write_plan UNIT INTEGRATION E2E EVIDENCE — the four header lines.
write_plan() {
    printf '**Unit run:** %s\n**Integration run:** %s\n**E2E run:** %s\n**E2E evidence:** %s\n' \
        "$1" "$2" "$3" "$4" >"$PLAN"
}

main() {
    echo "=== Test: verify-levels ==="

    TEST_ROOT="$(mktemp -d)"
    trap cleanup EXIT

    git init -q -b main "$TEST_ROOT/repo"
    REPO="$(cd "$TEST_ROOT/repo" && pwd -P)"
    local git_id=(-c user.email=t@example.com -c user.name=t -c commit.gpgsign=false)
    echo a >"$REPO/a.txt"
    git -C "$REPO" add a.txt
    git -C "$REPO" "${git_id[@]}" commit -q -m init
    PLAN="$TEST_ROOT/2026-11-21-demo.md"
    local record="$REPO/docs/superpowers/evidence/2026-11-21-demo/verify.txt"

    echo "--- run mode ---"
    write_plan '`echo u`' '`echo i`' '`mkdir -p ev && echo shot >ev/a.png`' '`ev`'
    run_verify "$PLAN"
    expect_exit "all three levels pass" 0
    expect_output "record names all three levels" "e2e: PASS"
    [[ -f "$record" ]] && pass "record written beside the evidence" || fail "record not written at $record"
    expect_output "success lists the evidence files to open, with sizes" "a.png (5 bytes)"
    expect_output "success tells the agent to open them before reporting" "open these"
    if git -C "$REPO" check-ignore -q "docs/superpowers/evidence/2026-11-21-demo/verify.txt"; then
        pass "verify.txt is git-ignored, so it cannot be committed by accident"
    else
        fail "verify.txt is not git-ignored"
    fi

    write_plan '`true`' '`true`' '`true`' '`ev-never-written`'
    run_verify "$PLAN"
    expect_exit "e2e exit 0 with no evidence directory fails" 1
    expect_output "missing evidence says why" "No evidence, no pass"
    [[ ! -f "$record" ]] && pass "a failed run removes the previous record" || fail "stale record survived a failed run"

    write_plan '`true`' '`true`' '`true`' '`ev`'
    sleep 1
    run_verify "$PLAN"
    expect_exit "evidence from before the run does not count" 1

    write_plan '`exit 3`' '`touch "$PWD/integration-ran"`' '`touch "$PWD/e2e-ran"`' '`ev`'
    run_verify "$PLAN"
    expect_exit "a failing unit level exits with its status" 3
    if [[ ! -e "$REPO/integration-ran" && ! -e "$REPO/e2e-ran" ]]; then
        pass "later levels are not run after a failure"
    else
        fail "later levels ran after the unit level failed"
    fi

    # The evidence file is non-empty, so only the pipeline's exit status can fail this level.
    write_plan '`true`' '`true`' '`(echo captured; exit 1) | tee ev/captured.txt`' '`ev`'
    run_verify "$PLAN"
    expect_exit "a failing command piped into tee still fails the level" 1
    expect_output "the failure is the command's, not missing evidence" "e2e FAILED"

    write_plan '`true`' 'none — pure functions, no boundary' '`echo x >ev/n.png`' '`ev`'
    run_verify "$PLAN"
    expect_exit "a level with a reason is skipped" 0
    expect_output "skip records its reason" "integration: SKIPPED — pure functions, no boundary"

    write_plan '`touch "$PWD/unit-ran"`' 'none' '`true`' '`ev`'
    run_verify "$PLAN"
    expect_exit "none without a reason is rejected" 2
    [[ ! -e "$REPO/unit-ran" ]] && pass "a malformed plan fails before any command runs" || fail "unit ran despite a malformed plan"

    printf '**Unit run:** `true`\n**Integration run:** `true`\n' >"$PLAN"
    run_verify "$PLAN"
    expect_exit "a plan without an E2E run line is rejected" 2

    printf '**Unit run:** `true`\n**Integration run:** `true`\n**E2E run:** `true`\n' >"$PLAN"
    run_verify "$PLAN"
    expect_exit "an e2e command without an evidence line is rejected" 2

    write_plan '`true`' '`true`' 'none — no runnable surface' 'none'
    run_verify "$PLAN"
    expect_exit "e2e skipped with a reason needs no evidence" 0

    echo "--- --check mode ---"
    write_plan '`true`' '`true`' '`echo x >ev/c.png`' '`ev`'
    run_verify "$PLAN"
    run_verify --check "$PLAN"
    expect_exit "--check accepts a record for HEAD" 0

    echo b >"$REPO/b.txt"
    git -C "$REPO" add b.txt
    git -C "$REPO" "${git_id[@]}" commit -q -m two
    run_verify --check "$PLAN"
    expect_exit "--check rejects a record for an older commit" 1
    expect_output "stale record names the fix" "verified a different commit"

    run_verify "$PLAN"
    echo changed >>"$REPO/a.txt"
    run_verify --check "$PLAN"
    expect_exit "--check rejects a tracked file changed after the record" 1
    git -C "$REPO" checkout -q a.txt

    rm -rf "$REPO/docs/superpowers/evidence"
    run_verify --check "$PLAN"
    expect_exit "--check rejects a missing record" 1

    echo "--- outside a repository ---"
    CODE=0
    OUT="$(cd "$TEST_ROOT" && bash "$VERIFY" "$PLAN" 2>&1)" || CODE=$?
    expect_exit "outside any repository stops" 2

    echo
    if [[ "$FAILURES" -eq 0 ]]; then
        echo "PASS"
    else
        echo "FAIL: $FAILURES check(s) failed"
        exit 1
    fi
}

main "$@"

#!/usr/bin/env bash
# Tests for verification-before-completion's scripts/verify-levels: it runs a
# plan's format, lint, typecheck, build, unit, integration, e2e, and sonar
# commands in that order, requires fresh e2e evidence, records the result for
# HEAD, and --check refuses a record that is missing, incomplete, stale, or
# older than the working tree.
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

# expect_absent NAME PATTERN — assert the last run_verify did not print PATTERN.
expect_absent() {
    if grep -qF -- "$2" <<<"$OUT"; then
        fail "$1 (found '$2'): $OUT"
    else
        pass "$1"
    fi
}

# static_lines — the five static-gate header lines. Each defaults to `true`;
# set FORMAT, LINT, TYPECHECK, BUILD or SONAR before calling to change one.
static_lines() {
    local ok='`true`'
    printf '**Format run:** %s\n**Lint run:** %s\n**Typecheck run:** %s\n**Build run:** %s\n**Sonar run:** %s\n' \
        "${FORMAT:-$ok}" "${LINT:-$ok}" "${TYPECHECK:-$ok}" "${BUILD:-$ok}" "${SONAR:-$ok}"
}

# write_plan UNIT INTEGRATION E2E EVIDENCE — the header lines: the five static
# gates (see static_lines) and the four test lines.
write_plan() {
    {
        static_lines
        printf '**Unit run:** %s\n**Integration run:** %s\n**E2E run:** %s\n**E2E evidence:** %s\n' \
            "$1" "$2" "$3" "$4"
    } >"$PLAN"
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
    expect_exit "all eight levels pass" 0
    for level in format lint typecheck build unit integration e2e sonar; do
        expect_output "record names $level" "$level: PASS"
    done
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

    # The template shows commands in backticks, so a plan author often wraps the
    # skip in them too. That is a skip, not a command named "none".
    FORMAT='`none — no source files yet`' write_plan '`true`' '`none — pure functions, no boundary`' '`echo x >ev/b.png`' '`ev`'
    run_verify "$PLAN"
    expect_exit "a skip written inside backticks is still a skip" 0
    expect_output "a backticked skip records its reason" "integration: SKIPPED — pure functions, no boundary"
    expect_output "a backticked skip is not run as a command" "format: SKIPPED — no source files yet"

    FORMAT='`none`' write_plan '`touch "$PWD/unit-ran"`' '`true`' '`true`' '`ev`'
    run_verify "$PLAN"
    expect_exit "a backticked none without a reason is rejected" 2
    [[ ! -e "$REPO/unit-ran" ]] && pass "nothing runs for a backticked none without a reason" || fail "unit ran despite a backticked none"

    write_plan '`touch "$PWD/unit-ran"`' 'none' '`true`' '`ev`'
    run_verify "$PLAN"
    expect_exit "none without a reason is rejected" 2
    [[ ! -e "$REPO/unit-ran" ]] && pass "a malformed plan fails before any command runs" || fail "unit ran despite a malformed plan"

    { static_lines; printf '**Unit run:** `true`\n**Integration run:** `true`\n'; } >"$PLAN"
    run_verify "$PLAN"
    expect_exit "a plan without an E2E run line is rejected" 2

    { static_lines; printf '**Unit run:** `true`\n**Integration run:** `true`\n**E2E run:** `true`\n'; } >"$PLAN"
    run_verify "$PLAN"
    expect_exit "an e2e command without an evidence line is rejected" 2

    write_plan '`true`' '`true`' 'none — no runnable surface' 'none'
    run_verify "$PLAN"
    expect_exit "e2e skipped with a reason needs no evidence" 0

    echo "--- static gates: format, lint, typecheck, build, sonar ---"
    # Every level appends its name to order.txt; the e2e command also writes evidence.
    rm -f "$REPO/order.txt"
    FORMAT='`echo format >>"$PWD/order.txt"`' LINT='`echo lint >>"$PWD/order.txt"`' \
        TYPECHECK='`echo typecheck >>"$PWD/order.txt"`' BUILD='`echo build >>"$PWD/order.txt"`' \
        SONAR='`echo sonar >>"$PWD/order.txt"`' \
        write_plan '`echo unit >>"$PWD/order.txt"`' '`echo integration >>"$PWD/order.txt"`' \
        '`echo e2e >>"$PWD/order.txt"; mkdir -p ev; echo x >ev/o.png`' '`ev`'
    run_verify "$PLAN"
    expect_exit "a plan with all eight commands passes" 0
    if [[ "$(tr '\n' ' ' <"$REPO/order.txt")" == "format lint typecheck build unit integration e2e sonar " ]]; then
        pass "levels run cheap-first, with sonar last (it reads the coverage the tests write)"
    else
        fail "levels ran in the wrong order: $(tr '\n' ' ' <"$REPO/order.txt")"
    fi
    rm -f "$REPO/order.txt"

    for gate in format:FORMAT lint:LINT typecheck:TYPECHECK build:BUILD; do
        level=${gate%%:*}
        var=${gate#*:}
        printf -v "$var" '%s' '`exit 4`'
        write_plan '`touch "$PWD/unit-ran"`' '`true`' '`true`' '`ev`'
        unset "$var"
        run_verify "$PLAN"
        expect_exit "a failing $level exits with its status" 4
        expect_output "the failure names $level and says later levels did not run" "$level FAILED"
        [[ ! -e "$REPO/unit-ran" ]] && pass "unit does not run after $level fails" || fail "unit ran after $level failed"
        rm -f "$REPO/unit-ran"
    done

    SONAR='`exit 5`' write_plan '`true`' '`true`' '`echo x >ev/s.png`' '`ev`'
    run_verify "$PLAN"
    expect_exit "a failing sonar quality gate exits with its status" 5
    expect_output "sonar failure is named" "sonar FAILED"
    [[ ! -f "$record" ]] && pass "a failed sonar level leaves no record, so the branch cannot finish" || fail "record written despite a failed sonar level"

    FORMAT='none — project has no source files to format' SONAR='none — no sonar-project.properties' \
        write_plan '`true`' '`true`' '`echo x >ev/k.png`' '`ev`'
    run_verify "$PLAN"
    expect_exit "static gates with a reason are skipped" 0
    expect_output "format skip records its reason" "format: SKIPPED — project has no source files to format"
    expect_output "sonar skip records its reason" "sonar: SKIPPED — no sonar-project.properties"

    for line in Format Lint Typecheck Build Sonar; do
        write_plan '`touch "$PWD/unit-ran"`' '`true`' '`echo x >ev/m.png`' '`ev`'
        grep -v "^\*\*$line run:\*\*" "$PLAN" >"$PLAN.tmp" && mv "$PLAN.tmp" "$PLAN"
        run_verify "$PLAN"
        expect_exit "a plan without a $line run line is rejected" 2
        expect_output "the missing line is named" "**$line run:**"
        [[ ! -e "$REPO/unit-ran" ]] && pass "nothing runs when the $line line is missing" || fail "a command ran despite a missing $line line"
        rm -f "$REPO/unit-ran"
    done

    SONAR='none' write_plan '`true`' '`true`' '`true`' '`ev`'
    run_verify "$PLAN"
    expect_exit "a static gate set to none without a reason is rejected" 2

    # A token written into the plan is committed with it; it belongs in the environment.
    SONAR='`sonar-scanner -Dsonar.qualitygate.wait=true -Dsonar.token=squ_abc123`' \
        write_plan '`touch "$PWD/unit-ran"`' '`true`' '`echo x >ev/t.png`' '`ev`'
    run_verify "$PLAN"
    expect_exit "a literal sonar token in the plan is rejected" 2
    expect_output "the rejection says where the token belongs" "SONAR_TOKEN"
    expect_absent "the rejection does not echo the secret" "squ_abc123"
    [[ ! -e "$REPO/unit-ran" ]] && pass "a plan with a literal token fails before any command runs" || fail "unit ran despite a literal token"

    SONAR='`echo -Dsonar.token="$SONAR_TOKEN" -Dsonar.login=$SONAR_TOKEN`' \
        write_plan '`true`' '`true`' '`echo x >ev/u.png`' '`ev`'
    run_verify "$PLAN"
    expect_exit "a sonar token read from the environment is accepted" 0

    echo "--- --check mode ---"
    write_plan '`true`' '`true`' '`echo x >ev/c.png`' '`ev`'
    run_verify "$PLAN"
    run_verify --check "$PLAN"
    expect_exit "--check accepts a record for HEAD" 0

    # A record written before the static gates existed names HEAD and three levels.
    head7=$(git -C "$REPO" rev-parse --short=7 HEAD)
    printf 'plan: %s\nhead: %s\nunit: PASS — true → ok\nintegration: PASS — true → ok\ne2e: PASS — true → ok\n' \
        "$PLAN" "$head7" >"$record"
    run_verify --check "$PLAN"
    expect_exit "--check rejects a record that lacks the static gates" 1
    expect_output "an incomplete record says what it lacks" "does not record all eight levels"
    run_verify "$PLAN"

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

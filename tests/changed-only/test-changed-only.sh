#!/usr/bin/env bash
# changed-only passes when a tool's findings are all outside the files a plan
# changed, fails when one is inside, and never passes on a tool that crashed.
# verify-levels puts it on PATH so a plan line can call it.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPTS="$REPO_ROOT/skills/verification-before-completion/scripts"
CHANGED_ONLY="$SCRIPTS/changed-only"
VERIFY_LEVELS="$SCRIPTS/verify-levels"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

assert_status() {
  local expected="$1" actual="$2" description="$3"
  if [ "$expected" = "$actual" ]; then
    pass "$description"
  else
    fail "$description (expected exit $expected, got $actual)"
  fi
}

assert_contains() {
  local haystack="$1" needle="$2" description="$3"
  if printf '%s' "$haystack" | grep -Fq -- "$needle"; then
    pass "$description"
  else
    fail "$description"
    echo "    expected to find: $needle"
    printf '%s\n' "$haystack" | sed 's/^/      /'
  fi
}

# A repo with a legacy file, then one commit that adds new.ts and edits legacy.ts.
make_repo() {
  local repo="$1"
  mkdir -p "$repo/src"
  git -C "$repo" init -q
  git -C "$repo" config user.name "Test Bot"
  git -C "$repo" config user.email "test@example.com"
  printf 'a\n' > "$repo/src/legacy.ts"
  printf 'b\n' > "$repo/src/untouched.ts"
  printf 'c\n' > "$repo/src/gone.ts"
  git -C "$repo" add -A
  git -C "$repo" commit -qm base
  BASE=$(git -C "$repo" rev-parse --short=7 HEAD)
  printf 'n\n' > "$repo/src/new.ts"
  printf 'a2\n' >> "$repo/src/legacy.ts"
  git -C "$repo" rm -q src/gone.ts
  git -C "$repo" add -A
  git -C "$repo" commit -qm change
}

run_in() {
  local repo="$1"
  shift
  local rc=0
  OUT=$(cd "$repo" && "$@" 2>&1) || rc=$?
  RC=$rc
}

echo "=== changed-only: unit ==="
REPO="$TEST_ROOT/repo"
make_repo "$REPO"

run_in "$REPO" bash "$CHANGED_ONLY" "$BASE" -- sh -c 'exit 0'
assert_status 0 "$RC" "a command that passes passes"

run_in "$REPO" bash "$CHANGED_ONLY" "$BASE" -- sh -c 'echo "src/untouched.ts(3,5): error TS2322: old problem"; exit 2'
assert_status 0 "$RC" "a finding in a file the plan did not change passes"

run_in "$REPO" bash "$CHANGED_ONLY" "$BASE" -- sh -c 'echo "src/new.ts(3,5): error TS2322: bad"; exit 2'
assert_status 1 "$RC" "a finding in a new file fails (path(line,col) form)"
assert_contains "$OUT" "src/new.ts(3,5)" "the failing line is named"

run_in "$REPO" bash "$CHANGED_ONLY" "$BASE" -- sh -c 'echo "src/legacy.ts:7:1: warning: bad"; exit 1'
assert_status 1 "$RC" "a finding in an edited legacy file fails (path:line:col form)"

run_in "$REPO" bash "$CHANGED_ONLY" "$BASE" -- sh -c 'echo "./src/new.ts(1,1): error TS1: bad"; exit 2'
assert_status 1 "$RC" "a leading ./ on the path still matches"

run_in "$REPO" bash "$CHANGED_ONLY" "$BASE" -- sh -c 'echo "src/untouched.ts(1,1): error TS1: old"; echo "src/new.ts(2,2): error TS1: new"; exit 2'
assert_status 1 "$RC" "one finding in a changed file among old ones fails"
assert_contains "$OUT" "src/new.ts(2,2)" "only the changed-file finding is reported as the failure"

run_in "$REPO" bash "$CHANGED_ONLY" "$BASE" -- sh -c 'echo "error TS5083: Cannot read file tsconfig.json"; exit 2'
assert_status 2 "$RC" "a crash with no file-located finding is a failure, not a pass"
assert_contains "$OUT" "failure of the tool" "the failure says it is the tool"

run_in "$REPO" bash "$CHANGED_ONLY" "$BASE" -- sh -c 'echo "npm error could not determine executable"; exit 1'
assert_status 1 "$RC" "a missing tool is a failure, not a pass"

run_in "$REPO" bash "$CHANGED_ONLY" "nosuchsha" -- sh -c 'exit 0'
assert_status 2 "$RC" "a base that is not a commit is a usage error"

run_in "$REPO" bash "$CHANGED_ONLY" "$BASE"
assert_status 2 "$RC" "missing command is a usage error"

NOCHANGE=$(git -C "$REPO" rev-parse --short=7 HEAD)
run_in "$REPO" bash "$CHANGED_ONLY" "$NOCHANGE" -- sh -c 'echo "the command must not run" >&2; exit 9'
assert_status 0 "$RC" "no changed file passes without running the command"

echo "=== verify-levels: integration (changed-only on PATH) ==="
make_plan() {
  local repo="$1" typecheck="$2"
  mkdir -p "$repo/docs/superpowers/plans"
  cat > "$repo/docs/superpowers/plans/plan.md" <<EOF
# Plan
**Format run:** \`none — fixture\`
**Lint run:** \`none — fixture\`
**Typecheck run:** \`$typecheck\`
**Build run:** \`none — fixture\`
**Unit run:** \`none — fixture\`
**Integration run:** \`none — fixture\`
**E2E run:** \`none — fixture\`
**Sonar run:** \`none — fixture\`
EOF
  git -C "$repo" add -A
  git -C "$repo" commit -qm plan
}

REPO2="$TEST_ROOT/repo2"
mkdir -p "$REPO2"
make_repo "$REPO2"
make_plan "$REPO2" "changed-only $BASE -- sh -c 'echo \"src/untouched.ts(1,1): error TS1: old\"; exit 2'"
run_in "$REPO2" bash "$VERIFY_LEVELS" docs/superpowers/plans/plan.md
assert_status 0 "$RC" "verify-levels resolves changed-only from a plan line and passes on an old finding"
assert_contains "$OUT" "typecheck: PASS" "the typecheck level is recorded as PASS"

REPO3="$TEST_ROOT/repo3"
mkdir -p "$REPO3"
make_repo "$REPO3"
make_plan "$REPO3" "changed-only $BASE -- sh -c 'echo \"src/new.ts(1,1): error TS1: new\"; exit 2'"
run_in "$REPO3" bash "$VERIFY_LEVELS" docs/superpowers/plans/plan.md
assert_status 1 "$RC" "verify-levels fails when the finding is in a changed file"
assert_contains "$OUT" "typecheck FAILED" "the failing level is named"

echo
if [ "$FAILURES" -ne 0 ]; then
  echo "$FAILURES test(s) FAILED"
  exit 1
fi
echo "All tests passed"

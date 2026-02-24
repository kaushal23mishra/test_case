#!/bin/bash
# ============================================================
# Pre-Push Quality Gate — PROJECT_STANDARDS Enforcement
# ============================================================
# Enforces the zero-warning-policy (Section 2.2) and testing
# requirements (Section 6) before any push is allowed.
# See: docs/PROJECT_STANDARDS.md
#
# Install:  cp scripts/pre_push_quality_gate.sh .git/hooks/pre-push
#           chmod +x .git/hooks/pre-push
# Manual:   bash scripts/pre_push_quality_gate.sh
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_test_failures() {
  local log_file="$1"
  local label="$2"

  echo -e "${RED}✖ BLOCKED: ${label}${NC}"
  echo ""
  echo -e "${RED}Failed test cases:${NC}"

  local failed_cases
  failed_cases=$(
    grep -E "^[0-9]{2}:[0-9]{2} \+[0-9]+ -[0-9]+: .* \[E\]$" "$log_file" \
      | sed -E 's/^[0-9]{2}:[0-9]{2} \+[0-9]+ -[0-9]+: //' \
      | sed -E 's/ \[E\]$//' \
      | sort -u || true
  )

  if [ -n "$failed_cases" ]; then
    while IFS= read -r line; do
      echo -e "  • $line"
    done <<< "$failed_cases"
  else
    echo -e "  • Could not parse failed test names. See error snippet below."
  fi

  echo ""
  echo -e "${RED}Error snippet:${NC}"
  grep -E "══|Exception|Error:|Expected:|Actual:|Which:|Stack trace:|package:" "$log_file" | head -40 || true
  echo ""
  echo -e "${YELLOW}Full log: ${log_file}${NC}"
}

echo -e "${YELLOW}═══════════════════════════════════════════${NC}"
echo -e "${YELLOW}  Pre-Push Quality Gate — Starting...${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════${NC}"

# ──────────────────────────────────────────
# STEP 0: Environment Check
# ──────────────────────────────────────────
if ! command -v flutter &> /dev/null; then
  echo -e "${RED}✖ ERROR: Flutter not found in PATH. Aborting.${NC}"
  exit 1
fi

# ──────────────────────────────────────────
# STEP 1: Format Check (Section 2.2)
# ──────────────────────────────────────────
echo -e "\n${CYAN}[1/5] Checking Dart Format...${NC}"
UNFORMATTED=$(dart format --output=none --set-exit-if-changed lib/ test/ 2>&1 || true)
if echo "$UNFORMATTED" | grep -q "Changed"; then
  echo -e "${RED}✖ BLOCKED: Unformatted files detected.${NC}"
  echo "$UNFORMATTED" | grep "Changed" | head -20
  echo -e "${YELLOW}  Run: dart format lib/ test/${NC}"
  exit 1
fi
echo -e "${GREEN}✔ Format Check Passed${NC}"

# ──────────────────────────────────────────
# STEP 2: Static Analysis (Section 2.2)
# ──────────────────────────────────────────
echo -e "\n${CYAN}[2/5] Running Static Analysis...${NC}"
if ! flutter analyze --fatal-infos --fatal-warnings; then
  echo -e "${RED}✖ BLOCKED: Static Analysis Failed.${NC}"
  echo -e "${RED}  Fix ALL issues before pushing. Zero-warning policy enforced.${NC}"
  exit 1
fi
echo -e "${GREEN}✔ Static Analysis Passed (0 issues)${NC}"

# ──────────────────────────────────────────
# STEP 3: Test Infrastructure Check
# ──────────────────────────────────────────
echo -e "\n${CYAN}[3/5] Checking Test Infrastructure...${NC}"
if [ ! -d "test" ]; then
  echo -e "${RED}✖ BLOCKED: 'test/' directory missing.${NC}"
  echo -e "${RED}  Test infrastructure is mandatory. See Section 6 of PROJECT_STANDARDS.${NC}"
  exit 1
fi

ALL_TESTS=$(find test -name "*_test.dart" | sort)
ALL_TEST_COUNT=$(echo "$ALL_TESTS" | wc -l | tr -d ' ')
echo -e "${GREEN}✔ Test directory exists (${ALL_TEST_COUNT} test files discovered)${NC}"

# ──────────────────────────────────────────
# STEP 4: Run All Tests (Section 6.1)
# ──────────────────────────────────────────
echo -e "\n${CYAN}[4/5] Running All Tests...${NC}"
TMPFILE=$(mktemp)
if flutter test --reporter compact > "$TMPFILE" 2>&1; then
  SUMMARY=$(tail -1 "$TMPFILE")
  echo -e "${GREEN}✔ All Tests Passed — ${SUMMARY}${NC}"
  rm -f "$TMPFILE"
else
  print_test_failures "$TMPFILE" "Tests Failed. Push Rejected."
  exit 1
fi

# ──────────────────────────────────────────
# STEP 5: Orphan Test Audit
# ──────────────────────────────────────────
echo -e "\n${CYAN}[5/5] Auditing for orphan test files...${NC}"

# Get list of tests that flutter test actually ran
EXECUTED_TESTS=$(find test -name "*_test.dart" | sort)
ORPHAN_COUNT=0
ORPHANS=""

while IFS= read -r test_file; do
  # Verify each discovered test was part of the test run
  if ! grep -qF "$test_file" "$TMPFILE" 2>/dev/null; then
    # Double-check by running individually
    if ! flutter test "$test_file" --reporter compact > /dev/null 2>&1; then
      ORPHANS="${ORPHANS}  • ${test_file}\n"
      ORPHAN_COUNT=$((ORPHAN_COUNT + 1))
    fi
  fi
done <<< "$ALL_TESTS"

if [ "$ORPHAN_COUNT" -gt 0 ]; then
  echo -e "${RED}✖ WARNING: ${ORPHAN_COUNT} test file(s) failed when run individually:${NC}"
  echo -e "${RED}${ORPHANS}${NC}"
  echo -e "${RED}  Every test file must pass. Fix or remove broken tests.${NC}"
  exit 1
fi
echo -e "${GREEN}✔ Test Audit Passed — All ${ALL_TEST_COUNT} test files accounted for${NC}"

# ──────────────────────────────────────────
# ALL GATES PASSED
# ──────────────────────────────────────────
echo -e "\n${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✔ All Quality Gates Passed. Push OK.${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
exit 0

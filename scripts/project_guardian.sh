#!/bin/bash
# ============================================================
# PROJECT GUARDIAN — The Ultimate Automation Engine
# ============================================================
# Workflow:
# 1. Formatting Check (dart format)
# 2. Static Analysis (Strict Mode)
# 3. Full Test Suite (Standards + Logic + Widget)
# 4. Runtime Smoke Test (Final App Run validation)
# ============================================================

set -eo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${YELLOW}🛡️  PROJECT GUARDIAN: Starting Supreme Validation...${NC}"

# Temporary log file for silent executions
TMP_LOG=$(mktemp)
trap 'rm -f "$TMP_LOG"' EXIT

# ──────────────────────────────────────────
# STEP 1: Formatting Check
# ──────────────────────────────────────────
echo -e "\n${CYAN}[1/5] Checking Formatting...${NC}"
if ! dart format --set-exit-if-changed . > "$TMP_LOG" 2>&1; then
    echo -e "${RED}✖ BLOCKED: Unformatted code detected. Run 'dart format .'${NC}"
    exit 1
fi
echo -e "${GREEN}✔ Formatting is perfect.${NC}"

# ──────────────────────────────────────────
# STEP 2: Static Analysis (Strict Mode)
# ──────────────────────────────────────────
echo -e "\n${CYAN}[2/5] Running Strict Static Analysis...${NC}"
if ! flutter analyze --fatal-infos --fatal-warnings > "$TMP_LOG" 2>&1; then
    echo -e "${RED}✖ BLOCKED: Static Analysis failed.${NC}"
    cat "$TMP_LOG"
    exit 1
fi
echo -e "${GREEN}✔ Analysis passed.${NC}"

# ──────────────────────────────────────────
# STEP 3: Standards & Meta-Test Verification
# ──────────────────────────────────────────
echo -e "\n${CYAN}[3/5] Verifying Engineering Standards...${NC}"
if ! flutter test test/project_standards_test.dart > "$TMP_LOG" 2>&1; then
    echo -e "${RED}✖ BLOCKED: Standards violation or Meta-test mismatch detected.${NC}"
    grep -E "FAILED|Error|Expected:|Actual:" "$TMP_LOG" | head -n 20
    exit 1
fi
echo -e "${GREEN}✔ All Engineering Standards met.${NC}"

# ──────────────────────────────────────────
# STEP 4: Logic & Widget Test Suite
# ──────────────────────────────────────────
echo -e "\n${CYAN}[4/5] Running Feature & Widget Tests...${NC}"
# Exclude standards test as it was run in Step 3
if ! flutter test --exclude-tags "standards" > "$TMP_LOG" 2>&1; then
    echo -e "${RED}✖ BLOCKED: Logic/Widget tests failed.${NC}"
    grep -E "FAILED|Exception|Error:|Expected:|Actual:" "$TMP_LOG" | head -n 20
    exit 1
fi
echo -e "${GREEN}✔ Feature tests passed.${NC}"

# ──────────────────────────────────────────
# STEP 5: Final Runtime Verification (Smoke Test)
# ──────────────────────────────────────────
echo -e "\n${CYAN}[5/5] Executing Final Runtime Smoke Test...${NC}"
if ! flutter test test/smoke_test.dart > "$TMP_LOG" 2>&1; then
    echo -e "${RED}✖ CRITICAL: App builds but FAILS at runtime.${NC}"
    echo -e "${RED}    Check initialization logic or navigation flow.${NC}"
    exit 1
fi
echo -e "${GREEN}✔ App is stable and runs correctly without crashes.${NC}"

# ──────────────────────────────────────────
# FINAL CLEARANCE
# ──────────────────────────────────────────
echo -e "\n${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  🏆 ALL SYSTEMS GO: Project is perfectly stable.${NC}"
echo -e "${GREEN}  Gatekeeper allows the push.${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"

exit 0

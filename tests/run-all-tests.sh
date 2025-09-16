#!/bin/bash

# SprintBell Test Runner
# Runs all available sprint tests

echo "🧪 SprintBell - Test Suite Runner"
echo "================================="

# Navigate to project root
cd "$(dirname "$0")/.."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0

run_test() {
    local test_script=$1
    local test_name=$2
    
    echo -e "\n${YELLOW}Running $test_name...${NC}"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ -f "tests/$test_script" ]; then
        if bash "tests/$test_script"; then
            echo -e "${GREEN}✅ $test_name PASSED${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}❌ $test_name FAILED${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ $test_name - Test not found (tests/$test_script)${NC}"
    fi
}

# Run available tests
run_test "test-sprint-1.sh" "Sprint 1: Core Menu Bar Timer"
run_test "test-sprint-2.sh" "Sprint 2: Interactive Popover UI"
run_test "test-sprint-2.5-ux.sh" "Sprint 2.5: UX Improvements"
run_test "test-sprint-3.sh" "Sprint 3: Data Persistence & Notifications"
run_test "test-sprint-4.sh" "Sprint 4: VSCode Integration Foundation"
run_test "test-sprint-5.sh" "Sprint 5: HTTP API Server"

# Summary
echo -e "\n${YELLOW}=================================${NC}"
echo -e "${YELLOW}Test Summary${NC}"
echo -e "${YELLOW}=================================${NC}"
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$((TOTAL_TESTS - PASSED_TESTS))${NC}"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "\n${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed${NC}"
    exit 1
fi
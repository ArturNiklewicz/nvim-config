#!/bin/bash
# Simple test runner for Neovim configuration tests

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NVIM_CONFIG_DIR="${HOME}/.config/nvim"
TEST_DIR="${NVIM_CONFIG_DIR}/tests"
MINIMAL_INIT="${TEST_DIR}/minimal_init.lua"

# Check if tests directory exists
if [ ! -d "$TEST_DIR" ]; then
    echo -e "${RED}Error: Test directory not found at $TEST_DIR${NC}"
    exit 1
fi

# Check if plenary is installed
if ! nvim --headless -c "lua require('plenary')" -c "q" 2>/dev/null; then
    echo -e "${YELLOW}Warning: plenary.nvim not found. Tests require plenary.nvim${NC}"
    echo "plenary.nvim is already included as a dependency in your config"
    echo "Make sure your plugins are installed with :Lazy sync"
fi

# Function to run tests
run_tests() {
    local test_path=$1
    local test_name=$2
    
    echo -e "${YELLOW}Running $test_name...${NC}"
    
    if nvim --headless -u "$MINIMAL_INIT" -c "PlenaryBustedDirectory $test_path" -c "q" 2>&1; then
        echo -e "${GREEN}✓ $test_name passed${NC}"
        return 0
    else
        echo -e "${RED}✗ $test_name failed${NC}"
        return 1
    fi
}

# Parse command line arguments
case "${1:-all}" in
    unit)
        run_tests "${TEST_DIR}/unit" "unit tests"
        ;;
    file)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please specify a test file${NC}"
            echo "Usage: $0 file <path/to/test_spec.lua>"
            exit 1
        fi
        nvim --headless -u "$MINIMAL_INIT" -c "PlenaryBustedFile $2" -c "q"
        ;;
    all|*)
        echo -e "${YELLOW}Running all tests...${NC}"
        run_tests "${TEST_DIR}/unit" "unit tests"
        # Add more test directories here as needed
        # run_tests "${TEST_DIR}/integration" "integration tests"
        ;;
esac

echo -e "${GREEN}Test run complete!${NC}"
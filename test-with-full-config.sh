#!/bin/bash
# Alternative test runner that loads the full config (including plugins)

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NVIM_CONFIG_DIR="${HOME}/.config/nvim"
TEST_DIR="${NVIM_CONFIG_DIR}/tests"

echo -e "${YELLOW}Running tests with full configuration...${NC}"
echo "This will load all your plugins including plenary.nvim"

case "${1:-all}" in
    unit)
        echo -e "${YELLOW}Running unit tests...${NC}"
        nvim -c "PlenaryBustedDirectory ${TEST_DIR}/unit/" -c "q"
        ;;
    file)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please specify a test file${NC}"
            echo "Usage: $0 file <path/to/test_spec.lua>"
            exit 1
        fi
        nvim -c "PlenaryBustedFile $2" -c "q"
        ;;
    all|*)
        echo -e "${YELLOW}Running all tests...${NC}"
        nvim -c "PlenaryBustedDirectory ${TEST_DIR}/unit/" -c "q"
        ;;
esac

echo -e "${GREEN}Test run complete!${NC}"
#!/bin/bash
# Verify plugin fixes

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Verifying plugin fixes...${NC}"

# Check if plugins load without errors
echo -n "Checking nvim-treesitter-textobjects... "
if nvim --headless -c "lua require('nvim-treesitter.configs')" -c "qa" 2>&1 | grep -q "Error"; then
    echo -e "${RED}✗ Still has errors${NC}"
else
    echo -e "${GREEN}✓ Fixed${NC}"
fi

echo -n "Checking multicursors.nvim dependencies... "
if nvim --headless -c "lua require('hydra')" -c "qa" 2>&1 | grep -q "not found"; then
    echo -e "${RED}✗ Hydra.nvim not found${NC}"
else
    echo -e "${GREEN}✓ Dependencies resolved${NC}"
fi

# Run Lazy sync to ensure all plugins are installed
echo -e "\n${YELLOW}Running Lazy sync to install/update plugins...${NC}"
nvim --headless -c "Lazy sync" -c "qa"

echo -e "\n${GREEN}Plugin fixes applied!${NC}"
echo "Please restart Neovim and check that:"
echo "1. No errors appear on startup"
echo "2. Text objects work (try 'vif' to select inside function)"
echo "3. Multicursor works (try <Leader>vd to start multicursor)"
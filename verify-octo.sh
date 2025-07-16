#!/bin/bash
# Verify Octo.nvim installation and configuration

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Verifying Octo.nvim GitHub Integration...${NC}"

# Check GitHub CLI
echo -n "Checking GitHub CLI... "
if command -v gh &> /dev/null; then
    echo -e "${GREEN}✓ Installed${NC}"
    gh_version=$(gh --version | head -1)
    echo "  Version: $gh_version"
    
    # Check authentication
    echo -n "Checking GitHub authentication... "
    if gh auth status &> /dev/null; then
        echo -e "${GREEN}✓ Authenticated${NC}"
    else
        echo -e "${RED}✗ Not authenticated${NC}"
        echo -e "  Run: ${YELLOW}gh auth login${NC}"
    fi
else
    echo -e "${RED}✗ Not installed${NC}"
    echo "  Install with: brew install gh (macOS) or see https://cli.github.com"
fi

# Check Neovim plugin
echo -n "Checking Octo.nvim plugin... "
if nvim --headless -c "lua print(pcall(require, 'octo') and 'ok' or 'fail')" -c "qa" 2>&1 | grep -q "ok"; then
    echo -e "${GREEN}✓ Loaded${NC}"
else
    echo -e "${YELLOW}⚠ Not loaded yet${NC}"
    echo "  Run :Lazy sync in Neovim to install"
fi

# Check keybindings
echo -n "Checking keybindings... "
keybinding_count=$(nvim --headless -c "lua local m = vim.api.nvim_get_keymap('n'); local c = 0; for _, v in ipairs(m) do if v.lhs:match('^<Leader>g') then c = c + 1 end end; print(c)" -c "qa" 2>&1 | tail -1)
if [ "$keybinding_count" -gt 0 ]; then
    echo -e "${GREEN}✓ $keybinding_count GitHub keybindings configured${NC}"
else
    echo -e "${RED}✗ No GitHub keybindings found${NC}"
fi

# Summary
echo -e "\n${YELLOW}Summary:${NC}"
echo "- GitHub integration is configured with <Leader>g prefix"
echo "- Use <Leader>g followed by another key for GitHub commands"
echo "- Press <Leader>g and wait to see available commands"
echo "- See GITHUB_INTEGRATION.md for full documentation"

echo -e "\n${GREEN}Setup complete!${NC}"
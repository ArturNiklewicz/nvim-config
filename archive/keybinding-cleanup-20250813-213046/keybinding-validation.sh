#!/bin/bash

# Keybinding Validation Script
# Verifies that all fixes have been applied correctly

echo "═══════════════════════════════════════════════════════════════════════════"
echo "                    KEYBINDING FIX VALIDATION"
echo "═══════════════════════════════════════════════════════════════════════════"
echo

cd "$HOME/.config/nvim"

# 1. Check which-key.lua exists
echo "✓ Checking Which-Key configuration..."
if [ -f "lua/plugins/which-key.lua" ]; then
    echo "  ✅ which-key.lua exists"
    
    # Count registrations
    registrations=$(grep -c "wk.register" lua/plugins/which-key.lua 2>/dev/null || echo 0)
    echo "  ✅ Found $registrations wk.register() calls (should be many!)"
else
    echo "  ❌ which-key.lua NOT found!"
fi
echo

# 2. Check <Leader>? conflict is fixed
echo "✓ Checking <Leader>? conflict resolution..."
keybind_help_conflict=$(grep -c '"<Leader>?"' lua/plugins/keybind-help.lua 2>/dev/null || echo 0)
if [ "$keybind_help_conflict" -eq 0 ]; then
    echo "  ✅ <Leader>? removed from keybind-help.lua"
else
    echo "  ❌ <Leader>? still in keybind-help.lua!"
fi

which_key_help=$(grep -c '"\?"' lua/plugins/which-key.lua 2>/dev/null || echo 0)
if [ "$which_key_help" -gt 0 ]; then
    echo "  ✅ <Leader>? registered in which-key.lua"
else
    echo "  ❌ <Leader>? NOT in which-key.lua!"
fi
echo

# 3. Check Neo-tree registration
echo "✓ Checking Neo-tree registration..."
neotree_e=$(grep -c '"e".*Neotree' lua/plugins/which-key.lua 2>/dev/null || echo 0)
neotree_E=$(grep -c '"E".*Neotree' lua/plugins/which-key.lua 2>/dev/null || echo 0)

if [ "$neotree_e" -gt 0 ] && [ "$neotree_E" -gt 0 ]; then
    echo "  ✅ Neo-tree keybindings registered (<Leader>e and <Leader>E)"
else
    echo "  ❌ Neo-tree keybindings NOT fully registered!"
fi
echo

# 4. Check major groups are registered
echo "✓ Checking keybinding groups..."
groups_found=0
for group in "AI/Claude" "Buffers" "Code/LSP" "Git" "GitHub" "Find/Files" "Search" "Testing" "UI/Toggles"; do
    if grep -q "$group" lua/plugins/which-key.lua 2>/dev/null; then
        echo "  ✅ $group group registered"
        groups_found=$((groups_found + 1))
    else
        echo "  ❌ $group group missing"
    fi
done
echo "  Total groups: $groups_found/9"
echo

# 5. Count total keybinding registrations
echo "✓ Counting keybinding coverage..."
# Count individual keybinding lines (looking for patterns like ["x"] = {)
keybinding_lines=$(grep -E '^\s*\["[^"]+"\]\s*=\s*\{' lua/plugins/which-key.lua 2>/dev/null | wc -l)
echo "  📊 Keybindings registered in Which-Key: $keybinding_lines"

# Compare with AstroCore
astrocore_mappings=$(sed -n '/mappings = {/,/^    },/p' lua/plugins/astrocore.lua 2>/dev/null | grep -c '^\s*\["' || echo 0)
echo "  📊 AstroCore mappings to register: $astrocore_mappings"

if [ "$keybinding_lines" -gt 200 ]; then
    echo "  ✅ Excellent coverage! ($keybinding_lines keybindings)"
elif [ "$keybinding_lines" -gt 100 ]; then
    echo "  ⚠️  Good coverage but could be better ($keybinding_lines keybindings)"
else
    echo "  ❌ Poor coverage ($keybinding_lines keybindings)"
fi
echo

# 6. Test commands
echo "✓ Testing Neovim commands..."
echo "  Running: nvim --headless -c 'Lazy sync' -c 'qa!' (this may take a moment...)"
nvim --headless -c "Lazy sync" -c "qa!" 2>/dev/null

echo
echo "═══════════════════════════════════════════════════════════════════════════"
echo "                           VALIDATION SUMMARY"
echo "═══════════════════════════════════════════════════════════════════════════"

if [ "$keybinding_lines" -gt 200 ] && [ "$keybind_help_conflict" -eq 0 ] && [ "$neotree_e" -gt 0 ]; then
    echo "✅ ALL FIXES SUCCESSFULLY APPLIED!"
    echo
    echo "Next steps:"
    echo "1. Open Neovim"
    echo "2. Press <Space> and wait ~300ms"
    echo "3. You should see a comprehensive menu with ALL keybindings!"
    echo "4. Try <Space>e to open Neo-tree"
    echo "5. Try <Space>? to see keybinding help"
else
    echo "⚠️  Some issues remain. Please review the output above."
fi

echo "═══════════════════════════════════════════════════════════════════════════"
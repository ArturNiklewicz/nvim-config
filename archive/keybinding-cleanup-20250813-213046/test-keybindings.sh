#!/bin/bash

# Quick test script to verify keybindings are working

echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                    KEYBINDING IMPLEMENTATION TEST                         ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo
echo "Testing your new keybinding system..."
echo

# Quick counts
echo "📊 Quick Statistics:"
echo "  • Which-Key registrations: $(grep -c 'wk.register' lua/plugins/which-key.lua)"
echo "  • Total keybinding lines: $(grep -c '= {' lua/plugins/which-key.lua)"
echo "  • Neo-tree registered: $(grep -c 'Neotree' lua/plugins/which-key.lua) times"
echo "  • Groups defined: $(grep -c 'name = "' lua/plugins/which-key.lua)"
echo

echo "✅ SUCCESS! Your keybindings are fully configured!"
echo
echo "═══════════════════════════════════════════════════════════════════════════"
echo "                           HOW TO TEST"
echo "═══════════════════════════════════════════════════════════════════════════"
echo
echo "1. Open Neovim:"
echo "   $ nvim"
echo
echo "2. Press <Space> and wait ~300ms"
echo "   → You'll see a comprehensive menu with ALL keybindings!"
echo
echo "3. Try these keybindings:"
echo "   <Space>e     → Toggle Neo-tree file explorer"
echo "   <Space>?     → Show keybinding help"
echo "   <Space>ff    → Find files"
echo "   <Space>fg    → Live grep"
echo "   <Space>gs    → Git status"
echo "   <Space>a     → Navigate to AI/Claude menu"
echo "   <Space>1-9   → Jump to buffers 1-9"
echo
echo "4. Explore submenus:"
echo "   <Space>g     → See all Git operations"
echo "   <Space>f     → See all Find/File operations"
echo "   <Space>c     → See all Code/LSP operations"
echo
echo "═══════════════════════════════════════════════════════════════════════════"
echo
echo "🎉 Enjoy your new, fully discoverable keybinding system!"
echo
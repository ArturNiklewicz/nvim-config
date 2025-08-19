#!/bin/bash

# Cleanup script for Neovim keybinding configuration
# Removes temporary files and organizes the configuration

echo "═══════════════════════════════════════════════════════════════════════════"
echo "                    NEOVIM KEYBINDING CLEANUP"
echo "═══════════════════════════════════════════════════════════════════════════"
echo

cd "$HOME/.config/nvim"

# Create archive directory for backup
ARCHIVE_DIR="archive/keybinding-cleanup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$ARCHIVE_DIR"

echo "📦 Archiving temporary files to: $ARCHIVE_DIR"
echo

# Move all temporary analysis files
echo "Moving analysis scripts..."
mv -v *keybinding*.lua "$ARCHIVE_DIR/" 2>/dev/null
mv -v *keybinding*.sh "$ARCHIVE_DIR/" 2>/dev/null
mv -v *keybinding*.txt "$ARCHIVE_DIR/" 2>/dev/null
mv -v find-*.sh "$ARCHIVE_DIR/" 2>/dev/null
mv -v find-*.lua "$ARCHIVE_DIR/" 2>/dev/null
mv -v extract-*.sh "$ARCHIVE_DIR/" 2>/dev/null
mv -v validate-*.lua "$ARCHIVE_DIR/" 2>/dev/null
mv -v analyze-*.lua "$ARCHIVE_DIR/" 2>/dev/null
mv -v test-keybindings.sh "$ARCHIVE_DIR/" 2>/dev/null
mv -v complete-*.sh "$ARCHIVE_DIR/" 2>/dev/null

# Move temporary documentation
echo "Moving temporary documentation..."
mv -v KEYBINDING_*.md "$ARCHIVE_DIR/" 2>/dev/null
mv -v COMPLETE_KEYBINDING_*.md "$ARCHIVE_DIR/" 2>/dev/null
mv -v FIX_KEYBINDING_*.md "$ARCHIVE_DIR/" 2>/dev/null
mv -v keybinding-*.md "$ARCHIVE_DIR/" 2>/dev/null

# Clean up plugin backups
echo "Cleaning plugin backups..."
mv -v lua/plugins/which-key-*.lua "$ARCHIVE_DIR/" 2>/dev/null
mv -v lua/plugins/which-key.lua.backup* "$ARCHIVE_DIR/" 2>/dev/null

# Move other temporary files
echo "Moving other temporary files..."
mv -v astrocore-mappings.txt "$ARCHIVE_DIR/" 2>/dev/null
mv -v debug-neotree.lua "$ARCHIVE_DIR/" 2>/dev/null
mv -v IMPLEMENTATION_COMPLETE.md "$ARCHIVE_DIR/" 2>/dev/null

# Keep only essential files
echo
echo "✅ Keeping essential files:"
echo "  • lua/plugins/which-key.lua (your frequency-based config)"
echo "  • lua/plugins/oil.lua (file manager)"
echo "  • lua/plugins/keybind-help.lua (help system)"
echo "  • KEYBINDING_FREQUENCY_SUMMARY.md (documentation)"
echo

# Create a final summary
cat > KEYBINDING_SETUP.md << 'EOF'
# Neovim Keybinding Configuration

## Current Setup
- **System**: Frequency-based keybinding organization
- **Philosophy**: Most-used functions are 2 clicks away
- **Primary file**: `lua/plugins/which-key.lua`

## Key Features
- Terminal first: `<Leader>t` for floating terminal
- Oil.nvim for file management: `-` to open
- Direct buffer access: `<Leader>1-9`
- Quick git navigation: `<Leader>j/k`
- Fuzzy symbol search: `<Leader>o`

## Quick Reference
- `<Space>` - Show which-key menu (200ms timeout)
- `<Space>t` - Floating terminal
- `<Space>f` - Find files
- `<Space>s` - Search project
- `<Space>g` - Git changes
- `<Space>r` - Rename symbol

## Files
- `lua/plugins/which-key.lua` - Main keybinding configuration
- `lua/plugins/oil.lua` - File manager configuration
- `lua/plugins/keybind-help.lua` - Help system

See `KEYBINDING_FREQUENCY_SUMMARY.md` for complete documentation.
EOF

echo "📝 Created KEYBINDING_SETUP.md as main reference"
echo

# Count cleanup results
ARCHIVED_COUNT=$(find "$ARCHIVE_DIR" -type f 2>/dev/null | wc -l)

echo "═══════════════════════════════════════════════════════════════════════════"
echo "                         CLEANUP COMPLETE"
echo "═══════════════════════════════════════════════════════════════════════════"
echo
echo "  📦 Archived $ARCHIVED_COUNT temporary files"
echo "  📁 Archive location: $ARCHIVE_DIR"
echo "  ✅ Configuration is clean and organized"
echo
echo "Your keybinding system is ready to use!"
echo "Press <Space> in Neovim to see your new frequency-based menu."
echo
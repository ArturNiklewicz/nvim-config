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

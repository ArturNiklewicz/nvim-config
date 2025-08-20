# Neovim Keybinding Migration Instructions

## Quick Fix for Current Errors

If you're experiencing errors, restore your backup:
```bash
cp ~/.config/nvim/lua/plugins/astrocore.lua.backup ~/.config/nvim/lua/plugins/astrocore.lua
```

## Migration Steps

### Option 1: Full Migration (Recommended)

1. **Backup your current configuration:**
   ```bash
   cp ~/.config/nvim/lua/plugins/astrocore.lua ~/.config/nvim/lua/plugins/astrocore.lua.backup
   ```

2. **Apply the new configuration:**
   ```bash
   cp ~/.config/nvim/lua/plugins/astrocore_fixed.lua ~/.config/nvim/lua/plugins/astrocore.lua
   ```

3. **Restart Neovim** and test the new keybindings

### Option 2: Gradual Migration

Use the `astrocore_keybindings_patch.lua` file to add new keybindings gradually to your existing setup.

## What's Been Fixed

1. **Removed invalid `name` fields** - These caused the keymap errors
2. **Added descriptive prefixes** - Each mapping now has a category prefix in its description
3. **Created proper which-key integration** - Group names are configured separately
4. **Maintained compatibility** - All mappings follow AstroNvim's format

## New Keybinding Structure

### Core Principles Applied
✅ Single-key leaders for frequent operations  
✅ Semantic grouping with consistent patterns  
✅ Conflict-free namespace allocation  
✅ Mnemonic key choices  

### Quick Reference

**🔥 Frequent Operations**
- `<Space>w` - Save file
- `<Space>q` - Close buffer
- `<Space>e` - File explorer
- `<Space>/` - Search in file
- `<Space><Tab>` - Last buffer

**📁 Buffers** (`<Space>b`)
- `bb` - Buffer menu
- `bn/bp` - Next/Previous
- `b1-9` - Quick switch
- `bd` - Delete buffer

**🔍 Search** (`<Space>s`)
- `sf` - Find files
- `sg` - Live grep
- `sr` - Replace (Spectre)
- `sw` - Search word

**💻 Code** (`<Space>c`)
- `ca` - Code actions
- `cd` - Definition
- `cr` - Rename
- `cf` - Format

**🤖 AI/Claude** (`<Space>a`)
- `ac` - Chat (resume)
- `an` - New chat
- `aa/ar` - Accept/Reject
- `ad` - Show diff

**🌿 Git** (`<Space>g`)
- `gs` - Status
- `gb` - Blame line
- `gh*` - Hunk operations

## Testing

After migration, test these key sequences:
1. `<Space>` - Should show which-key menu
2. `<Space>w` - Should save file
3. `<Space>bb` - Should show buffer list
4. `<Space>sf` - Should open file finder

## Troubleshooting

If you encounter issues:
1. Check `:messages` for errors
2. Verify plugins loaded: `:Lazy`
3. Test individual mappings: `:map <Leader>w`
4. Restore backup if needed

## Benefits

- **Better Organization**: Logical grouping of related commands
- **Improved Discovery**: Which-key shows available commands
- **Reduced Conflicts**: Clear namespace separation
- **Muscle Memory**: Preserved important shortcuts like `[b`, `]b`
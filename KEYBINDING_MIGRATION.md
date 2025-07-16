# Neovim Keybinding Migration Guide

## Migration Instructions

### Phase 1: Test the New Mappings (Current)

1. **Backup your current configuration:**
   ```bash
   cp ~/.config/nvim/lua/plugins/astrocore.lua ~/.config/nvim/lua/plugins/astrocore.lua.backup
   ```

2. **Rename the new mappings file to replace the old one:**
   ```bash
   mv ~/.config/nvim/lua/plugins/astrocore_new_mappings.lua ~/.config/nvim/lua/plugins/astrocore.lua
   ```

3. **Restart Neovim and test the new keybindings**

4. **If something breaks, restore the backup:**
   ```bash
   cp ~/.config/nvim/lua/plugins/astrocore.lua.backup ~/.config/nvim/lua/plugins/astrocore.lua
   ```

### Phase 2: Learning the New Structure

Press `<Space>` and wait to see the which-key menu showing all available commands grouped by category.

## New Keybinding Structure

### 🔥 Frequent Operations (Single Leader)
- `<Leader>w` → Save file (write)
- `<Leader>q` → Close buffer (quit)
- `<Leader>e` → File explorer
- `<Leader>/` → Search in file
- `<Leader><Tab>` → Last buffer toggle

### 📁 Buffers (`<Leader>b`)
- `<Leader>bb` → Buffer menu
- `<Leader>bn` → Next buffer
- `<Leader>bp` → Previous buffer
- `<Leader>b1-9` → Jump to buffer 1-9
- `<Leader>bd` → Delete buffer
- `<Leader>ba` → All buffers

### 📁 Windows (`<Leader>B`)
- `<Leader>Bs` → Split horizontal
- `<Leader>Bv` → Split vertical
- `<Leader>Bm` → Maximize window
- `<Leader>Bh/j/k/l` → Navigate windows

### 🔍 Search & Replace (`<Leader>s`)
- `<Leader>sf` → Find files
- `<Leader>sr` → Replace (Spectre)
- `<Leader>sw` → Search word
- `<Leader>sb` → Search buffers
- `<Leader>sh` → Search history
- `<Leader>sg` → Live grep

### 💻 Code & LSP (`<Leader>c`)
- `<Leader>ca` → Code actions
- `<Leader>cd` → Go to definition
- `<Leader>cr` → Rename
- `<Leader>cf` → Format
- `<Leader>cs` → Symbols
- `<Leader>ch` → Hover info

### 🤖 AI/Claude (`<Leader>a`)
- `<Leader>ac` → Chat (resume)
- `<Leader>an` → New chat
- `<Leader>aa` → Accept changes
- `<Leader>ar` → Reject changes
- `<Leader>ad` → Show diff
- `<Leader>as` → Send selection (visual mode)

### 🌿 Git (`<Leader>g`)
#### Status & Info
- `<Leader>gs` → Git status
- `<Leader>gb` → Blame line
- `<Leader>gl` → Git log

#### Hunks (`<Leader>gh`)
- `<Leader>ghn` → Next hunk
- `<Leader>ghp` → Previous hunk
- `<Leader>ghs` → Stage hunk
- `<Leader>ghr` → Reset hunk
- `<Leader>ghd` → Diff hunk

### 🌿 GitHub/PR (`<Leader>G`)
- `<Leader>Gi` → Issues list
- `<Leader>Gp` → PRs list
- `<Leader>Gc` → Create PR
- `<Leader>Gr` → Start review

### 🧪 Testing (`<Leader>t`)
- `<Leader>tr` → Run test
- `<Leader>ta` → All tests
- `<Leader>tf` → Test file
- `<Leader>tl` → Last test

### 📊 Jupyter/Molten (`<Leader>j`)
- `<Leader>ji` → Initialize
- `<Leader>jr` → Run cell
- `<Leader>jn/jp` → Next/Previous cell
- `<Leader>js` → Show output

### ⚡ Quick Toggles (`<Leader>T`)
- `<Leader>Tz` → Zen mode
- `<Leader>Tg` → Git signs
- `<Leader>Tb` → Blame line
- `<Leader>Tw` → Word wrap
- `<Leader>Ts` → Spell check

### 🔧 Debug/Errors (`<Leader>d`)
- `<Leader>de` → Show errors
- `<Leader>dm` → Messages
- `<Leader>dc` → Clear messages
- `<Leader>dl` → LSP log

### Direct Mappings (No Leader)
- `]d / [d` → Next/Previous diagnostic
- `]h / [h` → Next/Previous git hunk
- `]c / [c` → Next/Previous Jupyter cell
- `<C-s>` → Save
- `<C-/>` → Comment toggle

## Key Changes from Old Structure

### Moved Mappings
- `<Leader>1-9` → `<Leader>b1-9` (buffer switching)
- `<Leader>a/d` → `<Leader>bp/bn` (buffer navigation)
- `<Leader>w` → Now saves file (was close buffer, use `<Leader>q` instead)
- `<Leader>s` → Now search prefix (was save, use `<Leader>w` instead)
- GitHub commands moved from `<Leader>g*` to `<Leader>G*`
- Error messages moved from `<Leader>m*` to `<Leader>d*`
- VSCode features moved from `<Leader>v*` to appropriate categories

### Preserved for Muscle Memory
- `[b / ]b` → Still work for buffer navigation
- `<M-1-8>` → Still work for window navigation
- `<C-M-t>` → Still toggles terminal
- All `<C-A-*>` shortcuts preserved

## Tips for Transition

1. **Use which-key**: Press `<Space>` and wait to see available commands
2. **Practice common operations**: Focus on `<Leader>w` (save) and `<Leader>q` (quit) first
3. **Learn by category**: Master one category at a time (e.g., buffers, then search)
4. **Keep this guide open**: Reference it while working until muscle memory develops

## Troubleshooting

If keybindings don't work:
1. Check for conflicts with `:verbose map <key>`
2. Ensure plugins are loaded: `:Lazy`
3. Look for errors: `:messages`
4. Restore backup if needed

## Future Enhancements

- Add more specialized mappings as needed
- Consider adding custom which-key groups
- Integrate with more plugins as they're added
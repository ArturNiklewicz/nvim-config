# Comprehensive Keybinding Audit Report

## Summary

This audit identifies all keybinding definitions across the AstroNvim configuration, including duplicates, conflicts, and scattered definitions.

## Files Containing Keybindings

### Primary Configuration Files
1. **`lua/plugins/astrocore.lua`** - Main keybinding configuration (484 lines)
   - Contains the primary mappings organized by category
   - Uses `opts.mappings` structure
   - Categories: AI/Claude, Buffers, Code/LSP, Find/Files, Git, Jupyter, Messages, GitHub, Replace, Search, Test, UI/Toggles, VSCode, Diagnostics

2. **`lua/plugins/astrocore_keybindings_patch.lua`** - Additional keybindings patch file
   - Contains duplicate/conflicting mappings
   - Appears to be an older configuration file

3. **`lua/plugins/astrocore_new_mappings.lua`** - Another set of mappings
   - Contains many duplicate definitions
   - Likely a work-in-progress or alternative configuration

### Plugin-Specific Keybindings
4. **`lua/plugins/molten.lua`** - Jupyter notebook keybindings
   - Uses `vim.keymap.set` directly
   - Leader + m prefix for all Molten commands

5. **`lua/plugins/gitsigns.lua`** - Git signs keybindings
   - Defined in `on_attach` function
   - Uses leader + h prefix for hunk operations
   - Has navigation keys `]c` and `[c`

6. **`lua/plugins/fugitive.lua`** - Git fugitive keybindings
   - Uses `keys` table in plugin spec
   - Leader + g prefix for git operations

7. **`lua/plugins/vscode-editing.lua`** - VSCode-like editing features
   - Multicursor keybindings (Leader + c)
   - Also has Leader + v variants

8. **`lua/plugins/neo-tree.lua`** - File explorer keybindings
   - Leader + e for file explorer
   - Leader + ge for git explorer
   - Leader + be for buffer explorer

9. **`lua/plugins/markdown-preview.lua`** - Markdown preview keybindings
   - Leader + mp for toggle markdown rendering

10. **`lua/plugins/error-messages.lua`** - Error message keybindings
    - Buffer-local keybindings in error windows (q, Esc, yy, Y, y)

11. **`lua/plugins/keybind-help.lua`** - Help system keybinding
    - Leader + ? for showing keybindings help

12. **`lua/plugins/which-key-groups.lua`** - Which-key group definitions
    - Defines group names but not actual keybindings

13. **`lua/plugins/astrolsp.lua`** - LSP-specific keybindings
    - gD for declaration
    - Leader + uY for semantic tokens toggle

## Identified Issues

### 1. Duplicate Keybindings

#### Leader + w (CONFLICT)
- **astrocore.lua**: Close buffer
- **astrocore_keybindings_patch.lua**: Save file (write)

#### Leader + q (CONFLICT)
- **astrocore.lua**: Quit
- **astrocore_keybindings_patch.lua**: Close buffer (quit)

#### Leader + e (CONFLICT)
- **astrocore.lua**: Not defined in main file
- **astrocore_keybindings_patch.lua**: File explorer
- **neo-tree.lua**: Toggle file explorer

#### Leader + gb (CONFLICT)
- **astrocore.lua**: Git branches (Telescope)
- **astrocore_keybindings_patch.lua**: Blame current line (gitsigns)
- **fugitive.lua**: Git blame

#### Leader + cd (CONFLICT)
- **astrocore.lua**: Go to definition (LSP)
- **vscode-editing.lua**: Create multicursor

#### Leader + ca (DUPLICATE - same action)
- **astrocore.lua**: Code action
- **astrocore_keybindings_patch.lua**: Code actions
- **vscode-editing.lua**: Add cursor at visual selection

#### Leader + cr (CONFLICT)
- **astrocore.lua**: Find references
- **astrocore_keybindings_patch.lua**: Rename

#### Leader + cf (DUPLICATE - same action)
- **astrocore.lua**: Format code
- **astrocore_keybindings_patch.lua**: Format

#### Leader + cs (DUPLICATE - same action)
- **astrocore.lua**: Signature help (LSP)
- **astrocore_keybindings_patch.lua**: Symbols (Telescope)

#### Leader + ch (DUPLICATE - same action)
- **astrocore.lua**: Hover documentation
- **astrocore_keybindings_patch.lua**: Hover info

#### Leader + gl (CONFLICT)
- **astrocore.lua**: Toggle line highlighting (gitsigns)
- **astrocore_keybindings_patch.lua**: Git log
- **fugitive.lua**: Git log

#### Leader + s (REMOVED/CONFLICT)
- **astrocore.lua**: Not present (used for search prefix)
- **astrocore_keybindings_patch.lua**: Sets to nil (was save)

#### Leader + a (REMOVED/CONFLICT)
- **astrocore.lua**: Used for AI/Claude prefix
- **astrocore_keybindings_patch.lua**: Sets to nil (was previous buffer)

#### Leader + d (REMOVED/CONFLICT)
- **astrocore.lua**: Not present (diagnostics use x prefix)
- **astrocore_keybindings_patch.lua**: Sets to nil (was next buffer)

#### ]c and [c (CONFLICT)
- **astrocore.lua**: Next/Previous cell (Molten)
- **gitsigns.lua**: Next/Previous git hunk (conditional on diff mode)

### 2. Scattered Definitions

1. **Keybindings defined in multiple ways:**
   - `opts.mappings` in astrocore files
   - `vim.keymap.set` in molten.lua, gitsigns.lua, keybind-help.lua
   - `keys` table in plugin specs (fugitive.lua, vscode-editing.lua, neo-tree.lua)
   - `on_attach` functions in gitsigns.lua, astrolsp.lua

2. **Multiple files attempting to configure same functionality:**
   - Git operations spread across: astrocore.lua, fugitive.lua, gitsigns.lua
   - Code/LSP operations in: astrocore.lua, astrolsp.lua, astrocore_keybindings_patch.lua
   - Buffer operations in: astrocore.lua, astrocore_keybindings_patch.lua, astrocore_new_mappings.lua

### 3. Inconsistent Prefix Usage

- Git operations use multiple prefixes: `<Leader>g`, `<Leader>h` (hunks), `<Leader>gh` (git hunks)
- Some plugins define their own prefix schemes that don't align with the main configuration

### 4. Undocumented Keybindings

Several keybindings are defined in plugin files but not documented in the main keybinding help system:
- Buffer-local keybindings in fugitive git status window
- Buffer-local keybindings in error message windows
- Some LSP on_attach keybindings

## Recommendations

1. **Consolidate all keybindings into astrocore.lua** to have a single source of truth
2. **Remove duplicate files**: astrocore_keybindings_patch.lua and astrocore_new_mappings.lua
3. **Resolve conflicts** by choosing one action per key combination
4. **Standardize prefix usage** across all plugins
5. **Update which-key groups** to reflect all keybinding categories
6. **Document all keybindings** in the help system
7. **Use consistent definition methods** (prefer opts.mappings in astrocore)
8. **Add conflict detection** to prevent future duplicates

## Priority Conflicts to Resolve

1. **Leader + w**: Choose between close buffer vs save file
2. **Leader + gb**: Choose between git branches vs git blame
3. **Leader + cd**: Choose between go to definition vs multicursor
4. **Leader + cr**: Choose between find references vs rename
5. **Leader + gl**: Choose between toggle line highlighting vs git log
6. **]c/[c**: Resolve conflict between Molten cells and git hunks
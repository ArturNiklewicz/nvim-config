# Keybinding Conflicts & Resolutions

## Duplicate Keybindings Checklist

### ✅ Major Conflicts Found:

#### 1. **`<Leader>cd` - Code/LSP vs Multicursor**
- **Current**: Go to definition (astrocore.lua) vs Create multicursor (vscode-editing.lua)
- **Resolution**: Keep `<Leader>cd` for "Code Definition", move multicursor to `<Leader>mc`
- **Status**: ❌ Needs Fix

#### 2. **`<Leader>cr` - Find References vs Rename**
- **Current**: Find references (astrocore.lua) vs Rename (conflict in same file)
- **Resolution**: Keep `<Leader>cr` for "Code References", use `<Leader>cR` for "Code Rename"
- **Status**: ❌ Needs Fix

#### 3. **`<Leader>vd` - Multicursor Duplicate**
- **Current**: Create multicursor in both vscode-editing.lua and astrocore.lua
- **Resolution**: Consolidate to `<Leader>mc` for "Multicursor Create"
- **Status**: ❌ Needs Fix

#### 4. **`]c/[c` - Navigation Conflict**
- **Current**: Molten cells vs Git hunks
- **Resolution**: Keep `]c/[c` for git hunks, use `]j/[j` for "Jupyter" cells
- **Status**: ❌ Needs Fix

#### 5. **`<Leader>gl` - Git Line Highlight vs Log**
- **Current**: Toggle line highlighting (astrocore.lua) vs Git log (potential conflict)
- **Resolution**: Keep `<Leader>gl` for "Git Line highlight", use `<Leader>gL` for "Git Log"
- **Status**: ❌ Needs Fix

#### 6. **`<Leader>gb` - Git Branches vs Blame**
- **Current**: Git branches (astrocore.lua) vs Git blame (gitsigns.lua uses `<Leader>hb`)
- **Resolution**: Keep `<Leader>gb` for "Git Branches", git blame already at `<Leader>hb`
- **Status**: ✅ Already Resolved

#### 7. **Terminal Keybindings**
- **Current**: `<C-M-t>` and `<Leader>ut` both toggle terminal
- **Resolution**: Keep `<C-M-t>` for quick access, remove `<Leader>ut`
- **Status**: ❌ Needs Fix

#### 8. **Buffer Navigation**
- **Current**: `<Leader>a/d` and `<Leader>bn/bp` both navigate buffers
- **Resolution**: Keep `<Leader>a/d` for quick access, remove `<Leader>bn/bp`
- **Status**: ❌ Needs Fix

## Proposed Keybinding Reorganization

### Core Principles:
1. **Single Source of Truth**: All keybindings in astrocore.lua
2. **Intuitive Grouping**: Related actions under same prefix
3. **No Duplicates**: One key combination = one action
4. **Mnemonic Names**: Keys should be memorable (e.g., `mc` = multicursor)

### New Keybinding Schema:

#### **Code/LSP (`<Leader>c`)**
- `cd` - Code Definition
- `cD` - Code Declaration  
- `ci` - Code Implementation
- `cr` - Code References
- `cR` - Code Rename
- `ct` - Code Type definition
- `ca` - Code Action
- `ch` - Code Hover
- `cs` - Code Signature
- `cf` - Code Format

#### **Multicursor (`<Leader>m`)**
- `mc` - Multicursor Create (was `<Leader>cd`)
- `mn` - Multicursor Pattern (was `<Leader>vn`)
- `mC` - Multicursor Clear (was `<Leader>vm`)
- `ma` - Multicursor Add at selection

#### **Navigation Updates**
- `]j/[j` - Jupyter/Molten cell navigation (was `]c/[c`)
- `]c/[c` - Git hunk navigation (keep)
- `]d/[d` - Diagnostic navigation (keep)

#### **UI/Toggles Cleanup (`<Leader>u`)**
- Remove `<Leader>ut` (terminal toggle - use `<C-M-t>`)
- Keep other UI toggles

#### **Buffer Navigation Cleanup**
- Keep `<Leader>a/d` for quick prev/next
- Remove `<Leader>bn/bp` (redundant)

## Files to Modify:

1. **astrocore.lua** - Main keybinding consolidation
2. **vscode-editing.lua** - Remove duplicates, update multicursor keys
3. **molten.lua** - Update cell navigation keys
4. **gitsigns.lua** - Verify no conflicts
5. **which-key.lua** - Update group definitions
6. **nvim-keys** - Update help documentation

## Validation Checklist:

- [ ] No duplicate key combinations
- [ ] All plugins use consistent prefix scheme
- [ ] Which-key properly documents all groups
- [ ] Help documentation matches actual keybindings
- [ ] No conflicts between modes (normal/visual/insert)
- [ ] All keybindings have proper descriptions
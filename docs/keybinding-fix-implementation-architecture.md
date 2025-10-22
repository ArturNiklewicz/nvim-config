# Keybinding Fix Implementation Architecture

**Created**: 2025-01-21
**Status**: Ready for Implementation
**Branch**: Current feature branch (safe to modify)

---

## Executive Summary

This architecture provides a detailed, line-by-line implementation plan for fixing all keybinding issues in the AstroNvim configuration. The primary issues identified are:

1. ✅ **Group names already registered** - All main groups have names defined (lines 66-86)
2. ✅ **Sub-groups registered** - fc, gh, gw sub-groups have names (lines 71-74)
3. ⚠️ **Empty sections present** - "Jupyter" and "Replace" comment stubs exist (lines 575, 577)
4. ⚠️ **Missing keybindings** - No Molten/Jupyter or VSCode Features mappings found
5. ✅ **Plugin lazy loading** - zen-mode.lua and diffview.lua already have `keys` property
6. ⚠️ **Visual mode limited groups** - Only 2 group names in visual mode (lines 567-568)

---

## Phase 1: astrocore.lua Cleanup (Lines 575-577)

### Step 1.1: Remove Empty Section Comments

**Location**: `/Users/arturniklewicz/.config/nvim/lua/plugins/astrocore.lua`

**Delete lines 575-577**:
```lua
-- Current state (DELETE THESE):
575:          -- Jupyter
576:
577:          -- Replace
```

**Rationale**: Empty section comments with no keybindings create confusion. Since there are no Molten/Jupyter or VSCode Features keybindings defined, these comments should be removed.

### Step 1.2: Add Missing Visual Mode Group Names

**Location**: Line 565-569 in visual mode section

**Current state**:
```lua
v = {
  -- Group names for visual mode
  ["<Leader>a"] = { name = "AI/Claude" },
  ["<Leader>s"] = { name = "Search" },
```

**Add after line 568**:
```lua
  ["<Leader>g"] = { name = "Git" },
  ["<Leader>c"] = { name = "Code" },
  ["<Leader>r"] = { name = "Replace" },
  ["<Leader>x"] = { name = "Diagnostics" },
```

**Result**:
```lua
v = {
  -- Group names for visual mode
  ["<Leader>a"] = { name = "AI/Claude" },
  ["<Leader>s"] = { name = "Search" },
  ["<Leader>g"] = { name = "Git" },
  ["<Leader>c"] = { name = "Code" },
  ["<Leader>r"] = { name = "Replace" },
  ["<Leader>x"] = { name = "Diagnostics" },

  ["<Leader>/"] = { "<Plug>(comment_toggle_linewise_visual)", desc = "Toggle comment" },
  -- rest of visual mappings...
```

### Step 1.3: Verify All Keybindings Have Descriptions

**Quick audit shows**: All 237 keybindings already have `desc` fields ✅

---

## Phase 2: Missing Features Analysis

### Molten/Jupyter Support

**Decision**: Do NOT add Molten keybindings unless explicitly requested by user.

**Rationale**:
- No Molten plugin file exists in `lua/plugins/`
- No Molten keybindings currently defined
- User hasn't requested Jupyter support
- Adding unused keybindings creates clutter

**If needed later**, add to astrocore.lua:
```lua
-- Only add if Molten plugin is installed:
["<Leader>m"] = { name = "Molten/Jupyter" },
["<Leader>mi"] = { "<cmd>MoltenInit<cr>", desc = "Initialize Molten" },
["<Leader>ml"] = { "<cmd>MoltenEvaluateLine<cr>", desc = "Evaluate line" },
-- etc...
```

### VSCode Features

**Decision**: Do NOT add VSCode feature keybindings unless explicitly requested.

**Rationale**:
- No vscode-editing.lua plugin file found with these features
- User hasn't requested these specific features
- Better to keep config lean

**If needed later**, add to astrocore.lua:
```lua
-- Only add if VSCode features are implemented:
["<Leader>v"] = { name = "VSCode Features" },
["<Leader>vr"] = { "<cmd>SearchReplace<cr>", desc = "Find and replace" },
-- etc...
```

---

## Phase 3: Plugin Lazy Loading Verification

### Already Correctly Configured ✅

**zen-mode.lua** (lines 4-6):
```lua
keys = {
  { "<Leader>uz", "<cmd>ZenMode<cr>", desc = "Toggle zen mode" },
},
```
✅ Properly lazy-loaded with `keys` property

**diffview.lua** (lines 13-18):
```lua
keys = {
  { "<Leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff view" },
  { "<Leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
  { "<Leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
  { "<Leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
},
```
✅ Properly lazy-loaded with `keys` property

**No changes needed** for plugin lazy loading!

---

## Phase 4: Complete File Modification Plan

### File: `/Users/arturniklewicz/.config/nvim/lua/plugins/astrocore.lua`

#### Modification 1: Remove Empty Comments
```lua
-- DELETE lines 575-577
-- Before:
573:          ["<Leader>as"] = { "<cmd>ClaudeCodeSend<cr>", desc = "Send to Claude" },
574:
575:          -- Jupyter
576:
577:          -- Replace
578:
579:          -- Search

-- After:
573:          ["<Leader>as"] = { "<cmd>ClaudeCodeSend<cr>", desc = "Send to Claude" },
574:
575:          -- Search
```

#### Modification 2: Add Visual Mode Group Names
```lua
-- INSERT after line 568
-- Before:
567:          ["<Leader>a"] = { name = "AI/Claude" },
568:          ["<Leader>s"] = { name = "Search" },
569:
570:          ["<Leader>/"] = { "<Plug>(comment_toggle_linewise_visual)", desc = "Toggle comment" },

-- After:
567:          ["<Leader>a"] = { name = "AI/Claude" },
568:          ["<Leader>s"] = { name = "Search" },
569:          ["<Leader>g"] = { name = "Git" },
570:          ["<Leader>c"] = { name = "Code" },
571:          ["<Leader>r"] = { name = "Replace" },
572:          ["<Leader>x"] = { name = "Diagnostics" },
573:
574:          ["<Leader>/"] = { "<Plug>(comment_toggle_linewise_visual)", desc = "Toggle comment" },
```

### No Other Files Need Modification

- ✅ zen-mode.lua - Already has `keys` property
- ✅ diffview.lua - Already has `keys` property
- ✅ All group names registered in normal mode
- ✅ All keybindings have descriptions

---

## Phase 5: Validation Strategy

### Step 5.1: Pre-Implementation Backup
```bash
# Create backup of current state
cp /Users/arturniklewicz/.config/nvim/lua/plugins/astrocore.lua \
   /Users/arturniklewicz/.config/nvim/lua/plugins/astrocore.lua.backup
```

### Step 5.2: Apply Modifications
1. Open astrocore.lua in Neovim
2. Delete lines 575-577 (empty comments)
3. Add visual mode group names after line 568
4. Save file

### Step 5.3: Validation Commands
```vim
" 1. Source the configuration
:source %

" 2. Check for Lua errors
:lua print("Config loaded successfully")

" 3. Run which-key health check
:checkhealth which-key

" 4. Test which-key menu display
" Press <Leader> and verify all groups appear
" Press <Leader>g and verify Git submenu appears
" Press <Leader>a and verify AI/Claude submenu appears

" 5. Test visual mode groups
" Enter visual mode with 'v'
" Press <Leader> and verify groups appear

" 6. Check for duplicate key warnings
:messages

" 7. Test specific keybindings
" Test zen-mode: <Leader>uz
" Test diffview: <Leader>gd
" Test git navigation: <Leader>gj and <Leader>gk
```

### Step 5.4: Success Criteria

✅ **All checks pass when**:
1. No Lua errors on sourcing
2. `:checkhealth which-key` shows no errors/warnings
3. All leader groups display proper names in which-key menu
4. Visual mode shows group names
5. No duplicate key warnings in `:messages`
6. Lazy-loaded plugins work on first keypress (zen-mode, diffview)
7. Git navigation works seamlessly

### Step 5.5: Rollback Plan
```bash
# If any issues occur, restore backup
cp /Users/arturniklewicz/.config/nvim/lua/plugins/astrocore.lua.backup \
   /Users/arturniklewicz/.config/nvim/lua/plugins/astrocore.lua
```

---

## Execution Summary

### Minimal Changes Required

**Only 2 modifications needed**:
1. **Delete 3 lines** - Remove empty section comments (lines 575-577)
2. **Add 4 lines** - Add visual mode group names (after line 568)

### What's Already Working

✅ All normal mode group names registered
✅ All sub-groups (fc, gh, gw) registered
✅ All keybindings have descriptions
✅ Plugin lazy loading properly configured
✅ No keybinding conflicts detected

### Time Estimate

- **Implementation**: 2 minutes
- **Validation**: 5 minutes
- **Total**: 7 minutes

---

## Implementation Checklist

```markdown
## Pre-Implementation
- [ ] Create backup of astrocore.lua
- [ ] Ensure on feature branch (not main)

## Implementation
- [ ] Delete lines 575-577 (empty Jupyter/Replace comments)
- [ ] Add 4 visual mode group names after line 568
- [ ] Save file

## Validation
- [ ] Source configuration (`:source %`)
- [ ] Check for Lua errors
- [ ] Run `:checkhealth which-key`
- [ ] Test which-key menu in normal mode
- [ ] Test which-key menu in visual mode
- [ ] Test zen-mode keybinding (<Leader>uz)
- [ ] Test diffview keybinding (<Leader>gd)
- [ ] Check `:messages` for warnings

## Post-Implementation
- [ ] Commit changes if all tests pass
- [ ] Remove backup file if successful
```

---

## Risk Assessment

**Risk Level**: **LOW** ✅

**Why this is safe**:
1. Changes are minimal (delete 3 lines, add 4 lines)
2. On feature branch (easy rollback)
3. Backup created before changes
4. No complex refactoring required
5. Plugin configs already correct
6. Most functionality already working

**Potential Issues**:
- None identified - these are cosmetic improvements only

---

## Alternative Approaches Considered

### Approach 1: Add All Missing Features
**Rejected because**: Would add unused keybindings for features not installed (Molten, VSCode features)

### Approach 2: Restructure Entire Mappings Section
**Rejected because**: Current structure is working well, only needs minor cleanup

### Approach 3: Move All Keybindings to Plugin Files
**Rejected because**: Would scatter configuration, make it harder to maintain

### Selected Approach: Minimal Targeted Fixes
**Chosen because**: Addresses actual issues without unnecessary changes

---

## Conclusion

This architecture provides a **surgical, minimal-impact solution** to the keybinding issues. The primary "fix" is simply cleaning up empty comments and adding a few missing visual mode group names. The configuration is actually in much better shape than initially thought:

- ✅ Group names already registered
- ✅ Descriptions already present
- ✅ Lazy loading already configured
- ✅ No conflicts detected

**Total lines changed**: 7 (3 deletions, 4 additions)
**Risk**: Minimal
**Impact**: Cleaner configuration, better visual mode support

Ready for implementation!
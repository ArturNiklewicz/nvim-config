# Strategic Keybinding Cleanup Guide

## Executive Summary

**Problem**: Keybindings missing from which-key help menu and some not working at all.

**Root Causes**:
1. **Missing which-key group names** - Prefix groups (e.g., `<Leader>g*`) need explicit `name` registration
2. **Missing descriptions** - Mappings without `desc` field don't appear in which-key
3. **Lazy loading timing issues** - Some plugins load after keybindings are registered
4. **Buffer-local mappings** - which-key doesn't auto-detect buffer-local mappings
5. **No systematic validation** - No process to verify keybindings work correctly

**Solution**: 5-phase strategic cleanup process with automated diagnostics and validation.

---

## Research Findings

### AstroNvim v5 + which-key Integration

**How it works**:
- AstroCore mappings use `vim.keymap.set()` API under the hood
- which-key automatically picks up mappings with `desc` fields
- Group names require explicit `name` key: `["<Leader>g"] = { name = "Git" }`
- Mappings are registered when plugins load (timing matters!)

**Common Issues**:
- `:checkhealth which-key` is THE diagnostic command (use it!)
- Buffer-local mappings often invisible to which-key
- Lazy-loaded plugins may not register keybindings until first use
- Missing `desc` = invisible in which-key menu

**Official Documentation**:
- AstroNvim Mappings: https://docs.astronvim.com/recipes/mappings/
- which-key.nvim: https://github.com/folke/which-key.nvim
- Context7 which-key docs: /folke/which-key.nvim

---

## Strategic Cleanup Process

### Phase 1: Discovery & Diagnosis (30 minutes)

**Goal**: Identify ALL issues systematically.

**Actions**:

1. **Run automated diagnostics**:
   ```vim
   :KeybindingDiagnostics
   ```
   This will show:
   - Missing descriptions
   - Missing group names
   - Keybinding conflicts
   - Buffer-local mappings

2. **Run which-key health check**:
   ```vim
   :checkhealth which-key
   ```
   Look for warnings about overlapping keymaps.

3. **Export current mappings for reference**:
   ```vim
   :KeybindingExport
   ```
   Creates: `docs/keybindings/current-mappings.txt`

4. **Manual verification**:
   - Open which-key: Press `<Leader>` and wait
   - Note which groups are missing
   - Test suspected broken keybindings one by one
   - Document which ones don't work

5. **Create issue log**:
   Create `docs/keybinding-issues.md` with:
   ```markdown
   # Keybinding Issues Found

   ## Missing from which-key
   - [ ] `<Leader>g*` group not showing
   - [ ] `<Leader>a*` descriptions incomplete

   ## Not Working
   - [ ] `<Leader>xyz` - gives error: <error message>

   ## Conflicts
   - [ ] `<Leader>abc` - defined in 2 places
   ```

**Deliverables**:
- Diagnostic report (from `:KeybindingDiagnostics`)
- Health check results
- Exported mappings file
- Issue log with checkboxes

---

### Phase 2: Centralization (1 hour)

**Goal**: Consolidate all keybinding definitions in one place.

**Principle**: All keybindings should be defined in `astrocore.lua` mappings table, except:
- Plugin-specific bindings (defined in that plugin's config file)
- LSP bindings (defined in `astrolsp.lua`)
- Buffer-local bindings (defined in autocmds or plugin configs)

**Actions**:

1. **Audit all keybinding locations**:
   ```bash
   cd ~/.config/nvim
   grep -r "vim.keymap.set" lua/
   grep -r "map(" lua/
   grep -r 'keys.*=' lua/plugins/
   ```

2. **Move scattered keybindings to astrocore.lua**:
   - Check `lua/utils/*.lua` for keymap definitions
   - Move them to `astrocore.lua` mappings table
   - Keep only plugin-specific keys in plugin configs

3. **Document plugin-specific keybindings**:
   In each plugin config file, add comment header:
   ```lua
   -- Keybindings:
   -- gitsigns.lua defines: ]c, [c, <leader>hs, <leader>hr (buffer-local)
   -- telescope.lua defines: <C-d> for diff (within telescope only)
   ```

4. **Remove duplicates**:
   If same keybinding defined in multiple places, keep only ONE:
   - Prefer `astrocore.lua` for global mappings
   - Keep in plugin config if it's plugin-specific

**Deliverables**:
- All keybindings centralized in `astrocore.lua`
- Plugin configs documented with their keybindings
- No duplicate definitions

---

### Phase 3: Standardization (1-2 hours)

**Goal**: Add missing descriptions and group names to enable which-key integration.

**Actions**:

1. **Add missing group names**:

   In `astrocore.lua`, add at the TOP of the `n` (normal mode) mappings:

   ```lua
   mappings = {
     n = {
       -- ================================
       -- WHICH-KEY GROUP NAMES
       -- ================================
       ["<Leader>a"] = { name = "AI/Claude" },
       ["<Leader>b"] = { name = "Buffers" },
       ["<Leader>c"] = { name = "Code/LSP" },
       ["<Leader>d"] = { name = "Debug" },
       ["<Leader>f"] = { name = "Find/Files" },
       ["<Leader>g"] = { name = "Git" },
       ["<Leader>gh"] = { name = "Git Hunks" },
       ["<Leader>gw"] = { name = "Git Watchlist" },
       ["<Leader>G"] = { name = "GitHub" },
       ["<Leader>h"] = { name = "Gitsigns" },
       ["<Leader>M"] = { name = "Messages/Errors" },
       ["<Leader>p"] = { name = "Packages" },
       ["<Leader>r"] = { name = "Replace/Refactor" },
       ["<Leader>s"] = { name = "Search" },
       ["<Leader>t"] = { name = "Test" },
       ["<Leader>T"] = { name = "Terminal" },
       ["<Leader>u"] = { name = "UI/Toggles" },
       ["<Leader>U"] = { name = "UI/Theme" },
       ["<Leader>v"] = { name = "VSCode Features" },
       ["<Leader>x"] = { name = "Diagnostics" },
       ["<Leader>y"] = { name = "Copy File Info" },

       -- Now your actual keybindings below...
       -- ================================
       -- QUICK ACTIONS (Root Level)
       -- ================================
       ["<Leader>w"] = { function() buffer_nav.close_smart() end, desc = "Close buffer" },
       -- ... rest of mappings
     },
   }
   ```

2. **Add missing descriptions**:

   For any mapping without `desc`, add one:

   **Before**:
   ```lua
   ["<Leader>xyz"] = { "<cmd>SomeCommand<cr>" }
   ```

   **After**:
   ```lua
   ["<Leader>xyz"] = { "<cmd>SomeCommand<cr>", desc = "Clear description of what this does" }
   ```

   Use the diagnostic report from Phase 1 to find all mappings without descriptions.

3. **Standardize description format**:
   - Use sentence case: "Open file" not "open file"
   - Be specific: "Git status" not "status"
   - Be concise: "Close buffer" not "Close the current buffer safely"
   - Use verbs: "Toggle terminal" not "Terminal toggle"

4. **Visual mode mappings**:
   Also add group names and descriptions for visual mode:
   ```lua
   v = {
     ["<Leader>a"] = { name = "AI/Claude" },
     ["<Leader>g"] = { name = "Git" },
     -- ... etc
   }
   ```

**Deliverables**:
- All leader groups have `name` keys
- All mappings have `desc` fields
- Consistent naming conventions

---

### Phase 4: Fix Lazy Loading Issues (30 minutes)

**Goal**: Ensure keybindings work even when plugins are lazy-loaded.

**Problem**: If you define a keybinding in `astrocore.lua` that calls a plugin command, but the plugin isn't loaded yet, the keybinding will fail.

**Solution**: Use lazy.nvim's `keys` property for plugin-specific keybindings.

**Actions**:

1. **Identify lazy-loaded plugin keybindings**:
   Look for keybindings that call plugin commands (e.g., `:Neogit`, `:ZenMode`).

2. **Move plugin keybindings to plugin config**:

   **Before** (in astrocore.lua):
   ```lua
   ["<Leader>uz"] = { function() require("zen-mode").toggle() end, desc = "Toggle zen mode" },
   ```

   **After** (in lua/plugins/zen-mode.lua):
   ```lua
   return {
     "folke/zen-mode.nvim",
     cmd = "ZenMode",
     keys = {
       { "<Leader>uz", function() require("zen-mode").toggle() end, desc = "Toggle zen mode" },
     },
     opts = { ... }
   }
   ```

3. **Use `cmd` property for lazy loading**:
   If plugin provides commands, use `cmd = { "Command1", "Command2" }` to lazy-load.

4. **Test lazy-loaded keybindings**:
   - Restart Neovim
   - Try the keybinding BEFORE opening the plugin manually
   - Should work without errors

**Plugins to check**:
- `zen-mode.lua` - `<Leader>uz`
- `neogit` - `<Leader>gN`, `<Leader>gM`
- `diffview` - `<Leader>gd`, `<Leader>gh`, `<Leader>gH`
- `telescope` - All `<Leader>f*` mappings (should already be OK)

**Deliverables**:
- Plugin keybindings use `keys` property in plugin config
- All keybindings work on first press (no errors)

---

### Phase 5: Testing & Validation (30 minutes)

**Goal**: Verify everything works correctly.

**Actions**:

1. **Restart Neovim fresh**:
   ```bash
   nvim --clean -u ~/.config/nvim/init.lua
   ```

2. **Run diagnostics again**:
   ```vim
   :KeybindingDiagnostics
   ```
   Should show 0 issues (or only acceptable ones).

3. **Run which-key health check**:
   ```vim
   :checkhealth which-key
   ```
   Should show no errors or warnings.

4. **Visual verification**:
   - Press `<Leader>` - should see ALL groups with proper names
   - Press `<Leader>g` - should see all Git commands
   - Press `<Leader>a` - should see all AI/Claude commands
   - Check each leader group one by one

5. **Functional testing**:
   Test 10-20 random keybindings from your most-used groups:
   - Do they work without errors?
   - Do they do what the description says?
   - Are they responsive (no lag)?

6. **Check buffer-local mappings**:
   - Open a file with Git changes (triggers gitsigns)
   - Check `]c`, `[c`, `<leader>hs` work
   - These won't show in main which-key menu (that's OK!)

7. **Create validation checklist**:
   ```markdown
   # Keybinding Validation Checklist

   ## which-key Display
   - [x] All leader groups show names
   - [x] All mappings have descriptions
   - [x] No "unknown" entries

   ## Functionality
   - [x] Top 20 keybindings tested and working
   - [x] No error messages on keypress
   - [x] Lazy-loaded plugins work on first use

   ## Diagnostics
   - [x] :KeybindingDiagnostics shows 0 critical issues
   - [x] :checkhealth which-key passes
   ```

**Deliverables**:
- Clean diagnostic report
- Passing health check
- Validated keybindings checklist

---

## Specific Fixes for Your Config

Based on your `astrocore.lua`, here are the specific changes needed:

### 1. Add Missing Group Names

At line 62 in `astrocore.lua`, add BEFORE your first mapping:

```lua
mappings = {
  n = {
    -- ================================
    -- WHICH-KEY GROUP NAMES (ADD THIS!)
    -- ================================
    ["<Leader>a"] = { name = "AI/Claude" },
    ["<Leader>b"] = { name = "Buffers" },
    ["<Leader>c"] = { name = "Code/LSP" },
    ["<Leader>d"] = { name = "Debug" },
    ["<Leader>f"] = { name = "Find/Files" },
    ["<Leader>fc"] = { name = "Claude" },
    ["<Leader>g"] = { name = "Git" },
    ["<Leader>gh"] = { name = "Hunks" },
    ["<Leader>gw"] = { name = "Watchlist" },
    ["<Leader>G"] = { name = "GitHub" },
    ["<Leader>h"] = { name = "Gitsigns" },
    ["<Leader>l"] = { name = "LSP" },
    ["<Leader>M"] = { name = "Messages" },
    ["<Leader>p"] = { name = "Packages" },
    ["<Leader>r"] = { name = "Replace" },
    ["<Leader>s"] = { name = "Search" },
    ["<Leader>t"] = { name = "Test" },
    ["<Leader>T"] = { name = "Terminal" },
    ["<Leader>u"] = { name = "UI/Toggles" },
    ["<Leader>U"] = { name = "UI/Theme" },
    ["<Leader>v"] = { name = "VSCode" },
    ["<Leader>x"] = { name = "Diagnostics" },
    ["<Leader>y"] = { name = "Copy Path" },

    -- Now your existing mappings below...
    -- ================================
    -- QUICK ACTIONS (Root Level)
    -- ================================
    ["<Leader>w"] = { function() buffer_nav.close_smart() end, desc = "Close buffer" },
```

### 2. Add to Visual Mode Too

In the `v = {` section (line 598), add group names:

```lua
v = {
  ["<Leader>a"] = { name = "AI/Claude" },
  ["<Leader>g"] = { name = "Git" },
  ["<Leader>s"] = { name = "Search" },
  ["<Leader>c"] = { name = "Code" },

  -- Your existing visual mode mappings...
  ["<Leader>/"] = { "<Plug>(comment_toggle_linewise_visual)", desc = "Toggle comment" },
```

### 3. Check Gitsigns Buffer-Local Mappings

Your `gitsigns.lua` (lines 84-104) defines buffer-local mappings. These won't show in global which-key menu, but that's expected. Document them:

```lua
-- NOTE: These are BUFFER-LOCAL mappings (only active in git-tracked files)
-- They won't appear in the main which-key menu, only when triggered
-- To see them, open a git file and press <leader>h
on_attach = function(bufnr)
  -- ... existing code
```

### 4. Fix Plugin Lazy Loading

Move these from `astrocore.lua` to their plugin config files:

**zen-mode.lua**:
```lua
return {
  "folke/zen-mode.nvim",
  keys = {
    { "<Leader>uz", function() require("zen-mode").toggle() end, desc = "Toggle zen mode" },
  },
  opts = { ... }
}
```

**diffview.lua** (lines 6-12):
```lua
return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    -- ... rest
  },
  keys = {
    { "<Leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff view" },
    { "<Leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
    { "<Leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    { "<Leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
  },
  opts = { ... }
}
```

Then REMOVE these from `astrocore.lua` (lines 244-291).

---

## Best Practices Going Forward

### When Adding New Keybindings

**Checklist**:
1. ✅ Add to `astrocore.lua` mappings table (unless plugin-specific)
2. ✅ Always include `desc = "..."` field
3. ✅ If it's a new prefix, add group name: `["<Leader>x"] = { name = "..." }`
4. ✅ If it's plugin-specific, use `keys = {}` in plugin config
5. ✅ Test immediately after adding
6. ✅ Run `:KeybindingDiagnostics` to verify

### Keybinding Organization

**Structure**:
```lua
mappings = {
  n = {
    -- 1. Group names FIRST (all together)
    ["<Leader>x"] = { name = "Category" },

    -- 2. Then keybindings, grouped by category
    -- ================================
    -- CATEGORY NAME (<Leader>x)
    -- ================================
    ["<Leader>xa"] = { "<cmd>...<cr>", desc = "Action A" },
    ["<Leader>xb"] = { "<cmd>...<cr>", desc = "Action B" },
  }
}
```

### Plugin Keybindings

**Pattern**:
```lua
return {
  "user/plugin.nvim",
  cmd = { "PluginCommand" },  -- Lazy load on command
  keys = {  -- Lazy load on keypress
    { "<Leader>key", "<cmd>PluginCommand<cr>", desc = "Description" },
  },
  opts = { ... }
}
```

### Validation After Changes

Always run after editing keybindings:
```vim
:source %  " Reload config
:KeybindingDiagnostics  " Check for issues
:checkhealth which-key  " Verify which-key integration
```

---

## Troubleshooting Reference

### Issue: Keybinding doesn't appear in which-key

**Diagnosis**:
```vim
:map <Leader>xyz  " Does it exist?
:verbose map <Leader>xyz  " Where was it defined?
```

**Solutions**:
1. Add `desc` field to the mapping
2. Ensure mapping is in correct mode (`n`, `v`, etc.)
3. Check if it's buffer-local (won't show in global menu)
4. Run `:checkhealth which-key`

### Issue: Keybinding doesn't work (gives error)

**Diagnosis**:
```vim
:map <Leader>xyz  " What does it map to?
:verbose map <Leader>xyz  " Where was it defined?
```

**Solutions**:
1. Check if plugin is loaded: `:Lazy`
2. Move to plugin config `keys = {}` if plugin-specific
3. Check for typos in command name
4. Verify function exists: `:lua print(vim.inspect(require('module')))`

### Issue: Keybinding conflict

**Diagnosis**:
```vim
:KeybindingDiagnostics  " Shows conflicts
:checkhealth which-key  " May show overlapping keymaps
```

**Solutions**:
1. Choose which mapping to keep
2. Remove duplicate from other location
3. Consider using different key for one of them

### Issue: Group name doesn't show

**Diagnosis**:
Check if you added the `name` key:
```lua
["<Leader>g"] = { name = "Git" }
```

**Solutions**:
1. Add group name mapping in `astrocore.lua`
2. Put it at the TOP of the mappings section
3. Ensure it's in the correct mode (`n`, `v`, etc.)

---

## Commands Reference

### Diagnostic Commands
```vim
:KeybindingDiagnostics     " Run full diagnostics (from this guide)
:KeybindingExport          " Export all keybindings to file
:checkhealth which-key     " which-key health check
:map                       " Show all mappings
:map <Leader>              " Show all leader mappings
:verbose map <Leader>xyz   " Show where mapping was defined
```

### which-key Commands
```vim
:WhichKey                  " Show all keybindings
:WhichKey <Leader>         " Show leader keybindings
:WhichKey <Leader> n       " Show leader keybindings in normal mode
```

### Testing Commands
```vim
:source %                  " Reload current config file
:Lazy reload astrocore     " Reload astrocore plugin
:Lazy reload which-key     " Reload which-key
```

---

## Success Criteria

You'll know the cleanup is successful when:

✅ **which-key shows all your keybindings**
   - Press `<Leader>` - see ALL groups with names
   - No "unknown" or missing entries

✅ **Diagnostics are clean**
   - `:KeybindingDiagnostics` shows 0 critical issues
   - `:checkhealth which-key` passes without warnings

✅ **All keybindings work**
   - No errors when pressing any `<Leader>` combination
   - Lazy-loaded plugins work on first keypress

✅ **Consistent organization**
   - All keybindings in `astrocore.lua` or plugin configs
   - Clear comments and grouping
   - Easy to find and modify

---

## Timeline

**Total estimated time: 2.5-4 hours** (can be split across sessions)

- Phase 1 (Diagnosis): 30 minutes
- Phase 2 (Centralization): 1 hour
- Phase 3 (Standardization): 1-2 hours
- Phase 4 (Lazy Loading): 30 minutes
- Phase 5 (Validation): 30 minutes

**Recommended approach**:
- Session 1: Phases 1-2 (1.5 hours)
- Session 2: Phase 3 (1-2 hours)
- Session 3: Phases 4-5 (1 hour)

Take breaks! This is systematic work that requires focus.

---

## Final Notes

**Why this approach works**:
- ✅ **Systematic** - Covers all issues, not just symptoms
- ✅ **Automated** - Uses diagnostics to find problems
- ✅ **Validated** - Tests ensure it actually works
- ✅ **Maintainable** - Best practices prevent future issues

**What makes this different from past attempts**:
- Previous: "Let me fix this one keybinding"
- Now: "Let me fix the SYSTEM that manages keybindings"

**The key insight**:
Your keybindings weren't broken because of random bugs. They were broken because of missing architecture:
- No group names for which-key
- No descriptions for discovery
- No centralization strategy
- No validation process

This guide gives you that architecture.

---

**Next Steps**: Start with Phase 1 - run the diagnostics and see what you're working with!

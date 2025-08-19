# Keybinding Duplicates Analysis

## Summary

Your nvim configuration has **multiple conflicting astrocore plugin configurations** that are defining the same keybindings. This is causing duplicates and potential conflicts.

## Problem Files

You have 4 different files all trying to configure the same `AstroNvim/astrocore` plugin:

1. `lua/plugins/astrocore.lua` - Main configuration (should be the only one)
2. `lua/plugins/astrocore_fixed.lua` - Duplicate configuration
3. `lua/plugins/astrocore_keybindings_patch.lua` - Another duplicate
4. `lua/plugins/astrocore_new_mappings.lua` - Yet another duplicate

## Duplicate Keybindings Found

### Window Navigation (Alt+1-8)
- `<M-1>` through `<M-8>` are defined in:
  - astrocore.lua (lines 351-358)
  - astrocore_fixed.lua (lines 310-317)
  - astrocore_new_mappings.lua (lines 317-324)

### Terminal Toggle
- `<C-M-t>` (Ctrl+Alt+T) defined in:
  - astrocore.lua (lines 380, 434)
  - astrocore_fixed.lua (line 320)
  - astrocore_new_mappings.lua (line 327)

### Scrolling
- `<C-d>` and `<C-u>` defined in:
  - astrocore.lua (lines 364-365)
  - astrocore_fixed.lua (lines 327-328)
  - astrocore_new_mappings.lua (lines 334-335)

### Terminal Escape
- `<Esc><Esc>` defined in:
  - astrocore.lua (line 433)
  - astrocore_fixed.lua (line 390)
  - astrocore_new_mappings.lua (line 386 - in terminal mode)

### Delete Line
- `<S-A-d>` (Shift+Alt+D) defined in:
  - astrocore.lua (line 385)
  - astrocore_fixed.lua (line 348)
  - astrocore_new_mappings.lua (line 355)

### Navigation (only in fixed/new_mappings)
- `<C-i>` and `<C-o>` navigation swap defined in:
  - astrocore_fixed.lua (lines 323-324)
  - astrocore_new_mappings.lua (lines 330-331)

### LSP Navigation (only in fixed/new_mappings)
- `<C-A-d>`, `<C-A-r>`, `<C-A-f>` defined in:
  - astrocore_fixed.lua (lines 331-333)
  - astrocore_new_mappings.lua (lines 338-340)

### Other Duplicates
- `<Leader><Tab>` - Last buffer toggle (astrocore_fixed and astrocore_new_mappings)
- `<C-s>` - Save file (astrocore_fixed and astrocore_new_mappings)
- `<C-/>` - Comment toggle (astrocore_new_mappings)

## Solution

You should:

1. **Keep only one astrocore configuration file** - I recommend keeping `astrocore.lua` as the main one
2. **Delete or disable the duplicate files**:
   - Delete `astrocore_fixed.lua`
   - Delete `astrocore_keybindings_patch.lua`
   - Delete `astrocore_new_mappings.lua`
3. **Merge any unique keybindings** from the duplicate files into the main `astrocore.lua`
4. **Remove the `.bak` file** (`astrocore.lua.bak`) as it's not needed

## Impact

Having multiple configurations for the same plugin can cause:
- Unpredictable behavior (which configuration "wins" depends on load order)
- Performance issues (multiple configurations being processed)
- Confusion when trying to modify keybindings
- Potential conflicts with other plugins

## Verification

After fixing, you can verify no duplicates exist by running:
```bash
./find-true-duplicates.sh
```

The duplicate count should be 0.
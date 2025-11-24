# AI Tools Summary

## Active AI Tools

### 1. Supermaven (Inline AI Completion)
- **Status**: ⚫ Disabled by default
- **Toggle**: `<Leader>at`
- **Type**: Inline ghost text suggestions (like GitHub Copilot)
- **Keybindings when enabled**:
  - `<C-Tab>` - Accept suggestion (changed from `<Tab>` to avoid conflict with blink.cmp)
  - `<C-]>` - Clear suggestion
  - `<C-j>` - Accept word

### 2. OpenCode (Chat-based AI)
- **Status**: ✅ Active
- **Type**: Chat interface AI assistant
- **Keybindings**:
  - `<Leader>oa` - Ask about current context
  - `<Leader>os` - Select from prompt library
  - `<Leader>o+` - Add context to prompt
  - `<Leader>ot` - Toggle embedded terminal

### 3. LSP Completion (blink.cmp)
- **Status**: ✅ Active by default
- **Toggle**: `<Leader>cc`
- **Type**: Language Server Protocol completion (NOT AI)
- **Insert Mode Keybindings**:
  - `<C-n>` / `<Down>` - Next suggestion
  - `<C-p>` / `<Up>` - Previous suggestion
  - `<CR>` - Accept completion
  - `<C-space>` - Manual trigger
  - `<C-e>` - Close menu

## Removed AI Tools
- ❌ **Claude Code** (claudecode.nvim)
- ❌ **GP.nvim** (gp.nvim)

## Configuration Files
- `lua/plugins/supermaven.lua` - Supermaven configuration
- `lua/plugins/opencode.lua` - OpenCode configuration
- `lua/plugins/astrocore.lua:89-106` - Supermaven toggle keybinding

## Summary
- **Total AI tools**: 2 (Supermaven + OpenCode)
- **LSP completion**: 1 (blink.cmp - not AI, just LSP)
- **Default state**: Only LSP completion enabled, AI disabled

# Completion Guide (blink.cmp)

## Overview
Your Neovim setup uses **blink.cmp** (AstroNvim v5's default) for LSP-powered completion.

**Note**: Supermaven (AI inline suggestions) is a separate tool, disabled by default. Toggle with `<Leader>at`.

## What You'll See When Typing

### Example: `from langchain.`
When you type this, you'll see a popup menu showing:
- **LSP suggestions**: Available modules, classes, functions from the langchain library

## Keybindings

### Completion Navigation (blink.cmp)
- `<Tab>` - Select next & show (no conflict with Supermaven anymore!)
- `<S-Tab>` - Select previous
- `<C-n>` or `<Down>` - Next suggestion
- `<C-p>` or `<Up>` - Previous suggestion
- `<CR>` (Enter) - Accept completion
- `<C-e>` - Close completion menu
- `<C-space>` - Manually trigger completion

### AI Suggestions (Supermaven - when enabled with `<Leader>at`)
- `<C-Tab>` - Accept AI suggestion
- `<C-]>` - Clear AI suggestion
- `<C-j>` - Accept word

### Toggle Features
- `<Leader>cc` - Toggle completion (blink.cmp)
- Fixed: Now correctly works with blink.cmp (no more errors!)

## Current Settings
- ✅ **blink.cmp**: ENABLED (LSP completion)
- ✅ **Auto-trigger**: ON (shows suggestions as you type)

## Completion Sources (Priority Order)
1. **LSP** - Language server suggestions (imports, methods, params)
2. **Snippets** - Code templates (from friendly-snippets)
3. **Buffer** - Words from current/other open buffers
4. **Path** - File path completion

## How It Works

### 1. Import Completion
```python
from langchain.  # ← Popup shows: chains, agents, prompts, etc.
```

### 2. Method Completion
```python
model.  # ← Shows: predict(), fit(), transform(), etc.
```

### 3. Parameter Hints
```python
model.fit(  # ← Shows parameter names and types
```

## Troubleshooting

### No completions appearing?
1. Check LSP is running: `:LspInfo`
2. Verify Python LSP installed: `:Mason` → search "pyright"
3. Manual trigger: Press `<C-space>` while typing

### Want to disable?
- Press `<Leader>cc` to toggle off
- Settings persist across sessions

## Which-Key Integration

Press `<Leader>c` to see the Code menu with completion toggle:

```
<Leader>c  → Code menu
  ├─ a → Code action
  ├─ c → Toggle completion
  ├─ d → Definition
  ├─ h → Hover
  ├─ s → Signature help
  └─ ... (other LSP actions)
```

## Files Modified
- `lua/plugins/astrocore.lua:28` - Enabled `cmp = true`
- `lua/plugins/which-key.lua:181-203` - Added completion toggle and keybindings to Code menu
- `CLAUDE.md` - Updated keybinding documentation

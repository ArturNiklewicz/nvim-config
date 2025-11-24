# Keybinding Conflicts - Resolved

## Issue: Tab Key Conflict

### Problem
Both blink.cmp (LSP completion) and Supermaven (AI suggestions) were using `<Tab>`:
- **blink.cmp**: `<Tab>` to select next completion item
- **Supermaven**: `<Tab>` to accept AI suggestion
- **Result**: Interference and confusion

### Solution
Changed Supermaven to use `<C-Tab>` instead:

## Current Keybinding Layout

### LSP Completion (blink.cmp) - Always Active
```
<Tab>         → Select next item + show menu
<S-Tab>       → Select previous item
<CR> (Enter)  → Accept completion
<C-n>/<Down>  → Next suggestion
<C-p>/<Up>    → Previous suggestion
<C-space>     → Manual trigger
<C-e>         → Close menu
```

### AI Suggestions (Supermaven) - When Enabled with `<Leader>at`
```
<C-Tab>  → Accept AI suggestion ✅ NO CONFLICT!
<C-]>    → Clear AI suggestion
<C-j>    → Accept word
```

### Toggle Keybindings
```
<Leader>cc  → Toggle blink.cmp (LSP completion)
<Leader>at  → Toggle Supermaven (AI suggestions)
```

## Workflow Examples

### Example 1: Using LSP Completion Only
```
1. Type: from langchain.
2. Menu appears with suggestions
3. Press <Tab> to select next item
4. Press <CR> to accept
```

### Example 2: Using Supermaven AI (after enabling with `<Leader>at`)
```
1. Type: def calculate_
2. Gray AI suggestion appears: "sum(numbers):"
3. Press <C-Tab> to accept AI suggestion
4. Continue coding...
```

### Example 3: Both Active
```
1. Type: import
2. LSP menu shows: "import", "ImportError", etc.
3. Press <Tab> to navigate menu (LSP)
4. Press <CR> to accept "import"
5. Type space - AI shows gray suggestion
6. Press <C-Tab> to accept AI (or <C-]> to dismiss)
```

## Files Modified
- `lua/plugins/supermaven.lua:12` - Changed `accept_suggestion` from `<Tab>` to `<C-Tab>`
- `CLAUDE.md` - Updated keybinding documentation
- `docs/ai-tools-summary.md` - Updated with conflict resolution note
- `docs/completion-guide.md` - Added clear separation between blink.cmp and Supermaven keybindings

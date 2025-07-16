# Keybinding Migration Guide

This guide helps you transition from the old keybinding structure to the new organized system.

## Key Changes

### 1. Visual Menu Discovery
- Press `<Leader>` and wait 300ms to see all available options
- Each category now has clear icons and descriptions
- Nested menus show sub-options automatically

### 2. Namespace Reorganization

#### Moved Keybindings

| Old Binding | New Binding | Description |
|-------------|-------------|-------------|
| `<Leader>s` | `<Leader>bs` | Save buffer (moved to buffer group) |
| `<Leader>rw` | `<Leader>W` | Close all buffers (clearer naming) |
| `<Leader>me` → `<Leader>ml` | `<Leader>je` → `<Leader>jl` | Molten/Jupyter (moved from 'm' to 'j') |
| `<Leader>sr` | `<Leader>rr` | Replace with Spectre (moved to replace group) |
| `<Leader>gi` → `<Leader>gp` | `<Leader>oi` → `<Leader>op` | GitHub/Octo (moved to 'o' prefix) |

#### New Logical Groups

**AI/Claude (`<Leader>a`)**
- All Claude Code commands consolidated here
- Consistent naming: accept/reject changes

**Buffers (`<Leader>b`)**
- `b1-b9`: Direct buffer access
- `bb`: List buffers
- `bd/bD`: Delete buffer/all
- `bs/bS`: Save buffer/all

**Code/LSP (`<Leader>c`)**
- All LSP operations
- Code actions, definitions, references
- Formatting and refactoring

**Find/Files (`<Leader>f`)**
- All Telescope file operations
- Find files, grep, symbols
- Help and command search

**Git/GitHub (`<Leader>g`)**
- Git operations (status, diff, commits)
- Gitsigns integration

**Jupyter/Molten (`<Leader>j`)**
- All Jupyter notebook operations
- Clear separation from messages

**Messages (`<Leader>m`)**
- Error and message management
- Copy operations

**Octo/GitHub (`<Leader>o`)**
- GitHub issues and PRs
- Review operations

**Replace/Refactor (`<Leader>r`)**
- Spectre and native replace
- Refactoring operations

**Search (`<Leader>s`)**
- Project and buffer search
- Search history

**Test (`<Leader>t`)**
- Test execution
- Debug operations

**UI/Toggles (`<Leader>u`)**
- All UI toggles (zen mode, numbers, etc.)
- Terminal toggle

**VSCode Features (`<Leader>v`)**
- Multicursor
- Clipboard history
- Smart selection

**Diagnostics (`<Leader>x`)**
- Error navigation
- Diagnostic lists

### 3. Quick Access Patterns

- **Number keys**: `<Leader>1-9` for direct buffer access
- **Alt keys**: `<Alt>1-8` for window focus
- **Bracket navigation**: `[` and `]` for previous/next operations
- **Quick saves**: `<Leader>w` to close, `<Leader>W` to close all
- **Comments**: `<Leader>/` to toggle comments

## Learning the New System

1. **Start with which-key**: Press `<Leader>` and explore visually
2. **Use categories**: Think in terms of what you want to do (buffer, search, git, etc.)
3. **Consistent patterns**: 
   - Lowercase = common operation
   - Uppercase = stronger version (e.g., `w` close one, `W` close all)
   - Double letter = list/menu (e.g., `bb` list buffers, `ff` find files)

## Customization

To add your own keybindings while maintaining organization:

```lua
-- In your user configuration
return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    opts.mappings.n["<Leader>yc"] = { "<cmd>YourCommand<cr>", desc = "Your custom command" }
    
    -- Register with which-key
    require("which-key").register({
      ["<leader>y"] = { name = "Your Category", _ = "which_key_ignore" },
    })
    
    return opts
  end,
}
```

## Quick Reference Card

```
┌─ Quick Actions ─┐  ┌─ Navigation ──┐  ┌─ Search/Find ─┐
│ ,w  Close buff  │  │ ,1-9 Buffer N │  │ ,ff Find file │
│ ,W  Close all   │  │ [b   Prev buf │  │ ,fg Live grep │
│ ,q  Quit        │  │ ]b   Next buf │  │ ,ss Search buf│
│ ,/  Comment     │  │ [d   Prev diag│  │ ,sw Search wrd│
└─────────────────┘  └───────────────┘  └───────────────┘

┌─ AI/Claude ─────┐  ┌─ Git/GitHub ──┐  ┌─ Code/LSP ────┐
│ ,ac Resume chat │  │ ,gs Git status│  │ ,ca Code actn │
│ ,aa Accept diff │  │ ,gd Git diff  │  │ ,cd Definition│
│ ,ad Reject diff │  │ ,op PR list   │  │ ,cr References│
│ ,ao Open files  │  │ ,oi Issue list│  │ ,cf Format    │
└─────────────────┘  └───────────────┘  └───────────────┘
```

## Troubleshooting

If a keybinding doesn't work:
1. Check if which-key shows it when you press `<Leader>`
2. Run `:map <Leader>xy` to see if it's mapped
3. Check for conflicts with `:verbose map <Leader>xy`
4. Ensure required plugins are installed
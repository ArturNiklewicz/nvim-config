# LSP Guide for Neovim

Complete guide for understanding, configuring, and using Language Server Protocol (LSP) in this Neovim setup.

---

## Quick Reference

| LSP Server | Language | Purpose |
|------------|----------|---------|
| `lua_ls` | Lua | Completions, diagnostics, hints |
| `basedpyright` | Python | Type checking, diagnostics, completions |
| `pylsp` | Python | Refactoring via rope (rename/move) |
| `vtsls` | TypeScript/JS | Full IDE features, inlay hints |
| `tailwindcss` | CSS | Tailwind class completions |
| `clangd` | C/C++ | Full IDE features |
| `eslint` | JS/TS | Linting integration |

---

## Part 1: Understanding LSP

### What is LSP?

Language Server Protocol (LSP) is a standardized protocol between editors and language servers. Instead of each editor implementing language features for every language, LSP provides:

```
┌─────────────┐         ┌─────────────────┐
│   Neovim    │ ◄─────► │  Language Server │
│  (Client)   │   LSP   │  (e.g., pylsp)   │
└─────────────┘         └─────────────────┘
```

### LSP Capabilities

| Capability | Description | Keybinding |
|------------|-------------|------------|
| `completion` | Code suggestions | Auto / `<C-Space>` |
| `hover` | Documentation popup | `<Leader>ch` or `K` |
| `definition` | Go to definition | `<Leader>cd` or `gd` |
| `references` | Find all usages | `<Leader>cr` or `gr` |
| `rename` | Rename symbol project-wide | `<Leader>cR` |
| `codeAction` | Quick fixes, refactors | `<Leader>ca` |
| `formatting` | Auto-format code | `<Leader>cf` |
| `diagnostics` | Errors, warnings | `]d` / `[d` to navigate |
| `inlayHints` | Inline type hints | Toggle with config |
| `codeLens` | Inline actions | Enabled by default |

### Multiple LSPs Per Buffer

You can run multiple LSP servers on the same file:

```
Python file (.py)
├── basedpyright  → Type checking, completions, diagnostics
└── pylsp         → Refactoring (rename with import updates)
```

**Why?** Different servers excel at different tasks:
- `basedpyright`: Fast, accurate type checking
- `pylsp + rope`: Project-wide refactoring with import updates

---

## Part 2: Current Configuration

### Config Location

```
~/.config/nvim/lua/plugins/astrolsp.lua
```

### Features Enabled

```lua
features = {
  codelens = true,        -- Inline actions (run test, etc.)
  inlay_hints = false,    -- Type hints inline (disabled by default)
  semantic_tokens = true, -- Enhanced syntax highlighting
}
```

### Installed Servers

Managed via Mason (`:Mason`):

| Server | Config Location |
|--------|-----------------|
| `lua_ls` | `astrocommunity.pack.lua` |
| `basedpyright` | `astrolsp.lua` + `astrocommunity.pack.python` |
| `pylsp` | `astrolsp.lua` (for rope refactoring) |
| `vtsls` | `astrocommunity.pack.typescript` |
| `tailwindcss` | `astrocommunity.pack.tailwindcss` |
| `clangd` | `astrolsp.lua` |
| `eslint` | `astrolsp.lua` |

---

## Part 3: LSP Keybindings

### Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `gd` | Definition | Jump to where symbol is defined |
| `gD` | Declaration | Jump to declaration |
| `gr` | References | List all usages |
| `gi` | Implementation | Go to implementation |
| `gt` | Type Definition | Jump to type |
| `K` | Hover | Show documentation |
| `<C-k>` | Signature Help | Show function signature (insert mode) |

### Code Actions

| Key | Action | Description |
|-----|--------|-------------|
| `<Leader>ca` | Code Action | Quick fixes, refactors |
| `<Leader>cR` | Rename | Rename symbol project-wide |
| `<Leader>cf` | Format | Format current buffer |
| `<Leader>cr` | References | Find all references |
| `<Leader>cd` | Definition | Go to definition |
| `<Leader>ch` | Hover | Show documentation |
| `<Leader>cs` | Signature | Show signature help |

### Diagnostics

| Key | Action | Description |
|-----|--------|-------------|
| `]d` | Next Diagnostic | Jump to next error/warning |
| `[d` | Prev Diagnostic | Jump to previous error/warning |
| `<Leader>ld` | Line Diagnostics | Show diagnostics for current line |
| `<Leader>lD` | All Diagnostics | Show all diagnostics (Telescope) |

---

## Part 4: Configuring LSP Servers

### Adding a New Server

1. **Install via Mason**:
   ```vim
   :Mason
   " Search for server, press 'i' to install
   ```

2. **Add to config** (`astrolsp.lua`):
   ```lua
   servers = {
     "your_server_name",
   },
   config = {
     your_server_name = {
       settings = {
         -- server-specific settings
       },
     },
   },
   ```

3. **Restart Neovim** or `:LspRestart`

### Server-Specific Configuration

#### Python (basedpyright + pylsp)

```lua
-- Type checking (basedpyright)
basedpyright = {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "standard", -- "off", "basic", "standard", "strict"
        autoImportCompletions = true,
        diagnosticMode = "workspace",
      },
    },
  },
},

-- Refactoring (pylsp with rope)
pylsp = {
  settings = {
    pylsp = {
      plugins = {
        -- Disable overlapping features
        pycodestyle = { enabled = false },
        pyflakes = { enabled = false },
        -- Enable rope
        rope = { enabled = true },
        rope_rename = { enabled = true },
      },
    },
  },
},
```

#### TypeScript/JavaScript (vtsls)

Configured via `astrocommunity.pack.typescript`:

```lua
vtsls = {
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = "all" },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
      },
    },
  },
},
```

#### Lua (lua_ls)

Configured via `astrocommunity.pack.lua`:

```lua
lua_ls = {
  settings = {
    Lua = {
      hint = {
        enable = true,
        arrayIndex = "Disable",
      },
    },
  },
},
```

---

## Part 5: Inlay Hints

### What Are Inlay Hints?

Virtual text showing types, parameter names, etc:

```typescript
// Without hints:
const result = calculate(5, 10)

// With hints:
const result: number = calculate(a: 5, b: 10)
//           ^^^^^^^^            ^^    ^^
//           return type         parameter names
```

### Toggle Inlay Hints

**Global toggle** (add to your config):
```lua
["<Leader>uH"] = {
  function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
  desc = "Toggle inlay hints",
}
```

**Enable by default** (`astrolsp.lua`):
```lua
features = {
  inlay_hints = true,  -- Change from false to true
}
```

### Per-Language Hints

| Language | Hint Types Available |
|----------|---------------------|
| TypeScript | Parameter names, types, return types |
| Lua | Variable types, array indices |
| Python | (Limited - basedpyright supports some) |
| Rust | Full support |

---

## Part 6: Formatting

### Format on Save

Enabled by default in `astrolsp.lua`:

```lua
formatting = {
  format_on_save = {
    enabled = true,
  },
  timeout_ms = 1000,
},
```

### Disable for Specific Languages

```lua
format_on_save = {
  ignore_filetypes = {
    "python",  -- Don't format Python on save
  },
},
```

### Manual Format

| Key | Action |
|-----|--------|
| `<Leader>cf` | Format buffer |
| `<Leader>lf` | Format buffer (alternative) |

### Formatters Used

| Language | Formatter | Source |
|----------|-----------|--------|
| Lua | StyLua | none-ls |
| Python | Ruff/Black | none-ls |
| TypeScript | Prettier | vtsls/none-ls |
| JSON | Prettier | none-ls |

---

## Part 7: Diagnostics

### Understanding Diagnostic Levels

| Level | Icon | Description |
|-------|------|-------------|
| Error | ✗ | Code won't work |
| Warning | ⚠ | Potential issues |
| Info | ℹ | Suggestions |
| Hint | 💡 | Style recommendations |

### Navigating Diagnostics

```
]d          Next diagnostic (any severity)
[d          Previous diagnostic
]e          Next error only
[e          Previous error only
```

### Viewing Diagnostics

```
<Leader>ld  Show line diagnostics (floating window)
<Leader>lD  All diagnostics (Telescope)
:Trouble    Diagnostics panel (if installed)
```

### Diagnostic Configuration

In `astrolsp.lua` or `astrocore.lua`:

```lua
vim.diagnostic.config({
  virtual_text = true,      -- Show inline
  signs = true,             -- Show in sign column
  underline = true,         -- Underline problems
  update_in_insert = false, -- Don't update while typing
  severity_sort = true,     -- Sort by severity
})
```

---

## Part 8: Project-Wide Operations

### Rename Symbol

`<Leader>cR` renames across all files:

| Language | LSP Used | Imports Updated? |
|----------|----------|------------------|
| Python | pylsp (rope) | ✅ Yes |
| TypeScript | vtsls | ✅ Yes |
| Lua | lua_ls | ⚠️ Partial |

After rename: `<Leader>W` to save all files.

### Find References

`<Leader>cr` or `gr` shows all usages:

```
┌─────────────────────────────────────────────────┐
│ References to 'MyClass'                         │
├─────────────────────────────────────────────────┤
│ src/models.py:15 - class MyClass:               │
│ src/views.py:8   - from models import MyClass   │
│ src/tests.py:3   - from models import MyClass   │
│ src/utils.py:42  - instance = MyClass()         │
└─────────────────────────────────────────────────┘
```

### File Operations with Import Updates

When renaming/moving files in **neo-tree** or **oil**:

| Language | Auto-updates imports? |
|----------|----------------------|
| TypeScript/JS | ✅ Yes (via vtsls + lsp-file-operations) |
| Python | ❌ No (basedpyright doesn't support) |

For Python file moves, use:
- Manual import fixes
- `ruff check --fix` for cleanup

---

## Part 9: Troubleshooting

### Check LSP Status

```vim
:LspInfo              " Show attached servers
:LspLog               " View LSP logs
:checkhealth lsp      " Health check
```

### Common Issues

#### LSP Not Attaching

1. Check if server is installed: `:Mason`
2. Check filetype: `:set ft?`
3. Check root directory: `:lua print(vim.lsp.buf.list_workspace_folders()[1])`

#### Slow Completions

```lua
-- Increase debounce time
vim.opt.updatetime = 300
```

#### Duplicate Diagnostics

Multiple LSPs reporting same errors? Disable in one:

```lua
pylsp = {
  settings = {
    pylsp = {
      plugins = {
        pyflakes = { enabled = false },  -- Let basedpyright handle
      },
    },
  },
},
```

#### Format Not Working

1. Check formatter: `:LspInfo`
2. Check none-ls: `:NullLsInfo`
3. Manual format: `:lua vim.lsp.buf.format()`

### Restart LSP

```vim
:LspRestart           " Restart all LSPs for buffer
:LspStop              " Stop all LSPs
:LspStart             " Start LSPs
```

---

## Part 10: Advanced Configuration

### Disable LSP for Specific Files

```lua
-- In on_attach or autocmd
if vim.fn.expand("%:t") == "huge_file.py" then
  vim.lsp.stop_client(client.id)
end
```

### Custom Handlers

```lua
-- Override hover to use custom window
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  { border = "rounded" }
)
```

### Workspace Folders

```vim
:lua vim.lsp.buf.add_workspace_folder("/path/to/folder")
:lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
```

### LSP Logging

```lua
vim.lsp.set_log_level("debug")
-- Then check :LspLog
```

---

## Quick Cheatsheet

```
┌──────────────────────────────────────────────────────────────┐
│  LSP NAVIGATION                                              │
├──────────────────────────────────────────────────────────────┤
│  gd / <Leader>cd     Go to definition                        │
│  gD / <Leader>cD     Go to declaration                       │
│  gr / <Leader>cr     Find all references                     │
│  gi / <Leader>ci     Go to implementation                    │
│  K / <Leader>ch      Hover documentation                     │
├──────────────────────────────────────────────────────────────┤
│  LSP ACTIONS                                                 │
├──────────────────────────────────────────────────────────────┤
│  <Leader>ca          Code actions (quick fixes)              │
│  <Leader>cR          Rename symbol (project-wide)            │
│  <Leader>cf          Format buffer                           │
│  <Leader>cs          Signature help                          │
├──────────────────────────────────────────────────────────────┤
│  DIAGNOSTICS                                                 │
├──────────────────────────────────────────────────────────────┤
│  ]d / [d             Next/prev diagnostic                    │
│  <Leader>ld          Line diagnostics                        │
│  <Leader>lD          All diagnostics (Telescope)             │
├──────────────────────────────────────────────────────────────┤
│  MANAGEMENT                                                  │
├──────────────────────────────────────────────────────────────┤
│  :LspInfo            Show attached LSP servers               │
│  :LspRestart         Restart LSP servers                     │
│  :Mason              Manage LSP installations                │
│  :checkhealth lsp    LSP health check                        │
├──────────────────────────────────────────────────────────────┤
│  WORKFLOW                                                    │
├──────────────────────────────────────────────────────────────┤
│  1. Navigate:  gd to jump to definition                      │
│  2. Explore:   gr to find all usages                         │
│  3. Refactor:  <Leader>cR to rename project-wide             │
│  4. Save:      <Leader>W to save all changed files           │
└──────────────────────────────────────────────────────────────┘
```

---

## Resources

- [Neovim LSP Documentation](https://neovim.io/doc/user/lsp.html)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [AstroLSP](https://github.com/AstroNvim/astrolsp)
- [Mason](https://github.com/williamboman/mason.nvim)
- [LSP Server Configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)

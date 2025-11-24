# OpenCode Setup Guide

OpenCode is an AI coding agent built for terminal-based workflows. This guide covers installation and Neovim integration.

## What is OpenCode?

- 100% open source AI coding agent for the terminal
- Created by the SST team
- Not coupled to any specific provider (works with Anthropic, OpenAI, Google, or local models)
- Terminal-based workflow with Neovim integration

## Installation

### Install OpenCode CLI

```bash
# Default installation (installs to ~/.local/bin)
curl -fsSL https://opencode.ai/install | bash

# Custom installation directory
OPENCODE_INSTALL_DIR=/usr/local/bin curl -fsSL https://opencode.ai/install | bash

# Or specify XDG_BIN_DIR
XDG_BIN_DIR=$HOME/.local/bin curl -fsSL https://opencode.ai/install | bash
```

### Verify Installation

```bash
# Check opencode is installed
which opencode

# Run opencode
opencode --help
```

## Neovim Integration

The `opencode.nvim` plugin (by NickvanDyke) is already configured in your setup.

### Plugin Configuration

Located at: `lua/plugins/opencode.lua`

**Key Features:**
- Auto-connects to opencode instances in the current working directory
- Embedded opencode terminal toggle
- Server-Sent-Events (SSE) integration for real-time updates
- Requires `folke/snacks.nvim` dependency (already installed)

### Keybindings

All keybindings use `<Leader>o` prefix:

| Key | Mode | Description |
|-----|------|-------------|
| `<Leader>oa` | Normal, Visual | Ask about current context |
| `<Leader>os` | Normal, Visual | Select from prompt library |
| `<Leader>o+` | Normal, Visual | Add current context to prompt |
| `<Leader>ot` | Normal | Toggle embedded opencode terminal |

### Usage Workflow

1. **Start opencode in your project:**
   ```bash
   cd your-project
   opencode
   ```

2. **Open Neovim in the same directory:**
   ```bash
   nvim
   ```

3. **The plugin will auto-connect** to the running opencode instance

4. **Use keybindings** to interact with opencode:
   - `<Leader>oa` - Ask opencode about the current file or selection
   - `<Leader>ot` - Toggle embedded opencode terminal
   - `<Leader>os` - Browse and select from saved prompts

### Health Check

After installation, verify setup with:
```vim
:checkhealth opencode
```

## Configuration Options

The plugin uses sensible defaults. Custom configuration can be added to `vim.g.opencode_opts` in the plugin file.

See full options in: `lua/opencode/config.lua` (from the plugin source)

## Alternative Plugins

If this plugin doesn't fit your workflow, consider:

- `sudo-tee/opencode.nvim` - Full Neovim frontend (requires opencode v0.6.3+)
- `kksimons/nvim-opencode` - Alternative integration approach
- `cousine/opencode-context.nvim` - Tmux pane integration

## Troubleshooting

### Plugin doesn't connect to opencode

1. Ensure opencode is running in the same directory as Neovim
2. Check `:checkhealth opencode` for issues
3. Verify `vim.o.autoread = true` is set (handled by plugin)

### Snacks.nvim errors

The plugin requires `folke/snacks.nvim` with `input` and `picker` modules:
```lua
{ "folke/snacks.nvim", opts = { input = {}, picker = {} } }
```

This is already configured in the plugin file.

## Resources

- OpenCode GitHub: https://github.com/sst/opencode
- Plugin GitHub: https://github.com/NickvanDyke/opencode.nvim
- OpenCode Website: https://opencode.ai

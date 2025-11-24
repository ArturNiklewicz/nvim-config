# OpenCode Troubleshooting Guide

## Error: "Couldn't find any opencode processes"

### Root Cause
This error occurs when the `opencode.nvim` plugin cannot find a running opencode process to connect to.

### Diagnosis Results
**Current Status:**
- ✅ Plugin installed: `lua/plugins/opencode.lua`
- ❌ OpenCode CLI not installed
- ❌ No opencode process running

### Solution: Install OpenCode CLI

The opencode.nvim plugin is a **client** that connects to the opencode **application**. You need both installed.

## Installation Steps

### 1. Install OpenCode Application

```bash
# Install opencode CLI (chooses ~/.local/bin by default)
curl -fsSL https://opencode.ai/install | bash

# Or install to /usr/local/bin
OPENCODE_INSTALL_DIR=/usr/local/bin curl -fsSL https://opencode.ai/install | bash
```

### 2. Verify Installation

```bash
# Check installation
which opencode
opencode --version

# If not found, check PATH
echo $PATH | tr ':' '\n' | grep -E '\.local/bin|/usr/local/bin'
```

### 3. Add to PATH (if needed)

If opencode installed to `~/.local/bin` but not in PATH:

```bash
# For bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# For zsh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# For fish
fish_add_path ~/.local/bin
```

## Correct Usage Workflow

### Option 1: External OpenCode (Recommended)

**Terminal 1:**
```bash
cd ~/your-project
opencode
```

**Terminal 2:**
```bash
cd ~/your-project
nvim
```

Now in Neovim:
- `<Leader>oa` - Ask about code (auto-connects to running opencode)
- Plugin finds the opencode process in same CWD

### Option 2: Embedded Terminal

1. Open Neovim in your project
2. Press `<Leader>ot` - Opens embedded opencode terminal
3. OpenCode runs inside Neovim (requires opencode CLI installed)

## Key Concepts

### How the Plugin Works

1. **Auto-discovery**: Plugin searches for opencode processes in current working directory
2. **SSE Connection**: Connects via Server-Sent-Events to communicate
3. **Requires Both**: Needs both plugin (Neovim) AND CLI (opencode app)

### Why You Got This Error

```
Couldn't find any opencode processes
```

**Meaning**: Plugin looked for running opencode but found none.

**Cause**: OpenCode CLI not installed OR no opencode process running in CWD.

## Verification Checklist

After installation, verify:

```bash
# 1. CLI installed
which opencode
# Expected: /home/user/.local/bin/opencode (or /usr/local/bin/opencode)

# 2. Start opencode
cd ~/test-project
opencode
# Should start opencode TUI

# 3. Open Neovim in same directory (new terminal)
cd ~/test-project
nvim

# 4. Check health in Neovim
:checkhealth opencode
# Should show opencode is running and connected
```

## Common Issues

### Issue: "opencode: command not found"

**Solution**: CLI not installed or not in PATH
- Install with: `curl -fsSL https://opencode.ai/install | bash`
- Add to PATH (see step 3 above)

### Issue: Plugin connects but no response

**Solution**: Version mismatch
- Update plugin: `:Lazy sync`
- Update CLI: Re-run install script

### Issue: "No snacks.nvim input module"

**Solution**: Dependency missing
- The plugin config already includes this: `{ "folke/snacks.nvim", opts = { input = {}, picker = {} } }`
- Run: `:Lazy sync` to install

## Alternative Plugins

If this workflow doesn't fit your needs:

1. **sudo-tee/opencode.nvim** - Full Neovim frontend (different approach)
2. **cousine/opencode-context.nvim** - Tmux pane integration
3. **kksimons/nvim-opencode** - Alternative client

## Resources

- OpenCode Website: https://opencode.ai
- OpenCode GitHub: https://github.com/sst/opencode
- Plugin GitHub: https://github.com/NickvanDyke/opencode.nvim
- Setup Guide: `docs/opencode-setup.md`

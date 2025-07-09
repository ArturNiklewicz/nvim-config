# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal AstroNvim v5+ configuration repository. AstroNvim is a Neovim configuration framework that provides a structured way to configure plugins, keybindings, and settings.

## Architecture

### Core Structure
- **`init.lua`** - Bootstrap file that sets up Lazy.nvim package manager
- **`lua/lazy_setup.lua`** - Main Lazy.nvim configuration with plugin imports
- **`lua/polish.lua`** - Final configuration step for custom Lua code (currently disabled)
- **`lua/community.lua`** - AstroCommunity plugin imports (currently disabled)
- **`lua/plugins/`** - Individual plugin configurations

### Key Configuration Files
- **`lua/plugins/astrocore.lua`** - Core AstroNvim settings, keybindings, and vim options
- **`lua/plugins/astroui.lua`** - UI configuration and theming (currently disabled)
- **`lua/plugins/astrolsp.lua`** - LSP configuration
- **`lua/plugins/mason.lua`** - Package manager for LSP servers, formatters, linters
- **`lua/plugins/treesitter.lua`** - Syntax highlighting and parsing
- **`lua/plugins/none-ls.lua`** - Formatting and linting integration

### Custom Plugins
- **`lua/plugins/zen-mode.lua`** - Distraction-free editing mode
- **`lua/plugins/bufferline.lua`** - Enhanced buffer/tab navigation
- **`lua/plugins/molten.lua`** - Jupyter notebook integration
- **`lua/plugins/claude-code.lua`** - Claude Code AI assistant integration
- **`lua/plugins/user.lua`** - Custom user-specific plugins

## Configuration Management

### Activation Pattern
Many configuration files use the pattern `if true then return {} end` at the top to disable them by default. Remove this line to activate the configuration.

### Leader Key
- Leader key: `<Space>`
- Local leader key: `,`

### Custom Keybindings
The configuration includes VSCode-inspired keybindings:
- `<Leader>1-9` - Switch to buffer 1-9
- `<Alt>1-8` - Focus window/split 1-8
- `<Ctrl+Alt>T` - Toggle terminal
- `<Ctrl+Alt>Tab1-4` - Focus specific terminal instances

### Claude Code Integration
- `<Leader>ac` - Toggle Claude Code terminal
- `<Leader>as` - Send selected text to Claude Code (visual mode)
- `<Leader>ad` - Accept Claude Code changes
- `<Leader>ar` - Reject Claude Code changes

## Development Notes

### Language Support
Community packs are configured for:
- Lua (lua_ls)
- TypeScript/JavaScript (with Next.js support)
- Tailwind CSS
- Python (with Ruff/Black formatting)

### Linting
Uses Selene for Lua linting with relaxed rules configured in `selene.toml`.

### Plugin Management
Uses Lazy.nvim with:
- Version pinning for AstroNvim (^5)
- Community plugin imports
- Custom plugin configurations in `lua/plugins/`

### Buffer Navigation
Custom buffer switching functions validate buffer existence before switching to prevent "Invalid buffer id" errors.

## Installation Requirements

Requires backing up existing Neovim configuration directories:
- `~/.config/nvim`
- `~/.local/share/nvim`
- `~/.local/state/nvim`
- `~/.cache/nvim`

## Important Notes

- This configuration is personalized for macOS (uses `<D->` for Cmd key mappings)
- Terminal-specific configurations may need adjustment for different terminal emulators
- Custom keybindings override some default AstroNvim mappings

## Claude Code Setup

### Prerequisites
1. Install Claude Code CLI: `npm install -g @anthropic-ai/claude-code`
2. Ensure `folke/snacks.nvim` is available (already configured in user.lua)

### Usage
1. Navigate to your project directory
2. Run `claude` in terminal to start Claude Code
3. Use `<Leader>ac` in Neovim to toggle Claude Code terminal
4. Select text and use `<Leader>as` to send to Claude Code
5. Use `<Leader>ad` to accept or `<Leader>ar` to reject changes

### Plugin Details
- Uses `coder/claudecode.nvim` - reverse-engineered from official VS Code extension
- Implements WebSocket-based Model Context Protocol (MCP)
- Provides real-time context and file interaction with Claude Code
- Pure Lua implementation with zero external dependencies
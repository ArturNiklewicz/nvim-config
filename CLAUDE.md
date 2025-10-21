# CLAUDE.md

This file provides guidance to Claude Code when working with this AstroNvim v5+ configuration.

## Repository Overview

Personal AstroNvim v5+ configuration with enhanced productivity features and IDE-like capabilities.

## Architecture

### Core Structure
- `init.lua` - Bootstrap Lazy.nvim
- `lua/lazy_setup.lua` - Plugin imports
- `lua/plugins/` - Individual plugin configs

### Key Files
- `astrocore.lua` - Core settings, keybindings, vim options
- `astroui.lua` - UI configuration
- `astrolsp.lua` - LSP configuration
- `mason.lua` - LSP/formatter/linter management
- `treesitter.lua` - Syntax highlighting
- `none-ls.lua` - Formatting and linting

### Custom Plugins
- `zen-mode.lua` - Distraction-free editing
- `bufferline.lua` - Buffer navigation
- `molten.lua` - Jupyter notebook integration
- `claudecode.lua` - Claude Code AI integration
- `error-messages.lua` - Error handling
- `markdown-preview.lua` - Terminal markdown preview
- `telescope.lua` - Fixed multi-select behavior (Tab to toggle)
- `vscode-editing.lua` - VSCode-like features
- `text-objects.lua` - Enhanced text objects
- `user.lua` - User overrides

## Keybindings

Leader: `<Space>` | Local Leader: `,`

### Keybindings Help
- `<Leader>?` - Show all keybindings help
- `:Keybindings` or `:Keys` - Show keybindings in Neovim
- `~/.config/nvim/nvim-keys` - Terminal script to show all keybindings

### Core Navigation
- `<Leader>1-9` - Switch to buffer 1-9
- `<Leader>a/d` - Previous/next buffer
- `<Leader>w` - Close buffer
- `<Alt>1-8` - Focus window 1-8
- `<Ctrl+I/O>` - Navigate back/forward
- `]d/[d` - Next/previous diagnostic/diff

### Telescope Multi-Select
- `<Tab>` - Toggle selection and move down
- `<S-Tab>` - Toggle selection and move up
- `<C-q>` - Send to quickfix list
- `<M-q>` - Send selected to quickfix list
- Note: Tab now properly toggles selection instead of opening files

### Claude Code (`<Leader>a`)
- `ac` - Toggle terminal (with resume)
- `aC` - Fresh chat (no resume)
- `aa/ad` - Accept/deny diff changes
- `ao` - Open all edited files
- `as` - Send selection (visual)
- `ab` - Add buffer to context

### Molten/Jupyter (`<Leader>m`)
- `mi` - Initialize
- `ml/mv` - Evaluate line/selection
- `mo/mh` - Show/hide output
- `ms/mS/mR` - Start/stop/restart kernel

### VSCode Features (`<Leader>v`)
- `sr` - Find and replace
- `sw/sp` - Search word/file
- `vy/vp` - Clipboard history/paste
- `vd/vn` - Create multicursor
- `vv` - Smart selection (treesitter)
- `vi/vs/vd` - Incremental selection expand/scope/shrink

### Multicursor (`<Leader>c`)
- `cd` - Create multicursor (like VSCode Ctrl+D)
- `cn` - Create multicursor for pattern
- `cc` - Clear all multicursors
- `ca` - Add cursor at visual selection
- `cw` - Add cursor under word

### Git (`<Leader>g`)
- `gN` - Neogit status (staging UI)
- `gM` - Make commit with Neogit
- `gA` - AI quick commit (bash + Claude CLI, interactive mode)
- `gp` - Git commit timeline (preview recent commits)
- `gP` - Preview commits then commit with AI
- `gs` - Git status (Telescope)
- `gb` - Git branches
- `gc` - Git commits (view history)
- `gC` - Buffer commits
- `gd/gD` - Git diff view (open/close)
- `gh/gH` - File/branch history
- `gj/gk` - **Enhanced**: Navigate next/previous changed file (seamless navigation)
- `gf` - List all changed files
- `gt` - Toggle git signs
- `gn` - Toggle line number highlighting
- `gl` - Toggle line highlighting
- `gw` - Toggle word diff
- `gT` - Toggle blame line
- `gr` - Refresh git signs

#### Git File Navigation Enhancements
- `gj/gk` now works seamlessly with proper file path matching
- Automatically jumps to first change in file using GitSigns
- Saves cursor position before navigation
- Shows file status and progress (staged/modified/untracked)
- Handles file path edge cases and escaping

#### Git Watchlist (`<Leader>gw`)
- `gwa` - Add current file to watchlist
- `gwr` - Remove current file from watchlist
- `gwl` - Show watchlist with status
- `gwj/gwk` - Navigate watchlist files
- `gwm` - Check for changes manually
- `gws` - Start auto-monitoring

#### AI Commit Message Generation
**Auto-triggers on**:
- `gM` (Neogit commit) - Opens commit buffer with AI-generated message
- `gN` → `c` (commit from Neogit) - Auto-generates message in commit buffer

**Manual regeneration** (in commit buffer):
- `<Leader>ag` - Regenerate commit message

**Architecture**:
- Bash handles: git stats, file detection, commit type/scope, conventional commits
- Claude CLI handles: commit body (WHY, context, reasoning)
- Performance: ~500ms (vs 2-3s Lua orchestration)
- See: `docs/git-commit-ai.md` for details

### GitHub (`<Leader>G`)
- `Gi/GI` - List/create GitHub issues
- `Gp/GP` - List/create GitHub PRs
- `Gr` - List GitHub repos
- `Gs` - Search GitHub
- `Ga/Gl/Gc` - Add assignee/label/comment
- `GR` - Start GitHub review
- `Gd/Go/Gm` - PR diff/checkout/merge
- `Gv/Gw` - View PR/repo in browser

### File Copy (`<Leader>y`)
- `yf` - Copy filename to clipboard
- `yp` - Copy relative file path to clipboard
- `yP` - Copy full file path to clipboard

### Terminal
- `<Ctrl+Alt>T` - Toggle terminal
- `<Ctrl+Alt>Tab1-4` - Focus terminal 1-4

## Language Support
- Lua (lua_ls, Selene)
- TypeScript/JavaScript
- Python (Ruff/Black)
- Tailwind CSS

## Claude Code Integration

### Setup
1. Install: `npm install -g @anthropic-ai/claude-code`
2. Plugin auto-configured in `claudecode.lua`

### Features
- Auto-resume previous sessions
- Side-by-side diff view
- Auto-open edited files
- WebSocket MCP protocol (ports 41041-41099)

### Memory
- Project: `./CLAUDE.md` (this file)
- User: `~/.claude/CLAUDE.md`
- Session: `claude --resume`
- Quick: Start with `#` to add to memory

## Development Notes
- macOS optimized (Cmd key mappings)
- Uses Lazy.nvim package manager
- Custom buffer validation
- Requires backing up Neovim dirs before install

## Important Instructions
- Prefer editing existing files over creating new ones
- Never create documentation unless explicitly requested
- Follow existing code conventions and patterns
- Check for required libraries before using them
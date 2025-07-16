# GitHub Integration Guide

## Overview

This Neovim configuration includes minimal GitHub integration through:
- **Octo.nvim**: Native GitHub integration within Neovim
- **GitHub CLI**: Command-line interface for GitHub operations

## Quick Start

1. **Install GitHub CLI** (if not already installed):
   ```bash
   # macOS
   brew install gh
   
   # Linux
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
   sudo apt update
   sudo apt install gh
   ```

2. **Authenticate with GitHub**:
   ```bash
   gh auth login
   ```

3. **Install plugins** (in Neovim):
   ```vim
   :Lazy sync
   ```

## Keybindings Reference

All GitHub commands use the `<Leader>g` prefix.

### Core Commands

| Keybinding | Description | Command |
|------------|-------------|---------|
| `<Leader>gi` | List issues | `:Octo issue list` |
| `<Leader>gI` | Create issue | `:Octo issue create` |
| `<Leader>gp` | List pull requests | `:Octo pr list` |
| `<Leader>gP` | Create pull request | `:Octo pr create` |
| `<Leader>gr` | List repositories | `:Octo repo list` |
| `<Leader>gs` | Search GitHub | `:Octo search` |

### Pull Request Operations

| Keybinding | Description | Details |
|------------|-------------|---------|
| `<Leader>gv` | View PR in browser | Opens current PR in default browser |
| `<Leader>gc` | Show PR checks | Displays CI/CD status |
| `<Leader>gm` | Merge PR | Interactive merge (merge/squash/rebase) |
| `<Leader>gf` | Show PR diff | View changes in current PR |
| `<Leader>go` | Checkout PR | Switch to PR branch locally |

### Code Review

| Keybinding | Description | Details |
|------------|-------------|---------|
| `<Leader>gR` | Start review | Begin reviewing current PR |
| `<Leader>gC` | Add comment | Comment on issue/PR |
| `<Leader>ga` | Add assignee | Assign user to issue/PR |
| `<Leader>gl` | Add label | Apply labels |

### Quick Actions

| Keybinding | Description | Details |
|------------|-------------|---------|
| `<Leader>gb` | Create issue from line | Uses current line as issue title |
| `<Leader>g/` | Search repos | Quick repository search |

## Workflows

### Creating an Issue

```vim
" Method 1: From current line
" 1. Place cursor on a line with TODO or bug description
" 2. Press <Leader>gb
" 3. Edit title if needed and confirm

" Method 2: Full issue creation
" 1. Press <Leader>gI
" 2. Fill in issue template
" 3. Save and close buffer to create
```

### Pull Request Workflow

```vim
" 1. List PRs
<Leader>gp

" 2. Select and open a PR
" Navigate with j/k and press <Enter>

" 3. Review the PR
<Leader>gR  " Start review
<Leader>gf  " View diff
<Leader>gC  " Add comments

" 4. Check CI status
<Leader>gc

" 5. Merge when ready
<Leader>gm
" Select merge method: merge, squash, or rebase
```

### Quick PR Review

```vim
" 1. View PR in browser for overview
<Leader>gv

" 2. Checkout PR locally for testing
<Leader>go

" 3. Run tests, make changes if needed

" 4. Merge from Neovim
<Leader>gm
```

## Octo Buffer Commands

When inside an Octo buffer (issue/PR view), additional mappings are available:

### Issue/PR Navigation
- `]c` - Next comment
- `[c` - Previous comment
- `]t` - Next thread
- `[t` - Previous thread

### Issue/PR Actions
- `<localleader>ca` - Add comment
- `<localleader>cd` - Delete comment
- `<localleader>ic` - Close issue
- `<localleader>io` - Reopen issue

### PR Specific
- `<localleader>po` - Checkout PR
- `<localleader>pm` - Merge PR
- `<localleader>pc` - List commits
- `<localleader>pf` - List changed files
- `<localleader>pd` - Show diff

### Review Actions
- `<localleader>vs` - Submit review
- `<localleader>vr` - Resume review
- `<localleader>vd` - Discard review

## Command Reference

### Octo Commands

```vim
:Octo <tab>                 " Show all available commands
:Octo issue list            " List issues for current repo
:Octo issue create          " Create new issue
:Octo pr list               " List PRs for current repo
:Octo pr create             " Create new PR
:Octo pr diff               " Show PR diff
:Octo pr checkout           " Checkout PR branch
:Octo pr merge              " Merge PR
:Octo review start          " Start PR review
:Octo review submit         " Submit PR review
```

### Custom Commands

```vim
:OctoReview                 " Quick access to PR list
```

## Tips & Tricks

1. **Telescope Integration**: All Octo pickers use Telescope for fuzzy finding
   - Use `/` to search within results
   - `<C-x>` to open in split
   - `<C-v>` to open in vertical split

2. **GitHub CLI Integration**: Some commands use `gh` directly for faster operations
   - PR viewing in browser
   - Quick status checks
   - Repository searches

3. **Notifications**: Operations show notifications in Neovim
   - Success/failure messages
   - Progress indicators for long operations

4. **Authentication**: Ensure `gh auth status` shows you're logged in
   - Octo uses GitHub CLI's authentication
   - No separate token configuration needed

## Troubleshooting

### Issue: Commands not working
```bash
# Check GitHub CLI authentication
gh auth status

# Re-authenticate if needed
gh auth login
```

### Issue: Octo commands not found
```vim
" Ensure plugin is installed
:Lazy sync

" Check if Octo is loaded
:lua print(vim.inspect(package.loaded["octo"]))
```

### Issue: Can't find repository
```vim
" Ensure you're in a git repository
:!git remote -v

" Set upstream if needed
:!git remote add upstream https://github.com/owner/repo.git
```
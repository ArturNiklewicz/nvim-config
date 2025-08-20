# Git Workflow with AI-Powered Commit Messages

## Overview
This configuration provides a comprehensive git workflow with Neogit for staging, Telescope integration for navigation, and AI-powered commit message generation using Claude Code.

## Key Features

### 1. **Neogit Integration**
- Full Magit-inspired git interface
- Visual staging/unstaging of hunks and files
- Interactive commit editor with diff preview
- Telescope integration for branch/commit selection

### 2. **AI Commit Message Generation**
- Uses Claude Code to analyze staged changes
- Generates conventional commit messages
- Follows best practices (type, scope, description)
- Considers breaking changes and critical details

### 3. **Telescope Git Integration**
- Multi-select support for git files
- Quick navigation through commits, branches, status
- Enhanced with Tab key for proper selection

## Keybindings

### Git Operations (`<Leader>g`)
- `<Leader>gN` - Open Neogit status (main staging interface)
- `<Leader>gM` - Make commit with Neogit
- `<Leader>gA` - AI quick commit (stages all + AI message)
- `<Leader>gs` - Git status (Telescope)
- `<Leader>gb` - Git branches
- `<Leader>gc` - Git commits (view history)
- `<Leader>gC` - Buffer commits
- `<Leader>gd` - Open diff view
- `<Leader>gD` - Close diff view
- `<Leader>gn` - Toggle line number highlighting (GitSigns)
- `<Leader>gt` - Toggle git signs

### In Neogit Status Buffer
- `s` - Stage file/hunk
- `u` - Unstage file/hunk
- `S` - Stage all
- `U` - Unstage all
- `Tab` - Toggle fold
- `cc` - Commit
- `ca` - Amend
- `pp` - Push
- `pl` - Pull
- `?` - Help

### In Git Commit Buffer
- `<Leader>ai` - Generate AI commit message
- `<Leader>cf` - Insert "feat: " prefix
- `<Leader>cx` - Insert "fix: " prefix
- `<Leader>cd` - Insert "docs: " prefix
- `<Leader>cr` - Insert "refactor: " prefix
- `<Leader>cv` - Validate commit message format
- `<Leader>cb` - Add BREAKING CHANGE section
- `<C-g><C-a>` - Generate AI message (insert mode)

## Workflow Examples

### Standard Workflow
1. `<Leader>gN` - Open Neogit to see changes
2. Navigate to files, press `Tab` to expand
3. `s` to stage specific hunks or files
4. `cc` to open commit editor
5. `<Leader>ai` to generate AI commit message
6. Review and edit message
7. `<C-c><C-c>` to commit

### Quick AI Commit
1. Make your changes
2. `<Leader>gA` - Stages all and commits with AI message
3. Review the generated message in Claude Code
4. Copy and use in commit editor

### Alternative Commit Flow
1. `<Leader>gM` - Direct commit with Neogit
2. AI message generated automatically in commit buffer
3. Edit and confirm

### Selective Staging with Telescope
1. `<Leader>gs` - Open git status in Telescope
2. `Tab` to select multiple files
3. `Enter` to open all selected files
4. Use GitSigns to stage hunks: `<Leader>hs`

## AI Commit Message Features

### Prompt Engineering
The AI analyzes:
- Git diff of staged changes
- Conventional commit requirements
- Breaking changes detection
- Performance and security implications
- User-facing changes

### Message Format
```
type(scope): concise description

- Critical implementation detail
- User-facing change description
- Performance consideration

BREAKING CHANGE: description (if applicable)
```

### Supported Types
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Formatting
- `refactor` - Code refactoring
- `perf` - Performance
- `test` - Tests
- `chore` - Maintenance
- `build` - Build system
- `ci` - CI/CD

## Configuration Files

### Core Files
- `lua/plugins/neogit.lua` - Neogit configuration
- `lua/utils/ai-commit.lua` - AI commit generation logic
- `after/ftplugin/gitcommit.lua` - Git commit buffer setup
- `lua/plugins/astrocore.lua` - Keybinding definitions

### Dependencies
- Neogit - Main git interface
- Telescope - Fuzzy finding
- GitSigns - Hunk staging
- Diffview - Enhanced diffs
- Claude Code - AI assistance

## Tips

1. **Review AI Messages**: Always review AI-generated commit messages for accuracy
2. **Stage Related Changes**: Group related changes for better commit messages
3. **Use Conventional Commits**: Helps with changelog generation and semantic versioning
4. **Validate Before Commit**: Use `<Leader>cv` to check message format
5. **Leverage Hunks**: Stage specific parts of files for cleaner commits

## Troubleshooting

### AI Generation Not Working
- Ensure Claude Code is running: `<Leader>ac`
- Check if staged changes exist: `git diff --cached`
- Verify utils/ai-commit.lua is loaded

### Neogit Issues
- Run `:checkhealth neogit`
- Ensure git is installed: `which git`
- Check for conflicting keybindings

### Telescope Selection
- Use `Tab` to toggle selection (not Enter)
- `<C-q>` sends to quickfix list
- Multi-select now properly configured
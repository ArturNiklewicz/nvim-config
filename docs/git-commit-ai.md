# Git Commit AI Workflow

**Primeagen-approved**: Minimal, fast, bash-first with AI enhancement only where it adds value.

## Architecture

### Responsibility Split

| Task | Tool | Reason |
|------|------|--------|
| Get staged files | `git diff --cached --name-status` | Instant, accurate, built-in |
| Count changes | `git diff --cached --numstat` | Native git, no parsing |
| Detect commit type | bash patterns | Fast, deterministic |
| Generate subject | bash + git stats | Formulaic conventional commits |
| **Generate body** | **Claude CLI** | **AI for nuance: WHY, context, trade-offs** |
| Preview | fzf + git show | Interactive, visual |

## Performance

- **Bash parsing**: <10ms
- **Claude API call**: ~500ms (body only)
- **Total**: ~510ms

**Previous Lua orchestration**: 2-3s (multi-agent, diff parsing, message building)

## Workflow

### Manual Trigger
```bash
<Leader>gA → Preview changes → Generate subject (bash) → Generate body (Claude) → Preview → Commit/Edit/Abort
```

### Auto-Trigger (Neogit/Git Commit)
```bash
<Leader>gM (Neogit commit) → Opens commit buffer → Auto-generates message → Edit and commit
<Leader>gN → c (commit in Neogit) → Opens commit buffer → Auto-generates message → Edit and commit
```

**Auto-trigger behavior**:
- Detects when `gitcommit` or `NeogitCommitMessage` buffers open
- Checks if buffer is empty (no existing commit message)
- Calls bash script in non-interactive mode
- Inserts generated message into buffer
- You can edit before committing

### 1. Preview Staged Changes
```bash
# Shows files with git status indicators
git diff --cached --name-status
```

### 2. Generate Subject (Bash)
```bash
# Detects type: feat, fix, refactor
# Detects scope: plugins, utils, config, scripts, docs
# Output: "feat(plugins): update 3 files"
```

**Conventional commit types**:
- `feat`: New files > modifications (feature addition)
- `fix`: Modifications > deletions (bug fix)
- `refactor`: Has deletions (code cleanup)

### 3. Generate Body (Claude CLI)
```bash
# Prompt to Claude:
# - Be concise (2-4 bullet points)
# - Focus on WHY, not WHAT (diff shows what)
# - Use conventional commit style
# - No fluff
```

**Fallback** (if Claude unavailable):
```
Changes:
- Added X lines
- Removed Y lines

Modified files:
- file1.lua
- file2.sh
```

### 4. Preview Full Message
```
=== Commit Message Preview ===
feat(plugins): update git workflow

- Replaced Lua orchestration with bash-first approach
- AI generates only commit body for context
- Reduced commit generation time from 2-3s to ~500ms
==============================
```

### 5. Commit Options
- **c** - Commit with this message
- **e** - Edit message in `$EDITOR`
- **a** - Abort

## Script Location

`~/.config/nvim/scripts/git-commit-ai.sh`

## Keybindings

- `<Leader>gA` - Quick commit with AI (interactive mode)
- `<Leader>ag` - Regenerate commit message (when in commit buffer)

**Auto-triggers on**:
- `<Leader>gM` - Neogit commit
- `<Leader>gN` then `c` - Commit from Neogit status

## Environment Variables

- `SKIP_PREVIEW=1` - Skip change preview (for automated workflows)
- `NONINTERACTIVE=1` - Non-interactive mode (output to stdout, no prompts)
- `COMMIT_MSG_FILE` - Custom commit message file path (default: `/tmp/git-commit-msg-$$`)
- `EDITOR` - Editor for manual editing (default: `vim`)

**Internal use** (set by auto-trigger):
```bash
SKIP_PREVIEW=1 NONINTERACTIVE=1 git-commit-ai.sh
# Outputs commit message to stdout, no user interaction
```

## Dependencies

**Required**:
- `git`
- `bash`

**Optional** (falls back to basic generation):
- `claude` CLI (npm: `@anthropic-ai/claude-code`)

## Examples

### Basic Usage
```bash
# Make changes
echo "test" >> README.md

# Stage and commit with AI
<Leader>gA
```

### Skip Preview (Automated)
```bash
SKIP_PREVIEW=1 ~/.config/nvim/scripts/git-commit-ai.sh
```

### Custom Editor
```bash
EDITOR=nvim ~/.config/nvim/scripts/git-commit-ai.sh
```

## Design Principles (Primeagen-Style)

1. **Bash for structure** - Git operations, file stats, pattern matching
2. **AI for nuance** - Context, reasoning, trade-offs (commit body only)
3. **Fast by default** - No unnecessary abstractions
4. **Preview everything** - See changes before committing
5. **Fallback always** - Works without AI, gracefully degrades
6. **No magic** - Clear, readable bash scripts
7. **Single responsibility** - Each function does one thing well

## Comparison: Old vs New

### Old (Lua Orchestration)
```
lua/utils/ai-commit/init.lua           (323 lines)
lua/utils/ai-commit/diff-parser.lua    (150 lines)
lua/utils/ai-commit/commit-analyzer.lua (200 lines)
lua/utils/ai-commit/message-builder.lua (180 lines)
lua/utils/ai-commit/config.lua         (100 lines)
lua/utils/ai-commit/logger.lua         (80 lines)
----------------------------------------
TOTAL: ~1000+ lines of Lua
PERFORMANCE: 2-3 seconds
```

### New (Bash + Claude CLI)
```
scripts/git-commit-ai.sh               (~250 lines)
----------------------------------------
TOTAL: ~250 lines of bash
PERFORMANCE: ~500ms
```

**Reduction**: 75% less code, 5-6x faster

## Why This Works

1. **Git is the parser** - Native `git diff` is faster and more accurate than custom Lua parsing
2. **Conventional commits are formulaic** - Type detection doesn't need AI
3. **AI excels at context** - "Why did we make this change?" requires reasoning
4. **Preview prevents mistakes** - See the commit message before committing
5. **Bash is fast** - No Neovim/Lua startup overhead, direct system calls

## Future Enhancements

- [ ] Git hook integration for pre-commit message generation
- [ ] Custom scope detection rules (project-specific patterns)
- [ ] Commit message templates
- [ ] Integration with conventional commit linters (commitlint)
- [ ] Multi-language commit messages (i18n)

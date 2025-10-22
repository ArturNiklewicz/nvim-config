# Git Quick Workflows

Faster git operations with AI-generated commit messages.

## 🎯 Quick Reference

| Keybinding | Action | Speed |
|------------|--------|-------|
| `<Leader>gQ` | Commit + Push (AI) | ~510ms |
| `<Leader>gY` | **Sync** (pull + commit + push) | ~1s |
| `<Leader>gu` | Pull (rebase) | ~200ms |
| `<Leader>gU` | Push | ~200ms |
| `<Leader>gq` | Commit only (AI, no push) | ~510ms |
| `<Leader>gA` | Interactive commit (full UI) | User-paced |

---

## 🚀 Fastest Workflows

### **1-Key Commit+Push** (Recommended)
```
<Leader>gQ
→ Stage all → Generate AI message → Commit → Push
→ Total: ~510ms
```

### **1-Key Sync** (pull → commit → push)
```
<Leader>gY
→ Pull → Stage all → Generate AI message → Commit → Push
→ Total: ~1s
```

### **Separate Operations**
```
<Leader>gu  (pull)
<Leader>gq  (commit)
<Leader>gU  (push)
```

---

## Shell Aliases (Even Faster!)

Add to `~/.zshrc` or `~/.bashrc`:

```bash
# Git commit + push (AI-generated message)
alias gcp='git add -A && git commit -m "$(NONINTERACTIVE=1 ~/.config/nvim/scripts/git-commit-ai.sh)" && git push'

# Git sync (pull + commit + push)
alias gsync='git pull --rebase && git add -A && git commit -m "$(NONINTERACTIVE=1 ~/.config/nvim/scripts/git-commit-ai.sh)" && git push'

# Quick commit (no push)
alias gc='git add -A && git commit -m "$(NONINTERACTIVE=1 ~/.config/nvim/scripts/git-commit-ai.sh)"'

# Git pull with rebase
alias gpl='git pull --rebase'

# Git push
alias gps='git push'
```

**Usage** (from terminal):
```bash
gcp      # Instant commit+push with AI message
gsync    # Pull, commit, push (full sync)
```

**Performance**: **No Nvim startup overhead** - runs directly in shell!

---

## Comparison: Nvim vs Shell

### Nvim Keybindings
- ✅ Works inside editor
- ✅ Visual feedback (notifications)
- ✅ No context switching
- ❌ Requires Nvim to be open

### Shell Aliases
- ✅ Works anywhere (terminal)
- ✅ Slightly faster (no Nvim startup)
- ✅ Simpler (just bash)
- ❌ No visual feedback
- ❌ Can't use from Nvim

### **Recommendation**: Use both!
- **In Nvim**: `<Leader>gQ` for quick commit+push
- **In terminal**: `gcp` for quick commit+push

---

## Implementation Details

### Background Execution
All operations run asynchronously (non-blocking):
```lua
vim.fn.jobstart(cmd, {
  on_exit = function(_, exit_code)
    -- Show success/failure notification
  end,
  on_stdout = function(_, data)
    -- Stream output in real-time
  end,
})
```

### Error Handling
- Failed commits → Notification with error
- Failed pulls → Notification with conflict details
- Failed pushes → Notification with rejection reason

### Notifications
- 🔄 "Committing and pushing..."
- ✅ "Committed and pushed!"
- ❌ "Commit/push failed"

---

## Advanced Usage

### Custom Commit Message (Override AI)
```bash
# In terminal
git add -A
git commit -m "Your custom message"
git push
```

### Selective Staging
```bash
# Stage specific files first
git add file1.lua file2.lua

# Then use quick commit (won't stage more files)
<Leader>gq
```

### Review Before Push
```bash
<Leader>gq   # Commit only
# Review with: git show HEAD
<Leader>gU   # Push when ready
```

---

## Troubleshooting

### "No changes to commit"
- Nothing is staged
- All changes are already committed
- **Solution**: Make changes first!

### "Push failed: rejected"
- Remote has changes you don't have locally
- **Solution**: Pull first with `<Leader>gu`

### "Commit failed: empty message"
- Claude CLI not available or returned empty
- **Solution**: Install `@anthropic-ai/claude-code` or commit manually

---

## Performance Benchmarks

| Operation | Time |
|-----------|------|
| Bash git stats | < 10ms |
| Claude body generation | ~500ms |
| Git commit | ~50ms |
| Git push | ~200ms (network) |
| **Total (commit+push)** | **~760ms** |

---

## Why This Is Fast

1. **Bash parsing** - No Lua overhead, direct git commands
2. **AI for body only** - Subject is formulaic (bash)
3. **Async execution** - Non-blocking, continues working
4. **No UI overhead** - Direct terminal output

---

## Keyboard Mnemonics

- `gQ` - **Quick** commit+push
- `gY` - S**y**nc (full workflow)
- `gu` - Pull **u**pdate
- `gU` - Push **U**pload
- `gq` - **q**uick commit (no push)

---

## See Also

- `docs/git-commit-ai.md` - AI commit message generation details
- `CLAUDE.md` - Full keybinding reference

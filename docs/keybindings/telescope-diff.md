# Telescope File Diff

## Diff Two Files Using Telescope

Your telescope configuration includes a built-in diff feature for comparing any two files in your codebase.

### Quick Workflow

1. **Open telescope file finder**: `<Leader>ff` (or any telescope picker)
2. **Select first file**: Press `Tab` to toggle selection
3. **Select second file**: Press `Tab` to toggle selection
4. **Trigger diff**: Press `Ctrl+D`

### Example

```
<Leader>ff          → Open file finder
/some-file.lua      → Search for first file
Tab                 → Select it
/another-file.lua   → Search for second file
Tab                 → Select it
Ctrl+D              → Open diff view
q                   → Close diff when done
```

## Features

The diff viewer provides:
- **GitHub-style unified diff** format
- **Syntax highlighting** for additions (green) and deletions (red)
- **Read-only buffer** to prevent accidental edits
- **Quick close** with `q` keybinding
- **Tab-based view** so you can easily switch back to your work

## Implementation Details

From `lua/plugins/telescope.lua:36-129`:
- Custom action: `diff_selected_files`
- Keybinding: `<C-d>` in both insert and normal mode
- Requires exactly 2 files to be selected
- Uses system `diff -u` command for comparison
- Opens result in a new tab with diff filetype

## Alternative: Side-by-Side Diff

For inline side-by-side diffs:

1. Open first file: `:e file1.lua`
2. Split and diff: `:vert diffsplit file2.lua`

## Related Git Diff Features

- `<Leader>hd` - Inline git diff for current file vs index
- `<Leader>hD` - Inline git diff vs HEAD~
- `<Leader>gd` - Full DiffView (separate tab with file panel)
- `<Leader>hp` - Preview current git hunk in floating window

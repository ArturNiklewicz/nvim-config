# Refactoring Workflow Cheatsheet

Complete guide for efficient code refactoring using Telescope, Harpoon, Grapple, refactoring.nvim, and Vim macros.

---

## Quick Reference

| Tool | Purpose | Key |
|------|---------|-----|
| **Harpoon** | Permanent hot files (4-5 per project) | `<Leader>h` |
| **Grapple** | Branch-scoped context files | `<Leader>g` |
| **Telescope** | Fuzzy find + preview + tag | `<Leader>f` |
| **refactoring.nvim** | Semantic refactors | `<Leader>r` |
| **Macros** | Record & replay edits | `q{reg}` |

---

## Part 1: File Navigation & Tagging

### Telescope Tagging (Multi-Select Support)

```
<Leader>ff          Open find_files
<Tab>               Toggle selection on current file
<S-Tab>             Toggle selection (move up)
<C-h>               Add to Harpoon (selected files OR current)
<C-g>               Tag with Grapple (selected files OR current)
<CR>                Open file(s)
<Esc>               Close picker
```

**Workflow**: Use `<Tab>` to select multiple files, then `<C-h>` or `<C-g>` to batch add.
Selections are cleared after adding, so you can continue selecting more files.

### Harpoon: Permanent Project Files

```
<Leader>ha          Add current buffer to Harpoon
<Leader>hh          Toggle Harpoon quick menu
<Leader>h1-9        Jump directly to slot 1-9
<Leader>hp/hn       Previous/next Harpoon file
<Leader>fm          Telescope: preview Harpoon marks
```

### Grapple: Branch-Scoped Tags

```
<Leader>ga          Toggle Grapple tag (remembers cursor position)
<Leader>gm          Toggle Grapple menu
<Leader>g[/g]       Previous/next Grapple tag
<Leader>ft          Telescope: preview Grapple tags
```

**Key difference**: Grapple tags are scoped to git branch. Switch branches → different tags.

---

## Part 2: Semantic Refactoring (refactoring.nvim)

### Interactive Refactor Menu

```
<Leader>rr          Telescope refactor selector (works in normal + visual)
```

### Extract Operations (Visual Mode)

Select code first with `v`, `V`, or `<C-v>`, then:

```
<Leader>re          Extract Function
<Leader>rf          Extract Function To File
<Leader>rv          Extract Variable
```

### Extract Operations (Normal Mode)

```
<Leader>rb          Extract Block (under cursor)
<Leader>rB          Extract Block To File
```

### Inline Operations

```
<Leader>ri          Inline Variable (normal + visual)
<Leader>rI          Inline Function
```

### Debug Helpers

```
<Leader>rp          Insert printf debug statement
<Leader>rP          Print variable under cursor (visual)
<Leader>rc          Cleanup all debug statements
```

### LSP Refactoring

```
<Leader>rn          Rename symbol (LSP)
<Leader>ca          Code actions menu
```

---

## Part 3: Vim Macros for Repetitive Refactoring

### Macro Basics

```
q{reg}              Start recording to register (a-z)
q                   Stop recording
@{reg}              Play macro once
@@                  Repeat last macro
{n}@{reg}           Play macro n times
:%normal @{reg}     Play macro on all lines
```

### Recording Best Practices

1. **Start from known position**: Begin with `0` (line start) or `^` (first non-blank)
2. **Use motions, not counts**: `dw` not `5x` (words vary in length)
3. **End on next target**: Finish with `j` or `n` to position for repeat
4. **Use search patterns**: `/pattern<CR>` finds regardless of position

### Macro Workflow Example

**Scenario**: Convert function calls across multiple files

```vim
" 1. Record macro on first occurrence
qq                          " Start recording to register q
0                           " Go to line start (known position)
/oldFunction(<CR>           " Find the function call
ciw                         " Change inner word
newFunction<Esc>            " Type new name
n                           " Jump to next occurrence
q                           " Stop recording

" 2. Test on current file
@q                          " Run once to verify
@@                          " Run again
100@@                       " Run 100 more times (stops at end)

" 3. Apply across Harpoon files
<Leader>h1                  " Jump to file 1
:%normal @q                 " Apply to all lines
<Leader>h2                  " Jump to file 2
:%normal @q                 " Apply to all lines
```

### Advanced Macro Patterns

#### Pattern 1: CSV to Code Transformation

```vim
" Input:  name,type,default
" Output: private name: type = default;

qa                          " Record to register a
0                           " Start of line
iprivate <Esc>              " Insert 'private '
f,                          " Find first comma
s: <Esc>                    " Replace with ': '
f,                          " Find second comma
s = <Esc>                   " Replace with ' = '
A;<Esc>                     " Append semicolon
j0                          " Next line, start position
q                           " Stop recording
```

#### Pattern 2: Add Error Handling to Functions

```vim
qe                          " Record to register e
/function<CR>               " Find function keyword
/{<CR>                      " Find opening brace
o  try {<Esc>               " Open line, add try
/return<CR>                 " Find return statement
O  } catch (error) {<CR>    " Add catch before return
    console.error(error);<CR>
    throw error;<CR>
  }<Esc>
n                           " Next function
q                           " Stop recording
```

#### Pattern 3: Convert Promise to Async/Await

```vim
qp                          " Record to register p
/\.then(<CR>                " Find .then(
dt(                         " Delete to opening paren
iawait <Esc>                " Insert await
/\.then(<CR>                " Find next .then if exists
q                           " Stop recording
```

### Macro + Refactoring.nvim Combo

```vim
" 1. Use refactoring.nvim for the first semantic change
V                           " Visual line
<Leader>re                  " Extract Function (prompts for name)

" 2. Record macro for repetitive follow-up edits
qq
/oldPattern<CR>
ciwnewPattern<Esc>
n
q

" 3. Apply macro, then use LSP rename for final cleanup
50@@                        " Apply pattern changes
<Leader>rn                  " LSP rename for proper refactoring
```

---

## Part 4: Complete Refactoring Workflows

### Workflow A: Refactor Across Multiple Files

```
1. DISCOVER     <Leader>ff → search for files to refactor
2. TAG          <C-h> on each file (adds to Harpoon)
3. PREVIEW      <Leader>fm → verify tagged files
4. REFACTOR     On first file:
                  - Visual select code
                  - <Leader>rr → choose refactor type
                  - Or record macro: qq...q
5. PROPAGATE    <Leader>h1 → @q → <Leader>h2 → @q → ...
6. VERIFY       <Leader>fm → check each file
7. RENAME       <Leader>rn for final symbol renames
```

### Workflow B: Branch-Specific Refactoring

```
1. BRANCH       git checkout feature/refactor-auth
2. TAG          <Leader>ga on each file (Grapple, branch-scoped)
3. NAVIGATE     <Leader>g[ and <Leader>g] to cycle files
4. REFACTOR     <Leader>re/rv/ri for semantic changes
5. COMMIT       Changes tracked per branch
6. SWITCH       git checkout main (Grapple tags change!)
```

### Workflow C: Bulk Text Transformation with Macros

```
1. MARK START   <Leader>ha (add file to Harpoon)
2. RECORD       qq (start macro)
3. POSITION     0 or ^ (known starting point)
4. TRANSFORM    Use motions: f, t, w, e, /, etc.
5. FINISH       j (move to next line)
6. STOP         q (end recording)
7. TEST         @q (verify on one line)
8. BULK APPLY   :%normal @q (all lines in file)
9. NEXT FILE    <Leader>h2 → :%normal @q
```

---

## Part 5: Macro Register Reference

### View Macros

```vim
:reg                        " Show all registers
:reg q                      " Show register q only
```

### Edit Macros

```vim
" Paste macro to buffer, edit, then re-save
:put q                      " Paste register q
" ... edit the line ...
"qy$                        " Yank back to register q
```

### Special Characters in Macros

| Char | Meaning | Insert with |
|------|---------|-------------|
| `^[` | Escape | `Ctrl+v` then `Esc` |
| `^M` | Enter | `Ctrl+v` then `Enter` |
| `^I` | Tab | `Ctrl+v` then `Tab` |

### Persistent Macros (Save Across Sessions)

Add to your config or save in a file:

```vim
" In init.lua or a macro file
vim.fn.setreg('q', '0f,r:ea;<Esc>j')
vim.fn.setreg('e', '/function\n/{<CR>otry {<Esc>')
```

---

## Part 6: Refactoring.nvim Keybindings Reference

| Key | Operation | Mode | Description |
|-----|-----------|------|-------------|
| `<Leader>rr` | Telescope Menu | n, x | Interactive refactor selector |
| `<Leader>re` | Extract Function | x | Pull selection into new function |
| `<Leader>rf` | Extract Function To File | x | Extract selection to separate file |
| `<Leader>rv` | Extract Variable | x | Assign selection to variable |
| `<Leader>rb` | Extract Block | n | Extract block under cursor |
| `<Leader>rB` | Extract Block To File | n | Extract block to separate file |
| `<Leader>ri` | Inline Variable | n, x | Replace variable with its value |
| `<Leader>rI` | Inline Function | n | Replace call with function body |
| `<Leader>rn` | Rename Symbol | n | LSP-based symbol rename |
| `<Leader>rdp` | Printf Debug | n | Insert debug print statement |
| `<Leader>rdv` | Print Variable | n, x | Print variable value |
| `<Leader>rdc` | Cleanup Debug | n | Remove all debug statements |

**Mode Key**: `n` = normal, `x` = visual (select code first)

---

## Part 7: Tips & Tricks

### Performance for Large Files

```vim
:set lazyredraw              " Don't redraw during macro execution
```

### Safe Macro Execution

```vim
" Stop on error (won't continue if pattern not found)
:set debug=msg

" Or use :global for conditional execution
:g/pattern/normal @q
```

### Combining with Quickfix

```vim
<Leader>ff                   " Find files
<Tab><Tab><Tab>              " Select multiple
<C-q>                        " Send to quickfix list
:cdo normal @q               " Run macro on all quickfix entries
```

### Multi-Cursor Alternative

For simple changes, consider multi-cursor (`<Leader>cd`) instead of macros:

```
<Leader>cd                   " Add cursor at word under cursor
<Leader>cd                   " Add another (like Ctrl+D in VSCode)
c                            " Change all at once
newText<Esc>                 " Type replacement
```

---

## Quick Cheatsheet

```
┌──────────────────────────────────────────────────────────────┐
│  NAVIGATION                                                   │
├──────────────────────────────────────────────────────────────┤
│  <Leader>ff            Open file finder                      │
│  <Tab>                 Toggle selection on file              │
│  <C-h>                 Add selected/current to Harpoon       │
│  <C-g>                 Tag selected/current with Grapple     │
│  <Leader>h1-9          Jump to Harpoon slot                  │
│  <Leader>g[/g]         Cycle Grapple tags                    │
├──────────────────────────────────────────────────────────────┤
│  REFACTORING                                                  │
├──────────────────────────────────────────────────────────────┤
│  <Leader>rr            Telescope refactor menu (n/x)         │
│  <Leader>re            Extract Function (visual)             │
│  <Leader>rf            Extract Function to File (visual)     │
│  <Leader>rv            Extract Variable (visual)             │
│  <Leader>rb            Extract Block (normal)                │
│  <Leader>rB            Extract Block to File (normal)        │
│  <Leader>ri            Inline Variable (n/x)                 │
│  <Leader>rI            Inline Function (normal)              │
│  <Leader>rn            Rename Symbol (LSP)                   │
├──────────────────────────────────────────────────────────────┤
│  MACROS                                                       │
├──────────────────────────────────────────────────────────────┤
│  qq                    Start recording to register q         │
│  q                     Stop recording                        │
│  @q                    Play macro                            │
│  @@                    Repeat last macro                     │
│  10@@                  Play macro 10 times                   │
│  :%normal @q           Play macro on all lines               │
│  :g/pattern/normal @q  Play macro on matching lines          │
├──────────────────────────────────────────────────────────────┤
│  WORKFLOW                                                     │
├──────────────────────────────────────────────────────────────┤
│  1. Tag files:    <Leader>ff → <Tab> to select → <C-h>       │
│  2. Record:       qq → edits → j → q                         │
│  3. Apply:        <Leader>h1 → :%normal @q → repeat          │
└──────────────────────────────────────────────────────────────┘
```

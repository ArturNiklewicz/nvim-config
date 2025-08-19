# Neovim Keybinding Complete Analysis Report

Generated: 2025-08-13 20:30:06

## Summary Statistics

| Metric | Count |
|--------|-------|
| Total Keybindings | 441 |
| Unique Keybindings | 372 |
| Duplicates | 7 |
| Conflicts | 62 |
| Which-Key Registered | 14 |
| Orphaned | 0 |
| Unbinded | 386 |

## Conflicts (Action Required)

### `[n] <Esc>`

- **lua/plugins/neo-tree.lua:89** → `revert_preview`
- **lua/plugins/error-messages.lua:246** → `"<cmd>close<cr>"`

### `[n] Gp`

- **lua/plugins/astrocore.lua:225** → `<cmd>Octo pr list<cr>`
- **validate-keybindings.lua:78** → `GitHub PRs`

### `[n] n`

- **lua/plugins/astrocore.lua:365** → `nzzzv`
- **keybinding-ultimate-analyzer.lua:111** → `n`

### `[n] ]j`

- **lua/plugins/astrocore.lua:371** → `<cmd>MoltenNext<cr>`
- **validate-keybindings.lua:139** → `Next Jupyter cell`

### `[n] [j`

- **lua/plugins/astrocore.lua:372** → `<cmd>MoltenPrev<cr>`
- **validate-keybindings.lua:140** → `Previous Jupyter cell`

### `[n] <C-M-t>`

- **lua/plugins/astrocore.lua:379** → `<cmd>ToggleTerm<cr>`
- **lua/plugins/astrocore.lua:433** → `<cmd>ToggleTerm<cr>`
- **validate-keybindings.lua:145** → `Toggle terminal`

### `[n] dd`

- **lua/plugins/astrocore.lua:384** → ` `
- **lua/plugins/fugitive.lua:96** → `"dd"`

### `[n] /`

- **lua/plugins/astrocore.lua:392** → `<Plug>(comment_toggle_linewise_visual)`
- **lua/plugins/neo-tree.lua:144** → `fuzzy_finder`

### `[n] as`

- **lua/plugins/astrocore.lua:395** → `<cmd>ClaudeCodeSend<cr>`
- **lua/plugins/text-objects.lua:45** → `@statement.outer`

### `[n] gc`

- **lua/plugins/neo-tree.lua:162** → `git_commit`
- **lua/plugins/fugitive.lua:39** → `<cmd>Git commit<cr>`
- **validate-keybindings.lua:61** → `Git commits`

### `[n] ur`

- **lua/plugins/astrocore.lua:302** → `<cmd>set relativenumber!<cr>`
- **validate-keybindings.lua:120** → `Toggle relative`

### `[n] bd`

- **lua/plugins/neo-tree.lua:177** → `buffer_delete`
- **validate-keybindings.lua:37** → `Delete buffer`

### `[n] ji`

- **lua/plugins/astrocore.lua:188** → `<cmd>MoltenInit<cr>`
- **validate-keybindings.lua:88** → `Initialize molten`

### `[n] <`

- **lua/plugins/astrocore.lua:418** → `<gv`
- **lua/plugins/neo-tree.lua:116** → `prev_source`

### `[n] >`

- **lua/plugins/astrocore.lua:419** → `>gv`
- **lua/plugins/neo-tree.lua:117** → `next_source`

### `[n] jl`

- **lua/plugins/astrocore.lua:190** → `<cmd>MoltenEvaluateLine<cr>`
- **validate-keybindings.lua:89** → `Evaluate line`

### `[n] jo`

- **lua/plugins/astrocore.lua:192** → `<cmd>MoltenShowOutput<cr>`
- **validate-keybindings.lua:90** → `Show output`

### `[n] jh`

- **lua/plugins/astrocore.lua:193** → `<cmd>MoltenHideOutput<cr>`
- **validate-keybindings.lua:91** → `Hide output`

### `[n] ?`

- **lua/plugins/astrocore.lua:52** → `<cmd>Keybindings<cr>`
- **lua/plugins/neo-tree.lua:115** → `show_help`
- **lua/plugins/keybind-help.lua:37** → `show_keybindings`
- **validate-keybindings.lua:23** → `Show keybindings`

### `[n] ac`

- **lua/plugins/astrocore.lua:59** → `<cmd>ClaudeCodeResume<cr>`
- **lua/plugins/text-objects.lua:21** → `@class.outer`
- **validate-keybindings.lua:30** → `Claude toggle`

### `[n] aC`

- **lua/plugins/astrocore.lua:60** → `<cmd>ClaudeCodeFresh<cr>`
- **lua/plugins/text-objects.lua:37** → `@comment.outer`
- **validate-keybindings.lua:31** → `Claude fresh`

### `[n] af`

- **lua/plugins/astrocore.lua:61** → `<cmd>ClaudeCodeFocus<cr>`
- **lua/plugins/text-objects.lua:17** → `@function.outer`

### `[n] ab`

- **lua/plugins/astrocore.lua:63** → `<cmd>ClaudeCodeAdd %<cr>`
- **lua/plugins/text-objects.lua:41** → `@block.outer`

### `[n] ca`

- **lua/plugins/fugitive.lua:92** → `"ca"`
- **validate-keybindings.lua:42** → `Code action`

### `[n] aa`

- **lua/plugins/astrocore.lua:64** → `<cmd>ClaudeAcceptChanges<cr>`
- **validate-keybindings.lua:32** → `Accept changes`

### `[n] ad`

- **lua/plugins/astrocore.lua:65** → `<cmd>ClaudeRejectChanges<cr>`
- **validate-keybindings.lua:33** → `Deny changes`

### `[n] gd`

- **lua/plugins/astrocore.lua:128** → `<cmd>DiffviewOpen<cr>`
- **lua/plugins/fugitive.lua:43** → `<cmd>Gdiffsplit<cr>`
- **validate-keybindings.lua:62** → `Git diff view`

### `[n] gD`

- **lua/plugins/astrocore.lua:129** → `<cmd>DiffviewClose<cr>`
- **lua/plugins/fugitive.lua:44** → `<cmd>Git diff<cr>`

### `[n] gl`

- **lua/plugins/astrocore.lua:136** → `<cmd>Gitsigns toggle_linehl<cr>`
- **lua/plugins/fugitive.lua:48** → `<cmd>Git log<cr>`

### `[n] s`

- **lua/plugins/neo-tree.lua:93** → `open_vsplit`
- **lua/plugins/fugitive.lua:86** → `"s"`

### `[n] A`

- **lua/plugins/neo-tree.lua:106** → `add_directory`
- **lua/plugins/neo-tree.lua:158** → `git_add_all`

### `[n] gs`

- **lua/plugins/fugitive.lua:38** → `<cmd>Git<cr>`
- **validate-keybindings.lua:59** → `Git status`

### `[n] ]c`

- **lua/plugins/text-objects.lua:77** → `@class.outer`
- **validate-keybindings.lua:135** → `Next git hunk`

### `[n] ]C`

- **lua/plugins/text-objects.lua:81** → `@comment.outer`
- **lua/plugins/text-objects.lua:85** → `@class.outer`

### `[n] mC`

- **lua/plugins/astrocore.lua:207** → `<Cmd>MCclear<CR>`
- **validate-keybindings.lua:96** → `Multicursor clear`

### `[n] [c`

- **lua/plugins/text-objects.lua:92** → `@class.outer`
- **validate-keybindings.lua:136** → `Previous git hunk`

### `[n] ma`

- **lua/plugins/astrocore.lua:208** → `<Cmd>MCstart<CR>`
- **validate-keybindings.lua:97** → `Multicursor add`

### `[n] [C`

- **lua/plugins/text-objects.lua:96** → `@comment.outer`
- **lua/plugins/text-objects.lua:100** → `@class.outer`

### `[n] gp`

- **lua/plugins/neo-tree.lua:163** → `git_push`
- **lua/plugins/fugitive.lua:52** → `<cmd>Git push<cr>`

### `[n] Ma`

- **lua/plugins/astrocore.lua:214** → `<cmd>Messages<cr>`
- **validate-keybindings.lua:101** → `Show messages`

### `[n] Mc`

- **lua/plugins/astrocore.lua:215** → `<cmd>CopyLastError<cr>`
- **validate-keybindings.lua:102** → `Copy last error`

### `[n] gO`

- **lua/plugins/fugitive.lua:68** → `<cmd>GBrowse<cr>`
- **lua/plugins/fugitive.lua:71** → `:GBrowse<cr>`

### `[n] gb`

- **lua/plugins/fugitive.lua:47** → `<cmd>Git blame<cr>`
- **validate-keybindings.lua:60** → `Git branches`

### `[n] ]g`

- **lua/plugins/neo-tree.lua:150** → `next_git_modified`
- **validate-keybindings.lua:141** → `Next git hunk`

### `[n] [g`

- **lua/plugins/neo-tree.lua:149** → `prev_git_modified`
- **validate-keybindings.lua:142** → `Previous git hunk`

### `[n] .`

- **lua/plugins/text-objects.lua:147** → `textsubjects-smart`
- **lua/plugins/neo-tree.lua:142** → `set_root`
- **lua/plugins/neo-tree.lua:179** → `set_root`

### `[n] w`

- **lua/plugins/neo-tree.lua:95** → `open_with_window_picker`
- **validate-keybindings.lua:24** → `Close buffer`

### `[n] Me`

- **lua/plugins/astrocore.lua:213** → `<cmd>Errors<cr>`
- **validate-keybindings.lua:100** → `Show errors`

### `[n] e`

- **lua/plugins/neo-tree.lua:13** → `<cmd>Neotree toggle reveal right<cr>`
- **validate-keybindings.lua:26** → `Toggle file explorer`

### `[n] E`

- **lua/plugins/neo-tree.lua:14** → `<cmd>Neotree focus reveal right<cr>`
- **validate-keybindings.lua:27** → `Focus file explorer`

### `[n] q`

- **lua/plugins/astrocore.lua:50** → `<cmd>confirm q<cr>`
- **lua/plugins/neo-tree.lua:114** → `close_window`
- **lua/plugins/fugitive.lua:83** → `"<cmd>close<cr>"`
- **lua/plugins/error-messages.lua:245** → `"<cmd>close<cr>"`
- **validate-keybindings.lua:25** → `Quit`

### `[n] ge`

- **lua/plugins/neo-tree.lua:17** → `<cmd>Neotree toggle source=git_status position=right<cr>`
- **validate-keybindings.lua:63** → `Git explorer`

### `[n] gE`

- **lua/plugins/neo-tree.lua:18** → `<cmd>Neotree focus source=git_status position=right<cr>`
- **validate-keybindings.lua:64** → `Focus git explorer`

### `[n] un`

- **lua/plugins/astrocore.lua:301** → `<cmd>set number!<cr>`
- **validate-keybindings.lua:119** → `Toggle numbers`

### `[n] be`

- **lua/plugins/neo-tree.lua:21** → `<cmd>Neotree toggle source=buffers position=right<cr>`
- **validate-keybindings.lua:38** → `Toggle buffer explorer`

### `[n] bE`

- **lua/plugins/neo-tree.lua:22** → `<cmd>Neotree focus source=buffers position=right<cr>`
- **validate-keybindings.lua:39** → `Focus buffer explorer`

### `[n] mn`

- **lua/plugins/astrocore.lua:206** → `<Cmd>MCpattern<CR>`
- **lua/plugins/astrocore.lua:415** → `<Cmd>MCpattern<CR>`
- **validate-keybindings.lua:95** → `Multicursor pattern`

### `[n] vy`

- **lua/plugins/astrocore.lua:317** → `<cmd>Telescope neoclip<cr>`
- **validate-keybindings.lua:123** → `Clipboard history`

### `[n] gr`

- **lua/plugins/astrocore.lua:139** → `<cmd>Gitsigns refresh<cr>`
- **lua/plugins/neo-tree.lua:161** → `git_revert_file`
- **lua/plugins/fugitive.lua:64** → `<cmd>Gread<cr>`

### `[n] Gi`

- **lua/plugins/astrocore.lua:223** → `<cmd>Octo issue list<cr>`
- **validate-keybindings.lua:77** → `GitHub issues`

### `[n] rr`

- **lua/plugins/astrocore.lua:257** → `<cmd>Spectre<cr>`
- **lua/plugins/astrocore.lua:405** → `<cmd>Spectre<cr>`
- **validate-keybindings.lua:105** → `Replace (Spectre)`

### `[n] mc`

- **lua/plugins/astrocore.lua:205** → `<Cmd>MCstart<CR>`
- **lua/plugins/astrocore.lua:414** → `<Cmd>MCstart<CR>`
- **validate-keybindings.lua:94** → `Multicursor create`


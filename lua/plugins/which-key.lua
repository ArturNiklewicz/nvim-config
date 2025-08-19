-- Balanced Keybinding Configuration
-- Using new which-key v3 spec format

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 200
  end,
  config = function()
    local wk = require("which-key")
    
    wk.setup({
      plugins = {
        marks = true,
        registers = true,
        spelling = { enabled = true, suggestions = 20 },
        presets = {
          operators = false,
          motions = false,
          text_objects = false,
          windows = true,
          nav = true,
          z = false,
          g = true,
        },
      },
      icons = {
        breadcrumb = "»",
        separator = "→",
        group = "+",
      },
      win = {
        border = "rounded",
        wo = {
          winblend = 0,
        },
      },
      layout = {
        height = { min = 4, max = 20 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "center",
      },
    })

    -- Define all keybindings using the new spec format
    local mappings = {
      -- Direct access commands (no submenu)
      { "<leader>e", "<cmd>Oil<cr>", desc = "File explorer (Oil)" },
      { "<leader>E", "<cmd>Neotree toggle<cr>", desc = "Neo-tree toggle" },
      { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>s", "<cmd>Telescope live_grep<cr>", desc = "Search project" },
      { "<leader>w", function() require("astrocore.buffer").close() end, desc = "Close buffer" },
      { "<leader>q", "<cmd>q<cr>", desc = "Quit" },
      { "<leader>Q", "<cmd>qa<cr>", desc = "Quit all" },
      { "<leader>h", "<cmd>nohlsearch<cr>", desc = "Clear highlights" },
      { "<leader>P", "<cmd>Telescope commands<cr>", desc = "Command palette" },
      { "<leader>.", "<cmd>Telescope find_files cwd=%:p:h<cr>", desc = "Find in current dir" },
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen mode" },
      { "<leader>W", "<cmd>wa<cr>", desc = "Save all" },
      { "<leader>R", "<cmd>e!<cr>", desc = "Reload file" },
      { "<leader>n", "<cmd>enew<cr>", desc = "New file" },
      { "<leader>`", function() require("astrocore.buffer").nav_to_last() end, desc = "Switch to last buffer" },
      { "<leader>?", "<cmd>Keybindings<cr>", desc = "Show keybindings" },
      { "<leader>-", "<cmd>Oil .<cr>", desc = "Open current directory" },
      
      -- Buffer navigation (1-9, 0)
      { "<leader>1", function() require("astrocore.buffer").nav(1) end, desc = "Buffer 1" },
      { "<leader>2", function() require("astrocore.buffer").nav(2) end, desc = "Buffer 2" },
      { "<leader>3", function() require("astrocore.buffer").nav(3) end, desc = "Buffer 3" },
      { "<leader>4", function() require("astrocore.buffer").nav(4) end, desc = "Buffer 4" },
      { "<leader>5", function() require("astrocore.buffer").nav(5) end, desc = "Buffer 5" },
      { "<leader>6", function() require("astrocore.buffer").nav(6) end, desc = "Buffer 6" },
      { "<leader>7", function() require("astrocore.buffer").nav(7) end, desc = "Buffer 7" },
      { "<leader>8", function() require("astrocore.buffer").nav(8) end, desc = "Buffer 8" },
      { "<leader>9", function() require("astrocore.buffer").nav(9) end, desc = "Buffer 9" },
      { "<leader>0", function() require("astrocore.buffer").nav(10) end, desc = "Buffer 10" },

      -- Git operations
      { "<leader>g", group = "Git" },
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit (full UI)" },
      { "<leader>gf", function() require("telescope.builtin").git_status() end, desc = "List changed files" },
      { "<leader>gs", function() require("telescope.builtin").git_status() end, desc = "Git status" },
      { "<leader>gb", function() require("telescope.builtin").git_branches() end, desc = "Git branches" },
      { "<leader>gc", function() require("telescope.builtin").git_commits() end, desc = "Git commits" },
      { "<leader>gC", function() require("telescope.builtin").git_bcommits() end, desc = "Buffer commits" },
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff view" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
      { "<leader>gt", "<cmd>Gitsigns toggle_signs<cr>", desc = "Toggle git signs" },
      { "<leader>gn", "<cmd>Gitsigns toggle_numhl<cr>", desc = "Toggle line number highlighting" },
      { "<leader>gl", "<cmd>Gitsigns toggle_linehl<cr>", desc = "Toggle line highlighting" },
      { "<leader>gW", "<cmd>Gitsigns toggle_word_diff<cr>", desc = "Toggle word diff" },
      { "<leader>gT", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle blame line" },
      { "<leader>gr", "<cmd>Gitsigns refresh<cr>", desc = "Refresh git signs" },
      { "<leader>gj", function() require("utils.git-monitor").jump_file("next") end, desc = "Next changed file" },
      { "<leader>gk", function() require("utils.git-monitor").jump_file("prev") end, desc = "Previous changed file" },
      
      -- Git watchlist
      { "<leader>gw", group = "Git watchlist" },
      { "<leader>gwa", function() require("utils.git-monitor").add_to_watchlist() end, desc = "Add file to watchlist" },
      { "<leader>gwr", function() require("utils.git-monitor").remove_from_watchlist() end, desc = "Remove file from watchlist" },
      { "<leader>gwl", function() require("utils.git-monitor").show_watchlist() end, desc = "Show watchlist" },
      { "<leader>gwj", function() require("utils.git-monitor").jump_watchlist("next") end, desc = "Next watchlist file" },
      { "<leader>gwk", function() require("utils.git-monitor").jump_watchlist("prev") end, desc = "Previous watchlist file" },
      { "<leader>gwm", function() require("utils.git-monitor").monitor_changes() end, desc = "Check for changes" },
      { "<leader>gws", function() require("utils.git-monitor").setup_auto_monitor() vim.notify("Auto-monitoring enabled for watchlist", vim.log.levels.INFO) end, desc = "Start auto-monitoring" },

      -- GitHub operations
      { "<leader>G", group = "GitHub" },
      { "<leader>Gi", "<cmd>Octo issue list<cr>", desc = "List GitHub issues" },
      { "<leader>GI", "<cmd>Octo issue create<cr>", desc = "Create GitHub issue" },
      { "<leader>Gp", "<cmd>Octo pr list<cr>", desc = "List GitHub PRs" },
      { "<leader>GP", "<cmd>Octo pr create<cr>", desc = "Create GitHub PR" },
      { "<leader>Gr", "<cmd>Octo repo list<cr>", desc = "List GitHub repos" },
      { "<leader>Gs", "<cmd>Octo search<cr>", desc = "Search GitHub" },
      { "<leader>Ga", "<cmd>Octo assignee add<cr>", desc = "Add GitHub assignee" },
      { "<leader>Gl", "<cmd>Octo label add<cr>", desc = "Add GitHub label" },
      { "<leader>Gc", "<cmd>Octo comment add<cr>", desc = "Add GitHub comment" },
      { "<leader>GR", "<cmd>Octo review start<cr>", desc = "Start GitHub review" },
      { "<leader>Gd", "<cmd>Octo pr diff<cr>", desc = "Show GitHub PR diff" },
      { "<leader>Go", "<cmd>Octo pr checkout<cr>", desc = "Checkout GitHub PR" },
      { "<leader>Gm", function() vim.ui.input({ prompt = "Merge method (merge/squash/rebase): " }, function(method) if method and (method == "merge" or method == "squash" or method == "rebase") then vim.fn.system("gh pr merge --" .. method) vim.notify("PR merged with " .. method) end end) end, desc = "Merge GitHub PR" },
      { "<leader>Gv", function() vim.fn.system("gh pr view --web") vim.notify("Opening PR in browser...") end, desc = "View GitHub PR in browser" },
      { "<leader>Gw", function() vim.fn.system("gh repo view --web") vim.notify("Opening repo in browser...") end, desc = "View GitHub repo in browser" },

      -- AI/Claude
      { "<leader>a", group = "AI/Claude" },
      { "<leader>ac", "<cmd>ClaudeCodeResume<cr>", desc = "Claude toggle (resume)" },
      { "<leader>aC", "<cmd>ClaudeCodeFresh<cr>", desc = "Claude fresh chat" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude focus" },
      { "<leader>ar", "<cmd>ClaudeCodeResume<cr>", desc = "Claude resume" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer to Claude" },
      { "<leader>aa", "<cmd>ClaudeAcceptChanges<cr>", desc = "Accept changes" },
      { "<leader>ad", "<cmd>ClaudeRejectChanges<cr>", desc = "Reject changes" },
      { "<leader>ao", "<cmd>ClaudeOpenAllFiles<cr>", desc = "Open edited files" },
      { "<leader>ai", "<cmd>ClaudeShowDiff<cr>", desc = "Show diff" },
      { "<leader>aD", "<cmd>ClaudeShowAllDiffs<cr>", desc = "Show all diffs" },

      -- Code/LSP
      { "<leader>c", group = "Code" },
      { "<leader>ca", function() vim.lsp.buf.code_action() end, desc = "Code action" },
      { "<leader>cd", function() vim.lsp.buf.definition() end, desc = "Code definition" },
      { "<leader>cD", function() vim.lsp.buf.declaration() end, desc = "Code declaration" },
      { "<leader>ci", function() vim.lsp.buf.implementation() end, desc = "Code implementation" },
      { "<leader>cr", function() vim.lsp.buf.references() end, desc = "Code references" },
      { "<leader>cR", function() vim.lsp.buf.rename() end, desc = "Code rename" },
      { "<leader>ct", function() vim.lsp.buf.type_definition() end, desc = "Code type definition" },
      { "<leader>ch", function() vim.lsp.buf.hover() end, desc = "Code hover" },
      { "<leader>cs", function() vim.lsp.buf.signature_help() end, desc = "Code signature" },
      { "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, desc = "Code format" },

      -- Find/Search
      { "<leader>f", group = "Find" },
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
      { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "Recent files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Find buffers" },
      { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help tags" },
      { "<leader>fm", function() require("telescope.builtin").marks() end, desc = "Find marks" },
      { "<leader>fc", function() require("telescope.builtin").commands() end, desc = "Commands" },
      { "<leader>fk", function() require("telescope.builtin").keymaps() end, desc = "Keymaps" },
      { "<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Document symbols" },
      { "<leader>fS", function() require("telescope.builtin").lsp_workspace_symbols() end, desc = "Workspace symbols" },
      { "<leader>fo", function() require("telescope.builtin").vim_options() end, desc = "Vim options" },
      { "<leader>fR", function() require("telescope.builtin").registers() end, desc = "Registers" },

      -- Jupyter/Molten
      { "<leader>j", group = "Jupyter" },
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Initialize Molten" },
      { "<leader>je", "<cmd>MoltenEvaluateOperator<cr>", desc = "Evaluate operator" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Evaluate line" },
      { "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Re-evaluate cell" },
      { "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Show output" },
      { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Hide output" },
      { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Delete cell" },
      { "<leader>js", "<cmd>MoltenStart<cr>", desc = "Start kernel" },
      { "<leader>jS", "<cmd>MoltenStop<cr>", desc = "Stop kernel" },
      { "<leader>jR", "<cmd>MoltenRestart<cr>", desc = "Restart kernel" },
      { "<leader>jk", "<cmd>MoltenKernelStatusToggle<cr>", desc = "Toggle kernel status" },
      { "<leader>jI", "<cmd>MoltenImportOutput<cr>", desc = "Import output" },
      { "<leader>jE", "<cmd>MoltenExportOutput<cr>", desc = "Export output" },


      -- Messages/Errors
      { "<leader>M", group = "Messages" },
      { "<leader>Me", "<cmd>Errors<cr>", desc = "Show errors" },
      { "<leader>Ma", "<cmd>Messages<cr>", desc = "Show all messages" },
      { "<leader>Mc", "<cmd>CopyLastError<cr>", desc = "Copy last error" },
      { "<leader>MC", "<cmd>CopyAllErrors<cr>", desc = "Copy all errors" },
      { "<leader>MA", "<cmd>CopyAllMessages<cr>", desc = "Copy all messages" },
      { "<leader>Md", "<cmd>messages clear<cr>", desc = "Clear messages" },

      -- Buffers
      { "<leader>b", group = "Buffers" },
      { "<leader>bb", function() require("telescope.builtin").buffers() end, desc = "List buffers" },
      { "<leader>bd", function() require("astrocore.buffer").close() end, desc = "Delete buffer" },
      { "<leader>bD", function() require("astrocore.buffer").close_all() end, desc = "Delete all buffers" },
      { "<leader>bo", function() require("astrocore.buffer").close_others() end, desc = "Delete other buffers" },
      { "<leader>bs", "<cmd>w<cr>", desc = "Save buffer" },
      { "<leader>bS", "<cmd>wa<cr>", desc = "Save all buffers" },
      { "<leader>b1", function() require("astrocore.buffer").nav(1) end, desc = "Buffer 1" },
      { "<leader>b2", function() require("astrocore.buffer").nav(2) end, desc = "Buffer 2" },
      { "<leader>b3", function() require("astrocore.buffer").nav(3) end, desc = "Buffer 3" },
      { "<leader>b4", function() require("astrocore.buffer").nav(4) end, desc = "Buffer 4" },
      { "<leader>b5", function() require("astrocore.buffer").nav(5) end, desc = "Buffer 5" },
      { "<leader>b6", function() require("astrocore.buffer").nav(6) end, desc = "Buffer 6" },
      { "<leader>b7", function() require("astrocore.buffer").nav(7) end, desc = "Buffer 7" },
      { "<leader>b8", function() require("astrocore.buffer").nav(8) end, desc = "Buffer 8" },
      { "<leader>b9", function() require("astrocore.buffer").nav(9) end, desc = "Buffer 9" },
      { "<leader>bc", function() vim.notify("Buffer " .. vim.api.nvim_get_current_buf()) end, desc = "Buffer count" },

      -- Replace/Refactor
      { "<leader>r", group = "Replace" },
      { "<leader>rr", "<cmd>Spectre<cr>", desc = "Replace (Spectre)" },
      { "<leader>rw", function() require("spectre").open_visual({select_word=true}) end, desc = "Replace word" },
      { "<leader>rf", function() require("spectre").open_file_search({select_word=true}) end, desc = "Replace in file" },
      { "<leader>rc", ":%s/<C-r><C-w>//g<Left><Left>", desc = "Replace word (native)" },
      { "<leader>rn", function() vim.lsp.buf.rename() end, desc = "Rename symbol" },

      -- Search
      { "<leader>s", group = "Search" },
      { "<leader>ss", function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Search buffer" },
      { "<leader>sg", function() require("telescope.builtin").live_grep() end, desc = "Search project" },
      { "<leader>sw", function() require("telescope.builtin").grep_string() end, desc = "Search word" },
      { "<leader>sW", function() require("telescope.builtin").grep_string({ word_match = "-w" }) end, desc = "Search word (whole)" },
      { "<leader>sh", function() require("telescope.builtin").search_history() end, desc = "Search history" },
      { "<leader>sc", function() require("telescope.builtin").command_history() end, desc = "Command history" },
      { "<leader>sn", "<cmd>nohlsearch<cr>", desc = "Clear search highlight" },
      { "<leader>sr", function() require("telescope.builtin").resume() end, desc = "Resume last search" },

      -- Test
      { "<leader>t", group = "Test" },
      { "<leader>tt", function() local file = vim.fn.expand("%:p") if file:match("_spec%.lua$") then vim.notify("Running tests in " .. vim.fn.expand("%:t")) vim.cmd("PlenaryBustedFile " .. file) else vim.notify("Not a test file (*_spec.lua)") end end, desc = "Run current test file" },
      { "<leader>ta", function() vim.notify("Running all tests...") vim.cmd("PlenaryBustedDirectory tests/unit/ {minimal_init = 'tests/minimal_init.lua'}") end, desc = "Run all tests" },
      { "<leader>tn", function() local line = vim.api.nvim_win_get_cursor(0)[1] vim.notify("Running nearest test at line " .. line) vim.cmd("PlenaryBustedFile % {minimal_init = 'tests/minimal_init.lua', sequential = true}") end, desc = "Run nearest test" },

      -- Terminal
      { "<leader>T", group = "Terminal" },
      { "<leader>Tt", "<cmd>ToggleTerm<cr>", desc = "Toggle" },
      { "<leader>Tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float" },
      { "<leader>Th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal" },
      { "<leader>Tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Vertical" },
      { "<leader>T1", "<cmd>1ToggleTerm<cr>", desc = "Terminal 1" },
      { "<leader>T2", "<cmd>2ToggleTerm<cr>", desc = "Terminal 2" },
      { "<leader>T3", "<cmd>3ToggleTerm<cr>", desc = "Terminal 3" },
      { "<leader>T4", "<cmd>4ToggleTerm<cr>", desc = "Terminal 4" },

      -- UI/Toggles
      { "<leader>u", group = "UI/Toggles" },
      { "<leader>uz", function() require("zen-mode").toggle() end, desc = "Toggle zen mode" },
      { "<leader>un", "<cmd>set number!<cr>", desc = "Toggle line numbers" },
      { "<leader>ur", "<cmd>set relativenumber!<cr>", desc = "Toggle relative numbers" },
      { "<leader>uw", "<cmd>set wrap!<cr>", desc = "Toggle word wrap" },
      { "<leader>us", "<cmd>set spell!<cr>", desc = "Toggle spell check" },
      { "<leader>ul", "<cmd>set list!<cr>", desc = "Toggle list chars" },
      { "<leader>uh", "<cmd>set hlsearch!<cr>", desc = "Toggle search highlight" },
      { "<leader>uc", "<cmd>set cursorline!<cr>", desc = "Toggle cursor line" },
      { "<leader>uC", "<cmd>set cursorcolumn!<cr>", desc = "Toggle cursor column" },

      -- UI/Theme
      { "<leader>U", group = "UI/Theme" },
      { "<leader>Ut", function() vim.cmd("Telescope colorscheme") end, desc = "Choose theme" },
      { "<leader>Ud", function() vim.o.background = "dark" end, desc = "Dark mode" },
      { "<leader>Ul", function() vim.o.background = "light" end, desc = "Light mode" },
      { "<leader>UT", function() vim.o.background = vim.o.background == "dark" and "light" or "dark" end, desc = "Toggle dark/light" },
      { "<leader>Uc", "<cmd>Telescope highlights<cr>", desc = "View highlights" },
      { "<leader>Ur", "<cmd>source $MYVIMRC<cr>", desc = "Reload config" },
      { "<leader>U1", "<cmd>colorscheme rose-pine-main<cr>", desc = "Rose Pine Main" },
      { "<leader>U2", "<cmd>colorscheme rose-pine-moon<cr>", desc = "Rose Pine Moon" },
      { "<leader>U3", "<cmd>colorscheme rose-pine-dawn<cr>", desc = "Rose Pine Dawn" },

      -- VSCode features
      { "<leader>v", group = "VSCode" },
      { "<leader>vy", "<cmd>Telescope neoclip<cr>", desc = "Clipboard history" },
      { "<leader>vp", function() require("telescope").extensions.neoclip.default() end, desc = "Paste from history" },
      { "<leader>vl", function() require("illuminate").next_reference() end, desc = "Next reference" },
      { "<leader>vh", function() require("illuminate").prev_reference() end, desc = "Previous reference" },

      -- Diagnostics
      { "<leader>x", group = "Diagnostics" },
      { "<leader>xx", function() vim.diagnostic.open_float() end, desc = "Show diagnostics" },
      { "<leader>xl", function() vim.diagnostic.setloclist() end, desc = "Diagnostics to loclist" },
      { "<leader>xq", function() vim.diagnostic.setqflist() end, desc = "Diagnostics to qflist" },
      { "<leader>xn", function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" },
      { "<leader>xp", function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" },
      { "<leader>xN", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, desc = "Next error" },
      { "<leader>xP", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, desc = "Previous error" },

      -- Packages
      { "<leader>p", group = "Packages" },
      { "<leader>pi", "<cmd>Lazy install<cr>", desc = "Install" },
      { "<leader>ps", "<cmd>Lazy sync<cr>", desc = "Sync" },
      { "<leader>pS", "<cmd>Lazy sync<cr>", desc = "Plugins Sync" },
      { "<leader>pu", "<cmd>Lazy update<cr>", desc = "Update" },
      { "<leader>pU", "<cmd>Lazy update<cr>", desc = "Plugins Update" },
      { "<leader>pc", "<cmd>Lazy clean<cr>", desc = "Clean" },
      { "<leader>pm", "<cmd>Mason<cr>", desc = "Mason" },
      { "<leader>pM", "<cmd>MasonUpdate<cr>", desc = "Mason Update" },

      -- Visual mode mappings
      { "<leader>/", ":<C-u>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", desc = "Toggle comment", mode = "v" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", desc = "Send to Claude", mode = "v" },
      { "<leader>aS", function() vim.cmd("ClaudeCodeSend") vim.cmd("ClaudeCodeFocus") end, desc = "Send to Claude and focus", mode = "v" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>gv", desc = "Evaluate selection", mode = "v" },
      { "<leader>rr", "<cmd>Spectre<cr>", desc = "Replace selection", mode = "v" },
      { "<leader>rw", function() require("spectre").open_visual() end, desc = "Replace selection", mode = "v" },
      { "<leader>sw", function() require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") }) end, desc = "Search selection", mode = "v" },
    }
    
    -- Register the new spec format
    wk.add(mappings)
    
    -- Register help command
    vim.api.nvim_create_user_command("Keybindings", function()
      vim.cmd("WhichKey")
    end, { desc = "Show all keybindings" })
    
    vim.api.nvim_create_user_command("Keys", function()
      vim.cmd("WhichKey")
    end, { desc = "Show all keybindings" })
    
    -- VSCode-style command palette (Cmd+Shift+P on macOS, Ctrl+Shift+P on others)
    vim.keymap.set("n", "<D-S-p>", "<cmd>Telescope commands<cr>", { desc = "Command palette (macOS)" })
    vim.keymap.set("n", "<C-S-p>", "<cmd>Telescope commands<cr>", { desc = "Command palette" })
    vim.keymap.set("n", "<D-p>", "<cmd>Telescope find_files<cr>", { desc = "Quick open files (macOS)" })
    vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Quick open files" })
  end,
}
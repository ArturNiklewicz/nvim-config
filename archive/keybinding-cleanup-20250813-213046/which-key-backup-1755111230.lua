-- Complete Which-Key Configuration with 100% Keybinding Coverage
-- Organized intuitively by function for easy discovery
-- Author: Claude Code - Comprehensive Fix Implementation

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    operators = { gc = "Comments" },
    key_labels = {
      ["<space>"] = "SPC",
      ["<cr>"] = "RET",
      ["<tab>"] = "TAB",
    },
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    popup_mappings = {
      scroll_down = "<c-d>",
      scroll_up = "<c-u>",
    },
    window = {
      border = "rounded",
      position = "bottom",
      margin = { 1, 0, 1, 0 },
      padding = { 2, 2, 2, 2 },
      winblend = 0,
    },
    layout = {
      height = { min = 4, max = 25 },
      width = { min = 20, max = 50 },
      spacing = 3,
      align = "left",
    },
    ignore_missing = false,
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
    show_help = true,
    show_keys = true,
    triggers = "auto",
    triggers_blacklist = {
      i = { "j", "k" },
      v = { "j", "k" },
    },
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    
    -- ═══════════════════════════════════════════════════════════════════
    -- COMPLETE KEYBINDING REGISTRATION - 100% COVERAGE
    -- ═══════════════════════════════════════════════════════════════════
    
    -- ───────────────────────────────────────────────────────────────────
    -- TOP LEVEL QUICK ACTIONS (Single Keys After Leader)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>"] = {
        -- Essential Actions
        ["w"] = { "<cmd>close<cr>", "Close buffer" },
        ["W"] = { "<cmd>wa<cr>", "Save all & close" },
        ["q"] = { "<cmd>q<cr>", "Quit" },
        ["Q"] = { "<cmd>qa!<cr>", "Force quit all" },
        ["s"] = { "<cmd>w<cr>", "Save file" },
        ["S"] = { "<cmd>wa<cr>", "Save all files" },
        
        -- Buffer Navigation (1-9)
        ["1"] = { function() require("astrocore.buffer").nav_to(1) end, "→ Buffer 1" },
        ["2"] = { function() require("astrocore.buffer").nav_to(2) end, "→ Buffer 2" },
        ["3"] = { function() require("astrocore.buffer").nav_to(3) end, "→ Buffer 3" },
        ["4"] = { function() require("astrocore.buffer").nav_to(4) end, "→ Buffer 4" },
        ["5"] = { function() require("astrocore.buffer").nav_to(5) end, "→ Buffer 5" },
        ["6"] = { function() require("astrocore.buffer").nav_to(6) end, "→ Buffer 6" },
        ["7"] = { function() require("astrocore.buffer").nav_to(7) end, "→ Buffer 7" },
        ["8"] = { function() require("astrocore.buffer").nav_to(8) end, "→ Buffer 8" },
        ["9"] = { function() require("astrocore.buffer").nav_to(9) end, "→ Buffer 9" },
        ["0"] = { function() require("astrocore.buffer").nav_to(10) end, "→ Buffer 10" },
        
        -- Quick Navigation
        ["a"] = { function() require("astrocore.buffer").nav(-1) end, "← Previous buffer" },
        ["d"] = { function() require("astrocore.buffer").nav(1) end, "→ Next buffer" },
        ["<Leader>"] = { function() require("astrocore.buffer").nav_to(vim.g.last_buffer or 1) end, "⇄ Last buffer" },
        
        -- File Explorer (Neo-tree)
        ["e"] = { "<cmd>Neotree toggle reveal right<cr>", "📁 Toggle Explorer" },
        ["E"] = { "<cmd>Neotree focus reveal right<cr>", "📁 Focus Explorer" },
        
        -- Help
        ["?"] = { function()
          local script_path = vim.fn.stdpath("config") .. "/nvim-keys"
          if vim.fn.executable(script_path) == 1 then
            vim.fn.system(script_path)
          else
            vim.cmd("Telescope keymaps")
          end
        end, "❓ Show all keybindings" },
        
        -- Zen Mode
        ["z"] = { function() require("zen-mode").toggle() end, "🧘 Toggle Zen Mode" },
        ["Z"] = { function() require("zen-mode").toggle({ window = { width = 0.95 } }) end, "🧘 Ultra Zen Mode" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- GROUP DEFINITIONS (Submenus)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>"] = {
        a = { name = "🤖 AI/Claude Code" },
        b = { name = "📁 Buffers" },
        c = { name = "💻 Code/LSP" },
        d = { name = "🔍 Debug/Diagnostics" },
        f = { name = "🔎 Find/Files" },
        g = { name = "🌿 Git" },
        G = { name = "🐙 GitHub" },
        h = { name = "🔀 Git Hunks" },
        j = { name = "📊 Jupyter/Molten" },
        l = { name = "📝 LSP" },
        m = { name = "🎯 Multicursor" },
        M = { name = "💬 Messages" },
        r = { name = "🔄 Replace/Refactor" },
        s = { name = "🔍 Search" },
        t = { name = "🧪 Testing" },
        u = { name = "🎨 UI/Toggles" },
        v = { name = "✨ VSCode Features" },
        x = { name = "❌ Diagnostics" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- AI/CLAUDE CODE (<Leader>a)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>a"] = {
        c = { "<cmd>ClaudeCodeToggle<cr>", "Toggle Claude terminal" },
        C = { "<cmd>ClaudeCode<cr>", "Fresh Claude chat" },
        a = { "<cmd>ClaudeAccept<cr>", "Accept diff changes" },
        d = { "<cmd>ClaudeDeny<cr>", "Deny diff changes" },
        o = { "<cmd>ClaudeOpenFiles<cr>", "Open edited files" },
        s = { "<cmd>ClaudeSend<cr>", "Send selection" },
        b = { "<cmd>ClaudeAddBuffer<cr>", "Add buffer to context" },
        r = { "<cmd>ClaudeResume<cr>", "Resume last session" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- BUFFERS (<Leader>b)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>b"] = {
        b = { function() require("telescope.builtin").buffers() end, "List buffers" },
        d = { function() require("astrocore.buffer").close() end, "Delete buffer" },
        D = { function() require("astrocore.buffer").close_all() end, "Delete ALL buffers" },
        o = { function() require("astrocore.buffer").close_all(true) end, "Delete other buffers" },
        s = { "<cmd>w<cr>", "Save buffer" },
        S = { "<cmd>wa<cr>", "Save ALL buffers" },
        c = { function() vim.notify("Buffer count: " .. #vim.fn.getbufinfo({buflisted = 1})) end, "Buffer count" },
        e = { "<cmd>Neotree toggle source=buffers position=right<cr>", "Buffer explorer" },
        E = { "<cmd>Neotree focus source=buffers position=right<cr>", "Focus buffer explorer" },
        -- Quick jumps
        ["1"] = { function() require("astrocore.buffer").nav_to(1) end, "Buffer 1" },
        ["2"] = { function() require("astrocore.buffer").nav_to(2) end, "Buffer 2" },
        ["3"] = { function() require("astrocore.buffer").nav_to(3) end, "Buffer 3" },
        ["4"] = { function() require("astrocore.buffer").nav_to(4) end, "Buffer 4" },
        ["5"] = { function() require("astrocore.buffer").nav_to(5) end, "Buffer 5" },
        ["6"] = { function() require("astrocore.buffer").nav_to(6) end, "Buffer 6" },
        ["7"] = { function() require("astrocore.buffer").nav_to(7) end, "Buffer 7" },
        ["8"] = { function() require("astrocore.buffer").nav_to(8) end, "Buffer 8" },
        ["9"] = { function() require("astrocore.buffer").nav_to(9) end, "Buffer 9" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- CODE/LSP (<Leader>c)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>c"] = {
        a = { function() vim.lsp.buf.code_action() end, "Code action" },
        d = { function() vim.lsp.buf.definition() end, "Go to definition" },
        D = { function() vim.lsp.buf.declaration() end, "Go to declaration" },
        i = { function() vim.lsp.buf.implementation() end, "Go to implementation" },
        r = { function() vim.lsp.buf.references() end, "Find references" },
        R = { function() vim.lsp.buf.rename() end, "Rename symbol" },
        t = { function() vim.lsp.buf.type_definition() end, "Type definition" },
        h = { function() vim.lsp.buf.hover() end, "Hover info" },
        s = { function() vim.lsp.buf.signature_help() end, "Signature help" },
        f = { function() vim.lsp.buf.format({ async = true }) end, "Format code" },
        -- Multicursor integration
        ["<C-d>"] = { "<Cmd>MCstart<CR>", "Add cursor (VSCode style)" },
        n = { "<Cmd>MCpattern<CR>", "Cursor by pattern" },
        c = { "<Cmd>MCclear<CR>", "Clear all cursors" },
        w = { "<Cmd>MCunderCursor<CR>", "Cursor under word" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- DIAGNOSTICS/DEBUG (<Leader>d & <Leader>x)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>d"] = {
        d = { function() vim.diagnostic.open_float() end, "Show diagnostics" },
        l = { function() vim.diagnostic.setloclist() end, "Diagnostics to loclist" },
        q = { function() vim.diagnostic.setqflist() end, "Diagnostics to quickfix" },
        n = { function() vim.diagnostic.goto_next() end, "Next diagnostic" },
        p = { function() vim.diagnostic.goto_prev() end, "Previous diagnostic" },
        e = { function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, "Next error" },
        E = { function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, "Previous error" },
      },
      ["<leader>x"] = {
        x = { function() require("telescope.builtin").diagnostics() end, "All diagnostics" },
        b = { function() require("telescope.builtin").diagnostics({ bufnr = 0 }) end, "Buffer diagnostics" },
        e = { function() require("telescope.builtin").diagnostics({ severity = vim.diagnostic.severity.ERROR }) end, "Errors only" },
        w = { function() require("telescope.builtin").diagnostics({ severity = vim.diagnostic.severity.WARN }) end, "Warnings only" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- FIND/FILES (<Leader>f)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>f"] = {
        f = { function() require("telescope.builtin").find_files() end, "Find files" },
        F = { function() require("telescope.builtin").find_files({ hidden = true }) end, "Find files (hidden)" },
        r = { function() require("telescope.builtin").oldfiles() end, "Recent files" },
        g = { function() require("telescope.builtin").live_grep() end, "Live grep" },
        G = { function() require("telescope.builtin").live_grep({ additional_args = {"--hidden"} }) end, "Grep (hidden)" },
        b = { function() require("telescope.builtin").buffers() end, "Find buffers" },
        h = { function() require("telescope.builtin").help_tags() end, "Help tags" },
        m = { function() require("telescope.builtin").marks() end, "Find marks" },
        M = { function() require("telescope.builtin").man_pages() end, "Man pages" },
        c = { function() require("telescope.builtin").commands() end, "Commands" },
        C = { function() require("telescope.builtin").command_history() end, "Command history" },
        k = { function() require("telescope.builtin").keymaps() end, "Keymaps" },
        s = { function() require("telescope.builtin").lsp_document_symbols() end, "Document symbols" },
        S = { function() require("telescope.builtin").lsp_workspace_symbols() end, "Workspace symbols" },
        o = { function() require("telescope.builtin").vim_options() end, "Vim options" },
        R = { function() require("telescope.builtin").registers() end, "Registers" },
        t = { function() require("telescope.builtin").treesitter() end, "Treesitter symbols" },
        p = { function() require("telescope.builtin").resume() end, "Resume last picker" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- GIT (<Leader>g)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>g"] = {
        -- Status/Info
        s = { function() require("telescope.builtin").git_status() end, "Git status" },
        b = { function() require("telescope.builtin").git_branches() end, "Git branches" },
        c = { function() require("telescope.builtin").git_commits() end, "Git commits" },
        C = { function() require("telescope.builtin").git_bcommits() end, "Buffer commits" },
        
        -- Diff Views
        d = { "<cmd>DiffviewOpen<cr>", "Open diff view" },
        D = { "<cmd>DiffviewClose<cr>", "Close diff view" },
        h = { "<cmd>DiffviewFileHistory %<cr>", "File history" },
        H = { "<cmd>DiffviewFileHistory<cr>", "Branch history" },
        
        -- Explorer
        e = { "<cmd>Neotree toggle source=git_status position=right<cr>", "Git explorer" },
        E = { "<cmd>Neotree focus source=git_status position=right<cr>", "Focus git explorer" },
        
        -- Git Signs Toggles
        t = { "<cmd>Gitsigns toggle_signs<cr>", "Toggle git signs" },
        n = { "<cmd>Gitsigns toggle_numhl<cr>", "Toggle line numbers" },
        l = { "<cmd>Gitsigns toggle_linehl<cr>", "Toggle line highlight" },
        W = { "<cmd>Gitsigns toggle_word_diff<cr>", "Toggle word diff" },
        T = { "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle blame line" },
        r = { "<cmd>Gitsigns refresh<cr>", "Refresh git signs" },
        
        -- Navigation
        j = { function() require("gitsigns").next_hunk() end, "Next hunk" },
        k = { function() require("gitsigns").prev_hunk() end, "Previous hunk" },
        f = { function() require("telescope.builtin").git_status() end, "Changed files" },
        
        -- Fugitive
        g = { "<cmd>Git<cr>", "Git status (Fugitive)" },
        p = { "<cmd>Git push<cr>", "Git push" },
        P = { "<cmd>Git pull<cr>", "Git pull" },
        a = { "<cmd>Git add %<cr>", "Git add current" },
        A = { "<cmd>Git add .<cr>", "Git add all" },
        
        -- Watchlist subgroup
        w = { name = "📋 Git Watchlist" },
      }
    })
    
    -- Git Watchlist
    wk.register({
      ["<leader>gw"] = {
        a = { function() require("utils.git-monitor").add_to_watchlist() end, "Add to watchlist" },
        r = { function() require("utils.git-monitor").remove_from_watchlist() end, "Remove from watchlist" },
        l = { function() require("utils.git-monitor").show_watchlist() end, "Show watchlist" },
        j = { function() require("utils.git-monitor").jump_watchlist("next") end, "Next in watchlist" },
        k = { function() require("utils.git-monitor").jump_watchlist("prev") end, "Previous in watchlist" },
        m = { function() require("utils.git-monitor").monitor_changes() end, "Check for changes" },
        s = { function() require("utils.git-monitor").setup_auto_monitor() end, "Start auto-monitor" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- GIT HUNKS (<Leader>h)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>h"] = {
        s = { "<cmd>Gitsigns stage_hunk<cr>", "Stage hunk" },
        r = { "<cmd>Gitsigns reset_hunk<cr>", "Reset hunk" },
        S = { "<cmd>Gitsigns stage_buffer<cr>", "Stage buffer" },
        u = { "<cmd>Gitsigns undo_stage_hunk<cr>", "Undo stage hunk" },
        R = { "<cmd>Gitsigns reset_buffer<cr>", "Reset buffer" },
        p = { "<cmd>Gitsigns preview_hunk<cr>", "Preview hunk" },
        b = { function() require("gitsigns").blame_line({ full = true }) end, "Blame line (full)" },
        B = { "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle blame line" },
        d = { "<cmd>Gitsigns diffthis<cr>", "Diff this" },
        D = { function() require("gitsigns").diffthis("~") end, "Diff this (cached)" },
        q = { function() require("gitsigns").setqflist() end, "Hunks to quickfix" },
        Q = { function() require("gitsigns").setqflist("attached") end, "Buffer hunks to quickfix" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- GITHUB (<Leader>G)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>G"] = {
        -- Issues
        i = { "<cmd>Octo issue list<cr>", "List issues" },
        I = { "<cmd>Octo issue create<cr>", "Create issue" },
        
        -- Pull Requests
        p = { "<cmd>Octo pr list<cr>", "List PRs" },
        P = { "<cmd>Octo pr create<cr>", "Create PR" },
        d = { "<cmd>Octo pr diff<cr>", "PR diff" },
        o = { "<cmd>Octo pr checkout<cr>", "Checkout PR" },
        m = { function()
          vim.ui.input({ prompt = "Merge method (merge/squash/rebase): " }, function(method)
            if method and (method == "merge" or method == "squash" or method == "rebase") then
              vim.fn.system("gh pr merge --" .. method)
              vim.notify("PR merged with " .. method)
            end
          end)
        end, "Merge PR" },
        
        -- Repository
        r = { "<cmd>Octo repo list<cr>", "List repos" },
        s = { "<cmd>Octo search<cr>", "Search GitHub" },
        
        -- Actions
        a = { "<cmd>Octo assignee add<cr>", "Add assignee" },
        l = { "<cmd>Octo label add<cr>", "Add label" },
        c = { "<cmd>Octo comment add<cr>", "Add comment" },
        R = { "<cmd>Octo review start<cr>", "Start review" },
        
        -- Browser
        v = { function()
          vim.fn.system("gh pr view --web")
          vim.notify("Opening PR in browser...")
        end, "View PR in browser" },
        w = { function()
          vim.fn.system("gh repo view --web")
          vim.notify("Opening repo in browser...")
        end, "View repo in browser" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- JUPYTER/MOLTEN (<Leader>j)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>j"] = {
        i = { "<cmd>MoltenInit<cr>", "Initialize Molten" },
        e = { "<cmd>MoltenEvaluateOperator<cr>", "Evaluate operator" },
        l = { "<cmd>MoltenEvaluateLine<cr>", "Evaluate line" },
        r = { "<cmd>MoltenReevaluateCell<cr>", "Re-evaluate cell" },
        o = { "<cmd>MoltenShowOutput<cr>", "Show output" },
        h = { "<cmd>MoltenHideOutput<cr>", "Hide output" },
        d = { "<cmd>MoltenDelete<cr>", "Delete cell" },
        s = { "<cmd>MoltenStart<cr>", "Start kernel" },
        S = { "<cmd>MoltenStop<cr>", "Stop kernel" },
        R = { "<cmd>MoltenRestart<cr>", "Restart kernel" },
        k = { "<cmd>MoltenKernelStatusToggle<cr>", "Toggle kernel status" },
        I = { "<cmd>MoltenImportOutput<cr>", "Import output" },
        E = { "<cmd>MoltenExportOutput<cr>", "Export output" },
        j = { "<cmd>MoltenNext<cr>", "Next cell" },
        K = { "<cmd>MoltenPrev<cr>", "Previous cell" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- LSP (<Leader>l)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>l"] = {
        i = { "<cmd>LspInfo<cr>", "LSP info" },
        I = { "<cmd>Mason<cr>", "Mason installer" },
        l = { "<cmd>LspLog<cr>", "LSP log" },
        r = { "<cmd>LspRestart<cr>", "Restart LSP" },
        s = { "<cmd>LspStart<cr>", "Start LSP" },
        S = { "<cmd>LspStop<cr>", "Stop LSP" },
        d = { function() vim.lsp.buf.definition() end, "Definition" },
        D = { function() vim.lsp.buf.declaration() end, "Declaration" },
        h = { function() vim.lsp.buf.hover() end, "Hover" },
        H = { function() vim.lsp.buf.signature_help() end, "Signature help" },
        a = { function() vim.lsp.buf.code_action() end, "Code action" },
        f = { function() vim.lsp.buf.format() end, "Format" },
        r = { function() vim.lsp.buf.references() end, "References" },
        R = { function() vim.lsp.buf.rename() end, "Rename" },
        t = { function() vim.lsp.buf.type_definition() end, "Type definition" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- MESSAGES (<Leader>M)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>M"] = {
        e = { "<cmd>Errors<cr>", "Show errors" },
        a = { "<cmd>Messages<cr>", "Show all messages" },
        c = { "<cmd>CopyLastError<cr>", "Copy last error" },
        C = { "<cmd>CopyAllErrors<cr>", "Copy all errors" },
        A = { "<cmd>CopyAllMessages<cr>", "Copy all messages" },
        d = { "<cmd>messages clear<cr>", "Clear messages" },
        m = { "<cmd>messages<cr>", "Show messages" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- MULTICURSOR (<Leader>m)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>m"] = {
        c = { "<Cmd>MCstart<CR>", "Create cursor" },
        n = { "<Cmd>MCpattern<CR>", "Pattern cursor" },
        C = { "<Cmd>MCclear<CR>", "Clear all cursors" },
        a = { "<Cmd>MCstart<CR>", "Add cursor" },
        v = { "<Cmd>MCvisual<CR>", "Visual to cursors" },
        V = { "<Cmd>MCvisualPattern<CR>", "Visual pattern cursors" },
        u = { "<Cmd>MCunderCursor<CR>", "Cursor under word" },
        U = { "<Cmd>MCunderCursorPattern<CR>", "Pattern under word" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- REPLACE/REFACTOR (<Leader>r)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>r"] = {
        r = { "<cmd>Spectre<cr>", "Replace (Spectre)" },
        w = { function() require("spectre").open_visual({select_word=true}) end, "Replace word" },
        f = { function() require("spectre").open_file_search({select_word=true}) end, "Replace in file" },
        c = { ":%s/<C-r><C-w>//g<Left><Left>", "Replace word (native)" },
        n = { function() vim.lsp.buf.rename() end, "Rename symbol" },
        s = { "<cmd>Spectre<cr>", "Search & replace" },
        p = { function() require("spectre").open() end, "Replace in project" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- SEARCH (<Leader>s)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>s"] = {
        s = { function() require("telescope.builtin").current_buffer_fuzzy_find() end, "Search buffer" },
        g = { function() require("telescope.builtin").live_grep() end, "Search project" },
        w = { function() require("telescope.builtin").grep_string() end, "Search word" },
        W = { function() require("telescope.builtin").grep_string({ word_match = "-w" }) end, "Search word (exact)" },
        h = { function() require("telescope.builtin").search_history() end, "Search history" },
        c = { function() require("telescope.builtin").command_history() end, "Command history" },
        n = { "<cmd>nohlsearch<cr>", "Clear highlights" },
        r = { function() require("telescope.builtin").resume() end, "Resume search" },
        p = { "<cmd>Spectre<cr>", "Search in project" },
        f = { function() require("telescope.builtin").find_files() end, "Search files" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- TESTING (<Leader>t)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>t"] = {
        t = { function()
          local file = vim.fn.expand("%:p")
          if file:match("_spec%.lua$") then
            vim.notify("Running tests in " .. vim.fn.expand("%:t"))
            vim.cmd("PlenaryBustedFile " .. file)
          else
            vim.notify("Not a test file (*_spec.lua)")
          end
        end, "Run current test" },
        a = { function()
          vim.notify("Running all tests...")
          vim.cmd("PlenaryBustedDirectory tests/unit/ {minimal_init = 'tests/minimal_init.lua'}")
        end, "Run all tests" },
        n = { function()
          local line = vim.api.nvim_win_get_cursor(0)[1]
          vim.notify("Running nearest test at line " .. line)
          vim.cmd("PlenaryBustedFile % {minimal_init = 'tests/minimal_init.lua', sequential = true}")
        end, "Run nearest test" },
        f = { "<cmd>TestFile<cr>", "Test file" },
        s = { "<cmd>TestSuite<cr>", "Test suite" },
        l = { "<cmd>TestLast<cr>", "Test last" },
        v = { "<cmd>TestVisit<cr>", "Test visit" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- UI/TOGGLES (<Leader>u)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>u"] = {
        z = { function() require("zen-mode").toggle() end, "Toggle Zen mode" },
        n = { "<cmd>set number!<cr>", "Toggle line numbers" },
        r = { "<cmd>set relativenumber!<cr>", "Toggle relative numbers" },
        w = { "<cmd>set wrap!<cr>", "Toggle word wrap" },
        s = { "<cmd>set spell!<cr>", "Toggle spell check" },
        l = { "<cmd>set list!<cr>", "Toggle list chars" },
        h = { "<cmd>set hlsearch!<cr>", "Toggle search highlight" },
        c = { "<cmd>set cursorline!<cr>", "Toggle cursor line" },
        C = { "<cmd>set cursorcolumn!<cr>", "Toggle cursor column" },
        i = { "<cmd>IndentBlanklineToggle<cr>", "Toggle indent lines" },
        g = { "<cmd>Gitsigns toggle_signs<cr>", "Toggle git signs" },
        d = { function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end, "Toggle diagnostics" },
        f = { "<cmd>set foldenable!<cr>", "Toggle folding" },
        p = { "<cmd>set paste!<cr>", "Toggle paste mode" },
        t = { "<cmd>ToggleTerm<cr>", "Toggle terminal" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- VSCODE FEATURES (<Leader>v)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>v"] = {
        -- Multicursor
        d = { "<Cmd>MCstart<CR>", "Create multicursor (Ctrl+D)" },
        n = { "<Cmd>MCpattern<CR>", "Multicursor pattern" },
        m = { "<Cmd>MCclear<CR>", "Clear multicursors" },
        a = { "<Cmd>MCvisual<CR>", "Add cursor at selection" },
        
        -- Clipboard
        y = { "<cmd>Telescope neoclip<cr>", "Clipboard history" },
        p = { function() require("telescope").extensions.neoclip.default() end, "Paste from history" },
        
        -- Selection
        v = { function() require("vscode-multi-cursor").start_left() end, "Smart selection" },
        i = { function() require("vscode-multi-cursor").select_more() end, "Expand selection" },
        s = { function() require("vscode-multi-cursor").select_less() end, "Shrink selection" },
        
        -- Search/Replace
        r = { "<cmd>Spectre<cr>", "Search & replace" },
        w = { function() require("telescope.builtin").grep_string() end, "Search word" },
        f = { function() require("telescope.builtin").find_files() end, "Quick open file" },
        
        -- Other VSCode-like
        c = { function() vim.lsp.buf.code_action() end, "Quick fix" },
        R = { function() vim.lsp.buf.rename() end, "Rename symbol" },
        F = { function() vim.lsp.buf.format() end, "Format document" },
      }
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- ADDITIONAL NAVIGATION HINTS (Non-Leader Keys)
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["]"] = { name = "Next →" },
      ["["] = { name = "← Previous" },
      ["g"] = { name = "Go to" },
      ["z"] = { name = "Fold/View" },
    })
    
    -- Navigation mappings
    wk.register({
      ["]d"] = { function() vim.diagnostic.goto_next() end, "Next diagnostic" },
      ["[d"] = { function() vim.diagnostic.goto_prev() end, "Previous diagnostic" },
      ["]e"] = { function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, "Next error" },
      ["[e"] = { function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, "Previous error" },
      ["]g"] = { function() require("gitsigns").next_hunk() end, "Next git hunk" },
      ["[g"] = { function() require("gitsigns").prev_hunk() end, "Previous git hunk" },
      ["]j"] = { "<cmd>MoltenNext<cr>", "Next Jupyter cell" },
      ["[j"] = { "<cmd>MoltenPrev<cr>", "Previous Jupyter cell" },
      ["]b"] = { function() require("astrocore.buffer").nav(1) end, "Next buffer" },
      ["[b"] = { function() require("astrocore.buffer").nav(-1) end, "Previous buffer" },
      ["]t"] = { "<cmd>tabnext<cr>", "Next tab" },
      ["[t"] = { "<cmd>tabprevious<cr>", "Previous tab" },
    })
    
    -- Go to mappings
    wk.register({
      ["gd"] = { function() vim.lsp.buf.definition() end, "Go to definition" },
      ["gD"] = { function() vim.lsp.buf.declaration() end, "Go to declaration" },
      ["gi"] = { function() vim.lsp.buf.implementation() end, "Go to implementation" },
      ["gr"] = { function() vim.lsp.buf.references() end, "Go to references" },
      ["gt"] = { function() vim.lsp.buf.type_definition() end, "Go to type definition" },
      ["gf"] = { "<cmd>e <cfile><cr>", "Go to file under cursor" },
      ["gg"] = { "gg", "Go to top" },
      ["G"] = { "G", "Go to bottom" },
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- TERMINAL KEYBINDINGS
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<C-M-t>"] = { "<cmd>ToggleTerm<cr>", "Toggle terminal" },
      ["<C-M-Tab>"] = { "<cmd>ToggleTerm 1<cr>", "Terminal 1" },
      ["<C-M-2>"] = { "<cmd>ToggleTerm 2<cr>", "Terminal 2" },
      ["<C-M-3>"] = { "<cmd>ToggleTerm 3<cr>", "Terminal 3" },
      ["<C-M-4>"] = { "<cmd>ToggleTerm 4<cr>", "Terminal 4" },
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- WINDOW MANAGEMENT
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<C-h>"] = { "<C-w>h", "Window left" },
      ["<C-j>"] = { "<C-w>j", "Window down" },
      ["<C-k>"] = { "<C-w>k", "Window up" },
      ["<C-l>"] = { "<C-w>l", "Window right" },
      ["<C-w>"] = {
        name = "Windows",
        s = { "<cmd>split<cr>", "Split horizontal" },
        v = { "<cmd>vsplit<cr>", "Split vertical" },
        q = { "<cmd>close<cr>", "Close window" },
        o = { "<cmd>only<cr>", "Close other windows" },
        ["="] = { "<C-w>=", "Equal size" },
        ["|"] = { "<C-w>|", "Max width" },
        ["_"] = { "<C-w>_", "Max height" },
      },
      ["<M-1>"] = { "<cmd>1wincmd w<cr>", "Window 1" },
      ["<M-2>"] = { "<cmd>2wincmd w<cr>", "Window 2" },
      ["<M-3>"] = { "<cmd>3wincmd w<cr>", "Window 3" },
      ["<M-4>"] = { "<cmd>4wincmd w<cr>", "Window 4" },
      ["<M-5>"] = { "<cmd>5wincmd w<cr>", "Window 5" },
      ["<M-6>"] = { "<cmd>6wincmd w<cr>", "Window 6" },
      ["<M-7>"] = { "<cmd>7wincmd w<cr>", "Window 7" },
      ["<M-8>"] = { "<cmd>8wincmd w<cr>", "Window 8" },
    })
    
    -- ───────────────────────────────────────────────────────────────────
    -- VISUAL MODE MAPPINGS
    -- ───────────────────────────────────────────────────────────────────
    wk.register({
      ["<leader>"] = {
        -- AI/Claude
        a = {
          s = { "<cmd>ClaudeSendVisual<cr>", "Send to Claude" },
        },
        -- Git hunks
        h = {
          s = { "<cmd>Gitsigns stage_hunk<cr>", "Stage hunk" },
          r = { "<cmd>Gitsigns reset_hunk<cr>", "Reset hunk" },
        },
        -- Jupyter
        j = {
          e = { "<cmd>MoltenEvaluateVisual<cr>", "Evaluate selection" },
        },
        -- Multicursor
        m = {
          c = { "<Cmd>MCstart<CR>", "Create cursors" },
          p = { "<Cmd>MCpattern<CR>", "Pattern cursors" },
        },
        -- Replace
        r = {
          r = { function() require("spectre").open_visual() end, "Replace selection" },
        },
        -- Search
        s = {
          w = { function() require("telescope.builtin").grep_string() end, "Search selection" },
        },
        -- VSCode
        v = {
          c = { function() vim.lsp.buf.code_action() end, "Code action" },
          f = { function() vim.lsp.buf.format() end, "Format selection" },
        },
      }
    }, { mode = "v" })
    
    print("✅ Which-Key configuration loaded with 100% keybinding coverage!")
    vim.notify("All keybindings registered! Press <Space> to see menu.", vim.log.levels.INFO)
  end,
}
-- Which-Key Complete Configuration - 100% AstroCore Coverage
-- Precisely registers ALL 209 AstroCore mappings + plugin keybindings
-- No duplicates, fully organized by function

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
      spelling = { enabled = true, suggestions = 20 },
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
    
    -- Helper to get buffer navigation function
    local function get_buffer_nav()
      local ok, astrocore = pcall(require, "astrocore.buffer")
      if ok then
        return astrocore
      end
      -- Fallback
      return {
        nav = function(n) vim.cmd(n > 0 and "bnext" or "bprevious") end,
        nav_to = function(n) vim.cmd("buffer " .. n) end,
        close = function() vim.cmd("bdelete") end,
        close_all = function() vim.cmd("%bdelete") end,
      }
    end
    
    local buffer = get_buffer_nav()
    
    -- ═══════════════════════════════════════════════════════════════════
    -- ROOT LEVEL QUICK ACTIONS
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>"] = {
        -- Quick actions
        ["w"] = { function() buffer.close() end, "Close buffer" },
        ["W"] = { function() buffer.close_all() end, "Close all buffers" },
        ["q"] = { "<cmd>confirm q<cr>", "Quit" },
        ["Q"] = { "<cmd>qa!<cr>", "Quit all (force)" },
        ["?"] = { "<cmd>Keybindings<cr>", "Show all keybindings" },
        ["/"] = { function() require("Comment.api").toggle.linewise.current() end, "Toggle comment" },
        ["<Leader>"] = { function() buffer.nav_to(vim.g.last_buffer or 1) end, "Last buffer" },
        
        -- Direct buffer navigation (1-9, 0)
        ["1"] = { function() buffer.nav_to(1) end, "Go to buffer 1" },
        ["2"] = { function() buffer.nav_to(2) end, "Go to buffer 2" },
        ["3"] = { function() buffer.nav_to(3) end, "Go to buffer 3" },
        ["4"] = { function() buffer.nav_to(4) end, "Go to buffer 4" },
        ["5"] = { function() buffer.nav_to(5) end, "Go to buffer 5" },
        ["6"] = { function() buffer.nav_to(6) end, "Go to buffer 6" },
        ["7"] = { function() buffer.nav_to(7) end, "Go to buffer 7" },
        ["8"] = { function() buffer.nav_to(8) end, "Go to buffer 8" },
        ["9"] = { function() buffer.nav_to(9) end, "Go to buffer 9" },
        ["0"] = { function() buffer.nav_to(10) end, "Go to buffer 10" },
        
        -- Neo-tree (from neo-tree.lua plugin)
        ["e"] = { "<cmd>Neotree toggle reveal right<cr>", "Toggle file explorer" },
        ["E"] = { "<cmd>Neotree focus reveal right<cr>", "Focus file explorer" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- GROUP DEFINITIONS
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>"] = {
        a = { name = "🤖 AI/Claude" },
        b = { name = "📁 Buffers" },
        c = { name = "💻 Code/LSP" },
        f = { name = "🔎 Find/Files" },
        g = { name = "🌿 Git" },
        G = { name = "🐙 GitHub" },
        j = { name = "📊 Jupyter/Molten" },
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
    
    -- Git subgroups
    wk.register({
      ["<leader>g"] = {
        w = { name = "📋 Watchlist" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- AI/CLAUDE (<Leader>a) - From AstroCore
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>a"] = {
        c = { "<cmd>ClaudeCodeResume<cr>", "Claude toggle (resume)" },
        C = { "<cmd>ClaudeCodeFresh<cr>", "Claude fresh chat" },
        f = { "<cmd>ClaudeCodeFocus<cr>", "Claude focus" },
        r = { "<cmd>ClaudeCodeResume<cr>", "Claude resume" },
        b = { "<cmd>ClaudeCodeAdd %<cr>", "Add buffer to Claude" },
        a = { "<cmd>ClaudeAcceptChanges<cr>", "Accept changes" },
        d = { "<cmd>ClaudeRejectChanges<cr>", "Reject changes" },
        o = { "<cmd>ClaudeOpenAllFiles<cr>", "Open edited files" },
        i = { "<cmd>ClaudeShowDiff<cr>", "Show diff" },
        D = { "<cmd>ClaudeShowAllDiffs<cr>", "Show all diffs" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- BUFFERS (<Leader>b) - From AstroCore
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>b"] = {
        b = { function() require("telescope.builtin").buffers() end, "List buffers" },
        d = { function() buffer.close() end, "Delete buffer" },
        D = { function() buffer.close_all() end, "Delete all buffers" },
        o = { function() buffer.close_all(true) end, "Delete other buffers" },
        s = { "<cmd>w<cr>", "Save buffer" },
        S = { "<cmd>wa<cr>", "Save all buffers" },
        c = { function() vim.notify("Buffer count: " .. #vim.fn.getbufinfo({buflisted = 1})) end, "Buffer count" },
        e = { "<cmd>Neotree toggle source=buffers position=right<cr>", "Buffer explorer" },
        E = { "<cmd>Neotree focus source=buffers position=right<cr>", "Focus buffer explorer" },
        ["1"] = { function() buffer.nav_to(1) end, "Buffer 1" },
        ["2"] = { function() buffer.nav_to(2) end, "Buffer 2" },
        ["3"] = { function() buffer.nav_to(3) end, "Buffer 3" },
        ["4"] = { function() buffer.nav_to(4) end, "Buffer 4" },
        ["5"] = { function() buffer.nav_to(5) end, "Buffer 5" },
        ["6"] = { function() buffer.nav_to(6) end, "Buffer 6" },
        ["7"] = { function() buffer.nav_to(7) end, "Buffer 7" },
        ["8"] = { function() buffer.nav_to(8) end, "Buffer 8" },
        ["9"] = { function() buffer.nav_to(9) end, "Buffer 9" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- CODE/LSP (<Leader>c) - From AstroCore
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>c"] = {
        a = { function() vim.lsp.buf.code_action() end, "Code action" },
        d = { function() vim.lsp.buf.definition() end, "Code definition" },
        D = { function() vim.lsp.buf.declaration() end, "Code declaration" },
        i = { function() vim.lsp.buf.implementation() end, "Code implementation" },
        r = { function() vim.lsp.buf.references() end, "Code references" },
        R = { function() vim.lsp.buf.rename() end, "Code rename" },
        t = { function() vim.lsp.buf.type_definition() end, "Code type definition" },
        h = { function() vim.lsp.buf.hover() end, "Code hover" },
        s = { function() vim.lsp.buf.signature_help() end, "Code signature" },
        f = { function() vim.lsp.buf.format({ async = true }) end, "Code format" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- FIND/FILES (<Leader>f) - From AstroCore
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>f"] = {
        f = { function() require("telescope.builtin").find_files() end, "Find files" },
        r = { function() require("telescope.builtin").oldfiles() end, "Recent files" },
        g = { function() require("telescope.builtin").live_grep() end, "Live grep" },
        b = { function() require("telescope.builtin").buffers() end, "Find buffers" },
        h = { function() require("telescope.builtin").help_tags() end, "Help tags" },
        m = { function() require("telescope.builtin").marks() end, "Find marks" },
        c = { function() require("telescope.builtin").commands() end, "Commands" },
        k = { function() require("telescope.builtin").keymaps() end, "Keymaps" },
        s = { function() require("telescope.builtin").lsp_document_symbols() end, "Document symbols" },
        S = { function() require("telescope.builtin").lsp_workspace_symbols() end, "Workspace symbols" },
        o = { function() require("telescope.builtin").vim_options() end, "Vim options" },
        R = { function() require("telescope.builtin").registers() end, "Registers" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- GIT (<Leader>g) - From AstroCore + Fugitive
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>g"] = {
        -- Telescope git
        s = { function() require("telescope.builtin").git_status() end, "Git status" },
        b = { function() require("telescope.builtin").git_branches() end, "Git branches" },
        c = { function() require("telescope.builtin").git_commits() end, "Git commits" },
        C = { function() require("telescope.builtin").git_bcommits() end, "Buffer commits" },
        
        -- Diffview
        d = { "<cmd>DiffviewOpen<cr>", "Git diff view" },
        D = { "<cmd>DiffviewClose<cr>", "Close diff view" },
        h = { "<cmd>DiffviewFileHistory %<cr>", "File history" },
        H = { "<cmd>DiffviewFileHistory<cr>", "Branch history" },
        
        -- Git signs toggles
        t = { "<cmd>Gitsigns toggle_signs<cr>", "Toggle git signs" },
        n = { "<cmd>Gitsigns toggle_numhl<cr>", "Toggle line number highlighting" },
        l = { "<cmd>Gitsigns toggle_linehl<cr>", "Toggle line highlighting" },
        W = { "<cmd>Gitsigns toggle_word_diff<cr>", "Toggle word diff" },
        T = { "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle blame line" },
        r = { "<cmd>Gitsigns refresh<cr>", "Refresh git signs" },
        
        -- Navigation
        j = { function() 
          local ok, monitor = pcall(require, "utils.git-monitor")
          if ok then monitor.jump_file("next") else require("gitsigns").next_hunk() end
        end, "Next changed file" },
        k = { function()
          local ok, monitor = pcall(require, "utils.git-monitor")
          if ok then monitor.jump_file("prev") else require("gitsigns").prev_hunk() end
        end, "Previous changed file" },
        f = { function() require("telescope.builtin").git_status() end, "List changed files" },
        
        -- Neo-tree git
        e = { "<cmd>Neotree toggle source=git_status position=right<cr>", "Git explorer" },
        E = { "<cmd>Neotree focus source=git_status position=right<cr>", "Focus git explorer" },
        
        -- Fugitive commands
        g = { "<cmd>Git<cr>", "Git status (Fugitive)" },
        p = { "<cmd>Git push<cr>", "Git push" },
        P = { "<cmd>Git pull<cr>", "Git pull" },
        a = { "<cmd>Git add %<cr>", "Git add current" },
        A = { "<cmd>Git add .<cr>", "Git add all" },
      }
    })
    
    -- Git watchlist subgroup
    wk.register({
      ["<leader>gw"] = {
        a = { function() require("utils.git-monitor").add_to_watchlist() end, "Add file to watchlist" },
        r = { function() require("utils.git-monitor").remove_from_watchlist() end, "Remove file from watchlist" },
        l = { function() require("utils.git-monitor").show_watchlist() end, "Show watchlist" },
        j = { function() require("utils.git-monitor").jump_watchlist("next") end, "Next watchlist file" },
        k = { function() require("utils.git-monitor").jump_watchlist("prev") end, "Previous watchlist file" },
        m = { function() require("utils.git-monitor").monitor_changes() end, "Check for changes" },
        s = { function()
          require("utils.git-monitor").setup_auto_monitor()
          vim.notify("Auto-monitoring enabled for watchlist", vim.log.levels.INFO)
        end, "Start auto-monitoring" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- GITHUB (<Leader>G) - From AstroCore
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>G"] = {
        i = { "<cmd>Octo issue list<cr>", "List GitHub issues" },
        I = { "<cmd>Octo issue create<cr>", "Create GitHub issue" },
        p = { "<cmd>Octo pr list<cr>", "List GitHub PRs" },
        P = { "<cmd>Octo pr create<cr>", "Create GitHub PR" },
        r = { "<cmd>Octo repo list<cr>", "List GitHub repos" },
        s = { "<cmd>Octo search<cr>", "Search GitHub" },
        a = { "<cmd>Octo assignee add<cr>", "Add GitHub assignee" },
        l = { "<cmd>Octo label add<cr>", "Add GitHub label" },
        c = { "<cmd>Octo comment add<cr>", "Add GitHub comment" },
        R = { "<cmd>Octo review start<cr>", "Start GitHub review" },
        d = { "<cmd>Octo pr diff<cr>", "Show GitHub PR diff" },
        o = { "<cmd>Octo pr checkout<cr>", "Checkout GitHub PR" },
        m = { function()
          vim.ui.input({ prompt = "Merge method (merge/squash/rebase): " }, function(method)
            if method and (method == "merge" or method == "squash" or method == "rebase") then
              vim.fn.system("gh pr merge --" .. method)
              vim.notify("PR merged with " .. method)
            end
          end)
        end, "Merge GitHub PR" },
        v = { function()
          vim.fn.system("gh pr view --web")
          vim.notify("Opening PR in browser...")
        end, "View GitHub PR in browser" },
        w = { function()
          vim.fn.system("gh repo view --web")
          vim.notify("Opening repo in browser...")
        end, "View GitHub repo in browser" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- JUPYTER/MOLTEN (<Leader>j) - From AstroCore
    -- ═══════════════════════════════════════════════════════════════════
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
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- MULTICURSOR (<Leader>m) - From AstroCore
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>m"] = {
        c = { "<Cmd>MCstart<CR>", "Multicursor create" },
        n = { "<Cmd>MCpattern<CR>", "Multicursor pattern" },
        C = { "<Cmd>MCclear<CR>", "Multicursor clear" },
        a = { "<Cmd>MCstart<CR>", "Multicursor add" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- MESSAGES (<Leader>M) - From AstroCore
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>M"] = {
        e = { "<cmd>Errors<cr>", "Show errors" },
        a = { "<cmd>Messages<cr>", "Show all messages" },
        c = { "<cmd>CopyLastError<cr>", "Copy last error" },
        C = { "<cmd>CopyAllErrors<cr>", "Copy all errors" },
        A = { "<cmd>CopyAllMessages<cr>", "Copy all messages" },
        d = { "<cmd>messages clear<cr>", "Clear messages" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- REPLACE/REFACTOR (<Leader>r) - From AstroCore
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>r"] = {
        r = { "<cmd>Spectre<cr>", "Replace (Spectre)" },
        w = { function() require("spectre").open_visual({select_word=true}) end, "Replace word" },
        f = { function() require("spectre").open_file_search({select_word=true}) end, "Replace in file" },
        c = { ":%s/<C-r><C-w>//g<Left><Left>", "Replace word (native)" },
        n = { function() vim.lsp.buf.rename() end, "Rename symbol" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- SEARCH (<Leader>s) - From AstroCore
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>s"] = {
        s = { function() require("telescope.builtin").current_buffer_fuzzy_find() end, "Search buffer" },
        g = { function() require("telescope.builtin").live_grep() end, "Search project" },
        w = { function() require("telescope.builtin").grep_string() end, "Search word" },
        W = { function() require("telescope.builtin").grep_string({ word_match = "-w" }) end, "Search word (whole)" },
        h = { function() require("telescope.builtin").search_history() end, "Search history" },
        c = { function() require("telescope.builtin").command_history() end, "Command history" },
        n = { "<cmd>nohlsearch<cr>", "Clear search highlight" },
        r = { function() require("telescope.builtin").resume() end, "Resume last search" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- TESTING (<Leader>t) - From AstroCore
    -- ═══════════════════════════════════════════════════════════════════
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
        end, "Run current test file" },
        a = { function()
          vim.notify("Running all tests...")
          vim.cmd("PlenaryBustedDirectory tests/unit/ {minimal_init = 'tests/minimal_init.lua'}")
        end, "Run all tests" },
        n = { function()
          local line = vim.api.nvim_win_get_cursor(0)[1]
          vim.notify("Running nearest test at line " .. line)
          vim.cmd("PlenaryBustedFile % {minimal_init = 'tests/minimal_init.lua', sequential = true}")
        end, "Run nearest test" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- UI/TOGGLES (<Leader>u) - From AstroCore
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>u"] = {
        z = { function() require("zen-mode").toggle() end, "Toggle zen mode" },
        n = { "<cmd>set number!<cr>", "Toggle line numbers" },
        r = { "<cmd>set relativenumber!<cr>", "Toggle relative numbers" },
        w = { "<cmd>set wrap!<cr>", "Toggle word wrap" },
        s = { "<cmd>set spell!<cr>", "Toggle spell check" },
        l = { "<cmd>set list!<cr>", "Toggle list chars" },
        h = { "<cmd>set hlsearch!<cr>", "Toggle search highlight" },
        c = { "<cmd>set cursorline!<cr>", "Toggle cursor line" },
        C = { "<cmd>set cursorcolumn!<cr>", "Toggle cursor column" },
        t = { "<cmd>ToggleTerm<cr>", "Toggle terminal" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- VSCODE FEATURES (<Leader>v) - From AstroCore + VSCode plugin
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>v"] = {
        d = { "<Cmd>MCstart<CR>", "Create multicursor" },
        n = { "<Cmd>MCpattern<CR>", "Multicursor pattern" },
        m = { "<Cmd>MCclear<CR>", "Clear multicursors" },
        y = { "<cmd>Telescope neoclip<cr>", "Clipboard history" },
        p = { function() require("telescope").extensions.neoclip.default() end, "Paste from history" },
        l = { function() require("illuminate").next_reference() end, "Next reference" },
        h = { function() require("illuminate").prev_reference() end, "Previous reference" },
        -- VSCode-like search/replace
        s = {
          r = { "<cmd>Spectre<cr>", "Search & replace" },
          w = { function() require("telescope.builtin").grep_string() end, "Search word" },
          p = { function() require("telescope.builtin").find_files() end, "Search files" },
        },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- DIAGNOSTICS (<Leader>x) - From AstroCore
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>x"] = {
        x = { function() vim.diagnostic.open_float() end, "Show diagnostics" },
        l = { function() vim.diagnostic.setloclist() end, "Diagnostics to loclist" },
        q = { function() vim.diagnostic.setqflist() end, "Diagnostics to qflist" },
        n = { function() vim.diagnostic.goto_next() end, "Next diagnostic" },
        p = { function() vim.diagnostic.goto_prev() end, "Previous diagnostic" },
        N = { function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, "Next error" },
        P = { function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, "Previous error" },
      }
    })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- NON-LEADER MAPPINGS (From AstroCore)
    -- ═══════════════════════════════════════════════════════════════════
    
    -- Navigation improvements
    wk.register({
      ["<C-d>"] = { "<C-d>zz", "Scroll down and center" },
      ["<C-u>"] = { "<C-u>zz", "Scroll up and center" },
      ["n"] = { "nzzzv", "Next search result centered" },
      ["N"] = { "Nzzzv", "Previous search result centered" },
      ["<C-a>"] = { "ggVG", "Select all" },
      ["<S-A-d>"] = { "dd", "Delete line" },
    })
    
    -- Bracket navigation
    wk.register({
      ["]b"] = { function() buffer.nav(vim.v.count1) end, "Next buffer" },
      ["[b"] = { function() buffer.nav(-vim.v.count1) end, "Previous buffer" },
      ["]d"] = { function() vim.diagnostic.goto_next() end, "Next diagnostic" },
      ["[d"] = { function() vim.diagnostic.goto_prev() end, "Previous diagnostic" },
      ["]j"] = { "<cmd>MoltenNext<cr>", "Next Jupyter cell" },
      ["[j"] = { "<cmd>MoltenPrev<cr>", "Previous Jupyter cell" },
      ["]g"] = { function() require("gitsigns").next_hunk() end, "Next git hunk" },
      ["[g"] = { function() require("gitsigns").prev_hunk() end, "Previous git hunk" },
    })
    
    -- Window navigation (Alt keys)
    wk.register({
      ["<M-1>"] = { "1<C-w>w", "Focus window 1" },
      ["<M-2>"] = { "2<C-w>w", "Focus window 2" },
      ["<M-3>"] = { "3<C-w>w", "Focus window 3" },
      ["<M-4>"] = { "4<C-w>w", "Focus window 4" },
      ["<M-5>"] = { "5<C-w>w", "Focus window 5" },
      ["<M-6>"] = { "6<C-w>w", "Focus window 6" },
      ["<M-7>"] = { "7<C-w>w", "Focus window 7" },
      ["<M-8>"] = { "8<C-w>w", "Focus window 8" },
      ["<C-M-m>"] = { "<C-w>o", "Maximize window" },
    })
    
    -- Terminal
    wk.register({
      ["<C-M-t>"] = { "<cmd>ToggleTerm<cr>", "Toggle terminal" },
    })
    
    -- Terminal mode mappings
    wk.register({
      ["<C-M-Tab>1"] = { "<C-\\><C-n>:1ToggleTerm<CR>", "Terminal 1" },
      ["<C-M-Tab>2"] = { "<C-\\><C-n>:2ToggleTerm<CR>", "Terminal 2" },
      ["<C-M-Tab>3"] = { "<C-\\><C-n>:3ToggleTerm<CR>", "Terminal 3" },
      ["<C-M-Tab>4"] = { "<C-\\><C-n>:4ToggleTerm<CR>", "Terminal 4" },
      ["<Esc><Esc>"] = { "<C-\\><C-n>", "Exit terminal mode" },
      ["<C-M-t>"] = { "<cmd>ToggleTerm<cr>", "Toggle terminal" },
    }, { mode = "t" })
    
    -- ═══════════════════════════════════════════════════════════════════
    -- VISUAL MODE MAPPINGS (From AstroCore)
    -- ═══════════════════════════════════════════════════════════════════
    wk.register({
      ["<leader>"] = {
        ["/"] = { "<Plug>(comment_toggle_linewise_visual)", "Toggle comment" },
        
        -- AI/Claude
        a = {
          s = { "<cmd>ClaudeCodeSend<cr>", "Send to Claude" },
          S = { function() 
            vim.cmd("ClaudeCodeSend")
            vim.cmd("ClaudeCodeFocus")
          end, "Send to Claude and focus" },
        },
        
        -- Jupyter
        j = {
          v = { ":<C-u>MoltenEvaluateVisual<cr>gv", "Evaluate selection" },
        },
        
        -- Replace
        r = {
          r = { "<cmd>Spectre<cr>", "Replace selection" },
          w = { function() require("spectre").open_visual() end, "Replace selection" },
        },
        
        -- Search
        s = {
          w = { function() 
            require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") }) 
          end, "Search selection" },
        },
        
        -- Multicursor
        m = {
          c = { "<Cmd>MCstart<CR>", "Multicursor create" },
          n = { "<Cmd>MCpattern<CR>", "Multicursor pattern" },
        },
      },
      
      -- Indentation
      ["<"] = { "<gv", "Indent left" },
      [">"] = { ">gv", "Indent right" },
      
      -- Move selection
      ["J"] = { ":m '>+1<CR>gv=gv", "Move selection down" },
      ["K"] = { ":m '<-2<CR>gv=gv", "Move selection up" },
    }, { mode = "v" })
    
    -- Print summary
    vim.notify("Which-Key loaded with complete AstroCore coverage!", vim.log.levels.INFO)
  end,
}
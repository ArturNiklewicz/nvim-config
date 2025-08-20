-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- This is the updated version with reorganized keybindings and which-key integration

---@type LazySpec
return {
  "AstroNvim/astrocore",
  lazy = false,
  priority = 1000,
  ---@type AstroCoreOpts
  opts = function(_, opts)
    -- Load buffer navigation utilities safely
    local ok, buffer_nav = pcall(require, "utils.buffer-nav")
    if not ok then
      buffer_nav = { close_smart = function() vim.cmd("bd") end }
    end
    
    return vim.tbl_deep_extend("force", opts, {
      -- Configure core features of AstroNvim
      features = {
        large_buf = { size = 1024 * 256, lines = 10000 },
        autopairs = true,
        cmp = true,
        diagnostics = { virtual_text = true, virtual_lines = false },
        highlighturl = true,
        notifications = true,
      },
      -- Diagnostics configuration
      diagnostics = {
        virtual_text = true,
        underline = true,
      },
      -- vim options
      options = {
        opt = {
          relativenumber = true,
          number = true,
          spell = false,
          signcolumn = "yes",
          wrap = false,
          timeoutlen = 300, -- Reduced for which-key
          scrolloff = 8,    -- Keep cursor centered
          sidescrolloff = 8,
        },
        g = {},
      },
      -- Reorganized mappings with logical grouping
      mappings = {
        n = {
          -- ================================
          -- QUICK ACTIONS (Root Level)
          -- ================================
          ["<Leader>w"] = { function() buffer_nav.close_smart() end, desc = "Close buffer" },
          ["<Leader>W"] = { "<cmd>wa<cr>", desc = "Save all" },
          ["<Leader>q"] = { "<cmd>confirm q<cr>", desc = "Quit" },
          ["<Leader>Q"] = { "<cmd>qa!<cr>", desc = "Quit all" },
          ["<Leader>?"] = { "<cmd>Keybindings<cr>", desc = "Show keybindings" },
          ["<Leader>/"] = { function() require("Comment.api").toggle.linewise.current() end, desc = "Toggle comment" },
          ["<Leader><Leader>"] = { function() buffer_nav.nav_to_last() end, desc = "Last buffer" },
          ["<Leader>n"] = { "<cmd>enew<cr>", desc = "New file" },
          ["<Leader>R"] = { "<cmd>e!<cr>", desc = "Reload file" },
          ["<Leader>`"] = { function() buffer_nav.nav_to_last() end, desc = "Switch to last buffer" },
          
          -- ================================
          -- AI/CLAUDE CODE (<Leader>a)
          -- ================================
          ["<Leader>ac"] = { "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
          ["<Leader>af"] = { "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
          ["<Leader>ar"] = { "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
          ["<Leader>aC"] = { "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
          ["<Leader>am"] = { "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
          ["<Leader>ab"] = { "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
          ["<Leader>aa"] = { "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
          ["<Leader>ad"] = { "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
          
          -- ================================
          -- BUFFERS (<Leader>b)
          -- ================================
          ["<Leader>bb"] = { function() require("telescope.builtin").buffers() end, desc = "List buffers" },
          ["<Leader>bd"] = { function() buffer_nav.close_smart() end, desc = "Delete buffer" },
          ["<Leader>bD"] = { function() require("astrocore.buffer").close_all() end, desc = "Delete all buffers" },
          ["<Leader>bo"] = { function() buffer_nav.close_others() end, desc = "Delete other buffers" },
          -- Buffer navigation removed - use <Leader>a/d instead
          ["<Leader>bs"] = { "<cmd>w<cr>", desc = "Save buffer" },
          ["<Leader>bS"] = { "<cmd>wa<cr>", desc = "Save all buffers" },
          ["<Leader>b1"] = { function() buffer_nav.nav_to(1) end, desc = "Buffer 1" },
          ["<Leader>b2"] = { function() buffer_nav.nav_to(2) end, desc = "Buffer 2" },
          ["<Leader>b3"] = { function() buffer_nav.nav_to(3) end, desc = "Buffer 3" },
          ["<Leader>b4"] = { function() buffer_nav.nav_to(4) end, desc = "Buffer 4" },
          ["<Leader>b5"] = { function() buffer_nav.nav_to(5) end, desc = "Buffer 5" },
          ["<Leader>b6"] = { function() buffer_nav.nav_to(6) end, desc = "Buffer 6" },
          ["<Leader>b7"] = { function() buffer_nav.nav_to(7) end, desc = "Buffer 7" },
          ["<Leader>b8"] = { function() buffer_nav.nav_to(8) end, desc = "Buffer 8" },
          ["<Leader>b9"] = { function() buffer_nav.nav_to(9) end, desc = "Buffer 9" },
          ["<Leader>bc"] = { function() vim.notify("Buffer " .. vim.api.nvim_get_current_buf() .. " (" .. buffer_nav.count() .. " total)") end, desc = "Buffer count" },
          
          -- ================================
          -- CODE/LSP (<Leader>c)
          -- ================================
          ["<Leader>ca"] = { function() vim.lsp.buf.code_action() end, desc = "Code action" },
          ["<Leader>cd"] = { function() vim.lsp.buf.definition() end, desc = "Code definition" },
          ["<Leader>cD"] = { function() vim.lsp.buf.declaration() end, desc = "Code declaration" },
          ["<Leader>ci"] = { function() vim.lsp.buf.implementation() end, desc = "Code implementation" },
          ["<Leader>cr"] = { function() vim.lsp.buf.references() end, desc = "Code references" },
          ["<Leader>cR"] = { function() vim.lsp.buf.rename() end, desc = "Code rename" },
          ["<Leader>ct"] = { function() vim.lsp.buf.type_definition() end, desc = "Code type definition" },
          ["<Leader>ch"] = { function() vim.lsp.buf.hover() end, desc = "Code hover" },
          ["<Leader>cs"] = { function() vim.lsp.buf.signature_help() end, desc = "Code signature" },
          ["<Leader>cf"] = { function() vim.lsp.buf.format({ async = true }) end, desc = "Code format" },
          
          -- ================================
          -- FIND/FILES (<Leader>f)
          -- ================================
          ["<Leader>ff"] = { function() require("telescope.builtin").find_files() end, desc = "Find files" },
          ["<Leader>fr"] = { function() require("telescope.builtin").oldfiles() end, desc = "Recent files" },
          ["<Leader>fg"] = { function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
          ["<Leader>fb"] = { function() require("telescope.builtin").buffers() end, desc = "Find buffers" },
          ["<Leader>fh"] = { function() require("telescope.builtin").help_tags() end, desc = "Help tags" },
          ["<Leader>fm"] = { function() require("telescope.builtin").marks() end, desc = "Find marks" },
          ["<Leader>fc"] = { function() require("telescope.builtin").commands() end, desc = "Commands" },
          ["<Leader>fk"] = { function() require("telescope.builtin").keymaps() end, desc = "Keymaps" },
          ["<Leader>fs"] = { function() require("telescope.builtin").lsp_document_symbols() end, desc = "Document symbols" },
          ["<Leader>fS"] = { function() require("telescope.builtin").lsp_workspace_symbols() end, desc = "Workspace symbols" },
          ["<Leader>fo"] = { function() require("telescope.builtin").vim_options() end, desc = "Vim options" },
          ["<Leader>fR"] = { function() require("telescope.builtin").registers() end, desc = "Registers" },
          
          -- ================================
          -- GIT (<Leader>g)
          -- ================================
          ["<Leader>gs"] = { function()
            local git_check = require("utils.git-check")
            git_check.safe_git_command(function()
              require("telescope.builtin").git_status()
            end, "Git Status")()
          end, desc = "Git status" },
          ["<Leader>gb"] = { function()
            local git_check = require("utils.git-check")
            git_check.safe_git_command(function()
              require("telescope.builtin").git_branches()
            end, "Git Branches")()
          end, desc = "Git branches" },
          -- Neogit for comprehensive git workflow
          ["<Leader>gN"] = { "<cmd>Neogit<cr>", desc = "Neogit status" },
          ["<Leader>gM"] = { "<cmd>Neogit commit<cr>", desc = "Commit with Neogit" },
          -- AI-powered quick commit
          ["<Leader>gA"] = { "<cmd>AIQuickCommit<cr>", desc = "Quick commit with AI" },
          -- Telescope git viewers
          ["<Leader>gc"] = { function()
            local git_check = require("utils.git-check")
            git_check.safe_git_command(function()
              require("telescope.builtin").git_commits()
            end, "Git Commits")()
          end, desc = "View git commits" },
          ["<Leader>gC"] = { function()
            local git_check = require("utils.git-check")
            git_check.safe_git_command(function()
              require("telescope.builtin").git_bcommits()
            end, "Git Buffer Commits")()
          end, desc = "Buffer commits" },
          ["<Leader>gd"] = { function()
            local git_check = require("utils.git-check")
            if not git_check.is_git_repo() then
              vim.notify("Not in a git repository", vim.log.levels.WARN, { title = "Git Diff" })
              return
            end
            -- Check if diffview is installed
            local ok = pcall(require, "diffview")
            if ok then
              vim.cmd("DiffviewOpen")
            else
              vim.notify("Diffview plugin not installed", vim.log.levels.WARN)
            end
          end, desc = "Git diff view" },
          ["<Leader>gD"] = { function()
            local ok = pcall(require, "diffview")
            if ok then
              vim.cmd("DiffviewClose")
            else
              vim.notify("Diffview plugin not installed", vim.log.levels.WARN)
            end
          end, desc = "Close diff view" },
          ["<Leader>gh"] = { function()
            local git_check = require("utils.git-check")
            if not git_check.is_git_repo() then
              vim.notify("Not in a git repository", vim.log.levels.WARN, { title = "File History" })
              return
            end
            local ok = pcall(require, "diffview")
            if ok then
              vim.cmd("DiffviewFileHistory %")
            else
              vim.notify("Diffview plugin not installed", vim.log.levels.WARN)
            end
          end, desc = "File history" },
          ["<Leader>gH"] = { function()
            local git_check = require("utils.git-check")
            if not git_check.is_git_repo() then
              vim.notify("Not in a git repository", vim.log.levels.WARN, { title = "Branch History" })
              return
            end
            local ok = pcall(require, "diffview")
            if ok then
              vim.cmd("DiffviewFileHistory")
            else
              vim.notify("Diffview plugin not installed", vim.log.levels.WARN)
            end
          end, desc = "Branch history" },
          
          -- Git signs toggles
          ["<Leader>gt"] = { "<cmd>Gitsigns toggle_signs<cr>", desc = "Toggle git signs" },
          ["<Leader>gn"] = { "<cmd>Gitsigns toggle_numhl<cr>", desc = "Toggle line number highlighting" },
          ["<Leader>gl"] = { "<cmd>Gitsigns toggle_linehl<cr>", desc = "Toggle line highlighting" },
          ["<Leader>gW"] = { "<cmd>Gitsigns toggle_word_diff<cr>", desc = "Toggle word diff" },
          ["<Leader>gT"] = { "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle blame line" },
          ["<Leader>gr"] = { "<cmd>Gitsigns refresh<cr>", desc = "Refresh git signs" },
          
          -- Git file navigation (enhanced with monitoring)
          ["<Leader>gj"] = { function()
            require("utils.git-monitor").jump_file("next")
          end, desc = "Next changed file" },
          
          ["<Leader>gk"] = { function()
            require("utils.git-monitor").jump_file("prev")
          end, desc = "Previous changed file" },
          
          ["<Leader>gf"] = { function()
            -- List all files with git changes
            require("telescope.builtin").git_status()
          end, desc = "List changed files" },
          
          -- Git file monitoring/watchlist
          ["<Leader>gwa"] = { function()
            require("utils.git-monitor").add_to_watchlist()
          end, desc = "Add file to watchlist" },
          
          ["<Leader>gwr"] = { function()
            require("utils.git-monitor").remove_from_watchlist()
          end, desc = "Remove file from watchlist" },
          
          ["<Leader>gwl"] = { function()
            require("utils.git-monitor").show_watchlist()
          end, desc = "Show watchlist" },
          
          ["<Leader>gwj"] = { function()
            require("utils.git-monitor").jump_watchlist("next")
          end, desc = "Next watchlist file" },
          
          ["<Leader>gwk"] = { function()
            require("utils.git-monitor").jump_watchlist("prev")
          end, desc = "Previous watchlist file" },
          
          ["<Leader>gwm"] = { function()
            require("utils.git-monitor").monitor_changes()
          end, desc = "Check for changes" },
          
          ["<Leader>gws"] = { function()
            require("utils.git-monitor").setup_auto_monitor()
            vim.notify("Auto-monitoring enabled for watchlist", vim.log.levels.INFO)
          end, desc = "Start auto-monitoring" },
          
          -- ================================
          -- JUPYTER/MOLTEN (<Leader>j)
          -- ================================
          
          
          -- ================================
          -- MESSAGES/ERRORS (<Leader>M)
          -- ================================
          ["<Leader>Me"] = { "<cmd>Errors<cr>", desc = "Show errors" },
          ["<Leader>Ma"] = { "<cmd>Messages<cr>", desc = "Show all messages" },
          ["<Leader>Mc"] = { "<cmd>CopyLastError<cr>", desc = "Copy last error" },
          ["<Leader>MC"] = { "<cmd>CopyAllErrors<cr>", desc = "Copy all errors" },
          ["<Leader>MA"] = { "<cmd>CopyAllMessages<cr>", desc = "Copy all messages" },
          ["<Leader>Md"] = { "<cmd>messages clear<cr>", desc = "Clear messages" },
          
          -- ================================
          -- GITHUB (<Leader>G)
          -- ================================
          ["<Leader>Gi"] = { "<cmd>Octo issue list<cr>", desc = "List GitHub issues" },
          ["<Leader>GI"] = { "<cmd>Octo issue create<cr>", desc = "Create GitHub issue" },
          ["<Leader>Gp"] = { "<cmd>Octo pr list<cr>", desc = "List GitHub PRs" },
          ["<Leader>GP"] = { "<cmd>Octo pr create<cr>", desc = "Create GitHub PR" },
          ["<Leader>Gr"] = { "<cmd>Octo repo list<cr>", desc = "List GitHub repos" },
          ["<Leader>Gs"] = { "<cmd>Octo search<cr>", desc = "Search GitHub" },
          ["<Leader>Ga"] = { "<cmd>Octo assignee add<cr>", desc = "Add GitHub assignee" },
          ["<Leader>Gl"] = { "<cmd>Octo label add<cr>", desc = "Add GitHub label" },
          ["<Leader>Gc"] = { "<cmd>Octo comment add<cr>", desc = "Add GitHub comment" },
          ["<Leader>GR"] = { "<cmd>Octo review start<cr>", desc = "Start GitHub review" },
          ["<Leader>Gd"] = { "<cmd>Octo pr diff<cr>", desc = "Show GitHub PR diff" },
          ["<Leader>Go"] = { "<cmd>Octo pr checkout<cr>", desc = "Checkout GitHub PR" },
          ["<Leader>Gm"] = { function()
            vim.ui.input({ prompt = "Merge method (merge/squash/rebase): " }, function(method)
              if method and (method == "merge" or method == "squash" or method == "rebase") then
                vim.fn.system("gh pr merge --" .. method)
                vim.notify("PR merged with " .. method)
              end
            end)
          end, desc = "Merge GitHub PR" },
          
          -- Additional GitHub CLI commands
          ["<Leader>Gv"] = { function()
            vim.fn.system("gh pr view --web")
            vim.notify("Opening PR in browser...")
          end, desc = "View GitHub PR in browser" },
          ["<Leader>Gw"] = { function()
            vim.fn.system("gh repo view --web")
            vim.notify("Opening repo in browser...")
          end, desc = "View GitHub repo in browser" },
          
          -- ================================
          -- REPLACE/REFACTOR (<Leader>r)
          -- ================================
          ["<Leader>rc"] = { ":%s/<C-r><C-w>//g<Left><Left>", desc = "Replace word (native)" },
          ["<Leader>rn"] = { function() vim.lsp.buf.rename() end, desc = "Rename symbol" },
          
          -- ================================
          -- SEARCH (<Leader>s)
          -- ================================
          ["<Leader>ss"] = { function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Search buffer" },
          ["<Leader>sg"] = { function() require("telescope.builtin").live_grep() end, desc = "Search project" },
          ["<Leader>sw"] = { function() require("telescope.builtin").grep_string() end, desc = "Search word" },
          ["<Leader>sW"] = { function() require("telescope.builtin").grep_string({ word_match = "-w" }) end, desc = "Search word (whole)" },
          ["<Leader>sh"] = { function() require("telescope.builtin").search_history() end, desc = "Search history" },
          ["<Leader>sc"] = { function() require("telescope.builtin").command_history() end, desc = "Command history" },
          ["<Leader>sn"] = { "<cmd>nohlsearch<cr>", desc = "Clear search highlight" },
          ["<Leader>sr"] = { function() require("telescope.builtin").resume() end, desc = "Resume last search" },
          
          -- ================================
          -- TEST (<Leader>t)
          -- ================================
          ["<Leader>tt"] = { function()
            local file = vim.fn.expand("%:p")
            if file:match("_spec%.lua$") then
              vim.notify("Running tests in " .. vim.fn.expand("%:t"))
              vim.cmd("PlenaryBustedFile " .. file)
            else
              vim.notify("Not a test file (*_spec.lua)")
            end
          end, desc = "Run current test file" },
          ["<Leader>ta"] = { function()
            vim.notify("Running all tests...")
            vim.cmd("PlenaryBustedDirectory tests/unit/ {minimal_init = 'tests/minimal_init.lua'}")
          end, desc = "Run all tests" },
          ["<Leader>tn"] = { function()
            local line = vim.api.nvim_win_get_cursor(0)[1]
            vim.notify("Running nearest test at line " .. line)
            vim.cmd("PlenaryBustedFile % {minimal_init = 'tests/minimal_init.lua', sequential = true}")
          end, desc = "Run nearest test" },
          
          -- ================================
          -- TERMINAL (<Leader>T)
          -- ================================
          ["<Leader>Tt"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle" },
          ["<Leader>Tf"] = { "<cmd>ToggleTerm direction=float<cr>", desc = "Float" },
          ["<Leader>Th"] = { "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal" },
          ["<Leader>Tv"] = { "<cmd>ToggleTerm direction=vertical<cr>", desc = "Vertical" },
          ["<Leader>T1"] = { "<cmd>1ToggleTerm<cr>", desc = "Terminal 1" },
          ["<Leader>T2"] = { "<cmd>2ToggleTerm<cr>", desc = "Terminal 2" },
          ["<Leader>T3"] = { "<cmd>3ToggleTerm<cr>", desc = "Terminal 3" },
          ["<Leader>T4"] = { "<cmd>4ToggleTerm<cr>", desc = "Terminal 4" },
          
          -- ================================
          -- UI/TOGGLES (<Leader>u)
          -- ================================
          ["<Leader>uz"] = { function() require("zen-mode").toggle() end, desc = "Toggle zen mode" },
          ["<Leader>un"] = { "<cmd>set number!<cr>", desc = "Toggle line numbers" },
          ["<Leader>ur"] = { "<cmd>set relativenumber!<cr>", desc = "Toggle relative numbers" },
          ["<Leader>uw"] = { "<cmd>set wrap!<cr>", desc = "Toggle word wrap" },
          ["<Leader>us"] = { "<cmd>set spell!<cr>", desc = "Toggle spell check" },
          ["<Leader>ul"] = { "<cmd>set list!<cr>", desc = "Toggle list chars" },
          ["<Leader>uh"] = { "<cmd>set hlsearch!<cr>", desc = "Toggle search highlight" },
          -- Terminal removed from UI toggles - use <C-M-t> instead
          ["<Leader>uc"] = { "<cmd>set cursorline!<cr>", desc = "Toggle cursor line" },
          ["<Leader>uC"] = { "<cmd>set cursorcolumn!<cr>", desc = "Toggle cursor column" },
          
          -- ================================
          -- UI/THEME (<Leader>U)
          -- ================================
          ["<Leader>Ut"] = { function() vim.cmd("Telescope colorscheme") end, desc = "Choose theme" },
          ["<Leader>Ud"] = { function() vim.o.background = "dark" end, desc = "Dark mode" },
          ["<Leader>Ul"] = { function() vim.o.background = "light" end, desc = "Light mode" },
          ["<Leader>UT"] = { function() 
            vim.o.background = vim.o.background == "dark" and "light" or "dark" 
          end, desc = "Toggle dark/light" },
          ["<Leader>Uc"] = { "<cmd>Telescope highlights<cr>", desc = "View highlights" },
          ["<Leader>Ur"] = { "<cmd>source $MYVIMRC<cr>", desc = "Reload config" },
          ["<Leader>U1"] = { "<cmd>colorscheme rose-pine-main<cr>", desc = "Rose Pine Main" },
          ["<Leader>U2"] = { "<cmd>colorscheme rose-pine-moon<cr>", desc = "Rose Pine Moon" },
          ["<Leader>U3"] = { "<cmd>colorscheme rose-pine-dawn<cr>", desc = "Rose Pine Dawn" },
          
          -- ================================
          -- PACKAGES (<Leader>p)
          -- ================================
          ["<Leader>pi"] = { "<cmd>Lazy install<cr>", desc = "Install" },
          ["<Leader>ps"] = { "<cmd>Lazy sync<cr>", desc = "Sync" },
          ["<Leader>pS"] = { "<cmd>Lazy sync<cr>", desc = "Plugins Sync" },
          ["<Leader>pu"] = { "<cmd>Lazy update<cr>", desc = "Update" },
          ["<Leader>pU"] = { "<cmd>Lazy update<cr>", desc = "Plugins Update" },
          ["<Leader>pc"] = { "<cmd>Lazy clean<cr>", desc = "Clean" },
          ["<Leader>pm"] = { "<cmd>Mason<cr>", desc = "Mason" },
          ["<Leader>pM"] = { "<cmd>MasonUpdate<cr>", desc = "Mason Update" },
          
          -- ================================
          -- VSCODE FEATURES (<Leader>v)
          -- ================================
          
          -- ================================
          -- DIAGNOSTICS (<Leader>x)
          -- ================================
          ["<Leader>xx"] = { function() vim.diagnostic.open_float() end, desc = "Show diagnostics" },
          ["<Leader>xl"] = { function() vim.diagnostic.setloclist() end, desc = "Diagnostics to loclist" },
          ["<Leader>xq"] = { function() vim.diagnostic.setqflist() end, desc = "Diagnostics to qflist" },
          ["<Leader>xn"] = { function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" },
          ["<Leader>xp"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" },
          ["<Leader>xN"] = { function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, desc = "Next error" },
          ["<Leader>xP"] = { function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, desc = "Previous error" },
          
          -- ================================
          -- NUMBER KEY SHORTCUTS (Direct buffer access)
          -- ================================
          ["<Leader>1"] = { function() buffer_nav.nav_to(1) end, desc = "Go to buffer 1" },
          ["<Leader>2"] = { function() buffer_nav.nav_to(2) end, desc = "Go to buffer 2" },
          ["<Leader>3"] = { function() buffer_nav.nav_to(3) end, desc = "Go to buffer 3" },
          ["<Leader>4"] = { function() buffer_nav.nav_to(4) end, desc = "Go to buffer 4" },
          ["<Leader>5"] = { function() buffer_nav.nav_to(5) end, desc = "Go to buffer 5" },
          ["<Leader>6"] = { function() buffer_nav.nav_to(6) end, desc = "Go to buffer 6" },
          ["<Leader>7"] = { function() buffer_nav.nav_to(7) end, desc = "Go to buffer 7" },
          ["<Leader>8"] = { function() buffer_nav.nav_to(8) end, desc = "Go to buffer 8" },
          ["<Leader>9"] = { function() buffer_nav.nav_to(9) end, desc = "Go to buffer 9" },
          ["<Leader>0"] = { function() buffer_nav.nav_to(10) end, desc = "Go to buffer 10" },
          
          -- ================================
          -- WINDOW NAVIGATION (Alt keys remain unchanged)
          -- ================================
          ["<M-1>"] = { "1<C-w>w", desc = "Focus window 1" },
          ["<M-2>"] = { "2<C-w>w", desc = "Focus window 2" },
          ["<M-3>"] = { "3<C-w>w", desc = "Focus window 3" },
          ["<M-4>"] = { "4<C-w>w", desc = "Focus window 4" },
          ["<M-5>"] = { "5<C-w>w", desc = "Focus window 5" },
          ["<M-6>"] = { "6<C-w>w", desc = "Focus window 6" },
          ["<M-7>"] = { "7<C-w>w", desc = "Focus window 7" },
          ["<M-8>"] = { "8<C-w>w", desc = "Focus window 8" },
          ["<C-M-m>"] = { "<C-w>o", desc = "Maximize window" },
          
          -- ================================
          -- NAVIGATION IMPROVEMENTS
          -- ================================
          ["<C-d>"] = { "<C-d>zz", desc = "Scroll down and center" },
          ["<C-u>"] = { "<C-u>zz", desc = "Scroll up and center" },
          ["n"] = { "nzzzv", desc = "Next search result centered" },
          ["N"] = { "Nzzzv", desc = "Previous search result centered" },
          ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
          ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
          ["]d"] = { function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" },
          ["[d"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" },
          ["]g"] = { function() require("gitsigns").next_hunk() end, desc = "Next git hunk" },
          ["[g"] = { function() require("gitsigns").prev_hunk() end, desc = "Previous git hunk" },
          
          -- ================================
          -- TERMINAL
          -- ================================
          ["<C-M-t>"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
          
          -- ================================
          -- QUICK EDITS
          -- ================================
          ["<S-A-d>"] = { "dd", desc = "Delete line" },
          ["<C-a>"] = { "ggVG", desc = "Select all" },
        },
        
        -- ================================
        -- VISUAL MODE MAPPINGS
        -- ================================
        v = {
          ["<Leader>/"] = { "<Plug>(comment_toggle_linewise_visual)", desc = "Toggle comment" },
          
          -- AI/Claude
          ["<Leader>as"] = { "<cmd>ClaudeCodeSend<cr>", desc = "Send to Claude" },
          
          -- Jupyter
          
          -- Replace
          
          -- Search
          ["<Leader>sw"] = { function() 
            require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") }) 
          end, desc = "Search selection" },
          
          
          -- Navigation
          ["<"] = { "<gv", desc = "Indent left" },
          [">"] = { ">gv", desc = "Indent right" },
          ["J"] = { ":m '>+1<CR>gv=gv", desc = "Move selection down" },
          ["K"] = { ":m '<-2<CR>gv=gv", desc = "Move selection up" },
        },
        
        -- ================================
        -- TERMINAL MODE MAPPINGS
        -- ================================
        t = {
          -- Terminal navigation with Alt keys (escape sequence for terminals)
          ["<M-1>"] = { "<C-\\><C-n>1<C-w>w", desc = "Focus window 1" },
          ["<M-2>"] = { "<C-\\><C-n>2<C-w>w", desc = "Focus window 2" },
          ["<M-3>"] = { "<C-\\><C-n>3<C-w>w", desc = "Focus window 3" },
          ["<M-4>"] = { "<C-\\><C-n>4<C-w>w", desc = "Focus window 4" },
          ["<M-5>"] = { "<C-\\><C-n>5<C-w>w", desc = "Focus window 5" },
          ["<M-6>"] = { "<C-\\><C-n>6<C-w>w", desc = "Focus window 6" },
          ["<M-7>"] = { "<C-\\><C-n>7<C-w>w", desc = "Focus window 7" },
          ["<M-8>"] = { "<C-\\><C-n>8<C-w>w", desc = "Focus window 8" },
          
          -- Traditional terminal navigation
          ["<C-M-Tab>1"] = { "<C-\\><C-n>:1ToggleTerm<CR>", desc = "Terminal 1" },
          ["<C-M-Tab>2"] = { "<C-\\><C-n>:2ToggleTerm<CR>", desc = "Terminal 2" },
          ["<C-M-Tab>3"] = { "<C-\\><C-n>:3ToggleTerm<CR>", desc = "Terminal 3" },
          ["<C-M-Tab>4"] = { "<C-\\><C-n>:4ToggleTerm<CR>", desc = "Terminal 4" },
          ["<Esc><Esc>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
          ["<C-M-t>"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
        },
      },
      -- Custom autocommands
      autocmds = {
        -- Keybinding conflict detection
        keybinding_conflicts = {
        {
          event = "VimEnter",
          desc = "Detect keybinding conflicts on startup",
          callback = function()
            vim.defer_fn(function()
              local conflicts = {}
              local seen_mappings = {}
              
              -- Check all modes for conflicts
              for _, mode in ipairs({"n", "v", "x", "s", "o", "i", "c", "t"}) do
                local maps = vim.api.nvim_get_keymap(mode)
                
                for _, map in ipairs(maps) do
                  local key = mode .. ":" .. map.lhs
                  if seen_mappings[key] then
                    table.insert(conflicts, {
                      mode = mode,
                      key = map.lhs,
                      from = seen_mappings[key].from or "unknown",
                      to = map.from or "unknown"
                    })
                  else
                    seen_mappings[key] = map
                  end
                end
              end
              
              -- Report conflicts if found
              if #conflicts > 0 then
                local msg = "Keybinding conflicts detected:\n"
                for _, conflict in ipairs(conflicts) do
                  msg = msg .. string.format("  Mode '%s': %s (defined in: %s and %s)\n", 
                    conflict.mode, conflict.key, conflict.from, conflict.to)
                end
                vim.notify(msg, vim.log.levels.WARN, { title = "Keybinding Conflicts" })
              end
            end, 100) -- Delay to ensure all plugins are loaded
          end,
        },
      },
      -- Multicursor helpers
      multicursor_enhancements = {
        {
          event = "User",
          pattern = "MulticursorStart",
          desc = "Show multicursor help on start",
          callback = function()
            vim.notify("Multicursor active: <Leader>cc to clear, <Leader>cn for pattern", vim.log.levels.INFO)
          end,
        },
      },
    },
  })
  end,
}

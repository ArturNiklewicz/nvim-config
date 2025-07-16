-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- This is the updated version with reorganized keybindings and which-key integration

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = function(_, opts)
    -- Load buffer navigation utilities
    local buffer_nav = require("utils.buffer-nav")
    
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
          ["<Leader>W"] = { function() require("astrocore.buffer").close_all() end, desc = "Close all buffers" },
          ["<Leader>q"] = { "<cmd>confirm q<cr>", desc = "Quit" },
          ["<Leader>Q"] = { "<cmd>qa!<cr>", desc = "Quit all (force)" },
          ["<Leader>/"] = { function() require("Comment.api").toggle.linewise.current() end, desc = "Toggle comment" },
          ["<Leader><Leader>"] = { function() buffer_nav.nav_to_last() end, desc = "Last buffer" },
          
          -- ================================
          -- AI/CLAUDE CODE (<Leader>a)
          -- ================================
          ["<Leader>ac"] = { "<cmd>ClaudeCodeResume<cr>", desc = "Claude toggle (resume)" },
          ["<Leader>aC"] = { "<cmd>ClaudeCodeFresh<cr>", desc = "Claude fresh chat" },
          ["<Leader>af"] = { "<cmd>ClaudeCodeFocus<cr>", desc = "Claude focus" },
          ["<Leader>ar"] = { "<cmd>ClaudeCodeResume<cr>", desc = "Claude resume" },
          ["<Leader>ab"] = { "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer to Claude" },
          ["<Leader>aa"] = { "<cmd>ClaudeAcceptChanges<cr>", desc = "Accept changes" },
          ["<Leader>ad"] = { "<cmd>ClaudeRejectChanges<cr>", desc = "Reject changes" },
          ["<Leader>ao"] = { "<cmd>ClaudeOpenAllFiles<cr>", desc = "Open edited files" },
          ["<Leader>ai"] = { "<cmd>ClaudeShowDiff<cr>", desc = "Show diff" },
          ["<Leader>aD"] = { "<cmd>ClaudeShowAllDiffs<cr>", desc = "Show all diffs" },
          
          -- ================================
          -- BUFFERS (<Leader>b)
          -- ================================
          ["<Leader>bb"] = { function() require("telescope.builtin").buffers() end, desc = "List buffers" },
          ["<Leader>bd"] = { function() buffer_nav.close_smart() end, desc = "Delete buffer" },
          ["<Leader>bD"] = { function() require("astrocore.buffer").close_all() end, desc = "Delete all buffers" },
          ["<Leader>bo"] = { function() buffer_nav.close_others() end, desc = "Delete other buffers" },
          ["<Leader>bn"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
          ["<Leader>bp"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
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
          ["<Leader>cd"] = { function() vim.lsp.buf.definition() end, desc = "Go to definition" },
          ["<Leader>cD"] = { function() vim.lsp.buf.declaration() end, desc = "Go to declaration" },
          ["<Leader>ci"] = { function() vim.lsp.buf.implementation() end, desc = "Go to implementation" },
          ["<Leader>cr"] = { function() vim.lsp.buf.references() end, desc = "Find references" },
          ["<Leader>cR"] = { function() vim.lsp.buf.rename() end, desc = "Rename symbol" },
          ["<Leader>ct"] = { function() vim.lsp.buf.type_definition() end, desc = "Type definition" },
          ["<Leader>ch"] = { function() vim.lsp.buf.hover() end, desc = "Hover documentation" },
          ["<Leader>cs"] = { function() vim.lsp.buf.signature_help() end, desc = "Signature help" },
          ["<Leader>cf"] = { function() vim.lsp.buf.format({ async = true }) end, desc = "Format code" },
          
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
          -- GIT/GITHUB (<Leader>g)
          -- ================================
          ["<Leader>gs"] = { function() require("telescope.builtin").git_status() end, desc = "Git status" },
          ["<Leader>gb"] = { function() require("telescope.builtin").git_branches() end, desc = "Git branches" },
          ["<Leader>gc"] = { function() require("telescope.builtin").git_commits() end, desc = "Git commits" },
          ["<Leader>gC"] = { function() require("telescope.builtin").git_bcommits() end, desc = "Buffer commits" },
          ["<Leader>gd"] = { "<cmd>DiffviewOpen<cr>", desc = "Git diff view" },
          ["<Leader>gD"] = { "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
          ["<Leader>gh"] = { "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
          ["<Leader>gH"] = { "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
          
          -- ================================
          -- JUPYTER/MOLTEN (<Leader>j)
          -- ================================
          ["<Leader>ji"] = { "<cmd>MoltenInit<cr>", desc = "Initialize Molten" },
          ["<Leader>je"] = { "<cmd>MoltenEvaluateOperator<cr>", desc = "Evaluate operator" },
          ["<Leader>jl"] = { "<cmd>MoltenEvaluateLine<cr>", desc = "Evaluate line" },
          ["<Leader>jr"] = { "<cmd>MoltenReevaluateCell<cr>", desc = "Re-evaluate cell" },
          ["<Leader>jo"] = { "<cmd>MoltenShowOutput<cr>", desc = "Show output" },
          ["<Leader>jh"] = { "<cmd>MoltenHideOutput<cr>", desc = "Hide output" },
          ["<Leader>jd"] = { "<cmd>MoltenDelete<cr>", desc = "Delete cell" },
          ["<Leader>js"] = { "<cmd>MoltenStart<cr>", desc = "Start kernel" },
          ["<Leader>jS"] = { "<cmd>MoltenStop<cr>", desc = "Stop kernel" },
          ["<Leader>jR"] = { "<cmd>MoltenRestart<cr>", desc = "Restart kernel" },
          ["<Leader>jk"] = { "<cmd>MoltenKernelStatusToggle<cr>", desc = "Toggle kernel status" },
          ["<Leader>jI"] = { "<cmd>MoltenImportOutput<cr>", desc = "Import output" },
          ["<Leader>jE"] = { "<cmd>MoltenExportOutput<cr>", desc = "Export output" },
          
          -- ================================
          -- MESSAGES/ERRORS (<Leader>m)
          -- ================================
          ["<Leader>me"] = { "<cmd>Errors<cr>", desc = "Show errors" },
          ["<Leader>ma"] = { "<cmd>Messages<cr>", desc = "Show all messages" },
          ["<Leader>mc"] = { "<cmd>CopyLastError<cr>", desc = "Copy last error" },
          ["<Leader>mC"] = { "<cmd>CopyAllErrors<cr>", desc = "Copy all errors" },
          ["<Leader>mA"] = { "<cmd>CopyAllMessages<cr>", desc = "Copy all messages" },
          ["<Leader>md"] = { "<cmd>messages clear<cr>", desc = "Clear messages" },
          
          -- ================================
          -- OCTO/GITHUB (<Leader>o)
          -- ================================
          ["<Leader>oi"] = { "<cmd>Octo issue list<cr>", desc = "List issues" },
          ["<Leader>oI"] = { "<cmd>Octo issue create<cr>", desc = "Create issue" },
          ["<Leader>op"] = { "<cmd>Octo pr list<cr>", desc = "List PRs" },
          ["<Leader>oP"] = { "<cmd>Octo pr create<cr>", desc = "Create PR" },
          ["<Leader>or"] = { "<cmd>Octo repo list<cr>", desc = "List repos" },
          ["<Leader>os"] = { "<cmd>Octo search<cr>", desc = "Search GitHub" },
          ["<Leader>oa"] = { "<cmd>Octo assignee add<cr>", desc = "Add assignee" },
          ["<Leader>ol"] = { "<cmd>Octo label add<cr>", desc = "Add label" },
          ["<Leader>oc"] = { "<cmd>Octo comment add<cr>", desc = "Add comment" },
          ["<Leader>oR"] = { "<cmd>Octo review start<cr>", desc = "Start review" },
          ["<Leader>od"] = { "<cmd>Octo pr diff<cr>", desc = "Show PR diff" },
          ["<Leader>oo"] = { "<cmd>Octo pr checkout<cr>", desc = "Checkout PR" },
          ["<Leader>om"] = { function()
            vim.ui.input({ prompt = "Merge method (merge/squash/rebase): " }, function(method)
              if method and (method == "merge" or method == "squash" or method == "rebase") then
                vim.fn.system("gh pr merge --" .. method)
                vim.notify("PR merged with " .. method)
              end
            end)
          end, desc = "Merge PR" },
          
          -- ================================
          -- REPLACE/REFACTOR (<Leader>r)
          -- ================================
          ["<Leader>rr"] = { "<cmd>Spectre<cr>", desc = "Replace (Spectre)" },
          ["<Leader>rw"] = { function() require("spectre").open_visual({select_word=true}) end, desc = "Replace word" },
          ["<Leader>rf"] = { function() require("spectre").open_file_search({select_word=true}) end, desc = "Replace in file" },
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
          -- UI/TOGGLES (<Leader>u)
          -- ================================
          ["<Leader>uz"] = { function() require("zen-mode").toggle() end, desc = "Toggle zen mode" },
          ["<Leader>un"] = { "<cmd>set number!<cr>", desc = "Toggle line numbers" },
          ["<Leader>ur"] = { "<cmd>set relativenumber!<cr>", desc = "Toggle relative numbers" },
          ["<Leader>uw"] = { "<cmd>set wrap!<cr>", desc = "Toggle word wrap" },
          ["<Leader>us"] = { "<cmd>set spell!<cr>", desc = "Toggle spell check" },
          ["<Leader>ul"] = { "<cmd>set list!<cr>", desc = "Toggle list chars" },
          ["<Leader>uh"] = { "<cmd>set hlsearch!<cr>", desc = "Toggle search highlight" },
          ["<Leader>ut"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
          ["<Leader>uc"] = { "<cmd>set cursorline!<cr>", desc = "Toggle cursor line" },
          ["<Leader>uC"] = { "<cmd>set cursorcolumn!<cr>", desc = "Toggle cursor column" },
          
          -- ================================
          -- VSCODE FEATURES (<Leader>v)
          -- ================================
          ["<Leader>vd"] = { "<Cmd>MCstart<CR>", desc = "Create multicursor" },
          ["<Leader>vn"] = { "<Cmd>MCpattern<CR>", desc = "Multicursor pattern" },
          ["<Leader>vm"] = { "<Cmd>MCclear<CR>", desc = "Clear multicursors" },
          ["<Leader>vy"] = { "<cmd>Telescope neoclip<cr>", desc = "Clipboard history" },
          ["<Leader>vp"] = { function() require("telescope").extensions.neoclip.default() end, desc = "Paste from history" },
          ["<Leader>vl"] = { function() require("illuminate").next_reference() end, desc = "Next reference" },
          ["<Leader>vh"] = { function() require("illuminate").prev_reference() end, desc = "Previous reference" },
          
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
          ["]c"] = { "<cmd>MoltenNext<cr>", desc = "Next cell" },
          ["[c"] = { "<cmd>MoltenPrev<cr>", desc = "Previous cell" },
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
          ["<Leader>aS"] = { function() 
            vim.cmd("ClaudeCodeSend")
            vim.cmd("ClaudeCodeFocus")
          end, desc = "Send to Claude and focus" },
          
          -- Jupyter
          ["<Leader>jv"] = { ":<C-u>MoltenEvaluateVisual<cr>gv", desc = "Evaluate selection" },
          
          -- Replace
          ["<Leader>rr"] = { "<cmd>Spectre<cr>", desc = "Replace selection" },
          ["<Leader>rw"] = { function() require("spectre").open_visual() end, desc = "Replace selection" },
          
          -- Search
          ["<Leader>sw"] = { function() 
            require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") }) 
          end, desc = "Search selection" },
          
          -- VSCode
          ["<Leader>vd"] = { "<Cmd>MCstart<CR>", desc = "Create multicursor" },
          ["<Leader>vn"] = { "<Cmd>MCpattern<CR>", desc = "Multicursor pattern" },
          
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
          ["<C-M-Tab>1"] = { "<C-\\><C-n>:1ToggleTerm<CR>", desc = "Terminal 1" },
          ["<C-M-Tab>2"] = { "<C-\\><C-n>:2ToggleTerm<CR>", desc = "Terminal 2" },
          ["<C-M-Tab>3"] = { "<C-\\><C-n>:3ToggleTerm<CR>", desc = "Terminal 3" },
          ["<C-M-Tab>4"] = { "<C-\\><C-n>:4ToggleTerm<CR>", desc = "Terminal 4" },
          ["<Esc><Esc>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
          ["<C-M-t>"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
        },
      },
    })
  end,
}

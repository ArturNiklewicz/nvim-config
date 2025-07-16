-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
        timeoutlen = 300, -- faster key sequence timeout (default 1000ms)
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- ================================
        -- 🔥 FREQUENT OPERATIONS (Single Leader)
        -- ================================
        ["<Leader>w"] = { "<cmd>w<cr>", desc = "Save file (write)" },
        ["<Leader>q"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer (quit)" },
        ["<Leader>e"] = { "<cmd>Neotree toggle<cr>", desc = "File explorer" },
        ["<Leader>/"] = { function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Search in file" },
        ["<Leader><Tab>"] = { "<cmd>b#<cr>", desc = "Last buffer toggle" },

        -- ================================
        -- 📁 BUFFERS & WINDOWS (Leader b/B)
        -- ================================
        -- Buffer operations
        ["<Leader>bb"] = { function() require("telescope.builtin").buffers() end, desc = "Buffer menu" },
        ["<Leader>bn"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["<Leader>bp"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["<Leader>bd"] = { function() require("astrocore.buffer").close() end, desc = "Delete buffer" },
        ["<Leader>ba"] = { function() require("telescope.builtin").buffers() end, desc = "All buffers" },
        
        -- Buffer quick switching
        ["<Leader>b1"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[1] and vim.api.nvim_buf_is_valid(buffers[1].bufnr) then 
            vim.cmd("buffer " .. buffers[1].bufnr) 
          end
        end, desc = "Jump to buffer 1" },
        ["<Leader>b2"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[2] and vim.api.nvim_buf_is_valid(buffers[2].bufnr) then 
            vim.cmd("buffer " .. buffers[2].bufnr) 
          end
        end, desc = "Jump to buffer 2" },
        ["<Leader>b3"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[3] and vim.api.nvim_buf_is_valid(buffers[3].bufnr) then 
            vim.cmd("buffer " .. buffers[3].bufnr) 
          end
        end, desc = "Jump to buffer 3" },
        ["<Leader>b4"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[4] and vim.api.nvim_buf_is_valid(buffers[4].bufnr) then 
            vim.cmd("buffer " .. buffers[4].bufnr) 
          end
        end, desc = "Jump to buffer 4" },
        ["<Leader>b5"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[5] and vim.api.nvim_buf_is_valid(buffers[5].bufnr) then 
            vim.cmd("buffer " .. buffers[5].bufnr) 
          end
        end, desc = "Jump to buffer 5" },
        ["<Leader>b6"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[6] and vim.api.nvim_buf_is_valid(buffers[6].bufnr) then 
            vim.cmd("buffer " .. buffers[6].bufnr) 
          end
        end, desc = "Jump to buffer 6" },
        ["<Leader>b7"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[7] and vim.api.nvim_buf_is_valid(buffers[7].bufnr) then 
            vim.cmd("buffer " .. buffers[7].bufnr) 
          end
        end, desc = "Jump to buffer 7" },
        ["<Leader>b8"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[8] and vim.api.nvim_buf_is_valid(buffers[8].bufnr) then 
            vim.cmd("buffer " .. buffers[8].bufnr) 
          end
        end, desc = "Jump to buffer 8" },
        ["<Leader>b9"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[9] and vim.api.nvim_buf_is_valid(buffers[9].bufnr) then 
            vim.cmd("buffer " .. buffers[9].bufnr) 
          end
        end, desc = "Jump to buffer 9" },

        -- Window operations (Leader B)
        ["<Leader>Bs"] = { "<cmd>split<cr>", desc = "Split horizontal" },
        ["<Leader>Bv"] = { "<cmd>vsplit<cr>", desc = "Split vertical" },
        ["<Leader>Bm"] = { "<C-w>o", desc = "Maximize window" },
        ["<Leader>Bh"] = { "<C-w>h", desc = "Go to left window" },
        ["<Leader>Bj"] = { "<C-w>j", desc = "Go to down window" },
        ["<Leader>Bk"] = { "<C-w>k", desc = "Go to up window" },
        ["<Leader>Bl"] = { "<C-w>l", desc = "Go to right window" },

        -- ================================
        -- 🔍 SEARCH & REPLACE (Leader s)
        -- ================================
        ["<Leader>sf"] = { function() require("telescope.builtin").find_files() end, desc = "Find in files" },
        ["<Leader>sr"] = { "<cmd>Spectre<cr>", desc = "Replace (Spectre)" },
        ["<Leader>sw"] = { function() require("telescope.builtin").grep_string() end, desc = "Search word" },
        ["<Leader>sb"] = { function() require("telescope.builtin").buffers() end, desc = "Search buffers" },
        ["<Leader>sh"] = { function() require("telescope.builtin").oldfiles() end, desc = "Search history" },
        ["<Leader>sg"] = { function() require("telescope.builtin").live_grep() end, desc = "Search grep" },

        -- ================================
        -- 💻 CODE & LSP (Leader c)
        -- ================================
        ["<Leader>ca"] = { function() vim.lsp.buf.code_action() end, desc = "Code actions" },
        ["<Leader>cd"] = { function() vim.lsp.buf.definition() end, desc = "Go to definition" },
        ["<Leader>cr"] = { function() vim.lsp.buf.rename() end, desc = "Rename" },
        ["<Leader>cf"] = { function() vim.lsp.buf.format() end, desc = "Format" },
        ["<Leader>cs"] = { function() require("telescope.builtin").lsp_document_symbols() end, desc = "Symbols" },
        ["<Leader>ch"] = { function() vim.lsp.buf.hover() end, desc = "Hover info" },
        ["<Leader>ci"] = { function() vim.lsp.buf.implementation() end, desc = "Go to implementation" },
        ["<Leader>ct"] = { function() vim.lsp.buf.type_definition() end, desc = "Go to type definition" },
        ["<Leader>cR"] = { function() require("telescope.builtin").lsp_references() end, desc = "References" },
        ["<Leader>cx"] = { function() vim.lsp.buf.signature_help() end, desc = "Signature help" },

        -- ================================
        -- 🤖 AI/CLAUDE (Leader a)
        -- ================================
        ["<Leader>ac"] = { "<cmd>ClaudeCodeResume<cr>", desc = "Chat (resume)" },
        ["<Leader>an"] = { "<cmd>ClaudeCodeFresh<cr>", desc = "New chat" },
        ["<Leader>aa"] = { "<cmd>ClaudeAcceptChanges<cr>", desc = "Accept changes" },
        ["<Leader>ar"] = { "<cmd>ClaudeRejectChanges<cr>", desc = "Reject changes" },
        ["<Leader>ad"] = { "<cmd>ClaudeShowDiff<cr>", desc = "Show diff" },
        ["<Leader>ab"] = { "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer to context" },
        ["<Leader>af"] = { "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude window" },
        ["<Leader>ao"] = { "<cmd>ClaudeOpenAllFiles<cr>", desc = "Open all edited files" },
        ["<Leader>aD"] = { "<cmd>ClaudeShowAllDiffs<cr>", desc = "Show all diffs" },

        -- ================================
        -- 🌿 GIT UNIFIED (Leader g)
        -- ================================
        -- Status & Info
        ["<Leader>gs"] = { "<cmd>Git<cr>", desc = "Git status (fugitive)" },
        ["<Leader>gb"] = { function() require("gitsigns").blame_line() end, desc = "Blame current line" },
        ["<Leader>gl"] = { "<cmd>Git log<cr>", desc = "Git log" },
        
        -- Changes & Hunks
        ["<Leader>ghn"] = { function() require("gitsigns").next_hunk() end, desc = "Next hunk" },
        ["<Leader>ghp"] = { function() require("gitsigns").prev_hunk() end, desc = "Previous hunk" },
        ["<Leader>ghs"] = { function() require("gitsigns").stage_hunk() end, desc = "Stage hunk" },
        ["<Leader>ghr"] = { function() require("gitsigns").reset_hunk() end, desc = "Reset hunk" },
        ["<Leader>ghd"] = { function() require("gitsigns").diffthis() end, desc = "Diff hunk" },
        ["<Leader>ghu"] = { function() require("gitsigns").undo_stage_hunk() end, desc = "Undo stage hunk" },
        ["<Leader>ghS"] = { function() require("gitsigns").stage_buffer() end, desc = "Stage buffer" },
        ["<Leader>ghR"] = { function() require("gitsigns").reset_buffer() end, desc = "Reset buffer" },

        -- GitHub/PR (Leader G)
        ["<Leader>Gi"] = { "<cmd>Octo issue list<cr>", desc = "Issues list" },
        ["<Leader>Gp"] = { "<cmd>Octo pr list<cr>", desc = "PRs list" },
        ["<Leader>Gc"] = { "<cmd>Octo pr create<cr>", desc = "Create PR/issue" },
        ["<Leader>Gr"] = { "<cmd>Octo review start<cr>", desc = "Start review" },
        ["<Leader>Gm"] = { function()
          -- Quick merge current PR
          vim.ui.input({ prompt = "Merge method (merge/squash/rebase): " }, function(method)
            if method and (method == "merge" or method == "squash" or method == "rebase") then
              local cmd = string.format("gh pr merge --%s", method)
              vim.fn.system(cmd)
              vim.notify("PR merged with " .. method)
            end
          end)
        end, desc = "Merge current PR" },
        ["<Leader>Gv"] = { function()
          -- View current PR in browser
          vim.fn.system("gh pr view --web")
          vim.notify("Opening PR in browser...")
        end, desc = "View PR in browser" },
        ["<Leader>GC"] = { function()
          -- List PR checks
          local output = vim.fn.system("gh pr checks")
          vim.notify(output)
        end, desc = "Show PR checks" },

        -- ================================
        -- 🧪 TESTING (Leader t)
        -- ================================
        ["<Leader>tr"] = { function()
          -- Run tests in current file
          local file = vim.fn.expand("%:p")
          if file:match("_spec%.lua$") then
            vim.notify("Running tests in " .. vim.fn.expand("%:t"))
            vim.cmd("PlenaryBustedFile " .. file)
          else
            vim.notify("Not a test file (*_spec.lua)")
          end
        end, desc = "Run test" },
        ["<Leader>ta"] = { function()
          -- Run all tests
          vim.notify("Running all tests...")
          vim.cmd("PlenaryBustedDirectory tests/unit/ {minimal_init = 'tests/minimal_init.lua'}")
        end, desc = "All tests" },
        ["<Leader>tf"] = { function()
          -- Run tests in current file
          local file = vim.fn.expand("%:p")
          if file:match("_spec%.lua$") then
            vim.notify("Running tests in " .. vim.fn.expand("%:t"))
            vim.cmd("PlenaryBustedFile " .. file)
          else
            vim.notify("Not a test file (*_spec.lua)")
          end
        end, desc = "Test file" },
        ["<Leader>tl"] = { function()
          -- Run last test (implement test history)
          vim.notify("Run last test - not implemented yet")
        end, desc = "Last test" },

        -- ================================
        -- 📊 JUPYTER/MOLTEN (Leader j)
        -- ================================
        ["<Leader>ji"] = { "<cmd>MoltenInit<cr>", desc = "Initialize" },
        ["<Leader>jr"] = { function() 
          vim.cmd("MoltenEvaluateOperator") 
          vim.api.nvim_feedkeys("j", "n", false)
        end, desc = "Run cell" },
        ["<Leader>jn"] = { "<cmd>MoltenNext<cr>", desc = "Next cell" },
        ["<Leader>jp"] = { "<cmd>MoltenPrev<cr>", desc = "Previous cell" },
        ["<Leader>js"] = { "<cmd>MoltenShowOutput<cr>", desc = "Show output" },
        ["<Leader>jh"] = { "<cmd>MoltenHideOutput<cr>", desc = "Hide output" },
        ["<Leader>jl"] = { "<cmd>MoltenEvaluateLine<cr>", desc = "Evaluate line" },
        ["<Leader>jS"] = { "<cmd>MoltenInterrupt<cr>", desc = "Stop kernel" },
        ["<Leader>jR"] = { "<cmd>MoltenRestart!<cr>", desc = "Restart kernel" },

        -- ================================
        -- ⚡ QUICK TOGGLES (Leader T)
        -- ================================
        ["<Leader>Tz"] = { function() require("zen-mode").toggle() end, desc = "Zen mode" },
        ["<Leader>Tg"] = { function() require("gitsigns").toggle_signs() end, desc = "Git signs" },
        ["<Leader>Tb"] = { function() require("gitsigns").toggle_current_line_blame() end, desc = "Blame line" },
        ["<Leader>Tw"] = { "<cmd>set wrap!<cr>", desc = "Word wrap" },
        ["<Leader>Ts"] = { "<cmd>set spell!<cr>", desc = "Spell check" },
        ["<Leader>Tn"] = { "<cmd>set number!<cr>", desc = "Line numbers" },
        ["<Leader>Tr"] = { "<cmd>set relativenumber!<cr>", desc = "Relative numbers" },

        -- ================================
        -- 🔧 DEBUG/ERRORS (Leader d)
        -- ================================
        ["<Leader>de"] = { "<cmd>Errors<cr>", desc = "Show errors" },
        ["<Leader>dm"] = { "<cmd>Messages<cr>", desc = "Messages" },
        ["<Leader>dc"] = { "<cmd>messages clear<cr>", desc = "Clear messages" },
        ["<Leader>dl"] = { "<cmd>LspLog<cr>", desc = "LSP log" },
        ["<Leader>dC"] = { "<cmd>CopyLastError<cr>", desc = "Copy last error" },
        ["<Leader>dE"] = { "<cmd>CopyAllErrors<cr>", desc = "Copy all errors" },
        ["<Leader>dM"] = { "<cmd>CopyAllMessages<cr>", desc = "Copy all messages" },

        -- ================================
        -- ⌨️ DIRECT MAPPINGS (No Leader)
        -- ================================
        -- Diagnostics navigation
        ["]d"] = { function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" },
        ["[d"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" },
        
        -- Git hunks navigation (gitsigns)
        ["]h"] = { function() require("gitsigns").next_hunk() end, desc = "Next git hunk" },
        ["[h"] = { function() require("gitsigns").prev_hunk() end, desc = "Previous git hunk" },
        
        -- Jupyter cells navigation (when molten is active)
        ["]c"] = { "<cmd>MoltenNext<cr>", desc = "Next Jupyter cell" },
        ["[c"] = { "<cmd>MoltenPrev<cr>", desc = "Previous Jupyter cell" },
        
        -- Save shortcut
        ["<C-s>"] = { "<cmd>w<cr>", desc = "Save" },
        
        -- Comment toggle (handled by Comment.nvim plugin)
        ["<C-/>"] = { function() require("Comment.api").toggle.linewise.current() end, desc = "Comment toggle" },

        -- Keep existing window/split navigation (alt+1-8)
        ["<M-1>"] = { "1<C-w>w", desc = "Focus window 1" },
        ["<M-2>"] = { "2<C-w>w", desc = "Focus window 2" },
        ["<M-3>"] = { "3<C-w>w", desc = "Focus window 3" },
        ["<M-4>"] = { "4<C-w>w", desc = "Focus window 4" },
        ["<M-5>"] = { "5<C-w>w", desc = "Focus window 5" },
        ["<M-6>"] = { "6<C-w>w", desc = "Focus window 6" },
        ["<M-7>"] = { "7<C-w>w", desc = "Focus window 7" },
        ["<M-8>"] = { "8<C-w>w", desc = "Focus window 8" },

        -- Keep existing terminal toggle
        ["<C-M-t>"] = { function() vim.cmd("ToggleTerm") end, desc = "Toggle terminal" },

        -- Keep existing navigation
        ["<C-i>"] = { "<C-o>", desc = "Navigate back" },
        ["<C-o>"] = { "<C-i>", desc = "Navigate forward" },
        
        -- Scrolling with auto-center
        ["<C-d>"] = { "<C-d>zz", desc = "Scroll down half page and center" },
        ["<C-u>"] = { "<C-u>zz", desc = "Scroll up half page and center" },

        -- Keep existing LSP navigation
        ["<C-A-d>"] = { function() vim.lsp.buf.declaration() end, desc = "Go to declaration" },
        ["<C-A-r>"] = { function() vim.lsp.buf.references() end, desc = "Show references" },
        ["<C-A-f>"] = { function() require("telescope.builtin").lsp_document_symbols() end, desc = "Go to symbol" },

        -- Keep existing diff operations
        ["<Leader>dp"] = { function()
          if vim.wo.diff then
            vim.cmd("diffput")
          end
        end, desc = "Put diff to other window" },
        ["<Leader>do"] = { function()
          if vim.wo.diff then
            vim.cmd("diffget")
          end
        end, desc = "Get diff from other window" },

        -- Keep existing deletion
        ["<S-A-d>"] = { "dd", desc = "Delete line" },

        -- Keep bracket buffer navigation for muscle memory
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
      },
      
      -- ================================
      -- VISUAL MODE MAPPINGS
      -- ================================
      v = {
        -- Claude Code integration
        ["<Leader>as"] = { "<cmd>ClaudeCodeSend<cr>", desc = "Send selection to Claude Code" },
        ["<Leader>aS"] = { function() 
          vim.cmd("ClaudeCodeSend")
          vim.cmd("ClaudeCodeFocus")
        end, desc = "Send selection to Claude Code and focus" },
        
        -- Search & Replace
        ["<Leader>sr"] = { "<cmd>Spectre<cr>", desc = "Replace selection" },
        ["<Leader>sw"] = { function() require("spectre").open_visual() end, desc = "Search selection" },
        
        -- Code actions
        ["<Leader>ca"] = { function() vim.lsp.buf.code_action() end, desc = "Code actions" },
        ["<Leader>cf"] = { function() vim.lsp.buf.format() end, desc = "Format selection" },
        
        -- Git hunks (visual mode)
        ["<Leader>ghs"] = { function() require("gitsigns").stage_hunk({vim.fn.line("."), vim.fn.line("v")}) end, desc = "Stage hunk" },
        ["<Leader>ghr"] = { function() require("gitsigns").reset_hunk({vim.fn.line("."), vim.fn.line("v")}) end, desc = "Reset hunk" },
        
        -- Comment toggle
        ["<C-/>"] = { "<Plug>(comment_toggle_linewise_visual)", desc = "Comment toggle" },
      },
      
      -- ================================
      -- TERMINAL MODE MAPPINGS
      -- ================================
      t = {
        -- Terminal navigation
        ["<C-M-Tab>1"] = { "<C-\\><C-n>:1ToggleTerm<CR>", desc = "Focus terminal 1" },
        ["<C-M-Tab>2"] = { "<C-\\><C-n>:2ToggleTerm<CR>", desc = "Focus terminal 2" },
        ["<C-M-Tab>3"] = { "<C-\\><C-n>:3ToggleTerm<CR>", desc = "Focus terminal 3" },
        ["<C-M-Tab>4"] = { "<C-\\><C-n>:4ToggleTerm<CR>", desc = "Focus terminal 4" },
        
        -- Escape terminal mode
        ["<Esc><Esc>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
      },
    },
  },
}
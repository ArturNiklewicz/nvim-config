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
        -- 📁 BUFFERS (Leader b)
        -- ================================
        ["<Leader>bb"] = { function() require("telescope.builtin").buffers() end, desc = "Buffers: menu" },
        ["<Leader>bn"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Buffers: next" },
        ["<Leader>bp"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Buffers: previous" },
        ["<Leader>bd"] = { function() require("astrocore.buffer").close() end, desc = "Buffers: delete" },
        ["<Leader>ba"] = { function() require("telescope.builtin").buffers() end, desc = "Buffers: all" },
        
        -- Buffer quick switching
        ["<Leader>b1"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[1] and vim.api.nvim_buf_is_valid(buffers[1].bufnr) then 
            vim.cmd("buffer " .. buffers[1].bufnr) 
          end
        end, desc = "Buffers: go to 1" },
        ["<Leader>b2"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[2] and vim.api.nvim_buf_is_valid(buffers[2].bufnr) then 
            vim.cmd("buffer " .. buffers[2].bufnr) 
          end
        end, desc = "Buffers: go to 2" },
        ["<Leader>b3"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[3] and vim.api.nvim_buf_is_valid(buffers[3].bufnr) then 
            vim.cmd("buffer " .. buffers[3].bufnr) 
          end
        end, desc = "Buffers: go to 3" },
        ["<Leader>b4"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[4] and vim.api.nvim_buf_is_valid(buffers[4].bufnr) then 
            vim.cmd("buffer " .. buffers[4].bufnr) 
          end
        end, desc = "Buffers: go to 4" },
        ["<Leader>b5"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[5] and vim.api.nvim_buf_is_valid(buffers[5].bufnr) then 
            vim.cmd("buffer " .. buffers[5].bufnr) 
          end
        end, desc = "Buffers: go to 5" },
        ["<Leader>b6"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[6] and vim.api.nvim_buf_is_valid(buffers[6].bufnr) then 
            vim.cmd("buffer " .. buffers[6].bufnr) 
          end
        end, desc = "Buffers: go to 6" },
        ["<Leader>b7"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[7] and vim.api.nvim_buf_is_valid(buffers[7].bufnr) then 
            vim.cmd("buffer " .. buffers[7].bufnr) 
          end
        end, desc = "Buffers: go to 7" },
        ["<Leader>b8"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[8] and vim.api.nvim_buf_is_valid(buffers[8].bufnr) then 
            vim.cmd("buffer " .. buffers[8].bufnr) 
          end
        end, desc = "Buffers: go to 8" },
        ["<Leader>b9"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[9] and vim.api.nvim_buf_is_valid(buffers[9].bufnr) then 
            vim.cmd("buffer " .. buffers[9].bufnr) 
          end
        end, desc = "Buffers: go to 9" },

        -- ================================
        -- 📁 WINDOWS (Leader B)
        -- ================================
        ["<Leader>Bs"] = { "<cmd>split<cr>", desc = "Windows: split horizontal" },
        ["<Leader>Bv"] = { "<cmd>vsplit<cr>", desc = "Windows: split vertical" },
        ["<Leader>Bm"] = { "<C-w>o", desc = "Windows: maximize" },
        ["<Leader>Bh"] = { "<C-w>h", desc = "Windows: go left" },
        ["<Leader>Bj"] = { "<C-w>j", desc = "Windows: go down" },
        ["<Leader>Bk"] = { "<C-w>k", desc = "Windows: go up" },
        ["<Leader>Bl"] = { "<C-w>l", desc = "Windows: go right" },

        -- ================================
        -- 🔍 SEARCH & REPLACE (Leader s)
        -- ================================
        ["<Leader>sf"] = { function() require("telescope.builtin").find_files() end, desc = "Search: files" },
        ["<Leader>sr"] = { "<cmd>Spectre<cr>", desc = "Search: replace (Spectre)" },
        ["<Leader>sw"] = { function() require("telescope.builtin").grep_string() end, desc = "Search: word" },
        ["<Leader>sb"] = { function() require("telescope.builtin").buffers() end, desc = "Search: buffers" },
        ["<Leader>sh"] = { function() require("telescope.builtin").oldfiles() end, desc = "Search: history" },
        ["<Leader>sg"] = { function() require("telescope.builtin").live_grep() end, desc = "Search: grep" },
        ["<Leader>sp"] = { function() require("spectre").open_file_search({select_word=true}) end, desc = "Search: in file" },

        -- ================================
        -- 💻 CODE & LSP (Leader c)
        -- ================================
        ["<Leader>ca"] = { function() vim.lsp.buf.code_action() end, desc = "Code: actions" },
        ["<Leader>cd"] = { function() vim.lsp.buf.definition() end, desc = "Code: go to definition" },
        ["<Leader>cr"] = { function() vim.lsp.buf.rename() end, desc = "Code: rename" },
        ["<Leader>cf"] = { function() vim.lsp.buf.format() end, desc = "Code: format" },
        ["<Leader>cs"] = { function() require("telescope.builtin").lsp_document_symbols() end, desc = "Code: symbols" },
        ["<Leader>ch"] = { function() vim.lsp.buf.hover() end, desc = "Code: hover info" },
        ["<Leader>ci"] = { function() vim.lsp.buf.implementation() end, desc = "Code: implementation" },
        ["<Leader>ct"] = { function() vim.lsp.buf.type_definition() end, desc = "Code: type definition" },
        ["<Leader>cR"] = { function() require("telescope.builtin").lsp_references() end, desc = "Code: references" },
        ["<Leader>cx"] = { function() vim.lsp.buf.signature_help() end, desc = "Code: signature help" },

        -- ================================
        -- 🤖 AI/CLAUDE (Leader a)
        -- ================================
        ["<Leader>ac"] = { "<cmd>ClaudeCodeResume<cr>", desc = "AI: chat (resume)" },
        ["<Leader>an"] = { "<cmd>ClaudeCodeFresh<cr>", desc = "AI: new chat" },
        ["<Leader>aa"] = { "<cmd>ClaudeAcceptChanges<cr>", desc = "AI: accept changes" },
        ["<Leader>ar"] = { "<cmd>ClaudeRejectChanges<cr>", desc = "AI: reject changes" },
        ["<Leader>ad"] = { "<cmd>ClaudeShowDiff<cr>", desc = "AI: show diff" },
        ["<Leader>ab"] = { "<cmd>ClaudeCodeAdd %<cr>", desc = "AI: add buffer" },
        ["<Leader>af"] = { "<cmd>ClaudeCodeFocus<cr>", desc = "AI: focus window" },
        ["<Leader>ao"] = { "<cmd>ClaudeOpenAllFiles<cr>", desc = "AI: open all files" },
        ["<Leader>aD"] = { "<cmd>ClaudeShowAllDiffs<cr>", desc = "AI: show all diffs" },

        -- ================================
        -- 🌿 GIT (Leader g)
        -- ================================
        ["<Leader>gs"] = { "<cmd>Git<cr>", desc = "Git: status" },
        ["<Leader>gb"] = { function() require("gitsigns").blame_line() end, desc = "Git: blame line" },
        ["<Leader>gl"] = { "<cmd>Git log<cr>", desc = "Git: log" },
        
        -- Git hunks (Leader gh)
        ["<Leader>ghn"] = { function() require("gitsigns").next_hunk() end, desc = "Git hunks: next" },
        ["<Leader>ghp"] = { function() require("gitsigns").prev_hunk() end, desc = "Git hunks: previous" },
        ["<Leader>ghs"] = { function() require("gitsigns").stage_hunk() end, desc = "Git hunks: stage" },
        ["<Leader>ghr"] = { function() require("gitsigns").reset_hunk() end, desc = "Git hunks: reset" },
        ["<Leader>ghd"] = { function() require("gitsigns").diffthis() end, desc = "Git hunks: diff" },
        ["<Leader>ghu"] = { function() require("gitsigns").undo_stage_hunk() end, desc = "Git hunks: undo stage" },
        ["<Leader>ghS"] = { function() require("gitsigns").stage_buffer() end, desc = "Git hunks: stage buffer" },
        ["<Leader>ghR"] = { function() require("gitsigns").reset_buffer() end, desc = "Git hunks: reset buffer" },

        -- ================================
        -- 🌿 GITHUB (Leader G)
        -- ================================
        ["<Leader>Gi"] = { "<cmd>Octo issue list<cr>", desc = "GitHub: issues list" },
        ["<Leader>Gp"] = { "<cmd>Octo pr list<cr>", desc = "GitHub: PRs list" },
        ["<Leader>Gc"] = { "<cmd>Octo pr create<cr>", desc = "GitHub: create PR" },
        ["<Leader>Gr"] = { "<cmd>Octo review start<cr>", desc = "GitHub: start review" },
        ["<Leader>Gm"] = { function()
          vim.ui.input({ prompt = "Merge method (merge/squash/rebase): " }, function(method)
            if method and (method == "merge" or method == "squash" or method == "rebase") then
              local cmd = string.format("gh pr merge --%s", method)
              vim.fn.system(cmd)
              vim.notify("PR merged with " .. method)
            end
          end)
        end, desc = "GitHub: merge PR" },
        ["<Leader>Gv"] = { function()
          vim.fn.system("gh pr view --web")
          vim.notify("Opening PR in browser...")
        end, desc = "GitHub: view PR in browser" },
        ["<Leader>GC"] = { function()
          local output = vim.fn.system("gh pr checks")
          vim.notify(output)
        end, desc = "GitHub: show PR checks" },

        -- ================================
        -- 🧪 TESTING (Leader t)
        -- ================================
        ["<Leader>tr"] = { function()
          local file = vim.fn.expand("%:p")
          if file:match("_spec%.lua$") then
            vim.notify("Running tests in " .. vim.fn.expand("%:t"))
            vim.cmd("PlenaryBustedFile " .. file)
          else
            vim.notify("Not a test file (*_spec.lua)")
          end
        end, desc = "Test: run current" },
        ["<Leader>ta"] = { function()
          vim.notify("Running all tests...")
          vim.cmd("PlenaryBustedDirectory tests/unit/ {minimal_init = 'tests/minimal_init.lua'}")
        end, desc = "Test: run all" },
        ["<Leader>tf"] = { function()
          local file = vim.fn.expand("%:p")
          if file:match("_spec%.lua$") then
            vim.notify("Running tests in " .. vim.fn.expand("%:t"))
            vim.cmd("PlenaryBustedFile " .. file)
          else
            vim.notify("Not a test file (*_spec.lua)")
          end
        end, desc = "Test: run file" },
        ["<Leader>tl"] = { function()
          vim.notify("Run last test - not implemented yet")
        end, desc = "Test: run last" },

        -- ================================
        -- 📊 JUPYTER/MOLTEN (Leader j)
        -- ================================
        ["<Leader>ji"] = { "<cmd>MoltenInit<cr>", desc = "Jupyter: initialize" },
        ["<Leader>jr"] = { function() 
          vim.cmd("MoltenEvaluateOperator") 
          vim.api.nvim_feedkeys("j", "n", false)
        end, desc = "Jupyter: run cell" },
        ["<Leader>jn"] = { "<cmd>MoltenNext<cr>", desc = "Jupyter: next cell" },
        ["<Leader>jp"] = { "<cmd>MoltenPrev<cr>", desc = "Jupyter: previous cell" },
        ["<Leader>js"] = { "<cmd>MoltenShowOutput<cr>", desc = "Jupyter: show output" },
        ["<Leader>jh"] = { "<cmd>MoltenHideOutput<cr>", desc = "Jupyter: hide output" },
        ["<Leader>jl"] = { "<cmd>MoltenEvaluateLine<cr>", desc = "Jupyter: evaluate line" },
        ["<Leader>jS"] = { "<cmd>MoltenInterrupt<cr>", desc = "Jupyter: stop kernel" },
        ["<Leader>jR"] = { "<cmd>MoltenRestart!<cr>", desc = "Jupyter: restart kernel" },

        -- ================================
        -- ⚡ QUICK TOGGLES (Leader T)
        -- ================================
        ["<Leader>Tz"] = { function() require("zen-mode").toggle() end, desc = "Toggle: zen mode" },
        ["<Leader>Tg"] = { function() require("gitsigns").toggle_signs() end, desc = "Toggle: git signs" },
        ["<Leader>Tb"] = { function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle: blame line" },
        ["<Leader>Tw"] = { "<cmd>set wrap!<cr>", desc = "Toggle: word wrap" },
        ["<Leader>Ts"] = { "<cmd>set spell!<cr>", desc = "Toggle: spell check" },
        ["<Leader>Tn"] = { "<cmd>set number!<cr>", desc = "Toggle: line numbers" },
        ["<Leader>Tr"] = { "<cmd>set relativenumber!<cr>", desc = "Toggle: relative numbers" },

        -- ================================
        -- 🔧 DEBUG/ERRORS (Leader d)
        -- ================================
        ["<Leader>de"] = { "<cmd>Errors<cr>", desc = "Debug: show errors" },
        ["<Leader>dm"] = { "<cmd>Messages<cr>", desc = "Debug: show messages" },
        ["<Leader>dc"] = { "<cmd>messages clear<cr>", desc = "Debug: clear messages" },
        ["<Leader>dl"] = { "<cmd>LspLog<cr>", desc = "Debug: LSP log" },
        ["<Leader>dC"] = { "<cmd>CopyLastError<cr>", desc = "Debug: copy last error" },
        ["<Leader>dE"] = { "<cmd>CopyAllErrors<cr>", desc = "Debug: copy all errors" },
        ["<Leader>dM"] = { "<cmd>CopyAllMessages<cr>", desc = "Debug: copy all messages" },

        -- ================================
        -- DIRECT MAPPINGS (No Leader)
        -- ================================
        -- Diagnostics navigation
        ["]d"] = { function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" },
        ["[d"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" },
        
        -- Git hunks navigation
        ["]h"] = { function() require("gitsigns").next_hunk() end, desc = "Next git hunk" },
        ["[h"] = { function() require("gitsigns").prev_hunk() end, desc = "Previous git hunk" },
        
        -- Jupyter cells navigation
        ["]c"] = { "<cmd>MoltenNext<cr>", desc = "Next Jupyter cell" },
        ["[c"] = { "<cmd>MoltenPrev<cr>", desc = "Previous Jupyter cell" },
        
        -- Save shortcut
        ["<C-s>"] = { "<cmd>w<cr>", desc = "Save" },
        
        -- Keep existing window navigation
        ["<M-1>"] = { "1<C-w>w", desc = "Focus window 1" },
        ["<M-2>"] = { "2<C-w>w", desc = "Focus window 2" },
        ["<M-3>"] = { "3<C-w>w", desc = "Focus window 3" },
        ["<M-4>"] = { "4<C-w>w", desc = "Focus window 4" },
        ["<M-5>"] = { "5<C-w>w", desc = "Focus window 5" },
        ["<M-6>"] = { "6<C-w>w", desc = "Focus window 6" },
        ["<M-7>"] = { "7<C-w>w", desc = "Focus window 7" },
        ["<M-8>"] = { "8<C-w>w", desc = "Focus window 8" },

        -- Terminal toggle
        ["<C-M-t>"] = { function() vim.cmd("ToggleTerm") end, desc = "Toggle terminal" },

        -- Navigation
        ["<C-i>"] = { "<C-o>", desc = "Navigate back" },
        ["<C-o>"] = { "<C-i>", desc = "Navigate forward" },
        
        -- Scrolling
        ["<C-d>"] = { "<C-d>zz", desc = "Scroll down half page" },
        ["<C-u>"] = { "<C-u>zz", desc = "Scroll up half page" },

        -- Keep existing LSP navigation
        ["<C-A-d>"] = { function() vim.lsp.buf.declaration() end, desc = "Go to declaration" },
        ["<C-A-r>"] = { function() vim.lsp.buf.references() end, desc = "Show references" },
        ["<C-A-f>"] = { function() require("telescope.builtin").lsp_document_symbols() end, desc = "Go to symbol" },

        -- Diff operations
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

        -- Keep deletion
        ["<S-A-d>"] = { "dd", desc = "Delete line" },

        -- Bracket buffer navigation for muscle memory
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
      },
      
      -- ================================
      -- VISUAL MODE MAPPINGS
      -- ================================
      v = {
        -- Claude Code integration
        ["<Leader>as"] = { "<cmd>ClaudeCodeSend<cr>", desc = "AI: send selection" },
        ["<Leader>aS"] = { function() 
          vim.cmd("ClaudeCodeSend")
          vim.cmd("ClaudeCodeFocus")
        end, desc = "AI: send & focus" },
        
        -- Search & Replace
        ["<Leader>sr"] = { "<cmd>Spectre<cr>", desc = "Search: replace selection" },
        ["<Leader>sw"] = { function() require("spectre").open_visual() end, desc = "Search: selection" },
        
        -- Code actions
        ["<Leader>ca"] = { function() vim.lsp.buf.code_action() end, desc = "Code: actions" },
        ["<Leader>cf"] = { function() vim.lsp.buf.format() end, desc = "Code: format" },
        
        -- Git hunks
        ["<Leader>ghs"] = { function() require("gitsigns").stage_hunk({vim.fn.line("."), vim.fn.line("v")}) end, desc = "Git: stage hunk" },
        ["<Leader>ghr"] = { function() require("gitsigns").reset_hunk({vim.fn.line("."), vim.fn.line("v")}) end, desc = "Git: reset hunk" },
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
        
        -- Escape terminal
        ["<Esc><Esc>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
      },
    },
  },
}
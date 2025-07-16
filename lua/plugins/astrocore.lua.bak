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
        -- BUFFER MANAGEMENT
        -- ================================
        -- Buffer navigation
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["<Leader>a"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["<Leader>d"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        
        -- Buffer switching (VSCode-style leader+1-9)
        ["<Leader>1"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[1] and vim.api.nvim_buf_is_valid(buffers[1].bufnr) then 
            vim.cmd("buffer " .. buffers[1].bufnr) 
          end
        end, desc = "Go to buffer 1" },
        ["<Leader>2"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[2] and vim.api.nvim_buf_is_valid(buffers[2].bufnr) then 
            vim.cmd("buffer " .. buffers[2].bufnr) 
          end
        end, desc = "Go to buffer 2" },
        ["<Leader>3"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[3] and vim.api.nvim_buf_is_valid(buffers[3].bufnr) then 
            vim.cmd("buffer " .. buffers[3].bufnr) 
          end
        end, desc = "Go to buffer 3" },
        ["<Leader>4"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[4] and vim.api.nvim_buf_is_valid(buffers[4].bufnr) then 
            vim.cmd("buffer " .. buffers[4].bufnr) 
          end
        end, desc = "Go to buffer 4" },
        ["<Leader>5"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[5] and vim.api.nvim_buf_is_valid(buffers[5].bufnr) then 
            vim.cmd("buffer " .. buffers[5].bufnr) 
          end
        end, desc = "Go to buffer 5" },
        ["<Leader>6"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[6] and vim.api.nvim_buf_is_valid(buffers[6].bufnr) then 
            vim.cmd("buffer " .. buffers[6].bufnr) 
          end
        end, desc = "Go to buffer 6" },
        ["<Leader>7"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[7] and vim.api.nvim_buf_is_valid(buffers[7].bufnr) then 
            vim.cmd("buffer " .. buffers[7].bufnr) 
          end
        end, desc = "Go to buffer 7" },
        ["<Leader>8"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[8] and vim.api.nvim_buf_is_valid(buffers[8].bufnr) then 
            vim.cmd("buffer " .. buffers[8].bufnr) 
          end
        end, desc = "Go to buffer 8" },
        ["<Leader>9"] = { function() 
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[9] and vim.api.nvim_buf_is_valid(buffers[9].bufnr) then 
            vim.cmd("buffer " .. buffers[9].bufnr) 
          end
        end, desc = "Go to buffer 9" },

        -- Buffer closing
        ["<Leader>w"] = { function() require("astrocore.buffer").close() end, desc = "Close current buffer" },
        ["<Leader>rw"] = { function() require("astrocore.buffer").close_all() end, desc = "Close all buffers" },
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- ================================
        -- WINDOW MANAGEMENT
        -- ================================
        -- Window/split navigation (alt+1-8)
        ["<M-1>"] = { "1<C-w>w", desc = "Focus window 1" },
        ["<M-2>"] = { "2<C-w>w", desc = "Focus window 2" },
        ["<M-3>"] = { "3<C-w>w", desc = "Focus window 3" },
        ["<M-4>"] = { "4<C-w>w", desc = "Focus window 4" },
        ["<M-5>"] = { "5<C-w>w", desc = "Focus window 5" },
        ["<M-6>"] = { "6<C-w>w", desc = "Focus window 6" },
        ["<M-7>"] = { "7<C-w>w", desc = "Focus window 7" },
        ["<M-8>"] = { "8<C-w>w", desc = "Focus window 8" },

        -- Window operations
        ["<C-A-m>"] = { "<C-w>o", desc = "Maximize current window" },

        -- ================================
        -- TERMINAL MANAGEMENT
        -- ================================
        ["<C-M-t>"] = { function() vim.cmd("ToggleTerm") end, desc = "Toggle terminal" },

        -- ================================
        -- NAVIGATION
        -- ================================
        -- General navigation
        ["<C-i>"] = { "<C-o>", desc = "Navigate back" },
        ["<C-o>"] = { "<C-i>", desc = "Navigate forward" },
        
        -- Scrolling with auto-center
        ["<C-d>"] = { "<C-d>zz", desc = "Scroll down half page and center" },
        ["<C-u>"] = { "<C-u>zz", desc = "Scroll up half page and center" },

        -- LSP navigation
        ["<C-A-d>"] = { function() vim.lsp.buf.declaration() end, desc = "Go to declaration" },
        ["<C-A-r>"] = { function() vim.lsp.buf.references() end, desc = "Show references" },
        ["<C-A-f>"] = { function() require("telescope.builtin").lsp_document_symbols() end, desc = "Go to symbol" },

        -- Diff/diagnostic navigation
        ["]d"] = { function()
          if vim.wo.diff then
            vim.cmd("normal! ]c")
          else
            vim.diagnostic.goto_next()
          end
        end, desc = "Next diff/diagnostic" },
        ["[d"] = { function()
          if vim.wo.diff then
            vim.cmd("normal! [c")
          else
            vim.diagnostic.goto_prev()
          end
        end, desc = "Previous diff/diagnostic" },

        -- ================================
        -- DIFF OPERATIONS
        -- ================================
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

        -- ================================
        -- CLAUDE CODE INTEGRATION
        -- ================================
        -- Core commands
        ["<Leader>ac"] = { "<cmd>ClaudeCodeResume<cr>", desc = "Toggle Claude Code (with resume)" },
        ["<Leader>af"] = { "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code" },
        ["<Leader>ar"] = { "<cmd>ClaudeCodeResume<cr>", desc = "Resume Claude Code" },
        ["<Leader>aC"] = { "<cmd>ClaudeCodeFresh<cr>", desc = "Start fresh Claude Code chat" },
        ["<Leader>ab"] = { "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer to Claude" },
        
        -- Diff management
        ["<Leader>aa"] = { "<cmd>ClaudeAcceptChanges<cr>", desc = "Accept Claude Code changes" },
        ["<Leader>ad"] = { "<cmd>ClaudeRejectChanges<cr>", desc = "Reject Claude Code changes" },
        ["<Leader>ao"] = { "<cmd>ClaudeOpenAllFiles<cr>", desc = "Open all Claude Code edited files" },
        ["<Leader>ai"] = { "<cmd>ClaudeShowDiff<cr>", desc = "Show Claude Code diff for current file" },
        ["<Leader>aD"] = { "<cmd>ClaudeShowAllDiffs<cr>", desc = "Show Claude Code diff for all edited files" },

        -- ================================
        -- EDITING & FILES
        -- ================================
        ["<Leader>s"] = { "<cmd>w<cr>", desc = "Save file" },
        ["<S-A-d>"] = { "dd", desc = "Delete line" },

        -- ================================
        -- UI & MODES
        -- ================================
        ["<C-A-z>"] = { function() require("zen-mode").toggle() end, desc = "Toggle zen mode" },

        -- ================================
        -- ERROR MESSAGE MANAGEMENT
        -- ================================
        ["<Leader>me"] = { "<cmd>Errors<cr>", desc = "Show error messages" },
        ["<Leader>ma"] = { "<cmd>Messages<cr>", desc = "Show all messages" },
        ["<Leader>mc"] = { "<cmd>CopyLastError<cr>", desc = "Copy last error message" },
        ["<Leader>mC"] = { "<cmd>CopyAllErrors<cr>", desc = "Copy all error messages" },
        ["<Leader>mA"] = { "<cmd>CopyAllMessages<cr>", desc = "Copy all messages" },

        -- ================================
        -- VSCODE-LIKE EDITING
        -- ================================
        -- Search and replace
        ["<Leader>sr"] = { "<cmd>Spectre<cr>", desc = "Find and replace (Spectre)" },
        ["<Leader>sw"] = { function() require("spectre").open_visual({select_word=true}) end, desc = "Search current word" },
        ["<Leader>sp"] = { function() require("spectre").open_file_search({select_word=true}) end, desc = "Search in current file" },
        
        -- Clipboard management
        ["<Leader>vy"] = { "<cmd>Telescope neoclip<cr>", desc = "Clipboard history" },
        ["<Leader>vp"] = { function() require("telescope").extensions.neoclip.default() end, desc = "Paste from clipboard history" },
        
        -- Enhanced navigation
        ["<Leader>vi"] = { function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Find in current buffer" },
        ["<Leader>vl"] = { function() require("illuminate").next_reference() end, desc = "Next reference" },
        ["<Leader>vh"] = { function() require("illuminate").prev_reference() end, desc = "Previous reference" },

        -- ================================
        -- TESTING COMMANDS
        -- ================================
        ["<Leader>tt"] = { function()
          -- Run tests in current file
          local file = vim.fn.expand("%:p")
          if file:match("_spec%.lua$") then
            vim.notify("Running tests in " .. vim.fn.expand("%:t"))
            vim.cmd("PlenaryBustedFile " .. file)
          else
            vim.notify("Not a test file (*_spec.lua)")
          end
        end, desc = "Run tests in current file" },
        
        ["<Leader>ta"] = { function()
          -- Run all tests
          vim.notify("Running all tests...")
          vim.cmd("PlenaryBustedDirectory tests/unit/ {minimal_init = 'tests/minimal_init.lua'}")
        end, desc = "Run all tests" },
        
        ["<Leader>tn"] = { function()
          -- Run nearest test
          local line = vim.api.nvim_win_get_cursor(0)[1]
          vim.notify("Running nearest test at line " .. line)
          vim.cmd("PlenaryBustedFile % {minimal_init = 'tests/minimal_init.lua', sequential = true}")
        end, desc = "Run nearest test" },

        -- ================================
        -- GITHUB INTEGRATION (OCTO)
        -- ================================
        -- Core GitHub commands
        ["<Leader>gi"] = { "<cmd>Octo issue list<cr>", desc = "List GitHub issues" },
        ["<Leader>gI"] = { "<cmd>Octo issue create<cr>", desc = "Create GitHub issue" },
        ["<Leader>gp"] = { "<cmd>Octo pr list<cr>", desc = "List pull requests" },
        ["<Leader>gP"] = { "<cmd>Octo pr create<cr>", desc = "Create pull request" },
        ["<Leader>gr"] = { "<cmd>Octo repo list<cr>", desc = "List repositories" },
        ["<Leader>gs"] = { "<cmd>Octo search<cr>", desc = "Search GitHub" },
        
        -- GitHub CLI commands
        ["<Leader>gv"] = { function()
          -- View current PR in browser
          vim.fn.system("gh pr view --web")
          vim.notify("Opening PR in browser...")
        end, desc = "View PR in browser" },
        
        ["<Leader>gc"] = { function()
          -- List PR checks
          local output = vim.fn.system("gh pr checks")
          vim.notify(output)
        end, desc = "Show PR checks" },
        
        ["<Leader>gm"] = { function()
          -- Quick merge current PR
          vim.ui.input({ prompt = "Merge method (merge/squash/rebase): " }, function(method)
            if method and (method == "merge" or method == "squash" or method == "rebase") then
              local cmd = string.format("gh pr merge --%s", method)
              vim.fn.system(cmd)
              vim.notify("PR merged with " .. method)
            end
          end)
        end, desc = "Merge current PR" },
        
        ["<Leader>gb"] = { function()
          -- Create issue from current line or selection
          local line = vim.api.nvim_get_current_line()
          vim.ui.input({ prompt = "Issue title: ", default = line }, function(title)
            if title then
              local cmd = string.format("gh issue create --title '%s' --body ''", title:gsub("'", "\\'"))
              local output = vim.fn.system(cmd)
              vim.notify("Issue created: " .. output)
            end
          end)
        end, desc = "Create issue from current line" },
        
        ["<Leader>gf"] = { "<cmd>Octo pr diff<cr>", desc = "Show PR diff" },
        ["<Leader>go"] = { "<cmd>Octo pr checkout<cr>", desc = "Checkout PR" },
        ["<Leader>ga"] = { "<cmd>Octo assignee add<cr>", desc = "Add assignee" },
        ["<Leader>gl"] = { "<cmd>Octo label add<cr>", desc = "Add label" },
        ["<Leader>gC"] = { "<cmd>Octo comment add<cr>", desc = "Add comment" },
        ["<Leader>gR"] = { "<cmd>Octo review start<cr>", desc = "Start review" },
        
        -- Quick GitHub navigation
        ["<Leader>g/"] = { function()
          vim.ui.input({ prompt = "Search GitHub: " }, function(query)
            if query then
              local cmd = string.format("gh search repos '%s'", query:gsub("'", "\\'"))
              local output = vim.fn.system(cmd)
              vim.notify(output)
            end
          end)
        end, desc = "Search GitHub repos" },

        -- ================================
        -- DISABLED MAPPINGS
        -- ================================
        -- ["<C-S>"] = false,
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
        
        -- VSCode-like editing
        ["<Leader>sr"] = { "<cmd>Spectre<cr>", desc = "Find and replace selection" },
        ["<Leader>sw"] = { function() require("spectre").open_visual() end, desc = "Search selection" },
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
      },
    },
  },
}

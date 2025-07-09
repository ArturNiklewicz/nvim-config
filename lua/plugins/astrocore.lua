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

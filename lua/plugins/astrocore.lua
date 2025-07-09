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
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- VSCode-style buffer switching (leader+1-9)
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

        -- Window/split navigation (alt+1-8)
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

        -- Navigation shortcuts
        ["<C-i>"] = { "<C-o>", desc = "Navigate back" },
        ["<C-o>"] = { "<C-i>", desc = "Navigate forward" },

        -- Go to definition/declaration
        ["<C-A-d>"] = { function() vim.lsp.buf.declaration() end, desc = "Go to declaration" },
        ["<C-A-r>"] = { function() vim.lsp.buf.references() end, desc = "Show references" },

        -- Go to symbol
        ["<C-A-f>"] = { function() require("telescope.builtin").lsp_document_symbols() end, desc = "Go to symbol" },

        -- Maximize editor group
        ["<C-A-m>"] = { "<C-w>o", desc = "Maximize current window" },

        -- Delete lines
        ["<S-A-d>"] = { "dd", desc = "Delete line" },

        -- Zen mode toggle
        ["<C-A-z>"] = { function() require("zen-mode").toggle() end, desc = "Toggle zen mode" },

        -- Close all editors in group
        ["<Leader>rw"] = { function() require("astrocore.buffer").close_all() end, desc = "Close all buffers" },

        -- Claude Code integration
        ["<Leader>ac"] = { "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
        ["<Leader>ad"] = { "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude Code changes" },
        ["<Leader>ar"] = { "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject Claude Code changes" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      -- Visual mode mappings
      v = {
        -- Claude Code integration
        ["<Leader>as"] = { "<cmd>ClaudeCodeSend<cr>", desc = "Send to Claude Code" },
      },
      -- Terminal mode mappings
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

return {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  keys = {
    { "<Leader>uz", "<cmd>ZenMode<cr>", desc = "Toggle zen mode" },
  },
  opts = {
    win = {
      backdrop = 0.95,                -- Subtle backdrop for focus
      width = 120,                    -- Content width
      height = 1,                     -- Full height
      options = {
        -- IMPORTANT: Preserve line numbers and git signs
        signcolumn = "yes:2",         -- Ensure git signs column is always visible with width
        number = true,                -- Always show line numbers
        relativenumber = true,        -- Always show relative line numbers
        cursorline = true,            -- Keep cursor line highlight
        cursorcolumn = false,         -- Usually not needed
        foldcolumn = "1",             -- Keep fold column if you use folds
        list = false,                 -- Hide whitespace characters
        colorcolumn = "",             -- Hide color column in zen mode
        scrolloff = 999,              -- Center the cursor vertically
      },
    },
    plugins = {
      -- Preserve editor UI elements
      options = {
        enabled = true,
        ruler = true,                 -- Keep ruler
        showcmd = true,               -- Keep command display
        laststatus = 3,               -- Keep global statusline visible
      },
      -- CRITICAL: Keep gitsigns and line numbers active
      gitsigns = { enabled = true },  -- ALWAYS keep git signs visible
      twilight = { enabled = false }, -- Disable twilight dimming to see all code clearly
      tmux = { enabled = false },     -- Don't modify tmux
      kitty = {
        enabled = false,              -- Don't modify terminal font
        font = "+4",
      },
      alacritty = {
        enabled = false,
        font = "14",
      },
    },
    -- Callback to ensure settings are preserved
    on_open = function(win)
      -- Force line numbers and gitsigns to stay visible
      vim.opt_local.number = true
      vim.opt_local.relativenumber = true
      vim.opt_local.signcolumn = "yes:2"
      vim.opt_local.wrap = false      -- Keep nowrap
      vim.opt_local.linebreak = false -- Keep linebreak setting
      
      -- Ensure gitsigns refreshes
      vim.cmd("Gitsigns refresh")
    end,
    on_close = function()
      -- Restore normal scrolloff
      vim.opt_local.scrolloff = 8
    end,
  },
}
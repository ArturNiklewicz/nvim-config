return {
  "folke/zen-mode.nvim",
  opts = {
    window = {
      backdrop = 0.95,                -- Subtle backdrop for focus
      width = 120,                    -- Content width
      height = 1,                     -- Full height
      options = {
        -- Preserve all normal editor settings
        signcolumn = "yes",           -- Keep git signs column visible
        number = true,                -- Keep line numbers
        relativenumber = true,        -- Keep relative line numbers
        cursorline = true,            -- Keep cursor line highlight
        cursorcolumn = false,         -- Usually not needed
        foldcolumn = "1",             -- Keep fold column if you use folds
        list = false,                 -- Hide whitespace characters
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
      -- Keep essential plugins active
      twilight = { enabled = false }, -- Disable twilight dimming to see all code clearly
      gitsigns = { enabled = true },  -- Keep git signs visible
      tmux = { enabled = false },     -- Don't modify tmux
      kitty = {
        enabled = false,              -- Don't modify terminal font
        font = "+4",
      },
    },
    -- Callback to ensure settings are preserved
    on_open = function(win)
      -- Additional settings to preserve when entering zen mode
      vim.opt_local.wrap = false      -- Keep nowrap
      vim.opt_local.linebreak = false -- Keep linebreak setting
    end,
    on_close = function()
      -- Nothing to restore as we're keeping everything
    end,
  },
}
return {
  "folke/zen-mode.nvim",
  opts = {
    window = {
      backdrop = 0.95,
      width = 120,
      height = 1,
      options = {
        signcolumn = "yes",         -- Show git signs column
        number = true,              -- Show line numbers
        relativenumber = true,      -- Show relative line numbers
        cursorline = false,
        cursorcolumn = false,
        foldcolumn = "0",
        list = false,
      },
    },
    plugins = {
      options = {
        enabled = true,
        ruler = false,
        showcmd = false,
        laststatus = 3,             -- Show global statusline (shows buffers)
      },
      twilight = { enabled = true },
      gitsigns = { enabled = true },  -- Enable git signs in zen mode
      tmux = { enabled = false },
      kitty = {
        enabled = false,
        font = "+4",
      },
    },
  },
}
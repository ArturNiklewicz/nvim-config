-- Harpoon 2: Quick file marking and navigation
-- Purpose: Mark 4-5 most frequently accessed files per project for instant navigation
-- Author: ThePrimeagen
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  lazy = false,
  opts = {
    settings = {
      save_on_toggle = true,
      sync_on_ui_close = true,
      key = function()
        -- Project-specific marks based on git root or current working directory
        return vim.loop.cwd()
      end,
    },
  },
  config = function(_, opts)
    local harpoon = require("harpoon")

    -- REQUIRED: Setup harpoon with configuration
    harpoon:setup(opts)

    -- Keybindings defined in which-key.lua for consistency
    -- <Leader>ha - Add file
    -- <Leader>hh - Toggle menu
    -- <Leader>hp/hn - Previous/Next
    -- <Leader>h1-9 - Direct jumps
    -- <Leader>fm - Telescope integration

    -- Make harpoon list available globally for telescope integration
    _G.harpoon = harpoon
  end,
}

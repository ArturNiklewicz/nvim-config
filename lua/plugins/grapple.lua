-- Grapple: Scoped file tagging with cursor position memory
-- Purpose: Context-aware tagging (by git branch, project scope) with persistent cursor positions
-- Author: cbochs
-- Complements Harpoon: Use Harpoon for frequent files, Grapple for scoped/contextual navigation
return {
  "cbochs/grapple.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- optional, for file icons
  },
  lazy = false,
  opts = {
    scope = "git_branch", -- Scope tags to current git branch by default
    icons = true, -- Enable devicons
    status = true, -- Enable statusline integration
  },
  config = function(_, opts)
    require("grapple").setup(opts)

    -- Keybindings defined in which-key.lua for consistency
    -- <Leader>ga - Toggle tag
    -- <Leader>gm - Toggle menu
    -- <Leader>g[/g] - Navigate tags
    -- <Leader>ft - Telescope integration
  end,
}

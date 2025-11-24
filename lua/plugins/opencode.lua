-- OpenCode integration plugin
-- Neovim integration with opencode AI assistant
--
-- SETUP:
-- 1. This plugin requires the opencode application to be installed
-- 2. Run :checkhealth opencode after installation to verify setup
-- 3. The plugin auto-connects to opencode instances in the CWD
-- 4. Can toggle an embedded opencode terminal with <leader>ot
--
-- DEPENDENCIES:
-- - folke/snacks.nvim (with input and picker modules)
-- - vim.o.autoread enabled for external file changes

return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {} } },
  },
  lazy = false, -- Load immediately
  config = function()
    -- Enable auto-reload for external changes
    vim.o.autoread = true

    -- Optional: Configure opencode behavior
    -- Full options available in lua/opencode/config.lua
    vim.g.opencode_opts = {
      -- Configuration here (uses sensible defaults)
    }
  end,
  keys = {
    -- OpenCode group
    { "<leader>o", nil, desc = "OpenCode" },

    -- Ask about current context
    {
      "<leader>oa",
      function()
        require("opencode").ask("@this: ", {submit=true})
      end,
      mode = {"n", "x"},
      desc = "Ask about this"
    },

    -- Select from prompt library
    {
      "<leader>os",
      function()
        require("opencode").select()
      end,
      mode = {"n", "x"},
      desc = "Select prompt"
    },

    -- Add current context to prompt
    {
      "<leader>o+",
      function()
        require("opencode").prompt("@this")
      end,
      mode = {"n", "x"},
      desc = "Add this"
    },

    -- Toggle embedded AI assistant
    {
      "<leader>ot",
      function()
        require("opencode").toggle()
      end,
      desc = "Toggle embedded"
    },
  },
}

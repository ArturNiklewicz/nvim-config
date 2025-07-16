-- Which-key configuration for better keybinding discovery
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    icons = {
      group = "", -- remove the + icon
      separator = "➜",
    },
    window = {
      border = "rounded",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    
    -- Register group descriptions for better organization
    wk.register({
      ["<leader>a"] = { name = "🤖 AI/Claude" },
      ["<leader>b"] = { name = "📁 Buffers" },
      ["<leader>B"] = { name = "🪟 Windows" },
      ["<leader>c"] = { name = "💻 Code/LSP" },
      ["<leader>d"] = { name = "🔧 Debug/Errors" },
      ["<leader>g"] = { name = "🌿 Git" },
      ["<leader>gh"] = { name = "📝 Git Hunks" },
      ["<leader>G"] = { name = "🐙 GitHub" },
      ["<leader>j"] = { name = "📊 Jupyter/Molten" },
      ["<leader>s"] = { name = "🔍 Search" },
      ["<leader>t"] = { name = "🧪 Testing" },
      ["<leader>T"] = { name = "⚡ Toggles" },
    })
  end,
}
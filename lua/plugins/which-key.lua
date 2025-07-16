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
    -- Version and compatibility check
    local ok, wk = pcall(require, "which-key")
    if not ok then
      vim.notify("which-key.nvim not found - keybinding discovery disabled", vim.log.levels.WARN)
      return
    end
    
    -- Check minimum Neovim version
    if vim.fn.has("nvim-0.8.0") == 0 then
      vim.notify("which-key.nvim requires Neovim 0.8.0+", vim.log.levels.ERROR)
      return
    end
    
    local success, err = pcall(wk.setup, opts)
    if not success then
      vim.notify("Failed to setup which-key: " .. (err or "unknown error"), vim.log.levels.ERROR)
      return
    end
    
    -- Register group descriptions for better organization
    local groups = {
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
    }
    
    -- Register groups with error handling
    local reg_success, reg_err = pcall(wk.register, groups)
    if not reg_success then
      vim.notify("Failed to register which-key groups: " .. (reg_err or "unknown error"), vim.log.levels.WARN)
    end
  end,
}
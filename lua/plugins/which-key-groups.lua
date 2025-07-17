-- Which-key group definitions for the new keybinding structure
return {
  "folke/which-key.nvim",
  opts = function(_, opts)
    local wk = require("which-key")
    
    -- Register group names for better organization
    wk.register({
      ["<leader>"] = {
        a = { name = "AI/Claude" },
        b = { name = "Buffers" },
        B = { name = "Windows" },
        c = { name = "Code/LSP" },
        d = { name = "Debug/Errors" },
        g = { name = "Git" },
        G = { name = "GitHub" },
        j = { name = "Jupyter/Molten" },
        s = { name = "Search" },
        t = { name = "Testing" },
        T = { name = "Toggles" },
      },
      ["<leader>g"] = {
        h = { name = "Git Hunks" },
      },
    })
    
    return opts
  end,
}
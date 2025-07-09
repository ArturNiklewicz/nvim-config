return {
  "benlubas/molten-nvim",
  ft = { "python" },
  dependencies = { "3rd/image.nvim", "stevearc/dressing.nvim" },
  build = ":UpdateRemotePlugins",               -- molten is a remote plugin
  config = function()
    require("molten").setup({use_lsp = true})
  end,
}


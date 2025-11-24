-- VSCode-like breadcrumbs in winbar
return {
  "utilyre/barbecue.nvim",
  name = "barbecue",
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  lazy = false,
  priority = 900, -- Load after LSP but before UI
  opts = {
    theme = "auto", -- Auto-detect from colorscheme
    show_dirname = true,
    show_basename = true,
    show_modified = true,
    modified = function(bufnr) return vim.bo[bufnr].modified end,
    exclude_filetypes = { "netrw", "toggleterm", "Oil" },

    -- Custom background color to match theme
    theme = {
      normal = { bg = "#1A1C25" },
    },

    -- Symbols for breadcrumb separators
    symbols = {
      separator = " › ",
    },

    -- Context customization
    kinds = {
      File = "",
      Module = "",
      Namespace = "",
      Package = "",
      Class = "",
      Method = "",
      Property = "",
      Field = "",
      Constructor = "",
      Enum = "",
      Interface = "",
      Function = "",
      Variable = "",
      Constant = "",
      String = "",
      Number = "",
      Boolean = "",
      Array = "",
      Object = "",
      Key = "",
      Null = "",
      EnumMember = "",
      Struct = "",
      Event = "",
      Operator = "",
      TypeParameter = "",
    },
  },

  config = function(_, opts)
    require("barbecue").setup(opts)
  end,
}

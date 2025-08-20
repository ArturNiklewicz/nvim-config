-- Catppuccin colorscheme configuration
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    background = {
      light = "latte",
      dark = "mocha",
    },
    transparent_background = false,
    show_end_of_buffer = false,
    term_colors = true,
    dim_inactive = {
      enabled = false,
      shade = "dark",
      percentage = 0.15,
    },
    no_italic = false,
    no_bold = false,
    no_underline = false,
    styles = {
      comments = { "italic" },
      conditionals = { "italic" },
      loops = {},
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
    },
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = false,
      telescope = true,
      notify = true,
      mini = true,
      indent_blankline = {
        enabled = true,
        scope_color = "",
        colored_indent_levels = false,
      },
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
        },
        underlines = {
          errors = { "underline" },
          hints = { "underline" },
          warnings = { "underline" },
          information = { "underline" },
        },
        inlay_hints = {
          background = true,
        },
      },
    },
  },
}
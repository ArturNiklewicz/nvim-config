-- Enhanced file icons configuration
return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    priority = 1000,
    opts = {
      -- Enable colored icons
      color_icons = true,
      -- Use default icons
      default = true,
      -- Strict icon matching
      strict = true,
      -- Override specific icons if needed
      override_by_filename = {
        [".gitignore"] = {
          icon = "",
          color = "#f1502f",
          name = "Gitignore"
        },
        ["Makefile"] = {
          icon = "",
          color = "#6d8086",
          name = "Makefile"
        },
      },
      -- Override by extension
      override_by_extension = {
        ["log"] = {
          icon = "",
          color = "#81e043",
          name = "Log"
        },
        ["toml"] = {
          icon = "",
          color = "#6d8086",
          name = "Toml"
        },
        ["yml"] = {
          icon = "",
          color = "#6d8086",
          name = "Yaml"
        },
        ["yaml"] = {
          icon = "",
          color = "#6d8086",
          name = "Yaml"
        },
      },
    },
  },
}
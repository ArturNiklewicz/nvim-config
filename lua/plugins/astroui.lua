-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      -- change colorscheme
      colorscheme = "catppuccin-mocha",
      -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
      highlights = {
        init = { -- this table overrides highlights in all themes
          -- Normal = { bg = "#000000" },
        },
        astrodark = { -- a table of overrides/changes when applying the astrotheme theme
          -- Normal = { bg = "#000000" },
        },
      },
      -- Icons can be configured throughout the interface
      icons = {
        -- configure the loading of the lsp in the status line
        LSPLoading1 = "⠋",
        LSPLoading2 = "⠙",
        LSPLoading3 = "⠹",
        LSPLoading4 = "⠸",
        LSPLoading5 = "⠼",
        LSPLoading6 = "⠴",
        LSPLoading7 = "⠦",
        LSPLoading8 = "⠧",
        LSPLoading9 = "⠇",
        LSPLoading10 = "⠏",
      },
    },
  },
  -- Snacks configuration moved from user.lua
  {
    "folke/snacks.nvim",
    opts = {
      -- Fix buffer validation issues
      win = {
        backend = "nvim",
        wo = {
          winblend = 0,
        },
      },
      dashboard = {
        preset = {
          header = table.concat({
            "    ██ ████████ ████████ █████    ",
            "   ██   ██  ██   ██   ██     █    ",
            "   ███████  ██████    ██          ",
            "   ██   ██  ██   ██    █          ",
            "█ ███   ██ █ █    ██   ██       █ ",
            " ██     ███ █    ██  ██ ██     ██ ",
            " ███    ██  █    ██     ██   ███  ",
            " ██ █   ██  █    ██ ██  █ ███ █   ",
            " █   █  ██  ██  ██  ██  █  █  ██  ",
            "██    ███    ██ █   ██ ██      ██ ",
          }, "\n"),
        },
      },
    },
  },
  -- Disable better-escape
  { "max397574/better-escape.nvim", enabled = false },
  -- LuaSnip custom configuration
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts)
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },
  -- Autopairs custom configuration
  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts)
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules({
        Rule("$", "$", { "tex", "latex" })
          :with_pair(cond.not_after_regex "%%")
          :with_pair(cond.not_before_regex("xxx", 3))
          :with_move(cond.none())
          :with_del(cond.not_after_regex "xx")
          :with_cr(cond.none()),
      }, Rule("a", "a", "-vim"))
    end,
  },
}

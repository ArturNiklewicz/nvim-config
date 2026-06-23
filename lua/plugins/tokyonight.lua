-- TokyoNight (Night variant) — matches terminal bg #1a1b26 and tmux statusbar
return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "night",
    transparent = false,
    styles = {
      sidebars = "dark",
      floats = "dark",
    },
  },
}

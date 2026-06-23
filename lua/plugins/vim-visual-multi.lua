-- vim-visual-multi: VS Code / Sublime style multi-cursor.
-- Ctrl-N select word, Ctrl-Up/Down vertical cursors, n/N next/prev,
-- q skip, Q remove, Tab toggle cursor/extend mode. Works from normal mode.
return {
  "mg979/vim-visual-multi",
  branch = "master",
  lazy = false, -- map <C-n> etc. at startup; VeryLazy left <C-n> as default "line down" until load
}

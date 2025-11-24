-- Override AstroNvim's default ToggleTerm keybindings to prevent conflicts with vim-test
return {
  "akinsho/toggleterm.nvim",
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        -- Disable AstroNvim's default <Leader>t mappings for ToggleTerm
        -- to make room for vim-test keybindings
        local maps = opts.mappings or {}
        if not maps.n then maps.n = {} end

        -- Explicitly disable conflicting ToggleTerm bindings under <Leader>t
        maps.n["<Leader>tn"] = false  -- Was: ToggleTerm node, Now: vim-test TestNearest
        maps.n["<Leader>tp"] = false  -- Was: ToggleTerm python
        maps.n["<Leader>tf"] = false  -- Was: ToggleTerm float, Now: vim-test TestFile
        maps.n["<Leader>th"] = false  -- Was: ToggleTerm horizontal
        maps.n["<Leader>tv"] = false  -- Was: ToggleTerm vertical, Now: vim-test TestVisit
        maps.n["<Leader>tt"] = false  -- Was: ToggleTerm btm
        maps.n["<Leader>tu"] = false  -- Was: ToggleTerm gdu
        maps.n["<Leader>tl"] = false  -- Was: ToggleTerm lazygit, Now: vim-test TestLast

        -- Keep terminal access through <Leader>T (capital T) prefix
        -- These are preserved in astrocore.lua under TERMINAL section

        opts.mappings = maps
        return opts
      end,
    },
  },
}

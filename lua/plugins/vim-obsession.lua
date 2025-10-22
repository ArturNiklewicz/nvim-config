-- vim-obsession: Automatic session management for tmux-resurrect integration
-- Enables nvim session restoration when using tmux-resurrect
return {
  "tpope/vim-obsession",
  lazy = false, -- Load immediately for tmux integration
  keys = {
    { "<leader>ss", "<cmd>Obsess<CR>", desc = "Start session tracking" },
    { "<leader>sS", "<cmd>Obsess!<CR>", desc = "Stop session tracking" },
    { "<leader>sl", "<cmd>source Session.vim<CR>", desc = "Load session manually" },
  },
  init = function()
    -- Auto-start Obsession for existing Session.vim files
    vim.api.nvim_create_autocmd("VimEnter", {
      nested = true,
      callback = function()
        -- Only auto-start if Session.vim exists and no session is already loaded
        if vim.fn.argc() == 0 and vim.v.this_session == "" and vim.fn.filereadable("Session.vim") == 1 then
          vim.cmd("source Session.vim")
        end
      end,
    })
  end,
}

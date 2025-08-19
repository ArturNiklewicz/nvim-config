-- LazyGit integration for complete git workflow with fuzzy finding
return {
  "kdheepak/lazygit.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit (full UI)" },
    { "<leader>gf", "<cmd>LazyGitFilter<cr>", desc = "LazyGit (project commits)" },
    { "<leader>gF", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit (current file)" },
  },
  config = function()
    -- Configure LazyGit floating window
    vim.g.lazygit_floating_window_winblend = 0
    vim.g.lazygit_floating_window_scaling_factor = 0.9
    vim.g.lazygit_floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
    vim.g.lazygit_floating_window_use_plenary = 1
    vim.g.lazygit_use_neovim_remote = 1

    -- Custom config file if needed
    vim.g.lazygit_use_custom_config_file_path = 0
  end,
}
-- Claude Code integration plugin
-- AI-powered coding assistant with chat interface

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  lazy = false, -- Load immediately
  config = function()
    require("claudecode").setup({
      -- Server configuration
      server = {
        port_range = { 41041, 41099 },
        auto_start = true,
        log_level = "info", -- Options: "trace", "debug", "info", "warn", "error"
      },
      -- Terminal command (at root level, not in terminal section)
      terminal_cmd = "claude",
      -- Terminal layout and behavior
      terminal = {
        split_side = "right",           -- Window placement: "left" or "right"
        split_width_percentage = 0.35,  -- Terminal width as percentage of screen
        provider = "snacks",            -- Terminal provider: "auto", "snacks", "native", "external"
        auto_close = false,             -- Keep terminal open after command execution
      },
      -- Diff handling options
      diff_opts = {
        auto_close_on_accept = true,   -- Auto-close diff view after accepting changes
        vertical_split = true,          -- Use vertical split for diff view
        open_in_current_tab = true,     -- Open diff in current tab vs new tab
        keep_terminal_focus = false,    -- Return focus to editor after diff operations
      },
      -- Optional: Snacks floating window configuration
      snacks_win_opts = {
        position = "split",             -- "split" or "float" for floating window
        width = 0.35,                   -- Width when using split
        height = 0.9,                   -- Height for floating window
        border = "rounded",             -- Border style for floating window
      },
    })
  end,
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "oil", "minifiles" },
    },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
-- Neogit commit message configuration
-- Handles AI-powered commit message generation for Neogit

-- Setup AI commit utilities
local ok, ai_commit = pcall(require, "utils.ai-commit")
if not ok then
  return
end

-- Set textwidth for proper commit message formatting
vim.opt_local.textwidth = 72
vim.opt_local.colorcolumn = "50,72"

-- Enable spell checking
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"

-- Automatically generate AI commit message when buffer opens (if empty)
vim.defer_fn(function()
  -- Double-check we're still in the right buffer
  if vim.bo.filetype ~= "NeogitCommitMessage" then
    return
  end
  
  -- Check if buffer is empty
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local is_empty = true
  for _, line in ipairs(lines) do
    if line ~= "" and not line:match("^#") then
      is_empty = false
      break
    end
  end
  
  if is_empty then
    -- Generate AI message with safe error handling
    pcall(function()
      if ai_commit and ai_commit.generate_commit_message_inline then
        ai_commit.generate_commit_message_inline()
      end
    end)
  end
  
  -- Start in insert mode after a delay
  vim.defer_fn(function()
    if vim.api.nvim_get_mode().mode == 'n' then
      vim.cmd("startinsert")
    end
  end, 300)
end, 200)

-- Keybinding to regenerate AI message
vim.keymap.set("n", "<leader>ag", function()
  if ai_commit and ai_commit.generate_commit_message_inline then
    -- Clear current content (except comments)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local new_lines = {}
    for _, line in ipairs(lines) do
      if line:match("^#") then
        table.insert(new_lines, line)
      end
    end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
    -- Generate new message
    pcall(function()
      ai_commit.generate_commit_message_inline()
    end)
  end
end, { buffer = true, desc = "Generate new AI commit message" })

-- Conventional commit shortcuts
vim.keymap.set("n", "<leader>cf", "ifeat: ", { buffer = true, desc = "feat: New feature" })
vim.keymap.set("n", "<leader>cx", "ifix: ", { buffer = true, desc = "fix: Bug fix" })
vim.keymap.set("n", "<leader>cd", "idocs: ", { buffer = true, desc = "docs: Documentation" })
vim.keymap.set("n", "<leader>cs", "istyle: ", { buffer = true, desc = "style: Formatting" })
vim.keymap.set("n", "<leader>cr", "irefactor: ", { buffer = true, desc = "refactor: Code refactoring" })
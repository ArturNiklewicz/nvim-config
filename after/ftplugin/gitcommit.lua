-- Git commit message configuration
-- Formatting, spell checking, and conventional commit helpers
-- AI generation handled by git-commit-auto.lua (called from polish.lua)

-- Set textwidth for proper commit message formatting (72 chars for body)
vim.opt_local.textwidth = 72
vim.opt_local.colorcolumn = "50,72"

-- Enable spell checking for commit messages
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"

-- Set up abbreviations for conventional commit types
local commit_types = {
  ["feat"] = "feat: ",       -- New feature
  ["fix"] = "fix: ",         -- Bug fix
  ["docs"] = "docs: ",       -- Documentation only
  ["style"] = "style: ",     -- Formatting, white-space, etc
  ["refactor"] = "refactor: ", -- Code refactoring
  ["perf"] = "perf: ",       -- Performance improvement
  ["test"] = "test: ",       -- Adding tests
  ["chore"] = "chore: ",     -- Maintenance
  ["build"] = "build: ",     -- Build system changes
  ["ci"] = "ci: ",          -- CI configuration
  ["revert"] = "revert: ",   -- Revert a commit
}

-- Create insert mode abbreviations
for abbr, expansion in pairs(commit_types) do
  vim.cmd(string.format("iabbrev <buffer> %s %s", abbr, expansion))
end

-- Quick access to conventional commit types
vim.keymap.set("n", "<leader>cf", "ifeat: ", { buffer = true, desc = "feat: New feature" })
vim.keymap.set("n", "<leader>cx", "ifix: ", { buffer = true, desc = "fix: Bug fix" })
vim.keymap.set("n", "<leader>cd", "idocs: ", { buffer = true, desc = "docs: Documentation" })
vim.keymap.set("n", "<leader>cs", "istyle: ", { buffer = true, desc = "style: Formatting" })
vim.keymap.set("n", "<leader>cr", "irefactor: ", { buffer = true, desc = "refactor: Code refactoring" })
vim.keymap.set("n", "<leader>cp", "iperf: ", { buffer = true, desc = "perf: Performance" })
vim.keymap.set("n", "<leader>ct", "itest: ", { buffer = true, desc = "test: Tests" })
vim.keymap.set("n", "<leader>cc", "ichore: ", { buffer = true, desc = "chore: Maintenance" })

-- Show git diff in a split (if not already visible)
vim.keymap.set("n", "<leader>gd", function()
  -- Check if a diff window is already open
  local diff_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
    if ft == "diff" or ft == "git" then
      diff_win = win
      break
    end
  end

  if not diff_win then
    -- Open a new split with the diff
    vim.cmd("vsplit")
    vim.cmd("terminal git diff --cached")
    vim.cmd("wincmd p") -- Go back to commit message window
  end
end, { buffer = true, desc = "Show staged diff" })

-- Template for breaking changes
vim.keymap.set("n", "<leader>cb", function()
  local lines = {
    "",
    "BREAKING CHANGE: ",
  }
  vim.api.nvim_buf_set_lines(0, -1, -1, false, lines)
  -- Move to end of buffer and enter insert mode
  vim.cmd("normal! G$")
  vim.cmd("startinsert!")
end, { buffer = true, desc = "Add BREAKING CHANGE section" })

-- Helper to check commit message format
vim.keymap.set("n", "<leader>cv", function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, 1, false)
  if #lines == 0 or lines[1] == "" then
    vim.notify("Commit message is empty", vim.log.levels.WARN)
    return
  end

  local first_line = lines[1]
  -- Check conventional commit format
  local pattern = "^(%w+)(%(.*%))?: .+"
  if first_line:match(pattern) then
    vim.notify("✓ Valid conventional commit format", vim.log.levels.INFO)
  else
    vim.notify("✗ Not a conventional commit format. Expected: type(scope): description", vim.log.levels.WARN)
  end

  -- Check line length
  if #first_line > 72 then
    vim.notify(string.format("First line is %d chars (recommended: ≤72)", #first_line), vim.log.levels.WARN)
  elseif #first_line > 50 then
    vim.notify(string.format("First line is %d chars (recommended: ≤50)", #first_line), vim.log.levels.INFO)
  end
end, { buffer = true, desc = "Validate commit message" })

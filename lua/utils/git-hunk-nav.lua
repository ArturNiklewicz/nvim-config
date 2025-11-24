-- Enhanced Git Hunk Navigation
-- Fast, focused navigation through git hunks with cross-file overflow
-- Refactored for speed and simplicity - removed redundant gitsigns wrappers

local M = {}

-- Get git navigation module
local function get_git_nav()
  local ok, git_nav = pcall(require, "utils.git-nav")
  if not ok then return nil end
  return git_nav
end

-- Get gitsigns module
local function get_gitsigns()
  local ok, gitsigns = pcall(require, "gitsigns")
  if not ok then return nil end
  return gitsigns
end

-- Check if current file has git changes
local function has_git_changes()
  local git_nav = get_git_nav()
  if not git_nav then return false end

  local files = git_nav.get_changed_files()
  local current_file = vim.fn.expand("%:.")

  for _, file in ipairs(files) do
    if file.name == current_file then return true end
  end
  return false
end

-- Navigate to next/previous hunk with cross-file overflow (CORE FEATURE)
-- This is the unique value - everything else is just gitsigns wrappers
function M.navigate_hunk(direction)
  local gitsigns = get_gitsigns()
  local git_nav = get_git_nav()

  if not gitsigns then
    vim.notify("Gitsigns not available", vim.log.levels.WARN)
    return
  end

  if not git_nav then
    vim.notify("Git navigation not available", vim.log.levels.WARN)
    return
  end

  -- Check if current file has changes
  if not has_git_changes() then
    -- Not in a file with changes, jump directly to next/prev changed file
    git_nav.navigate(direction == "next" and "next" or "prev")
    -- Position at first hunk after file switch
    vim.defer_fn(function()
      local gs = get_gitsigns()
      if gs then
        if direction == "next" then
          vim.cmd("normal! gg")
          pcall(gs.next_hunk, {wrap = false, navigation_message = false})
        else
          vim.cmd("normal! G")
          pcall(gs.prev_hunk, {wrap = false, navigation_message = false})
        end
      end
    end, 100)
    return
  end

  -- Save current cursor position to detect if navigation succeeded
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  -- Try to navigate within current file first
  if direction == "next" then
    gitsigns.next_hunk({wrap = false, navigation_message = false})
  else
    gitsigns.prev_hunk({wrap = false, navigation_message = false})
  end

  -- Check if cursor actually moved (more reliable than pcall)
  local new_line = vim.api.nvim_win_get_cursor(0)[1]
  local hunk_found = (new_line ~= current_line)

  -- If no more hunks in current file, overflow to next/prev file
  if not hunk_found then
    local current_file = vim.fn.expand("%:.")
    git_nav.navigate(direction == "next" and "next" or "prev")

    -- After switching files, position at the appropriate hunk
    vim.defer_fn(function()
      local new_file = vim.fn.expand("%:.")
      if new_file ~= current_file then
        -- Successfully switched files
        if direction == "next" then
          -- Go to first hunk of new file
          vim.cmd("normal! gg")
          pcall(gitsigns.next_hunk, {wrap = false, navigation_message = false})
        else
          -- Go to last hunk of new file
          vim.cmd("normal! G")
          pcall(gitsigns.prev_hunk, {wrap = false, navigation_message = false})
        end
        vim.notify("🔄 " .. (direction == "next" and "Next" or "Previous") .. " file with changes", vim.log.levels.INFO)
      end
    end, 100)
  else
    -- Successfully navigated within file
    local line = vim.api.nvim_win_get_cursor(0)[1]
    vim.notify("📍 Hunk at line " .. line, vim.log.levels.INFO)
  end
end

-- Setup commands (minimal - removed gitsigns wrappers)
function M.setup()
  -- Core navigation commands
  vim.api.nvim_create_user_command("GitHunkNext", function()
    M.navigate_hunk("next")
  end, { desc = "Navigate to next git hunk (cross-file overflow)" })

  vim.api.nvim_create_user_command("GitHunkPrev", function()
    M.navigate_hunk("prev")
  end, { desc = "Navigate to previous git hunk (cross-file overflow)" })
end

return M

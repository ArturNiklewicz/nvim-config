-- Enhanced Git Navigation Module
-- Seamless navigation through git changes with proper file handling

local M = {}

-- Cache for git status
M.cache = {
  files = {},
  last_update = 0,
  update_interval = 1000, -- 1 second cache
}

-- Get git root directory
function M.get_git_root()
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return vim.trim(git_root)
end

-- Get all changed files with comprehensive status
function M.get_changed_files(force_refresh)
  local now = vim.loop.now()
  
  -- Use cache if available and fresh
  if not force_refresh and M.cache.last_update > 0 and 
     (now - M.cache.last_update) < M.cache.update_interval then
    return M.cache.files
  end
  
  local git_root = M.get_git_root()
  if not git_root then
    return {}
  end
  
  local files = {}
  local file_map = {}
  
  -- Helper to add file to list
  local function add_file(name, status, staged)
    if name and name ~= "" then
      local full_path = git_root .. "/" .. name
      if not file_map[name] then
        file_map[name] = {
          name = name,
          path = full_path,
          status = status,
          staged = staged,
          exists = vim.fn.filereadable(full_path) == 1
        }
        table.insert(files, file_map[name])
      elseif staged then
        -- Update staging status if this is a staged version
        file_map[name].staged = true
      end
    end
  end
  
  -- Get modified files (unstaged)
  local modified = vim.fn.systemlist("git diff --name-only")
  for _, file in ipairs(modified) do
    add_file(file, "modified", false)
  end
  
  -- Get staged files
  local staged = vim.fn.systemlist("git diff --cached --name-only")
  for _, file in ipairs(staged) do
    add_file(file, "modified", true)
  end
  
  -- Get untracked files
  local untracked = vim.fn.systemlist("git ls-files --others --exclude-standard")
  for _, file in ipairs(untracked) do
    add_file(file, "untracked", false)
  end
  
  -- Sort files by priority
  table.sort(files, function(a, b)
    -- Priority: staged > modified > untracked
    local priority = {
      modified = a.staged and 1 or 2,
      untracked = 3,
    }
    local pa = priority[a.status] or 5
    local pb = priority[b.status] or 5
    
    if pa ~= pb then
      return pa < pb
    end
    return a.name < b.name
  end)
  
  -- Update cache
  M.cache.files = files
  M.cache.last_update = now
  
  return files
end

-- Find current file index in the list
function M.find_current_index(files)
  local current = vim.fn.expand("%:.")
  local current_abs = vim.fn.expand("%:p")
  
  for i, file in ipairs(files) do
    -- Try relative path match first
    if file.name == current then
      return i
    end
    -- Try absolute path match
    if file.path == current_abs then
      return i
    end
    -- Try basename match as fallback
    if vim.fn.fnamemodify(file.name, ":t") == vim.fn.fnamemodify(current, ":t") then
      return i
    end
  end
  
  return 0
end

-- Navigate to file with proper checks and features
function M.navigate_to_file(file)
  if not file then
    return false
  end
  
  -- Check if file exists
  if not file.exists then
    vim.notify("File not found: " .. file.name, vim.log.levels.WARN)
    return false
  end
  
  -- Save current position in jumplist
  vim.cmd("normal! m'")
  
  -- Try to open the file
  local ok = pcall(vim.cmd, "edit " .. vim.fn.fnameescape(file.name))
  if not ok then
    vim.notify("Failed to open: " .. file.name, vim.log.levels.ERROR)
    return false
  end
  
  -- Auto-jump to first change for modified files
  if file.status == "modified" then
    vim.defer_fn(function()
      local has_gitsigns, gitsigns = pcall(require, "gitsigns")
      if has_gitsigns then
        -- Reset to top of file first, then jump to first hunk
        vim.cmd("normal! gg")
        pcall(gitsigns.next_hunk, {wrap = false, navigation_message = false})
      end
    end, 100) -- Increased delay for better reliability
  end
  
  return true
end

-- Main navigation function
function M.navigate(direction)
  local files = M.get_changed_files()
  
  if #files == 0 then
    vim.notify("No git changes found", vim.log.levels.INFO)
    return
  end
  
  local current_index = M.find_current_index(files)
  local next_index
  
  if current_index == 0 then
    -- Not on a git file, start from beginning or end
    next_index = direction == "next" and 1 or #files
  else
    -- Calculate next index with wrapping
    if direction == "next" then
      next_index = current_index % #files + 1
    else
      next_index = current_index - 1
      if next_index < 1 then
        next_index = #files
      end
    end
  end
  
  local target = files[next_index]
  
  -- Navigate to the file
  if M.navigate_to_file(target) then
    -- Show status notification
    local icon = target.staged and "●" or "○"
    local status_text = target.status
    if target.staged then
      status_text = "staged"
    end
    
    vim.notify(string.format("%s %s [%d/%d] %s", 
      icon,
      status_text,
      next_index,
      #files,
      target.name
    ), vim.log.levels.INFO)
  end
end

-- Quick jump to specific file by number
function M.quick_jump(number)
  local files = M.get_changed_files()
  
  if #files == 0 then
    vim.notify("No git changes found", vim.log.levels.INFO)
    return
  end
  
  if number < 1 or number > #files then
    vim.notify(string.format("Invalid file number. Range: 1-%d", #files), vim.log.levels.WARN)
    return
  end
  
  local target = files[number]
  if M.navigate_to_file(target) then
    local icon = target.staged and "●" or "○"
    local status_text = target.staged and "staged" or target.status
    vim.notify(string.format("%s %s [%d/%d] %s", 
      icon,
      status_text,
      number,
      #files,
      target.name
    ), vim.log.levels.INFO)
  end
end

-- List all changed files
function M.list_changes()
  local files = M.get_changed_files(true) -- Force refresh
  
  if #files == 0 then
    vim.notify("No git changes found", vim.log.levels.INFO)
    return
  end
  
  local lines = {"📋 Git Changes:"}
  for i, file in ipairs(files) do
    local icon = file.staged and "●" or "○"
    local status_text = file.staged and "staged" or file.status
    table.insert(lines, string.format("  %2d. %s %-8s %s", i, icon, status_text, file.name))
  end
  
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

-- Setup function
function M.setup()
  -- Create user commands
  vim.api.nvim_create_user_command("GitNext", function()
    M.navigate("next")
  end, { desc = "Navigate to next git change" })
  
  vim.api.nvim_create_user_command("GitPrev", function()
    M.navigate("prev")
  end, { desc = "Navigate to previous git change" })
  
  vim.api.nvim_create_user_command("GitList", function()
    M.list_changes()
  end, { desc = "List all git changes" })
  
  vim.api.nvim_create_user_command("GitJump", function(opts)
    local num = tonumber(opts.args)
    if num then
      M.quick_jump(num)
    else
      vim.notify("Usage: GitJump <number>", vim.log.levels.WARN)
    end
  end, { nargs = 1, desc = "Jump to git change by number" })
  
  -- Auto-refresh cache on file changes
  vim.api.nvim_create_autocmd({"BufWritePost", "FocusGained"}, {
    callback = function()
      M.cache.last_update = 0 -- Invalidate cache
    end,
    desc = "Refresh git status cache"
  })
  
  return M
end

return M
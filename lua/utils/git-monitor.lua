-- Git File Monitor Utility
-- Provides enhanced git file navigation with monitoring capabilities

local M = {}

-- File monitoring state
M.watchlist = {}
M.last_files = {}
M.file_stats = {}

-- Get all git changed files with status
function M.get_git_files()
  local files = {}
  local cwd = vim.fn.getcwd()
  
  -- Get unstaged files
  local unstaged = vim.fn.systemlist("git diff --name-only --relative")
  for _, file in ipairs(unstaged) do
    if file ~= "" then
      files[file] = { status = "modified", staged = false, path = cwd .. "/" .. file }
    end
  end
  
  -- Get staged files
  local staged = vim.fn.systemlist("git diff --cached --name-only --relative")
  for _, file in ipairs(staged) do
    if file ~= "" then
      files[file] = files[file] or { status = "modified", staged = true, path = cwd .. "/" .. file }
      files[file].staged = true
    end
  end
  
  -- Get untracked files
  local untracked = vim.fn.systemlist("git ls-files --others --exclude-standard")
  for _, file in ipairs(untracked) do
    if file ~= "" then
      files[file] = { status = "untracked", staged = false, path = cwd .. "/" .. file }
    end
  end
  
  return files
end

-- Get ordered list of files for navigation
function M.get_file_list()
  local files = M.get_git_files()
  local file_list = {}
  
  -- Convert to ordered list
  for filename, info in pairs(files) do
    table.insert(file_list, { name = filename, info = info })
  end
  
  -- Sort by priority: staged > modified > untracked
  table.sort(file_list, function(a, b)
    local priority_a = a.info.staged and 1 or (a.info.status == "modified" and 2 or 3)
    local priority_b = b.info.staged and 1 or (b.info.status == "modified" and 2 or 3)
    
    if priority_a ~= priority_b then
      return priority_a < priority_b
    end
    return a.name < b.name
  end)
  
  return file_list
end

-- Jump to next/previous file
function M.jump_file(direction)
  local files = M.get_file_list()
  
  if #files == 0 then
    vim.notify("No git changes found", vim.log.levels.INFO)
    return
  end
  
  -- Get current file path relative to git root
  local current_file = vim.fn.expand("%:.")
  local current_index = 0
  
  -- Find current file index (exact match or partial match)
  for i, file in ipairs(files) do
    -- Try exact match first
    if file.name == current_file then
      current_index = i
      break
    end
    -- Try matching just the filename if full path doesn't match
    local current_basename = vim.fn.fnamemodify(current_file, ":t")
    local file_basename = vim.fn.fnamemodify(file.name, ":t")
    if current_basename == file_basename then
      current_index = i
      break
    end
  end
  
  -- If we're not on a git file, start from the beginning
  local next_index
  if current_index == 0 then
    if direction == "next" then
      next_index = 1
    else
      next_index = #files
    end
  else
    -- Calculate next index with proper wrapping
    if direction == "next" then
      next_index = current_index % #files + 1
    else
      next_index = current_index - 1
      if next_index < 1 then next_index = #files end
    end
  end
  
  local target_file = files[next_index]
  
  -- Save current position before jumping
  vim.cmd("normal! m'")
  
  -- Open file and show status
  local ok, err = pcall(vim.cmd, "edit " .. vim.fn.fnameescape(target_file.name))
  if not ok then
    vim.notify("Failed to open file: " .. target_file.name, vim.log.levels.ERROR)
    return
  end
  
  -- Jump to first change in the file if gitsigns is available
  vim.defer_fn(function()
    local has_gitsigns, gitsigns = pcall(require, "gitsigns")
    if has_gitsigns then
      -- Try to jump to first hunk
      pcall(gitsigns.next_hunk, {wrap = false, navigation_message = false})
    end
  end, 50)
  
  local status_icon = target_file.info.staged and "●" or "○"
  local status_text = target_file.info.status == "untracked" and "untracked" or 
                      (target_file.info.staged and "staged" or "modified")
  
  vim.notify(string.format("%s %s [%d/%d] %s", 
    status_icon, 
    status_text, 
    next_index, 
    #files, 
    target_file.name
  ))
end

-- Add file to watchlist
function M.add_to_watchlist(filename)
  filename = filename or vim.fn.expand("%:t")
  if not vim.tbl_contains(M.watchlist, filename) then
    table.insert(M.watchlist, filename)
    vim.notify("Added " .. filename .. " to watchlist", vim.log.levels.INFO)
  else
    vim.notify(filename .. " already in watchlist", vim.log.levels.WARN)
  end
end

-- Remove file from watchlist
function M.remove_from_watchlist(filename)
  filename = filename or vim.fn.expand("%:t")
  for i, file in ipairs(M.watchlist) do
    if file == filename then
      table.remove(M.watchlist, i)
      vim.notify("Removed " .. filename .. " from watchlist", vim.log.levels.INFO)
      return
    end
  end
  vim.notify(filename .. " not in watchlist", vim.log.levels.WARN)
end

-- Show watchlist
function M.show_watchlist()
  if #M.watchlist == 0 then
    vim.notify("Watchlist is empty", vim.log.levels.INFO)
    return
  end
  
  local git_files = M.get_git_files()
  local output = "📋 Git Watchlist:\n"
  
  for i, filename in ipairs(M.watchlist) do
    local status = git_files[filename] and git_files[filename].status or "clean"
    local icon = status == "clean" and "✓" or 
                 status == "modified" and "●" or 
                 status == "untracked" and "?" or "○"
    
    output = output .. string.format("  %s %s (%s)\n", icon, filename, status)
  end
  
  vim.notify(output, vim.log.levels.INFO)
end

-- Jump to next file in watchlist
function M.jump_watchlist(direction)
  if #M.watchlist == 0 then
    vim.notify("Watchlist is empty. Use <Leader>gwa to add files.", vim.log.levels.WARN)
    return
  end
  
  local current_file = vim.fn.expand("%:t")
  local current_index = 0
  
  -- Find current file in watchlist
  for i, file in ipairs(M.watchlist) do
    if file == current_file then
      current_index = i
      break
    end
  end
  
  -- Calculate next index
  local next_index
  if direction == "next" then
    next_index = current_index % #M.watchlist + 1
  else
    next_index = current_index - 1
    if next_index < 1 then next_index = #M.watchlist end
  end
  
  local target_file = M.watchlist[next_index]
  local git_files = M.get_git_files()
  local file_info = git_files[target_file]
  
  -- Open file
  vim.cmd("edit " .. target_file)
  
  -- Show status
  local status = file_info and file_info.status or "clean"
  local icon = status == "clean" and "✓" or 
               status == "modified" and "●" or 
               status == "untracked" and "?" or "○"
  
  vim.notify(string.format("%s %s [%d/%d watchlist] %s", 
    icon, 
    status, 
    next_index, 
    #M.watchlist, 
    target_file
  ))
end

-- Monitor file changes and notify
function M.monitor_changes()
  local current_files = M.get_git_files()
  
  -- Compare with last known state
  for filename, info in pairs(current_files) do
    if not M.last_files[filename] then
      -- New file detected
      if vim.tbl_contains(M.watchlist, filename) then
        vim.notify("📝 Watched file changed: " .. filename, vim.log.levels.INFO)
      end
    elseif M.last_files[filename].status ~= info.status then
      -- Status changed
      if vim.tbl_contains(M.watchlist, filename) then
        vim.notify("🔄 Status changed: " .. filename .. " (" .. info.status .. ")", vim.log.levels.INFO)
      end
    end
  end
  
  -- Check for cleaned files
  for filename, _ in pairs(M.last_files) do
    if not current_files[filename] then
      if vim.tbl_contains(M.watchlist, filename) then
        vim.notify("✅ File cleaned: " .. filename, vim.log.levels.INFO)
      end
    end
  end
  
  M.last_files = current_files
end

-- Auto-monitor setup
function M.setup_auto_monitor()
  -- Monitor every 5 seconds
  local timer = vim.loop.new_timer()
  timer:start(5000, 5000, vim.schedule_wrap(function()
    M.monitor_changes()
  end))
end

return M
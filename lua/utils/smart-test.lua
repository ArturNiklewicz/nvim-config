-- Smart test runner that opens terminal in the right code window
local M = {}

-- Helper: Check if window is special (Neo-tree, Oil, terminal, help, floating)
local function is_special_window(winid)
  if not vim.api.nvim_win_is_valid(winid) then
    return true
  end

  local bufnr = vim.api.nvim_win_get_buf(winid)
  local filetype = vim.bo[bufnr].filetype
  local buftype = vim.bo[bufnr].buftype

  -- Check if floating window
  local config = vim.api.nvim_win_get_config(winid)
  if config.relative ~= '' then
    return true
  end

  -- Filter out special window types
  local special_filetypes = {
    'neo-tree',
    'NvimTree',
    'oil',  -- Oil.nvim file explorer
    'aerial',
    'Outline',
    'toggleterm',
    'help',
    'qf', -- quickfix
  }

  local special_buftypes = {
    'terminal',
    'prompt',
    'help',
    'quickfix',
    'acwrite', -- Oil uses acwrite
  }

  for _, ft in ipairs(special_filetypes) do
    if filetype == ft then
      return true
    end
  end

  for _, bt in ipairs(special_buftypes) do
    if buftype == bt then
      return true
    end
  end

  return false
end

-- Helper: Recursively collect all leaf windows from layout
local function collect_leaf_windows(layout)
  local windows = {}

  if layout[1] == 'leaf' then
    table.insert(windows, layout[2])
  elseif layout[1] == 'row' or layout[1] == 'col' then
    for _, child in ipairs(layout[2]) do
      vim.list_extend(windows, collect_leaf_windows(child))
    end
  end

  return windows
end

-- Find the rightmost code window (ignoring special windows)
local function find_target_window()
  local layout = vim.fn.winlayout()

  -- If single window or simple layout, use current window
  if layout[1] == 'leaf' then
    return vim.api.nvim_get_current_win()
  end

  -- For row layout (side-by-side windows), find rightmost code window
  if layout[1] == 'row' then
    local columns = layout[2]
    local code_windows = {}

    -- Process each column from left to right
    for _, col_layout in ipairs(columns) do
      local windows = collect_leaf_windows(col_layout)

      -- Find code windows in this column
      for _, winid in ipairs(windows) do
        if not is_special_window(winid) then
          table.insert(code_windows, winid)
        end
      end
    end

    -- If we have exactly 2 code windows, use the rightmost one
    if #code_windows == 2 then
      return code_windows[2]
    end

    -- Otherwise, if we have any code windows, use the last one
    if #code_windows > 0 then
      return code_windows[#code_windows]
    end
  end

  -- Fallback: use current window
  return vim.api.nvim_get_current_win()
end

-- Run a vim-test command in the smart target window
function M.run_test(test_type)
  -- Save current window
  local orig_win = vim.api.nvim_get_current_win()

  -- Find target window
  local target_win = find_target_window()

  -- Switch to target window
  vim.api.nvim_set_current_win(target_win)

  -- Run the appropriate test command
  local commands = {
    nearest = "TestNearest",
    file = "TestFile",
    suite = "TestSuite",
    last = "TestLast",
  }

  local cmd = commands[test_type]
  if cmd then
    vim.cmd(cmd)
  else
    vim.notify(string.format("Unknown test type: %s", test_type), vim.log.levels.ERROR)
    -- Switch back to original window on error
    vim.api.nvim_set_current_win(orig_win)
  end

  -- Note: We DON'T switch back - we stay in the terminal window
  -- User can switch back with <C-w>h or <Alt-1>
end

return M

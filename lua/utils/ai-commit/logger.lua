-- Logger module for AI commit message generation
-- Provides structured logging with levels and formatting

local M = {}

-- Log levels
local LEVELS = {
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4
}

-- Current log level
local current_level = LEVELS.INFO

-- Log level colors for Neovim
local level_highlights = {
  DEBUG = "Comment",
  INFO = "Normal",
  WARN = "WarningMsg",
  ERROR = "ErrorMsg"
}

-- Setup logger with specified level
function M.setup(level)
  if type(level) == "string" then
    current_level = LEVELS[level:upper()] or LEVELS.INFO
  elseif type(level) == "number" then
    current_level = level
  end
end

-- Format log message with timestamp and level
local function format_message(level_name, message)
  local timestamp = os.date("%H:%M:%S")
  return string.format("[%s] [AI-Commit %s] %s", timestamp, level_name, message)
end

-- Log with specified level
local function log(level, level_name, message)
  if level < current_level then
    return
  end
  
  local formatted = format_message(level_name, message)
  
  -- Use vim.notify for user-facing messages
  if level >= LEVELS.INFO then
    local vim_level = vim.log.levels.INFO
    if level == LEVELS.WARN then
      vim_level = vim.log.levels.WARN
    elseif level == LEVELS.ERROR then
      vim_level = vim.log.levels.ERROR
    end
    
    vim.schedule(function()
      vim.notify(message, vim_level, { title = "AI Commit" })
    end)
  end
  
  -- Always write to debug log if available
  if vim.fn.exists("*writefile") == 1 then
    local log_file = vim.fn.stdpath("cache") .. "/ai-commit.log"
    vim.fn.writefile({ formatted }, log_file, "a")
  end
end

-- Public logging methods
function M.debug(message)
  log(LEVELS.DEBUG, "DEBUG", message)
end

function M.info(message)
  log(LEVELS.INFO, "INFO", message)
end

function M.warn(message)
  log(LEVELS.WARN, "WARN", message)
end

function M.error(message)
  log(LEVELS.ERROR, "ERROR", message)
end

-- Log table for debugging
function M.debug_table(label, tbl)
  if current_level > LEVELS.DEBUG then
    return
  end
  
  local lines = { label .. ":" }
  local function add_lines(t, indent)
    for k, v in pairs(t) do
      if type(v) == "table" then
        table.insert(lines, indent .. tostring(k) .. ":")
        add_lines(v, indent .. "  ")
      else
        table.insert(lines, indent .. tostring(k) .. " = " .. tostring(v))
      end
    end
  end
  
  add_lines(tbl, "  ")
  M.debug(table.concat(lines, "\n"))
end

-- Clear log file
function M.clear_log()
  local log_file = vim.fn.stdpath("cache") .. "/ai-commit.log"
  vim.fn.writefile({}, log_file)
  M.info("Log file cleared")
end

-- Show log file in buffer
function M.show_log()
  local log_file = vim.fn.stdpath("cache") .. "/ai-commit.log"
  if vim.fn.filereadable(log_file) == 0 then
    M.info("No log file found")
    return
  end
  
  vim.cmd("split " .. log_file)
  vim.bo.modifiable = false
  vim.bo.buftype = "nofile"
  vim.bo.filetype = "log"
  
  -- Add keymaps for log buffer
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true })
  vim.keymap.set("n", "R", function()
    vim.cmd("e!")
    M.info("Log refreshed")
  end, { buffer = true, desc = "Refresh log" })
  vim.keymap.set("n", "C", function()
    M.clear_log()
    vim.cmd("close")
  end, { buffer = true, desc = "Clear log" })
end

-- Get current log level
function M.get_level()
  for name, level in pairs(LEVELS) do
    if level == current_level then
      return name
    end
  end
  return "UNKNOWN"
end

-- Set log level
function M.set_level(level)
  M.setup(level)
  M.info("Log level set to " .. M.get_level())
end

return M
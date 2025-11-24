-- Utility to trace vim.notify reassignments for debugging
-- Usage: :lua require("utils.notify-tracer").start()
-- View log: :e ~/.local/share/nvim/cache/notify_trace.log

local M = {}

local log_file = vim.fn.stdpath("cache") .. "/notify_trace.log"
local tracing = false

local function log(msg)
  local f = io.open(log_file, "a")
  if f then
    f:write(os.date("%H:%M:%S.") .. string.format("%03d", math.floor((vim.uv.hrtime() / 1000000) % 1000)) .. " - " .. msg .. "\n")
    f:close()
  end
end

function M.start()
  if tracing then
    vim.notify("Notify tracer already running", vim.log.levels.WARN)
    return
  end

  tracing = true

  -- Clear previous log
  local f = io.open(log_file, "w")
  if f then
    f:write("=== Notify Trace Started at " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===\n")
    f:close()
  end

  log("Initial vim.notify: " .. tostring(vim.notify))

  -- Store original vim.notify
  local current_notify = vim.notify

  -- Create a wrapper that logs and tracks changes
  local wrapper_count = 0

  local function create_wrapper()
    wrapper_count = wrapper_count + 1
    local wrapper_id = wrapper_count
    local wrapped_notify = current_notify

    return function(msg, level, opts)
      log(string.format("Wrapper #%d called: msg='%s', level=%s",
        wrapper_id,
        tostring(msg):sub(1, 50),
        tostring(level)))

      -- Check if vim.notify has changed since we wrapped it
      if vim.notify ~= wrapped_notify and vim.notify ~= current_notify then
        log(string.format("WARNING: vim.notify changed underneath wrapper #%d!", wrapper_id))
        log("  Old: " .. tostring(wrapped_notify))
        log("  New: " .. tostring(vim.notify))

        -- Get stack trace
        local info = debug.getinfo(2, "Sl")
        log(string.format("  Called from: %s:%s", info.source or "?", info.currentline or "?"))
      end

      return wrapped_notify(msg, level, opts)
    end
  end

  -- Replace vim.notify with our wrapper
  vim.notify = create_wrapper()
  current_notify = vim.notify

  log("Tracer wrapper installed")

  vim.notify("Notify tracer started. Log: " .. log_file, vim.log.levels.INFO)
end

function M.stop()
  if not tracing then
    vim.notify("Notify tracer not running", vim.log.levels.WARN)
    return
  end

  tracing = false
  log("=== Notify Trace Stopped ===\n")
  vim.notify("Notify tracer stopped. Log: " .. log_file, vim.log.levels.INFO)
end

function M.show_log()
  vim.cmd("edit " .. log_file)
end

-- Command to start tracing
vim.api.nvim_create_user_command("NotifyTraceStart", M.start, { desc = "Start tracing vim.notify calls" })
vim.api.nvim_create_user_command("NotifyTraceStop", M.stop, { desc = "Stop tracing vim.notify calls" })
vim.api.nvim_create_user_command("NotifyTraceLog", M.show_log, { desc = "Show notify trace log" })

return M

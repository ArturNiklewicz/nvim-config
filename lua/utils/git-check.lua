-- Git repository check utilities
local M = {}

-- Check if current directory is in a git repository
function M.is_git_repo()
  local ok = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
  return vim.v.shell_error == 0
end

-- Wrapper for git commands that checks for git repo first
function M.safe_git_command(fn, cmd_name)
  return function()
    if not M.is_git_repo() then
      vim.notify("Not in a git repository", vim.log.levels.WARN, { title = cmd_name or "Git" })
      return
    end
    fn()
  end
end

-- Check if a plugin is installed
function M.is_plugin_installed(plugin_name)
  local ok, _ = pcall(require, plugin_name)
  return ok
end

return M
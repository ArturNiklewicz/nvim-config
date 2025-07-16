-- Minimal init.lua for testing
-- This provides a clean environment for running tests

-- Set the runtime path to include the main config
vim.opt.runtimepath:prepend(vim.fn.stdpath("config"))

-- Basic options for testing
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = false
vim.opt.shadafile = "NONE"

-- Load plenary if available
local ok, plenary = pcall(require, "plenary")
if not ok then
  vim.notify("Plenary not found. Tests require plenary.nvim", vim.log.levels.ERROR)
  return
end

-- Optional: Load specific plugins needed for testing
-- You can uncomment and modify as needed
-- require("lazy_setup")  -- If you need lazy.nvim loaded
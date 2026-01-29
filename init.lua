-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.

-- Load .env file from config directory (must run before anything else)
local env_file = vim.fn.stdpath("config") .. "/.env"
local f = io.open(env_file, "r")
if f then
  for line in f:lines() do
    -- Skip empty lines and comments
    if line ~= "" and not line:match("^#") then
      -- Handle: KEY=value, export KEY=value, KEY="value", KEY='value'
      local key, value = line:match("^export%s+([%w_]+)=(.+)$")
      if not key then
        key, value = line:match("^([%w_]+)=(.+)$")
      end
      if key and value then
        -- Strip quotes and inline comments
        value = value:gsub("^[\"']", ""):gsub("[\"']%s*$", ""):gsub("%s+#.*$", "")
        vim.fn.setenv(key, value)
      end
    end
  end
  f:close()
end

local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    -- stylua: ignore
    vim.api.nvim_echo({ { ("Error cloning lazy.nvim:\n%s\n"):format(result), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end
end

vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"

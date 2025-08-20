-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Setup AI commit message generation
local ok, ai_commit = pcall(require, "utils.ai-commit")
if ok then
  ai_commit.setup()
end

-- Set Catppuccin as the main theme (with error handling)
local ok_theme = pcall(vim.cmd.colorscheme, "catppuccin")
if not ok_theme then
  -- Fallback to a built-in theme if Catppuccin isn't loaded yet
  vim.cmd.colorscheme("habamax")
end

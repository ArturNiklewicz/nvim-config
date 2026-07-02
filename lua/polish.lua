-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Defer git utility setup until first real file open (saves startup time)
vim.api.nvim_create_autocmd("User", {
  pattern = "AstroFile",
  once = true,
  group = vim.api.nvim_create_augroup("DeferredGitUtils", { clear = true }),
  callback = function()
    local ok_auto, git_commit_auto = pcall(require, "utils.git-commit-auto")
    if ok_auto then git_commit_auto.setup() end

    local ok_preview, git_preview = pcall(require, "utils.git-preview")
    if ok_preview then git_preview.setup() end

    local ok_nav, git_nav = pcall(require, "utils.git-nav")
    if ok_nav then git_nav.setup() end

    local ok_hunk, git_hunk = pcall(require, "utils.git-hunk-nav")
    if ok_hunk then git_hunk.setup() end
  end,
})

-- Set Catppuccin as the main theme (with error handling)
local ok_theme = pcall(vim.cmd.colorscheme, "tokyonight-night")
if not ok_theme then
  -- Fallback to a built-in theme if Catppuccin isn't loaded yet
  vim.cmd.colorscheme("habamax")
end

-- Hide the buffer tabline while Diffview is open, restore on close
local diffview_grp = vim.api.nvim_create_augroup("DiffviewTabline", { clear = true })
local saved_showtabline

vim.api.nvim_create_autocmd("User", {
  group = diffview_grp,
  pattern = "DiffviewViewOpened",
  callback = function()
    saved_showtabline = vim.o.showtabline
    vim.o.showtabline = 0
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = diffview_grp,
  pattern = "DiffviewViewClosed",
  callback = function()
    vim.o.showtabline = saved_showtabline or 2
  end,
})

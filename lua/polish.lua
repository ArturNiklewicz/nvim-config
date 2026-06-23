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

-- Custom startup layout: ASCII art + Oil.nvim
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("CustomStartupLayout", { clear = true }),
  once = true,
  callback = function()
    -- Only trigger on startup with no file arguments
    if vim.fn.argc() == 0 then
      vim.defer_fn(function()
        -- Get current buffer info
        local buftype = vim.bo.filetype
        local bufname = vim.api.nvim_buf_get_name(0)

        -- Check if we're on a dashboard-like buffer
        if bufname == "" or buftype == "snacks_dashboard" or buftype == "" then
          -- Save current window (dashboard)
          local dashboard_win = vim.api.nvim_get_current_win()

          -- Create horizontal split below (66% height for Oil, 33% for ASCII art)
          vim.cmd("below " .. math.floor(vim.o.lines * 0.66) .. "split")

          -- Open Oil.nvim in the bottom split
          local ok_oil, oil = pcall(require, "oil")
          if ok_oil then
            oil.open()
          else
            vim.notify("Oil.nvim not loaded", vim.log.levels.WARN)
          end

          -- Focus back to dashboard
          vim.api.nvim_set_current_win(dashboard_win)

          -- Disable UI elements in dashboard window
          vim.wo[dashboard_win].number = false
          vim.wo[dashboard_win].relativenumber = false
          vim.wo[dashboard_win].signcolumn = "no"
          vim.wo[dashboard_win].cursorline = false
          vim.wo[dashboard_win].cursorcolumn = false
        end
      end, 100) -- Delay to ensure dashboard is fully loaded
    end
  end,
})

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

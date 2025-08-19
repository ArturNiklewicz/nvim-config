return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  priority = 900, -- Load before other plugins
  init = function()
    -- Disable default mappings - we'll create our own
    vim.g.tmux_navigator_no_mappings = 1
    vim.g.tmux_navigator_save_on_switch = 2
    vim.g.tmux_navigator_disable_when_zoomed = 1
    vim.g.tmux_navigator_preserve_zoom = 1
  end,
  config = function()
    -- Set up the keymaps after the plugin loads
    local map = vim.keymap.set
    
    -- These need to be in normal, visual, and operator-pending modes
    local modes = {'n', 'v', 'o'}
    
    for _, mode in ipairs(modes) do
      map(mode, '<C-h>', '<cmd>TmuxNavigateLeft<cr>', { desc = "Navigate Left", silent = true })
      map(mode, '<C-j>', '<cmd>TmuxNavigateDown<cr>', { desc = "Navigate Down", silent = true })
      map(mode, '<C-k>', '<cmd>TmuxNavigateUp<cr>', { desc = "Navigate Up", silent = true })
      map(mode, '<C-l>', '<cmd>TmuxNavigateRight<cr>', { desc = "Navigate Right", silent = true })
      map(mode, '<C-\\>', '<cmd>TmuxNavigatePrevious<cr>', { desc = "Navigate Previous", silent = true })
    end
    
    -- Also set up in insert and terminal modes for seamless navigation
    map('i', '<C-h>', '<ESC><cmd>TmuxNavigateLeft<cr>', { desc = "Navigate Left", silent = true })
    map('i', '<C-j>', '<ESC><cmd>TmuxNavigateDown<cr>', { desc = "Navigate Down", silent = true })
    map('i', '<C-k>', '<ESC><cmd>TmuxNavigateUp<cr>', { desc = "Navigate Up", silent = true })
    map('i', '<C-l>', '<ESC><cmd>TmuxNavigateRight<cr>', { desc = "Navigate Right", silent = true })
    
    -- Terminal mode mappings
    map('t', '<C-h>', '<C-\\><C-n><cmd>TmuxNavigateLeft<cr>', { desc = "Navigate Left", silent = true })
    map('t', '<C-j>', '<C-\\><C-n><cmd>TmuxNavigateDown<cr>', { desc = "Navigate Down", silent = true })
    map('t', '<C-k>', '<C-\\><C-n><cmd>TmuxNavigateUp<cr>', { desc = "Navigate Up", silent = true })
    map('t', '<C-l>', '<C-\\><C-n><cmd>TmuxNavigateRight<cr>', { desc = "Navigate Right", silent = true })
  end,
}
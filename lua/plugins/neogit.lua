-- Neogit: Magit-inspired Git interface for Neovim
-- Provides comprehensive git workflow with staging, committing, and branch management
-- Integrates with Telescope for fuzzy finding and Diffview for enhanced diffs

return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "sindrets/diffview.nvim", -- Already configured in diffview.lua
  },
  cmd = "Neogit",
  init = function()
    -- Set up autocmd to enable relative line numbers in Neogit buffers
    vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWinEnter" }, {
      pattern = { "NeogitStatus", "NeogitCommitView", "NeogitPopup", "NeogitLogView" },
      callback = function()
        -- Force line numbers to be visible with a small delay to override Neogit's settings
        vim.defer_fn(function()
          vim.wo.number = true
          vim.wo.relativenumber = true
          vim.wo.signcolumn = "yes"
          vim.wo.cursorline = true
          vim.wo.numberwidth = 4
          vim.wo.foldcolumn = "0"  -- Ensure fold column doesn't hide numbers
        end, 10)
      end,
      desc = "Enable relative line numbers in Neogit buffers"
    })
    
    -- Also set for when buffer name contains Neogit
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname:match("Neogit") then
          vim.defer_fn(function()
            vim.wo.number = true
            vim.wo.relativenumber = true
            vim.wo.signcolumn = "yes"
            vim.wo.cursorline = true
            vim.wo.numberwidth = 4
          end, 10)
        end
      end,
      desc = "Force line numbers in Neogit buffers"
    })
  end,
  keys = {
    { "<leader>gN", "<cmd>Neogit<cr>", desc = "Neogit status" },
    { "<leader>gM", "<cmd>Neogit commit<cr>", desc = "Commit with Neogit" },
  },
  opts = {
    -- Signs configuration for visual clarity
    disable_signs = false,
    signs = {
      -- Sections
      section = { "", "" },  -- Expanded, Collapsed
      item = { "", "" },
      hunk = { "", "" },
    },
    -- Use Telescope for selection
    integrations = {
      telescope = true,
      diffview = true,
    },
    -- Graph style
    graph_style = "unicode",
    -- Use insert mode for commit editor by default
    commit_editor = {
      kind = "split",
      show_staged_diff = true,
      -- Start in insert mode for faster typing
      staged_diff_split_kind = "split",
    },
    -- Configure commit popup
    commit_popup = {
      kind = "split",
    },
    -- Custom mappings configuration with proper action names
    mappings = {
      status = {
        -- Navigation (with relative line number support)
        ["j"] = "MoveDown",
        ["k"] = "MoveUp",
        ["<down>"] = "MoveDown",
        ["<up>"] = "MoveUp",
        -- gg and G will use default vim motions, not custom mappings
        -- Sections
        ["o"] = "OpenTree",
        ["<tab>"] = "Toggle",
        -- File operations
        ["s"] = "Stage",
        ["u"] = "Unstage",
        ["S"] = "StageAll",
        ["U"] = "UnstageStaged",
        ["x"] = "Discard",
        -- Navigation to files
        ["<cr>"] = "GoToFile",
        ["<c-s>"] = "SplitOpen",
        ["<c-v>"] = "VSplitOpen",
        ["<c-t>"] = "TabOpen",
        -- Don't override 'p' as it's used for pull popup
        -- Git command keys - leave unmapped to use Neogit's default popup behavior
        -- c = commit popup (default)
        -- d = diff popup (default)
        -- l = log popup (default)
        -- P = push popup (default)
        -- p = pull popup (default)
        -- r = rebase popup (default)
        -- z = stash popup (default)
        -- Diff hunks
        ["]c"] = "GoToNextHunkHeader",
        ["[c"] = "GoToPreviousHunkHeader",
        -- Sections
        ["]s"] = "NextSection",
        ["[s"] = "PreviousSection",
        -- Other
        ["y"] = "YankSelected",
        ["q"] = "Close",
        ["<esc>"] = "Close",
        -- Don't override 'g?' as it's used for help popup
        ["R"] = "RefreshBuffer",
        ["<F5>"] = "RefreshBuffer",
      },
      -- Other buffer mappings can be added here if needed
      commit_editor = {
        ["q"] = "Close",
        ["<c-c><c-c>"] = "Submit",
        ["<c-c><c-k>"] = "Abort",
      },
    },
    -- Remember settings per repository
    remember_settings = true,
    -- Auto refresh on focus
    auto_refresh = true,
    -- Sort branches by recency
    sort_branches = "-committerdate",
    -- Console notification settings
    notification_icon = "󰊢",
    -- Status buffer configuration
    status = {
      recent_commit_count = 10,
    },
    -- Section configuration
    sections = {
      untracked = {
        folded = false,
        hidden = false,
      },
      unstaged = {
        folded = false,
        hidden = false,
      },
      staged = {
        folded = false,
        hidden = false,
      },
      stashes = {
        folded = true,
        hidden = false,
      },
      unpulled = {
        folded = true,
        hidden = false,
      },
      unmerged = {
        folded = false,
        hidden = false,
      },
      recent = {
        folded = true,
        hidden = false,
      },
    },
  },
}
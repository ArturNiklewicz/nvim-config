-- Diffview.nvim - Single tabpage interface for cycling through diffs
return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewRefresh",
    "DiffviewFileHistory",
  },
  keys = {
    { "<Leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff view" },
    { "<Leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
    { "<Leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    { "<Leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
  },
  opts = {
    diff_binaries = false,
    enhanced_diff_hl = false,
    use_icons = true,
    icons = {
      folder_closed = "",
      folder_open = "",
    },
    signs = {
      fold_closed = "",
      fold_open = "",
      done = "✓",
    },
    view = {
      default = {
        layout = "diff2_horizontal",  -- Valid layout: side-by-side diff
        winbar_info = false,
      },
      merge_tool = {
        layout = "diff3_horizontal",
        disable_diagnostics = true,
        winbar_info = true,
      },
      file_history = {
        layout = "diff2_horizontal",  -- Valid layout for file history
        winbar_info = false,
      },
    },
    file_panel = {
      listing_style = "tree",
      tree_options = {
        flatten_dirs = true,
        folder_statuses = "only_folded",
      },
      win_config = {
        position = "left",
        width = 35,
        win_opts = {},
      },
    },
    file_history_panel = {
      log_options = {
        git = {
          single_file = {
            diff_merges = "combined",
          },
          multi_file = {
            diff_merges = "first-parent",
          },
        },
      },
      win_config = {
        position = "bottom",
        height = 16,
        win_opts = {},
      },
    },
    commit_log_panel = {
      win_config = {},
    },
    default_args = {
      DiffviewOpen = {},
      DiffviewFileHistory = {},
    },
    hooks = {},
    keymaps = {
      disable_defaults = false,
      view = {
        ["<tab>"] = "<cmd>DiffviewToggleFiles<cr>",
        ["<leader>e"] = "<cmd>DiffviewFocusFiles<cr>",
        ["<leader>b"] = "<cmd>DiffviewToggleFiles<cr>",
        ["<leader>gv"] = {
          function()
            local actions = require("diffview.actions")
            actions.cycle_layout()
          end,
          desc = "Cycle diff view layout",
        },
      },
      file_panel = {
        ["j"] = "<cmd>DiffviewNextEntry<cr>",
        ["<down>"] = "<cmd>DiffviewNextEntry<cr>",
        ["k"] = "<cmd>DiffviewPrevEntry<cr>",
        ["<up>"] = "<cmd>DiffviewPrevEntry<cr>",
        ["<cr>"] = "<cmd>DiffviewSelect<cr>",
        ["o"] = "<cmd>DiffviewOpenFile<cr>",
        ["<2-LeftMouse>"] = "<cmd>DiffviewSelect<cr>",
        ["-"] = "<cmd>DiffviewToggleStage<cr>",
        ["S"] = "<cmd>DiffviewStageAll<cr>",
        ["U"] = "<cmd>DiffviewUnstageAll<cr>",
        ["X"] = "<cmd>DiffviewRestoreEntry<cr>",
        ["L"] = "<cmd>DiffviewOpenCommitLog<cr>",
        ["<c-b>"] = "<cmd>DiffviewScrollDown<cr>",
        ["<c-f>"] = "<cmd>DiffviewScrollUp<cr>",
        ["<tab>"] = "<cmd>DiffviewToggleFiles<cr>",
        ["<leader>e"] = "<cmd>DiffviewFocusFiles<cr>",
        ["<leader>b"] = "<cmd>DiffviewToggleFiles<cr>",
        ["<leader>gv"] = {
          function()
            local actions = require("diffview.actions")
            actions.cycle_layout()
          end,
          desc = "Cycle diff view layout",
        },
        ["gf"] = "<cmd>DiffviewGotoFile<cr>",
        ["<C-w><C-f>"] = "<cmd>DiffviewGotoFileTab<cr>",
        ["<C-w>gf"] = "<cmd>DiffviewGotoFileTab<cr>",
        ["i"] = "<cmd>DiffviewToggleFlattenDirs<cr>",
        ["R"] = "<cmd>DiffviewRefresh<cr>",
      },
      file_history_panel = {
        ["g!"] = "<cmd>DiffviewOptions<cr>",
        ["<C-A-d>"] = "<cmd>DiffviewOpenDiff<cr>",
        ["y"] = "<cmd>DiffviewYankEntry<cr>",
        ["L"] = "<cmd>DiffviewOpenCommitLog<cr>",
        ["zR"] = "<cmd>DiffviewOpenAllFolds<cr>",
        ["zM"] = "<cmd>DiffviewCloseAllFolds<cr>",
        ["j"] = "<cmd>DiffviewNextEntry<cr>",
        ["<down>"] = "<cmd>DiffviewNextEntry<cr>",
        ["k"] = "<cmd>DiffviewPrevEntry<cr>",
        ["<up>"] = "<cmd>DiffviewPrevEntry<cr>",
        ["<cr>"] = "<cmd>DiffviewSelect<cr>",
        ["o"] = "<cmd>DiffviewOpenFile<cr>",
        ["<2-LeftMouse>"] = "<cmd>DiffviewSelect<cr>",
        ["<c-b>"] = "<cmd>DiffviewScrollDown<cr>",
        ["<c-f>"] = "<cmd>DiffviewScrollUp<cr>",
        ["<tab>"] = "<cmd>DiffviewToggleFiles<cr>",
        ["<leader>e"] = "<cmd>DiffviewFocusFiles<cr>",
        ["<leader>b"] = "<cmd>DiffviewToggleFiles<cr>",
        ["<leader>gv"] = {
          function()
            local actions = require("diffview.actions")
            actions.cycle_layout()
          end,
          desc = "Cycle diff view layout",
        },
        ["gf"] = "<cmd>DiffviewGotoFile<cr>",
        ["<C-w><C-f>"] = "<cmd>DiffviewGotoFileTab<cr>",
        ["<C-w>gf"] = "<cmd>DiffviewGotoFileTab<cr>",
      },
      option_panel = {
        ["<tab>"] = "<cmd>DiffviewSelectEntry<cr>",
        ["q"] = "<cmd>DiffviewClose<cr>",
      },
    },
  },
}
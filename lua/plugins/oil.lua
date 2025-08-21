-- Oil.nvim - Superior file management
-- Replace clunky file operations with a buffer-based file manager

return {
  -- Disable Neo-tree completely
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
  -- Oil.nvim configuration
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    priority = 999,
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
      { "<Leader>-", "<cmd>Oil .<cr>", desc = "Open current directory" },
      {
        "<Leader>E",
        function()
          -- Enhanced float toggle with dynamic sizing
          local oil = require "oil"
          oil.toggle_float()
        end,
        desc = "Toggle Oil float (auto-sized)",
      },
      {
        "<Leader>o",
        function()
          -- Smart toggle Oil: opens in sidebar if not open, closes if open
          local oil_buffers = vim.tbl_filter(
            function(buf) return vim.bo[buf].filetype == "oil" end,
            vim.api.nvim_list_bufs()
          )
          if #oil_buffers > 0 then
            -- Close oil buffers
            for _, buf in ipairs(oil_buffers) do
              local wins = vim.fn.win_findbuf(buf)
              for _, win in ipairs(wins) do
                vim.api.nvim_win_close(win, false)
              end
            end
          else
            -- Open oil in vertical split with better sizing
            vim.cmd "vsplit"
            vim.cmd "Oil ."
            vim.cmd "vertical resize 40" -- Increased width for better visibility
            -- Set window options for better display
            vim.wo.number = false
            vim.wo.relativenumber = false
            vim.wo.signcolumn = "no"
            vim.wo.foldcolumn = "0"
            vim.wo.wrap = false
          end
        end,
        desc = "Toggle Oil sidebar",
      },
    },
    opts = {
      default_file_explorer = true,
      columns = {
        "permissions",
        "size",
        "mtime",
        "icon",  -- Icon without highlight override to use natural colors
      },
      -- Configure icons
      experimental_watch_for_changes = true,
      constrain_cursor = "editable",
      buf_options = {
        buflisted = false,
        bufhidden = "hide",
      },
      win_options = {
        wrap = false,
        signcolumn = "no",
        cursorcolumn = false,
        foldcolumn = "0",
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "nvic",
      },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      prompt_save_on_select_new_entry = false,
      cleanup_delay_ms = 2000,
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<BS>"] = "actions.parent",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split", -- Changed from <C-h> to <C-s> for horizontal split
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh", -- Changed from <C-l> to <C-r> for refresh
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
        ["gd"] = {
          desc = "Toggle detail view",
          callback = function()
            local oil = require "oil"
            local config = require "oil.config"
            if #config.columns == 1 then
              -- Show all columns with icons after mtime
              oil.set_columns {
                "permissions",
                "size",
                "mtime",
                "icon",  -- Natural colored icons
              }
            else
              -- Show only icons with natural colors
              oil.set_columns {
                "icon",
              }
            end
          end,
        },
        -- Explicitly disable conflicting mappings to allow vim-tmux-navigator to work
        ["<C-h>"] = false,
        ["<C-j>"] = false,
        ["<C-k>"] = false,
        ["<C-l>"] = false,
      },
      use_default_keymaps = true,
      view_options = {
        show_hidden = true,
        is_hidden_file = function(name, bufnr) return vim.startswith(name, ".") end,
        is_always_hidden = function(name, bufnr) return name == ".." or name == ".git" end,
        sort = {
          { "type", "asc" },
          { "name", "asc" },
        },
      },
      float = {
        padding = 2,
        max_width = 0,
        max_height = 0,
        border = "rounded",
        win_options = {
          winblend = 0,
        },
        -- Calculate height to show all entries plus 3 extra rows
        override = function(conf)
          -- Get the Oil buffer
          local oil = require "oil"
          local bufnr = vim.api.nvim_get_current_buf()

          -- Count lines in the buffer (all entries)
          local line_count = vim.api.nvim_buf_line_count(bufnr)

          -- Calculate height: all entries + 3 extra rows + 2 for border
          local desired_height = math.max(10, line_count + 3)

          -- Get terminal dimensions
          local editor_height = vim.o.lines

          -- Ensure we don't exceed 90% of editor height
          local max_allowed = math.floor(editor_height * 0.9)
          conf.height = math.min(desired_height, max_allowed)

          -- Ensure minimum height of 10 rows
          conf.height = math.max(10, conf.height)

          return conf
        end,
      },
      preview = {
        max_width = 0.9,
        min_width = { 40, 0.4 },
        width = nil,
        max_height = 0.9,
        min_height = { 8, 0.1 }, -- Increased minimum to show more rows
        height = nil,
        border = "rounded",
        win_options = {
          winblend = 0,
        },
        -- Dynamic height calculation for preview
        update = function(conf, entry)
          -- Calculate dynamic height based on content
          local lines = vim.api.nvim_buf_get_lines(entry.bufnr or 0, 0, -1, false)
          local line_count = #lines

          -- Show all lines plus 3 extra rows
          local desired_height = line_count + 3
          local editor_height = vim.o.lines
          local max_allowed = math.floor(editor_height * 0.9)

          conf.height = math.min(desired_height, max_allowed)
          conf.height = math.max(8, conf.height) -- Minimum 8 rows

          return conf
        end,
      },
      progress = {
        max_width = 0.9,
        min_width = { 40, 0.4 },
        width = nil,
        max_height = { 10, 0.9 },
        min_height = { 5, 0.1 },
        height = nil,
        border = "rounded",
        minimized_border = "none",
        win_options = {
          winblend = 0,
        },
      },
    },
    config = function(_, opts)
      -- Ensure nvim-web-devicons is set up with proper colors for each file type
      local devicons = require("nvim-web-devicons")
      devicons.setup({
        color_icons = true,  -- Enable colored icons
        default = true,      -- Use default icon set
        strict = true,       -- Enable strict matching
      })
      
      -- Set up oil with devicon integration
      require("oil").setup(opts)

      -- Auto-open oil.nvim on startup when opening a directory
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(data)
          local directory = vim.fn.isdirectory(data.file) == 1

          if directory then
            require("oil").open()
          elseif data.file == "" then
            -- No file argument, open oil in current directory
            require("oil").open()
          end
        end,
      })
    end,
  },
}

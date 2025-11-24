return {
  -- Disable AstroNvim's heirline to allow bufferline control of tabline
  { "rebelot/heirline.nvim", enabled = false },

  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    lazy = false, -- Ensure early loading
    priority = 1000, -- Load before other UI plugins
    opts = {
      options = {
        mode = "buffers",
        numbers = function(opts)
          -- Enhanced visibility: show ordinal number with prominent styling
          return string.format('%s', opts.ordinal)
        end,
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        indicator = {
          icon = "▎",
          style = "icon",
        },
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 20,
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        persist_buffer_sort = true,
        separator_style = "thin",
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        sort_by = "id",
      },
      highlights = {
        fill = {
          bg = "#1A1C25",
        },
        background = {
          bg = "#1A1C25",
        },
        tab = {
          bg = "#1A1C25",
        },
        tab_selected = {
          bg = "#1A1C25",
        },
        tab_separator = {
          bg = "#1A1C25",
        },
        tab_separator_selected = {
          bg = "#1A1C25",
        },
        close_button = {
          bg = "#1A1C25",
        },
        close_button_visible = {
          bg = "#1A1C25",
        },
        close_button_selected = {
          bg = "#1A1C25",
        },
        buffer_visible = {
          bg = "#1A1C25",
        },
        buffer_selected = {
          bg = "#1A1C25",
        },
        numbers = {
          bg = "#1A1C25",
        },
        numbers_visible = {
          bg = "#1A1C25",
        },
        numbers_selected = {
          bg = "#1A1C25",
        },
        diagnostic = {
          bg = "#1A1C25",
        },
        diagnostic_visible = {
          bg = "#1A1C25",
        },
        diagnostic_selected = {
          bg = "#1A1C25",
        },
        hint = {
          bg = "#1A1C25",
        },
        hint_visible = {
          bg = "#1A1C25",
        },
        hint_selected = {
          bg = "#1A1C25",
        },
        hint_diagnostic = {
          bg = "#1A1C25",
        },
        hint_diagnostic_visible = {
          bg = "#1A1C25",
        },
        hint_diagnostic_selected = {
          bg = "#1A1C25",
        },
        info = {
          bg = "#1A1C25",
        },
        info_visible = {
          bg = "#1A1C25",
        },
        info_selected = {
          bg = "#1A1C25",
        },
        info_diagnostic = {
          bg = "#1A1C25",
        },
        info_diagnostic_visible = {
          bg = "#1A1C25",
        },
        info_diagnostic_selected = {
          bg = "#1A1C25",
        },
        warning = {
          bg = "#1A1C25",
        },
        warning_visible = {
          bg = "#1A1C25",
        },
        warning_selected = {
          bg = "#1A1C25",
        },
        warning_diagnostic = {
          bg = "#1A1C25",
        },
        warning_diagnostic_visible = {
          bg = "#1A1C25",
        },
        warning_diagnostic_selected = {
          bg = "#1A1C25",
        },
        error = {
          bg = "#1A1C25",
        },
        error_visible = {
          bg = "#1A1C25",
        },
        error_selected = {
          bg = "#1A1C25",
        },
        error_diagnostic = {
          bg = "#1A1C25",
        },
        error_diagnostic_visible = {
          bg = "#1A1C25",
        },
        error_diagnostic_selected = {
          bg = "#1A1C25",
        },
        modified = {
          bg = "#1A1C25",
        },
        modified_visible = {
          bg = "#1A1C25",
        },
        modified_selected = {
          bg = "#1A1C25",
        },
        duplicate = {
          bg = "#1A1C25",
        },
        duplicate_visible = {
          bg = "#1A1C25",
        },
        duplicate_selected = {
          bg = "#1A1C25",
        },
        separator = {
          bg = "#1A1C25",
        },
        separator_visible = {
          bg = "#1A1C25",
        },
        separator_selected = {
          bg = "#1A1C25",
        },
        indicator_visible = {
          bg = "#1A1C25",
        },
        indicator_selected = {
          bg = "#1A1C25",
        },
        pick = {
          bg = "#1A1C25",
        },
        pick_visible = {
          bg = "#1A1C25",
        },
        pick_selected = {
          bg = "#1A1C25",
        },
      },
    },
    -- CRITICAL: Initialize bufferline with opts
    config = function(_, opts)
      require("bufferline").setup(opts)
    end,
  },
}
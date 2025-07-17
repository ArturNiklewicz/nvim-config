-- VSCode-like editing enhancements for Neovim
-- Provides multicursor, enhanced search, clipboard management, and text objects

return {
  -- System clipboard integration
  {
    "AstroNvim/astrocore",
    opts = {
      options = {
        opt = {
          clipboard = "unnamedplus", -- VSCode-like clipboard integration
        },
      },
    },
  },
  
  -- Multicursor support (VSCode-like Ctrl+D behavior)
  {
    "smoka7/multicursors.nvim",
    event = "User AstroFile",
    cmd = { "MCstart", "MCpattern", "MCclear", "MCvisualCursor", "MCunderCursor" },
    dependencies = { 
      "nvim-treesitter/nvim-treesitter",
      "smoka7/hydra.nvim",
    },
    opts = {
      hint_config = {
        border = "rounded",
        position = "bottom-right",
      },
      generate_hints = {
        normal = true,
        insert = true,
        extend = true,
        config = {
          column_count = 1,
        },
      },
    },
    keys = {
      {
        "<Leader>cd",
        "<Cmd>MCstart<CR>",
        mode = { "v", "n" },
        desc = "Create multicursor (like Ctrl+D)",
      },
      {
        "<Leader>cn",
        "<Cmd>MCpattern<CR>",
        mode = { "v", "n" },
        desc = "Create multicursor for pattern",
      },
      {
        "<Leader>cc",
        "<Cmd>MCclear<CR>",
        mode = { "n" },
        desc = "Clear all multicursors",
      },
      {
        "<Leader>ca",
        "<Cmd>MCvisualCursor<CR>",
        mode = { "v" },
        desc = "Add cursor at visual selection",
      },
      {
        "<Leader>cw",
        "<Cmd>MCunderCursor<CR>",
        mode = { "n" },
        desc = "Add cursor under word",
      },
      -- Keep some VSCode-style bindings for compatibility
      {
        "<Leader>vd",
        "<Cmd>MCstart<CR>",
        mode = { "v", "n" },
        desc = "Create multicursor (like Ctrl+D)",
      },
    },
  },
  
  -- Word highlighting (VSCode-like word under cursor)
  {
    "RRethy/vim-illuminate",
    event = "User AstroFile",
    opts = {
      delay = 120,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
      filetypes_denylist = {
        "dirbuf",
        "dirvish",
        "fugitive",
        "alpha",
        "NvimTree",
        "lazy",
        "neogitstatus",
        "Trouble",
        "lir",
        "Outline",
        "spectre_panel",
        "toggleterm",
        "DressingSelect",
        "TelescopePrompt",
      },
    },
  },
  
  -- Enhanced search with visual feedback
  {
    "kevinhwang91/nvim-hlslens",
    event = "User AstroFile",
    opts = {
      calm_down = true,
      nearest_only = true,
      nearest_float_when = "always",
    },
    keys = {
      {
        "n",
        "<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>",
        desc = "Next search result",
      },
      {
        "N",
        "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>",
        desc = "Previous search result",
      },
      {
        "*",
        "*<Cmd>lua require('hlslens').start()<CR>",
        desc = "Search word under cursor forward",
      },
      {
        "#",
        "#<Cmd>lua require('hlslens').start()<CR>",
        desc = "Search word under cursor backward",
      },
    },
  },
  
  -- Clipboard manager with history
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "nvim-telescope/telescope.nvim" },
    event = "User AstroFile",
    opts = {
      history = 1000,
      enable_persistent_history = true,
      length_limit = 1048576,
      continuous_sync = true,
      db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
      filter = nil,
      preview = true,
      prompt = nil,
      default_register = '"',
      default_register_macros = 'q',
      enable_macro_history = true,
      content_spec_column = false,
      disable_keycodes_parsing = false,
      on_select = {
        move_to_front = false,
        close_telescope = true,
      },
      on_paste = {
        set_reg = false,
        move_to_front = false,
        close_telescope = true,
      },
      on_replay = {
        set_reg = false,
        move_to_front = false,
        close_telescope = true,
      },
      on_custom_action = {
        close_telescope = true,
      },
      keys = {
        telescope = {
          i = {
            select = '<cr>',
            paste = '<c-p>',
            paste_behind = '<c-P>',
            replay = '<c-q>',
            delete = '<c-d>',
            edit = '<c-e>',
            custom = {},
          },
          n = {
            select = '<cr>',
            paste = 'p',
            paste_behind = 'P',
            replay = 'q',
            delete = 'd',
            edit = 'e',
            custom = {},
          },
        },
      },
    },
  },
  
  -- Enhanced yank with visual feedback
  {
    "gbprod/yanky.nvim",
    event = "User AstroFile",
    opts = {
      ring = {
        history_length = 100,
        storage = "shada",
        sync_with_numbered_registers = true,
        cancel_event = "update",
        ignore_registers = { "_" },
        update_register_on_cycle = false,
      },
      picker = {
        select = {
          action = nil,
        },
        telescope = {
          use_default_mappings = true,
          mappings = nil,
        },
      },
      system_clipboard = {
        sync_with_ring = true,
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 500,
      },
      preserve_cursor_position = {
        enabled = true,
      },
    },
  },
  
  -- Visual search and replace interface
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      color_devicons = true,
      open_cmd = "vnew",
      live_update = false,
      lnum_for_results = true,
      line_sep_start = "┌─────────────────────────────────────────",
      result_padding = "│  ",
      line_sep       = "└─────────────────────────────────────────",
      highlight = {
        ui = "String",
        search = "DiffChange",
        replace = "DiffDelete"
      },
      mapping = {
        ['toggle_line'] = {
          map = "dd",
          cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
          desc = "toggle current item"
        },
        ['enter_file'] = {
          map = "<cr>",
          cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
          desc = "goto current file"
        },
        ['send_to_qf'] = {
          map = "<leader>sq",
          cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
          desc = "send all item to quickfix"
        },
        ['replace_cmd'] = {
          map = "<leader>sc",
          cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
          desc = "input replace vim command"
        },
        ['show_option_menu'] = {
          map = "<leader>so",
          cmd = "<cmd>lua require('spectre').show_options()<CR>",
          desc = "show option"
        },
        ['run_current_replace'] = {
          map = "<leader>sr",
          cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
          desc = "replace current line"
        },
        ['run_replace'] = {
          map = "<leader>sR",
          cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
          desc = "replace all"
        },
        ['change_view_mode'] = {
          map = "<leader>sv",
          cmd = "<cmd>lua require('spectre').change_view()<CR>",
          desc = "change result view mode"
        },
        ['change_replace_sed'] = {
          map = "trs",
          cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
          desc = "use sed to replace"
        },
        ['change_replace_oxi'] = {
          map = "tro",
          cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
          desc = "use oxi to replace"
        },
        ['toggle_live_update'] = {
          map = "tu",
          cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
          desc = "update change when vim write file."
        },
        ['toggle_ignore_case'] = {
          map = "ti",
          cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
          desc = "toggle ignore case"
        },
        ['toggle_ignore_hidden'] = {
          map = "th",
          cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
          desc = "toggle search hidden"
        },
        ['resume_last_search'] = {
          map = "<leader>sl",
          cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
          desc = "resume last search before close"
        },
      },
      find_engine = {
        ['rg'] = {
          cmd = "rg",
          args = {
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
          },
          options = {
            ['ignore-case'] = {
              value = "--ignore-case",
              icon = "[I]",
              desc = "ignore case"
            },
            ['hidden'] = {
              value = "--hidden",
              desc = "hidden file",
              icon = "[H]"
            },
          }
        },
      },
      replace_engine = {
        ['sed'] = {
          cmd = "sed",
          args = nil,
          options = {
            ['ignore-case'] = {
              value = "--ignore-case",
              icon = "[I]",
              desc = "ignore case"
            },
          }
        },
      },
      default = {
        find = {
          cmd = "rg",
          options = {"ignore-case"}
        },
        replace = {
          cmd = "sed"
        }
      },
      replace_vim_cmd = "cdo",
      is_open = false,
      is_insert_mode = false
    },
  },
  
  -- Scrollbar for better navigation context
  {
    "petertriho/nvim-scrollbar",
    event = "User AstroFile",
    opts = {
      show = true,
      show_in_active_only = false,
      set_highlights = true,
      folds = 1000,
      max_lines = false,
      hide_if_all_visible = false,
      throttle_ms = 100,
      handle = {
        text = " ",
        blend = 30,
        color = nil,
        color_nr = nil,
        highlight = "CursorColumn",
        hide_if_all_visible = true,
      },
      marks = {
        Cursor = {
          text = "•",
          priority = 0,
          gui = nil,
          color = nil,
          cterm = nil,
          color_nr = nil,
          highlight = "Normal",
        },
        Search = {
          text = { "-", "=" },
          priority = 1,
          gui = nil,
          color = "orange",
          cterm = nil,
          color_nr = nil,
          highlight = "Search",
        },
        Error = {
          text = { "-", "=" },
          priority = 2,
          gui = nil,
          color = "red",
          cterm = nil,
          color_nr = nil,
          highlight = "DiagnosticVirtualTextError",
        },
        Warn = {
          text = { "-", "=" },
          priority = 3,
          gui = nil,
          color = "yellow",
          cterm = nil,
          color_nr = nil,
          highlight = "DiagnosticVirtualTextWarn",
        },
        Info = {
          text = { "-", "=" },
          priority = 4,
          gui = nil,
          color = "blue",
          cterm = nil,
          color_nr = nil,
          highlight = "DiagnosticVirtualTextInfo",
        },
        Hint = {
          text = { "-", "=" },
          priority = 5,
          gui = nil,
          color = "green",
          cterm = nil,
          color_nr = nil,
          highlight = "DiagnosticVirtualTextHint",
        },
        Misc = {
          text = { "-", "=" },
          priority = 6,
          gui = nil,
          color = "purple",
          cterm = nil,
          color_nr = nil,
          highlight = "Normal",
        },
        GitAdd = {
          text = "┆",
          priority = 7,
          gui = nil,
          color = "green",
          cterm = nil,
          color_nr = nil,
          highlight = "GitSignsAdd",
        },
        GitChange = {
          text = "┆",
          priority = 7,
          gui = nil,
          color = "yellow",
          cterm = nil,
          color_nr = nil,
          highlight = "GitSignsChange",
        },
        GitDelete = {
          text = "▁",
          priority = 7,
          gui = nil,
          color = "red",
          cterm = nil,
          color_nr = nil,
          highlight = "GitSignsDelete",
        },
      },
      excluded_buftypes = {
        "terminal",
      },
      excluded_filetypes = {
        "cmp_docs",
        "cmp_menu",
        "noice",
        "prompt",
        "TelescopePrompt",
        "alpha",
      },
      autocmd = {
        render = {
          "BufWinEnter",
          "TabEnter",
          "TermEnter",
          "WinEnter",
          "CmdwinLeave",
          "TextChanged",
          "VimResized",
          "WinScrolled",
        },
        clear = {
          "BufWinLeave",
          "TabLeave",
          "TermLeave",
          "WinLeave",
        },
      },
      handlers = {
        cursor = true,
        diagnostic = true,
        gitsigns = true,
        handle = true,
        search = true,
        ale = false,
      },
    },
  },
}
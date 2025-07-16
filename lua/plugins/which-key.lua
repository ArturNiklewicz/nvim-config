-- which-key.nvim configuration for visual menu discovery
-- Provides instant visual hints for all keybindings when pressing leader key

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    operators = { gc = "Comments" },
    key_labels = {
      ["<space>"] = "SPC",
      ["<cr>"] = "RET",
      ["<tab>"] = "TAB",
    },
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    popup_mappings = {
      scroll_down = "<c-d>",
      scroll_up = "<c-u>",
    },
    window = {
      border = "rounded",
      position = "bottom",
      margin = { 1, 0, 1, 0 },
      padding = { 2, 2, 2, 2 },
      winblend = 0,
    },
    layout = {
      height = { min = 4, max = 25 },
      width = { min = 20, max = 50 },
      spacing = 3,
      align = "left",
    },
    ignore_missing = false,
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
    show_help = true,
    show_keys = true,
    triggers = "auto",
    triggers_blacklist = {
      i = { "j", "k" },
      v = { "j", "k" },
    },
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    
    -- Register group names for better organization
    wk.register({
      ["<leader>"] = {
        a = { name = "󰚩 AI/Claude", _ = "which_key_ignore" },
        b = { name = " Buffers", _ = "which_key_ignore" },
        c = { name = " Code/LSP", _ = "which_key_ignore" },
        f = { name = " Find/Files", _ = "which_key_ignore" },
        g = { name = " Git/GitHub", _ = "which_key_ignore" },
        j = { name = "󰪫 Jupyter/Molten", _ = "which_key_ignore" },
        l = { name = " LSP", _ = "which_key_ignore" },
        m = { name = " Messages", _ = "which_key_ignore" },
        o = { name = " Octo/GitHub", _ = "which_key_ignore" },
        p = { name = " Packages", _ = "which_key_ignore" },
        r = { name = "󰛔 Replace/Refactor", _ = "which_key_ignore" },
        s = { name = " Search", _ = "which_key_ignore" },
        t = { name = " Test", _ = "which_key_ignore" },
        u = { name = " UI/Toggles", _ = "which_key_ignore" },
        v = { name = " VSCode", _ = "which_key_ignore" },
        w = { name = " Windows", _ = "which_key_ignore" },
        x = { name = " Diagnostics", _ = "which_key_ignore" },
        z = { name = " Zen", _ = "which_key_ignore" },
      },
      -- Visual mode groups
      ["<leader>"] = {
        mode = { "v" },
        a = { name = "󰚩 AI/Claude", _ = "which_key_ignore" },
        j = { name = "󰪫 Jupyter", _ = "which_key_ignore" },
        r = { name = "󰛔 Replace", _ = "which_key_ignore" },
        s = { name = " Search", _ = "which_key_ignore" },
        v = { name = " VSCode", _ = "which_key_ignore" },
      },
      -- Additional navigation hints
      ["]"] = { name = "Next", _ = "which_key_ignore" },
      ["["] = { name = "Previous", _ = "which_key_ignore" },
      ["g"] = { name = "Go to", _ = "which_key_ignore" },
      ["z"] = { name = "Fold", _ = "which_key_ignore" },
    })
    
    -- Register specific command descriptions for clarity
    wk.register({
      ["<leader>"] = {
        -- Quick actions
        w = "Close buffer",
        s = "Save file",
        q = "Quit",
        
        -- Number keys for buffer switching
        ["1"] = "Buffer 1",
        ["2"] = "Buffer 2",
        ["3"] = "Buffer 3",
        ["4"] = "Buffer 4",
        ["5"] = "Buffer 5",
        ["6"] = "Buffer 6",
        ["7"] = "Buffer 7",
        ["8"] = "Buffer 8",
        ["9"] = "Buffer 9",
        
        -- Navigation
        d = "Next buffer",
        a = "Previous buffer",
      },
    })
  end,
}
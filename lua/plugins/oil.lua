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
    { "<Leader>E", function() 
      require("oil").toggle_float() 
    end, desc = "Toggle Oil float" },
    { "<Leader>o", function()
      -- Smart toggle Oil: opens in sidebar if not open, closes if open
      local oil_buffers = vim.tbl_filter(function(buf)
        return vim.bo[buf].filetype == "oil"
      end, vim.api.nvim_list_bufs())
      
      if #oil_buffers > 0 then
        -- Close oil buffers
        for _, buf in ipairs(oil_buffers) do
          local wins = vim.fn.win_findbuf(buf)
          for _, win in ipairs(wins) do
            vim.api.nvim_win_close(win, false)
          end
        end
      else
        -- Open oil in vertical split
        vim.cmd("vsplit")
        vim.cmd("Oil .")
        vim.cmd("vertical resize 35")
      end
    end, desc = "Toggle Oil sidebar" },
  },
  opts = {
    default_file_explorer = true,
    columns = {
      "icon",
      "permissions",
      "size",
      "mtime",
    },
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
      ["<C-h>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
    },
    use_default_keymaps = true,
    view_options = {
      show_hidden = true,
      is_hidden_file = function(name, bufnr)
        return vim.startswith(name, ".")
      end,
      is_always_hidden = function(name, bufnr)
        return name == ".." or name == ".git"
      end,
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
      override = function(conf)
        return conf
      end,
    },
    preview = {
      max_width = 0.9,
      min_width = { 40, 0.4 },
      width = nil,
      max_height = 0.9,
      min_height = { 5, 0.1 },
      height = nil,
      border = "rounded",
      win_options = {
        winblend = 0,
      },
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
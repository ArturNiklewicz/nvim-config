---@type LazySpec
return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup {
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      ignore_filetypes = {
        -- Add filetypes to ignore if needed
        -- cpp = true,
      },
      color = {
        suggestion_color = "#808080",
        cterm = 244,
      },
      log_level = "info", -- set to "off" to disable logging completely
      disable_inline_completion = false, -- keep inline completion enabled
      disable_keymaps = false, -- use built-in keymaps
      condition = function()
        -- Get current buffer path
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname == "" then return false end
        
        -- Check if file is .env or similar
        local filename = vim.fn.fnamemodify(bufname, ":t")
        if filename:match("^%.env") or filename:match("%.env$") or filename:match("%.env%.") then
          return true -- disable for .env files
        end
        
        -- Check if file is gitignored
        local handle = io.popen("git check-ignore " .. vim.fn.shellescape(bufname) .. " 2>/dev/null")
        if handle then
          local result = handle:read("*a")
          handle:close()
          if result and result:match("%S") then
            return true -- disable for gitignored files
          end
        end
        
        return false -- enable by default
      end,
    }
  end,
}

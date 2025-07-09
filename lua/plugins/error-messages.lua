-- Enhanced error message handling for Neovim
-- Provides better message display and easy copying

return {
  {
    "folke/snacks.nvim",
    opts = {
      notifier = {
        enabled = true,
        timeout = 5000,
        style = "fancy",
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    optional = true,
    opts = {
      timeout = 5000,
      stages = "fade",
      render = "default",
    },
  },
  {
    -- Custom error message enhancements
    "nvim-lua/plenary.nvim",
    config = function()
      -- Enhanced message handling functions
      local M = {}

      -- Function to get all messages
      function M.get_messages()
        local messages = {}
        local output = vim.fn.execute("messages")
        for line in output:gmatch("[^\r\n]+") do
          table.insert(messages, line)
        end
        return messages
      end

      -- Function to get recent error messages
      function M.get_error_messages()
        local messages = M.get_messages()
        local errors = {}
        for _, msg in ipairs(messages) do
          if msg:match("^Error") or msg:match("^E%d+:") or msg:match("ERROR") then
            table.insert(errors, msg)
          end
        end
        return errors
      end

      -- Function to copy messages to clipboard
      function M.copy_messages(messages)
        local text = table.concat(messages, "\n")
        vim.fn.setreg("+", text)
        vim.fn.setreg("*", text)
        vim.notify("Messages copied to clipboard", vim.log.levels.INFO)
      end

      -- Function to show messages in a floating window
      function M.show_messages_window(messages)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, messages)
        vim.bo[buf].filetype = "text"
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].modifiable = false

        local width = math.floor(vim.o.columns * 0.8)
        local height = math.floor(vim.o.lines * 0.6)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)

        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded",
          title = " Messages ",
          title_pos = "center",
        })

        -- Set window options
        vim.wo[win].wrap = true
        vim.wo[win].cursorline = true

        -- Keymaps for the messages window
        local opts = { buffer = buf, noremap = true, silent = true }
        vim.keymap.set("n", "q", "<cmd>close<cr>", opts)
        vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", opts)
        vim.keymap.set("n", "yy", function()
          local line = vim.api.nvim_get_current_line()
          vim.fn.setreg("+", line)
          vim.fn.setreg("*", line)
          vim.notify("Line copied to clipboard", vim.log.levels.INFO)
        end, opts)
        vim.keymap.set("n", "Y", function()
          M.copy_messages(messages)
        end, opts)
        vim.keymap.set("v", "y", function()
          local start_pos = vim.fn.getpos("'<")
          local end_pos = vim.fn.getpos("'>")
          local lines = vim.api.nvim_buf_get_lines(buf, start_pos[2] - 1, end_pos[2], false)
          local text = table.concat(lines, "\n")
          vim.fn.setreg("+", text)
          vim.fn.setreg("*", text)
          vim.notify("Selection copied to clipboard", vim.log.levels.INFO)
        end, opts)
      end

      -- Function to show error messages in floating window
      function M.show_error_messages()
        local errors = M.get_error_messages()
        if #errors == 0 then
          vim.notify("No error messages found", vim.log.levels.INFO)
          return
        end
        M.show_messages_window(errors)
      end

      -- Function to show all messages in floating window
      function M.show_all_messages()
        local messages = M.get_messages()
        if #messages == 0 then
          vim.notify("No messages found", vim.log.levels.INFO)
          return
        end
        M.show_messages_window(messages)
      end

      -- Function to copy last error message
      function M.copy_last_error()
        local errors = M.get_error_messages()
        if #errors == 0 then
          vim.notify("No error messages found", vim.log.levels.WARN)
          return
        end
        local last_error = errors[#errors]
        vim.fn.setreg("+", last_error)
        vim.fn.setreg("*", last_error)
        vim.notify("Last error copied to clipboard", vim.log.levels.INFO)
      end

      -- Function to copy all error messages
      function M.copy_all_errors()
        local errors = M.get_error_messages()
        if #errors == 0 then
          vim.notify("No error messages found", vim.log.levels.WARN)
          return
        end
        M.copy_messages(errors)
      end

      -- Function to copy all messages
      function M.copy_all_messages()
        local messages = M.get_messages()
        if #messages == 0 then
          vim.notify("No messages found", vim.log.levels.WARN)
          return
        end
        M.copy_messages(messages)
      end

      -- Create user commands
      vim.api.nvim_create_user_command("Messages", M.show_all_messages, { desc = "Show all messages in floating window" })
      vim.api.nvim_create_user_command("Errors", M.show_error_messages, { desc = "Show error messages in floating window" })
      vim.api.nvim_create_user_command("CopyLastError", M.copy_last_error, { desc = "Copy last error message to clipboard" })
      vim.api.nvim_create_user_command("CopyAllErrors", M.copy_all_errors, { desc = "Copy all error messages to clipboard" })
      vim.api.nvim_create_user_command("CopyAllMessages", M.copy_all_messages, { desc = "Copy all messages to clipboard" })

      -- Make functions globally available
      _G.ErrorMessages = M
    end,
  },
}
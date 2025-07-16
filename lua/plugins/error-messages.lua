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

      -- Function to check clipboard availability
      local function has_clipboard()
        return vim.fn.has('clipboard') == 1
      end

      -- Function to copy text to clipboard with validation
      local function safe_clipboard_copy(text)
        if has_clipboard() then
          vim.fn.setreg('+', text)
          vim.fn.setreg('*', text)
        else
          -- Fallback to unnamed register
          vim.fn.setreg('"', text)
          vim.notify("Clipboard not available, copied to unnamed register", vim.log.levels.WARN)
        end
      end

      -- Function to get all messages with improved parsing
      function M.get_messages()
        local messages = {}
        
        -- Use nvim_exec2 for better structured output
        local ok, result = pcall(function()
          return vim.api.nvim_exec2("messages", { output = true })
        end)
        
        if not ok then
          vim.notify("Failed to retrieve messages: " .. tostring(result), vim.log.levels.ERROR)
          return {}
        end
        
        local output = result.output or ""
        
        -- Use vim.split for proper line parsing
        local lines = vim.split(output, '\n', { trimempty = true })
        
        for _, line in ipairs(lines) do
          -- Filter out truly empty lines but keep lines with just whitespace
          if line:match('%S') then  -- Has non-whitespace characters
            -- Check for truncated messages
            if line:match("%.%.%.$") then
              table.insert(messages, line .. " [truncated]")
            else
              table.insert(messages, vim.trim(line))
            end
          end
        end
        
        return messages
      end

      -- Function to get recent error messages with comprehensive pattern matching
      function M.get_error_messages()
        local messages = M.get_messages()
        local errors = {}
        for _, msg in ipairs(messages) do
          -- More comprehensive error detection
          if msg:match("^E%d+:") or      -- Vim error codes
             msg:match("^Error") or       -- Generic errors
             msg:match("^W%d+:") or       -- Warning codes
             msg:match("ERROR") or        -- Uppercase ERROR
             msg:match("^%.%.%.") or      -- Truncated messages that might be errors
             msg:match("^%s*Error") or    -- Indented errors
             msg:match("stack traceback:") or  -- Lua stack traces
             msg:match("^%s*at") then     -- Stack trace lines
            table.insert(errors, msg)
          end
        end
        return errors
      end

      -- Function to copy messages to clipboard with validation
      function M.copy_messages(messages)
        if #messages == 0 then
          vim.notify("No messages to copy", vim.log.levels.WARN)
          return
        end
        
        local text = table.concat(messages, "\n")
        safe_clipboard_copy(text)
        
        local clipboard_msg = has_clipboard() and "clipboard" or "unnamed register"
        vim.notify(string.format("Copied %d messages to %s", #messages, clipboard_msg), vim.log.levels.INFO)
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
          safe_clipboard_copy(line)
          
          local clipboard_msg = has_clipboard() and "clipboard" or "unnamed register"
          vim.notify("Line copied to " .. clipboard_msg, vim.log.levels.INFO)
        end, opts)
        vim.keymap.set("n", "Y", function()
          M.copy_messages(messages)
        end, opts)
        vim.keymap.set("v", "y", function()
          -- Properly handle visual mode selection
          vim.cmd('normal! "vy')
          local text = vim.fn.getreg('v')
          
          if text and text ~= "" then
            safe_clipboard_copy(text)
            local clipboard_msg = has_clipboard() and "clipboard" or "unnamed register"
            vim.notify("Selection copied to " .. clipboard_msg, vim.log.levels.INFO)
          else
            vim.notify("No text selected", vim.log.levels.WARN)
          end
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
        safe_clipboard_copy(last_error)
        
        local clipboard_msg = has_clipboard() and "clipboard" or "unnamed register"
        vim.notify("Last error copied to " .. clipboard_msg, vim.log.levels.INFO)
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
      
      -- Test command to generate sample messages
      vim.api.nvim_create_user_command("TestMessages", function()
        vim.notify("This is a test notification", vim.log.levels.INFO)
        vim.cmd("echoerr 'This is a test error message'")
        vim.cmd("echohl WarningMsg | echo 'This is a warning' | echohl None")
        vim.notify("Messages generated for testing", vim.log.levels.INFO)
      end, { desc = "Generate test messages for debugging" })

      -- Make functions globally available
      _G.ErrorMessages = M
    end,
  },
}
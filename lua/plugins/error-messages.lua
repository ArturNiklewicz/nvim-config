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

      -- Function to check clipboard availability with system detection
      local function has_clipboard()
        -- Check if we have native clipboard support
        if vim.fn.has('clipboard') == 1 then
          return true
        end
        -- On macOS, check for pbcopy/pbpaste
        if vim.fn.has('mac') == 1 or vim.fn.has('macunix') == 1 then
          return vim.fn.executable('pbcopy') == 1 and vim.fn.executable('pbpaste') == 1
        end
        -- On Linux, check for xclip or xsel
        if vim.fn.has('unix') == 1 then
          return vim.fn.executable('xclip') == 1 or vim.fn.executable('xsel') == 1
        end
        return false
      end

      -- Function to copy text to clipboard with validation
      local function safe_clipboard_copy(text)
        local success = false
        
        -- Try native clipboard first
        if vim.fn.has('clipboard') == 1 then
          vim.fn.setreg('+', text)
          -- Verify the copy worked
          if vim.fn.getreg('+') == text then
            success = true
          end
        end
        
        -- If native failed, try system commands
        if not success then
          if vim.fn.has('mac') == 1 or vim.fn.has('macunix') == 1 then
            -- Use pbcopy on macOS
            if vim.fn.executable('pbcopy') == 1 then
              local handle = io.popen('pbcopy', 'w')
              if handle then
                handle:write(text)
                handle:close()
                success = true
              end
            end
          elseif vim.fn.has('unix') == 1 then
            -- Try xclip first, then xsel on Linux
            if vim.fn.executable('xclip') == 1 then
              local handle = io.popen('xclip -selection clipboard', 'w')
              if handle then
                handle:write(text)
                handle:close()
                success = true
              end
            elseif vim.fn.executable('xsel') == 1 then
              local handle = io.popen('xsel --clipboard --input', 'w')
              if handle then
                handle:write(text)
                handle:close()
                success = true
              end
            end
          end
        end
        
        -- Always copy to unnamed register as backup
        vim.fn.setreg('"', text)
        
        if success then
          return true
        else
          vim.notify("Failed to copy to system clipboard, copied to unnamed register", vim.log.levels.WARN)
          return false
        end
      end

      -- Function to get all messages with improved parsing
      function M.get_messages()
        local messages = {}
        
        -- First, try to get the last error message from vim.v.errmsg
        if vim.v.errmsg and vim.v.errmsg ~= "" then
          table.insert(messages, "[Last Error] " .. vim.v.errmsg)
        end
        
        -- Use nvim_exec2 for better structured output
        local ok, result = pcall(function()
          return vim.api.nvim_exec2("messages", { output = true })
        end)
        
        if not ok then
          vim.notify("Failed to retrieve messages: " .. tostring(result), vim.log.levels.ERROR)
          return messages  -- Return what we have so far
        end
        
        local output = result.output or ""
        
        -- Use vim.split for proper line parsing, keeping empty lines for context
        local lines = vim.split(output, '\n', { plain = true })
        
        -- Process lines, preserving structure
        for i, line in ipairs(lines) do
          -- Keep all lines including empty ones for context
          if line == "" then
            -- Only add empty line if we're not at the start or end
            if i > 1 and i < #lines and #messages > 0 then
              table.insert(messages, "")
            end
          else
            -- Check for truncated messages
            if line:match("%.%.%.$") then
              table.insert(messages, line .. " [truncated]")
            else
              table.insert(messages, line)
            end
          end
        end
        
        -- Also check for diagnostic messages
        local diagnostics = vim.diagnostic.get(nil, { severity = { min = vim.diagnostic.severity.ERROR } })
        if #diagnostics > 0 then
          table.insert(messages, "")
          table.insert(messages, "=== Diagnostics ===")
          for _, diag in ipairs(diagnostics) do
            local msg = string.format("[%s] %s", 
              vim.diagnostic.severity[diag.severity] or "ERROR",
              diag.message)
            table.insert(messages, msg)
          end
        end
        
        return messages
      end

      -- Function to get recent error messages with comprehensive pattern matching
      function M.get_error_messages()
        local errors = {}
        
        -- First add vim.v.errmsg if available
        if vim.v.errmsg and vim.v.errmsg ~= "" then
          table.insert(errors, "[Last Error] " .. vim.v.errmsg)
          table.insert(errors, "")  -- Add separator
        end
        
        -- Get all messages and filter for errors
        local messages = M.get_messages()
        local in_stack_trace = false
        
        for _, msg in ipairs(messages) do
          -- More comprehensive error detection
          if msg:match("^%[Last Error%]") or   -- Already added
             msg:match("^E%d+:") or           -- Vim error codes
             msg:match("^Error") or           -- Generic errors
             msg:match("^W%d+:") or           -- Warning codes
             msg:match("ERROR") or            -- Uppercase ERROR
             msg:match("^%.%.%.") or          -- Truncated messages
             msg:match("^%s*Error") or        -- Indented errors
             msg:match("stack traceback:") or -- Lua stack traces
             msg:match("^%[ERROR%]") or       -- Diagnostic errors
             msg:match("^=== Diagnostics ===") then  -- Diagnostic section
            table.insert(errors, msg)
            -- Start collecting stack trace
            if msg:match("stack traceback:") then
              in_stack_trace = true
            end
          elseif in_stack_trace and (msg:match("^%s+") or msg == "") then
            -- Include stack trace lines (indented or empty)
            table.insert(errors, msg)
            -- Stop at empty line after stack trace
            if msg == "" then
              in_stack_trace = false
            end
          elseif msg:match("^%s*at ") then  -- Stack trace lines
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
        local success = safe_clipboard_copy(text)
        
        if success then
          vim.notify(string.format("✓ Copied %d messages to system clipboard", #messages), vim.log.levels.INFO)
        else
          vim.notify(string.format("Copied %d messages to unnamed register (clipboard failed)", #messages), vim.log.levels.WARN)
        end
      end

      -- Function to show messages in a floating window
      function M.show_messages_window(messages)
        local buf = vim.api.nvim_create_buf(false, true)
        -- Split messages that contain newlines into separate lines
        local lines = {}
        for _, msg in ipairs(messages) do
          for line in msg:gmatch("[^\n]+") do
            table.insert(lines, line)
          end
        end
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
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
          local success = safe_clipboard_copy(line)
          
          if success then
            vim.notify("✓ Line copied to system clipboard", vim.log.levels.INFO)
          else
            vim.notify("Line copied to unnamed register (clipboard failed)", vim.log.levels.WARN)
          end
        end, opts)
        vim.keymap.set("n", "Y", function()
          M.copy_messages(messages)
        end, opts)
        vim.keymap.set("v", "y", function()
          -- Properly handle visual mode selection
          vim.cmd('normal! "vy')
          local text = vim.fn.getreg('v')
          
          if text and text ~= "" then
            local success = safe_clipboard_copy(text)
            if success then
              vim.notify("✓ Selection copied to system clipboard", vim.log.levels.INFO)
            else
              vim.notify("Selection copied to unnamed register (clipboard failed)", vim.log.levels.WARN)
            end
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
        
        -- Find the last non-empty error
        local last_error = nil
        for i = #errors, 1, -1 do
          if errors[i] ~= "" then
            last_error = errors[i]
            break
          end
        end
        
        if not last_error then
          vim.notify("No error messages found", vim.log.levels.WARN)
          return
        end
        
        local success = safe_clipboard_copy(last_error)
        
        if success then
          vim.notify("✓ Last error copied to system clipboard", vim.log.levels.INFO)
        else
          vim.notify("Last error copied to unnamed register (clipboard failed)", vim.log.levels.WARN)
        end
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
        -- Test Lua error with stack trace
        pcall(function() error("This is a Lua error with stack trace") end)
        -- Test diagnostic
        vim.diagnostic.set(vim.api.nvim_create_namespace("test"), 0, {
          {
            lnum = 0,
            col = 0,
            severity = vim.diagnostic.severity.ERROR,
            message = "Test diagnostic error",
            source = "test",
          }
        })
        vim.notify("Messages generated for testing", vim.log.levels.INFO)
      end, { desc = "Generate test messages for debugging" })
      
      -- Debug command to check clipboard status
      vim.api.nvim_create_user_command("ClipboardStatus", function()
        local status = {}
        table.insert(status, "=== Clipboard Status ===")
        table.insert(status, "vim.fn.has('clipboard'): " .. vim.fn.has('clipboard'))
        table.insert(status, "OS: " .. (vim.fn.has('mac') == 1 and "macOS" or vim.fn.has('unix') == 1 and "Unix/Linux" or "Other"))
        table.insert(status, "pbcopy available: " .. (vim.fn.executable('pbcopy') == 1 and "yes" or "no"))
        table.insert(status, "pbpaste available: " .. (vim.fn.executable('pbpaste') == 1 and "yes" or "no"))
        table.insert(status, "xclip available: " .. (vim.fn.executable('xclip') == 1 and "yes" or "no"))
        table.insert(status, "xsel available: " .. (vim.fn.executable('xsel') == 1 and "yes" or "no"))
        table.insert(status, "")
        table.insert(status, "Testing clipboard write...")
        local test_text = "Clipboard test " .. os.time()
        local success = safe_clipboard_copy(test_text)
        table.insert(status, "Write result: " .. (success and "SUCCESS" or "FAILED"))
        
        -- Display in floating window
        M.show_messages_window(status)
      end, { desc = "Show clipboard status and test clipboard functionality" })

      -- Make functions globally available
      _G.ErrorMessages = M
    end,
  },
}
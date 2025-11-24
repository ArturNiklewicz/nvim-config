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
        -- Filter hook: log all notifications to :messages, then allow them to proceed
        filter = function(notif)
          -- Map log levels to readable names
          local level_names = {
            error = "ERROR",
            warn = "WARNING",
            info = "INFO",
            debug = "DEBUG",
            trace = "TRACE",
          }
          local prefix = level_names[notif.level] or "INFO"

          -- Clean message: remove newlines, escape quotes
          local msg = tostring(notif.msg or ""):gsub("\n", " "):gsub('"', '\\"'):gsub("'", "''")

          -- Add to :messages history using echom
          -- Use pcall to prevent errors from breaking notifications
          pcall(function()
            vim.cmd(string.format('echom "[%s] %s"', prefix, msg))
          end)

          -- Return true to allow notification to proceed (false would hide it)
          return true
        end,
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
      
      -- Configuration for handling large message sets
      local config = {
        max_messages = 5000,  -- Maximum messages to process at once
        max_clipboard_size = 1024 * 1024,  -- 1MB clipboard limit
        chunk_size = 1000,  -- Process messages in chunks
        use_temp_file = true,  -- Use temp file for large outputs
        temp_dir = vim.fn.stdpath('cache'),  -- Temp file directory
      }

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

      -- Function to get all messages with improved parsing and limits
      function M.get_messages(opts)
        opts = opts or {}
        local max_lines = opts.max_lines or config.max_messages
        local filter = opts.filter  -- Optional filter function
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
        
        -- Apply limit if too many lines
        if #lines > max_lines then
          vim.notify(string.format("⚠️ Truncating messages: %d lines → %d lines", #lines, max_lines), vim.log.levels.WARN)
          -- Keep the most recent messages
          local start_idx = #lines - max_lines + 1
          local truncated = {}
          for i = start_idx, #lines do
            table.insert(truncated, lines[i])
          end
          lines = truncated
          table.insert(messages, "[TRUNCATED: Showing last " .. max_lines .. " lines]")
          table.insert(messages, "")
        end
        
        -- Process lines in chunks for better performance
        local chunk_size = config.chunk_size
        for chunk_start = 1, #lines, chunk_size do
          local chunk_end = math.min(chunk_start + chunk_size - 1, #lines)
          
          -- Process chunk
          for i = chunk_start, chunk_end do
            local line = lines[i]
            
            -- Apply filter if provided
            if filter and not filter(line) then
              goto continue
            end
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
            
            ::continue::
          end
          
          -- Yield control periodically for responsiveness
          if chunk_end < #lines then
            vim.schedule(function() end)
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
      function M.get_error_messages(opts)
        opts = opts or {}
        local errors = {}
        
        -- First add vim.v.errmsg if available
        if vim.v.errmsg and vim.v.errmsg ~= "" then
          table.insert(errors, "[Last Error] " .. vim.v.errmsg)
          table.insert(errors, "")  -- Add separator
        end
        
        -- Get all messages and filter for errors with limits
        local messages = M.get_messages({
          max_lines = opts.max_lines or config.max_messages,
          filter = opts.filter
        })
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

      -- Function to copy messages to clipboard with size validation and temp file fallback
      function M.copy_messages(messages, opts)
        opts = opts or {}
        if #messages == 0 then
          vim.notify("No messages to copy", vim.log.levels.WARN)
          return
        end
        
        -- Use efficient string building for large message sets
        local parts = {}
        local total_size = 0
        
        for _, msg in ipairs(messages) do
          table.insert(parts, msg)
          total_size = total_size + #msg + 1  -- +1 for newline
        end
        
        local text = table.concat(parts, "\n")
        
        -- Check if text is too large for clipboard
        if total_size > config.max_clipboard_size then
          -- Write to temp file instead
          if config.use_temp_file then
            local temp_file = config.temp_dir .. "/nvim_errors_" .. os.time() .. ".txt"
            local file = io.open(temp_file, "w")
            if file then
              file:write(text)
              file:close()
              
              -- Try to copy file path to clipboard
              safe_clipboard_copy(temp_file)
              vim.notify(string.format("✅ Messages too large (%d KB). Saved to: %s", 
                math.floor(total_size / 1024), temp_file), vim.log.levels.INFO)
              
              -- Open file in split if requested
              if opts.open_file then
                vim.cmd("split " .. temp_file)
              end
              return
            else
              vim.notify("❌ Failed to create temp file", vim.log.levels.ERROR)
              return
            end
          else
            vim.notify(string.format("❌ Messages too large for clipboard (%d KB, max %d KB)", 
              math.floor(total_size / 1024), 
              math.floor(config.max_clipboard_size / 1024)), vim.log.levels.ERROR)
            return
          end
        end
        
        local success = safe_clipboard_copy(text)
        
        if success then
          vim.notify(string.format("✓ Copied %d messages to system clipboard", #messages), vim.log.levels.INFO)
        else
          vim.notify(string.format("Copied %d messages to unnamed register (clipboard failed)", #messages), vim.log.levels.WARN)
        end
      end

      -- Function to show messages in a floating window with pagination
      function M.show_messages_window(messages, opts)
        opts = opts or {}
        local page_size = opts.page_size or 100
        local current_page = opts.page or 1
        
        -- Calculate pagination
        local total_pages = math.ceil(#messages / page_size)
        current_page = math.max(1, math.min(current_page, total_pages))
        
        local start_idx = (current_page - 1) * page_size + 1
        local end_idx = math.min(current_page * page_size, #messages)
        
        -- Get current page messages
        local page_messages = {}
        for i = start_idx, end_idx do
          table.insert(page_messages, messages[i])
        end
        
        -- Add pagination info
        if total_pages > 1 then
          table.insert(page_messages, 1, string.format("[Page %d/%d | Total: %d messages | Use 'n'/'p' to navigate]", 
            current_page, total_pages, #messages))
          table.insert(page_messages, 2, "")
        end
        local buf = vim.api.nvim_create_buf(false, true)
        -- Split messages that contain newlines into separate lines
        local lines = {}
        for _, msg in ipairs(page_messages) do
          if msg then
            for line in msg:gmatch("[^\n]+") do
              table.insert(lines, line)
            end
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
        local keymap_opts = { buffer = buf, noremap = true, silent = true }
        vim.keymap.set("n", "q", "<cmd>close<cr>", keymap_opts)
        vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", keymap_opts)
        
        -- Pagination navigation
        if total_pages > 1 then
          vim.keymap.set("n", "n", function()
            vim.cmd("close")
            M.show_messages_window(messages, { page = current_page + 1, page_size = page_size })
          end, keymap_opts)
          
          vim.keymap.set("n", "p", function()
            vim.cmd("close")
            M.show_messages_window(messages, { page = current_page - 1, page_size = page_size })
          end, keymap_opts)
          
          vim.keymap.set("n", "g", function()
            vim.ui.input({ prompt = "Go to page (1-" .. total_pages .. "): " }, function(input)
              local page = tonumber(input)
              if page and page >= 1 and page <= total_pages then
                vim.cmd("close")
                M.show_messages_window(messages, { page = page, page_size = page_size })
              end
            end)
          end, keymap_opts)
        end
        vim.keymap.set("n", "yy", function()
          local line = vim.api.nvim_get_current_line()
          local success = safe_clipboard_copy(line)
          
          if success then
            vim.notify("✓ Line copied to system clipboard", vim.log.levels.INFO)
          else
            vim.notify("Line copied to unnamed register (clipboard failed)", vim.log.levels.WARN)
          end
        end, keymap_opts)
        vim.keymap.set("n", "Y", function()
          M.copy_messages(messages, { open_file = false })
        end, keymap_opts)
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
        end, keymap_opts)
      end

      -- Function to show error messages in floating window
      function M.show_error_messages(opts)
        opts = opts or {}
        local errors = M.get_error_messages(opts)
        if #errors == 0 then
          vim.notify("No error messages found", vim.log.levels.INFO)
          return
        end
        M.show_messages_window(errors, opts)
      end

      -- Function to show all messages in floating window
      function M.show_all_messages(opts)
        opts = opts or {}
        local messages = M.get_messages(opts)
        if #messages == 0 then
          vim.notify("No messages found", vim.log.levels.INFO)
          return
        end
        M.show_messages_window(messages, opts)
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
      function M.copy_all_errors(opts)
        opts = opts or {}
        local errors = M.get_error_messages(opts)
        if #errors == 0 then
          vim.notify("No error messages found", vim.log.levels.WARN)
          return
        end
        M.copy_messages(errors, opts)
      end

      -- Function to copy all messages
      function M.copy_all_messages(opts)
        opts = opts or {}
        local messages = M.get_messages(opts)
        if #messages == 0 then
          vim.notify("No messages found", vim.log.levels.WARN)
          return
        end
        M.copy_messages(messages, opts)
      end

      -- Create user commands with enhanced options
      vim.api.nvim_create_user_command("Messages", function(cmd)
        local args = cmd.args
        local opts = {}
        
        -- Parse arguments for pagination
        local page = args:match("--page=(%d+)")
        if page then opts.page = tonumber(page) end
        
        local page_size = args:match("--size=(%d+)")
        if page_size then opts.page_size = tonumber(page_size) end
        
        M.show_all_messages(opts)
      end, { 
        desc = "Show all messages in floating window",
        nargs = "*",
        complete = function()
          return { "--page=1", "--size=100" }
        end
      })
      
      vim.api.nvim_create_user_command("Errors", function(cmd)
        local args = cmd.args
        local opts = {}
        
        -- Parse arguments
        local severity = args:match("--severity=(%w+)")
        if severity then 
          opts.filter = function(line)
            return line:match(severity:upper()) ~= nil
          end
        end
        
        local recent = args:match("--recent=(%d+)")
        if recent then opts.max_lines = tonumber(recent) end
        
        M.show_error_messages(opts)
      end, { 
        desc = "Show error messages in floating window",
        nargs = "*",
        complete = function()
          return { "--severity=ERROR", "--severity=WARN", "--recent=100" }
        end
      })
      
      vim.api.nvim_create_user_command("CopyLastError", M.copy_last_error, { desc = "Copy last error message to clipboard" })
      
      vim.api.nvim_create_user_command("CopyAllErrors", function(cmd)
        local args = cmd.args
        local opts = {}
        
        -- Parse options
        if args:match("--file") then
          opts.open_file = true
        end
        
        local max = args:match("--max=(%d+)")
        if max then opts.max_lines = tonumber(max) end
        
        M.copy_all_errors(opts)
      end, { 
        desc = "Copy all error messages to clipboard",
        nargs = "*",
        complete = function()
          return { "--file", "--max=1000" }
        end
      })
      
      vim.api.nvim_create_user_command("CopyAllMessages", function(cmd)
        local args = cmd.args
        local opts = {}
        
        if args:match("--file") then
          opts.open_file = true
        end
        
        M.copy_all_messages(opts)
      end, { 
        desc = "Copy all messages to clipboard",
        nargs = "*",
        complete = function()
          return { "--file" }
        end
      })
      
      -- Test command to generate sample messages with large dataset option
      vim.api.nvim_create_user_command("TestMessages", function(cmd)
        local args = cmd.args
        local large_test = args:match("--large")
        
        if large_test then
          -- Generate a large number of test errors
          vim.notify("Generating large error set for testing...", vim.log.levels.INFO)
          
          -- Create 10,000 test errors
          for i = 1, 10000 do
            if i % 100 == 0 then
              vim.cmd(string.format("echoerr 'Test error %d: This is a sample error message with some details about what went wrong at line %d'", i, i))
            end
            if i % 500 == 0 then
              -- Add some variety
              pcall(function() error(string.format("Lua error %d: Test stack trace error", i)) end)
            end
          end
          
          vim.notify("Large error set generated. Try :CopyAllErrors or :Errors", vim.log.levels.INFO)
          return
        end
        
        -- Normal test messages
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
      end, { 
        desc = "Generate test messages for debugging",
        nargs = "*",
        complete = function()
          return { "--large" }
        end
      })
      
      -- Command to show/configure error handling settings
      vim.api.nvim_create_user_command("ErrorConfig", function(cmd)
        local args = cmd.args
        
        -- Parse configuration updates
        local max_messages = args:match("max_messages=(%d+)")
        if max_messages then
          config.max_messages = tonumber(max_messages)
        end
        
        local max_clipboard = args:match("max_clipboard=(%d+)")
        if max_clipboard then
          config.max_clipboard_size = tonumber(max_clipboard) * 1024  -- Convert KB to bytes
        end
        
        local chunk_size = args:match("chunk_size=(%d+)")
        if chunk_size then
          config.chunk_size = tonumber(chunk_size)
        end
        
        -- Show current configuration
        local status = {}
        table.insert(status, "=== Error Handling Configuration ===")
        table.insert(status, "")
        table.insert(status, string.format("Max messages to process: %d", config.max_messages))
        table.insert(status, string.format("Max clipboard size: %d KB", config.max_clipboard_size / 1024))
        table.insert(status, string.format("Processing chunk size: %d", config.chunk_size))
        table.insert(status, string.format("Use temp file for large outputs: %s", tostring(config.use_temp_file)))
        table.insert(status, string.format("Temp directory: %s", config.temp_dir))
        table.insert(status, "")
        table.insert(status, "Usage: :ErrorConfig [max_messages=N] [max_clipboard=KB] [chunk_size=N]")
        
        M.show_messages_window(status)
      end, {
        desc = "Show/configure error handling settings",
        nargs = "*",
        complete = function()
          return { "max_messages=5000", "max_clipboard=1024", "chunk_size=1000" }
        end
      })
      
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
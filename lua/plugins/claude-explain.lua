-- Claude Code Explanation Plugin
-- Shows floating window with AI explanations of selected code

return {
  {
    "nvim-lua/plenary.nvim",
    lazy = false,
  },
  {
    "claude-explain",
    name = "claude-explain",
    dir = vim.fn.stdpath("config") .. "/lua/claude-explain",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = false,
    config = function()
    local M = {}
    
    -- Plugin configuration
    local config = {
      keymaps = {
        explain = "<C-e>",
        explain_error = "<leader>exe",
        explain_function = "<leader>exf",
      },
      claude_args = {
        timeout = 30000,
        use_claude_file = true,
        model = nil,
      },
      ui = {
        width_ratio = 0.7,
        height_ratio = 0.5,
        border = "rounded",
        highlight = "Normal",
        close_events = { "CursorMoved", "CursorMovedI", "InsertCharPre" },
      },
      cache = {
        enabled = true,
        ttl = 300,
      }
    }
    
    -- Cache for explanations
    local cache = {}
    
    -- Helper function to get cache key
    local function get_cache_key(content)
      return vim.fn.sha256(content)
    end
    
    -- Helper function to check cache
    local function get_cached_explanation(content)
      if not config.cache.enabled then return nil end
      
      local key = get_cache_key(content)
      local entry = cache[key]
      
      if entry and (os.time() - entry.timestamp) < config.cache.ttl then
        return entry.explanation
      end
      
      return nil
    end
    
    -- Helper function to cache explanation
    local function cache_explanation(content, explanation)
      if not config.cache.enabled then return end
      
      local key = get_cache_key(content)
      cache[key] = {
        explanation = explanation,
        timestamp = os.time()
      }
    end
    
    -- Get visual selection text
    local function get_visual_selection()
      local s_start = vim.fn.getpos("v")
      local s_end = vim.fn.getpos(".")
      
      -- Handle case where selection might be backwards
      if s_start[2] > s_end[2] or (s_start[2] == s_end[2] and s_start[3] > s_end[3]) then
        s_start, s_end = s_end, s_start
      end
      
      local lines = vim.fn.getregion(s_start, s_end)
      return table.concat(lines, "\n")
    end
    
    -- Get text under cursor (word or line)
    local function get_cursor_context()
      local current_word = vim.fn.expand("<cword>")
      if current_word == "" then
        return vim.api.nvim_get_current_line()
      end
      return current_word
    end
    
    -- Get current file type for language detection
    local function get_language()
      local ft = vim.bo.filetype
      if ft == "" then return "text" end
      return ft
    end
    
    -- Show loading indicator
    local function show_loading()
      vim.notify("🤖 Claude is thinking...", vim.log.levels.INFO, { title = "Claude Explain" })
    end
    
    -- Query Claude Code CLI
    local function query_claude(code, language, callback)
      show_loading()
      
      local prompt = string.format(
        "Explain this %s code clearly and concisely:\n\n```%s\n%s\n```\n\nProvide:\n1. What it does\n2. How it works\n3. Any notable patterns or best practices",
        language, language, code
      )
      
      local cmd = {
        "claude",
        "--print",
        "--output-format", "text",
        "--allowedTools", "",
        prompt
      }
      
      -- Use plenary.nvim job for async execution
      local Job = require('plenary.job')
      
      Job:new({
        command = cmd[1],
        args = vim.list_slice(cmd, 2),
        on_exit = function(job, return_val)
          vim.schedule(function()
            if return_val == 0 then
              local result = table.concat(job:result(), "\n")
              if result and result ~= "" then
                cache_explanation(code, result)
                callback(result, nil)
              else
                callback(nil, "Empty response from Claude")
              end
            else
              local error_msg = table.concat(job:stderr_result(), "\n")
              callback(nil, error_msg)
            end
          end)
        end,
        on_stderr = function(_, data)
          vim.schedule(function()
            vim.notify("Claude error: " .. data, vim.log.levels.WARN)
          end)
        end,
      }):start()
    end
    
    -- Show explanation in floating window
    local function show_explanation(content, title)
      if not content or content == "" then
        vim.notify("No explanation received", vim.log.levels.WARN)
        return
      end
      
      -- Split content into lines for proper display
      local lines = vim.split(content, "\n")
      
      -- Calculate window dimensions
      local width = math.floor(vim.o.columns * config.ui.width_ratio)
      local height = math.min(math.floor(vim.o.lines * config.ui.height_ratio), #lines + 2)
      
      local opts = {
        relative = "cursor",
        row = 1,
        col = 0,
        width = width,
        height = height,
        style = "minimal",
        border = config.ui.border,
        title = title or " Claude Explanation ",
        title_pos = "center",
        focusable = true,
        close_events = config.ui.close_events,
      }
      
      -- Create buffer and set content
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.bo[bufnr].filetype = "markdown"
      vim.bo[bufnr].modifiable = false
      
      -- Open floating window
      local winnr = vim.api.nvim_open_win(bufnr, true, opts)
      
      -- Set window options
      vim.wo[winnr].wrap = true
      vim.wo[winnr].cursorline = true
      
      -- Add keymaps for the floating window
      local keymap_opts = { buffer = bufnr, noremap = true, silent = true }
      vim.keymap.set("n", "q", "<cmd>close<cr>", keymap_opts)
      vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", keymap_opts)
      vim.keymap.set("n", "yy", function()
        local line = vim.api.nvim_get_current_line()
        vim.fn.setreg("+", line)
        vim.notify("Line copied to clipboard", vim.log.levels.INFO)
      end, keymap_opts)
      vim.keymap.set("n", "Y", function()
        vim.fn.setreg("+", content)
        vim.notify("Full explanation copied to clipboard", vim.log.levels.INFO)
      end, keymap_opts)
    end
    
    -- Main explanation function
    function M.explain_selection()
      local mode = vim.fn.mode()
      local text = ""
      
      if mode == "v" or mode == "V" or mode == "\22" then -- Visual modes
        text = get_visual_selection()
        -- Exit visual mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      else
        text = get_cursor_context()
      end
      
      if text == "" then
        vim.notify("No text selected or under cursor", vim.log.levels.WARN)
        return
      end
      
      -- Check cache first
      local cached = get_cached_explanation(text)
      if cached then
        show_explanation(cached, " Claude Explanation (cached) ")
        return
      end
      
      local language = get_language()
      
      query_claude(text, language, function(explanation, error)
        if error then
          vim.notify("Claude error: " .. error, vim.log.levels.ERROR)
        else
          show_explanation(explanation, " Claude Explanation ")
        end
      end)
    end
    
    -- Explain diagnostic under cursor
    function M.explain_diagnostic()
      local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
      
      if #diagnostics == 0 then
        vim.notify("No diagnostic under cursor", vim.log.levels.WARN)
        return
      end
      
      local diag = diagnostics[1]
      local text = string.format("Error: %s\nSource: %s", diag.message, diag.source or "unknown")
      
      -- Check cache first
      local cached = get_cached_explanation(text)
      if cached then
        show_explanation(cached, " Error Explanation (cached) ")
        return
      end
      
      local prompt = string.format(
        "Explain this error message and provide solutions:\n\n%s\n\nContext: %s file",
        text, get_language()
      )
      
      query_claude(text, "error", function(explanation, error)
        if error then
          vim.notify("Claude error: " .. error, vim.log.levels.ERROR)
        else
          show_explanation(explanation, " Error Explanation ")
        end
      end)
    end
    
    -- Explain entire function
    function M.explain_function()
      local ts_utils = require('nvim-treesitter.ts_utils')
      if not ts_utils then
        vim.notify("Treesitter utils not available", vim.log.levels.WARN)
        return
      end
      
      local node = ts_utils.get_node_at_cursor()
      if not node then
        vim.notify("No treesitter node under cursor", vim.log.levels.WARN)
        return
      end
      
      -- Find function node
      local function_node = node
      while function_node do
        local node_type = function_node:type()
        if node_type:match("function") or node_type:match("method") then
          break
        end
        function_node = function_node:parent()
      end
      
      if not function_node then
        vim.notify("No function found at cursor", vim.log.levels.WARN)
        return
      end
      
      local start_row, start_col, end_row, end_col = function_node:range()
      local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
      local text = table.concat(lines, "\n")
      
      -- Check cache first
      local cached = get_cached_explanation(text)
      if cached then
        show_explanation(cached, " Function Explanation (cached) ")
        return
      end
      
      local language = get_language()
      
      query_claude(text, language, function(explanation, error)
        if error then
          vim.notify("Claude error: " .. error, vim.log.levels.ERROR)
        else
          show_explanation(explanation, " Function Explanation ")
        end
      end)
    end
    
    -- Setup function
    function M.setup(opts)
      config = vim.tbl_deep_extend("force", config, opts or {})
      
      -- Create user commands
      vim.api.nvim_create_user_command("ClaudeExplain", M.explain_selection, {
        desc = "Explain selected code with Claude",
        range = true
      })
      
      vim.api.nvim_create_user_command("ClaudeExplainError", M.explain_diagnostic, {
        desc = "Explain diagnostic under cursor"
      })
      
      vim.api.nvim_create_user_command("ClaudeExplainFunction", M.explain_function, {
        desc = "Explain function under cursor"
      })
      
      -- Create keymaps (override default Ctrl+E scroll behavior)
      vim.keymap.set({"n", "v"}, config.keymaps.explain, M.explain_selection, {
        desc = "Explain code with Claude",
        silent = true,
        noremap = true  -- Override default mapping
      })
      
      vim.keymap.set("n", config.keymaps.explain_error, M.explain_diagnostic, {
        desc = "Explain error with Claude",
        silent = true
      })
      
      vim.keymap.set("n", config.keymaps.explain_function, M.explain_function, {
        desc = "Explain function with Claude",
        silent = true
      })
    end
    
    -- Initialize plugin
    M.setup()
    
    -- Make module globally available for debugging
    _G.ClaudeExplain = M
  end,
  },
}
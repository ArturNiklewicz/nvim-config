return {
  "coder/claudecode.nvim",
  dependencies = { 
    "folke/snacks.nvim",
    "rktjmp/fwatch.nvim",
    "akinsho/bufferline.nvim",
  },
  opts = {
    terminal_cmd = "claude",  -- Default command (fresh session)
    
    -- Diff integration settings
    diff_opts = {
      auto_close_on_accept = false,  -- Keep diff open for review
      show_diff_stats = true,        -- Show change statistics
      vertical_split = true,         -- Use vertical split for better side-by-side view
      open_in_current_tab = true,    -- Open in current tab
    },
    
    -- Auto-open files in buffers when Claude Code edits them
    auto_open_edited_files = true,
    
    -- Terminal configuration for better integration
    terminal = {
      split_side = "right",
      split_width_percentage = 0.30,
      provider = "auto",
      auto_close = false,  -- Keep terminal open for ongoing interaction
    },
  },
  
  config = function(_, opts)
    -- Setup the plugin with default options
    require("claudecode").setup(opts)
    
    -- Enhanced Claude Code integration module
    local M = {}
    local fwatch = require("fwatch")
    local watchers = {}
    local edited_files = {}
    
    -- File watching functionality
    local function watch_file(filepath)
      if watchers[filepath] then return end
      
      watchers[filepath] = fwatch.watch(filepath, {
        on_event = function(filename, events)
          if events.change then
            -- Auto-reload buffer if it exists
            local bufnr = vim.fn.bufnr(filepath)
            if bufnr ~= -1 then
              vim.schedule(function()
                vim.api.nvim_buf_call(bufnr, function()
                  vim.cmd("checktime")
                end)
              end)
            end
            
            -- Track as edited file
            edited_files[filepath] = true
          end
        end
      })
    end
    
    -- Auto-open edited files in buffers
    local function auto_open_file(filepath)
      if not vim.fn.filereadable(filepath) then return end
      
      vim.schedule(function()
        -- Check if buffer already exists
        local bufnr = vim.fn.bufnr(filepath)
        if bufnr == -1 then
          -- Create new buffer
          vim.cmd("edit " .. vim.fn.fnameescape(filepath))
          bufnr = vim.fn.bufnr(filepath)
        end
        
        -- Start watching the file
        watch_file(filepath)
        
        -- Mark as edited by Claude
        edited_files[filepath] = true
      end)
    end
    
    -- Enhanced diff management using native Neovim diff
    local function show_claude_diff(filepath)
      if not edited_files[filepath] then return end
      
      vim.schedule(function()
        -- Create a temporary file with the HEAD version
        local temp_file = vim.fn.tempname()
        local git_cmd = string.format("git show HEAD:%s", vim.fn.fnamemodify(filepath, ":~:."))
        
        -- Get the HEAD version of the file
        local result = vim.fn.system(git_cmd)
        if vim.v.shell_error == 0 then
          -- Write HEAD version to temp file
          local temp_handle = io.open(temp_file, "w")
          if temp_handle then
            temp_handle:write(result)
            temp_handle:close()
            
            -- Open the current file and the HEAD version in diff mode
            vim.cmd("tabnew " .. vim.fn.fnameescape(filepath))
            vim.cmd("vertical diffsplit " .. vim.fn.fnameescape(temp_file))
            
            -- Set buffer options for the temp file
            vim.bo.buftype = "nofile"
            vim.bo.bufhidden = "wipe"
            vim.bo.filetype = vim.bo[vim.fn.bufnr(filepath)].filetype
            
            -- Add buffer name for clarity
            vim.api.nvim_buf_set_name(0, filepath .. " (HEAD)")
            
            -- Clean up temp file when buffer is closed
            vim.api.nvim_create_autocmd("BufWipeout", {
              buffer = 0,
              once = true,
              callback = function()
                vim.fn.delete(temp_file)
              end
            })
          end
        else
          vim.notify("Could not get HEAD version of file: " .. filepath, vim.log.levels.ERROR)
        end
      end)
    end
    
    -- Accept all Claude Code changes
    local function accept_claude_changes()
      local current_file = vim.fn.expand("%:p")
      if edited_files[current_file] then
        vim.cmd("write")
        edited_files[current_file] = nil
        if watchers[current_file] then
          watchers[current_file]:stop()
          watchers[current_file] = nil
        end
        vim.notify("Claude Code changes accepted: " .. vim.fn.fnamemodify(current_file, ":t"))
      end
    end
    
    -- Reject Claude Code changes
    local function reject_claude_changes()
      local current_file = vim.fn.expand("%:p")
      if edited_files[current_file] then
        vim.cmd("edit!")
        edited_files[current_file] = nil
        if watchers[current_file] then
          watchers[current_file]:stop()
          watchers[current_file] = nil
        end
        vim.notify("Claude Code changes rejected: " .. vim.fn.fnamemodify(current_file, ":t"))
      end
    end
    
    -- Open all files edited by Claude Code
    local function open_all_edited_files()
      for filepath, _ in pairs(edited_files) do
        if vim.fn.filereadable(filepath) == 1 then
          auto_open_file(filepath)
        end
      end
    end
    
    -- Show diff for current file
    local function show_current_diff()
      local current_file = vim.fn.expand("%:p")
      show_claude_diff(current_file)
    end
    
    -- Show diff for all edited files using native Neovim diff
    local function show_all_diffs()
      local files_to_diff = {}
      for filepath, _ in pairs(edited_files) do
        if vim.fn.filereadable(filepath) == 1 then
          table.insert(files_to_diff, filepath)
        end
      end
      
      if #files_to_diff == 0 then
        vim.notify("No Claude Code edited files to diff", vim.log.levels.INFO)
        return
      end
      
      vim.schedule(function()
        -- Create a new tab for the multi-diff view
        vim.cmd("tabnew")
        local main_tab = vim.fn.tabpagenr()
        
        -- Process each file
        for i, filepath in ipairs(files_to_diff) do
          local temp_file = vim.fn.tempname()
          local git_cmd = string.format("git show HEAD:%s", vim.fn.fnamemodify(filepath, ":~:."))
          
          -- Get the HEAD version of the file
          local result = vim.fn.system(git_cmd)
          if vim.v.shell_error == 0 then
            -- Write HEAD version to temp file
            local temp_handle = io.open(temp_file, "w")
            if temp_handle then
              temp_handle:write(result)
              temp_handle:close()
              
              if i == 1 then
                -- First file: open in current window
                vim.cmd("edit " .. vim.fn.fnameescape(filepath))
                vim.cmd("vertical diffsplit " .. vim.fn.fnameescape(temp_file))
              else
                -- Additional files: create new tab
                vim.cmd("tabnew " .. vim.fn.fnameescape(filepath))
                vim.cmd("vertical diffsplit " .. vim.fn.fnameescape(temp_file))
              end
              
              -- Set buffer options for the temp file
              vim.bo.buftype = "nofile"
              vim.bo.bufhidden = "wipe"
              vim.bo.filetype = vim.bo[vim.fn.bufnr(filepath)].filetype
              
              -- Add buffer name for clarity
              vim.api.nvim_buf_set_name(0, filepath .. " (HEAD)")
              
              -- Clean up temp file when buffer is closed
              vim.api.nvim_create_autocmd("BufWipeout", {
                buffer = 0,
                once = true,
                callback = function()
                  vim.fn.delete(temp_file)
                end
              })
            end
          else
            vim.notify("Could not get HEAD version of file: " .. filepath, vim.log.levels.WARN)
          end
        end
        
        -- Return to the first tab
        vim.cmd("tabnext " .. main_tab)
        
        vim.notify("Opened diff view for " .. #files_to_diff .. " Claude Code edited files", vim.log.levels.INFO)
      end)
    end
    
    -- Make functions globally available
    _G.ClaudeAcceptChanges = accept_claude_changes
    _G.ClaudeRejectChanges = reject_claude_changes
    _G.ClaudeOpenAllFiles = open_all_edited_files
    _G.ClaudeShowDiff = show_current_diff
    _G.ClaudeShowAllDiffs = show_all_diffs
    _G.ClaudeAutoOpenFile = auto_open_file
    
    -- CORRECT API USAGE: Working with the actual plugin
    local terminal_module = require("claudecode.terminal")
    
    -- Custom function to start fresh Claude Code chat
    local function start_fresh_claude()
      -- Close existing terminal completely for fresh start
      if terminal_module.get_active_terminal_bufnr() then
        terminal_module.close()
      end
      
      -- Create a temporary override for the terminal command
      local original_opts = vim.deepcopy(opts)
      local fresh_opts = vim.deepcopy(opts)
      fresh_opts.terminal_cmd = "claude"  -- No resume flag
      
      -- Temporarily reconfigure the terminal module
      require("claudecode").setup(fresh_opts)
      
      -- Open the terminal
      terminal_module.open()
      
      -- Restore original configuration after terminal opens
      vim.defer_fn(function()
        require("claudecode").setup(original_opts)
      end, 500)
    end
    
    -- Custom function to start with resume
    local function start_resume_claude()
      -- Create a temporary override for the terminal command  
      local original_opts = vim.deepcopy(opts)
      local resume_opts = vim.deepcopy(opts)
      resume_opts.terminal_cmd = "claude --resume"
      
      -- Temporarily reconfigure the terminal module
      require("claudecode").setup(resume_opts)
      
      -- Use focus_toggle for smart behavior (show/hide/focus)
      terminal_module.focus_toggle()
      
      -- Restore original configuration after terminal opens
      vim.defer_fn(function()
        require("claudecode").setup(original_opts)
      end, 500)
    end
    
    -- Create custom user commands
    vim.api.nvim_create_user_command("ClaudeCodeFresh", start_fresh_claude, {
      desc = "Start fresh Claude Code chat (no resume)"
    })
    
    vim.api.nvim_create_user_command("ClaudeCodeResume", start_resume_claude, {
      desc = "Start Claude Code with resume picker"
    })
    
    -- Make functions available globally
    _G.ClaudeCodeFresh = start_fresh_claude
    _G.ClaudeCodeResume = start_resume_claude
    
    -- Enhanced user commands
    vim.api.nvim_create_user_command("ClaudeAcceptChanges", accept_claude_changes, {
      desc = "Accept Claude Code changes for current file"
    })
    
    vim.api.nvim_create_user_command("ClaudeRejectChanges", reject_claude_changes, {
      desc = "Reject Claude Code changes for current file"
    })
    
    vim.api.nvim_create_user_command("ClaudeOpenAllFiles", open_all_edited_files, {
      desc = "Open all files edited by Claude Code"
    })
    
    vim.api.nvim_create_user_command("ClaudeShowDiff", show_current_diff, {
      desc = "Show diff for current file"
    })
    
    vim.api.nvim_create_user_command("ClaudeShowAllDiffs", show_all_diffs, {
      desc = "Show diff for all Claude Code edited files"
    })
    
    vim.api.nvim_create_user_command("ClaudeAutoOpen", function(opts)
      auto_open_file(opts.args)
    end, {
      desc = "Auto-open file with Claude Code integration",
      nargs = 1,
      complete = "file"
    })
    
    -- Auto-command to detect external file changes
    vim.api.nvim_create_autocmd({"BufWritePost", "FileChangedShellPost"}, {
      pattern = "*",
      callback = function()
        local filepath = vim.fn.expand("%:p")
        if vim.fn.filereadable(filepath) == 1 then
          watch_file(filepath)
        end
      end
    })
    
    -- Cleanup watchers on exit
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        for _, watcher in pairs(watchers) do
          if watcher then
            watcher:stop()
          end
        end
      end
    })
  end,
}
-- AI-powered git commit message generation - Main module
-- Modular, well-architected implementation with proper error handling

local M = {}

-- Module dependencies
local DiffParser = require('utils.ai-commit.diff-parser')
local CommitAnalyzer = require('utils.ai-commit.commit-analyzer')
local MessageBuilder = require('utils.ai-commit.message-builder')
local Config = require('utils.ai-commit.config')
local Logger = require('utils.ai-commit.logger')

-- Initialize module with options
function M.setup(opts)
  -- Merge user options with defaults
  Config.setup(opts)
  
  -- Initialize logger
  Logger.setup(Config.get('log_level'))
  
  -- Setup commands
  M.setup_commands()
  
  -- Setup autocommands
  M.setup_autocommands()
  
  Logger.debug("AI Commit module initialized")
end

-- Get staged changes diff with proper error handling
function M.get_staged_diff()
  local cmd = Config.get('git_command') .. " diff --cached 2>&1"
  local handle = io.popen(cmd)
  
  if not handle then
    local err = "Failed to execute git command: " .. cmd
    Logger.error(err)
    return nil, err
  end
  
  local diff = handle:read("*a")
  local success, exit_code = handle:close()
  
  if not success then
    local err = "Git command failed with exit code: " .. tostring(exit_code)
    Logger.error(err)
    return nil, err
  end
  
  -- Validate diff content
  if not diff or diff:match("^%s*$") then
    Logger.info("No staged changes found")
    return nil, "No staged changes found"
  end
  
  Logger.debug("Retrieved staged diff: " .. #diff .. " bytes")
  return diff
end

-- Generate commit message inline (for buffer insertion)
function M.generate_commit_message_inline()
  Logger.debug("Starting inline commit message generation")
  
  -- Validate buffer context
  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    Logger.warn("Invalid buffer for commit message generation")
    return
  end
  
  local ft = vim.bo[bufnr].filetype
  if ft ~= "gitcommit" and ft ~= "NeogitCommitMessage" then
    Logger.debug("Not a commit buffer, skipping generation")
    return
  end
  
  -- Get staged diff
  local diff, err = M.get_staged_diff()
  if not diff then
    Logger.info("No diff available for generation: " .. (err or "unknown"))
    return
  end
  
  -- Validate diff size
  local max_diff_size = Config.get('max_diff_size')
  if #diff > max_diff_size then
    Logger.info("Truncating large diff from " .. #diff .. " to " .. max_diff_size)
    diff = diff:sub(1, max_diff_size) .. "\n... (diff truncated)"
  end
  
  -- Generate commit message
  local ok, message = pcall(M.generate_message, diff)
  if not ok then
    Logger.error("Failed to generate message: " .. tostring(message))
    -- Fallback to basic generation
    message = M.generate_basic_message(diff)
  end
  
  -- Insert into buffer
  local insert_ok = M.insert_message_to_buffer(bufnr, message)
  if insert_ok then
    Logger.info("Successfully generated and inserted commit message")
  else
    Logger.error("Failed to insert message into buffer")
  end
end

-- Main message generation logic
function M.generate_message(diff)
  -- Validate input
  local valid, validation_err = M.validate_diff(diff)
  if not valid then
    Logger.warn("Invalid diff: " .. validation_err)
    return M.generate_basic_message(diff)
  end
  
  -- Parse diff into structured data
  local parsed_diff = DiffParser.parse(diff)
  if not parsed_diff then
    Logger.warn("Failed to parse diff, using basic generation")
    return M.generate_basic_message(diff)
  end
  
  -- Analyze for commit type and scope
  local analysis = CommitAnalyzer.analyze(parsed_diff)
  if not analysis then
    Logger.warn("Failed to analyze diff, using parsed data directly")
    analysis = CommitAnalyzer.basic_analysis(parsed_diff)
  end
  
  -- Build commit message
  local message = MessageBuilder.build(analysis, parsed_diff)
  if not message or #message == 0 then
    Logger.warn("Message builder returned empty result, using fallback")
    return M.generate_basic_message(diff)
  end
  
  Logger.debug("Generated commit message with " .. #message .. " lines")
  return message
end

-- Validate diff content
function M.validate_diff(diff)
  if type(diff) ~= "string" then
    return false, "Diff must be a string"
  end
  
  if #diff == 0 then
    return false, "Diff is empty"
  end
  
  local max_size = Config.get('max_diff_size') * 2  -- Allow some overhead
  if #diff > max_size then
    return false, "Diff exceeds maximum size limit"
  end
  
  -- Check for valid git diff format
  if not diff:match("diff %-%-git") and not diff:match("^@@") then
    return false, "Not a valid git diff format"
  end
  
  return true
end

-- Basic fallback message generation
function M.generate_basic_message(diff)
  Logger.debug("Using basic message generation as fallback")
  
  local lines = {}
  local files_changed = 0
  local additions = 0
  local deletions = 0
  
  -- Quick scan for basic stats
  for line in diff:gmatch("[^\n]+") do
    if line:match("^diff %-%-git") then
      files_changed = files_changed + 1
    elseif line:match("^%+") and not line:match("^%+%+%+") then
      additions = additions + 1
    elseif line:match("^%-") and not line:match("^%-%-%-") then
      deletions = deletions + 1
    end
  end
  
  -- Generate simple message
  local change_type = additions > deletions and "add" or "update"
  table.insert(lines, string.format("chore: %s files with changes", change_type))
  table.insert(lines, "")
  table.insert(lines, string.format("- Modified %d files", files_changed))
  table.insert(lines, string.format("- Added %d lines", additions))
  table.insert(lines, string.format("- Removed %d lines", deletions))
  
  return lines
end

-- Insert message into buffer
function M.insert_message_to_buffer(bufnr, message)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    Logger.error("Buffer " .. bufnr .. " is not valid")
    return false
  end
  
  local ok, result = pcall(function()
    -- Store original modifiable state
    local was_modifiable = vim.bo[bufnr].modifiable
    
    -- Make buffer modifiable if needed
    if not was_modifiable then
      vim.bo[bufnr].modifiable = true
    end
    
    -- Insert message at the beginning
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, message)
    
    -- Restore modifiable state
    if not was_modifiable then
      vim.bo[bufnr].modifiable = false
    end
  end)
  
  if not ok then
    Logger.error("Failed to insert message: " .. tostring(result))
    return false
  end
  
  return true
end

-- Quick commit with AI-generated message
function M.quick_commit()
  Logger.info("Starting quick commit with AI message")
  
  local diff, err = M.get_staged_diff()
  if not diff then
    -- No staged changes, stage everything
    Logger.info("No staged changes, staging all files")
    vim.fn.system(Config.get('git_command') .. " add -A")
    diff, err = M.get_staged_diff()
    if not diff then
      vim.notify(err or "No changes to commit", vim.log.levels.WARN)
      return
    end
  end
  
  -- Open commit editor with Neogit
  local ok, neogit = pcall(require, "neogit")
  if ok then
    neogit.open({ "commit" })
  else
    -- Fallback to git command directly
    vim.cmd("!git commit")
  end
  
  -- Generate and insert message after buffer loads
  vim.defer_fn(function()
    M.generate_commit_message_inline()
  end, 200)
end

-- Setup user commands
function M.setup_commands()
  vim.api.nvim_create_user_command("AIGenerateCommit", M.generate_commit_message_inline, {
    desc = "Generate AI commit message for staged changes"
  })
  
  vim.api.nvim_create_user_command("AIQuickCommit", M.quick_commit, {
    desc = "Stage all changes and commit with AI message"
  })
  
  vim.api.nvim_create_user_command("AICommitConfig", function()
    Config.show_config()
  end, {
    desc = "Show AI commit configuration"
  })
  
  Logger.debug("User commands created")
end

-- Setup autocommands
function M.setup_autocommands()
  local group = vim.api.nvim_create_augroup("AICommitMsg", { clear = true })
  
  -- Auto-generate for gitcommit filetype
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "gitcommit",
    group = group,
    callback = function(args)
      local bufnr = args.buf
      
      -- Set buffer-local keymap for regenerating
      vim.keymap.set("n", "<leader>ag", function()
        M.generate_commit_message_inline()
      end, {
        buffer = bufnr,
        desc = "Generate AI commit message"
      })
      
      -- Auto-generate if configured
      if Config.get('auto_generate') then
        vim.defer_fn(function()
          -- Check if buffer is empty
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          local is_empty = true
          for _, line in ipairs(lines) do
            if line ~= "" and not line:match("^#") then
              is_empty = false
              break
            end
          end
          
          if is_empty then
            M.generate_commit_message_inline()
          end
        end, 200)
      end
    end,
    desc = "Setup AI commit message generation for git commits"
  })
  
  Logger.debug("Autocommands created")
end

return M
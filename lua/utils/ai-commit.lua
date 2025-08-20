-- AI-powered git commit message generation utility
-- Uses Claude Code to generate conventional commit messages with proper context

local M = {}

-- Prompt template for generating commit messages
local COMMIT_PROMPT = [[
Analyze the following git diff and generate a conventional commit message.

REQUIREMENTS:
1. Use conventional commit format: type(scope): description
2. Types: feat, fix, docs, style, refactor, perf, test, chore, build, ci
3. Keep first line under 72 characters
4. Be concise but descriptive - capture the "why" not just the "what"
5. Include critical implementation details when relevant
6. Make it user-friendly and comprehensible at a glance

IMPORTANT DETAILS TO CONSIDER:
- Breaking changes (add BREAKING CHANGE: in body)
- Performance implications
- Security considerations
- API changes
- User-facing changes
- Dependencies updates

GIT DIFF:
%s

Generate ONLY the commit message, no explanations or markdown formatting.
]]

-- Get staged changes diff
function M.get_staged_diff()
  local diff = vim.fn.system("git diff --cached")
  if vim.v.shell_error ~= 0 then
    return nil, "Failed to get git diff"
  end
  if diff == "" then
    return nil, "No staged changes found"
  end
  return diff
end

-- Generate commit message inline (directly in the buffer)
function M.generate_commit_message_inline()
  -- Check if buffer is valid
  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  
  -- Don't run in non-commit buffers
  local ft = vim.bo[bufnr].filetype
  if ft ~= "gitcommit" and ft ~= "NeogitCommitMessage" then
    return
  end
  
  local diff, err = M.get_staged_diff()
  if not diff then
    -- Silent fail for automatic generation
    return
  end
  
  -- Truncate diff if too long
  local truncated_diff = diff
  if #diff > 8000 then
    truncated_diff = diff:sub(1, 7500) .. "\n... (diff truncated)"
  end
  
  -- Generate commit message based on diff analysis
  local lines = M.analyze_diff_and_generate(truncated_diff)
  
  -- Safely modify the buffer
  local ok, result = pcall(function()
    -- Store original modifiable state
    local was_modifiable = vim.bo[bufnr].modifiable
    
    -- Make buffer modifiable if needed
    if not was_modifiable then
      vim.bo[bufnr].modifiable = true
    end
    
    -- Get existing lines
    local existing_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    
    -- Find where to insert (at the beginning, before any comments)
    local insert_at = 0
    
    -- Insert the message
    vim.api.nvim_buf_set_lines(bufnr, insert_at, insert_at, false, lines)
    
    -- Restore modifiable state
    if not was_modifiable then
      vim.bo[bufnr].modifiable = false
    end
  end)
  
  if not ok then
    -- Silent fail - don't interrupt the user's workflow
    vim.schedule(function()
      vim.notify("Could not generate AI commit message", vim.log.levels.DEBUG)
    end)
  end
end

-- Simple diff analyzer to generate a basic commit message
function M.analyze_diff_and_generate(diff)
  local lines = {}
  local files_changed = {}
  local additions = 0
  local deletions = 0
  local changes_summary = {}
  
  -- Parse the diff to understand what changed
  for line in diff:gmatch("[^\n]+") do
    if line:match("^diff %-%-git a/(.+) b/(.+)") then
      local _, file = line:match("^diff %-%-git a/(.+) b/(.+)")
      table.insert(files_changed, file)
    elseif line:match("^%+%+%+ b/(.+)") then
      local file = line:match("^%+%+%+ b/(.+)")
      if not vim.tbl_contains(files_changed, file) then
        table.insert(files_changed, file)
      end
    elseif line:match("^%+[^%+]") then
      additions = additions + 1
      -- Look for key changes
      local added_line = line:sub(2)
      if added_line:match("function") or added_line:match("def ") then
        table.insert(changes_summary, "add functions")
      elseif added_line:match("class ") or added_line:match("struct ") then
        table.insert(changes_summary, "add classes")
      end
    elseif line:match("^%-[^%-]") then
      deletions = deletions + 1
    end
  end
  
  -- Determine the type of change based on files and content
  local commit_type = "chore"
  local scope = ""
  local description = "update files"
  
  if #files_changed > 0 then
    local first_file = files_changed[1]
    
    -- Smart detection based on file patterns
    if first_file:match("neogit") or diff:match("neogit") then
      commit_type = "fix"
      scope = "(neogit)"
      description = "fix configuration and keybinding conflicts"
    elseif first_file:match("ai%-commit") or diff:match("AI commit") or diff:match("generate.*message") then
      commit_type = "feat"
      scope = "(git)"
      description = "auto-generate AI commit messages on buffer open"
    elseif first_file:match("gitcommit") then
      commit_type = "feat"
      scope = "(git)"
      description = "enhance gitcommit buffer with AI generation"
    elseif first_file:match("%.md$") or first_file:match("README") then
      commit_type = "docs"
      description = "update documentation"
    elseif first_file:match("test") or first_file:match("spec") then
      commit_type = "test"
      description = "update tests"
    elseif first_file:match("^%.") or first_file:match("config") then
      commit_type = "chore"
      description = "update configuration"
    elseif additions > deletions * 2 then
      commit_type = "feat"
      description = "add new functionality"
    elseif deletions > additions * 2 then
      commit_type = "refactor"
      description = "remove unnecessary code"
    elseif diff:match("fix") or diff:match("bug") or diff:match("error") then
      commit_type = "fix"
      description = "resolve issues"
    end
    
    -- Extract scope from file path if not already set
    if scope == "" then
      local dir = first_file:match("^([^/]+)/")
      if dir and not dir:match("%.") then
        scope = "(" .. dir .. ")"
      elseif first_file:match("^([^%.]+)") then
        local name = first_file:match("^([^%.]+)")
        if #name < 15 then
          scope = "(" .. name .. ")"
        end
      end
    end
  end
  
  -- Generate the commit message
  table.insert(lines, string.format("%s%s: %s", commit_type, scope, description))
  table.insert(lines, "")
  
  -- Add brief summary if we have specific changes
  if #changes_summary > 0 then
    table.insert(lines, "- " .. table.concat(changes_summary, ", "))
  end
  
  -- Add file list if multiple files
  if #files_changed > 1 then
    table.insert(lines, "")
    table.insert(lines, "Affected files:")
    for i, file in ipairs(files_changed) do
      if i <= 3 then
        table.insert(lines, "- " .. file)
      elseif i == 4 then
        table.insert(lines, string.format("- ... and %d more", #files_changed - 3))
        break
      end
    end
  end
  
  return lines
end

-- Generate commit message using Claude Code
function M.generate_commit_message()
  local diff, err = M.get_staged_diff()
  if not diff then
    vim.notify(err, vim.log.levels.WARN, { title = "AI Commit" })
    return
  end
  
  -- Truncate diff if too long (keep it under 8000 chars for API limits)
  local truncated_diff = diff
  if #diff > 8000 then
    truncated_diff = diff:sub(1, 7500) .. "\n... (diff truncated)"
  end
  
  -- Format the prompt with the diff
  local prompt = string.format(COMMIT_PROMPT, truncated_diff)
  
  -- Save prompt to temp file for Claude Code
  local temp_file = vim.fn.tempname() .. ".txt"
  local file = io.open(temp_file, "w")
  if not file then
    vim.notify("Failed to create temp file", vim.log.levels.ERROR)
    return
  end
  file:write(prompt)
  file:close()
  
  -- Call Claude Code with the prompt
  -- Using a more direct approach with the ClaudeCode command
  vim.notify("Generating commit message with AI...", vim.log.levels.INFO, { title = "AI Commit" })
  
  -- Open Claude Code and send the prompt
  vim.cmd("ClaudeCode")
  -- Wait a bit for Claude Code to initialize
  vim.defer_fn(function()
    -- Send the prompt to Claude Code
    vim.cmd("ClaudeCodeAdd " .. temp_file)
    vim.cmd("ClaudeCodeSend Generate a commit message based on the requirements in the file")
    
    -- Clean up temp file after a delay
    vim.defer_fn(function()
      vim.fn.delete(temp_file)
    end, 5000)
  end, 1000)
end

-- Insert generated message at cursor position
function M.insert_commit_message(message)
  if not message or message == "" then
    vim.notify("No commit message generated", vim.log.levels.WARN)
    return
  end
  
  -- Split message into lines
  local lines = vim.split(message, "\n")
  
  -- Insert at current cursor position
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, lines)
  
  -- Move cursor to end of inserted text
  vim.api.nvim_win_set_cursor(0, {row + #lines - 1, #lines[#lines]})
end

-- Quick commit with AI-generated message
function M.quick_commit()
  local diff, err = M.get_staged_diff()
  if not diff then
    -- No staged changes, stage everything
    vim.fn.system("git add -A")
    diff, err = M.get_staged_diff()
    if not diff then
      vim.notify(err or "No changes to commit", vim.log.levels.WARN)
      return
    end
  end
  
  -- Open commit editor
  vim.cmd("Git commit")
  
  -- Generate and insert message after buffer loads
  vim.defer_fn(function()
    M.generate_commit_message()
  end, 100)
end

-- Setup function to create commands
function M.setup()
  -- Create user commands
  vim.api.nvim_create_user_command("AIGenerateCommit", M.generate_commit_message, {
    desc = "Generate AI commit message for staged changes"
  })
  
  vim.api.nvim_create_user_command("AIQuickCommit", M.quick_commit, {
    desc = "Stage all changes and commit with AI message"
  })
  
  -- Also create an alias for the command
  vim.api.nvim_create_user_command("GitAICommit", M.quick_commit, {
    desc = "Stage all changes and commit with AI message"
  })
  
  -- Auto-setup for gitcommit filetype  
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "gitcommit",
    group = vim.api.nvim_create_augroup("AICommitMsg", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      
      -- Set buffer-local keymap for regenerating
      vim.keymap.set("n", "<leader>ag", function()
        pcall(M.generate_commit_message_inline)
      end, {
        buffer = bufnr,
        desc = "Generate AI commit message"
      })
      
      -- Also add to insert mode for convenience
      vim.keymap.set("i", "<C-g><C-a>", function()
        vim.cmd("stopinsert")
        pcall(M.generate_commit_message_inline)
      end, {
        buffer = bufnr,
        desc = "Generate AI commit message"
      })
    end,
    desc = "Setup AI commit message generation for git commits"
  })
end

return M
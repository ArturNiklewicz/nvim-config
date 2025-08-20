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
      
      -- Set buffer-local keymaps
      vim.keymap.set("n", "<leader>ai", M.generate_commit_message, {
        buffer = bufnr,
        desc = "Generate AI commit message"
      })
      
      -- Also add to insert mode for convenience
      vim.keymap.set("i", "<C-g><C-a>", function()
        vim.cmd("stopinsert")
        M.generate_commit_message()
      end, {
        buffer = bufnr,
        desc = "Generate AI commit message"
      })
      
      -- Add helpful message
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(bufnr) and 
           vim.api.nvim_buf_get_option(bufnr, "filetype") == "gitcommit" then
          -- Check if buffer is empty (new commit)
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)
          if #lines == 0 or lines[1] == "" then
            vim.notify("Press <leader>ai to generate AI commit message", vim.log.levels.INFO)
          end
        end
      end, 100)
    end,
    desc = "Setup AI commit message generation for git commits"
  })
end

return M
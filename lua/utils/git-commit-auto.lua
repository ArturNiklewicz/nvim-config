-- Auto-generate commit messages using AI
-- Uses OpenAI API with gpt-4o-mini for speed (~300-600ms)
-- Triggers on COMMIT_EDITMSG (works with git commit -v, Neogit, fugitive)

local M = {}

-- Config
local CONFIG = {
  model = "gpt-4o-mini",
  max_tokens = 300,
  api_url = "https://api.openai.com/v1/chat/completions",
  max_diff_size = 6000,
  timeout_ms = 10000,
}

-- Build the prompt for commit message generation
local function build_prompt(branch, files, diff)
  return string.format([[Generate a conventional commit message for these changes.

BRANCH: %s
FILES:
%s

DIFF:
%s

FORMAT:
type(scope): subject (imperative, max 72 chars)

    Body explaining WHAT and WHY.
    - Key changes per file
    - Rationale/context

TYPES: feat|fix|refactor|docs|test|chore|perf|style|ci|build

Output ONLY the commit message, starting with the type:]], branch, files, diff)
end

-- Extract commit message from AI response (filter markdown artifacts)
local function extract_commit_message(text)
  if not text or text == "" then return nil end

  local lines = {}
  local in_msg = false

  for line in text:gmatch("[^\r\n]+") do
    if not in_msg and line:match("^[a-z]+%(?[^)]*%)?:%s") then
      in_msg = true
    end
    if in_msg then
      if line:match("^```") or line:match("^%*%*") or line:match("^%-%-%-") then
        break
      end
      table.insert(lines, line)
    end
  end

  return #lines > 0 and table.concat(lines, "\n") or nil
end

-- Generate commit message using OpenAI API
local function generate_commit_message(callback)
  local api_key = os.getenv("OPENAI_API_KEY")
  if not api_key then
    callback(nil, "OPENAI_API_KEY not set")
    return
  end

  -- Get git context
  local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("%s+$", "")
  if branch == "" then branch = "main" end

  local files = vim.fn.system("git diff --staged --name-status 2>/dev/null")
  local diff = vim.fn.system("git diff --staged 2>/dev/null")

  if not diff or diff == "" then
    callback(nil, "No staged changes")
    return
  end

  -- Truncate diff if too large
  if #diff > CONFIG.max_diff_size then
    diff = diff:sub(1, CONFIG.max_diff_size - 500) .. "\n\n... (truncated)"
  end

  -- Build request payload (OpenAI format)
  local prompt = build_prompt(branch, files, diff)
  local payload = vim.fn.json_encode({
    model = CONFIG.model,
    max_tokens = CONFIG.max_tokens,
    messages = { { role = "user", content = prompt } },
  })

  -- Call OpenAI API using curl (async via vim.system)
  local curl_args = {
    "curl", "-s", "--max-time", tostring(CONFIG.timeout_ms / 1000),
    CONFIG.api_url,
    "-H", "Authorization: Bearer " .. api_key,
    "-H", "Content-Type: application/json",
    "-d", payload,
  }

  vim.system(curl_args, { text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        callback(nil, "curl failed: " .. (res.stderr or ""))
        return
      end

      local ok, response = pcall(vim.fn.json_decode, res.stdout)
      if not ok or not response then
        callback(nil, "Failed to parse API response")
        return
      end

      -- Check for API errors
      if response.error then
        callback(nil, response.error.message or "API error")
        return
      end

      -- Extract message text (OpenAI format: choices[0].message.content)
      local text = response.choices and response.choices[1] and response.choices[1].message and response.choices[1].message.content
      local message = extract_commit_message(text)

      if message then
        callback(message, nil)
      else
        callback(nil, "No valid commit message in response")
      end
    end)
  end)
end

-- Insert commit message into buffer
local function insert_message(bufnr, message, replace)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  local lines = vim.split(message, "\n")

  if replace then
    -- Find where comments start (lines beginning with #)
    local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local comment_start = #buf_lines
    for i, line in ipairs(buf_lines) do
      if line:match("^#") then
        comment_start = i - 1
        break
      end
    end
    -- Replace content before comments
    vim.api.nvim_buf_set_lines(bufnr, 0, comment_start, false, lines)
  else
    -- Insert at top
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, lines)
  end

  vim.cmd("normal! gg")
end

function M.setup()
  local group = vim.api.nvim_create_augroup("AICommitMessage", { clear = true })

  -- Track buffers we've already processed to avoid double-triggering
  local processed_buffers = {}

  -- Generate commit message when entering commit buffer
  -- Use FileType event which fires reliably for both git commit and Neogit
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "gitcommit",
    callback = function(args)
      local bufnr = args.buf

      -- Skip if already processed this buffer
      if processed_buffers[bufnr] then return end
      processed_buffers[bufnr] = true

      -- Clean up tracking when buffer is deleted
      vim.api.nvim_create_autocmd("BufDelete", {
        buffer = bufnr,
        once = true,
        callback = function()
          processed_buffers[bufnr] = nil
        end,
      })

      -- Defer to let buffer content load first
      vim.defer_fn(function()
        if not vim.api.nvim_buf_is_valid(bufnr) then return end

        -- Skip if already has content (non-comment lines)
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 5, false)
        for _, line in ipairs(lines) do
          if line ~= "" and not line:match("^#") then return end
        end

        vim.notify("Generating commit message...", vim.log.levels.INFO)

        generate_commit_message(function(message, err)
          if err then
            vim.notify("Commit msg failed: " .. err, vim.log.levels.WARN)
            return
          end
          if message then
            insert_message(bufnr, message, false)
            vim.notify("✓ Commit message generated", vim.log.levels.INFO)
          end
        end)
      end, 50) -- Small delay for buffer to be ready

      -- Also set up the regenerate keymap
      vim.keymap.set("n", "<Leader>ag", function()
        vim.notify("Regenerating commit message...", vim.log.levels.INFO)

        generate_commit_message(function(message, err)
          if err then
            vim.notify("Regenerate failed: " .. err, vim.log.levels.WARN)
            return
          end
          if message then
            insert_message(bufnr, message, true)
            vim.notify("✓ Commit message regenerated", vim.log.levels.INFO)
          end
        end)
      end, { buffer = bufnr, desc = "Regenerate commit message" })
    end,
    desc = "Auto-generate AI commit message",
  })
end

return M

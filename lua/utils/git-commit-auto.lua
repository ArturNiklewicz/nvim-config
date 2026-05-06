-- Auto-generate commit messages using AI
-- Uses OpenAI API with gpt-4o-mini + streaming
-- Parallel git commands + real-time token streaming via jobstart

local M = {}

local CONFIG = {
  model = "qwen3-35b",
  max_tokens = 300,
  api_url = "https://api.zrobmyto.ai/v1/chat/completions",
  max_diff_size = 6000,
}

local function build_prompt(branch, files, diff)
  return string.format(
    [[Generate a conventional commit message.

BRANCH: %s
FILES:
%s

DIFF:
%s

FORMAT: type(scope): subject

Body with WHAT and WHY.

TYPES: feat|fix|refactor|docs|test|chore|perf|style|ci|build

Output ONLY the commit message:]],
    branch,
    files,
    diff
  )
end

-- Parallel git context fetch
local function get_git_context(callback)
  local results = { branch = "main", files = "", diff = "" }
  local pending = 3

  local function done()
    pending = pending - 1
    if pending == 0 then callback(results) end
  end

  vim.system({ "git", "branch", "--show-current" }, { text = true }, function(r)
    vim.schedule(function()
      if r.code == 0 and r.stdout then results.branch = r.stdout:gsub("%s+$", "") end
      done()
    end)
  end)

  vim.system({ "git", "diff", "--staged", "--name-status" }, { text = true }, function(r)
    vim.schedule(function()
      if r.code == 0 then results.files = r.stdout or "" end
      done()
    end)
  end)

  vim.system({ "git", "diff", "--staged" }, { text = true }, function(r)
    vim.schedule(function()
      if r.code == 0 then
        local diff = r.stdout or ""
        if #diff > CONFIG.max_diff_size then diff = diff:sub(1, CONFIG.max_diff_size - 100) .. "\n...(truncated)" end
        results.diff = diff
      end
      done()
    end)
  end)
end

-- Stream commit message into buffer
local function stream_commit_message(bufnr, on_done)
  local api_key = os.getenv "OPENAI_API_KEY"
  if not api_key then
    on_done "OPENAI_API_KEY not set"
    return
  end

  get_git_context(function(ctx)
    if ctx.diff == "" then
      on_done "No staged changes"
      return
    end

    local payload = vim.fn.json_encode {
      model = CONFIG.model,
      max_tokens = CONFIG.max_tokens,
      stream = true,
      messages = { { role = "user", content = build_prompt(ctx.branch, ctx.files, ctx.diff) } },
    }

    -- Write payload to temp file (avoids shell escaping issues)
    local tmpfile = vim.fn.tempname()
    local f = io.open(tmpfile, "w")
    if not f then
      on_done "Failed to create temp file"
      return
    end
    f:write(payload)
    f:close()

    local content = ""
    local comment_start = nil

    -- Find where git comments start (cache this)
    local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(buf_lines) do
      if line:match "^#" then
        comment_start = i - 1
        break
      end
    end
    comment_start = comment_start or #buf_lines

    -- Clear content area
    if comment_start > 0 then vim.api.nvim_buf_set_lines(bufnr, 0, comment_start, false, {}) end

    local job_id = vim.fn.jobstart({
      "curl",
      "-sN",
      CONFIG.api_url,
      "-H",
      "Authorization: Bearer " .. api_key,
      "-H",
      "Content-Type: application/json",
      "-d",
      "@" .. tmpfile,
    }, {
      on_stdout = function(_, data, _)
        for _, line in ipairs(data) do
          -- Parse SSE: "data: {...}"
          local json_str = line:match "^data: (.+)$"
          if json_str and json_str ~= "[DONE]" then
            local ok, parsed = pcall(vim.fn.json_decode, json_str)
            if ok and parsed.choices and parsed.choices[1] then
              local delta = parsed.choices[1].delta
              if delta and delta.content then
                content = content .. delta.content

                -- Update buffer with current content
                vim.schedule(function()
                  if not vim.api.nvim_buf_is_valid(bufnr) then return end

                  -- Extract commit message (skip preamble if any)
                  local msg = content
                  local start_idx = msg:find "[a-z]+%(?[^)]*%)?:%s"
                  if start_idx and start_idx > 1 then msg = msg:sub(start_idx) end

                  -- Remove markdown artifacts
                  msg = msg:gsub("```[^\n]*\n?", ""):gsub("^%*%*.*%*%*\n?", "")

                  local lines = vim.split(msg, "\n", { plain = true })

                  -- Find current comment position
                  local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                  local cur_comment = #current_lines
                  for i, l in ipairs(current_lines) do
                    if l:match "^#" then
                      cur_comment = i - 1
                      break
                    end
                  end

                  vim.api.nvim_buf_set_lines(bufnr, 0, cur_comment, false, lines)
                end)
              end
            end
          end
        end
      end,

      on_exit = function(_, code, _)
        vim.schedule(function()
          os.remove(tmpfile)
          if code == 0 and content ~= "" then
            on_done(nil)
          else
            on_done(code ~= 0 and "curl failed" or "Empty response")
          end
        end)
      end,

      stdout_buffered = false,
    })

    if job_id <= 0 then
      os.remove(tmpfile)
      on_done "Failed to start curl"
    end
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("AICommitMessage", { clear = true })
  local processed = {}

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "gitcommit",
    callback = function(args)
      local bufnr = args.buf
      if processed[bufnr] then return end
      processed[bufnr] = true

      vim.api.nvim_create_autocmd("BufDelete", {
        buffer = bufnr,
        once = true,
        callback = function() processed[bufnr] = nil end,
      })

      vim.defer_fn(function()
        if not vim.api.nvim_buf_is_valid(bufnr) then return end

        -- Skip if already has content
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 5, false)
        for _, line in ipairs(lines) do
          if line ~= "" and not line:match "^#" then return end
        end

        vim.notify("Generating...", vim.log.levels.INFO)

        stream_commit_message(bufnr, function(err)
          if err then
            vim.notify("Failed: " .. err, vim.log.levels.WARN)
          else
            vim.notify("✓ Done", vim.log.levels.INFO)
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(bufnr) then vim.api.nvim_win_set_cursor(0, { 1, 0 }) end
            end)
          end
        end)
      end, 50)

      -- Regenerate keymap
      vim.keymap.set("n", "<Leader>ag", function()
        vim.notify("Regenerating...", vim.log.levels.INFO)
        stream_commit_message(bufnr, function(err)
          if err then
            vim.notify("Failed: " .. err, vim.log.levels.WARN)
          else
            vim.notify("✓ Done", vim.log.levels.INFO)
          end
        end)
      end, { buffer = bufnr, desc = "Regenerate commit message" })
    end,
  })
end

return M

-- Auto-generate commit messages for Neogit and git commit buffers
-- Calls bash script and inserts result into buffer
-- Single Claude call for speed, conventional commit format

local M = {}

-- Track buffers we've already generated for (prevents duplicates)
local generated_buffers = {}

-- Generate commit message and insert into buffer
function M.generate_for_buffer(bufnr, force)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check if buffer is valid
  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  -- Check filetype
  local ft = vim.bo[bufnr].filetype
  if ft ~= "gitcommit" and ft ~= "NeogitCommitMessage" then
    return
  end

  -- Prevent duplicate generation (unless forced)
  if not force and generated_buffers[bufnr] then
    return
  end

  -- Check if buffer already has content (non-comment, non-empty lines)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local has_content = false
  for _, line in ipairs(lines) do
    -- Skip empty lines and git comment lines
    if line ~= "" and not line:match("^#") then
      has_content = true
      break
    end
  end

  if has_content and not force then
    -- Buffer already has content, mark as generated and skip
    generated_buffers[bufnr] = true
    return
  end

  -- Mark buffer as being processed
  generated_buffers[bufnr] = true

  -- Get script path
  local script_path = vim.fn.stdpath("config") .. "/scripts/git-commit-ai.sh"

  -- Check if script exists
  if vim.fn.filereadable(script_path) ~= 1 then
    vim.notify("git-commit-ai.sh not found", vim.log.levels.WARN)
    return
  end

  -- Call script in non-interactive mode
  local cmd = string.format("SKIP_PREVIEW=1 NONINTERACTIVE=1 %s 2>&1", script_path)

  vim.notify("Generating commit message...", vim.log.levels.INFO)

  -- Run async
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data or #data == 0 then return end

      -- Filter trailing empty lines
      while #data > 0 and (data[#data] == "" or data[#data] == nil) do
        table.remove(data)
      end

      if #data == 0 then return end

      -- Update buffer on main thread
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(bufnr) then return end

        -- Make buffer modifiable
        local was_modifiable = vim.bo[bufnr].modifiable
        if not was_modifiable then
          vim.bo[bufnr].modifiable = true
        end

        -- Insert at beginning of buffer
        vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, data)

        -- Restore modifiable state
        if not was_modifiable then
          vim.bo[bufnr].modifiable = false
        end

        vim.notify("✓ Commit message generated", vim.log.levels.INFO)
      end)
    end,
    on_stderr = function(_, data)
      if not data or #data == 0 then return end

      vim.schedule(function()
        local msg = table.concat(data, "\n")
        if msg ~= "" and not msg:match("^%s*$") then
          vim.notify("Commit error: " .. msg, vim.log.levels.ERROR)
        end
      end)
    end,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.schedule(function()
          vim.notify("Commit generation failed (exit " .. exit_code .. ")", vim.log.levels.ERROR)
        end)
      end
    end,
  })
end

-- Setup autocommands
function M.setup()
  local group = vim.api.nvim_create_augroup("GitCommitAuto", { clear = true })

  -- Auto-generate for commit buffers
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "gitcommit", "NeogitCommitMessage" },
    group = group,
    callback = function(args)
      -- Delay to let buffer settle
      vim.defer_fn(function()
        M.generate_for_buffer(args.buf)
      end, 150)
    end,
    desc = "Auto-generate commit message",
  })

  -- Manual regenerate keymap
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "gitcommit", "NeogitCommitMessage" },
    group = group,
    callback = function(args)
      vim.keymap.set("n", "<Leader>ag", function()
        -- Force regeneration
        M.generate_for_buffer(args.buf, true)
      end, {
        buffer = args.buf,
        desc = "Regenerate commit message",
      })
    end,
    desc = "Add regenerate keymap",
  })

  -- Clean up tracking when buffer is deleted
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
      generated_buffers[args.buf] = nil
    end,
    desc = "Clean up buffer tracking",
  })
end

return M

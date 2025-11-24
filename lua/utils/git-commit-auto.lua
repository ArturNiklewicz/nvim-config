-- Auto-generate commit messages for Neogit and git commit buffers
-- Calls bash script and inserts result into buffer

local M = {}

-- Generate commit message and insert into buffer
function M.generate_for_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check if buffer is valid and is a commit buffer
  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  local ft = vim.bo[bufnr].filetype
  if ft ~= "gitcommit" and ft ~= "NeogitCommitMessage" then
    return
  end

  -- Check if buffer is already populated (has non-comment lines)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local has_content = false
  for _, line in ipairs(lines) do
    if line ~= "" and not line:match("^#") then
      has_content = true
      break
    end
  end

  if has_content then
    -- Buffer already has content, don't auto-generate
    return
  end

  -- Get script path
  local script_path = vim.fn.stdpath("config") .. "/scripts/git-commit-ai.sh"

  -- Check if script exists
  if vim.fn.filereadable(script_path) ~= 1 then
    vim.notify("git-commit-ai.sh not found", vim.log.levels.WARN)
    return
  end

  -- Call script in non-interactive mode (generate message only)
  local cmd = string.format("SKIP_PREVIEW=1 NONINTERACTIVE=1 %s 2>&1", script_path)

  vim.notify("Generating commit message with AI...", vim.log.levels.INFO)

  -- Run async to not block UI
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data or #data == 0 then return end

      -- Filter out empty lines at the end
      while #data > 0 and (data[#data] == "" or data[#data] == nil) do
        table.remove(data)
      end

      if #data == 0 then return end

      -- Schedule buffer update on main thread
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
        if msg ~= "" then
          vim.notify("Error generating commit: " .. msg, vim.log.levels.ERROR)
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

  -- Auto-generate for gitcommit filetype
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "gitcommit", "NeogitCommitMessage" },
    group = group,
    callback = function(args)
      -- Delay slightly to let buffer settle (150ms for faster response)
      vim.defer_fn(function()
        M.generate_for_buffer(args.buf)
      end, 150)
    end,
    desc = "Auto-generate commit message with bash script",
  })

  -- Also provide manual trigger keymap in commit buffers
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "gitcommit", "NeogitCommitMessage" },
    group = group,
    callback = function(args)
      vim.keymap.set("n", "<Leader>ag", function()
        M.generate_for_buffer(args.buf)
      end, {
        buffer = args.buf,
        desc = "Regenerate commit message",
      })
    end,
    desc = "Add regenerate keymap to commit buffers",
  })
end

return M

-- Auto-generate commit messages using AI
-- Triggers on COMMIT_EDITMSG (works with git commit -v, Neogit, fugitive)

local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("AICommitMessage", { clear = true })

  -- Generate commit message when entering commit buffer
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    pattern = { "COMMIT_EDITMSG", "NeogitCommitMessage" },
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()

      -- Skip if already has content (non-comment lines)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 5, false)
      for _, line in ipairs(lines) do
        if line ~= "" and not line:match("^#") then
          return
        end
      end

      -- Get script path
      local script = vim.fn.stdpath("config") .. "/scripts/ai-commit-msg"
      if vim.fn.executable(script) ~= 1 then
        return
      end

      vim.notify("Generating commit message...", vim.log.levels.INFO)

      -- Run async
      vim.system({ script }, {}, function(res)
        vim.schedule(function()
          if res.code ~= 0 then
            vim.notify("Commit msg failed: " .. (res.stderr or ""), vim.log.levels.WARN)
            return
          end

          local msg = res.stdout
          if not msg or msg == "" then
            return
          end

          -- Insert at top of buffer
          if vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, vim.split(msg, "\n"))
            vim.notify("✓ Commit message generated", vim.log.levels.INFO)
          end
        end)
      end)
    end,
    desc = "Auto-generate AI commit message",
  })

  -- Manual regenerate keymap
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "gitcommit", "NeogitCommitMessage" },
    callback = function(args)
      vim.keymap.set("n", "<Leader>ag", function()
        local script = vim.fn.stdpath("config") .. "/scripts/ai-commit-msg"
        vim.notify("Regenerating commit message...", vim.log.levels.INFO)

        vim.system({ script }, {}, function(res)
          vim.schedule(function()
            if res.code == 0 and res.stdout and res.stdout ~= "" then
              -- Clear and insert new message
              vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, {})
              vim.api.nvim_buf_set_lines(args.buf, 0, 0, false, vim.split(res.stdout, "\n"))
              vim.notify("✓ Commit message regenerated", vim.log.levels.INFO)
            end
          end)
        end)
      end, { buffer = args.buf, desc = "Regenerate commit message" })
    end,
  })
end

return M

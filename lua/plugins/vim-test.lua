return {
  "vim-test/vim-test",
  dependencies = {
    "akinsho/toggleterm.nvim",
  },
  keys = {
    { "<leader>tn", function() require("utils.smart-test").run_test("nearest") end, desc = "Test Nearest" },
    { "<leader>tf", function() require("utils.smart-test").run_test("file") end, desc = "Test File" },
    { "<leader>ts", function() require("utils.smart-test").run_test("suite") end, desc = "Test Suite" },
    { "<leader>tl", function() require("utils.smart-test").run_test("last") end, desc = "Test Last" },
    { "<leader>tv", "<cmd>TestVisit<cr>", desc = "Test Visit" },
  },
  config = function()
    -- Use neovim strategy - opens terminal in current window (replaces buffer)
    vim.g["test#strategy"] = "neovim"

    -- IMPORTANT: Set term_position to empty string to open terminal in current window
    -- Empty string = no split, just replace current buffer with terminal
    vim.g["test#neovim#term_position"] = ""

    -- Configure test runners for specific languages
    vim.g["test#python#runner"] = "pytest"
    vim.g["test#javascript#runner"] = "jest"
    vim.g["test#ruby#runner"] = "rspec"

    -- Pytest configuration with verbose output
    vim.g["test#python#pytest#options"] = "-vv"
    vim.g["test#javascript#jest#options"] = "--no-coverage"

    -- Auto-detect Python test executable based on project environment
    -- Priority: uv > poetry > pipenv > .venv/venv > system python
    local function detect_pytest_executable()
      local root = vim.fn.getcwd()
      if vim.fn.filereadable(root .. "/uv.lock") == 1 then
        return "uv run pytest"
      elseif vim.fn.filereadable(root .. "/poetry.lock") == 1 then
        return "poetry run pytest"
      elseif vim.fn.filereadable(root .. "/Pipfile.lock") == 1 then
        return "pipenv run pytest"
      elseif vim.fn.filereadable(root .. "/.venv/bin/pytest") == 1 then
        return root .. "/.venv/bin/pytest"
      elseif vim.fn.filereadable(root .. "/venv/bin/pytest") == 1 then
        return root .. "/venv/bin/pytest"
      else
        return "python3 -m pytest"
      end
    end

    vim.g["test#python#pytest#executable"] = detect_pytest_executable()

    -- Re-detect when changing directories
    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function()
        vim.g["test#python#pytest#executable"] = detect_pytest_executable()
      end,
    })

    -- Auto-copy test results to clipboard when test terminal closes
    vim.api.nvim_create_autocmd("TermClose", {
      callback = function(ev)
        local bufnr = ev.buf
        if not vim.api.nvim_buf_is_valid(bufnr) then return end

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        -- Filter out empty trailing lines and ANSI escape codes
        local clean = {}
        for _, line in ipairs(lines) do
          local stripped = line:gsub("\27%[[%d;]*m", ""):gsub("\r", "")
          if stripped ~= "" then
            table.insert(clean, stripped)
          end
        end

        if #clean == 0 then return end

        -- Only capture if it looks like test output (pytest/jest/rspec markers)
        local output = table.concat(clean, "\n")
        if output:match("pytest") or output:match("PASSED") or output:match("FAILED")
          or output:match("ERROR") or output:match("jest") or output:match("rspec")
          or output:match("test session starts") then
          vim.fn.setreg("+", output)
          vim.notify("Test results copied to clipboard", vim.log.levels.INFO)
        end
      end,
    })
  end,
}

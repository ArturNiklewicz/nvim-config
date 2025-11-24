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

    -- Custom transformation to ensure proper Python execution
    vim.g["test#python#pytest#executable"] = "python3 -m pytest"
  end,
}

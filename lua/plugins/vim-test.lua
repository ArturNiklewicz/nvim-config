return {
  "vim-test/vim-test",
  dependencies = {
    "preservim/vimux",
  },
  keys = {
    { "<leader>tn", "<cmd>TestNearest<cr>", desc = "Test Nearest" },
    { "<leader>tf", "<cmd>TestFile<cr>", desc = "Test File" },
    { "<leader>ts", "<cmd>TestSuite<cr>", desc = "Test Suite" },
    { "<leader>tl", "<cmd>TestLast<cr>", desc = "Test Last" },
    { "<leader>tv", "<cmd>TestVisit<cr>", desc = "Test Visit" },
  },
  config = function()
    -- Configure vim-test to use vimux strategy
    vim.g["test#strategy"] = "vimux"
    
    -- Configure vimux settings
    vim.g.VimuxHeight = "30"
    vim.g.VimuxOrientation = "v"
    vim.g.VimuxUseNearest = 1
    
    -- Optional: Configure test runners for specific languages
    vim.g["test#python#runner"] = "pytest"
    vim.g["test#javascript#runner"] = "jest"
    vim.g["test#ruby#runner"] = "rspec"
    
    -- Optional: Configure custom mappings
    vim.cmd([[
      let test#python#pytest#options = '-vv'
      let test#javascript#jest#options = '--no-coverage'
    ]])
  end,
}
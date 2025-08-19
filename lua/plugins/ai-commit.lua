-- AI-powered commit message generation
return {
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    config = function()
      -- Disable default keybindings
      vim.g.codeium_disable_bindings = 1
      
      -- AI commit message command
      vim.api.nvim_create_user_command("AICommit", function()
        -- Stage changes if not already staged
        local staged = vim.fn.system("git diff --cached --name-only")
        if staged == "" then
          vim.fn.system("git add -A")
        end
        
        -- Get diff for context
        local diff = vim.fn.system("git diff --cached")
        
        -- Create commit message buffer
        vim.cmd("new")
        vim.cmd("setlocal buftype=nofile")
        vim.cmd("setlocal bufhidden=wipe")
        vim.cmd("setlocal nobuflisted")
        vim.cmd("file AI_COMMIT_MESSAGE")
        
        -- Add template
        local lines = {
          "# AI-Generated Commit Message",
          "# Edit as needed, then :wq to commit or :q! to cancel",
          "",
          "feat: ",
          "",
          "# Diff context:",
        }
        
        -- Add diff summary (first 20 lines)
        local diff_lines = vim.split(diff, '\n')
        for i = 1, math.min(20, #diff_lines) do
          table.insert(lines, "# " .. diff_lines[i])
        end
        
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.cmd("normal! 4G$")
        
        -- Set up autocmd to commit on save
        vim.cmd([[
          autocmd BufWritePost <buffer> lua vim.fn.system("git commit -F " .. vim.fn.expand("%:p"))
          autocmd BufWritePost <buffer> bdelete!
        ]])
      end, { desc = "Generate AI commit message" })
      
      -- Keybinding
      vim.keymap.set("n", "<leader>gC", "<cmd>AICommit<cr>", { desc = "AI commit message" })
    end,
  },
  
  -- Alternative: Simple commit helper
  {
    "2kabhishek/co-author.nvim",
    dependencies = { "stevearc/dressing.nvim" },
    cmd = { "CoAuthor" },
    keys = {
      { "<leader>gA", "<cmd>CoAuthor<cr>", desc = "Add co-author to commit" },
    },
    config = true,
  },
}
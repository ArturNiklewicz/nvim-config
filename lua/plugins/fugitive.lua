-- vim-fugitive: Premier git integration for Neovim
-- Provides comprehensive Git commands and workflow integration

return {
  "tpope/vim-fugitive",
  cmd = {
    "Git",
    "G",
    "Gstatus",
    "Gblame",
    "Gpush",
    "Gpull",
    "Gcommit",
    "Glog",
    "Gdiff",
    "Gdiffsplit",
    "Gread",
    "Gwrite",
    "Ggrep",
    "GMove",
    "GDelete",
    "GBrowse",
    "GRemove",
    "GRename",
    "Glgrep",
    "Gedit",
    "Gsplit",
    "Gvsplit",
    "Gtabedit",
    "Gpedit",
    "Ghdiffsplit",
    "GvDiffsplit",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    -- Main Git interface
    { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
    { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
    { "<leader>gC", "<cmd>Git commit --amend<cr>", desc = "Git commit amend" },
    
    -- Diff operations
    { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff split" },
    { "<leader>gD", "<cmd>Git diff<cr>", desc = "Git diff" },
    
    -- Blame and history
    { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
    { "<leader>gl", "<cmd>Git log<cr>", desc = "Git log" },
    { "<leader>gL", "<cmd>Git log --oneline<cr>", desc = "Git log (oneline)" },
    
    -- Push/Pull operations
    { "<leader>gp", "<cmd>Git push<cr>", desc = "Git push" },
    { "<leader>gP", "<cmd>Git pull<cr>", desc = "Git pull" },
    
    -- Branch operations
    { "<leader>gB", "<cmd>Git branch<cr>", desc = "Git branches" },
    { "<leader>go", "<cmd>Git checkout<cr>", desc = "Git checkout" },
    
    -- Stash operations
    { "<leader>gS", "<cmd>Git stash<cr>", desc = "Git stash" },
    { "<leader>gU", "<cmd>Git stash pop<cr>", desc = "Git stash pop" },
    
    -- File operations
    { "<leader>gr", "<cmd>Gread<cr>", desc = "Git read (checkout file)" },
    { "<leader>gw", "<cmd>Gwrite<cr>", desc = "Git write (stage file)" },
    
    -- Browse/Open in browser
    { "<leader>gO", "<cmd>GBrowse<cr>", desc = "Open in GitHub", mode = { "n", "v" } },
    
    -- Quick actions in visual mode
    { "<leader>gO", ":GBrowse<cr>", desc = "Open in GitHub", mode = "v" },
  },
  config = function()
    -- Set up fugitive-specific keymaps that are active in fugitive buffers
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "fugitive",
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local opts = { buffer = bufnr, remap = false }
        
        -- Navigation
        vim.keymap.set("n", "<Tab>", "=", opts)
        vim.keymap.set("n", "q", "<cmd>close<cr>", opts)
        
        -- Staging/Unstaging
        vim.keymap.set("n", "s", "s", opts) -- Stage
        vim.keymap.set("n", "u", "u", opts) -- Unstage
        vim.keymap.set("n", "U", "U", opts) -- Unstage all
        
        -- Commit
        vim.keymap.set("n", "cc", "cc", opts) -- Commit
        vim.keymap.set("n", "ca", "ca", opts) -- Commit amend
        vim.keymap.set("n", "ce", "ce", opts) -- Commit amend (edit message)
        
        -- Diff
        vim.keymap.set("n", "dd", "dd", opts) -- Diff
        vim.keymap.set("n", "dv", "dv", opts) -- Diff vertical split
      end,
    })
    
    -- Create user commands for common workflows
    vim.api.nvim_create_user_command("GitQuickCommit", function(opts)
      vim.cmd("Git add -A")
      vim.cmd("Git commit -m '" .. opts.args .. "'")
    end, { nargs = 1, desc = "Quick commit with message" })
    
    vim.api.nvim_create_user_command("GitPushOrigin", function()
      vim.cmd("Git push origin HEAD")
    end, { desc = "Push current branch to origin" })
    
    vim.api.nvim_create_user_command("GitPullRebase", function()
      vim.cmd("Git pull --rebase")
    end, { desc = "Pull with rebase" })
  end,
}
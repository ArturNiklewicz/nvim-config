return {
  "tpope/vim-fugitive",
  cmd = {
    "G",
    "Git",
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
    "Gdrop",
  },
  ft = { "fugitive", "gitcommit", "gitrebase" },
  dependencies = {
    "tpope/vim-rhubarb",
  },
  config = function()
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = vim.api.nvim_create_augroup("fugitive_autocmd", { clear = true }),
      pattern = "*",
      callback = function()
        if vim.bo.ft ~= "fugitive" then
          return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = { buffer = bufnr, remap = false }
        
        vim.keymap.set("n", "<leader>gp", function()
          vim.cmd.Git("push")
        end, opts)

        vim.keymap.set("n", "<leader>gP", function()
          vim.cmd.Git({ "pull", "--rebase" })
        end, opts)

        vim.keymap.set("n", "<leader>gt", "<cmd>Git push -u origin<CR>", opts)
      end,
    })

    local fugitive_group = vim.api.nvim_create_augroup("Fugitive", { clear = true })
    
    vim.api.nvim_create_autocmd("User", {
      pattern = "FugitiveChanged",
      group = fugitive_group,
      callback = function()
        if vim.bo.filetype == "fugitive" then
          vim.cmd("normal! g<C-G>")
        end
      end,
    })
  end,
  keys = {
    { "<leader>gG", "<cmd>Git<CR>", desc = "Fugitive status" },
    { "<leader>gB", "<cmd>Git blame<CR>", desc = "Git blame" },
    { "<leader>gL", "<cmd>Git log<CR>", desc = "Git log" },
    { "<leader>gR", "<cmd>Gread<CR>", desc = "Git read (checkout file)" },
    { "<leader>gW", "<cmd>Gwrite<CR>", desc = "Git write (stage file)" },
    { "<leader>gE", "<cmd>Gedit<CR>", desc = "Git edit" },
    { "<leader>gD", "<cmd>Gdiffsplit<CR>", desc = "Git diff split" },
    { "<leader>gV", "<cmd>Gvsplit<CR>", desc = "Git vsplit" },
  },
}
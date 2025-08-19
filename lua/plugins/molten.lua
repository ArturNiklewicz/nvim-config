return {
  "benlubas/molten-nvim",
  lazy = false,  -- Load immediately, not on filetype
  dependencies = { 
    "3rd/image.nvim", 
    "stevearc/dressing.nvim",
  },
  build = ":UpdateRemotePlugins",
  init = function()
    -- Configure molten before loading
    vim.g.molten_image_provider = "image.nvim"
    vim.g.molten_output_win_max_height = 12
    vim.g.molten_auto_open_output = true
    vim.g.molten_wrap_output = true
    vim.g.molten_virt_text_output = true
    vim.g.molten_virt_lines_off_by_1 = true
  end,
  config = function()
    -- Additional molten settings
    vim.g.molten_output_show_more = true
    vim.g.molten_enter_output_behavior = "open_and_enter"
    vim.g.molten_use_border_highlights = true
    
    -- Molten keybindings
    local keymap = vim.keymap.set
    
    -- Core molten operations
    keymap("n", "<Leader>mi", "<cmd>MoltenInit<cr>", { desc = "Initialize molten" })
    keymap("n", "<Leader>me", "<cmd>MoltenEvaluateOperator<cr>", { desc = "Evaluate operator" })
    keymap("n", "<Leader>ml", "<cmd>MoltenEvaluateLine<cr>", { desc = "Evaluate line" })
    keymap("n", "<Leader>mr", "<cmd>MoltenReevaluateCell<cr>", { desc = "Re-evaluate cell" })
    keymap("v", "<Leader>mv", ":<C-u>MoltenEvaluateVisual<cr>gv", { desc = "Evaluate visual selection" })
    
    -- Output management
    keymap("n", "<Leader>mo", "<cmd>MoltenShowOutput<cr>", { desc = "Show output" })
    keymap("n", "<Leader>mh", "<cmd>MoltenHideOutput<cr>", { desc = "Hide output" })
    keymap("n", "<Leader>md", "<cmd>MoltenDelete<cr>", { desc = "Delete cell" })
    
    -- Navigation (changed to ]j/[j to avoid conflict with git hunks)
    keymap("n", "]j", "<cmd>MoltenNext<cr>", { desc = "Next Jupyter cell" })
    keymap("n", "[j", "<cmd>MoltenPrev<cr>", { desc = "Previous Jupyter cell" })
    
    -- Kernel management
    keymap("n", "<Leader>mk", "<cmd>MoltenKernelStatusToggle<cr>", { desc = "Toggle kernel status" })
    keymap("n", "<Leader>ms", "<cmd>MoltenStart<cr>", { desc = "Start kernel" })
    keymap("n", "<Leader>mS", "<cmd>MoltenStop<cr>", { desc = "Stop kernel" })
    keymap("n", "<Leader>mR", "<cmd>MoltenRestart<cr>", { desc = "Restart kernel" })
    
    -- Import/export
    keymap("n", "<Leader>mI", "<cmd>MoltenImportOutput<cr>", { desc = "Import output" })
    keymap("n", "<Leader>mE", "<cmd>MoltenExportOutput<cr>", { desc = "Export output" })
    
    -- Auto-commands for better workflow
    vim.api.nvim_create_autocmd("User", {
      pattern = "MoltenInitPost",
      callback = function()
        vim.notify("Molten initialized successfully", vim.log.levels.INFO)
      end,
    })
    
    vim.api.nvim_create_autocmd("User", {
      pattern = "MoltenKernelReady",
      callback = function()
        vim.notify("Kernel is ready", vim.log.levels.INFO)
      end,
    })
  end,
}


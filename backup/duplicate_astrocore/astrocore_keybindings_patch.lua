-- This is a patch file to test the new keybinding structure
-- It extends the existing AstroCore configuration with the new mappings

return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    -- Ensure mappings table exists
    opts.mappings = opts.mappings or {}
    opts.mappings.n = opts.mappings.n or {}
    
    -- Add new frequent operations
    opts.mappings.n["<Leader>w"] = { "<cmd>w<cr>", desc = "Save file (write)" }
    opts.mappings.n["<Leader>q"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer (quit)" }
    opts.mappings.n["<Leader>e"] = { "<cmd>Neotree toggle<cr>", desc = "File explorer" }
    opts.mappings.n["<Leader>/"] = { function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Search in file" }
    opts.mappings.n["<Leader><Tab>"] = { "<cmd>b#<cr>", desc = "Last buffer toggle" }
    
    -- Buffer operations
    opts.mappings.n["<Leader>bb"] = { function() require("telescope.builtin").buffers() end, desc = "Buffer menu" }
    opts.mappings.n["<Leader>bn"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" }
    opts.mappings.n["<Leader>bp"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" }
    opts.mappings.n["<Leader>bd"] = { function() require("astrocore.buffer").close() end, desc = "Delete buffer" }
    opts.mappings.n["<Leader>ba"] = { function() require("telescope.builtin").buffers() end, desc = "All buffers" }
    
    -- Buffer quick switching (keep existing <Leader>1-9 for now)
    for i = 1, 9 do
      opts.mappings.n["<Leader>b" .. i] = {
        function()
          local buffers = vim.fn.getbufinfo({buflisted = 1})
          if buffers[i] and vim.api.nvim_buf_is_valid(buffers[i].bufnr) then
            vim.cmd("buffer " .. buffers[i].bufnr)
          end
        end,
        desc = "Jump to buffer " .. i
      }
    end
    
    -- Window operations
    opts.mappings.n["<Leader>Bs"] = { "<cmd>split<cr>", desc = "Split horizontal" }
    opts.mappings.n["<Leader>Bv"] = { "<cmd>vsplit<cr>", desc = "Split vertical" }
    opts.mappings.n["<Leader>Bm"] = { "<C-w>o", desc = "Maximize window" }
    
    -- Search operations (keep existing <Leader>s mappings and add new ones)
    opts.mappings.n["<Leader>sf"] = { function() require("telescope.builtin").find_files() end, desc = "Find files" }
    opts.mappings.n["<Leader>sg"] = { function() require("telescope.builtin").live_grep() end, desc = "Search grep" }
    opts.mappings.n["<Leader>sb"] = { function() require("telescope.builtin").buffers() end, desc = "Search buffers" }
    opts.mappings.n["<Leader>sh"] = { function() require("telescope.builtin").oldfiles() end, desc = "Search history" }
    
    -- Code/LSP operations
    opts.mappings.n["<Leader>ca"] = { function() vim.lsp.buf.code_action() end, desc = "Code actions" }
    opts.mappings.n["<Leader>cd"] = { function() vim.lsp.buf.definition() end, desc = "Go to definition" }
    opts.mappings.n["<Leader>cr"] = { function() vim.lsp.buf.rename() end, desc = "Rename" }
    opts.mappings.n["<Leader>cf"] = { function() vim.lsp.buf.format() end, desc = "Format" }
    opts.mappings.n["<Leader>cs"] = { function() require("telescope.builtin").lsp_document_symbols() end, desc = "Symbols" }
    opts.mappings.n["<Leader>ch"] = { function() vim.lsp.buf.hover() end, desc = "Hover info" }
    
    -- Git operations (enhance existing)
    opts.mappings.n["<Leader>gb"] = { function() require("gitsigns").blame_line() end, desc = "Blame current line" }
    opts.mappings.n["<Leader>gl"] = { "<cmd>Git log<cr>", desc = "Git log" }
    
    -- Git hunks
    opts.mappings.n["<Leader>ghn"] = { function() require("gitsigns").next_hunk() end, desc = "Next hunk" }
    opts.mappings.n["<Leader>ghp"] = { function() require("gitsigns").prev_hunk() end, desc = "Previous hunk" }
    opts.mappings.n["<Leader>ghs"] = { function() require("gitsigns").stage_hunk() end, desc = "Stage hunk" }
    opts.mappings.n["<Leader>ghr"] = { function() require("gitsigns").reset_hunk() end, desc = "Reset hunk" }
    opts.mappings.n["<Leader>ghd"] = { function() require("gitsigns").diffthis() end, desc = "Diff hunk" }
    
    -- Testing operations
    opts.mappings.n["<Leader>tr"] = {
      function()
        local file = vim.fn.expand("%:p")
        if file:match("_spec%.lua$") then
          vim.notify("Running tests in " .. vim.fn.expand("%:t"))
          vim.cmd("PlenaryBustedFile " .. file)
        else
          vim.notify("Not a test file (*_spec.lua)")
        end
      end,
      desc = "Run test"
    }
    
    -- Toggles
    opts.mappings.n["<Leader>Tz"] = { function() require("zen-mode").toggle() end, desc = "Toggle zen mode" }
    opts.mappings.n["<Leader>Tg"] = { function() require("gitsigns").toggle_signs() end, desc = "Toggle git signs" }
    opts.mappings.n["<Leader>Tb"] = { function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle blame line" }
    opts.mappings.n["<Leader>Tw"] = { "<cmd>set wrap!<cr>", desc = "Toggle word wrap" }
    opts.mappings.n["<Leader>Ts"] = { "<cmd>set spell!<cr>", desc = "Toggle spell check" }
    
    -- Debug/Errors
    opts.mappings.n["<Leader>de"] = { "<cmd>Errors<cr>", desc = "Show errors" }
    opts.mappings.n["<Leader>dm"] = { "<cmd>Messages<cr>", desc = "Show messages" }
    opts.mappings.n["<Leader>dc"] = { "<cmd>messages clear<cr>", desc = "Clear messages" }
    
    -- Direct mappings
    opts.mappings.n["]d"] = { function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" }
    opts.mappings.n["[d"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" }
    opts.mappings.n["]h"] = { function() require("gitsigns").next_hunk() end, desc = "Next git hunk" }
    opts.mappings.n["[h"] = { function() require("gitsigns").prev_hunk() end, desc = "Previous git hunk" }
    opts.mappings.n["<C-s>"] = { "<cmd>w<cr>", desc = "Save" }
    
    -- Remove conflicting mappings
    opts.mappings.n["<Leader>s"] = nil -- Was save, now save is <Leader>w
    opts.mappings.n["<Leader>a"] = nil -- Was previous buffer, now AI prefix
    opts.mappings.n["<Leader>d"] = nil -- Was next buffer, now debug prefix
    
    return opts
  end,
}
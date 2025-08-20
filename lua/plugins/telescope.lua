-- Telescope configuration with proper multi-select behavior
-- Fixes Enter key to open all selected files, not just the one under cursor
return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    
    -- Ensure defaults table exists
    opts.defaults = opts.defaults or {}
    opts.defaults.mappings = opts.defaults.mappings or {}
    opts.defaults.mappings.i = opts.defaults.mappings.i or {}
    opts.defaults.mappings.n = opts.defaults.mappings.n or {}
    
    -- Custom action to open multiple selected files
    local function multi_select_open(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)
      local multi_selections = picker:get_multi_selection()
      
      if vim.tbl_isempty(multi_selections) then
        -- No selections, open file under cursor
        actions.select_default(prompt_bufnr)
      else
        -- Close telescope
        actions.close(prompt_bufnr)
        -- Open all selected files
        for _, entry in ipairs(multi_selections) do
          if entry.path or entry.filename then
            local filename = entry.path or entry.filename
            vim.cmd("edit " .. vim.fn.fnameescape(filename))
          end
        end
      end
    end
    
    -- Fix Enter to open all selected files
    opts.defaults.mappings.i["<CR>"] = multi_select_open
    opts.defaults.mappings.n["<CR>"] = multi_select_open
    
    -- Keep Tab for selection (these were already working)
    opts.defaults.mappings.i["<Tab>"] = actions.toggle_selection + actions.move_selection_worse
    opts.defaults.mappings.i["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better
    opts.defaults.mappings.i["<C-q>"] = actions.send_to_qflist + actions.open_qflist
    opts.defaults.mappings.i["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist
    
    -- Normal mode mappings
    opts.defaults.mappings.n["<Tab>"] = actions.toggle_selection + actions.move_selection_worse
    opts.defaults.mappings.n["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better
    opts.defaults.mappings.n["<C-q>"] = actions.send_to_qflist + actions.open_qflist
    opts.defaults.mappings.n["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist
    
    return opts
  end,
}
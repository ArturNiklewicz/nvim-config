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
    
    -- Custom action to diff two selected files
    local function diff_selected_files(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)
      local multi_selections = picker:get_multi_selection()
      
      if #multi_selections ~= 2 then
        vim.notify("Select exactly 2 files to diff (use Tab to select)", vim.log.levels.WARN)
        return
      end
      
      actions.close(prompt_bufnr)
      
      local file1 = multi_selections[1].path or multi_selections[1].filename or multi_selections[1][1]
      local file2 = multi_selections[2].path or multi_selections[2].filename or multi_selections[2][1]
      
      -- Create unified diff view
      local diff_cmd = string.format("diff -u %s %s", vim.fn.shellescape(file1), vim.fn.shellescape(file2))
      local diff_output = vim.fn.system(diff_cmd)
      
      if vim.v.shell_error == 0 then
        vim.notify("Files are identical", vim.log.levels.INFO)
        return
      elseif vim.v.shell_error == 2 then
        vim.notify("Error comparing files", vim.log.levels.ERROR)
        return
      end
      
      -- Split diff output into lines
      local lines = vim.split(diff_output, "\n")
      
      -- Create new buffer with diff output
      vim.cmd("tabnew")
      local buf = vim.api.nvim_get_current_buf()
      
      -- Set buffer options
      vim.bo[buf].buftype = "nofile"
      vim.bo[buf].bufhidden = "wipe"
      vim.bo[buf].swapfile = false
      vim.bo[buf].filetype = "diff"
      
      -- Set up GitHub-style highlighting with relative line numbers
      vim.api.nvim_win_set_option(0, 'cursorline', false)
      vim.api.nvim_win_set_option(0, 'number', true)
      vim.api.nvim_win_set_option(0, 'relativenumber', true)
      
      -- Use theme-consistent diff highlights (matches GitSigns/Neogit)
      vim.cmd([[
        highlight! link DiffAddBg DiffAdd
        highlight! link DiffDeleteBg DiffDelete
        highlight! link DiffContextLine Comment
      ]])
      
      -- Set buffer name
      vim.api.nvim_buf_set_name(buf, string.format("Diff: %s ↔ %s", vim.fn.fnamemodify(file1, ":t"), vim.fn.fnamemodify(file2, ":t")))
      
      -- Add diff content
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      
      -- Apply highlights to the buffer
      local ns_id = vim.api.nvim_create_namespace('diff_highlights')
      for i, line in ipairs(lines) do
        if line:match("^%+[^%+]") then
          -- Added line (but not +++ header)
          vim.api.nvim_buf_add_highlight(buf, ns_id, "DiffAddBg", i-1, 0, -1)
        elseif line:match("^%-[^%-]") then
          -- Deleted line (but not --- header)
          vim.api.nvim_buf_add_highlight(buf, ns_id, "DiffDeleteBg", i-1, 0, -1)
        elseif line:match("^@@") then
          -- Hunk header
          vim.api.nvim_buf_add_highlight(buf, ns_id, "DiffContextLine", i-1, 0, -1)
        end
      end
      
      -- Make buffer read-only
      vim.bo[buf].modifiable = false
      vim.bo[buf].readonly = true
      
      -- Add keybinding to close
      vim.keymap.set("n", "q", ":tabclose<CR>", { buffer = buf, silent = true, desc = "Close diff" })
    end
    
    -- Fix Enter to open all selected files
    opts.defaults.mappings.i["<CR>"] = multi_select_open
    opts.defaults.mappings.n["<CR>"] = multi_select_open
    
    -- Keep Tab for selection (these were already working)
    opts.defaults.mappings.i["<Tab>"] = actions.toggle_selection + actions.move_selection_worse
    opts.defaults.mappings.i["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better
    opts.defaults.mappings.i["<C-q>"] = actions.send_to_qflist + actions.open_qflist
    opts.defaults.mappings.i["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist
    
    -- Add Ctrl+D for diff action
    opts.defaults.mappings.i["<C-d>"] = diff_selected_files
    opts.defaults.mappings.n["<C-d>"] = diff_selected_files

    -- Add to Harpoon from Telescope (Ctrl+H)
    local function add_to_harpoon(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      if entry and (entry.path or entry.filename) then
        local filepath = entry.path or entry.filename
        -- Add file to harpoon without closing telescope
        local harpoon = require("harpoon")
        local item = { value = filepath, context = { row = 1, col = 0 } }
        harpoon:list():add(item)
        vim.notify("Added to Harpoon: " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.INFO)
      end
    end

    -- Add to Grapple from Telescope (Ctrl+G)
    local function add_to_grapple(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      if entry and (entry.path or entry.filename) then
        local filepath = entry.path or entry.filename
        -- Add file to grapple without closing telescope
        require("grapple").tag({ path = filepath })
        vim.notify("Tagged with Grapple: " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.INFO)
      end
    end

    -- Harpoon and Grapple mappings
    opts.defaults.mappings.i["<C-h>"] = add_to_harpoon
    opts.defaults.mappings.n["<C-h>"] = add_to_harpoon
    opts.defaults.mappings.i["<C-g>"] = add_to_grapple
    opts.defaults.mappings.n["<C-g>"] = add_to_grapple
    
    -- Normal mode mappings
    opts.defaults.mappings.n["<Tab>"] = actions.toggle_selection + actions.move_selection_worse
    opts.defaults.mappings.n["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better
    opts.defaults.mappings.n["<C-q>"] = actions.send_to_qflist + actions.open_qflist
    opts.defaults.mappings.n["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist
    
    return opts
  end,
}
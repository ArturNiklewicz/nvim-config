-- Debug Neo-tree loading issues
-- Temporary debug file to check Neo-tree status

return {
  "debug-neotree",
  name = "debug-neotree",
  dir = vim.fn.stdpath("config"),
  lazy = false,
  priority = 9999,
  config = function()
    vim.api.nvim_create_user_command("CheckNeotree", function()
      -- Check if Neo-tree is loaded
      local ok, neotree = pcall(require, "neo-tree")
      if ok then
        print("✅ Neo-tree is loaded successfully")
        
        -- Check if commands are available
        if vim.fn.exists(":Neotree") == 2 then
          print("✅ Neotree command is available")
        else
          print("❌ Neotree command is NOT available")
        end
        
        -- Check keybindings
        local keymaps = vim.api.nvim_get_keymap("n")
        local found_e = false
        local found_question = false
        
        for _, keymap in ipairs(keymaps) do
          if keymap.lhs == " e" or keymap.lhs == "<Space>e" then
            found_e = true
            print("✅ Found <Leader>e mapping: " .. (keymap.desc or keymap.rhs or ""))
          end
          if keymap.lhs == " ?" or keymap.lhs == "<Space>?" then
            found_question = true
            print("✅ Found <Leader>? mapping: " .. (keymap.desc or keymap.rhs or ""))
          end
        end
        
        if not found_e then
          print("❌ <Leader>e mapping NOT found")
        end
        if not found_question then
          print("❌ <Leader>? mapping NOT found")
        end
        
        -- List all leader mappings
        print("\n📋 All <Leader> mappings:")
        for _, keymap in ipairs(keymaps) do
          if keymap.lhs:match("^<Space>") or keymap.lhs:match("^ ") then
            local key = keymap.lhs:gsub("<Space>", "<Leader>"):gsub("^ ", "<Leader>")
            print("  " .. key .. " → " .. (keymap.desc or keymap.rhs or ""))
          end
        end
      else
        print("❌ Neo-tree is NOT loaded. Error: " .. tostring(neotree))
        
        -- Check if the plugin file exists
        local plugin_file = vim.fn.stdpath("config") .. "/lua/plugins/neo-tree.lua"
        if vim.fn.filereadable(plugin_file) == 1 then
          print("✅ neo-tree.lua file exists")
        else
          print("❌ neo-tree.lua file NOT found")
        end
        
        -- Check lazy.nvim status
        local lazy_ok, lazy = pcall(require, "lazy")
        if lazy_ok then
          print("✅ lazy.nvim is loaded")
          
          -- Check if Neo-tree is in the plugin list
          local plugins = require("lazy").plugins()
          local found_neotree = false
          for name, _ in pairs(plugins) do
            if name:match("neo%-tree") then
              found_neotree = true
              print("✅ Neo-tree found in lazy.nvim plugins: " .. name)
              break
            end
          end
          if not found_neotree then
            print("❌ Neo-tree NOT found in lazy.nvim plugins")
          end
        else
          print("❌ lazy.nvim is NOT loaded")
        end
      end
    end, { desc = "Check Neo-tree loading status" })
    
    print("Debug commands loaded. Run :CheckNeotree to diagnose issues")
  end,
}
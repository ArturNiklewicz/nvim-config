-- Keybinding Help Plugin
-- Provides commands to display all custom keybindings

return {
  "keybind-help",
  name = "keybind-help", 
  dir = vim.fn.stdpath("config"),
  lazy = false,
  priority = 1000,
  config = function()
    -- Function to display keybindings
    local function show_keybindings()
      -- Execute the external script for consistency
      local script_path = vim.fn.stdpath("config") .. "/nvim-keys"
      if vim.fn.executable(script_path) == 1 then
        vim.fn.system(script_path)
      else
        print("Keybindings script not found at: " .. script_path)
        print("Please ensure nvim-keys script exists and is executable")
      end
    end
    
    -- Create commands for use within nvim
    vim.api.nvim_create_user_command("Keybindings", show_keybindings, {
      desc = "Show all custom keybindings"
    })
    
    vim.api.nvim_create_user_command("KeybindHelp", show_keybindings, {
      desc = "Display comprehensive keybinding help"
    })
    
    -- Also create a short alias
    vim.api.nvim_create_user_command("Keys", show_keybindings, {
      desc = "Show all custom keybindings (short alias)"
    })
    
    -- Keybinding removed - now registered in which-key.lua to avoid conflict
  end,
}
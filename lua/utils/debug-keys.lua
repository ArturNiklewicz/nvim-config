-- Debug script to check keybinding registration
local M = {}

function M.check_leader_keys()
  print("\n=== Checking <Leader> Number Key Bindings ===")

  for i = 1, 9 do
    local key = "<Leader>" .. i
    local maps = vim.api.nvim_get_keymap('n')
    local found = false

    for _, map in ipairs(maps) do
      if map.lhs == " " .. i or map.lhs == key then
        print(string.format("%s: FOUND - %s", key, map.rhs or "function"))
        found = true
        break
      end
    end

    if not found then
      print(string.format("%s: NOT FOUND", key))
    end
  end

  print("\n=== Checking buffer_nav module ===")
  local ok, buffer_nav = pcall(require, "utils.buffer-nav")
  if ok then
    print("✓ buffer-nav loaded successfully")
    print("✓ nav_to function exists:", type(buffer_nav.nav_to) == "function")
  else
    print("✗ Failed to load buffer-nav:", buffer_nav)
  end

  print("\n=== Checking BufferLineGoToBuffer command ===")
  local cmd_exists = vim.fn.exists(":BufferLineGoToBuffer") == 2
  print("Command exists:", cmd_exists)
  if not cmd_exists then
    print("⚠ BufferLineGoToBuffer command not found - bufferline may not be initialized")
  end
end

return M

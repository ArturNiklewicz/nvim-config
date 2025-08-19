-- Analyze all keybindings and compare with which-key definitions
local M = {}

-- Extract keybindings from a lua file
function M.extract_keybindings(filepath)
  local keybindings = {}
  local file = io.open(filepath, "r")
  if not file then return keybindings end
  
  local content = file:read("*all")
  file:close()
  
  -- Pattern 1: ["<key>"] = { ... }
  for key in content:gmatch('%["([^"]+)"%]%s*=%s*{') do
    if key:match("^<") then -- Only capture actual key mappings
      table.insert(keybindings, key)
    end
  end
  
  -- Pattern 2: vim.keymap.set("mode", "key", ...)
  for mode, key in content:gmatch('vim%.keymap%.set%s*%(%s*"([^"]+)"%s*,%s*"([^"]+)"') do
    table.insert(keybindings, key .. " (" .. mode .. ")")
  end
  
  return keybindings
end

-- Get all lua files
function M.get_lua_files(dir)
  local files = {}
  local handle = io.popen('find "' .. dir .. '" -name "*.lua" -type f')
  if handle then
    for file in handle:lines() do
      table.insert(files, file)
    end
    handle:close()
  end
  return files
end

-- Main analysis
function M.analyze()
  local config_dir = vim.fn.stdpath("config") .. "/lua/plugins"
  local all_keybindings = {}
  local file_keybindings = {}
  
  -- Get all lua files
  local files = M.get_lua_files(config_dir)
  
  -- Extract keybindings from each file
  for _, file in ipairs(files) do
    local filename = file:match("([^/]+)$")
    local bindings = M.extract_keybindings(file)
    if #bindings > 0 then
      file_keybindings[filename] = bindings
      for _, binding in ipairs(bindings) do
        if not all_keybindings[binding] then
          all_keybindings[binding] = {}
        end
        table.insert(all_keybindings[binding], filename)
      end
    end
  end
  
  -- Find duplicates
  print("=== DUPLICATE KEYBINDINGS ===")
  local has_duplicates = false
  for binding, files in pairs(all_keybindings) do
    if #files > 1 then
      has_duplicates = true
      print("\n" .. binding .. " found in:")
      for _, file in ipairs(files) do
        print("  - " .. file)
      end
    end
  end
  
  if not has_duplicates then
    print("No duplicate keybindings found!")
  end
  
  -- Count keybindings per file
  print("\n\n=== KEYBINDING COUNT PER FILE ===")
  for file, bindings in pairs(file_keybindings) do
    print(string.format("%-30s: %d keybindings", file, #bindings))
  end
  
  -- Check which-key coverage
  print("\n\n=== CHECKING WHICH-KEY COVERAGE ===")
  local which_key_file = config_dir .. "/which-key.lua"
  local wk_content = ""
  local f = io.open(which_key_file, "r")
  if f then
    wk_content = f:read("*all")
    f:close()
  end
  
  -- Extract leader keybindings from astrocore.lua
  local astrocore_bindings = {}
  for _, binding in ipairs(file_keybindings["astrocore.lua"] or {}) do
    if binding:match("^<Leader>") then
      local key = binding:match("<Leader>(.+)")
      if key then
        astrocore_bindings[key] = true
      end
    end
  end
  
  -- Check if they're in which-key
  local missing_in_whichkey = {}
  for key, _ in pairs(astrocore_bindings) do
    -- Simple check - look for the key pattern in which-key content
    local patterns = {
      '["%[%]' .. key:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") .. '"%]',
      '["' .. key:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") .. '"]',
      key:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") .. ' = "',
    }
    
    local found = false
    for _, pattern in ipairs(patterns) do
      if wk_content:find(pattern) then
        found = true
        break
      end
    end
    
    if not found and not key:match("^%d$") then -- Skip number keys as they're handled specially
      table.insert(missing_in_whichkey, "<Leader>" .. key)
    end
  end
  
  if #missing_in_whichkey > 0 then
    print("\nKeybindings possibly missing from which-key:")
    for _, binding in ipairs(missing_in_whichkey) do
      print("  - " .. binding)
    end
  else
    print("\nAll leader keybindings appear to be in which-key!")
  end
end

-- Run the analysis
M.analyze()

return M
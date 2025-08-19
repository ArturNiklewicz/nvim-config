#!/usr/bin/env lua

-- Comprehensive keybinding extractor for AstroNvim config
-- Table to store all keybindings found
local all_keybindings = {}
local duplicates = {}

-- Helper function to add a keybinding
local function add_keybinding(file, line_num, mode, key, action, desc)
  local binding = {
    file = file,
    line = line_num,
    mode = mode or "n",
    key = key,
    action = action,
    desc = desc or "No description"
  }
  
  -- Create unique key for checking duplicates
  local unique_key = (mode or "n") .. ":" .. key
  
  if not all_keybindings[unique_key] then
    all_keybindings[unique_key] = {}
  end
  
  table.insert(all_keybindings[unique_key], binding)
  
  -- Mark as duplicate if more than one binding
  if #all_keybindings[unique_key] > 1 then
    duplicates[unique_key] = true
  end
end

-- Function to parse a file for keybindings
local function parse_file(filepath)
  local file = io.open(filepath, "r")
  if not file then return end
  
  local content = file:read("*all")
  file:close()
  
  local line_num = 0
  
  -- Track lines for line number counting
  for line in content:gmatch("[^\n]*") do
    line_num = line_num + 1
    
    -- Pattern 1: ["<key>"] = { action, desc = "..." }
    local key, rest = line:match('%[%s*["\']([^"\']+)["\']%s*%]%s*=%s*{(.*)$')
    if key and rest then
      local desc = rest:match('desc%s*=%s*["\']([^"\']+)["\']')
      local action = rest:match('^%s*([^,]+)')
      add_keybinding(filepath, line_num, nil, key, action or rest, desc)
    end
    
    -- Pattern 2: vim.keymap.set("mode", "key", action, { desc = "..." })
    local mode, key2, rest2 = line:match('vim%.keymap%.set%s*%(%s*["\']([^"\']+)["\']%s*,%s*["\']([^"\']+)["\']%s*,(.*)$')
    if mode and key2 then
      local desc = rest2:match('desc%s*=%s*["\']([^"\']+)["\']')
      add_keybinding(filepath, line_num, mode, key2, rest2, desc)
    end
    
    -- Pattern 3: keymap("mode", "key", action, opts)
    local mode3, key3, rest3 = line:match('keymap%s*%(%s*["\']([^"\']+)["\']%s*,%s*["\']([^"\']+)["\']%s*,(.*)$')
    if mode3 and key3 then
      local desc = rest3:match('desc%s*=%s*["\']([^"\']+)["\']')
      add_keybinding(filepath, line_num, mode3, key3, rest3, desc)
    end
  end
  
  -- Also parse for mappings tables with nested structure
  for mode, mode_content in content:gmatch('mappings%s*=%s*{.-(%w)%s*=%s*({.-\n%s*})') do
    for key, action_block in mode_content:gmatch('%[%s*["\']([^"\']+)["\']%s*%]%s*=%s*{([^}]+)}') do
      local desc = action_block:match('desc%s*=%s*["\']([^"\']+)["\']')
      local action = action_block:match('^%s*([^,]+)')
      -- Find approximate line number
      local _, _, substr = content:find(key)
      local line_before = 1
      if substr then
        for _ in content:sub(1, substr):gmatch("\n") do
          line_before = line_before + 1
        end
      end
      add_keybinding(filepath, line_before, mode, key, action or action_block, desc)
    end
  end
end

-- Get list of lua files from command
local handle = io.popen('find . -name "*.lua" -type f 2>/dev/null')
local lua_files = {}
if handle then
  for file in handle:lines() do
    table.insert(lua_files, file)
  end
  handle:close()
end

-- Parse all lua files
for _, file in ipairs(lua_files) do
  parse_file(file)
end

-- Sort keys for consistent output
local sorted_keys = {}
for key in pairs(all_keybindings) do
  table.insert(sorted_keys, key)
end
table.sort(sorted_keys)

-- Output duplicates first
print("=== DUPLICATE KEYBINDINGS ===\n")
local dup_count = 0
for _, key in ipairs(sorted_keys) do
  if duplicates[key] then
    local bindings = all_keybindings[key]
    local mode, keymap = key:match("^(.+):(.+)$")
    
    print(string.format("[%s] %s - DEFINED %d TIMES:", mode, keymap, #bindings))
    for i, b in ipairs(bindings) do
      print(string.format("  %d. %s:%d", i, b.file, b.line))
      print(string.format("     Desc: %s", b.desc))
    end
    print()
    dup_count = dup_count + 1
  end
end

-- Summary
print("\n=== SUMMARY ===")
print(string.format("Total unique keybindings: %d", #sorted_keys))
local total_defs = 0
for _, bindings in pairs(all_keybindings) do
  total_defs = total_defs + #bindings
end
print(string.format("Total keybinding definitions: %d", total_defs))
print(string.format("Duplicate keybindings: %d", dup_count))

-- Output all unique bindings
print("\n\n=== ALL UNIQUE KEYBINDINGS ===\n")
for _, key in ipairs(sorted_keys) do
  local bindings = all_keybindings[key]
  if #bindings == 1 then
    local b = bindings[1]
    local mode, keymap = key:match("^(.+):(.+)$")
    print(string.format("[%s] %s - %s", mode, keymap, b.desc))
    print(string.format("  File: %s:%d", b.file, b.line))
  end
end
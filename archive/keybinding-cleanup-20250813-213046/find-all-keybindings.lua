#!/usr/bin/env lua

-- Comprehensive keybinding extractor for AstroNvim config
local lfs = require("lfs")

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

-- Function to recursively find lua files
local function find_lua_files(dir)
  local files = {}
  
  local function scan_dir(path)
    for file in lfs.dir(path) do
      if file ~= "." and file ~= ".." then
        local full_path = path .. "/" .. file
        local attr = lfs.attributes(full_path)
        
        if attr then
          if attr.mode == "directory" and not file:match("^%.") then
            scan_dir(full_path)
          elseif attr.mode == "file" and file:match("%.lua$") then
            table.insert(files, full_path)
          end
        end
      end
    end
  end
  
  scan_dir(dir)
  return files
end

-- Main execution
local nvim_config_dir = os.getenv("HOME") .. "/.config/nvim"
local lua_files = find_lua_files(nvim_config_dir)

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

-- Output results
print("=== ALL KEYBINDINGS FOUND ===\n")
local total_bindings = 0
for _, key in ipairs(sorted_keys) do
  local bindings = all_keybindings[key]
  local mode, keymap = key:match("^(.+):(.+)$")
  
  if #bindings == 1 then
    local b = bindings[1]
    print(string.format("[%s] %s", mode, keymap))
    print(string.format("  File: %s:%d", b.file:gsub(nvim_config_dir .. "/", ""), b.line))
    print(string.format("  Desc: %s", b.desc))
    print()
    total_bindings = total_bindings + 1
  end
end

-- Output duplicates
print("\n=== DUPLICATE KEYBINDINGS ===\n")
local dup_count = 0
for _, key in ipairs(sorted_keys) do
  if duplicates[key] then
    local bindings = all_keybindings[key]
    local mode, keymap = key:match("^(.+):(.+)$")
    
    print(string.format("[%s] %s - DEFINED %d TIMES:", mode, keymap, #bindings))
    for i, b in ipairs(bindings) do
      print(string.format("  %d. %s:%d", i, b.file:gsub(nvim_config_dir .. "/", ""), b.line))
      print(string.format("     Desc: %s", b.desc))
    end
    print()
    dup_count = dup_count + 1
  end
end

-- Summary
print("\n=== SUMMARY ===")
print(string.format("Total unique keybindings: %d", #sorted_keys))
print(string.format("Total keybinding definitions: %d", total_bindings + dup_count))
print(string.format("Duplicate keybindings: %d", dup_count))
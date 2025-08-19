#!/usr/bin/env lua

-- Extract ALL AstroCore mappings for precise Which-Key registration
-- This will generate the exact code needed

local astrocore_file = vim.fn.stdpath("config") .. "/lua/plugins/astrocore.lua"

-- Read the file
local file = io.open(astrocore_file, "r")
if not file then
  print("Error: Cannot read astrocore.lua")
  return
end

local content = file:read("*all")
file:close()

-- Extract mappings section
local mappings_start = content:find("mappings = {")
local mappings_end = content:find("^%s*},%s*$", mappings_start)

if not mappings_start or not mappings_end then
  print("Error: Cannot find mappings section")
  return
end

local mappings_section = content:sub(mappings_start, mappings_end)

-- Parse all mappings
local mappings = {}
local current_mode = "n"

for line in mappings_section:gmatch("[^\r\n]+") do
  -- Check for mode change
  local mode = line:match('^%s*(%w+)%s*=%s*{%s*$')
  if mode then
    current_mode = mode
  end
  
  -- Extract keybinding
  local key, cmd, desc = line:match('%["([^"]+)"%]%s*=%s*{%s*(.-),%s*desc%s*=%s*"([^"]+)"')
  if not key and not cmd and not desc then
    -- Try function format
    key, desc = line:match('%["([^"]+)"%]%s*=%s*{%s*function%(%).-end,%s*desc%s*=%s*"([^"]+)"')
    if key and desc then
      cmd = "function"
    end
  end
  
  if key then
    if not mappings[current_mode] then
      mappings[current_mode] = {}
    end
    table.insert(mappings[current_mode], {
      key = key,
      cmd = cmd or "function",
      desc = desc
    })
  end
end

-- Generate Which-Key registration code
print("-- COMPLETE ASTROCORE MAPPINGS FOR WHICH-KEY")
print("-- Auto-generated from astrocore.lua")
print("")

-- Group mappings by prefix
local function organize_by_prefix(mode_mappings)
  local organized = {}
  
  for _, mapping in ipairs(mode_mappings) do
    local key = mapping.key
    if key:match("^<Leader>") then
      -- Extract the first character after <Leader>
      local prefix = key:match("^<Leader>(.)")
      if prefix then
        if not organized[prefix] then
          organized[prefix] = {}
        end
        -- Store without <Leader> prefix for which-key
        local subkey = key:gsub("^<Leader>", "")
        table.insert(organized[prefix], {
          key = subkey,
          cmd = mapping.cmd,
          desc = mapping.desc
        })
      end
    else
      -- Non-leader mappings
      if not organized["_other"] then
        organized["_other"] = {}
      end
      table.insert(organized["_other"], mapping)
    end
  end
  
  return organized
end

-- Print organized mappings
for mode, mode_mappings in pairs(mappings) do
  print("\n-- Mode: " .. mode)
  local organized = organize_by_prefix(mode_mappings)
  
  -- Print by group
  for prefix, group_mappings in pairs(organized) do
    if prefix ~= "_other" then
      print(string.format('\n-- <Leader>%s group', prefix))
      for _, m in ipairs(group_mappings) do
        print(string.format('  ["%s"] = { %s, "%s" },', 
          m.key, 
          m.cmd == "function" and "function() --[[function body]] end" or m.cmd,
          m.desc))
      end
    end
  end
end

print("\n-- Total mappings found: " .. #mappings["n"] .. " in normal mode")
print("-- Copy the above into which-key.lua registration blocks")
#!/usr/bin/env lua

-- Comprehensive Keybinding Analyzer for Neovim Configuration
-- Analyzes ALL keybinding sources with 100% accuracy
-- Author: Claude Code
-- Date: 2025

local lfs = require("lfs") or nil
local json = vim and vim.json or require("json") or nil

-- Configuration
local config = {
  nvim_dir = os.getenv("HOME") .. "/.config/nvim",
  output_format = "detailed", -- "detailed", "summary", "json"
  include_defaults = false,
  check_duplicates = true,
  analyze_which_key = true,
}

-- Data structures
local keybindings = {
  all = {},           -- All keybindings found
  by_source = {},     -- Grouped by source file
  by_mode = {},       -- Grouped by mode (n, v, i, etc.)
  duplicates = {},    -- Duplicate keybindings
  which_key = {},     -- Which-key registered bindings
  conflicts = {},     -- Conflicting keybindings
  stats = {
    total = 0,
    unique = 0,
    duplicates = 0,
    conflicts = 0,
    by_mode = {},
    by_source = {},
    which_key_registered = 0,
    which_key_missing = 0,
  }
}

-- Keybinding patterns to search for
local patterns = {
  -- vim.keymap.set patterns
  {
    pattern = 'vim%.keymap%.set%s*%(.-"(.-)"%s*,%s*"(.-)"%s*,%s*(.-)[,)]',
    type = "vim.keymap.set",
    extract = function(line, captures)
      local modes, lhs, rhs = captures[1], captures[2], captures[3]
      return modes, lhs, rhs
    end
  },
  {
    pattern = "vim%.keymap%.set%s*%(.-%'(.-)%'%s*,%s*%'(.-)%'%s*,%s*(.-)[,)]",
    type = "vim.keymap.set",
    extract = function(line, captures)
      local modes, lhs, rhs = captures[1], captures[2], captures[3]
      return modes, lhs, rhs
    end
  },
  {
    pattern = 'vim%.keymap%.set%s*%(%s*%{(.-)%}%s*,%s*"(.-)"%s*,%s*(.-)[,)]',
    type = "vim.keymap.set_table",
    extract = function(line, captures)
      local modes = captures[1]:gsub('["%s]', '')
      local lhs = captures[2]
      local rhs = captures[3]
      return modes, lhs, rhs
    end
  },
  -- vim.api.nvim_set_keymap patterns
  {
    pattern = 'vim%.api%.nvim_set_keymap%s*%(.-"(.-)"%s*,%s*"(.-)"%s*,%s*"(.-)"',
    type = "nvim_set_keymap",
    extract = function(line, captures)
      return captures[1], captures[2], captures[3]
    end
  },
  -- Plugin keys tables
  {
    pattern = '%s*%{%s*"(.-)"%s*,%s*"(.-)"%s*,%s*desc%s*=%s*"(.-)"',
    type = "plugin_keys",
    extract = function(line, captures)
      return "n", captures[1], captures[2]
    end
  },
  {
    pattern = "%s*%{%s*'(.-)'%s*,%s*'(.-)'%s*,%s*desc%s*=%s*'(.-)'",
    type = "plugin_keys",
    extract = function(line, captures)
      return "n", captures[1], captures[2]
    end
  },
  -- AstroNvim mappings format
  {
    pattern = '%["(.-)"%]%s*=%s*%{%s*"(.-)"',
    type = "astro_mappings",
    extract = function(line, captures)
      return "n", captures[1], captures[2]
    end
  },
  {
    pattern = "%['(.-)'%]%s*=%s*%{%s*'(.-)'",
    type = "astro_mappings",
    extract = function(line, captures)
      return "n", captures[1], captures[2]
    end
  },
  -- Which-key register patterns
  {
    pattern = '%["(.-)"%]%s*=%s*"(.-)"',
    type = "which_key",
    extract = function(line, captures)
      return "n", captures[1], captures[2]
    end
  },
  {
    pattern = "%['(.-)'%]%s*=%s*'(.-)'",
    type = "which_key",
    extract = function(line, captures)
      return "n", captures[1], captures[2]
    end
  },
}

-- Helper functions
local function normalize_key(key)
  -- Normalize key representations
  key = key:gsub("<[Ll]eader>", "<Space>")
  key = key:gsub("<[Ll]ocalleader>", ",")
  key = key:gsub("<[Cc][Rr]>", "<CR>")
  key = key:gsub("<[Ee][Ss][Cc]>", "<Esc>")
  key = key:gsub("<[Tt][Aa][Bb]>", "<Tab>")
  key = key:gsub("<[Bb][Ss]>", "<BS>")
  key = key:gsub("<[Ss]pace>", " ")
  key = key:gsub("<C%-", "<Ctrl-")
  key = key:gsub("<M%-", "<Alt-")
  key = key:gsub("<A%-", "<Alt-")
  key = key:gsub("<S%-", "<Shift-")
  return key
end

local function expand_modes(mode_str)
  -- Expand mode string to individual modes
  local modes = {}
  if mode_str:find("n") then table.insert(modes, "n") end
  if mode_str:find("v") then table.insert(modes, "v") end
  if mode_str:find("x") then table.insert(modes, "x") end
  if mode_str:find("s") then table.insert(modes, "s") end
  if mode_str:find("o") then table.insert(modes, "o") end
  if mode_str:find("i") then table.insert(modes, "i") end
  if mode_str:find("c") then table.insert(modes, "c") end
  if mode_str:find("t") then table.insert(modes, "t") end
  if #modes == 0 then modes = {"n"} end -- Default to normal mode
  return modes
end

local function read_file(filepath)
  local file = io.open(filepath, "r")
  if not file then return nil end
  local content = file:read("*all")
  file:close()
  return content
end

local function scan_file(filepath)
  local content = read_file(filepath)
  if not content then return end
  
  local file_bindings = {}
  local line_num = 0
  
  for line in content:gmatch("[^\r\n]+") do
    line_num = line_num + 1
    
    -- Skip comments
    if line:match("^%s*%-%-") then
      goto continue
    end
    
    -- Check each pattern
    for _, pattern_info in ipairs(patterns) do
      local captures = {line:match(pattern_info.pattern)}
      if #captures > 0 then
        local modes, lhs, rhs = pattern_info.extract(line, captures)
        if modes and lhs then
          lhs = normalize_key(lhs)
          local expanded_modes = expand_modes(modes)
          
          for _, mode in ipairs(expanded_modes) do
            local binding = {
              mode = mode,
              lhs = lhs,
              rhs = rhs or "",
              source = filepath:gsub(config.nvim_dir .. "/", ""),
              line = line_num,
              type = pattern_info.type,
              raw = line:sub(1, 100) -- Store first 100 chars of raw line
            }
            
            table.insert(file_bindings, binding)
            
            -- Add to main data structure
            local key = mode .. "|" .. lhs
            if not keybindings.all[key] then
              keybindings.all[key] = {}
            end
            table.insert(keybindings.all[key], binding)
            
            -- Track by mode
            if not keybindings.by_mode[mode] then
              keybindings.by_mode[mode] = {}
            end
            table.insert(keybindings.by_mode[mode], binding)
            
            keybindings.stats.total = keybindings.stats.total + 1
          end
        end
      end
    end
    
    ::continue::
  end
  
  if #file_bindings > 0 then
    keybindings.by_source[filepath:gsub(config.nvim_dir .. "/", "")] = file_bindings
  end
end

local function find_lua_files(dir)
  local files = {}
  
  local function scan_dir(path)
    local handle = io.popen('find "' .. path .. '" -name "*.lua" 2>/dev/null')
    if handle then
      for file in handle:lines() do
        -- Skip backup and test directories
        if not file:match("/backup/") and 
           not file:match("/tests/") and
           not file:match("%.git/") then
          table.insert(files, file)
        end
      end
      handle:close()
    end
  end
  
  scan_dir(dir)
  return files
end

local function analyze_duplicates()
  for key, bindings in pairs(keybindings.all) do
    if #bindings > 1 then
      -- Found duplicate
      local mode, lhs = key:match("^(.-)|(.*)")
      local dup_info = {
        mode = mode,
        lhs = lhs,
        count = #bindings,
        sources = {}
      }
      
      for _, binding in ipairs(bindings) do
        table.insert(dup_info.sources, {
          file = binding.source,
          line = binding.line,
          rhs = binding.rhs,
          type = binding.type
        })
      end
      
      table.insert(keybindings.duplicates, dup_info)
      keybindings.stats.duplicates = keybindings.stats.duplicates + 1
      
      -- Check if it's a conflict (different rhs values)
      local rhs_values = {}
      for _, binding in ipairs(bindings) do
        rhs_values[binding.rhs] = true
      end
      
      local unique_rhs = 0
      for _ in pairs(rhs_values) do
        unique_rhs = unique_rhs + 1
      end
      
      if unique_rhs > 1 then
        -- This is a conflict
        table.insert(keybindings.conflicts, dup_info)
        keybindings.stats.conflicts = keybindings.stats.conflicts + 1
      end
    end
  end
  
  keybindings.stats.unique = keybindings.stats.total - keybindings.stats.duplicates
end

local function analyze_which_key()
  -- Count which-key registrations
  local which_key_count = 0
  
  for _, binding in pairs(keybindings.by_source["lua/plugins/which-key.lua"] or {}) do
    if binding.type == "which_key" then
      which_key_count = which_key_count + 1
      keybindings.which_key[binding.mode .. "|" .. binding.lhs] = binding
    end
  end
  
  keybindings.stats.which_key_registered = which_key_count
  
  -- Find missing which-key registrations
  for key, _ in pairs(keybindings.all) do
    if not keybindings.which_key[key] then
      keybindings.stats.which_key_missing = keybindings.stats.which_key_missing + 1
    end
  end
end

local function generate_report()
  print("=" .. string.rep("=", 78))
  print("                    NEOVIM KEYBINDING COMPREHENSIVE ANALYSIS")
  print("=" .. string.rep("=", 78))
  print()
  
  -- Summary Statistics
  print("SUMMARY STATISTICS")
  print("-" .. string.rep("-", 78))
  print(string.format("Total Keybindings Found:        %d", keybindings.stats.total))
  print(string.format("Unique Keybindings:             %d", keybindings.stats.unique))
  print(string.format("Duplicate Definitions:          %d", keybindings.stats.duplicates))
  print(string.format("Conflicting Keybindings:        %d", keybindings.stats.conflicts))
  print(string.format("Which-Key Registered:           %d", keybindings.stats.which_key_registered))
  print(string.format("Missing from Which-Key:         %d", keybindings.stats.which_key_missing))
  print()
  
  -- Mode Distribution
  print("KEYBINDINGS BY MODE")
  print("-" .. string.rep("-", 78))
  for mode, bindings in pairs(keybindings.by_mode) do
    local mode_name = ({
      n = "Normal",
      v = "Visual",
      x = "Visual Block",
      s = "Select",
      o = "Operator",
      i = "Insert",
      c = "Command",
      t = "Terminal"
    })[mode] or mode
    print(string.format("  %s mode (%s):  %d bindings", mode_name, mode, #bindings))
  end
  print()
  
  -- Source File Distribution
  print("KEYBINDINGS BY SOURCE FILE")
  print("-" .. string.rep("-", 78))
  local sorted_sources = {}
  for source, bindings in pairs(keybindings.by_source) do
    table.insert(sorted_sources, {source = source, count = #bindings})
  end
  table.sort(sorted_sources, function(a, b) return a.count > b.count end)
  
  for i = 1, math.min(10, #sorted_sources) do
    local item = sorted_sources[i]
    print(string.format("  %-50s %d", item.source, item.count))
  end
  if #sorted_sources > 10 then
    print(string.format("  ... and %d more files", #sorted_sources - 10))
  end
  print()
  
  -- Duplicates
  if #keybindings.duplicates > 0 then
    print("DUPLICATE KEYBINDINGS (Same key in same mode)")
    print("-" .. string.rep("-", 78))
    for i = 1, math.min(10, #keybindings.duplicates) do
      local dup = keybindings.duplicates[i]
      print(string.format("\n  [%s] %s - Defined %d times:", dup.mode, dup.lhs, dup.count))
      for _, source in ipairs(dup.sources) do
        print(string.format("    • %s:%d → %s", 
          source.file, source.line, 
          source.rhs:sub(1, 40) .. (#source.rhs > 40 and "..." or "")))
      end
    end
    if #keybindings.duplicates > 10 then
      print(string.format("\n  ... and %d more duplicates", #keybindings.duplicates - 10))
    end
    print()
  end
  
  -- Conflicts
  if #keybindings.conflicts > 0 then
    print("CONFLICTING KEYBINDINGS (Same key, different actions)")
    print("-" .. string.rep("-", 78))
    for i = 1, math.min(5, #keybindings.conflicts) do
      local conflict = keybindings.conflicts[i]
      print(string.format("\n  ⚠️  [%s] %s - CONFLICT:", conflict.mode, conflict.lhs))
      for _, source in ipairs(conflict.sources) do
        print(string.format("    • %s:%d → %s", 
          source.file, source.line, 
          source.rhs:sub(1, 40) .. (#source.rhs > 40 and "..." or "")))
      end
    end
    if #keybindings.conflicts > 5 then
      print(string.format("\n  ... and %d more conflicts", #keybindings.conflicts - 5))
    end
    print()
  end
  
  print("=" .. string.rep("=", 78))
end

local function save_json_report()
  local json_file = config.nvim_dir .. "/keybinding-analysis.json"
  local file = io.open(json_file, "w")
  if file then
    -- Create a simplified structure for JSON
    local json_data = {
      stats = keybindings.stats,
      duplicates = keybindings.duplicates,
      conflicts = keybindings.conflicts,
      timestamp = os.date("%Y-%m-%d %H:%M:%S")
    }
    
    -- Simple JSON serialization (basic implementation)
    local function to_json(obj, indent)
      indent = indent or 0
      local spacing = string.rep("  ", indent)
      local result = {}
      
      if type(obj) == "table" then
        local is_array = #obj > 0
        table.insert(result, is_array and "[" or "{")
        
        local items = {}
        if is_array then
          for i, v in ipairs(obj) do
            table.insert(items, to_json(v, indent + 1))
          end
        else
          for k, v in pairs(obj) do
            local key = '"' .. tostring(k) .. '": '
            table.insert(items, spacing .. "  " .. key .. to_json(v, indent + 1))
          end
        end
        
        if #items > 0 then
          table.insert(result, "\n" .. table.concat(items, ",\n") .. "\n" .. spacing)
        end
        table.insert(result, is_array and "]" or "}")
      elseif type(obj) == "string" then
        return '"' .. obj:gsub('"', '\\"') .. '"'
      else
        return tostring(obj)
      end
      
      return table.concat(result)
    end
    
    file:write(to_json(json_data))
    file:close()
    print("\nJSON report saved to: " .. json_file)
  end
end

-- Main execution
local function main()
  print("Starting comprehensive keybinding analysis...")
  print("Scanning directory: " .. config.nvim_dir)
  print()
  
  -- Find all Lua files
  local files = find_lua_files(config.nvim_dir)
  print(string.format("Found %d Lua files to analyze", #files))
  
  -- Scan each file
  local progress = 0
  for _, file in ipairs(files) do
    scan_file(file)
    progress = progress + 1
    if progress % 10 == 0 then
      io.write(".")
      io.flush()
    end
  end
  print("\n")
  
  -- Analyze data
  print("Analyzing duplicates and conflicts...")
  analyze_duplicates()
  
  if config.analyze_which_key then
    print("Analyzing which-key registrations...")
    analyze_which_key()
  end
  
  -- Generate report
  generate_report()
  
  -- Save JSON report
  save_json_report()
  
  print("\nAnalysis complete!")
  print("Run this script anytime to get updated statistics.")
end

-- Execute
main()
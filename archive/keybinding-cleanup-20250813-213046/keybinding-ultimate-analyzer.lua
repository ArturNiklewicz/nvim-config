#!/usr/bin/env lua

-- Ultimate Keybinding Analyzer for Neovim Configuration
-- Complete analysis with duplicate detection, which-key coverage, and unbinded keymaps
-- Author: Claude Code
-- Version: 2.0

local config = {
  nvim_dir = os.getenv("HOME") .. "/.config/nvim",
  check_unbinded = true,
  verbose = false,
}

-- ANSI color codes for terminal output
local colors = {
  reset = "\27[0m",
  bold = "\27[1m",
  red = "\27[31m",
  green = "\27[32m",
  yellow = "\27[33m",
  blue = "\27[34m",
  magenta = "\27[35m",
  cyan = "\27[36m",
  white = "\27[37m",
}

-- Data structures
local analysis = {
  keybindings = {},      -- All found keybindings
  which_key = {},        -- Which-key registrations
  duplicates = {},       -- Duplicate keybindings
  conflicts = {},        -- Conflicting keybindings (same key, different action)
  unbinded = {},         -- References to keybindings that don't exist
  orphaned = {},         -- Keybindings not in which-key
  stats = {
    total = 0,
    unique = 0,
    duplicates = 0,
    conflicts = 0,
    which_key_total = 0,
    which_key_groups = 0,
    unbinded = 0,
    orphaned = 0,
    by_mode = {},
    by_source = {},
  }
}

-- Pattern definitions for finding keybindings
local patterns = {
  -- vim.keymap.set with various quote styles
  {
    regex = 'vim%.keymap%.set%s*%(%s*["\'{]%s*([^"\'%}]-)%s*["\'}]%s*,%s*["\']([^"\']-)["\']%s*,%s*([^,%)]+)',
    name = "vim.keymap.set",
    extract = function(mode, lhs, rhs)
      return mode:gsub('["%s{}]', ''), lhs, rhs
    end
  },
  -- vim.api.nvim_set_keymap
  {
    regex = 'vim%.api%.nvim_set_keymap%s*%(%s*["\']([^"\']-)["\']%s*,%s*["\']([^"\']-)["\']%s*,%s*["\']([^"\']-)["\']',
    name = "nvim_set_keymap",
    extract = function(mode, lhs, rhs)
      return mode, lhs, rhs
    end
  },
  -- AstroNvim mappings table format
  {
    regex = '%[%s*["\']([^"\']+)["\']%s*%]%s*=%s*%{%s*["\']([^"\']+)["\']',
    name = "astro_mappings",
    extract = function(lhs, rhs)
      return "n", lhs, rhs  -- Default to normal mode
    end
  },
  -- Plugin keys table format
  {
    regex = '%{%s*["\']([^"\']+)["\']%s*,%s*["\']?([^"\',%}]+)["\']?%s*,?%s*desc%s*=%s*["\']([^"\']+)["\']',
    name = "plugin_keys",
    extract = function(lhs, rhs, desc)
      return "n", lhs, rhs or desc
    end
  },
  -- Which-key register format
  {
    regex = '%[%s*["\']([^"\']+)["\']%s*%]%s*=%s*["\']([^"\']+)["\']',
    name = "which_key_binding",
    extract = function(lhs, desc)
      return "n", lhs, desc
    end
  },
  -- Which-key group format
  {
    regex = '%[%s*["\']([^"\']+)["\']%s*%]%s*=%s*%{%s*name%s*=%s*["\']([^"\']+)["\']',
    name = "which_key_group",
    extract = function(lhs, name)
      return "n", lhs, "GROUP: " .. name
    end
  },
}

-- Helper functions
local function normalize_key(key)
  if not key then return "" end
  key = key:gsub("<[Ll]eader>", "<Space>")
  key = key:gsub("<[Ll]ocalleader>", ",")
  key = key:gsub("<[Cc][Rr]>", "<CR>")
  key = key:gsub("<[Ee][Ss][Cc]>", "<Esc>")
  key = key:gsub("<[Tt][Aa][Bb]>", "<Tab>")
  key = key:gsub("<[Bb][Ss]>", "<BS>")
  key = key:gsub("<[Ss]pace>", " ")
  key = key:gsub("^%s+", ""):gsub("%s+$", "")
  return key
end

local function expand_modes(mode_str)
  local modes = {}
  local mode_map = {
    ["n"] = "n", ["v"] = "v", ["x"] = "x", ["s"] = "s",
    ["o"] = "o", ["i"] = "i", ["c"] = "c", ["t"] = "t",
  }
  
  -- Handle array-like mode strings
  if mode_str:match("%{") then
    for m in mode_str:gmatch('["\'](.-)["\']') do
      if mode_map[m] then
        table.insert(modes, m)
      end
    end
  else
    -- Handle single string with multiple modes
    for char in mode_str:gmatch(".") do
      if mode_map[char] then
        table.insert(modes, char)
      end
    end
  end
  
  return #modes > 0 and modes or {"n"}
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
  
  local relative_path = filepath:gsub(config.nvim_dir .. "/", "")
  local line_num = 0
  
  -- Track which-key specific files
  local is_which_key = relative_path:match("which%-key") ~= nil
  
  for line in content:gmatch("[^\r\n]+") do
    line_num = line_num + 1
    
    -- Skip pure comment lines
    if line:match("^%s*%-%-") then
      goto continue
    end
    
    -- Try each pattern
    for _, pattern in ipairs(patterns) do
      local captures = {line:match(pattern.regex)}
      if #captures > 0 then
        local mode, lhs, rhs = pattern.extract(unpack(captures))
        
        if lhs and lhs ~= "" then
          lhs = normalize_key(lhs)
          local modes = expand_modes(mode or "n")
          
          for _, m in ipairs(modes) do
            local key_id = m .. "|" .. lhs
            local binding = {
              mode = m,
              lhs = lhs,
              rhs = rhs or "",
              source = relative_path,
              line = line_num,
              type = pattern.name,
              is_which_key = is_which_key,
            }
            
            -- Add to appropriate collection
            if is_which_key then
              if pattern.name == "which_key_group" then
                analysis.stats.which_key_groups = analysis.stats.which_key_groups + 1
              else
                analysis.which_key[key_id] = binding
                analysis.stats.which_key_total = analysis.stats.which_key_total + 1
              end
            else
              if not analysis.keybindings[key_id] then
                analysis.keybindings[key_id] = {}
              end
              table.insert(analysis.keybindings[key_id], binding)
              analysis.stats.total = analysis.stats.total + 1
              
              -- Track by mode
              analysis.stats.by_mode[m] = (analysis.stats.by_mode[m] or 0) + 1
            end
            
            -- Track by source
            analysis.stats.by_source[relative_path] = (analysis.stats.by_source[relative_path] or 0) + 1
          end
        end
      end
    end
    
    -- Check for unbinded references (desc without actual binding)
    if config.check_unbinded then
      local desc_match = line:match('desc%s*=%s*["\']([^"\']+)["\']')
      if desc_match and not line:match('vim%.keymap%.set') and not line:match('keys%s*=') then
        -- This might be an unbinded reference
        table.insert(analysis.unbinded, {
          desc = desc_match,
          source = relative_path,
          line = line_num,
        })
      end
    end
    
    ::continue::
  end
end

local function find_lua_files(dir)
  local files = {}
  local handle = io.popen('find "' .. dir .. '" -type f -name "*.lua" 2>/dev/null | grep -v "/backup/" | grep -v "/.git/" | grep -v "/tests/"')
  if handle then
    for file in handle:lines() do
      table.insert(files, file)
    end
    handle:close()
  end
  return files
end

local function analyze_duplicates()
  for key_id, bindings in pairs(analysis.keybindings) do
    if #bindings > 1 then
      local mode, lhs = key_id:match("^(.-)|(.*)")
      
      -- Check if it's a true conflict (different actions)
      local unique_rhs = {}
      for _, binding in ipairs(bindings) do
        unique_rhs[binding.rhs] = true
      end
      
      local is_conflict = false
      local count = 0
      for _ in pairs(unique_rhs) do
        count = count + 1
      end
      if count > 1 then
        is_conflict = true
      end
      
      local dup_info = {
        mode = mode,
        lhs = lhs,
        count = #bindings,
        is_conflict = is_conflict,
        sources = bindings,
      }
      
      if is_conflict then
        table.insert(analysis.conflicts, dup_info)
        analysis.stats.conflicts = analysis.stats.conflicts + 1
      else
        table.insert(analysis.duplicates, dup_info)
        analysis.stats.duplicates = analysis.stats.duplicates + 1
      end
    end
  end
  
  analysis.stats.unique = analysis.stats.total - analysis.stats.duplicates - analysis.stats.conflicts
end

local function analyze_orphaned()
  -- Find keybindings not in which-key
  for key_id, _ in pairs(analysis.keybindings) do
    if not analysis.which_key[key_id] then
      local mode, lhs = key_id:match("^(.-)|(.*)")
      -- Only count leader-based keybindings as potentially orphaned
      if lhs:match("^<Space>") or lhs:match("^<Leader>") then
        table.insert(analysis.orphaned, {
          mode = mode,
          lhs = lhs,
          bindings = analysis.keybindings[key_id]
        })
        analysis.stats.orphaned = analysis.stats.orphaned + 1
      end
    end
  end
end

local function print_section(title)
  print()
  print(colors.bold .. colors.cyan .. "━━━ " .. title .. " " .. string.rep("━", 75 - #title) .. colors.reset)
end

local function print_stat(label, value, color)
  color = color or colors.white
  print(string.format("  %s%-35s%s %s%d%s", colors.white, label, colors.reset, color, value, colors.reset))
end

local function generate_report()
  print(colors.bold .. colors.magenta)
  print("╔" .. string.rep("═", 78) .. "╗")
  print("║" .. string.rep(" ", 20) .. "NEOVIM KEYBINDING ULTIMATE ANALYSIS" .. string.rep(" ", 22) .. "║")
  print("╚" .. string.rep("═", 78) .. "╝")
  print(colors.reset)
  
  -- Statistics
  print_section("SUMMARY STATISTICS")
  print_stat("Total Keybindings Found:", analysis.stats.total, colors.green)
  print_stat("Unique Keybindings:", analysis.stats.unique, colors.green)
  print_stat("Duplicate Definitions:", analysis.stats.duplicates, analysis.stats.duplicates > 0 and colors.yellow or colors.green)
  print_stat("Conflicting Keybindings:", analysis.stats.conflicts, analysis.stats.conflicts > 0 and colors.red or colors.green)
  print_stat("Which-Key Registered:", analysis.stats.which_key_total, colors.blue)
  print_stat("Which-Key Groups:", analysis.stats.which_key_groups, colors.blue)
  print_stat("Orphaned (not in Which-Key):", analysis.stats.orphaned, analysis.stats.orphaned > 0 and colors.yellow or colors.green)
  print_stat("Potentially Unbinded:", #analysis.unbinded, #analysis.unbinded > 0 and colors.yellow or colors.green)
  
  -- Mode distribution
  print_section("KEYBINDINGS BY MODE")
  local mode_names = {
    n = "Normal", v = "Visual", x = "Visual Block", s = "Select",
    o = "Operator", i = "Insert", c = "Command", t = "Terminal"
  }
  for mode, count in pairs(analysis.stats.by_mode) do
    print(string.format("  %s%-20s%s %d", colors.cyan, mode_names[mode] or mode, colors.reset, count))
  end
  
  -- Top source files
  print_section("TOP SOURCE FILES")
  local sources = {}
  for source, count in pairs(analysis.stats.by_source) do
    table.insert(sources, {source = source, count = count})
  end
  table.sort(sources, function(a, b) return a.count > b.count end)
  
  for i = 1, math.min(8, #sources) do
    print(string.format("  %-50s %d", sources[i].source, sources[i].count))
  end
  
  -- Conflicts (most critical)
  if #analysis.conflicts > 0 then
    print_section("⚠️  CONFLICTING KEYBINDINGS (CRITICAL)")
    for i = 1, math.min(5, #analysis.conflicts) do
      local conflict = analysis.conflicts[i]
      print(colors.red .. string.format("\n  [%s] %s - %d conflicting definitions:", 
        conflict.mode, conflict.lhs, conflict.count) .. colors.reset)
      for _, source in ipairs(conflict.sources) do
        print(string.format("    %s• %s:%d%s → %s", 
          colors.yellow, source.source, source.line, colors.reset,
          source.rhs:sub(1, 40)))
      end
    end
  end
  
  -- Regular duplicates
  if #analysis.duplicates > 0 then
    print_section("DUPLICATE KEYBINDINGS (Same action)")
    for i = 1, math.min(3, #analysis.duplicates) do
      local dup = analysis.duplicates[i]
      print(string.format("\n  [%s] %s - Defined %d times", dup.mode, dup.lhs, dup.count))
      for j, source in ipairs(dup.sources) do
        if j <= 3 then
          print(string.format("    • %s:%d", source.source, source.line))
        end
      end
    end
  end
  
  -- Orphaned keybindings
  if #analysis.orphaned > 0 then
    print_section("ORPHANED KEYBINDINGS (Not in Which-Key)")
    local shown = 0
    for _, orphan in ipairs(analysis.orphaned) do
      if shown < 10 then
        local binding = orphan.bindings[1]
        print(string.format("  [%s] %-20s from %s:%d", 
          orphan.mode, orphan.lhs, binding.source, binding.line))
        shown = shown + 1
      end
    end
    if #analysis.orphaned > 10 then
      print(colors.yellow .. "  ... and " .. (#analysis.orphaned - 10) .. " more" .. colors.reset)
    end
  end
  
  -- Unbinded references
  if #analysis.unbinded > 0 then
    print_section("POTENTIALLY UNBINDED REFERENCES")
    for i = 1, math.min(5, #analysis.unbinded) do
      local unbound = analysis.unbinded[i]
      print(string.format("  '%s' at %s:%d", 
        unbound.desc, unbound.source, unbound.line))
    end
  end
  
  print()
  print(colors.bold .. colors.green .. "═" .. string.rep("═", 78) .. colors.reset)
  print()
end

local function save_detailed_report()
  local report_file = config.nvim_dir .. "/KEYBINDING_COMPLETE_ANALYSIS.md"
  local file = io.open(report_file, "w")
  if not file then
    print(colors.red .. "Failed to create report file" .. colors.reset)
    return
  end
  
  file:write("# Neovim Keybinding Complete Analysis Report\n\n")
  file:write("Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n")
  
  file:write("## Summary Statistics\n\n")
  file:write("| Metric | Count |\n")
  file:write("|--------|-------|\n")
  file:write(string.format("| Total Keybindings | %d |\n", analysis.stats.total))
  file:write(string.format("| Unique Keybindings | %d |\n", analysis.stats.unique))
  file:write(string.format("| Duplicates | %d |\n", analysis.stats.duplicates))
  file:write(string.format("| Conflicts | %d |\n", analysis.stats.conflicts))
  file:write(string.format("| Which-Key Registered | %d |\n", analysis.stats.which_key_total))
  file:write(string.format("| Orphaned | %d |\n", analysis.stats.orphaned))
  file:write(string.format("| Unbinded | %d |\n", #analysis.unbinded))
  
  file:write("\n## Conflicts (Action Required)\n\n")
  if #analysis.conflicts > 0 then
    for _, conflict in ipairs(analysis.conflicts) do
      file:write(string.format("### `[%s] %s`\n\n", conflict.mode, conflict.lhs))
      for _, source in ipairs(conflict.sources) do
        file:write(string.format("- **%s:%d** → `%s`\n", 
          source.source, source.line, source.rhs))
      end
      file:write("\n")
    end
  else
    file:write("No conflicts found! ✅\n\n")
  end
  
  file:close()
  print(colors.green .. "Detailed report saved to: " .. report_file .. colors.reset)
end

-- Main execution
local function main()
  print(colors.bold .. "Starting ultimate keybinding analysis..." .. colors.reset)
  
  -- Find and scan files
  local files = find_lua_files(config.nvim_dir)
  print(string.format("Found %d Lua files to analyze", #files))
  
  local progress = 0
  for _, file in ipairs(files) do
    scan_file(file)
    progress = progress + 1
    if progress % 10 == 0 then
      io.write(".")
      io.flush()
    end
  end
  print()
  
  -- Analyze
  analyze_duplicates()
  analyze_orphaned()
  
  -- Generate reports
  generate_report()
  save_detailed_report()
  
  print(colors.bold .. colors.green .. "\n✅ Analysis complete!" .. colors.reset)
  print("For actionable items, see: " .. colors.cyan .. "KEYBINDING_COMPLETE_ANALYSIS.md" .. colors.reset)
end

-- Run the analysis
main()
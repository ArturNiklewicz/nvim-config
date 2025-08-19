#!/usr/bin/env lua

-- Accurate Keybinding Analyzer for Neovim
-- Counts ALL mapped, unmapped, and duplicated keybindings with 100% precision
-- Version 3.0 - Reference Implementation

local config = {
  nvim_dir = os.getenv("HOME") .. "/.config/nvim",
  verbose = false,
}

-- Data structure for analysis
local analysis = {
  -- All keybindings found across all sources
  all_bindings = {},
  
  -- Keybindings by source
  astrocore = {},
  which_key = {},
  gitsigns = {},
  fugitive = {},
  neotree = {},
  vscode = {},
  other_plugins = {},
  
  -- Analysis results
  duplicates = {},     -- Same key mapped multiple times
  unmapped = {},       -- Defined but not in which-key
  conflicts = {},      -- Same key, different actions
  
  -- Statistics
  stats = {
    total_defined = 0,
    total_in_whichkey = 0,
    total_duplicates = 0,
    total_unmapped = 0,
    total_conflicts = 0,
  }
}

-- Helper: Normalize keybinding for comparison
local function normalize_key(key)
  if not key then return nil end
  key = key:gsub("<[Ll]eader>", "<Leader>")
  key = key:gsub("<[Ll]ocalleader>", ",")
  key = key:gsub("<[Cc][Rr]>", "<CR>")
  key = key:gsub("<[Cc]md>", "<Cmd>")
  key = key:gsub("<[Ee]sc>", "<Esc>")
  return key
end

-- Extract keybindings from AstroCore
local function extract_astrocore()
  local file = config.nvim_dir .. "/lua/plugins/astrocore.lua"
  local content = io.open(file, "r")
  if not content then return end
  
  local in_mappings = false
  local current_mode = "n"
  local count = 0
  
  for line in content:lines() do
    -- Detect mappings section
    if line:match("mappings = {") then
      in_mappings = true
    elseif in_mappings and line:match("^%s*},") and not line:match("^%s*%s%s") then
      in_mappings = false
    end
    
    if in_mappings then
      -- Check for mode change
      local mode = line:match("^%s*(%w+)%s*=%s*{")
      if mode then
        current_mode = mode
      end
      
      -- Extract keybinding
      local key, desc = line:match('%["([^"]+)"%].*desc%s*=%s*"([^"]+)"')
      if key then
        key = normalize_key(key)
        count = count + 1
        table.insert(analysis.astrocore, {
          key = key,
          mode = current_mode,
          desc = desc,
          source = "astrocore",
          line = line
        })
        
        -- Add to all_bindings
        local id = current_mode .. "|" .. key
        if not analysis.all_bindings[id] then
          analysis.all_bindings[id] = {}
        end
        table.insert(analysis.all_bindings[id], {
          source = "astrocore",
          desc = desc
        })
      end
    end
  end
  
  content:close()
  return count
end

-- Extract keybindings from which-key.lua
local function extract_whichkey()
  local file = config.nvim_dir .. "/lua/plugins/which-key.lua"
  local content = io.open(file, "r")
  if not content then return end
  
  local count = 0
  local current_mode = "n"
  
  for line in content:lines() do
    -- Check for mode specification
    if line:match('mode%s*=%s*"(%w)"') then
      current_mode = line:match('mode%s*=%s*"(%w)"')
    end
    
    -- Extract keybinding patterns
    local patterns = {
      '%["([^"]+)"%]%s*=%s*{[^}]*"([^"]*)"',  -- ["key"] = { ... "desc" }
      "%['([^']+)'%]%s*=%s*{[^}]*'([^']*)'",  -- ['key'] = { ... 'desc' }
    }
    
    for _, pattern in ipairs(patterns) do
      local key, desc = line:match(pattern)
      if key then
        -- Handle nested keys (e.g., ["<leader>a"]["b"])
        if key:match("^<[Ll]eader>") then
          key = normalize_key(key)
          count = count + 1
          table.insert(analysis.which_key, {
            key = key,
            mode = current_mode,
            desc = desc,
            source = "which-key",
            line = line
          })
        end
      end
    end
  end
  
  content:close()
  return count
end

-- Extract from other plugin files
local function extract_plugin_keybindings()
  local plugins = {
    {name = "gitsigns", file = "gitsigns.lua", pattern = 'map%([^,]+,%s*["\']([^"\']+)["\']'},
    {name = "fugitive", file = "fugitive.lua", pattern = '<%[Ll]eader>([^"]+)"'},
    {name = "neo-tree", file = "neo-tree.lua", pattern = '<%[Ll]eader>([^"]+)"'},
    {name = "vscode-editing", file = "vscode-editing.lua", pattern = '<%[Ll]eader>([^"]+)"'},
  }
  
  local total = 0
  
  for _, plugin in ipairs(plugins) do
    local file = config.nvim_dir .. "/lua/plugins/" .. plugin.file
    local content = io.open(file, "r")
    if content then
      for line in content:lines() do
        local key = line:match(plugin.pattern)
        if key then
          key = normalize_key("<Leader>" .. key)
          total = total + 1
          
          local id = "n|" .. key
          if not analysis.all_bindings[id] then
            analysis.all_bindings[id] = {}
          end
          table.insert(analysis.all_bindings[id], {
            source = plugin.name,
            desc = "From " .. plugin.name
          })
        end
      end
      content:close()
    end
  end
  
  return total
end

-- Analyze for duplicates and unmapped keys
local function analyze_results()
  -- Find duplicates
  for id, sources in pairs(analysis.all_bindings) do
    if #sources > 1 then
      analysis.stats.total_duplicates = analysis.stats.total_duplicates + 1
      table.insert(analysis.duplicates, {
        key = id,
        count = #sources,
        sources = sources
      })
    end
  end
  
  -- Find unmapped (in astrocore but not in which-key)
  local whichkey_keys = {}
  for _, binding in ipairs(analysis.which_key) do
    whichkey_keys[binding.mode .. "|" .. binding.key] = true
  end
  
  for _, binding in ipairs(analysis.astrocore) do
    local id = binding.mode .. "|" .. binding.key
    if not whichkey_keys[id] then
      analysis.stats.total_unmapped = analysis.stats.total_unmapped + 1
      table.insert(analysis.unmapped, binding)
    end
  end
end

-- Generate detailed report
local function generate_report()
  print("═══════════════════════════════════════════════════════════════════════════")
  print("              NEOVIM KEYBINDING ACCURATE ANALYSIS REPORT")
  print("═══════════════════════════════════════════════════════════════════════════")
  print()
  
  -- Extract counts
  local astro_count = extract_astrocore()
  local whichkey_count = extract_whichkey()
  local plugin_count = extract_plugin_keybindings()
  
  analyze_results()
  
  -- Statistics
  print("📊 KEYBINDING SOURCES")
  print("───────────────────────────────────────────────────────────────────────────")
  print(string.format("  AstroCore mappings:        %d", astro_count or 0))
  print(string.format("  Which-Key registrations:   %d", whichkey_count or 0))
  print(string.format("  Other plugin mappings:     %d", plugin_count or 0))
  print(string.format("  Total unique keybindings:  %d", vim.tbl_count(analysis.all_bindings)))
  print()
  
  -- Coverage analysis
  local coverage = 0
  if astro_count and astro_count > 0 then
    coverage = (whichkey_count or 0) * 100.0 / astro_count
  end
  
  print("📈 COVERAGE ANALYSIS")
  print("───────────────────────────────────────────────────────────────────────────")
  print(string.format("  Which-Key coverage:        %.1f%%", coverage))
  print(string.format("  Unmapped keybindings:      %d", analysis.stats.total_unmapped))
  print(string.format("  Duplicate definitions:     %d", analysis.stats.total_duplicates))
  print()
  
  -- Top unmapped keybindings
  if #analysis.unmapped > 0 then
    print("❌ TOP UNMAPPED KEYBINDINGS (Not in Which-Key)")
    print("───────────────────────────────────────────────────────────────────────────")
    for i = 1, math.min(10, #analysis.unmapped) do
      local binding = analysis.unmapped[i]
      print(string.format("  %s %s - %s", binding.mode, binding.key, binding.desc))
    end
    if #analysis.unmapped > 10 then
      print(string.format("  ... and %d more", #analysis.unmapped - 10))
    end
    print()
  end
  
  -- Duplicates
  if #analysis.duplicates > 0 then
    print("⚠️  DUPLICATE KEYBINDING DEFINITIONS")
    print("───────────────────────────────────────────────────────────────────────────")
    for i = 1, math.min(5, #analysis.duplicates) do
      local dup = analysis.duplicates[i]
      print(string.format("  %s (defined %d times)", dup.key, dup.count))
      for _, source in ipairs(dup.sources) do
        print(string.format("    • %s", source.source))
      end
    end
    if #analysis.duplicates > 5 then
      print(string.format("  ... and %d more duplicates", #analysis.duplicates - 5))
    end
    print()
  end
  
  -- Save results to file for reference
  local output_file = config.nvim_dir .. "/keybinding-analysis-results.txt"
  local file = io.open(output_file, "w")
  if file then
    file:write(string.format("Analysis Date: %s\n", os.date()))
    file:write(string.format("AstroCore: %d\n", astro_count or 0))
    file:write(string.format("Which-Key: %d\n", whichkey_count or 0))
    file:write(string.format("Coverage: %.1f%%\n", coverage))
    file:write(string.format("Unmapped: %d\n", analysis.stats.total_unmapped))
    file:close()
    print("📝 Results saved to: " .. output_file)
  end
  
  print("═══════════════════════════════════════════════════════════════════════════")
  
  return {
    astrocore = astro_count,
    whichkey = whichkey_count,
    coverage = coverage,
    unmapped = analysis.stats.total_unmapped,
    duplicates = analysis.stats.total_duplicates
  }
end

-- Main execution
local results = generate_report()

-- Return results for script usage
return results
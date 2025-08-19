#!/usr/bin/env lua

-- Precise Keybinding Analyzer for Neovim Configuration

local M = {}
M.keybindings = {}
M.duplicates = {}
M.files_scanned = 0

-- More precise patterns for extracting keybindings
function M.parse_astro_mappings(content, filepath)
  local bindings = {}
  
  -- Find mappings = { ... } blocks
  for mappings_block in content:gmatch('mappings%s*=%s*{(.-)}%s*,%s*[%w_]') do
    -- Extract each mode block (n = {...}, v = {...}, etc.)
    for mode, mode_content in mappings_block:gmatch('(%w)%s*=%s*{([^}]-)}') do
      -- Extract keybindings from mode block
      -- Pattern 1: ["<key>"] = { action, desc = "..." }
      for key, action_block in mode_content:gmatch('%[%s*["\']([^"\']+)["\']%s*%]%s*=%s*{([^}]+)}') do
        local desc = action_block:match('desc%s*=%s*["\']([^"\']+)["\']') or "No description"
        local action = action_block:match('^%s*([^,]+)') or action_block
        action = action:gsub('^%s*', ''):gsub('%s*$', '')
        table.insert(bindings, {
          key = key,
          mode = mode,
          desc = desc,
          action = action,
          method = "AstroNvim mappings"
        })
      end
      
      -- Pattern 2: ["<key>"] = "action"
      for key, action in mode_content:gmatch('%[%s*["\']([^"\']+)["\']%s*%]%s*=%s*["\']([^"\']+)["\']') do
        table.insert(bindings, {
          key = key,
          mode = mode,
          desc = action,
          action = action,
          method = "AstroNvim mappings (string)"
        })
      end
      
      -- Pattern 3: ["<key>"] = function() ... end
      for key in mode_content:gmatch('%[%s*["\']([^"\']+)["\']%s*%]%s*=%s*function') do
        table.insert(bindings, {
          key = key,
          mode = mode,
          desc = "Function",
          action = "function()",
          method = "AstroNvim mappings (function)"
        })
      end
    end
  end
  
  return bindings
end

function M.parse_lazy_keys(content, filepath)
  local bindings = {}
  
  -- Find keys = { ... } blocks
  for keys_block in content:gmatch('keys%s*=%s*{(.-)}%s*[,}]') do
    -- Pattern: { "<key>", action, desc = "...", mode = "..." }
    for key_entry in keys_block:gmatch('{%s*["\']([^"\']+)["\'][^}]+}') do
      local key = key_entry
      local full_entry = keys_block:match('{%s*["\']' .. key:gsub("%-", "%%-"):gsub("%[", "%%["):gsub("%]", "%%]") .. '["\'][^}]+}')
      if full_entry then
        local desc = full_entry:match('desc%s*=%s*["\']([^"\']+)["\']') or "Lazy.nvim action"
        local mode = full_entry:match('mode%s*=%s*["\']([^"\']+)["\']') or "n"
        table.insert(bindings, {
          key = key,
          mode = mode,
          desc = desc,
          action = "Lazy.nvim",
          method = "Lazy.nvim keys"
        })
      end
    end
  end
  
  return bindings
end

function M.parse_vim_keymap_set(content, filepath)
  local bindings = {}
  
  -- Pattern: vim.keymap.set("mode", "key", action, { desc = "..." })
  for line in content:gmatch('vim%.keymap%.set%s*%([^\n]+%)') do
    local mode, key = line:match('["\']([^"\']+)["\']%s*,%s*["\']([^"\']+)["\']')
    if mode and key then
      local desc = line:match('desc%s*=%s*["\']([^"\']+)["\']') or "vim.keymap.set"
      table.insert(bindings, {
        key = key,
        mode = mode,
        desc = desc,
        action = "vim.keymap.set",
        method = "vim.keymap.set"
      })
    end
  end
  
  return bindings
end

function M.scan_file(filepath)
  local file = io.open(filepath, "r")
  if not file then
    print("Error: Cannot open " .. filepath)
    return
  end
  
  local content = file:read("*all")
  file:close()
  
  M.files_scanned = M.files_scanned + 1
  local relative_path = filepath:gsub("/Users/arturniklewicz/.config/nvim/", "")
  
  -- Parse different keybinding formats
  local bindings = {}
  
  -- AstroNvim mappings
  local astro_bindings = M.parse_astro_mappings(content, filepath)
  for _, binding in ipairs(astro_bindings) do
    binding.file = relative_path
    table.insert(bindings, binding)
  end
  
  -- Lazy.nvim keys
  local lazy_bindings = M.parse_lazy_keys(content, filepath)
  for _, binding in ipairs(lazy_bindings) do
    binding.file = relative_path
    table.insert(bindings, binding)
  end
  
  -- vim.keymap.set
  local vim_bindings = M.parse_vim_keymap_set(content, filepath)
  for _, binding in ipairs(vim_bindings) do
    binding.file = relative_path
    table.insert(bindings, binding)
  end
  
  -- Add to global list
  for _, binding in ipairs(bindings) do
    table.insert(M.keybindings, binding)
  end
  
  return #bindings
end

function M.analyze_all()
  local files_to_scan = {
    "lua/plugins/astrocore.lua",
    "lua/plugins/astrocore_fixed.lua",
    "lua/plugins/astrocore_keybindings_patch.lua",
    "lua/plugins/astrocore_new_mappings.lua",
    "lua/plugins/astrolsp.lua",
    "lua/plugins/bufferline.lua",
    "lua/plugins/claudecode.lua",
    "lua/plugins/error-messages.lua",
    "lua/plugins/fugitive.lua",
    "lua/plugins/gitsigns.lua",
    "lua/plugins/keybind-help.lua",
    "lua/plugins/markdown-preview.lua",
    "lua/plugins/molten.lua",
    "lua/plugins/neo-tree.lua",
    "lua/plugins/octo.lua",
    "lua/plugins/text-objects.lua",
    "lua/plugins/vscode-editing.lua",
    "lua/plugins/which-key.lua",
    "lua/plugins/zen-mode.lua",
    "lua/polish.lua",
    "lua/plugins/astrocore.lua.bak",
  }
  
  local base_path = "/Users/arturniklewicz/.config/nvim/"
  
  print("=== PRECISE NEOVIM KEYBINDING ANALYSIS ===")
  print("Analyzing keybinding configurations...\n")
  
  -- Scan each file
  for _, file in ipairs(files_to_scan) do
    local count = M.scan_file(base_path .. file)
    if count and count > 0 then
      print(string.format("✓ %s: %d keybindings", file:gsub("lua/plugins/", ""), count))
    end
  end
  
  -- Sort keybindings
  table.sort(M.keybindings, function(a, b)
    if a.key == b.key then
      if a.mode == b.mode then
        return a.file < b.file
      end
      return a.mode < b.mode
    end
    return a.key < b.key
  end)
  
  -- Find duplicates
  local seen = {}
  for _, kb in ipairs(M.keybindings) do
    local key_id = kb.mode .. ":" .. kb.key
    if not seen[key_id] then
      seen[key_id] = {kb}
    else
      table.insert(seen[key_id], kb)
      if not M.duplicates[key_id] then
        M.duplicates[key_id] = seen[key_id]
      end
    end
  end
  
  -- Print summary
  print("\n=== SUMMARY ===")
  print("Files scanned: " .. M.files_scanned)
  print("Total keybindings: " .. #M.keybindings)
  print("Unique combinations: " .. vim.tbl_count(seen))
  print("Duplicated keys: " .. vim.tbl_count(M.duplicates))
  
  -- Print duplicates
  if vim.tbl_count(M.duplicates) > 0 then
    print("\n=== DUPLICATE KEYBINDINGS ===")
    print("Keys defined in multiple locations:\n")
    
    -- Sort duplicates by number of definitions
    local sorted_dups = {}
    for key_id, defs in pairs(M.duplicates) do
      table.insert(sorted_dups, {key_id = key_id, defs = defs})
    end
    table.sort(sorted_dups, function(a, b)
      return #a.defs > #b.defs
    end)
    
    for _, dup in ipairs(sorted_dups) do
      local mode, key = dup.key_id:match("(.-):(.*)")
      print(string.format("\n[%s] %s - DEFINED %d TIMES:", mode, key, #dup.defs))
      for _, def in ipairs(dup.defs) do
        print(string.format("  • %-30s | %s | %s", 
          def.file:gsub("lua/plugins/", ""),
          def.method,
          def.desc:sub(1, 40)
        ))
      end
    end
  end
  
  -- Create clean output file
  local outfile = io.open("/Users/arturniklewicz/.config/nvim/keybinding-duplicates.txt", "w")
  if outfile then
    outfile:write("NEOVIM KEYBINDING DUPLICATE ANALYSIS\n")
    outfile:write("Generated: " .. os.date() .. "\n")
    outfile:write("=====================================\n\n")
    
    if vim.tbl_count(M.duplicates) > 0 then
      outfile:write("DUPLICATE KEYBINDINGS:\n\n")
      for _, dup in ipairs(sorted_dups) do
        local mode, key = dup.key_id:match("(.-):(.*)")
        outfile:write(string.format("[%s] %s (%d definitions):\n", mode, key, #dup.defs))
        for _, def in ipairs(dup.defs) do
          outfile:write(string.format("  - %s (%s): %s\n", 
            def.file, def.method, def.desc
          ))
        end
        outfile:write("\n")
      end
    else
      outfile:write("No duplicate keybindings found!\n")
    end
    
    outfile:close()
    print("\n\nDuplicate analysis saved to: keybinding-duplicates.txt")
  end
  
  -- Create matrix file
  local matrixfile = io.open("/Users/arturniklewicz/.config/nvim/keybinding-matrix.txt", "w")
  if matrixfile then
    matrixfile:write("NEOVIM KEYBINDING MATRIX\n")
    matrixfile:write("========================\n\n")
    
    local current_key = nil
    for _, kb in ipairs(M.keybindings) do
      if kb.key ~= current_key then
        current_key = kb.key
        matrixfile:write("\n" .. kb.key .. ":\n")
      end
      local dup_marker = ""
      if M.duplicates[kb.mode .. ":" .. kb.key] then
        dup_marker = " [DUP]"
      end
      matrixfile:write(string.format("  [%s] %-40s | %-25s | %s%s\n",
        kb.mode,
        kb.desc:sub(1, 40),
        kb.file:gsub("lua/plugins/", ""),
        kb.method,
        dup_marker
      ))
    end
    
    matrixfile:close()
    print("Complete matrix saved to: keybinding-matrix.txt")
  end
end

-- Run analysis
M.analyze_all()

return M
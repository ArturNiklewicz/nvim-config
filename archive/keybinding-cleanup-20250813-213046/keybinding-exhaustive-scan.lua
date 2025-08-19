#!/usr/bin/env lua

-- EXHAUSTIVE Keybinding Scanner for Neovim Configuration
-- This will find EVERY keybinding definition using EVERY possible method

local M = {}
M.all_keybindings = {}
M.duplicates = {}
M.conflicts = {}

-- Enhanced pattern matching for ALL keybinding methods
function M.scan_file(filepath)
  local file = io.open(filepath, "r")
  if not file then return end
  
  local content = file:read("*all")
  file:close()
  
  local relative_path = filepath:gsub("/Users/arturniklewicz/.config/nvim/", "")
  
  -- Method 1: AstroNvim mappings table
  -- mappings = { n = { ["<key>"] = { action, desc = "..." } } }
  for mode_block in content:gmatch('mappings%s*=%s*{.-\n%s*}') do
    for mode in mode_block:gmatch('(%w)%s*=%s*{') do
      local mode_content = mode_block:match(mode .. '%s*=%s*({.-})')
      if mode_content then
        -- Extract each keybinding
        for key, rest in mode_content:gmatch('%[["\'](.-)["\']%]%s*=%s*{(.-)}') do
          local desc = rest:match('desc%s*=%s*["\'](.-)["\']') or "No description"
          local action = rest:match('^%s*([^,]+)') or "Unknown action"
          table.insert(M.all_keybindings, {
            key = key,
            mode = mode,
            desc = desc,
            action = action,
            file = relative_path,
            method = "AstroNvim mappings",
            line = M.get_line_number(content, key)
          })
        end
        
        -- Also check for direct string assignments
        for key, action in mode_content:gmatch('%[["\'](.-)["\']%]%s*=%s*["\']([^"\']+)["\']') do
          table.insert(M.all_keybindings, {
            key = key,
            mode = mode,
            desc = action,
            action = action,
            file = relative_path,
            method = "AstroNvim mappings (string)",
            line = M.get_line_number(content, key)
          })
        end
        
        -- Check for function assignments
        for key in mode_content:gmatch('%[["\'](.-)["\']%]%s*=%s*function') do
          table.insert(M.all_keybindings, {
            key = key,
            mode = mode,
            desc = "Function",
            action = "function()",
            file = relative_path,
            method = "AstroNvim mappings (function)",
            line = M.get_line_number(content, key)
          })
        end
      end
    end
  end
  
  -- Method 2: Lazy.nvim keys
  -- keys = { { "<key>", action, desc = "..." } }
  for keys_block in content:gmatch('keys%s*=%s*{(.-\n%s*})') do
    -- Extract individual key definitions
    for key_def in keys_block:gmatch('{%s*["\']([^"\']+)["\']') do
      local key = key_def
      local desc = keys_block:match('desc%s*=%s*["\'](.-)["\']') or "No description"
      local mode = keys_block:match('mode%s*=%s*["\'](.-)["\']') or "n"
      table.insert(M.all_keybindings, {
        key = key,
        mode = mode,
        desc = desc,
        action = "Lazy.nvim",
        file = relative_path,
        method = "Lazy.nvim keys",
        line = M.get_line_number(content, key)
      })
    end
  end
  
  -- Method 3: vim.keymap.set
  for match in content:gmatch('vim%.keymap%.set%s*%([^%)]+%)') do
    local mode = match:match('["\']([^"\']+)["\']') or "?"
    local key = match:match('["\']%w["\'],[%s\n]*["\']([^"\']+)["\']') or "?"
    local desc = match:match('desc%s*=%s*["\'](.-)["\']') or "No description"
    table.insert(M.all_keybindings, {
      key = key,
      mode = mode,
      desc = desc,
      action = "vim.keymap.set",
      file = relative_path,
      method = "vim.keymap.set",
      line = M.get_line_number(content, match)
    })
  end
  
  -- Method 4: which-key register
  for wk_block in content:gmatch('wk%.register%s*%(%s*{(.-)}%s*,') do
    for key, desc in wk_block:gmatch('%[["\'](.-)["\']%]%s*=%s*["\']([^"\']+)["\']') do
      table.insert(M.all_keybindings, {
        key = key,
        mode = "n",  -- which-key defaults to normal mode
        desc = desc,
        action = "which-key",
        file = relative_path,
        method = "which-key.register",
        line = M.get_line_number(content, key)
      })
    end
  end
  
  -- Method 5: Direct nvim_set_keymap
  for match in content:gmatch('nvim_set_keymap%s*%([^%)]+%)') do
    local mode = match:match('["\']([^"\']+)["\']') or "?"
    local key = match:match('["\']%w["\'],[%s\n]*["\']([^"\']+)["\']') or "?"
    table.insert(M.all_keybindings, {
      key = key,
      mode = mode,
      desc = "nvim_set_keymap",
      action = "nvim_set_keymap",
      file = relative_path,
      method = "nvim_set_keymap",
      line = M.get_line_number(content, match)
    })
  end
  
  -- Method 6: on_attach functions
  for on_attach_block in content:gmatch('on_attach%s*=%s*function.-end') do
    for match in on_attach_block:gmatch('keymap[^%)]+%)') do
      local key = match:match('["\']([^"\']+)["\']') or "?"
      local mode = match:match('["\'](%w)["\']') or "n"
      table.insert(M.all_keybindings, {
        key = key,
        mode = mode,
        desc = "LSP on_attach",
        action = "on_attach",
        file = relative_path,
        method = "on_attach",
        line = M.get_line_number(content, match)
      })
    end
  end
  
  -- Method 7: Plugin-specific keybindings (like bufferline)
  -- Check for any table with key-like patterns
  for key in content:gmatch('<[A-Z][^>]+>') do
    if key:match('^<[A-Za-z%-]+>$') then
      -- Try to find context
      local context = M.find_context(content, key)
      if context then
        table.insert(M.all_keybindings, {
          key = key,
          mode = "n",
          desc = "Found in context",
          action = context,
          file = relative_path,
          method = "Pattern match",
          line = M.get_line_number(content, key)
        })
      end
    end
  end
end

-- Helper function to get line number
function M.get_line_number(content, search_str)
  local line_num = 1
  for line in content:gmatch("[^\n]*") do
    if line:find(search_str, 1, true) then
      return line_num
    end
    line_num = line_num + 1
  end
  return 0
end

-- Helper function to find context around a key
function M.find_context(content, key)
  local pos = content:find(key, 1, true)
  if not pos then return nil end
  
  -- Get surrounding 100 characters
  local start_pos = math.max(1, pos - 50)
  local end_pos = math.min(#content, pos + 50)
  local context = content:sub(start_pos, end_pos)
  
  -- Clean up context
  context = context:gsub('\n', ' '):gsub('%s+', ' ')
  return context
end

-- Analyze all files
function M.analyze_all()
  local files = {
    "/Users/arturniklewicz/.config/nvim/init.lua",
    "/Users/arturniklewicz/.config/nvim/lua/community.lua",
    "/Users/arturniklewicz/.config/nvim/lua/lazy_setup.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/astrocore.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/astrocore_fixed.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/astrocore_keybindings_patch.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/astrocore_new_mappings.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/astrolsp.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/astroui.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/bufferline.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/claudecode.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/error-messages.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/fugitive.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/gitsigns.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/keybind-help.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/markdown-preview.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/mason.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/molten.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/neo-tree.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/none-ls.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/octo.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/text-objects.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/treesitter.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/user.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/vscode-editing.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/which-key-groups.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/which-key.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/zen-mode.lua",
    "/Users/arturniklewicz/.config/nvim/lua/polish.lua",
    "/Users/arturniklewicz/.config/nvim/lua/utils/buffer-nav.lua",
    "/Users/arturniklewicz/.config/nvim/lua/utils/git-monitor.lua",
    "/Users/arturniklewicz/.config/nvim/lua/plugins/astrocore.lua.bak",
    "/Users/arturniklewicz/.config/nvim/plugin/tmux-swap.vim",
    "/Users/arturniklewicz/.config/nvim/validate-keybindings.lua"
  }
  
  print("=== EXHAUSTIVE NEOVIM KEYBINDING SCAN ===")
  print("Scanning " .. #files .. " files for ALL keybinding patterns...\n")
  
  -- Scan all files
  for _, filepath in ipairs(files) do
    print("Scanning: " .. filepath:gsub(".*/", ""))
    M.scan_file(filepath)
  end
  
  -- Sort by key then by file
  table.sort(M.all_keybindings, function(a, b)
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
  for _, kb in ipairs(M.all_keybindings) do
    local key_id = kb.mode .. ":" .. kb.key
    if not seen[key_id] then
      seen[key_id] = {kb}
    else
      table.insert(seen[key_id], kb)
      M.duplicates[key_id] = seen[key_id]
    end
  end
  
  -- Print results
  print("\n=== SUMMARY ===")
  print("Total keybindings found: " .. #M.all_keybindings)
  print("Unique key combinations: " .. vim.tbl_count(seen))
  print("Duplicated keys: " .. vim.tbl_count(M.duplicates))
  
  -- Print duplicates
  if vim.tbl_count(M.duplicates) > 0 then
    print("\n=== DUPLICATE KEYBINDINGS ===")
    for key_id, bindings in pairs(M.duplicates) do
      local mode, key = key_id:match("(.-):(.*)")
      print("\n[" .. mode .. "] " .. key .. " - DEFINED " .. #bindings .. " TIMES:")
      for _, binding in ipairs(bindings) do
        print("  • " .. binding.file .. " (line " .. binding.line .. ")")
        print("    Method: " .. binding.method)
        print("    Desc: " .. binding.desc)
        print("    Action: " .. binding.action:sub(1, 50))
      end
    end
  end
  
  -- Create comprehensive matrix
  print("\n=== COMPLETE KEYBINDING MATRIX ===")
  local current_key = nil
  for _, kb in ipairs(M.all_keybindings) do
    if kb.key ~= current_key then
      current_key = kb.key
      print("\n" .. kb.key .. ":")
    end
    local duplicate_marker = ""
    if M.duplicates[kb.mode .. ":" .. kb.key] and #M.duplicates[kb.mode .. ":" .. kb.key] > 1 then
      duplicate_marker = " [DUPLICATE!]"
    end
    print(string.format("  [%s] %-30s | %-25s | %s:%d%s",
      kb.mode,
      kb.desc:sub(1, 30),
      kb.method,
      kb.file:gsub("lua/plugins/", ""),
      kb.line,
      duplicate_marker
    ))
  end
  
  -- Export to file
  local export_file = io.open("/Users/arturniklewicz/.config/nvim/keybinding-analysis.txt", "w")
  if export_file then
    export_file:write("NEOVIM KEYBINDING ANALYSIS REPORT\n")
    export_file:write("Generated: " .. os.date() .. "\n")
    export_file:write("=====================================\n\n")
    
    export_file:write("DUPLICATES:\n")
    for key_id, bindings in pairs(M.duplicates) do
      local mode, key = key_id:match("(.-):(.*)")
      export_file:write("\n[" .. mode .. "] " .. key .. " (" .. #bindings .. " definitions):\n")
      for _, binding in ipairs(bindings) do
        export_file:write("  - " .. binding.file .. ":" .. binding.line .. " (" .. binding.method .. ")\n")
      end
    end
    
    export_file:write("\n\nALL KEYBINDINGS:\n")
    for _, kb in ipairs(M.all_keybindings) do
      export_file:write(string.format("[%s] %s | %s | %s | %s:%d\n",
        kb.mode, kb.key, kb.desc, kb.method, kb.file, kb.line))
    end
    
    export_file:close()
    print("\n\nFull report saved to: keybinding-analysis.txt")
  end
end

-- Run the analysis
M.analyze_all()

return M
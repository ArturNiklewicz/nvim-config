#!/usr/bin/env lua

-- Comprehensive Keybinding Analyzer for Neovim Configuration
-- This script scans ALL files for ALL possible keybinding definition methods

local M = {}

-- Table to store all found keybindings
M.keybindings = {}

-- Pattern definitions for different keybinding methods
M.patterns = {
  -- AstroNvim style: mappings = { n = { ["<key>"] = ... } }
  astro_mappings = {
    pattern = 'mappings%s*=%s*{',
    nested = true,
    name = "AstroNvim mappings"
  },
  
  -- Lazy.nvim style: keys = { { "<key>", ... } }
  lazy_keys = {
    pattern = 'keys%s*=%s*{',
    nested = true,
    name = "Lazy.nvim keys"
  },
  
  -- vim.keymap.set() calls
  vim_keymap_set = {
    pattern = 'vim%.keymap%.set%s*%(',
    nested = false,
    name = "vim.keymap.set"
  },
  
  -- vim.api.nvim_set_keymap() calls
  nvim_set_keymap = {
    pattern = 'vim%.api%.nvim_set_keymap%s*%(',
    nested = false,
    name = "nvim_set_keymap"
  },
  
  -- vim.api.nvim_buf_set_keymap() calls
  nvim_buf_set_keymap = {
    pattern = 'vim%.api%.nvim_buf_set_keymap%s*%(',
    nested = false,
    name = "nvim_buf_set_keymap"
  },
  
  -- map() function calls
  map_function = {
    pattern = 'map%s*%(',
    nested = false,
    name = "map function"
  },
  
  -- on_attach keybindings
  on_attach = {
    pattern = 'on_attach%s*=%s*function',
    nested = true,
    name = "on_attach"
  },
  
  -- config = function() ... end blocks
  config_function = {
    pattern = 'config%s*=%s*function',
    nested = true,
    name = "config function"
  },
  
  -- wk.register() for which-key
  which_key = {
    pattern = 'wk%.register%s*%(',
    nested = false,
    name = "which-key register"
  },
  
  -- Old vim style: :map, :nmap, :vmap, etc.
  vim_command_map = {
    pattern = 'vim%.cmd%s*%[%[%s*[nvixtos]?map',
    nested = false,
    name = "vim command map"
  }
}

-- Function to extract keybinding details from a line
function M.extract_keybinding(line, context, file, line_num)
  local key, mode, desc, action
  
  -- Try to extract key pattern
  local key_patterns = {
    '%["([^"]+)"%]',  -- ["<key>"]
    '%[\'([^\']+)\'%]',  -- ['<key>']
    '"([^"]+)"',  -- "<key>"
    '\'([^\']+)\'',  -- '<key>'
  }
  
  for _, pattern in ipairs(key_patterns) do
    key = line:match(pattern)
    if key then break end
  end
  
  -- Try to extract mode
  local mode_patterns = {
    '["\'](n)["\']',  -- normal
    '["\'](v)["\']',  -- visual
    '["\'](i)["\']',  -- insert
    '["\'](t)["\']',  -- terminal
    '["\'](x)["\']',  -- visual block
    '["\'](s)["\']',  -- select
    '["\'](o)["\']',  -- operator pending
    '["\'](c)["\']',  -- command
  }
  
  -- Extract description
  desc = line:match('desc%s*=%s*["\']([^"\']+)["\']') or
         line:match('description%s*=%s*["\']([^"\']+)["\']') or
         line:match('%-%-%s*(.+)$')  -- comment
  
  return key, mode, desc, action
end

-- Function to read and analyze a file
function M.analyze_file(filepath)
  local file = io.open(filepath, "r")
  if not file then
    print("Error: Cannot open file " .. filepath)
    return
  end
  
  local content = file:read("*all")
  file:close()
  
  local lines = {}
  for line in content:gmatch("[^\n]+") do
    table.insert(lines, line)
  end
  
  -- Track context for multi-line definitions
  local in_context = nil
  local context_depth = 0
  local buffer = ""
  
  for line_num, line in ipairs(lines) do
    -- Check for pattern matches
    for pattern_name, pattern_info in pairs(M.patterns) do
      if line:match(pattern_info.pattern) then
        in_context = pattern_name
        context_depth = 1
        buffer = line
      end
    end
    
    -- If we're in a context, continue building the buffer
    if in_context then
      buffer = buffer .. "\n" .. line
      
      -- Count brackets to determine when context ends
      local open_brackets = select(2, line:gsub("{", ""))
      local close_brackets = select(2, line:gsub("}", ""))
      context_depth = context_depth + open_brackets - close_brackets
      
      -- When context ends, process the buffer
      if context_depth <= 0 then
        local key, mode, desc, action = M.extract_keybinding(buffer, in_context, filepath, line_num)
        if key then
          table.insert(M.keybindings, {
            key = key,
            mode = mode or "?",
            desc = desc or "No description",
            file = filepath:gsub("/Users/arturniklewicz/.config/nvim/", ""),
            line = line_num,
            method = M.patterns[in_context].name,
            raw = buffer:sub(1, 200)  -- First 200 chars
          })
        end
        in_context = nil
        buffer = ""
      end
    end
  end
end

-- Function to analyze all files
function M.analyze_all()
  local files = {
    "init.lua",
    "lua/community.lua",
    "lua/lazy_setup.lua",
    "lua/plugins/astrocore.lua",
    "lua/plugins/astrocore_fixed.lua",
    "lua/plugins/astrocore_keybindings_patch.lua",
    "lua/plugins/astrocore_new_mappings.lua",
    "lua/plugins/astrolsp.lua",
    "lua/plugins/astroui.lua",
    "lua/plugins/bufferline.lua",
    "lua/plugins/claudecode.lua",
    "lua/plugins/error-messages.lua",
    "lua/plugins/fugitive.lua",
    "lua/plugins/gitsigns.lua",
    "lua/plugins/keybind-help.lua",
    "lua/plugins/markdown-preview.lua",
    "lua/plugins/mason.lua",
    "lua/plugins/molten.lua",
    "lua/plugins/neo-tree.lua",
    "lua/plugins/none-ls.lua",
    "lua/plugins/octo.lua",
    "lua/plugins/text-objects.lua",
    "lua/plugins/treesitter.lua",
    "lua/plugins/user.lua",
    "lua/plugins/vscode-editing.lua",
    "lua/plugins/which-key-groups.lua",
    "lua/plugins/which-key.lua",
    "lua/plugins/zen-mode.lua",
    "lua/polish.lua",
    "lua/utils/buffer-nav.lua",
    "lua/utils/git-monitor.lua",
    "lua/plugins/astrocore.lua.bak",
    "plugin/tmux-swap.vim",
    "validate-keybindings.lua"
  }
  
  local base_path = "/Users/arturniklewicz/.config/nvim/"
  
  print("=== NEOVIM KEYBINDING ANALYSIS ===")
  print("Scanning " .. #files .. " files...\n")
  
  for _, file in ipairs(files) do
    M.analyze_file(base_path .. file)
  end
  
  -- Sort keybindings by key for easier analysis
  table.sort(M.keybindings, function(a, b)
    if a.key == b.key then
      return a.file < b.file
    end
    return a.key < b.key
  end)
  
  -- Find duplicates
  local duplicates = {}
  local seen = {}
  
  for _, kb in ipairs(M.keybindings) do
    local key_mode = kb.key .. "|" .. kb.mode
    if seen[key_mode] then
      if not duplicates[key_mode] then
        duplicates[key_mode] = { seen[key_mode] }
      end
      table.insert(duplicates[key_mode], kb)
    else
      seen[key_mode] = kb
    end
  end
  
  -- Print summary
  print("\n=== SUMMARY ===")
  print("Total keybindings found: " .. #M.keybindings)
  print("Duplicate keys: " .. vim.tbl_count(duplicates))
  
  -- Print duplicates
  if vim.tbl_count(duplicates) > 0 then
    print("\n=== DUPLICATES ===")
    for key_mode, dups in pairs(duplicates) do
      local key, mode = key_mode:match("(.+)|(.+)")
      print("\nKey: " .. key .. " (mode: " .. mode .. ")")
      for _, dup in ipairs(dups) do
        print("  - " .. dup.file .. ":" .. dup.line .. " (" .. dup.method .. ")")
        print("    Desc: " .. dup.desc)
      end
    end
  end
  
  -- Print all keybindings
  print("\n=== ALL KEYBINDINGS ===")
  local current_key = nil
  for _, kb in ipairs(M.keybindings) do
    if kb.key ~= current_key then
      current_key = kb.key
      print("\n" .. kb.key .. ":")
    end
    print(string.format("  [%s] %s - %s:%d (%s)",
      kb.mode, kb.desc, kb.file, kb.line, kb.method))
  end
end

-- Run the analysis
M.analyze_all()

return M
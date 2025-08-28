-- Diff parser module for AI commit message generation
-- Efficient single-pass parsing of git diffs into structured data

local M = {}
local Config = require('utils.ai-commit.config')
local Logger = require('utils.ai-commit.logger')

-- Parse git diff into structured data
function M.parse(diff)
  Logger.debug("Starting diff parse of " .. #diff .. " bytes")
  
  local result = {
    files = {},
    stats = {
      total_additions = 0,
      total_deletions = 0,
      files_changed = 0,
      binary_files = 0
    },
    functions = {
      added = {},
      removed = {},
      modified = {}
    },
    imports = {
      added = {},
      removed = {}
    },
    config_changes = {},
    keymap_changes = {},
    hunks = {}
  }
  
  local current_file = nil
  local current_hunk = nil
  local line_number = 0
  
  -- Single pass through diff
  for line in diff:gmatch("[^\n]+") do
    line_number = line_number + 1
    
    -- File header
    if line:match("^diff %-%-git") then
      local old_path, new_path = line:match("a/(.+) b/(.+)")
      if old_path and new_path then
        current_file = new_path
        result.files[current_file] = {
          old_path = old_path,
          new_path = new_path,
          additions = 0,
          deletions = 0,
          hunks = {},
          is_new = false,
          is_deleted = false,
          is_renamed = false,
          is_binary = false
        }
        result.stats.files_changed = result.stats.files_changed + 1
      end
      
    -- Binary file detection
    elseif line:match("^Binary files") then
      if current_file then
        result.files[current_file].is_binary = true
        result.stats.binary_files = result.stats.binary_files + 1
      end
      
    -- New file detection
    elseif line:match("^new file mode") then
      if current_file then
        result.files[current_file].is_new = true
      end
      
    -- Deleted file detection
    elseif line:match("^deleted file mode") then
      if current_file then
        result.files[current_file].is_deleted = true
      end
      
    -- Renamed file detection
    elseif line:match("^rename from") then
      if current_file then
        result.files[current_file].is_renamed = true
        result.files[current_file].old_name = line:match("rename from (.+)")
      end
      
    -- Hunk header
    elseif line:match("^@@") then
      local old_start, old_count, new_start, new_count = line:match("@@%s%-(%d+),?(%d*)%s%+(%d+),?(%d*)%s@@")
      if old_start and new_start then
        current_hunk = {
          old_start = tonumber(old_start),
          old_count = tonumber(old_count) or 1,
          new_start = tonumber(new_start),
          new_count = tonumber(new_count) or 1,
          context = line:match("@@.*@@%s*(.*)"),
          additions = 0,
          deletions = 0
        }
        if current_file and result.files[current_file] then
          table.insert(result.files[current_file].hunks, current_hunk)
        end
        table.insert(result.hunks, current_hunk)
      end
      
    -- Addition line
    elseif line:match("^%+") and not line:match("^%+%+%+") then
      if current_file and result.files[current_file] then
        result.files[current_file].additions = result.files[current_file].additions + 1
        result.stats.total_additions = result.stats.total_additions + 1
        
        if current_hunk then
          current_hunk.additions = current_hunk.additions + 1
        end
        
        -- Parse line content
        local content = line:sub(2)
        M.parse_addition(content, current_file, result)
      end
      
    -- Deletion line
    elseif line:match("^%-") and not line:match("^%-%-%-") then
      if current_file and result.files[current_file] then
        result.files[current_file].deletions = result.files[current_file].deletions + 1
        result.stats.total_deletions = result.stats.total_deletions + 1
        
        if current_hunk then
          current_hunk.deletions = current_hunk.deletions + 1
        end
        
        -- Parse line content
        local content = line:sub(2)
        M.parse_deletion(content, current_file, result)
      end
    end
  end
  
  Logger.debug_table("Parsed diff result", result.stats)
  return result
end

-- Parse added line for specific patterns
function M.parse_addition(content, filepath, result)
  -- Skip empty or comment lines
  if content:match("^%s*$") or content:match("^%s*#") or content:match("^%s*//") then
    return
  end
  
  -- Get patterns for this file type
  local patterns = Config.get_patterns_for_file(filepath)
  
  -- Check for function additions
  if patterns.functions then
    for _, pattern in ipairs(patterns.functions) do
      local func_name = content:match(pattern)
      if func_name and not vim.tbl_contains(result.functions.added, func_name) then
        table.insert(result.functions.added, func_name)
        Logger.debug("Found added function: " .. func_name)
        break
      end
    end
  end
  
  -- Check for import additions
  if patterns.imports then
    for _, pattern in ipairs(patterns.imports) do
      local import_name = content:match(pattern)
      if import_name and not vim.tbl_contains(result.imports.added, import_name) then
        table.insert(result.imports.added, import_name)
        Logger.debug("Found added import: " .. import_name)
        break
      end
    end
  end
  
  -- Check for configuration changes
  local config_patterns = Config.get('patterns').config
  for _, pattern in ipairs(config_patterns) do
    if content:match(pattern) then
      local config_type = content:match("([%w_]+)%s*=") or "configuration"
      if not vim.tbl_contains(result.config_changes, config_type) then
        table.insert(result.config_changes, config_type)
        Logger.debug("Found config change: " .. config_type)
      end
      break
    end
  end
  
  -- Check for keymap changes
  local keymap_patterns = Config.get('patterns').keymaps
  for _, pattern in ipairs(keymap_patterns) do
    if content:match(pattern) then
      local key = content:match("['\"](<[^>]+>)['\"]") or 
                 content:match("['\"]([^'\"]+)['\"]")
      if key and not vim.tbl_contains(result.keymap_changes, key) then
        table.insert(result.keymap_changes, key)
        Logger.debug("Found keymap change: " .. key)
      end
      break
    end
  end
end

-- Parse deleted line for specific patterns
function M.parse_deletion(content, filepath, result)
  -- Skip empty or comment lines
  if content:match("^%s*$") or content:match("^%s*#") or content:match("^%s*//") then
    return
  end
  
  -- Get patterns for this file type
  local patterns = Config.get_patterns_for_file(filepath)
  
  -- Check for function removals
  if patterns.functions then
    for _, pattern in ipairs(patterns.functions) do
      local func_name = content:match(pattern)
      if func_name and not vim.tbl_contains(result.functions.removed, func_name) then
        table.insert(result.functions.removed, func_name)
        Logger.debug("Found removed function: " .. func_name)
        break
      end
    end
  end
  
  -- Check for import removals
  if patterns.imports then
    for _, pattern in ipairs(patterns.imports) do
      local import_name = content:match(pattern)
      if import_name and not vim.tbl_contains(result.imports.removed, import_name) then
        table.insert(result.imports.removed, import_name)
        Logger.debug("Found removed import: " .. import_name)
        break
      end
    end
  end
end

-- Get file type from path
function M.get_file_type(filepath)
  local ext = filepath:match("%.([^%.]+)$")
  if not ext then return "unknown" end
  
  local type_map = {
    lua = "lua",
    py = "python",
    js = "javascript",
    ts = "typescript",
    jsx = "javascript",
    tsx = "typescript",
    vue = "vue",
    md = "markdown",
    json = "json",
    yaml = "yaml",
    yml = "yaml",
    toml = "toml",
    sh = "shell",
    bash = "shell",
    zsh = "shell",
  }
  
  return type_map[ext] or ext
end

-- Check if file is a test file
function M.is_test_file(filepath)
  return filepath:match("test") or 
         filepath:match("spec") or 
         filepath:match("%.test%.") or 
         filepath:match("%.spec%.")
end

-- Check if file is documentation
function M.is_doc_file(filepath)
  return filepath:match("%.md$") or 
         filepath:match("%.rst$") or 
         filepath:match("%.txt$") or 
         filepath:match("README") or 
         filepath:match("CHANGELOG") or 
         filepath:match("LICENSE")
end

-- Check if file is configuration
function M.is_config_file(filepath)
  return filepath:match("config") or 
         filepath:match("%.conf") or 
         filepath:match("%.ini") or 
         filepath:match("%.json$") or 
         filepath:match("%.yaml$") or 
         filepath:match("%.yml$") or 
         filepath:match("%.toml$") or 
         filepath:match("rc$")
end

return M
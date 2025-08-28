-- Commit analyzer module for AI commit message generation
-- Analyzes parsed diff data to determine commit type, scope, and context

local M = {}
local Config = require('utils.ai-commit.config')
local Logger = require('utils.ai-commit.logger')
local DiffParser = require('utils.ai-commit.diff-parser')

-- Analyze parsed diff to determine commit type and scope
function M.analyze(parsed_diff)
  Logger.debug("Starting commit analysis")
  
  local analysis = {
    type = "chore",
    scope = nil,
    breaking = false,
    description = "",
    context = {
      is_feature = false,
      is_fix = false,
      is_refactor = false,
      is_docs = false,
      is_test = false,
      is_config = false,
      is_style = false,
      is_performance = false
    },
    summary = {
      primary_change = nil,
      secondary_changes = {},
      affected_areas = {}
    }
  }
  
  -- Analyze file types and determine scope
  analysis.scope = M.determine_scope(parsed_diff.files)
  
  -- Analyze change patterns to determine commit type
  analysis.type = M.determine_commit_type(parsed_diff)
  
  -- Check for breaking changes
  analysis.breaking = M.detect_breaking_changes(parsed_diff)
  
  -- Generate description based on changes
  analysis.description = M.generate_description(parsed_diff, analysis.type)
  
  -- Analyze context for additional information
  analysis.context = M.analyze_context(parsed_diff)
  
  -- Create summary of changes
  analysis.summary = M.create_summary(parsed_diff)
  
  Logger.debug_table("Commit analysis result", analysis)
  return analysis
end

-- Basic analysis fallback
function M.basic_analysis(parsed_diff)
  return {
    type = "chore",
    scope = nil,
    breaking = false,
    description = "update files",
    context = {},
    summary = {
      primary_change = "general updates",
      secondary_changes = {},
      affected_areas = {}
    }
  }
end

-- Determine scope from files
function M.determine_scope(files)
  if not files or vim.tbl_isempty(files) then
    return nil
  end
  
  local scope_counts = {}
  local scope_rules = Config.get('scope_rules')
  
  for filepath, _ in pairs(files) do
    -- Check against scope rules
    for _, rule in ipairs(scope_rules) do
      if filepath:match(rule.pattern) then
        scope_counts[rule.scope] = (scope_counts[rule.scope] or 0) + 1
        break
      end
    end
    
    -- Extract directory-based scope
    local dir = filepath:match("^([^/]+)/")
    if dir and not dir:match("%.") then
      scope_counts[dir] = (scope_counts[dir] or 0) + 1
    end
  end
  
  -- Find most common scope
  local max_count = 0
  local selected_scope = nil
  for scope, count in pairs(scope_counts) do
    if count > max_count then
      max_count = count
      selected_scope = scope
    end
  end
  
  -- Clean up scope name
  if selected_scope and #selected_scope <= 15 then
    return selected_scope
  end
  
  return nil
end

-- Determine commit type based on changes
function M.determine_commit_type(parsed_diff)
  local funcs = parsed_diff.functions
  local imports = parsed_diff.imports
  local config = parsed_diff.config_changes
  local keymaps = parsed_diff.keymap_changes
  local stats = parsed_diff.stats
  
  -- Priority-based type determination
  
  -- Check for new features
  if #funcs.added > 0 and #funcs.removed == 0 then
    Logger.debug("Type: feat - new functions added")
    return "feat"
  end
  
  -- Check for fixes (heuristic based on patterns and small changes)
  if stats.total_additions < 10 and stats.total_deletions < 10 then
    for filepath, file_data in pairs(parsed_diff.files) do
      if filepath:match("fix") or filepath:match("bug") then
        Logger.debug("Type: fix - fix pattern in filename")
        return "fix"
      end
    end
  end
  
  -- Check for refactoring
  if #funcs.added > 0 and #funcs.removed > 0 then
    Logger.debug("Type: refactor - functions replaced")
    return "refactor"
  end
  
  if #funcs.removed > 0 and #funcs.added == 0 then
    Logger.debug("Type: refactor - functions removed")
    return "refactor"
  end
  
  -- Check for documentation
  local doc_files = 0
  for filepath, _ in pairs(parsed_diff.files) do
    if DiffParser.is_doc_file(filepath) then
      doc_files = doc_files + 1
    end
  end
  if doc_files > 0 and doc_files >= stats.files_changed / 2 then
    Logger.debug("Type: docs - documentation files changed")
    return "docs"
  end
  
  -- Check for tests
  local test_files = 0
  for filepath, _ in pairs(parsed_diff.files) do
    if DiffParser.is_test_file(filepath) then
      test_files = test_files + 1
    end
  end
  if test_files > 0 and test_files >= stats.files_changed / 2 then
    Logger.debug("Type: test - test files changed")
    return "test"
  end
  
  -- Check for configuration changes
  if #config > 0 or #keymaps > 0 then
    Logger.debug("Type: feat - configuration/keymaps changed")
    return "feat"
  end
  
  -- Check for style changes (formatting only)
  if stats.total_additions == stats.total_deletions then
    Logger.debug("Type: style - equal additions/deletions")
    return "style"
  end
  
  -- Check for build/dependency changes
  for filepath, _ in pairs(parsed_diff.files) do
    if filepath:match("package%.json") or 
       filepath:match("Cargo%.toml") or 
       filepath:match("requirements%.txt") or
       filepath:match("go%.mod") then
      Logger.debug("Type: build - dependency file changed")
      return "build"
    end
  end
  
  -- Default to chore for maintenance tasks
  Logger.debug("Type: chore - default")
  return "chore"
end

-- Generate description based on changes
function M.generate_description(parsed_diff, commit_type)
  local funcs = parsed_diff.functions
  local imports = parsed_diff.imports
  local config = parsed_diff.config_changes
  local keymaps = parsed_diff.keymap_changes
  local stats = parsed_diff.stats
  
  -- Type-specific descriptions
  if commit_type == "feat" then
    if #funcs.added == 1 then
      return string.format("implement %s functionality", funcs.added[1])
    elseif #funcs.added > 1 then
      return string.format("add %d new functions for enhanced capabilities", #funcs.added)
    elseif #config > 0 then
      return string.format("enhance configuration with %s settings", table.concat(config, ", "))
    elseif #keymaps > 0 then
      return string.format("add %d new keybindings for improved workflow", #keymaps)
    elseif #imports.added > 0 then
      return string.format("integrate %s for extended functionality", imports.added[1])
    else
      return "add new functionality and improvements"
    end
    
  elseif commit_type == "fix" then
    if #funcs.modified > 0 then
      return string.format("resolve issues in %s", funcs.modified[1])
    else
      return "resolve issues and improve stability"
    end
    
  elseif commit_type == "refactor" then
    if #funcs.removed == 1 then
      return string.format("remove %s and optimize code structure", funcs.removed[1])
    elseif #funcs.removed > 1 then
      return string.format("restructure code by removing %d deprecated functions", #funcs.removed)
    elseif #funcs.added > 0 and #funcs.removed > 0 then
      return "restructure implementation with improved architecture"
    else
      return "improve code organization and maintainability"
    end
    
  elseif commit_type == "docs" then
    return "update documentation with clarifications and examples"
    
  elseif commit_type == "test" then
    return "enhance test coverage and reliability"
    
  elseif commit_type == "style" then
    return "improve code formatting and consistency"
    
  elseif commit_type == "build" then
    return "update build configuration and dependencies"
    
  else
    -- Chore or default
    if stats.files_changed == 1 then
      local filepath = next(parsed_diff.files)
      local filename = filepath:match("([^/]+)$") or filepath
      return string.format("update %s", filename)
    else
      return string.format("update %d files with various improvements", stats.files_changed)
    end
  end
end

-- Detect breaking changes
function M.detect_breaking_changes(parsed_diff)
  -- Check for removed functions (potential breaking change)
  if #parsed_diff.functions.removed > 0 then
    Logger.debug("Breaking change detected: functions removed")
    return true
  end
  
  -- Check for removed exports/public APIs
  for _, import in ipairs(parsed_diff.imports.removed) do
    if import:match("export") or import:match("public") then
      Logger.debug("Breaking change detected: public API removed")
      return true
    end
  end
  
  -- Check for major version bumps in package files
  for filepath, _ in pairs(parsed_diff.files) do
    if filepath:match("package%.json") or filepath:match("Cargo%.toml") then
      -- This would need more sophisticated checking of actual version changes
      Logger.debug("Potential breaking change: package file modified")
    end
  end
  
  return false
end

-- Analyze context for additional information
function M.analyze_context(parsed_diff)
  local context = {
    is_feature = false,
    is_fix = false,
    is_refactor = false,
    is_docs = false,
    is_test = false,
    is_config = false,
    is_style = false,
    is_performance = false,
    has_breaking_changes = false,
    complexity = "simple"  -- simple, moderate, complex
  }
  
  -- Determine complexity based on change size
  local total_changes = parsed_diff.stats.total_additions + parsed_diff.stats.total_deletions
  if total_changes > 500 then
    context.complexity = "complex"
  elseif total_changes > 100 then
    context.complexity = "moderate"
  else
    context.complexity = "simple"
  end
  
  -- Set context flags based on changes
  context.is_feature = #parsed_diff.functions.added > 0
  context.is_refactor = #parsed_diff.functions.removed > 0
  context.is_config = #parsed_diff.config_changes > 0
  context.has_breaking_changes = M.detect_breaking_changes(parsed_diff)
  
  -- Check for specific file types
  for filepath, _ in pairs(parsed_diff.files) do
    if DiffParser.is_doc_file(filepath) then
      context.is_docs = true
    end
    if DiffParser.is_test_file(filepath) then
      context.is_test = true
    end
    if DiffParser.is_config_file(filepath) then
      context.is_config = true
    end
  end
  
  return context
end

-- Create summary of changes
function M.create_summary(parsed_diff)
  local summary = {
    primary_change = nil,
    secondary_changes = {},
    affected_areas = {}
  }
  
  -- Determine primary change
  if #parsed_diff.functions.added > 0 then
    summary.primary_change = string.format("Added %d new functions", #parsed_diff.functions.added)
  elseif #parsed_diff.functions.removed > 0 then
    summary.primary_change = string.format("Removed %d functions", #parsed_diff.functions.removed)
  elseif #parsed_diff.config_changes > 0 then
    summary.primary_change = "Configuration updates"
  elseif parsed_diff.stats.files_changed > 0 then
    summary.primary_change = string.format("Modified %d files", parsed_diff.stats.files_changed)
  end
  
  -- Add secondary changes
  if #parsed_diff.imports.added > 0 then
    table.insert(summary.secondary_changes, string.format("Added %d imports", #parsed_diff.imports.added))
  end
  if #parsed_diff.keymap_changes > 0 then
    table.insert(summary.secondary_changes, string.format("Modified %d keybindings", #parsed_diff.keymap_changes))
  end
  
  -- Identify affected areas
  for filepath, _ in pairs(parsed_diff.files) do
    local area = filepath:match("^([^/]+)") or "root"
    if not vim.tbl_contains(summary.affected_areas, area) then
      table.insert(summary.affected_areas, area)
    end
  end
  
  return summary
end

return M
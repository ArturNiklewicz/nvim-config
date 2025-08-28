-- Message builder module for AI commit message generation
-- Constructs formatted commit messages from analysis data

local M = {}
local Config = require('utils.ai-commit.config')
local Logger = require('utils.ai-commit.logger')

-- Build commit message from analysis and parsed diff
function M.build(analysis, parsed_diff)
  Logger.debug("Building commit message")
  
  local lines = {}
  
  -- Build subject line
  local subject = M.build_subject(analysis)
  table.insert(lines, subject)
  
  -- Add empty line after subject
  table.insert(lines, "")
  
  -- Build body based on configuration
  if Config.get('include_stats') or Config.get('include_file_list') then
    local body_lines = M.build_body(analysis, parsed_diff)
    for _, line in ipairs(body_lines) do
      table.insert(lines, line)
    end
  end
  
  -- Add footer if needed
  local footer_lines = M.build_footer(analysis, parsed_diff)
  if #footer_lines > 0 then
    table.insert(lines, "")
    for _, line in ipairs(footer_lines) do
      table.insert(lines, line)
    end
  end
  
  Logger.debug("Built message with " .. #lines .. " lines")
  return lines
end

-- Build subject line
function M.build_subject(analysis)
  local type_str = analysis.type
  local scope_str = ""
  local description = analysis.description
  
  -- Add emoji if configured
  if Config.get('use_emoji') then
    local commit_types = Config.get('commit_types')
    if commit_types[analysis.type] and commit_types[analysis.type].emoji then
      type_str = commit_types[analysis.type].emoji .. " " .. type_str
    end
  end
  
  -- Add scope if present
  if analysis.scope then
    scope_str = "(" .. analysis.scope .. ")"
  end
  
  -- Format subject line
  local subject = string.format("%s%s: %s", type_str, scope_str, description)
  
  -- Ensure subject line length limit
  local max_length = 72
  if #subject > max_length then
    -- Truncate description to fit
    local prefix_length = #type_str + #scope_str + 2  -- +2 for ": "
    local max_desc_length = max_length - prefix_length - 3  -- -3 for "..."
    if max_desc_length > 10 then
      description = description:sub(1, max_desc_length) .. "..."
      subject = string.format("%s%s: %s", type_str, scope_str, description)
    end
  end
  
  return subject
end

-- Build message body
function M.build_body(analysis, parsed_diff)
  local lines = {}
  
  -- Add change summary if configured
  if Config.get('include_stats') then
    local stats_lines = M.build_stats_section(parsed_diff.stats)
    for _, line in ipairs(stats_lines) do
      table.insert(lines, line)
    end
    if #stats_lines > 0 then
      table.insert(lines, "")
    end
  end
  
  -- Add detailed changes based on analysis context
  if analysis.context.complexity ~= "simple" then
    local detail_lines = M.build_details_section(analysis, parsed_diff)
    for _, line in ipairs(detail_lines) do
      table.insert(lines, line)
    end
    if #detail_lines > 0 then
      table.insert(lines, "")
    end
  end
  
  -- Add file list if configured
  if Config.get('include_file_list') then
    local file_lines = M.build_files_section(parsed_diff.files)
    for _, line in ipairs(file_lines) do
      table.insert(lines, line)
    end
  end
  
  return lines
end

-- Build statistics section
function M.build_stats_section(stats)
  local lines = {}
  
  if stats.files_changed > 0 then
    table.insert(lines, string.format(
      "Changes: +%d/-%d lines across %d files",
      stats.total_additions,
      stats.total_deletions,
      stats.files_changed
    ))
  end
  
  if stats.binary_files > 0 then
    table.insert(lines, string.format("Binary files: %d", stats.binary_files))
  end
  
  return lines
end

-- Build details section
function M.build_details_section(analysis, parsed_diff)
  local lines = {}
  
  -- Add function changes
  if #parsed_diff.functions.added > 0 then
    table.insert(lines, "Added functions:")
    for i, func in ipairs(parsed_diff.functions.added) do
      if i <= 5 then  -- Limit to first 5
        table.insert(lines, string.format("- %s() for enhanced functionality", func))
      elseif i == 6 then
        table.insert(lines, string.format("- ... and %d more", #parsed_diff.functions.added - 5))
        break
      end
    end
    table.insert(lines, "")
  end
  
  if #parsed_diff.functions.removed > 0 then
    table.insert(lines, "Removed functions:")
    for i, func in ipairs(parsed_diff.functions.removed) do
      if i <= 5 then
        table.insert(lines, string.format("- %s() (deprecated/replaced)", func))
      elseif i == 6 then
        table.insert(lines, string.format("- ... and %d more", #parsed_diff.functions.removed - 5))
        break
      end
    end
    table.insert(lines, "")
  end
  
  -- Add configuration changes
  if #parsed_diff.config_changes > 0 then
    table.insert(lines, "Configuration updates:")
    local unique_configs = {}
    for _, config in ipairs(parsed_diff.config_changes) do
      if not unique_configs[config] then
        unique_configs[config] = true
        table.insert(lines, string.format("- Enhanced %s settings", config))
      end
    end
    table.insert(lines, "")
  end
  
  -- Add keymap changes
  if #parsed_diff.keymap_changes > 0 then
    table.insert(lines, "Keybinding updates:")
    for i, key in ipairs(parsed_diff.keymap_changes) do
      if i <= 5 then
        table.insert(lines, string.format("- %s mapping", key))
      elseif i == 6 then
        table.insert(lines, string.format("- ... and %d more", #parsed_diff.keymap_changes - 5))
        break
      end
    end
    table.insert(lines, "")
  end
  
  -- Add import changes
  if #parsed_diff.imports.added > 0 then
    table.insert(lines, "New dependencies:")
    for i, import in ipairs(parsed_diff.imports.added) do
      if i <= 3 then
        table.insert(lines, string.format("- %s integration", import))
      elseif i == 4 then
        table.insert(lines, string.format("- ... and %d more", #parsed_diff.imports.added - 3))
        break
      end
    end
    table.insert(lines, "")
  end
  
  -- Add primary change summary if available
  if analysis.summary.primary_change then
    table.insert(lines, "Primary change: " .. analysis.summary.primary_change)
    if #analysis.summary.secondary_changes > 0 then
      for _, change in ipairs(analysis.summary.secondary_changes) do
        table.insert(lines, "- " .. change)
      end
    end
    table.insert(lines, "")
  end
  
  return lines
end

-- Build files section
function M.build_files_section(files)
  local lines = {}
  local file_list = {}
  
  -- Convert to list and sort
  for filepath, data in pairs(files) do
    table.insert(file_list, {
      path = filepath,
      additions = data.additions,
      deletions = data.deletions,
      is_new = data.is_new,
      is_deleted = data.is_deleted,
      is_binary = data.is_binary
    })
  end
  
  -- Sort by change size (additions + deletions)
  table.sort(file_list, function(a, b)
    return (a.additions + a.deletions) > (b.additions + b.deletions)
  end)
  
  local max_files = Config.get('max_files_to_show') or 5
  
  if #file_list > 0 then
    table.insert(lines, "Modified files:")
    for i, file in ipairs(file_list) do
      if i <= max_files then
        local status = ""
        if file.is_new then
          status = " (new)"
        elseif file.is_deleted then
          status = " (deleted)"
        elseif file.is_binary then
          status = " (binary)"
        end
        
        table.insert(lines, string.format(
          "- %s (+%d/-%d)%s",
          file.path,
          file.additions,
          file.deletions,
          status
        ))
      elseif i == max_files + 1 then
        table.insert(lines, string.format("- ... and %d more files", #file_list - max_files))
        break
      end
    end
  end
  
  return lines
end

-- Build footer section
function M.build_footer(analysis, parsed_diff)
  local lines = {}
  
  -- Add breaking change notice
  if analysis.breaking or analysis.context.has_breaking_changes then
    table.insert(lines, "BREAKING CHANGE: This commit includes breaking changes")
    table.insert(lines, "Please review the changes carefully before updating")
  end
  
  -- Add references (would need to be extracted from diff or provided)
  -- Example: Fixes #123, Closes #456
  
  -- Add co-authors if configured
  -- Example: Co-authored-by: Name <email>
  
  return lines
end

-- Format message with template
function M.format_with_template(analysis, body_lines, footer_lines)
  local template = Config.get('commit_template')
  
  -- Build components
  local type_str = analysis.type
  local scope_str = analysis.scope and "(" .. analysis.scope .. ")" or ""
  local description = analysis.description
  local body = table.concat(body_lines, "\n")
  local footer = table.concat(footer_lines, "\n")
  
  -- Replace template variables
  local message = template
  message = message:gsub("{type}", type_str)
  message = message:gsub("{scope}", scope_str)
  message = message:gsub("{description}", description)
  message = message:gsub("{body}", body)
  message = message:gsub("{footer}", footer)
  
  -- Clean up empty lines
  message = message:gsub("\n\n\n+", "\n\n")
  message = message:gsub("^%s+", "")
  message = message:gsub("%s+$", "")
  
  return vim.split(message, "\n")
end

return M
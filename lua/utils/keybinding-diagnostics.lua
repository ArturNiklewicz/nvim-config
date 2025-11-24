-- Keybinding Diagnostics Tool
-- Run with: :lua require('utils.keybinding-diagnostics').run_full_audit()

local M = {}

-- Check if a mapping has a description
local function has_desc(mapping)
  return mapping.desc and mapping.desc ~= ""
end

-- Get all keymaps for a specific mode
local function get_mode_keymaps(mode)
  return vim.api.nvim_get_keymap(mode)
end

-- Check for missing descriptions in leader mappings
function M.check_missing_descriptions()
  local issues = {}
  local modes = { "n", "v", "x", "s", "o", "i" }

  for _, mode in ipairs(modes) do
    local maps = get_mode_keymaps(mode)
    for _, map in ipairs(maps) do
      if map.lhs:match("^<Leader>") or map.lhs:match("^<Space>") then
        if not has_desc(map) then
          table.insert(issues, {
            mode = mode,
            lhs = map.lhs,
            rhs = map.rhs or map.callback and "<function>" or "<unknown>",
            from = map.from or "unknown",
          })
        end
      end
    end
  end

  return issues
end

-- Check for missing which-key group names
function M.check_missing_group_names()
  local issues = {}
  local leader_prefixes = {}
  local modes = { "n", "v", "x" }

  -- Collect all leader key prefixes
  for _, mode in ipairs(modes) do
    local maps = get_mode_keymaps(mode)
    for _, map in ipairs(maps) do
      if map.lhs:match("^<Leader>") or map.lhs:match("^<Space>") then
        -- Extract the prefix (e.g., "<Leader>g" from "<Leader>gd")
        local prefix = map.lhs:match("^(<Leader>%a)")
        if prefix and #prefix == 9 then -- <Leader>X is 9 chars
          leader_prefixes[mode] = leader_prefixes[mode] or {}
          leader_prefixes[mode][prefix] = true
        end
      end
    end
  end

  -- Check if each prefix has a name registration
  for mode, prefixes in pairs(leader_prefixes) do
    for prefix, _ in pairs(prefixes) do
      local has_name = false
      local maps = get_mode_keymaps(mode)
      for _, map in ipairs(maps) do
        if map.lhs == prefix and map.desc and map.desc ~= "" then
          has_name = true
          break
        end
      end

      if not has_name then
        table.insert(issues, {
          mode = mode,
          prefix = prefix,
          suggestion = string.format('Add: ["%s"] = { name = "..." } to astrocore.lua mappings', prefix),
        })
      end
    end
  end

  return issues
end

-- Check for keybinding conflicts
function M.check_conflicts()
  local conflicts = {}
  local seen = {}
  local modes = { "n", "v", "x", "s", "o", "i", "c", "t" }

  for _, mode in ipairs(modes) do
    local maps = get_mode_keymaps(mode)
    for _, map in ipairs(maps) do
      local key = mode .. ":" .. map.lhs
      if seen[key] then
        table.insert(conflicts, {
          mode = mode,
          lhs = map.lhs,
          first = seen[key].from or "unknown",
          second = map.from or "unknown",
        })
      else
        seen[key] = map
      end
    end
  end

  return conflicts
end

-- Check for buffer-local mappings
function M.check_buffer_local_mappings()
  local buffer_maps = {}
  local modes = { "n", "v", "x", "s", "o", "i" }

  for _, mode in ipairs(modes) do
    local maps = vim.api.nvim_buf_get_keymap(0, mode)
    for _, map in ipairs(maps) do
      if map.lhs:match("^<Leader>") or map.lhs:match("^<Space>") then
        table.insert(buffer_maps, {
          mode = mode,
          lhs = map.lhs,
          desc = map.desc or "<no description>",
          filetype = vim.bo.filetype,
        })
      end
    end
  end

  return buffer_maps
end

-- Check for keybindings that don't work (can't be tested automatically, but we can list them)
function M.list_all_leader_keybindings()
  local all_bindings = {}
  local modes = { "n", "v", "x", "s", "o", "i" }

  for _, mode in ipairs(modes) do
    local maps = get_mode_keymaps(mode)
    for _, map in ipairs(maps) do
      if map.lhs:match("^<Leader>") or map.lhs:match("^<Space>") then
        table.insert(all_bindings, {
          mode = mode,
          lhs = map.lhs,
          desc = map.desc or "<no description>",
          rhs = map.rhs or map.callback and "<function>" or "<unknown>",
          from = map.from or "unknown",
        })
      end
    end
  end

  -- Sort by lhs
  table.sort(all_bindings, function(a, b)
    return a.lhs < b.lhs
  end)

  return all_bindings
end

-- Print formatted report
local function print_section(title, items, formatter)
  if #items == 0 then
    print(string.format("\n✅ %s: No issues found", title))
    return
  end

  print(string.format("\n❌ %s: %d issue(s) found", title, #items))
  print(string.rep("=", 80))
  for i, item in ipairs(items) do
    print(string.format("%d. %s", i, formatter(item)))
  end
end

-- Run full audit and print report
function M.run_full_audit()
  print("\n" .. string.rep("=", 80))
  print("KEYBINDING DIAGNOSTICS REPORT")
  print(string.rep("=", 80))

  -- Check 1: Missing descriptions
  local missing_desc = M.check_missing_descriptions()
  print_section("Missing Descriptions in Leader Mappings", missing_desc, function(item)
    return string.format("[%s] %s → %s (from: %s)", item.mode, item.lhs, item.rhs, item.from)
  end)

  -- Check 2: Missing group names
  local missing_groups = M.check_missing_group_names()
  print_section("Missing which-key Group Names", missing_groups, function(item)
    return string.format("[%s] %s - %s", item.mode, item.prefix, item.suggestion)
  end)

  -- Check 3: Conflicts
  local conflicts = M.check_conflicts()
  print_section("Keybinding Conflicts", conflicts, function(item)
    return string.format("[%s] %s - conflict between '%s' and '%s'", item.mode, item.lhs, item.first, item.second)
  end)

  -- Check 4: Buffer-local mappings
  local buffer_maps = M.check_buffer_local_mappings()
  print_section("Buffer-Local Leader Mappings (current buffer)", buffer_maps, function(item)
    return string.format("[%s] %s - %s (filetype: %s)", item.mode, item.lhs, item.desc, item.filetype)
  end)

  -- Summary
  print("\n" .. string.rep("=", 80))
  print("SUMMARY")
  print(string.rep("=", 80))
  print(string.format("Total issues found: %d", #missing_desc + #missing_groups + #conflicts))
  print(string.format("  - Missing descriptions: %d", #missing_desc))
  print(string.format("  - Missing group names: %d", #missing_groups))
  print(string.format("  - Conflicts: %d", #conflicts))
  print(string.format("  - Buffer-local mappings: %d", #buffer_maps))

  print("\n" .. string.rep("=", 80))
  print("RECOMMENDED ACTIONS")
  print(string.rep("=", 80))
  print("1. Run :checkhealth which-key to see which-key specific issues")
  print("2. Add 'desc' fields to all mappings without descriptions")
  print("3. Add 'name' keys for missing group prefixes")
  print("4. Resolve any conflicts by choosing which mapping to keep")
  print("5. Document buffer-local mappings in plugin configs")
  print("\nFor detailed cleanup guide, see: docs/keybinding-cleanup-guide.md")
  print(string.rep("=", 80) .. "\n")
end

-- Export list to file for reference
function M.export_all_keybindings(filepath)
  filepath = filepath or vim.fn.stdpath("config") .. "/docs/keybindings/current-mappings.txt"

  local all_bindings = M.list_all_leader_keybindings()
  local lines = {
    "ALL LEADER KEYBINDINGS",
    string.rep("=", 80),
    string.format("Generated: %s", os.date("%Y-%m-%d %H:%M:%S")),
    string.rep("=", 80),
    "",
  }

  for _, binding in ipairs(all_bindings) do
    table.insert(lines, string.format("[%s] %s → %s", binding.mode, binding.lhs, binding.desc))
    table.insert(lines, string.format("    RHS: %s", binding.rhs))
    table.insert(lines, string.format("    From: %s", binding.from))
    table.insert(lines, "")
  end

  -- Ensure directory exists
  vim.fn.mkdir(vim.fn.fnamemodify(filepath, ":h"), "p")

  -- Write file
  local file = io.open(filepath, "w")
  if file then
    file:write(table.concat(lines, "\n"))
    file:close()
    print(string.format("✅ Exported %d keybindings to: %s", #all_bindings, filepath))
  else
    print(string.format("❌ Failed to write to: %s", filepath))
  end
end

-- Create user command for easy access
vim.api.nvim_create_user_command("KeybindingDiagnostics", function()
  M.run_full_audit()
end, { desc = "Run keybinding diagnostics" })

vim.api.nvim_create_user_command("KeybindingExport", function()
  M.export_all_keybindings()
end, { desc = "Export all keybindings to file" })

return M

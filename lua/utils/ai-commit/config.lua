-- Configuration module for AI commit message generation
-- Centralized configuration with defaults and user overrides

local M = {}

-- Default configuration
local defaults = {
  -- Git settings
  git_command = "git",
  
  -- Processing limits
  max_diff_size = 10000,  -- Maximum diff size in bytes
  max_message_length = 500,  -- Maximum commit message length
  
  -- Auto-generation
  auto_generate = true,  -- Auto-generate on commit buffer open
  
  -- Logging
  log_level = "INFO",  -- DEBUG, INFO, WARN, ERROR
  
  -- Templates and patterns
  commit_template = [[
{type}{scope}: {description}

{body}

{footer}
  ]],
  
  -- Commit types
  commit_types = {
    feat = { emoji = "✨", description = "New feature" },
    fix = { emoji = "🐛", description = "Bug fix" },
    docs = { emoji = "📚", description = "Documentation" },
    style = { emoji = "💄", description = "Formatting, styling" },
    refactor = { emoji = "♻️", description = "Code refactoring" },
    perf = { emoji = "⚡", description = "Performance improvement" },
    test = { emoji = "✅", description = "Tests" },
    chore = { emoji = "🔧", description = "Maintenance" },
    build = { emoji = "📦", description = "Build system" },
    ci = { emoji = "🚀", description = "CI/CD" },
    revert = { emoji = "⏪", description = "Revert changes" },
  },
  
  -- Pattern definitions for different languages
  patterns = {
    functions = {
      lua = {
        "function%s+([%w_%.]+)%s*%(",
        "local%s+function%s+([%w_]+)%s*%(",
        "([%w_]+)%s*=%s*function%s*%(",
        "local%s+([%w_]+)%s*=%s*function%s*%("
      },
      python = {
        "def%s+([%w_]+)%s*%(",
        "async%s+def%s+([%w_]+)%s*%(",
        "class%s+([%w_]+)%s*[%(:]"
      },
      javascript = {
        "function%s+([%w_]+)%s*%(",
        "const%s+([%w_]+)%s*=%s*%(",
        "let%s+([%w_]+)%s*=%s*%(",
        "var%s+([%w_]+)%s*=%s*%(",
        "([%w_]+)%s*:%s*function%s*%(",
        "async%s+function%s+([%w_]+)%s*%("
      }
    },
    imports = {
      lua = {
        "require%s*%(.*['\"]([%w_%.%-/]+)['\"].*%)",
        "local%s+[%w_]+%s*=%s*require%s*%(.*['\"]([%w_%.%-/]+)['\"].*%)"
      },
      python = {
        "import%s+([%w_%.]+)",
        "from%s+([%w_%.]+)%s+import"
      },
      javascript = {
        "import%s+.+%s+from%s+['\"]([%w_%.%-/@]+)['\"]",
        "require%s*%(.*['\"]([%w_%.%-/@]+)['\"].*%)",
        "import%s*%(.*['\"]([%w_%.%-/@]+)['\"].*%)"
      }
    },
    config = {
      "opts%s*=%s*{",
      "config%s*=%s*{",
      "settings%s*=%s*{",
      "options%s*=%s*{",
      "setup%s*%(",
      "configure%s*%("
    },
    keymaps = {
      "vim%.keymap%.set",
      "map%s*%(",
      "noremap%s*%(",
      "keymap%s*%(",
      "%[\"[^\"]+\"%]%s*=%s*{"  -- ["<Leader>x"] = { ... }
    }
  },
  
  -- Scope detection rules
  scope_rules = {
    { pattern = "plugin", scope = "plugins" },
    { pattern = "config", scope = "config" },
    { pattern = "utils", scope = "utils" },
    { pattern = "test", scope = "test" },
    { pattern = "spec", scope = "test" },
    { pattern = "doc", scope = "docs" },
    { pattern = "README", scope = "docs" },
  },
  
  -- Message formatting
  use_emoji = false,  -- Add emoji to commit types
  include_stats = true,  -- Include change statistics
  include_file_list = true,  -- List modified files
  max_files_to_show = 5,  -- Maximum files to list explicitly
}

-- Current configuration (will be merged with user options)
local config = {}

-- Setup configuration with user options
function M.setup(opts)
  config = vim.tbl_deep_extend("force", defaults, opts or {})
  return config
end

-- Get configuration value
function M.get(key)
  if key then
    return config[key] or defaults[key]
  end
  return config
end

-- Set configuration value
function M.set(key, value)
  config[key] = value
end

-- Update configuration with partial options
function M.update(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  return config
end

-- Show current configuration
function M.show_config()
  local lines = { "AI Commit Configuration:", "" }
  
  local function add_config_lines(tbl, prefix)
    for key, value in pairs(tbl) do
      if type(value) == "table" then
        table.insert(lines, prefix .. key .. ":")
        add_config_lines(value, prefix .. "  ")
      elseif type(value) == "boolean" then
        table.insert(lines, prefix .. key .. ": " .. (value and "enabled" or "disabled"))
      else
        table.insert(lines, prefix .. key .. ": " .. tostring(value))
      end
    end
  end
  
  add_config_lines(config, "  ")
  
  -- Create floating window to show config
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "text"
  
  local width = math.max(40, math.min(80, vim.o.columns - 10))
  local height = math.min(#lines + 2, vim.o.lines - 5)
  
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " AI Commit Configuration ",
    title_pos = "center",
  })
  
  -- Close on q or Esc
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf })
end

-- Get pattern for language detection
function M.get_patterns_for_file(filepath)
  local ext = filepath:match("%.([^%.]+)$")
  if not ext then return {} end
  
  local lang_map = {
    lua = "lua",
    py = "python",
    js = "javascript",
    ts = "javascript",
    jsx = "javascript",
    tsx = "javascript",
  }
  
  local lang = lang_map[ext]
  if not lang then return {} end
  
  return {
    functions = config.patterns.functions[lang] or {},
    imports = config.patterns.imports[lang] or {}
  }
end

-- Initialize with defaults
config = defaults

return M
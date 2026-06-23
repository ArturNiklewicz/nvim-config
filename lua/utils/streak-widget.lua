-- streak-widget: Persistent floating streak countdown + stats (upper-right)
-- Toggle: <leader>mg | Auto-refresh after <leader>ms submit
--
-- Display states:
--   ACTIVE     — countdown ticking, streak alive (remaining > 0)
--   EXPIRED    — streak broken, waiting for next submit
--   NEW_RECORD — celebratory flash after beating record (5s → ACTIVE)

local M = {}

-- ── Config ──────────────────────────────────────────────

local STREAK_SH = os.getenv("HOME") .. "/.config/tmux/scripts/streak.sh"
local WIDGET_WIDTH = 33
local NEW_RECORD_FLASH_SECS = 5
local URGENCY_THRESHOLD = 30

-- ── Highlights ──────────────────────────────────────────

local ns = vim.api.nvim_create_namespace("streak_widget")

local function setup_highlights()
  local set = vim.api.nvim_set_hl
  set(0, "StreakHeader",   { fg = "#cba6f7", bold = true })
  set(0, "StreakXpBar",    { fg = "#a6e3a1" })
  set(0, "StreakActive",   { fg = "#fab387" })
  set(0, "StreakUrgent",   { fg = "#f38ba8", bold = true })
  set(0, "StreakExpired",  { fg = "#6c7086", italic = true })
  set(0, "StreakRecord",   { fg = "#f9e2af", bold = true })
  set(0, "StreakDigit",    { fg = "#89b4fa" })
  set(0, "StreakDigitHot", { fg = "#f38ba8", bold = true })
end

-- ── State ───────────────────────────────────────────────

local widget = { win = nil, buf = nil, timer = nil, resize_acmd = nil }

local stats = {
  score = 0, runs = 0, streak = 0, level = 0,
  xp = 0, xp_needed = 1, remaining = 0, record_score = 0,
}

local new_record_ttl = 0

local function display_state()
  if new_record_ttl > 0 then return "new_record" end
  if stats.remaining > 0 then return "active" end
  return "expired"
end

-- ── Art data ────────────────────────────────────────────

local DIGITS = {
  [0] = { "  __  ", " /  \\ ", "| () |", " \\__/ " },
  [1] = { "  _   ", " / |  ", " | |  ", " |_|  " },
  [2] = { " ___  ", "|_  ) ", " / /  ", "/___| " },
  [3] = { " ____ ", "|__ / ", " |_ \\ ", "|___/ " },
  [4] = { " _ _  ", "| | | ", "|_  _|", "  |_| " },
  [5] = { " ___  ", "| __| ", "|__ \\ ", "|___/ " },
  [6] = { "  __  ", " / /  ", "/ _ \\ ", "\\___/ " },
  [7] = { " ____ ", "|__  |", "  / / ", " /_/  " },
  [8] = { " ___  ", "( _ ) ", "/ _ \\ ", "\\___/ " },
  [9] = { " ___  ", "/ _ \\ ", "\\_, / ", " /_/  " },
}
local COLON = { "  _  ", " (_) ", "  _  ", " (_) " }

local STREAK_OVER_ART = {
  " ___ _____ ___ ___   _   _  __ ",
  "/ __|_   _| _ \\ __| /_\\ | |/ / ",
  "\\__ \\ | | |   / _| / _ \\| ' <  ",
  "|___/ |_|_|_|_\\___/_/_\\_\\_|\\_\\ ",
  "     / _ \\ \\ / / __| _ \\ |     ",
  "    | (_) \\ V /| _||   /_|     ",
  "     \\___/ \\_/ |___|_|_(_)     ",
}

local NEW_RECORD_ART = {
  "     _  _ _____      __     ",
  "    | \\| | __\\ \\    / /     ",
  "    | .` | _| \\ \\/\\/ /      ",
  " ___|_|\\_|___|_\\_/\\_/___  _ ",
  "| _ \\ __/ __/ _ \\| _ \\   \\| |",
  "|   / _| (_| (_) |   / |) |_|",
  "|_|_\\___\\___\\___/|_|_\\___/(_)",
}

-- ── Rendering ───────────────────────────────────────────

local function render_countdown(secs)
  local m = math.floor(secs / 60)
  local s = secs % 60
  local d = { math.floor(m / 10), m % 10, math.floor(s / 10), s % 10 }
  local rows = {}
  for r = 1, 4 do
    rows[r] = " " .. DIGITS[d[1]][r] .. DIGITS[d[2]][r] .. COLON[r] .. DIGITS[d[3]][r] .. DIGITS[d[4]][r]
  end
  return rows
end

local function render_xp_bar()
  local pct = math.min(math.floor(stats.xp * 100 / math.max(stats.xp_needed, 1)), 100)
  local filled = math.min(math.floor(pct / 5), 20)
  return string.rep("█", filled) .. string.rep("░", 20 - filled) .. " " .. pct .. "%"
end

--- Returns parallel arrays: lines (text) + hls (highlight group per line)
local function render()
  local lines, hls = {}, {}
  local ds = display_state()
  local urgent = ds == "active" and stats.remaining <= URGENCY_THRESHOLD

  -- Header
  lines[#lines + 1] = string.format("⚔️  LVL %d | XP %d/%d", stats.level, stats.xp, stats.xp_needed)
  hls[#hls + 1] = "StreakHeader"

  -- XP bar
  lines[#lines + 1] = render_xp_bar()
  hls[#hls + 1] = "StreakXpBar"

  -- Status line
  local status_map = {
    new_record = { string.format("🏆 NEW RECORD %d!", stats.record_score), "StreakRecord" },
    active     = { string.format("🔥 %d | Score %d | Record %d", stats.streak, stats.score, stats.record_score),
                   urgent and "StreakUrgent" or "StreakActive" },
    expired    = { string.format("💀 Score %d | Record %d", stats.score, stats.record_score), "StreakExpired" },
  }
  local sl = status_map[ds]
  lines[#lines + 1] = sl[1]
  hls[#hls + 1] = sl[2]

  -- Art block
  local art_map = {
    new_record = { NEW_RECORD_ART, "StreakRecord" },
    active     = { render_countdown(stats.remaining), urgent and "StreakDigitHot" or "StreakDigit" },
    expired    = { STREAK_OVER_ART, "StreakExpired" },
  }
  local art, art_hl = unpack(art_map[ds])
  for _, row in ipairs(art) do
    lines[#lines + 1] = row
    hls[#hls + 1] = art_hl
  end

  return lines, hls
end

-- ── Display ─────────────────────────────────────────────

local function update_display()
  if not widget.buf or not vim.api.nvim_buf_is_valid(widget.buf) then return end

  local lines, hls = render()

  vim.api.nvim_set_option_value("modifiable", true, { buf = widget.buf })
  vim.api.nvim_buf_set_lines(widget.buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = widget.buf })

  vim.api.nvim_buf_clear_namespace(widget.buf, ns, 0, -1)
  for i = 1, #lines do
    if hls[i] then
      vim.api.nvim_buf_add_highlight(widget.buf, ns, hls[i], i - 1, 0, -1)
    end
  end

  if widget.win and vim.api.nvim_win_is_valid(widget.win) then
    vim.api.nvim_win_set_height(widget.win, #lines)
  end
end

-- ── Data ────────────────────────────────────────────────

local STATS_KEYS = { "score", "runs", "streak", "level", "xp", "xp_needed", "remaining", "record_score" }

local function fetch_stats()
  local raw = vim.fn.trim(vim.fn.system({ STREAK_SH, "stats" }))
  if vim.v.shell_error ~= 0 or raw == "" then return false end

  local parts = vim.split(raw, "|")
  if #parts < 9 then return false end

  for i, key in ipairs(STATS_KEYS) do
    stats[key] = tonumber(parts[i]) or 0
  end
  if stats.xp_needed <= 0 then stats.xp_needed = 1 end

  if tonumber(parts[9]) == 1 then
    new_record_ttl = NEW_RECORD_FLASH_SECS
  end
  return true
end

-- ── Timer ───────────────────────────────────────────────

local function stop_timer()
  if widget.timer then
    vim.fn.timer_stop(widget.timer)
    widget.timer = nil
  end
end

local function on_tick()
  if not widget.win or not vim.api.nvim_win_is_valid(widget.win) then
    stop_timer()
    return
  end
  if stats.remaining > 0 then stats.remaining = stats.remaining - 1 end
  if new_record_ttl > 0 then new_record_ttl = new_record_ttl - 1 end
  update_display()
end

local function start_timer()
  stop_timer()
  widget.timer = vim.fn.timer_start(1000, function()
    vim.schedule(on_tick)
  end, { ["repeat"] = -1 })
end

-- ── Window ──────────────────────────────────────────────

local function reposition()
  if not widget.win or not vim.api.nvim_win_is_valid(widget.win) then return end
  vim.api.nvim_win_set_config(widget.win, {
    relative = "editor",
    row = 1,
    col = vim.o.columns - WIDGET_WIDTH - 2,
  })
end

local function open()
  setup_highlights()

  widget.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = widget.buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = widget.buf })
  vim.api.nvim_set_option_value("modifiable", false, { buf = widget.buf })

  widget.win = vim.api.nvim_open_win(widget.buf, false, {
    relative = "editor",
    width = WIDGET_WIDTH,
    height = 1, -- auto-sized after first render
    row = 1,
    col = vim.o.columns - WIDGET_WIDTH - 2,
    style = "minimal",
    border = "rounded",
    focusable = false,
    zindex = 100,
    title = " 🎮 STREAK ",
    title_pos = "center",
  })

  -- Block ALL interaction — keyboard scroll + mouse scroll over float
  local noop = "<Nop>"
  local block_keys = {
    "<C-d>", "<C-u>", "<C-f>", "<C-b>", "<C-e>", "<C-y>",
    "j", "k", "G", "gg", "h", "l", "<Up>", "<Down>",
    "<ScrollWheelUp>", "<ScrollWheelDown>",
    "<2-ScrollWheelUp>", "<2-ScrollWheelDown>",
    "<3-ScrollWheelUp>", "<3-ScrollWheelDown>",
    "<4-ScrollWheelUp>", "<4-ScrollWheelDown>",
    "<S-ScrollWheelUp>", "<S-ScrollWheelDown>",
    "<C-ScrollWheelUp>", "<C-ScrollWheelDown>",
    "<LeftMouse>", "<RightMouse>", "<MiddleMouse>",
  }
  for _, key in ipairs(block_keys) do
    vim.api.nvim_buf_set_keymap(widget.buf, "n", key, noop, { noremap = true, silent = true })
  end

  -- Bounce focus back immediately on enter
  widget.focus_acmd = vim.api.nvim_create_autocmd("WinEnter", {
    callback = function()
      if vim.api.nvim_get_current_win() == widget.win then
        vim.cmd("wincmd p")
      end
    end,
  })

  widget.resize_acmd = vim.api.nvim_create_autocmd("VimResized", {
    callback = reposition,
  })

  fetch_stats()
  update_display()
  start_timer()
end

local function close()
  stop_timer()
  for _, key in ipairs({ "resize_acmd", "focus_acmd" }) do
    if widget[key] then
      vim.api.nvim_del_autocmd(widget[key])
      widget[key] = nil
    end
  end
  if widget.win and vim.api.nvim_win_is_valid(widget.win) then
    vim.api.nvim_win_close(widget.win, true)
  end
  widget.win = nil
  widget.buf = nil
end

-- ── Public API ──────────────────────────────────────────

function M.toggle()
  if widget.win and vim.api.nvim_win_is_valid(widget.win) then
    close()
  else
    open()
  end
end

function M.refresh()
  if not widget.win or not vim.api.nvim_win_is_valid(widget.win) then return end
  fetch_stats()
  update_display()
end

function M.is_open()
  return widget.win ~= nil and vim.api.nvim_win_is_valid(widget.win)
end

return M

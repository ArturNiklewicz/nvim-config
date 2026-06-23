-- claude-srs: Send visual selection + mental hook to Claude Code pane
-- Connected mental hooks with streak gamification (SQLite persistence)

local M = {}

local HOME = os.getenv("HOME")
M.config = {
  prompt_file = "/tmp/nvim-claude-prompt.txt",
  tmux_script = HOME .. "/.config/tmux/scripts/send-to-claude.sh",
  streak_script = HOME .. "/.config/tmux/scripts/streak.sh",
}

local lang_map = {
  py = "python", js = "javascript", ts = "typescript", tsx = "tsx",
  lua = "lua", rs = "rust", go = "go", rb = "ruby", sh = "bash",
  java = "java", cpp = "cpp", c = "c", swift = "swift", kt = "kotlin",
  sql = "sql", yaml = "yaml", yml = "yaml", toml = "toml", json = "json",
}

local function get_lang(path)
  local ext = path:match("%.(%w+)$")
  return lang_map[ext] or ext or ""
end

local function compute_card_id(hook_seed, code)
  local cmd = { HOME .. "/.config/tmux/scripts/review.sh", "card-id", hook_seed, code }
  return vim.fn.trim(vim.fn.system(cmd))
end

local function build_prompt(file_path, start_line, end_line, code, mental_hook, lang, recent_hooks, card_id)
  local hooks_ctx = ""
  if recent_hooks and recent_hooks ~= "" then
    hooks_ctx = "\nPrevious hooks (continue this narrative):\n" .. recent_hooks
  end

  return string.format([[SRS flashcard. Display table, then persist to DB.

## SILENT (do NOT display)
- Derive topic slug from file path (lowercase, hyphens, 2-3 words). Skip src/lib/utils/scripts/config.
- card_id: %s
%s
File: %s (lines %d-%d)
Lang: %s
Seed: "%s"

## Style requirements

**def** — rich, domain-contextualized. 3-5 fragments/short sentences covering:
- What kind of construct this is (decorator, field, import, call, etc.)
- Specific type/API semantics (NewType, frozen dataclass, async gen, etc.) with concrete numbers/examples where relevant (e.g. "~40%% less memory", "16000 Hz speech")
- Why it matters here (purpose, constraint, common combo)
Caveman grammar OK (drop articles/filler) but keep substance. Backtick identifiers.

**hook** — terse mnemonic. Minimal tokens, maximum retention. Format:
- Emoji anchor + phonetic trigger → `identifier`
- One line, < 15 tokens total
- Each seed word → one mapping arrow
- No narration, no full sentences
- Continue emoji-narrative from previous hooks if present

## DISPLAY

| **code** | `[the code snippet, inline]` |
|---|---|
| **def** | [rich definition per style above] |
| **hook** | [terse mnemonic per style above] |

📂 <topic-slug>

## PERSIST (after displaying)

Run this Bash command to store def+hook in the SRS DB:

```
~/.config/tmux/scripts/review.sh annotate %s '<def text>' '<hook text>'
```

Substitute `<def text>` and `<hook text>` with the exact strings you rendered. Use single quotes; if def/hook contains a single quote, escape via `'\''`.

## Code
```%s
%s
```]], card_id, hooks_ctx, file_path, start_line, end_line, lang,
    mental_hook, card_id, lang, code)
end

local function build_chat_prompt(file_path, start_line, end_line, code, focus, lang, recent_hooks)
  local hooks_ctx = ""
  if recent_hooks and recent_hooks ~= "" then
    hooks_ctx = "\nPrevious hooks (my existing mental library):\n" .. recent_hooks
  end
  local focus_line = (focus and focus ~= "") and focus or "open exploration"

  return string.format([[Exploratory pass — explain this snippet, then cluster it with my prior hooks. Do NOT persist, do NOT create a flashcard.

File: %s (lines %d-%d)
Lang: %s
Focus: %s
%s

## Do
1. **Explain** — what this construct does. Domain context, type/API semantics with concrete numbers/examples where relevant, why it matters here. Rich but compressed.
2. **Cluster** — which of my previous hooks does this belong with? Name the cluster (short phrase). If it doesn't fit any, say "new cluster" and propose the name.
3. **Unified encoding** — propose a single mnemonic frame (emoji narrative, story, PAO, method-of-loci location) that holds this snippet + its cluster siblings together. Make the pieces rhyme.
4. **Pull threads** — 1-2 follow-up questions or adjacent concepts worth exploring next.

## Do NOT
- No `review.sh annotate`.
- No flashcard persistence.
- No SRS event.

## Code
```%s
%s
```]], file_path, start_line, end_line, lang, focus_line, hooks_ctx, lang, code)
end

local function send_chat(file_path, start_line, end_line, code, focus)
  local lang = get_lang(file_path)
  local recent = vim.fn.trim(
    vim.fn.system({ M.config.streak_script, "recent", file_path })
  )
  local prompt = build_chat_prompt(file_path, start_line, end_line, code, focus, lang, recent)

  local f = io.open(M.config.prompt_file, "w")
  if not f then
    vim.notify("Failed to write prompt file", vim.log.levels.ERROR)
    return
  end
  f:write(prompt)
  f:close()

  local _ = vim.fn.system(M.config.tmux_script)
  if vim.v.shell_error ~= 0 then
    vim.notify("No Claude pane found — toggle with C-M-s first", vim.log.levels.WARN)
  else
    vim.notify("Sent to Claude (chat)", vim.log.levels.INFO)
  end
end

local function send(file_path, start_line, end_line, code, mental_hook)
  local lang = get_lang(file_path)

  -- Get recent hooks for narrative continuity
  local recent = vim.fn.trim(
    vim.fn.system({ M.config.streak_script, "recent", file_path })
  )

  local card_id = compute_card_id(mental_hook, code)
  local prompt = build_prompt(file_path, start_line, end_line, code, mental_hook, lang, recent, card_id)

  local f = io.open(M.config.prompt_file, "w")
  if not f then
    vim.notify("Failed to write prompt file", vim.log.levels.ERROR)
    return
  end
  f:write(prompt)
  f:close()

  -- Send to Claude Code pane (check exit code)
  local result = vim.fn.system(M.config.tmux_script)
  if vim.v.shell_error ~= 0 then
    vim.notify("No Claude pane found — toggle with C-M-s first", vim.log.levels.WARN)
  else
    vim.notify("Sent to Claude", vim.log.levels.INFO)
  end

  -- Record event + show streak popup (async, non-blocking)
  vim.fn.jobstart({
    M.config.streak_script, "record",
    file_path, tostring(start_line), tostring(end_line),
    mental_hook, code,
  }, {
    on_exit = function()
      vim.schedule(function()
        require("utils.streak-widget").refresh()
      end)
    end,
  })
end

function M.open(lines, start_line, end_line)
  if not lines or #lines == 0 then
    vim.notify("No selection", vim.log.levels.WARN)
    return
  end

  local file_path = vim.fn.expand("%:p")
  local code = table.concat(lines, "\n")
  local fname = vim.fn.fnamemodify(file_path, ":t")

  local width = math.floor(vim.o.columns * 0.6)
  local height = 4
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Mental Hook  (C-s capture | C-M-c chat | q close) ",
    title_pos = "center",
    footer = string.format(" %s:%d-%d ", fname, start_line, end_line),
    footer_pos = "center",
  })

  vim.api.nvim_set_option_value("wrap", true, { win = win })
  vim.cmd("startinsert")

  local function submit()
    local hook_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local hook = vim.fn.trim(table.concat(hook_lines, "\n"))
    if hook == "" then
      vim.notify("Empty hook, cancelled", vim.log.levels.WARN)
      vim.api.nvim_win_close(win, true)
      return
    end
    vim.api.nvim_win_close(win, true)
    send(file_path, start_line, end_line, code, hook)
  end

  local function submit_chat()
    local hook_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local focus = vim.fn.trim(table.concat(hook_lines, "\n"))
    vim.api.nvim_win_close(win, true)
    send_chat(file_path, start_line, end_line, code, focus)
  end

  local function cancel()
    vim.api.nvim_win_close(win, true)
  end

  vim.keymap.set({ "n", "i" }, "<C-s>", submit, { buffer = buf })
  vim.keymap.set({ "n", "i" }, "<C-M-c>", submit_chat, { buffer = buf })
  vim.keymap.set("n", "q", cancel, { buffer = buf })
  vim.keymap.set("i", "<C-c>", cancel, { buffer = buf })

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })
end

return M

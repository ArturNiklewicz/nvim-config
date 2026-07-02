-- gitlab.nvim — review GitLab MRs in-editor. Self-host: git.zrobmyto.ai
-- Auth: set GITLAB_TOKEN (+ GITLAB_URL) env, or a .gitlab.nvim file in the project root.
return {
  "harrisoncramer/gitlab.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "dlyongemallo/diffview-plus.nvim", -- shared with diffview.lua (maintained fork)
    "stevearc/dressing.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  build = function() require("gitlab.server").build(true) end, -- builds Go binary
  config = function()
    require("diffview") -- gitlab.nvim needs diffview's global state
    require("gitlab").setup({
      -- Token decrypted from SOPS at runtime — never stored plaintext on disk or in env.
      auth_provider = function()
        local sops = vim.fn.exepath("sops")
        if sops == "" then sops = "/opt/homebrew/bin/sops" end -- GUI/launchd nvim may lack brew PATH
        local secret = vim.fn.expand("~/.config/claude/secrets.sops.env")
        local token = vim.fn.system({ sops, "-d", "--extract", '["GITLAB_TOKEN"]', secret })
        if vim.v.shell_error ~= 0 then
          return nil, nil, "gitlab.nvim: sops decrypt failed — is GITLAB_TOKEN in " .. secret .. "?"
        end
        token = vim.trim(token)
        if token == "" then return nil, nil, "gitlab.nvim: GITLAB_TOKEN empty in " .. secret end
        return token, "https://git.zrobmyto.ai", nil
      end,
      connection_settings = { remote = "origin" }, -- default; corrected per-repo by the autocmd below
    })

    -- gitlab.nvim has ONE global connection_settings.remote, but back-end MRs live on a
    -- separate `staging` remote while every other repo uses `origin`. git.lua reads this value
    -- live at review time, so pick it per-repo: `staging` if that remote exists, else `origin`.
    -- ponytail: cwd-based; if you open files with cwd outside the repo root, cd in first.
    local function set_gitlab_remote()
      local ok, state = pcall(require, "gitlab.state")
      if not ok or not state.settings.connection_settings then return end
      local remotes = vim.fn.systemlist("git remote")
      state.settings.connection_settings.remote =
        vim.tbl_contains(remotes, "staging") and "staging" or "origin"
    end
    vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, { callback = set_gitlab_remote })
    set_gitlab_remote()

    -- diffview-plus fork lazy-loads diff buffers, so an async discussion callback can pass a
    -- nil bufnr to place_diagnostics; nvim_buf_is_valid(nil) throws. Guard the arg type.
    -- ponytail: monkeypatch (survives plugin updates), drop if gitlab.nvim guards nil upstream.
    local diag = require("gitlab.indicators.diagnostics")
    local orig_place = diag.place_diagnostics
    diag.place_diagnostics = function(bufnr)
      if type(bufnr) ~= "number" then return end
      return orig_place(bufnr)
    end
  end,
}

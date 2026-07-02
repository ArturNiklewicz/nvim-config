-- nvim-devdocs — browse DevDocs OFFLINE inside nvim (telescope picker + markdown
-- buffers, rendered via the treesitter `html` parser). Replaces the :9292 web app.
--
-- PROJECT-SCOPED: <leader>dd shows only the CURRENT repo's stack (no react while you're
-- in the Python back-end, etc). <leader>dD is the unscoped all-docs picker; <leader>dc
-- is the current-filetype picker. Docsets live in stdpath("data")/devdocs, fully offline.
return {
  {
    "luckasRanarison/nvim-devdocs",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = {
      "DevdocsFetch", "DevdocsInstall", "DevdocsUninstall",
      "DevdocsOpen", "DevdocsOpenFloat",
      "DevdocsOpenCurrent", "DevdocsOpenCurrentFloat",
      "DevdocsToggle", "DevdocsUpdate", "DevdocsUpdateAll",
      "DevdocsProject",
    },
    keys = {
      { "<leader>dd", "<cmd>DevdocsProject<cr>",          desc = "DevDocs: THIS project's stack" },
      { "<leader>dc", "<cmd>DevdocsOpenCurrentFloat<cr>", desc = "DevDocs: current filetype" },
      { "<leader>dD", "<cmd>DevdocsOpenFloat<cr>",        desc = "DevDocs: ALL docs" },
      { "<leader>di", "<cmd>DevdocsInstall<cr>",          desc = "DevDocs: install a docset" },
      { "<leader>dt", "<cmd>DevdocsToggle<cr>",           desc = "DevDocs: toggle float" },
    },
    opts = {
      -- installed slugs (versioned use `~` on install; stored on disk as `-`).
      ensure_installed = {
        "python~3.12", "typescript~5.1", "javascript", "node", "react",
        "react_native", "fastapi", "http", "postgresql~18",
        "css", "html", "dom", "eslint", "jest", "playwright", "date_fns",
      },
      -- <leader>dc resolves docs per filetype (base names; variant auto-resolved).
      filetypes = {
        python = "python",
        typescript = "typescript",
        typescriptreact = { "react", "typescript" },
        javascript = { "node", "javascript" },
        javascriptreact = { "react", "javascript" },
        sql = "postgresql",
        css = "css",
        html = "html",
      },
      float_win = { border = "rounded", height = 28, width = 110 },
      wrap = true,
      mappings = { open_in_browser = "<leader>db" },
      after_open = function(bufnr)
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = bufnr, silent = true })
      end,
    },
    config = function(_, opts)
      require("nvim-devdocs").setup(opts)

      -- Per-repo allow-lists (installed alias form: versioned use `-`). Path is matched
      -- against the current file (else cwd), so the picker only shows that stack.
      local PROJECTS = {
        { match = "zrobmyto%.ai/back%-end",
          docs = { "python-3.12", "fastapi", "http", "postgresql-18" } },
        { match = "zrobmyto%.ai/front%-end",
          docs = { "typescript-5.1", "javascript", "node", "react", "react_native",
                   "css", "html", "dom", "eslint", "jest", "playwright", "date_fns" } },
      }

      local function project_docs()
        local path = vim.fn.expand("%:p")
        if path == "" then path = vim.fn.getcwd() end
        for _, p in ipairs(PROJECTS) do
          if path:match(p.match) then return p.docs, p.match end
        end
        return nil
      end

      vim.api.nvim_create_user_command("DevdocsProject", function()
        local list = require("nvim-devdocs.list")
        local pickers = require("nvim-devdocs.pickers")
        local docs = project_docs()
        if not docs then docs = list.get_installed_alias() end -- no repo match → all
        -- keep only docs actually installed, so a missing one never errors the picker.
        local installed = list.get_installed_alias()
        local scoped = vim.tbl_filter(function(d) return vim.tbl_contains(installed, d) end, docs)
        if vim.tbl_isempty(scoped) then
          vim.notify("devdocs: none of this project's docsets are installed", vim.log.levels.WARN)
          return
        end
        local entries = list.get_doc_entries(scoped)
        if not entries or vim.tbl_isempty(entries) then
          vim.notify("devdocs: no entries for " .. table.concat(scoped, ", "), vim.log.levels.WARN)
          return
        end
        pickers.open_picker(entries, true)
      end, { desc = "DevDocs picker scoped to the current project's stack" })
    end,
  },
}

-- usharp.nvim — local capture plugin, git-backed for two-way sync.
-- repo: git.zrobmyto.ai/zrobmyto.ai/usharp/usharp.nvim  (clone at ~/Developer/full-stack/usharp/usharp.nvim)
-- edit here -> `git push`;  other machine -> `git pull`.
return {
  {
    name = "usharp",
    dir = vim.fn.expand("~/Developer/full-stack/usharp/usharp.nvim"),
    lazy = false,
    config = function()
      require("usharp").setup()
    end,
  },
}

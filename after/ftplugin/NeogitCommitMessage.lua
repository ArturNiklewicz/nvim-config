-- Neogit commit message configuration
-- Formatting, spell checking, and conventional commit helpers
-- AI generation handled by git-commit-auto.lua (called from polish.lua)

-- Set textwidth for proper commit message formatting
vim.opt_local.textwidth = 72
vim.opt_local.colorcolumn = "50,72"

-- Enable spell checking
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"

-- Conventional commit shortcuts
vim.keymap.set("n", "<leader>cf", "ifeat: ", { buffer = true, desc = "feat: New feature" })
vim.keymap.set("n", "<leader>cx", "ifix: ", { buffer = true, desc = "fix: Bug fix" })
vim.keymap.set("n", "<leader>cd", "idocs: ", { buffer = true, desc = "docs: Documentation" })
vim.keymap.set("n", "<leader>cs", "istyle: ", { buffer = true, desc = "style: Formatting" })
vim.keymap.set("n", "<leader>cr", "irefactor: ", { buffer = true, desc = "refactor: Code refactoring" })

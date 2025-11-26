-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        "lua-language-server",
        "typescript-language-server",
        "eslint-lsp",
        "tailwindcss-language-server",
        "clangd", -- C/C++ language server
        "basedpyright", -- Python language server (enhanced pyright)

        -- install formatters
        "stylua",
        "prettier",
        "clang-format", -- C/C++ formatter

        -- install debuggers
        "debugpy",
        "codelldb", -- C/C++ debugger

        -- install any other package
        "tree-sitter-cli",
      },
    },
  },
}

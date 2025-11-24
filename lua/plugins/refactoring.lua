-- Refactoring operations based on Martin Fowler's Refactoring book
-- Supports extract function/variable, inline function/variable, and debug helpers
return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  lazy = false,
  opts = {
    -- Prompt for function return type (disabled by default, enable per language if needed)
    prompt_func_return_type = {
      go = false,
      java = false,
      cpp = false,
      c = false,
    },
    -- Prompt for function parameter types (disabled by default)
    prompt_func_param_type = {
      go = false,
      java = false,
      cpp = false,
      c = false,
    },
    -- Custom printf statements (can be customized per language)
    printf_statements = {},
    -- Custom print var statements (can be customized per language)
    print_var_statements = {},
    -- Show success message after refactor
    show_success_message = true,
  },
  config = function(_, opts)
    require("refactoring").setup(opts)

    -- Load Telescope extension for interactive refactor selection
    require("telescope").load_extension("refactoring")
  end,
}

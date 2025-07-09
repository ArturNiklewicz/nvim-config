-- Enhanced text objects for better text manipulation
-- Provides treesitter-based and additional text objects for more efficient editing

return {
  -- Treesitter text objects (syntax-aware selections)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "User AstroFile",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- Function text objects
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            
            -- Class text objects
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            
            -- Conditional text objects
            ["aI"] = "@conditional.outer",
            ["iI"] = "@conditional.inner",
            
            -- Loop text objects
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            
            -- Parameter text objects
            ["ap"] = "@parameter.outer",
            ["ip"] = "@parameter.inner",
            
            -- Comment text objects
            ["aC"] = "@comment.outer",
            ["iC"] = "@comment.inner",
            
            -- Block text objects
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
            
            -- Statement text objects
            ["as"] = "@statement.outer",
            ["is"] = "@statement.inner",
            
            -- Call text objects
            ["aF"] = "@call.outer",
            ["iF"] = "@call.inner",
          },
          selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@function.outer'] = 'V',
            ['@class.outer'] = '<c-v>',
          },
          include_surrounding_whitespace = true,
        },
        
        -- Smart incremental selection
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<Leader>vv",
            node_incremental = "<Leader>vi",
            scope_incremental = "<Leader>vs",
            node_decremental = "<Leader>vd",
          },
        },
        
        -- Movement between text objects
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]l"] = "@loop.outer",
            ["]s"] = "@statement.outer",
            ["]p"] = "@parameter.outer",
            ["]C"] = "@comment.outer",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
            ["]L"] = "@loop.outer",
            ["]S"] = "@statement.outer",
            ["]P"] = "@parameter.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[l"] = "@loop.outer",
            ["[s"] = "@statement.outer",
            ["[p"] = "@parameter.outer",
            ["[C"] = "@comment.outer",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[L"] = "@loop.outer",
            ["[S"] = "@statement.outer",
            ["[P"] = "@parameter.outer",
          },
        },
        
        -- Swapping text objects
        swap = {
          enable = true,
          swap_next = {
            ["<Leader>vpn"] = "@parameter.inner",
            ["<Leader>vfn"] = "@function.outer",
          },
          swap_previous = {
            ["<Leader>vpp"] = "@parameter.inner",
            ["<Leader>vfp"] = "@function.outer",
          },
        },
      },
    },
  },
  
  -- Additional text objects that complement treesitter
  {
    "chrisgrieser/nvim-various-textobjs",
    event = "User AstroFile",
    opts = {
      -- Use default keymaps for additional text objects
      useDefaultKeymaps = true,
      -- Disable notification when no text object is found
      disabledKeymaps = {},
    },
  },
  
  -- Smart text object selection based on context
  {
    "RRethy/nvim-treesitter-textsubjects",
    event = "User AstroFile",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      textsubjects = {
        enable = true,
        prev_selection = ',',
        keymaps = {
          ['.'] = 'textsubjects-smart',
          [';'] = 'textsubjects-container-outer',
          ['i;'] = 'textsubjects-container-inner',
        },
      },
    },
  },
}
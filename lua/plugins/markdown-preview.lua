return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
  ft = { "markdown" },
  config = function()
    require('render-markdown').setup({
      -- Toggle keymaps in code blocks
      code = {
        -- Turn on / off code block & inline code rendering
        enabled = true,
        -- Turn on / off any sign column related rendering
        sign = true,
        -- Determines how code blocks & inline code are rendered:
        --  none: disables all rendering
        --  normal: adds highlight group to code blocks & inline code, adds padding to code blocks
        --  language: adds language icon to sign column if enabled and icon + name above code blocks
        --  full: normal + language
        style = 'full',
        -- Determines where language icon is rendered:
        --  right: right side of code block
        --  left: left side of code block
        position = 'left',
        -- Amount of padding to add to the left of code blocks
        left_pad = 0,
        -- Amount of padding to add to the right of code blocks
        right_pad = 0,
        -- Width of the code block background:
        --  block: width of the code block
        --  full: full width of the window
        width = 'full',
        -- Determins how the top / bottom of code block are rendered:
        --  thick: use the same highlight as the code body
        --  thin: when lines are empty overlay the above & below icons
        border = 'thin',
        -- Used above code blocks for thin border
        above = '▄',
        -- Used below code blocks for thin border
        below = '▀',
        -- Highlight for code blocks & inline code
        highlight = 'RenderMarkdownCode',
        -- Highlight for inline code
        highlight_inline = 'RenderMarkdownCodeInline',
      },
      -- Checkboxes are a special instance of a 'list_item' that start with a 'shortcut_link'
      -- There are two special states for unchecked & checked defined in the markdown grammar
      checkbox = {
        -- Turn on / off checkbox state rendering
        enabled = true,
        unchecked = {
          -- Replaces '[ ]' of 'task_list_marker'
          icon = '󰄱 ',
          -- Highlight for the unchecked icon
          highlight = 'RenderMarkdownUnchecked',
        },
        checked = {
          -- Replaces '[x]' of 'task_list_marker'
          icon = '󰱒 ',
          -- Highlight for the checked icon
          highlight = 'RenderMarkdownChecked',
        },
        -- Define custom checkbox states, more involved as they are not part of the markdown grammar
        -- As a result this requires neovim >= 0.10.0 since it relies on 'inline' extmarks
        -- Can specify as many additional states as you like following the 'todo' pattern below
        --   The key in this case 'todo' is for display only & represents the state
        --   The value is a table that contains:
        --     raw: list of raw 'checkbox' that represent this state
        --     rendered: icon that replaces the raw 'checkbox'
        --     highlight: highlight group for the rendered icon
        custom = {
          todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo' },
        },
      },
      -- Headings
      heading = {
        -- Turn on / off heading icon & background rendering
        enabled = true,
        -- Turn on / off any sign column related rendering
        sign = true,
        -- Determines how the icon fills the available space:
        --  inline: underlying '#' is concealed resulting in a left aligned icon
        --  overlay: result is left padded with spaces to hide any additional '#'
        position = 'overlay',
        -- Replaces '#+' of 'atx_h1_marker'
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        -- Added to the sign column if enabled
        -- The result is highlight_group and/or multi highlight_group and/or icon
        signs = { '󰫎 ' },
        -- Width of the heading background:
        --  block: width of the heading text
        --  full: full width of the window
        width = 'full',
        -- The minimum width to use for the heading background when width is 'block'
        min_width = 0,
        -- Determins if a border is added above and below headings
        border = false,
        -- Alway use virtual text for headings, ignoring the global virtual_text setting
        virtual_text = true,
        -- Highlight the start of the line for headings
        backgrounds = {
          'RenderMarkdownH1Bg',
          'RenderMarkdownH2Bg',
          'RenderMarkdownH3Bg',
          'RenderMarkdownH4Bg',
          'RenderMarkdownH5Bg',
          'RenderMarkdownH6Bg',
        },
        -- The 'level' is used to index into the array using a cycle
        foregrounds = {
          'RenderMarkdownH1',
          'RenderMarkdownH2',
          'RenderMarkdownH3',
          'RenderMarkdownH4',
          'RenderMarkdownH5',
          'RenderMarkdownH6',
        },
      },
      -- Horizontal break
      dash = {
        -- Turn on / off thematic break rendering
        enabled = true,
        -- Replaces '---'|'***'|'___'
        icon = '─',
        -- Width of the generated line:
        --  <integer>: a hard coded width value
        --  full: full width of the window
        width = 'full',
        -- Highlight for the whole line generated from the icon
        highlight = 'RenderMarkdownDash',
      },
      -- Code blocks
      pipe_table = {
        -- Turn on / off pipe table rendering
        enabled = true,
        -- Determines how the table as a whole is rendered:
        --  none: disables all rendering
        --  normal: applies the 'cell' style rendering to each cell of the table
        --  full: normal + a top & bottom line that fill the width of the table
        style = 'full',
        -- Determines how individual cells of a table are rendered:
        --  overlay: writes completely over the table, removing conceal behavior and highlights
        --  raw: replaces only the '|' characters though this has implications (see :h 'conceallevel')
        --  padded: raw + cells are padded with inline extmarks to make up for any concealed text
        cell = 'padded',
        -- Characters used to replace table border
        -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal
        -- stylua: ignore
        border = {
          '┌', '┬', '┐',
          '├', '┼', '┤',
          '└', '┴', '┘',
          '│', '─',
        },
        -- Highlight for table heading, delimiter, and the line above
        head = 'RenderMarkdownTableHead',
        -- Highlight for everything else, main table rows and the line below
        row = 'RenderMarkdownTableRow',
        -- Highlight for table background
        filler = 'RenderMarkdownTableFill',
      },
      -- Callouts are a special instance of a 'block_quote' that start with a 'shortcut_link'
      -- Can specify as many additional values as you like following the pattern from any below, such as 'note'
      --   The key in this case 'note' is for display only & represents the callout type
      --   The value is a table that contains:
      --     raw: identifier that makes up the callout, usually inline code
      --     rendered: icon that replaces the raw callout
      --     highlight: highlight group for the rendered icon & title
      callout = {
        note = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo' },
        tip = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess' },
        important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint' },
        warning = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn' },
        caution = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError' },
        -- Obsidian: https://help.a.com/Editing+and+formatting/Callouts
        abstract = { raw = '[!ABSTRACT]', rendered = '󰨸 Abstract', highlight = 'RenderMarkdownInfo' },
        todo = { raw = '[!TODO]', rendered = '󰗡 Todo', highlight = 'RenderMarkdownInfo' },
        success = { raw = '[!SUCCESS]', rendered = '󰄬 Success', highlight = 'RenderMarkdownSuccess' },
        question = { raw = '[!QUESTION]', rendered = '󰘥 Question', highlight = 'RenderMarkdownWarn' },
        failure = { raw = '[!FAILURE]', rendered = '󰅖 Failure', highlight = 'RenderMarkdownError' },
        danger = { raw = '[!DANGER]', rendered = '󱐌 Danger', highlight = 'RenderMarkdownError' },
        bug = { raw = '[!BUG]', rendered = '󰨰 Bug', highlight = 'RenderMarkdownError' },
        example = { raw = '[!EXAMPLE]', rendered = '󰉹 Example', highlight = 'RenderMarkdownHint' },
        quote = { raw = '[!QUOTE]', rendered = '󱆨 Quote', highlight = 'RenderMarkdownQuote' },
      },
      -- Mimic org-mode
      bullet = {
        -- Turn on / off list bullet rendering
        enabled = true,
        -- Replaces '-'|'+'|'*' of 'list_item'
        -- How deeply nested the list is determines the 'level'
        -- The 'level' is used to index into the array using a cycle
        -- If the item is a 'checkbox' a conceal is used to hide the bullet instead
        icons = { '●', '○', '◆', '◇' },
        -- Highlight for the bullet icon
        highlight = 'RenderMarkdownBullet',
      },
      -- LaTeX blocks
      latex = {
        -- Turn on / off LaTeX rendering
        enabled = true,
        -- Executable used to convert latex formula to rendered unicode
        converter = 'latex2text',
        -- Highlight for LaTeX blocks
        highlight = 'RenderMarkdownMath',
        -- Amount of empty lines above LaTeX blocks
        top_pad = 0,
        -- Amount of empty lines below LaTeX blocks
        bottom_pad = 0,
      },
      -- HTML comments
      html = {
        -- Turn on / off HTML rendering
        enabled = true,
        -- Highlight for HTML blocks
        highlight = 'RenderMarkdownHtml',
      },
      -- Inline links
      link = {
        -- Turn on / off inline link icon rendering
        enabled = true,
        -- Inlined with text
        inline = '󰌷 ',
        -- Replaces text with
        image = '󰥶 ',
        -- Replaces text with
        email = '󰀓 ',
        -- Highlight for link text
        highlight = 'RenderMarkdownLink',
        -- Highlight for link and email icons
        hyperlink = 'RenderMarkdownLinkUrl',
        -- Highlight for image icons
        image_highlight = 'RenderMarkdownImageUrl',
      },
      -- Window options to use that change between rendered and raw view
      win_options = {
        -- See :h 'conceallevel'
        conceallevel = {
          -- Used when not being rendered, get user setting
          default = vim.api.nvim_get_option_value('conceallevel', {}),
          -- Used when being rendered, concealed text is completely hidden
          rendered = 3,
        },
        -- See :h 'concealcursor'
        concealcursor = {
          -- Used when not being rendered, get user setting
          default = vim.api.nvim_get_option_value('concealcursor', {}),
          -- Used when being rendered, disable concealing text in all modes
          rendered = '',
        },
      },
      -- Mapping from treesitter language to user defined handlers
      -- See 'Custom Handlers' section for more info
      custom_handlers = {},
      -- Define the filetypes to activate on
      -- 'lazy' will only activate if another supported filetype is found in the buffer
      -- 'deferred' will always activate
      file_types = { 'markdown' },
      -- Vim modes in which to show a rendered view of the markdown file
      -- All other modes will be uneffected by this plugin
      render_modes = { 'n', 'c' },
      -- Characters that require special handling when rendering markdown
      -- NonBreakingSpace (U+00A0) is used to keep cells properly aligned in tables
      special_chars = { [' '] = '·' },
      -- Disable for certain filetypes
      anti_conceal = {
        -- This will disable rendering when the cursor is on the respective line
        enabled = true,
        -- Number of lines above cursor to also disable
        above = 0,
        -- Number of lines below cursor to also disable  
        below = 0,
      },
      -- Mapping from treesitter language to user defined handlers
      -- See 'Custom Handlers' section for more info
      log_level = 'error',
      -- Filetypes this plugin will run on
      file_types = { 'markdown' },
      -- Out of the box language support for known filetypes
      -- Setting any of these to false will disable support
      markdown_query = '',
      -- Markdown query used for rendering
      markdown_quote_highlight = 'RenderMarkdownQuote',
      -- Highlight for the whole quote
      overrides = {
        -- Overrides for different buftypes, see :h 'buftype' for more info
        buftype = {
          nofile = {
            -- Disable rendering for nofile buffers
            render_modes = {},
          },
        },
      },
    })
    
    -- Keybindings
    local keymap = vim.keymap.set
    
    keymap("n", "<Leader>mp", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle markdown rendering" })
    keymap("n", "<Leader>ms", "<cmd>RenderMarkdown enable<cr>", { desc = "Enable markdown rendering" })
    keymap("n", "<Leader>mq", "<cmd>RenderMarkdown disable<cr>", { desc = "Disable markdown rendering" })
  end,
}
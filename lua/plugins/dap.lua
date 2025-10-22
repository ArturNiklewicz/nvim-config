-- Debug Adapter Protocol (DAP) configuration for C/C++ debugging
-- Provides full debugging capabilities with codelldb and nvim-dap-ui

---@type LazySpec
return {
  -- nvim-dap: Core debugging support
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- nvim-dap-ui: Debugging UI
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          local dap, dapui = require("dap"), require("dapui")

          -- Setup dap-ui with default configuration
          dapui.setup({
            icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
            mappings = {
              -- Use a table to apply multiple mappings
              expand = { "<CR>", "<2-LeftMouse>" },
              open = "o",
              remove = "d",
              edit = "e",
              repl = "r",
              toggle = "t",
            },
            -- Expand lines larger than the window
            expand_lines = true,
            layouts = {
              {
                elements = {
                  { id = "scopes", size = 0.25 },
                  { id = "breakpoints", size = 0.25 },
                  { id = "stacks", size = 0.25 },
                  { id = "watches", size = 0.25 },
                },
                size = 40,
                position = "left",
              },
              {
                elements = {
                  { id = "repl", size = 0.5 },
                  { id = "console", size = 0.5 },
                },
                size = 10,
                position = "bottom",
              },
            },
            floating = {
              max_height = nil,
              max_width = nil,
              border = "single",
              mappings = {
                close = { "q", "<Esc>" },
              },
            },
            windows = { indent = 1 },
            render = {
              max_type_length = nil,
            },
          })

          -- Auto-open/close UI on debugging events
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end,
      },
      -- nvim-dap-virtual-text: Show variable values inline
      {
        "theHamsta/nvim-dap-virtual-text",
        config = function()
          require("nvim-dap-virtual-text").setup({
            enabled = true,
            enabled_commands = true,
            highlight_changed_variables = true,
            highlight_new_as_changed = false,
            show_stop_reason = true,
            commented = false,
            only_first_definition = true,
            all_references = false,
            filter_references_pattern = '<module',
            virt_text_pos = 'eol',
            all_frames = false,
            virt_lines = false,
            virt_text_win_col = nil
          })
        end,
      },
    },
    config = function()
      local dap = require("dap")

      -- Configure codelldb adapter for C/C++
      dap.adapters.codelldb = {
        type = 'server',
        port = "${port}",
        executable = {
          -- Use Mason's installation path
          command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
          args = {"--port", "${port}"},
        }
      }

      -- C configuration
      dap.configurations.c = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
        },
        {
          name = "Launch with arguments",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = function()
            local input = vim.fn.input('Arguments: ')
            return vim.split(input, " ")
          end,
          runInTerminal = false,
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
        {
          name = "Launch from Makefile",
          type = "codelldb",
          request = "launch",
          program = function()
            -- First, try to build the project
            vim.fn.system("make")
            -- Look for the most recently modified executable
            local handle = io.popen("find . -type f -executable -not -path '*/\\.*' -printf '%T@ %p\\n' | sort -rn | head -1 | cut -d' ' -f2-")
            local result = handle:read("*a")
            handle:close()
            result = result:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
            if result ~= "" then
              return vim.fn.getcwd() .. "/" .. result:gsub("^%./", "")
            else
              return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
          preLaunchTask = "make", -- Run make before launching
        },
      }

      -- C++ uses the same configuration as C
      dap.configurations.cpp = dap.configurations.c

      -- Rust configuration (bonus, since codelldb supports it)
      dap.configurations.rust = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
        },
      }

      -- DAP UI customization
      vim.fn.sign_define('DapBreakpoint', {text='●', texthl='DiagnosticError', linehl='', numhl=''})
      vim.fn.sign_define('DapBreakpointCondition', {text='◆', texthl='DiagnosticError', linehl='', numhl=''})
      vim.fn.sign_define('DapBreakpointRejected', {text='✗', texthl='DiagnosticError', linehl='', numhl=''})
      vim.fn.sign_define('DapLogPoint', {text='◈', texthl='DiagnosticInfo', linehl='', numhl=''})
      vim.fn.sign_define('DapStopped', {text='▶', texthl='DiagnosticWarn', linehl='DapStoppedLine', numhl=''})

      -- Highlight for stopped line
      vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#3d3d3d' })

      -- Additional DAP commands for convenience
      vim.api.nvim_create_user_command("DapRunToCursor", function()
        require("dap").run_to_cursor()
      end, {})

      vim.api.nvim_create_user_command("DapEval", function(opts)
        require("dapui").eval(opts.args)
      end, { nargs = "*" })

      vim.api.nvim_create_user_command("DapUIFloat", function(opts)
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.scopes)
      end, {})

      -- Helper function to compile and debug
      vim.api.nvim_create_user_command("CompileAndDebug", function()
        local filetype = vim.bo.filetype
        local filename = vim.fn.expand("%:t:r")
        local filepath = vim.fn.expand("%:p")

        if filetype == "c" then
          vim.fn.system("gcc -g -o " .. filename .. " " .. filepath)
        elseif filetype == "cpp" then
          vim.fn.system("g++ -g -o " .. filename .. " " .. filepath)
        else
          vim.notify("Unsupported filetype for CompileAndDebug", vim.log.levels.ERROR)
          return
        end

        -- Check if compilation was successful
        if vim.v.shell_error == 0 then
          vim.notify("Compilation successful. Starting debugger...", vim.log.levels.INFO)
          -- Start debugging the compiled file
          require("dap").run({
            type = "codelldb",
            request = "launch",
            program = vim.fn.getcwd() .. "/" .. filename,
            cwd = vim.fn.getcwd(),
            stopOnEntry = false,
            args = {},
            runInTerminal = false,
          })
        else
          vim.notify("Compilation failed. Check for errors.", vim.log.levels.ERROR)
        end
      end, {})
    end,
  },
}
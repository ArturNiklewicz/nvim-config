return {
  "famiu/feline.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "lewis6991/gitsigns.nvim",
    "chrisgrieser/nvim-recorder", -- for statusline integration
  },
  config = function()
    local feline = require "feline"
    local vi_mode = require "feline.providers.vi_mode"

    local colors = {
      bg = "#1e1e2e",
      fg = "#cdd6f4",
      yellow = "#f9e2af",
      cyan = "#89dceb",
      darkblue = "#45475a",
      green = "#a6e3a1",
      orange = "#fab387",
      violet = "#cba6f7",
      magenta = "#f5c2e7",
      blue = "#89b4fa",
      red = "#f38ba8",
      black = "#11111b",
      gray = "#6c7086",
    }

    local vi_mode_colors = {
      NORMAL = colors.green,
      INSERT = colors.blue,
      VISUAL = colors.violet,
      OP = colors.green,
      BLOCK = colors.blue,
      REPLACE = colors.red,
      ["V-REPLACE"] = colors.red,
      ENTER = colors.cyan,
      MORE = colors.cyan,
      SELECT = colors.orange,
      COMMAND = colors.magenta,
      SHELL = colors.green,
      TERM = colors.cyan,
      NONE = colors.yellow,
    }

    local components = {
      active = { {}, {}, {} },
      inactive = { {}, {} },
    }

    components.active[1][1] = {
      provider = function()
        return " " .. vi_mode.get_vim_mode() .. " "
      end,
      hl = function()
        return {
          name = vi_mode.get_mode_highlight_name(),
          fg = colors.bg,
          bg = vi_mode_colors[vi_mode.get_vim_mode()],
          style = "bold",
        }
      end,
      right_sep = {
        str = " ",
        hl = { bg = colors.bg },
      },
    }

    components.active[1][2] = {
      provider = "git_branch",
      icon = " ",
      hl = {
        fg = colors.violet,
        bg = colors.bg,
        style = "bold",
      },
      right_sep = " ",
    }

    components.active[1][3] = {
      provider = "git_diff_added",
      icon = " ",
      hl = {
        fg = colors.green,
        bg = colors.bg,
      },
    }

    components.active[1][4] = {
      provider = "git_diff_changed",
      icon = " ",
      hl = {
        fg = colors.yellow,
        bg = colors.bg,
      },
    }

    components.active[1][5] = {
      provider = "git_diff_removed",
      icon = " ",
      hl = {
        fg = colors.red,
        bg = colors.bg,
      },
      right_sep = " ",
    }

    -- Macro recording status (nvim-recorder)
    components.active[2][1] = {
      provider = function()
        local ok, recorder = pcall(require, "recorder")
        if ok then
          local status = recorder.recordingStatus()
          if status and status ~= "" then
            return "  " .. status .. " "
          end
        end
        return ""
      end,
      hl = {
        fg = colors.red,
        bg = colors.bg,
        style = "bold",
      },
    }

    components.active[2][2] = {
      provider = {
        name = "file_info",
        opts = {
          type = "relative",
          file_modified_icon = "",
        },
      },
      icon = "",
      hl = {
        fg = colors.cyan,
        bg = colors.bg,
        style = "bold",
      },
    }

    -- Macro slots display (nvim-recorder) - shows available slots when not recording
    components.active[3][1] = {
      provider = function()
        local ok, recorder = pcall(require, "recorder")
        if ok then
          local slots = recorder.displaySlots()
          if slots and slots ~= "" then
            return "  " .. slots .. " "
          end
        end
        return ""
      end,
      hl = {
        fg = colors.magenta,
        bg = colors.bg,
      },
    }

    components.active[3][2] = {
      provider = function()
        local filename = vim.fn.expand "%:t"
        local extension = vim.fn.expand "%:e"
        local icon = require("nvim-web-devicons").get_icon(filename, extension)
        if icon == nil then
          icon = ""
        end
        return " " .. icon .. " " .. filename .. " "
      end,
      hl = {
        fg = colors.fg,
        bg = colors.darkblue,
      },
      left_sep = {
        str = " ",
        hl = { bg = colors.bg },
      },
    }

    components.active[3][3] = {
      provider = function()
        local clients = vim.lsp.get_clients { bufnr = 0 }
        if next(clients) == nil then
          return ""
        end

        local names = {}
        for _, client in pairs(clients) do
          if client.name ~= "null-ls" and client.name ~= "copilot" then
            table.insert(names, client.name)
          end
        end

        if #names > 0 then
          return " " .. table.concat(names, ", ") .. " "
        end
        return ""
      end,
      hl = {
        fg = colors.yellow,
        bg = colors.bg,
        style = "bold",
      },
      left_sep = " ",
    }

    components.active[3][4] = {
      provider = function()
        if rawget(vim, "lsp") then
          for _, client in ipairs(vim.lsp.get_clients()) do
            if client.attached_buffers[vim.api.nvim_get_current_buf()] and client.name ~= "null-ls" then
              return (vim.o.columns > 100 and "   LSP ") or "   "
            end
          end
        end
        return ""
      end,
      hl = {
        fg = colors.green,
        bg = colors.bg,
        style = "bold",
      },
    }

    components.active[3][5] = {
      provider = "diagnostic_errors",
      icon = " ",
      hl = {
        fg = colors.red,
        bg = colors.bg,
      },
    }

    components.active[3][6] = {
      provider = "diagnostic_warnings",
      icon = " ",
      hl = {
        fg = colors.yellow,
        bg = colors.bg,
      },
    }

    components.active[3][7] = {
      provider = "diagnostic_info",
      icon = " ",
      hl = {
        fg = colors.blue,
        bg = colors.bg,
      },
    }

    components.active[3][8] = {
      provider = "diagnostic_hints",
      icon = " ",
      hl = {
        fg = colors.cyan,
        bg = colors.bg,
      },
    }

    components.active[3][9] = {
      provider = function()
        local enc = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
        return " " .. enc:upper() .. " "
      end,
      hl = {
        fg = colors.violet,
        bg = colors.bg,
        style = "bold",
      },
      left_sep = " ",
    }

    components.active[3][10] = {
      provider = "position",
      hl = {
        fg = colors.fg,
        bg = colors.bg,
        style = "bold",
      },
      left_sep = " ",
    }

    components.active[3][11] = {
      provider = function()
        local current_line = vim.fn.line "."
        local total_lines = vim.fn.line "$"
        local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
        local line_ratio = current_line / total_lines
        local index = math.ceil(line_ratio * #chars)
        return " " .. chars[index] .. " "
      end,
      hl = {
        fg = colors.yellow,
        bg = colors.bg,
      },
    }

    components.inactive[1][1] = {
      provider = {
        name = "file_info",
        opts = {
          type = "relative",
        },
      },
      icon = "",
      hl = {
        fg = colors.gray,
        bg = colors.bg,
      },
    }

    components.inactive[2][1] = {
      provider = "position",
      hl = {
        fg = colors.gray,
        bg = colors.bg,
      },
    }

    feline.setup {
      theme = colors,
      components = components,
      vi_mode_colors = vi_mode_colors,
    }

    vim.o.showmode = false
    vim.o.laststatus = 3
  end,
}
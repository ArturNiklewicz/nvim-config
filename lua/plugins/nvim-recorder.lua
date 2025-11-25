-- nvim-recorder: Enhanced macro recording, playback, editing, and persistence
-- Simplified controls: q to start/stop, Q to play, <C-q> to switch slots
return {
  "chrisgrieser/nvim-recorder",
  dependencies = "rcarriga/nvim-notify",
  keys = {
    { "q", desc = " Start/Stop Recording" },
    { "Q", desc = " Play Recording" },
    { "<C-q>", desc = " Switch Macro Slot" },
    { "cq", desc = " Edit Macro" },
    { "dq", desc = " Delete All Macros" },
    { "yq", desc = " Yank Macro (for mapping)" },
  },
  config = function()
    require("recorder").setup({
      -- Named registers where macros are saved
      -- First register is default after startup
      slots = { "a", "b", "c", "d" },

      -- Static slots (use same register until manually switched)
      dynamicSlots = "static",

      mapping = {
        startStopRecording = "q",
        playMacro = "Q",
        switchSlot = "<C-q>",
        editMacro = "cq",
        deleteAllMacros = "dq",
        yankMacro = "yq",
        -- Breakpoint marker (use in normal mode during recording)
        addBreakPoint = "##",
      },

      -- Keep macros from previous sessions
      clear = false,

      -- Show notifications for macro operations
      lessNotifications = false,

      -- Use nerdfont icons
      useNerdfontIcons = true,

      -- Performance optimizations for high-count macro execution
      performanceOpts = {
        countThreshold = 100,
        lazyredraw = true,
        noSystemClipboard = true,
        autocmdEventsIgnore = {
          "TextChangedI",
          "TextChanged",
          "InsertLeave",
          "InsertEnter",
          "InsertCharPre",
        },
      },

      -- Share keymaps with nvim-dap (experimental)
      dapSharedKeymaps = false,
    })

    -- Update feline statusline with recorder components
    vim.defer_fn(function()
      local ok, feline = pcall(require, "feline")
      if not ok then return end

      local recorder = require("recorder")
      local colors = {
        bg = "#1e1e2e",
        red = "#f38ba8",
        green = "#a6e3a1",
        yellow = "#f9e2af",
        magenta = "#f5c2e7",
      }

      -- Get current feline config and add recorder components
      -- Recording status goes in the middle section
      local components = feline.statusline.components

      -- Add recording status to active[2] (middle section)
      if components and components.active and components.active[2] then
        -- Insert recording status before file info
        table.insert(components.active[2], 1, {
          provider = function()
            local status = recorder.recordingStatus()
            if status and status ~= "" then
              return " " .. status .. " "
            end
            return ""
          end,
          hl = {
            fg = colors.red,
            bg = colors.bg,
            style = "bold",
          },
        })
      end

      -- Add macro slots display to active[3] (right section)
      if components and components.active and components.active[3] then
        -- Insert at the beginning of right section
        table.insert(components.active[3], 1, {
          provider = function()
            local slots = recorder.displaySlots()
            if slots and slots ~= "" then
              return " " .. slots .. " "
            end
            return ""
          end,
          hl = {
            fg = colors.magenta,
            bg = colors.bg,
          },
        })
      end

      -- Force feline to refresh
      vim.cmd("redrawstatus")
    end, 100)
  end,
}

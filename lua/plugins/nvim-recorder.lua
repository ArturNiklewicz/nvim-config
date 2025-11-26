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

  end,
}

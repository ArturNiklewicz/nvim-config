-- Load environment variables from .env file
local function load_env()
  local env_file = vim.fn.stdpath("config") .. "/.env"
  if vim.fn.filereadable(env_file) == 1 then
    for line in io.lines(env_file) do
      local key, value = line:match("^([^=]+)=(.*)$")
      if key and value then
        vim.env[key] = value
      end
    end
  end
end

return {
  {
    "robitx/gp.nvim",
    config = function()
      load_env() -- Load .env file
      require("gp").setup({
        openai_api_key = vim.env.OPENAI_API_KEY,
        -- Or use other providers like Anthropic:
        -- providers = {
        --   anthropic = {
        --     endpoint = "https://api.anthropic.com/v1/messages",
        --     secret = vim.env.ANTHROPIC_API_KEY,
        --   },
        -- },
      })
    end,
    keys = {
      -- GP.nvim keybindings using <leader>p
      { "<leader>p", group = "GP.nvim" },
      { "<leader>pc", "<cmd>GpChatNew<cr>", desc = "New Chat" },
      { "<leader>pt", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
      { "<leader>pf", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
      { "<leader>pr", "<cmd>GpRewrite<cr>", mode = "v", desc = "Rewrite Selection" },
      { "<leader>pa", "<cmd>GpAppend<cr>", mode = "v", desc = "Append to Selection" },
      { "<leader>pi", "<cmd>GpImplement<cr>", mode = "v", desc = "Implement Selection" },
      { "<leader>pe", "<cmd>GpExplain<cr>", mode = "v", desc = "Explain Selection" },
      { "<leader>pu", "<cmd>GpUnitTests<cr>", mode = "v", desc = "Unit Tests" },
      -- Voice commands (requires SoX)
      { "<leader>pw", "<cmd>GpWhisper<cr>", desc = "Whisper (voice to chat)" },
      { "<leader>pW", "<cmd>GpWhisperRewrite<cr>", mode = "v", desc = "Whisper rewrite selection" },
    },
  },
}
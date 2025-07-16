-- Tests for Octo.nvim GitHub integration

describe("Octo GitHub Integration", function()
  local octo_available = false
  local gh_available = false
  
  before_each(function()
    -- Check if Octo plugin is available
    octo_available = pcall(require, "octo")
    
    -- Check if GitHub CLI is available
    gh_available = vim.fn.executable("gh") == 1
  end)
  
  describe("Plugin Loading", function()
    it("should have Octo plugin available", function()
      assert.is_true(octo_available, "Octo plugin not found")
    end)
    
    it("should have GitHub CLI available", function()
      assert.is_true(gh_available, "GitHub CLI (gh) not found in PATH")
    end)
  end)
  
  describe("Keybindings", function()
    it("should have GitHub keybindings registered", function()
      local mappings = vim.api.nvim_get_keymap("n")
      local github_mappings = {
        ["<Leader>gi"] = "List GitHub issues",
        ["<Leader>gI"] = "Create GitHub issue",
        ["<Leader>gp"] = "List pull requests",
        ["<Leader>gP"] = "Create pull request",
        ["<Leader>gr"] = "List repositories",
        ["<Leader>gs"] = "Search GitHub",
        ["<Leader>gv"] = "View PR in browser",
        ["<Leader>gc"] = "Show PR checks",
        ["<Leader>gm"] = "Merge current PR",
        ["<Leader>gb"] = "Create issue from current line",
        ["<Leader>gf"] = "Show PR diff",
        ["<Leader>go"] = "Checkout PR",
        ["<Leader>ga"] = "Add assignee",
        ["<Leader>gl"] = "Add label",
        ["<Leader>gC"] = "Add comment",
        ["<Leader>gR"] = "Start review",
        ["<Leader>g/"] = "Search GitHub repos",
      }
      
      for key, desc in pairs(github_mappings) do
        local found = false
        for _, mapping in ipairs(mappings) do
          if mapping.lhs == key then
            found = true
            assert.equals(desc, mapping.desc, string.format("Mapping %s has wrong description", key))
            break
          end
        end
        assert.is_true(found, string.format("GitHub mapping %s not found", key))
      end
    end)
  end)
  
  describe("Octo Commands", function()
    it("should have Octo command available", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.Octo, "Octo command not found")
    end)
    
    it("should have OctoReview user command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.OctoReview, "OctoReview command not found")
    end)
  end)
  
  describe("GitHub CLI Integration", function()
    it("should be able to check gh version", function()
      if gh_available then
        local result = vim.fn.system("gh --version")
        assert.is_not_nil(result:match("gh version"), "Failed to get gh version")
      else
        pending("GitHub CLI not available")
      end
    end)
    
    it("should handle gh auth status", function()
      if gh_available then
        -- This might fail if not authenticated, but should not error
        local result = vim.fn.system("gh auth status 2>&1")
        assert.is_string(result)
      else
        pending("GitHub CLI not available")
      end
    end)
  end)
  
  describe("Configuration", function()
    it("should use telescope as picker", function()
      if octo_available then
        local config = require("octo.config").values
        assert.equals("telescope", config.picker)
      else
        pending("Octo not loaded")
      end
    end)
    
    it("should have minimal mappings configured", function()
      if octo_available then
        local config = require("octo.config").values
        assert.is_not_nil(config.mappings)
        assert.is_not_nil(config.mappings.issue)
        assert.is_not_nil(config.mappings.pull_request)
      else
        pending("Octo not loaded")
      end
    end)
  end)
end)
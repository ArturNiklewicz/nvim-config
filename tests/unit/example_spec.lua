-- Example test file using plenary.nvim
-- This demonstrates how to write tests for your Neovim configuration

describe("Example Tests", function()
  -- Setup and teardown hooks
  before_each(function()
    -- Reset any state before each test
  end)

  after_each(function()
    -- Clean up after each test
  end)

  -- Basic assertion test
  it("should perform basic assertions", function()
    local result = 2 + 2
    assert.equals(4, result)
    assert.is_true(true)
    assert.is_false(false)
    assert.is_nil(nil)
  end)

  -- Testing vim functionality
  it("should test vim options", function()
    vim.opt.number = true
    assert.equals(true, vim.opt.number:get())
    
    vim.opt.relativenumber = false
    assert.equals(false, vim.opt.relativenumber:get())
  end)

  -- Testing keymappings
  it("should verify keymappings exist", function()
    -- Set a test mapping
    vim.keymap.set("n", "<leader>test", ":echo 'test'<CR>", { desc = "Test mapping" })
    
    -- Get all normal mode mappings
    local mappings = vim.api.nvim_get_keymap("n")
    local found = false
    
    for _, mapping in ipairs(mappings) do
      if mapping.lhs == "<Leader>test" then
        found = true
        break
      end
    end
    
    assert.is_true(found, "Test mapping not found")
  end)

  -- Testing custom functions
  it("should test custom functions", function()
    -- Example: Test a hypothetical utility function
    local function add_numbers(a, b)
      return a + b
    end
    
    assert.equals(5, add_numbers(2, 3))
    assert.equals(0, add_numbers(-5, 5))
  end)

  -- Async test example
  it("should handle async operations", function()
    local co = coroutine.create(function()
      local timer = vim.loop.new_timer()
      local done = false
      
      timer:start(10, 0, vim.schedule_wrap(function()
        done = true
        timer:stop()
        timer:close()
      end))
      
      -- Wait for timer
      vim.wait(100, function() return done end)
      assert.is_true(done)
    end)
    
    coroutine.resume(co)
  end)
end)

-- Plugin configuration tests
describe("Plugin Configuration", function()
  it("should have required plugins loaded", function()
    -- Check if lazy.nvim is available
    local ok, lazy = pcall(require, "lazy")
    assert.is_true(ok, "lazy.nvim not found")
    
    -- You can add more specific plugin checks here
  end)
end)

-- Configuration tests
describe("User Configuration", function()
  it("should load user configuration files", function()
    -- Test that configuration files can be required
    local configs = {
      "plugins.astrocore",
      "plugins.astroui",
      "plugins.astrolsp",
    }
    
    for _, config in ipairs(configs) do
      local ok = pcall(require, config)
      assert.is_true(ok, string.format("Failed to load %s", config))
    end
  end)
end)
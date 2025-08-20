-- Buffer navigation utilities
-- Provides helper functions for buffer management

local M = {}

-- Navigate to buffer by position (using bufferline's visual ordering)
function M.nav_to(position)
  -- BufferLineGoToBuffer navigates to the Nth visible buffer position
  -- This is exactly what we want - position-based navigation
  local success = pcall(vim.cmd, "BufferLineGoToBuffer " .. position)
  
  if not success then
    -- Fallback if bufferline is not available or position doesn't exist
    local buffers = vim.fn.getbufinfo({ buflisted = 1 })
    if buffers[position] and vim.api.nvim_buf_is_valid(buffers[position].bufnr) then
      vim.cmd("buffer " .. buffers[position].bufnr)
    else
      vim.notify("Buffer " .. position .. " does not exist", vim.log.levels.WARN)
    end
  end
end

-- Get buffer count
function M.count()
  return #vim.fn.getbufinfo({ buflisted = 1 })
end

-- Close buffer with confirmation for unsaved changes
function M.close_smart(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  
  if vim.bo[bufnr].modified then
    vim.ui.select(
      { "Save and close", "Close without saving", "Cancel" },
      { prompt = "Buffer has unsaved changes:" },
      function(choice)
        if choice == "Save and close" then
          vim.cmd("write")
          require("astrocore.buffer").close(bufnr)
        elseif choice == "Close without saving" then
          require("astrocore.buffer").close(bufnr, true)
        end
      end
    )
  else
    require("astrocore.buffer").close(bufnr)
  end
end

-- Close all buffers except current
function M.close_others()
  local current = vim.api.nvim_get_current_buf()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  
  for _, buf in ipairs(buffers) do
    if buf.bufnr ~= current then
      require("astrocore.buffer").close(buf.bufnr)
    end
  end
end

-- Navigate to last buffer
function M.nav_to_last()
  vim.cmd("buffer #")
end

return M
-- Test script for Claude Explain plugin
-- This demonstrates the functionality and serves as a test case

local function fibonacci(n)
  if n <= 1 then
    return n
  end
  return fibonacci(n - 1) + fibonacci(n - 2)
end

local function quicksort(arr, low, high)
  if low < high then
    local pi = partition(arr, low, high)
    quicksort(arr, low, pi - 1)
    quicksort(arr, pi + 1, high)
  end
end

-- Test the plugin functionality:
-- 1. Select the fibonacci function above and press Ctrl+E
-- 2. Put cursor on any word and press Ctrl+E
-- 3. Create an intentional error and press <Leader>exe on the diagnostic
-- 4. Put cursor in a function and press <Leader>exf

print("Claude Explain plugin test file loaded")
print("Use Ctrl+E on selected code to get explanations")

-- Example with potential error for testing error explanation
local undefined_variable = some_undefined_function()
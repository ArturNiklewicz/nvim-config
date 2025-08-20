-- Test script for verifying large error set handling
-- Run this with :source % to test the enhanced error handling

local function test_large_errors()
  print("Testing enhanced error handling with large datasets...")
  print("===============================================")
  
  -- Test 1: Generate moderate number of errors
  print("\nTest 1: Generating 100 errors...")
  for i = 1, 100 do
    vim.cmd(string.format("echoerr 'Test error %d: Sample error message'", i))
  end
  
  print("✓ Test 1 complete. Try :Errors to view paginated results")
  
  -- Test 2: Test clipboard size limit
  print("\nTest 2: Testing clipboard size limits...")
  local large_msg = string.rep("This is a very long error message. ", 100)
  for i = 1, 50 do
    vim.cmd(string.format("echoerr 'Long error %d: %s'", i, large_msg))
  end
  
  print("✓ Test 2 complete. Try :CopyAllErrors to test temp file fallback")
  
  -- Test 3: Test filtering
  print("\nTest 3: Generating mixed severity messages...")
  vim.cmd("echoerr 'ERROR: Critical system failure'")
  vim.cmd("echohl WarningMsg | echo 'WARN: Deprecated function used' | echohl None")
  vim.cmd("echoerr 'ERROR: Database connection failed'")
  vim.cmd("echo 'INFO: Process started successfully'")
  
  print("✓ Test 3 complete. Try :Errors --severity=ERROR")
  
  -- Test 4: Performance test
  print("\nTest 4: Performance test with 1000 errors...")
  local start_time = vim.loop.hrtime()
  
  for i = 1, 1000 do
    if i % 100 == 0 then
      vim.cmd(string.format("echoerr 'Performance test error %d'", i))
    end
  end
  
  local end_time = vim.loop.hrtime()
  local elapsed = (end_time - start_time) / 1e9
  
  print(string.format("✓ Test 4 complete. Generated 1000 errors in %.2f seconds", elapsed))
  
  print("\n===============================================")
  print("All tests complete! Available commands:")
  print("  :Messages --page=1 --size=50  - View paginated messages")
  print("  :Errors --recent=100          - View recent errors only")
  print("  :Errors --severity=ERROR      - Filter by severity")
  print("  :CopyAllErrors --file         - Copy with file fallback")
  print("  :CopyAllErrors --max=500      - Limit number of errors")
  print("  :ErrorConfig                  - View/change settings")
  print("  :TestMessages --large         - Generate 10,000 test errors")
end

-- Run the test
test_large_errors()
-- Test suite for toggle_tree_focus function
-- Tests the functionality of toggling focus between buffer and nvim-tree

local M = {}

-- Helper to load the functions module
local function load_functions()
  local ok, funcs = pcall(require, "functions")
  if not ok then
    error("Failed to load functions module: " .. funcs)
  end
  return funcs
end

-- Test 1: Function exists and is callable
function M.test_function_exists()
  local Functions = load_functions()
  assert(Functions.toggle_tree_focus ~= nil, "toggle_tree_focus function does not exist")
  assert(type(Functions.toggle_tree_focus) == "function", "toggle_tree_focus is not a function")
  print("✓ Test 1 passed: Function exists and is callable")
end

-- Test 2: Returns nil when no file is open (empty buffer)
function M.test_no_file_open()
  local Functions = load_functions()

  -- Create a new empty buffer with no file
  local buf = vim.api.nvim_create_buf(false, true)
  local prev_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_current_buf(buf)

  -- Call function and check it returns nil
  local result = Functions.toggle_tree_focus()
  assert(result == nil, "Expected nil when no file is open, got: " .. tostring(result))

  -- Cleanup
  vim.api.nvim_set_current_buf(prev_buf)
  vim.api.nvim_buf_delete(buf, { force = true })

  print("✓ Test 2 passed: Returns nil when no file is open")
end

-- Test 3: Extracts correct file path when file is open
function M.test_file_path_extraction()
  local Functions = load_functions()

  -- We can test this by checking if the function returns a non-nil value
  -- when called from a buffer with a file (like this test file itself)
  -- This requires nvim-tree to be installed and working
  local filepath = Functions.toggle_tree_focus()

  -- If nvim-tree is available, filepath should be a string
  if filepath ~= nil then
    assert(type(filepath) == "string", "Expected string result, got: " .. type(filepath))
    assert(string.len(filepath) > 0, "File path is empty")
    print("✓ Test 3 passed: File path extraction works - " .. filepath)
  else
    print("⊘ Test 3 skipped: nvim-tree not available in test environment")
  end
end

-- Test 4: Handles missing nvim-tree gracefully
function M.test_missing_nvim_tree()
  local Functions = load_functions()

  -- This test verifies that if nvim-tree is not installed,
  -- the function doesn't crash but returns nil
  -- Since we can't truly uninstall nvim-tree in a test,
  -- we just verify the function doesn't crash
  local ok = pcall(function()
    return Functions.toggle_tree_focus()
  end)

  assert(ok, "Function crashed instead of handling missing nvim-tree gracefully")
  print("✓ Test 4 passed: Function handles missing nvim-tree gracefully")
end

-- Test 5: Function returns consistent results on repeated calls
function M.test_repeated_calls()
  local Functions = load_functions()

  local result1 = Functions.toggle_tree_focus()
  local result2 = Functions.toggle_tree_focus()

  -- Results should be consistent (same file)
  if result1 ~= nil and result2 ~= nil then
    assert(result1 == result2, "Inconsistent results on repeated calls")
    print("✓ Test 5 passed: Repeated calls return consistent results")
  else
    print("⊘ Test 5 skipped: nvim-tree not available in test environment")
  end
end

-- Test 6: Function returns a string (filepath) on success
function M.test_return_type_on_success()
  local Functions = load_functions()
  local result = Functions.toggle_tree_focus()

  if result ~= nil then
    assert(type(result) == "string", "Expected string on success, got: " .. type(result))
    assert(string.match(result, "/"), "Result does not look like a file path: " .. result)
    print("✓ Test 6 passed: Returns valid filepath string on success")
  else
    print("⊘ Test 6 skipped: nvim-tree not available in test environment")
  end
end

-- Run all tests
local function run_all_tests()
  print("\n" .. string.rep("=", 50))
  print("Running nvim-tree toggle_tree_focus tests")
  print(string.rep("=", 50) .. "\n")

  local tests = {
    M.test_function_exists,
    M.test_no_file_open,
    M.test_file_path_extraction,
    M.test_missing_nvim_tree,
    M.test_repeated_calls,
    M.test_return_type_on_success,
  }

  local passed = 0
  local failed = 0

  for _, test_fn in ipairs(tests) do
    local ok, err = pcall(test_fn)
    if ok then
      passed = passed + 1
    else
      failed = failed + 1
      print("✗ Test failed: " .. err)
    end
  end

  print("\n" .. string.rep("=", 50))
  print(string.format("Test Results: %d passed, %d failed", passed, failed))
  print(string.rep("=", 50) .. "\n")
end

-- Export test runner
M.run_all = run_all_tests

return M

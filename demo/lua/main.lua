-- main.lua: Main entry point for the LSP demo
--
-- This file demonstrates LSP features like:
-- - grn: Rename variables across multiple files
-- - gr: See all places where a function is used
-- - gd: Jump to where something is defined
-- - gi: Find all implementations of a function

local math_module = require("demo.lua.math")
local utils_module = require("demo.lua.utils")

---Main function showcasing all the demo utilities
---@return table
local function main()
  -- Test data
  local numbers = { 1, 2, 3, 4, 5 }

  -- Test calculate_total (defined in math.lua)
  -- Try: gd to jump to the definition
  local total = math_module.calculate_total(numbers)
  print("Total: " .. total)

  -- Test calculate_product (defined in math.lua)
  -- Try: grn on calculate_product to rename it everywhere
  local product = math_module.calculate_product(numbers)
  print("Product: " .. product)

  -- Test calculate_average (defined in utils.lua)
  -- Try: gr on calculate_average to see all references
  local average = utils_module.calculate_average(numbers)
  print("Average: " .. average)

  -- Test apply_discount
  -- Try: K on apply_discount to see the docstring
  local price = 100.0
  local discount = 10.0
  local final_price = utils_module.apply_discount(price, discount)
  print(string.format("Price after %.0f%% discount: $%.2f", discount, final_price))

  -- Test chain_operations
  -- Try: gr on chain_operations to see where it's called
  local result = utils_module.chain_operations(5)
  print("Chain result: " .. result)

  return {
    total = total,
    product = product,
    average = average,
    final_price = final_price,
    chain_result = result,
  }
end

-- Run the main function
if arg ~= nil and arg[0]:match("main%.lua$") then
  local output = main()
  print("\nFinal results:")
  for key, value in pairs(output) do
    print(string.format("  %s: %s", key, tostring(value)))
  end
end

return { main = main }

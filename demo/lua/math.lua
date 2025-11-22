-- math.lua: Core mathematical functions demonstrating LSP features
--
-- This file is part of the LSP demo. Try these keybindings:
-- - gd: Jump to definition of functions
-- - gi: Jump to implementations
-- - grn: Rename a function/variable (workspace-wide)
-- - gra: Code actions (try adding type hints)

---Add two numbers together
---@param a number
---@param b number
---@return number
local function add(a, b)
  return a + b
end

---Multiply two numbers
---@param a number
---@param b number
---@return number
local function multiply(a, b)
  return a * b
end

---Calculate the total of a list of values
---@param values table
---@return number
local function calculate_total(values)
  local result = 0
  for _, value in ipairs(values) do
    result = add(result, value)
  end
  return result
end

---Calculate the product of a list of values
---@param values table
---@return number
local function calculate_product(values)
  local result = 1
  for _, value in ipairs(values) do
    result = multiply(result, value)
  end
  return result
end

return {
  add = add,
  multiply = multiply,
  calculate_total = calculate_total,
  calculate_product = calculate_product,
}

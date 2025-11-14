-- utils.lua: Utility functions that import from math.lua
--
-- This file demonstrates importing functions from another module
-- and using LSP to find references and implementations

local math_module = require("demo.lua.math")

---Calculate the average of a list of values
---@param values table
---@return number
local function calculate_average(values)
	local total = math_module.calculate_total(values)
	return total / #values
end

---Apply a discount percentage to a price
---@param price number The original price
---@param discount number The discount percentage (0-100)
---@return number The final price after discount
local function apply_discount(price, discount)
	local discount_amount = price * (discount / 100)
	return price - discount_amount
end

---Chain multiple operations together
---@param value number The starting value
---@return number The result after chaining operations
local function chain_operations(value)
	local step1 = math_module.add(value, 10)
	local step2 = math_module.multiply(step1, 2)
	return math_module.add(step2, 5)
end

return {
	calculate_average = calculate_average,
	apply_discount = apply_discount,
	chain_operations = chain_operations,
}

-- Test file for Lua LSP and linting
-- Contains intentional errors for testing diagnostics

local M = {}

-- Intentional unused variable
local an_junused_var = 10

-- Function with intentional errors
function M.calculate_sum(a, b)
	-- Intentional undefined global
	return a + b + an_undefined_global
end

-- Unused function
local function an_unused_function()
	local x = 5
	-- Missing return
end

-- Intentional syntax issues for testing
M.test_table = {
	key1 = "value1",
	key2 = "value2",
	-- Intentional long line for testing line length warnings: this is a very long comment that should trigger a line length warning in luacheck if configured
}

return M

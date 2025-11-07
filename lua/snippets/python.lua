local snip_status_ok, ls = pcall(require, "luasnip")
if not snip_status_ok then
	return
end

local snip = ls.snippet
local node = ls.snippet_node
local text = ls.text_node
local insert = ls.insert_node
local func = ls.function_node
local choice = ls.choice_node
local dynamicn = ls.dynamic_node

local date = function()
	return { os.date("%Y-%m-%d %H:%M:%S") }
end

-- for choice nodes, use <C-j> and <C-k> to toggle through the options
-- see luasnip.lua:125
return {
	snip("shebang", {
		text({ "#!/usr/bin/env python", "" }),
		insert(0),
	}),
}

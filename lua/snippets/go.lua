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
	snip("test", {
		text("func "),
		insert(1, "Name"),
		text("(t *testing.T)"),
		text({ " {", "" }),
		text("\t"),
		insert(0),
		text({ "", "}" }),
	}),
	snip("typei", {
		text("type "),
		insert(1, "Name"),
		text({ " interface {", "" }),
		text("\t"),
		insert(0),
		text({ "", "}" }),
	}),
	snip("types", {
		text("type "),
		insert(1, "Name"),
		text({ " struct {", "" }),
		text("\t"),
		insert(0),
		text({ "", "}" }),
	}),
	snip("func", {
		text("func "),
		insert(1, "Name"),
		text("("),
		insert(2),
		text(")"),
		insert(3),
		text({ " {", "" }),
		text("\t"),
		insert(0),
		text({ "", "}" }),
	}),
	snip("if", {
		text("if "),
		insert(1, "true"),
		text({ " {", "" }),
		text("\t"),
		insert(0),
		text({ "", "}" }),
	}),

	snip("fori", {
		text("for "),
		insert(1, "i := 0"),
		text(";"),
		insert(2, "i < 10"),
		text(";"),
		insert(3, "i++"),
		text({ " {", "" }),
		text("\t"),
		insert(0),
		text({ "", "}" }),
	}),
	snip("forr", {
		text("for "),
		insert(1, "k, v"),
		text(" := range "),
		insert(2, "expr"),
		text({ " {", "" }),
		text("\t"),
		insert(0),
		text({ "", "}" }),
	}),
}

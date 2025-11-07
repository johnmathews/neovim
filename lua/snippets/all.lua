local snip_status_ok, ls = pcall(require, "luasnip")
if not snip_status_ok then
	print("luasnip not found")
	return
end

-- some shorthands...
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

-- Make sure to not pass an invalid command, as io.popen() may write over nvim-text.
local function bash(_, _, command)
	local file = io.popen(command, "r")
	local res = {}
	for line in file:lines() do
		table.insert(res, line)
	end
	return res
end

return {
	-- all is filetype selector
	snip({
		trig = "date",
		namr = "Date",
		dscr = "Date in the form of YYYY-MM-DD",
	}, {
		func(date, {}),
	}),
	snip({
		trig = "pwd",
		namr = "PWD",
		dscr = "Path to current working directory",
	}, {
		func(bash, {}, "pwd"),
	}),
	snip({
		trig = "fn",
		namr = "Full Name",
		dscr = "Name and Surname",
	}, {
		text("John Mathews"),
		insert(0),
	}),
	snip({
		trig = "mo",
		namr = "vim mode line",
		dscr = "insert a mode line",
	}, {
		text("# vim: ft="),
		insert(1, "zsh"),
		text(":"),
		insert(2),
	}),
}

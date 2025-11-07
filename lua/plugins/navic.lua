local ok, navic = pcall(require, "nvim-navic")
if not ok then
	return
end

navic.setup({
	highlight = true,
	separator = "  ",
	depth_limit = 5,
	safe_output = true,
	lsp = {
		auto_attach = false,
	},
	icons = {
		File = "󰈙 ",
		Module = " ",
		Namespace = "󰌗 ",
		Package = " ",
		Class = "󰠱 ",
		Method = "󰆧 ",
		Property = "󰜢 ",
		Field = "󰇽 ",
		Constructor = " ",
		Enum = "󰒻 ",
		Interface = " ",
		Function = "󰊕 ",
		Variable = "󰀫 ",
		Constant = "󰏿 ",
		String = "󰉿 ",
		Number = "󰎠 ",
		Boolean = " ",
		Array = "󰅪 ",
		Object = "󰅩 ",
		Key = "󰌋 ",
		Null = "󰟢 ",
		EnumMember = " ",
		Struct = "󰙅 ",
		Event = " ",
		Operator = "󰆕 ",
		TypeParameter = "󰆧 ",
	},
})

local excluded_filetypes = {
	qf = true,
	Trouble = true,
	alpha = true,
	help = true,
	neo_tree = true,
	NvimTree = true,
	lazy = true,
	mason = true,
	dashboard = true,
	[""] = true,
}

_G.__navic_winbar = function()
	if excluded_filetypes[vim.bo.filetype] then
		return ""
	end

	if navic.is_available() then
		local location = navic.get_location()
		if location ~= "" then
			return location
		end
	end

	return ""
end

vim.o.winbar = "%{%v:lua.__navic_winbar()%}"

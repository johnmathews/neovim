-- Noice: Enhanced UI for messages, cmdline, and popups
local ok, noice = pcall(require, "noice")
if not ok then
	return
end

noice.setup({
	cmdline = {
		format = {
			cmdline = { pattern = "^:", icon = "", lang = "vim" },
			search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
			search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
		},
	},
	lsp = {
		progress = { enabled = true },
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
	},
	messages = {
		view = "notify",
		view_error = "notify",
		view_warn = "notify",
	},
	presets = {
		bottom_search = true,
		command_palette = true,
		long_message_to_split = true,
		lsp_doc_border = true,
	},
	views = {
		cmdline_popup = {
			border = {
				style = "rounded",
			},
			position = {
				row = "30%",
				col = "50%",
			},
			size = {
				width = 60,
				height = "auto",
			},
			win_options = {
				winblend = 10,
			},
		},
		popupmenu = {
			relative = "editor",
			position = {
				row = "40%",
				col = "50%",
			},
			size = {
				width = 60,
				height = 10,
			},
			border = {
				style = "rounded",
			},
			win_options = {
				winblend = 10,
			},
		},
	},
	routes = {
		{
			filter = {
				event = "msg_show",
				kind = "",
				find = "written",
			},
			opts = { skip = true },
		},
	},
})

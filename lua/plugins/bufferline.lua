local ok, bufferline = pcall(require, "bufferline")
if not ok then
	return
end

bufferline.setup({
	options = {
		mode = "buffers",
		style_preset = {
			bufferline.style_preset.no_italic,
			bufferline.style_preset.no_bold,
		},
		diagnostics = "nvim_lsp",
		diagnostics_indicator = function(_, _, diag)
			local icons = { error = " ", warning = " ", info = " " }
			for severity, icon in pairs(icons) do
				if diag[severity] then
					return icon .. diag[severity]
				end
			end
			return ""
		end,
		custom_areas = {},
		show_close_icon = false,
		show_buffer_close_icons = false,
		separator_style = "thin",
		always_show_bufferline = false,
		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer",
				highlight = "Directory",
				separator = true,
			},
			{
				filetype = "neo-tree",
				text = "File Explorer",
				highlight = "Directory",
				separator = true,
			},
		},
		hover = {
			enabled = true,
			delay = 150,
			reveal = { "close" },
		},
		indicator = {
			style = "underline",
		},
	},
})

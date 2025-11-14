-- Minimap: Code minimap with git and diagnostic integration
local ok, mini_map = pcall(require, "mini.map")
if not ok then
	return
end

mini_map.setup({
	integrations = {
		mini_map.gen_integration.builtin_search(),
		mini_map.gen_integration.diff(),
		mini_map.gen_integration.diagnostic({
			error = "DiagnosticFloatingError",
			warn = "DiagnosticFloatingWarn",
			info = "DiagnosticFloatingInfo",
			hint = "DiagnosticFloatingHint",
		}),
		mini_map.gen_integration.gitsigns(),
	},
	symbols = {
		encode = mini_map.gen_encode_symbols.dot("4x2"),
	},
	window = {
		side = "right",
		width = 12,
		winblend = 15,
		show_integration_count = false,
	},
})

vim.keymap.set("n", "<leader>mm", mini_map.toggle, { desc = "MiniMap: toggle" })
vim.keymap.set("n", "<leader>mr", mini_map.refresh, { desc = "MiniMap: refresh" })

-- local excluded = {
-- 	alpha = true,
-- 	checkhealth = true,
-- 	dashboard = true,
-- 	gitcommit = true,
-- 	help = true,
-- 	lazy = true,
-- 	mason = true,
-- 	NvimTree = true,
-- 	qf = true,
-- 	Trouble = true,
-- }

-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
-- 	callback = function()
-- 		if excluded[vim.bo.filetype] or vim.api.nvim_buf_line_count(0) < 80 then
-- 			mini_map.close()
-- 			return
-- 		end
-- 		mini_map.open()
-- 	end,
-- })

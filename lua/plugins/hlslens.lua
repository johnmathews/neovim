-- nvim-hlslens: Enhanced search with customizable virtual text showing match count
local status_ok, hlslens = pcall(require, "hlslens")
if not status_ok then
	return
end

hlslens.setup({
	-- Disable all virtual text rendering with empty override_lens
	override_lens = function(_render, _posList, _nearest, _idx, _relIdx)
		-- Do nothing - suppress all virtual text
	end,
})

-- Integrate with search commands
local kopts = { noremap = true, silent = true }

vim.api.nvim_set_keymap(
	"n",
	"n",
	[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
	kopts
)
vim.api.nvim_set_keymap(
	"n",
	"N",
	[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
	kopts
)
vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

-- Clear search highlight when pressing <Esc> in normal mode
vim.api.nvim_set_keymap("n", "<Esc>", ":noh<CR>", kopts)

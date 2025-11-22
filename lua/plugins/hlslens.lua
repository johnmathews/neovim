-- nvim-hlslens: Enhanced search with customizable virtual text showing match count
local status_ok, hlslens = pcall(require, "hlslens")
if not status_ok then
	return
end

hlslens.setup({
	-- Disable command-line virtual text previews and lens overlays
	auto_enable = true,
	nearest_only = true,
  nearest_float_when = 'auto',
})

-- Integrate with search commands
local kopts = { noremap = true, silent = true }

vim.api.nvim_set_keymap( "n", "n", [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap( "n", "N", [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

-- Clear search highlight when pressing <Esc> in normal mode
vim.api.nvim_set_keymap("n", "<Esc>", ":noh<CR>", kopts)

-- nvim-hlslens: Enhanced search with customizable virtual text showing match count
local status_ok, hlslens = pcall(require, "hlslens")
if not status_ok then
	return
end

hlslens.setup({
	-- Customize the virtual text to show only match count, not the search pattern
	override_lens = function(render, posList, nearest, idx, relIdx)
		local sfw = vim.v.searchforward == 1
		local indicator, text, chunks
		local absRelIdx = math.abs(relIdx)

		if absRelIdx > 1 then
			indicator = string.format("%d%s", absRelIdx, sfw and "▼" or "▲")
		elseif absRelIdx == 1 then
			indicator = sfw and "▼" or "▲"
		else
			indicator = ""
		end

		---@diagnostic disable-next-line: deprecated
		local lnum, col = unpack(posList[idx])
		if nearest then
			-- Show match count on the current match: [1/5]
			local cnt = #posList
			text = string.format("[%d/%d]", idx, cnt)
			chunks = { { " ", "Ignore" }, { text, "HlSearchLensNear" } }
		else
			-- Show indicator on other matches
			text = indicator
			chunks = { { " ", "Ignore" }, { text, "HlSearchLens" } }
		end
		render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
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

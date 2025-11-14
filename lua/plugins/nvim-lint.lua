-- lua/plugins/nvim-lint.lua

local lint = require("lint")
lint.linters_by_ft = {
	python = { "ruff" },
	lua = { "luacheck" },
	javascript = { "eslint_d" },
	typescript = { "eslint_d" },
	markdown = { "markdownlint-cli2" },
	sh = { "shellcheck" },
	bash = { "shellcheck" },
}

-- Run linters on keystroke (real-time feedback) and on save
local group = vim.api.nvim_create_augroup("Linting", { clear = true })
vim.api.nvim_create_autocmd(
	{ "BufEnter", "BufWinEnter", "BufWritePost", "TextChanged", "TextChangedI", "InsertLeave" },
	{
		group = group,
		callback = function()
			if lint.linters_by_ft[vim.bo.filetype] then
				lint.try_lint()
			end
		end,
	}
)

-- Manual
vim.keymap.set("n", "<leader>cl", function()
	require("lint").try_lint()
end, { desc = "Run lint" })

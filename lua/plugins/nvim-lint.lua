-- lua/plugins/nvim-lint.lua

local lint = require("lint")
lint.linters_by_ft = {
	python = { "ruff" },
	javascript = { "eslint_d" },
	typescript = { "eslint_d" },
	markdown = { "markdownlint-cli2" },
	sh = { "shellcheck" },
	bash = { "shellcheck" },
}

-- Run linters on save/leave insert
local group = vim.api.nvim_create_augroup("Linting", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
	group = group,
	callback = function()
		if lint.linters_by_ft[vim.bo.filetype] then
			lint.try_lint()
		end
	end,
})

-- Manual
vim.keymap.set("n", "<leader>cl", function()
	require("lint").try_lint()
end, { desc = "Run lint" })

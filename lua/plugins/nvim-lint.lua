-- lua/plugins/nvim-lint.lua

local lint = require("lint")
lint.linters_by_ft = {
	python = { "ruff", "mypy" }, -- mypy optional if you configure it
	javascript = { "eslint_d" },
	typescript = { "eslint_d" },
	sh = { "shellcheck" },
	markdown = { "markdownlint-cli2" },
}

-- Run linters on save/leave insert
local group = vim.api.nvim_create_augroup("Linting", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
	group = group,
	callback = function()
		-- Run only if linters exist for this ft
		if lint.linters_by_ft[vim.bo.filetype] then
			lint.try_lint()
		end
	end,
})
-- Manual
vim.keymap.set("n", "<leader>cl", function()
	require("lint").try_lint()
end, { desc = "Run lint" })

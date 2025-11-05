local ok_mason, mason = pcall(require, "mason")
if not ok_mason then
	return
end

mason.setup({
	ui = {
		border = "rounded",
		check_outdated_packages_on_open = false,
	},
})

-- Ensure non-LSP tools are installed (formatters/linters/dap/etc.)
local ok_mti, mti = pcall(require, "mason-tool-installer")
if ok_mti then
	mti.setup({
		ensure_installed = {
			-- formatters
			"stylua",
			"shfmt",
			"prettierd",
			"biome",
			"black",
			"isort",
			"ruff",
			-- linters
			"eslint_d",
			"markdownlint-cli2",
			"shellcheck",
			"mypy",
		},
		auto_update = false,
		run_on_start = true,
	})
end

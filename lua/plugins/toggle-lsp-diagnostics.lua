-- https://github.com/WhoIsSethDaniel/toggle-lsp-diagnostics.nvim
local status_ok, lsp_diagnostics = pcall(require, "toggle_lsp_diagnostics")

if not status_ok then
	return
end

-- this cannot be local if anything in the module is to be used as a keybind
Functions_ok, Functions = pcall(require, "functions")
if not Functions_ok then
	print("luaFunctions could not be loaded")
	return
end

lsp_diagnostics.init({
	start_on = true,
	underline = true,
	signs = true,
	virtual_text = false,
	source = "always",
})

-- this helper function is only used locally, why?
local function map(mode, l, r, opts)
	opts = opts or {}
	opts.buffer = bufnr
	vim.keymap.set(mode, l, r, opts)
end

map("n", "<Tab>dd", ":lua Functions.toggle_diagnostics()<CR>", KeymapOptions("Cycle diagnostics display"))
-- map("n", "<Tab>dd", "<Plug>(toggle-lsp-diag)", KeymapOptions("Diagnostics: Toggle signs and vtext")) -- :ToggleDiag

map("n", "<Tab>ds", "<Plug>(toggle-lsp-diag-signs)", KeymapOptions("Diagnostics: Toggle signs"))
map("n", "<Tab>du", "<Plug>(toggle-lsp-diag-underline)", KeymapOptions("Diagnostics: Toggle underline"))

map("n", "<Tab>df", "<Plug>(toggle-lsp-diag-off)", KeymapOptions("Diagnostics: Off")) --:ToggleDiagOfF
map("n", "<Tab>dn", "<Plug>(toggle-lsp-diag-on)", KeymapOptions("Diagnostics: On")) -- :ToggleDiagOn

-- map("n", "<Tab>dt", "<Plug>(toggle-lsp-diag-vtext)|:lua Functions.setDiagnosticConfig()<CR>", KeymapOptions("Diagnostics: Toggle virtual text"))
map(
	"n",
	"<Tab>dt",
	":lua Functions.setDiagnosticConfig()<CR>",
	KeymapOptions("Toggle lsp diagnostics (incl. language server name)")
)

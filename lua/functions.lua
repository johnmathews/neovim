local M = {}

function M.asyncGitCommitAndPush(commitMessage)
	if commitMessage == nil or commitMessage == "" then
		commitMessage = "quick commit" -- Default commit message
	end

	vim.loop.spawn("git", {
		args = { "rev-parse", "--inside-work-tree" },
		cwd = vim.loop.cwd(),
	}, function(code)
		if code ~= 0 then
			vim.schedule(function()
				vim.api.nvim_out_write("Can't commit, not in a git repository\n")
			end)
			return
		end

		vim.schedule(function()
			vim.fn.system("git add .")
			vim.fn.system('git commit -m "' .. commitMessage .. '"')
			vim.fn.system("git push")
			vim.api.nvim_out_write('git commit --all --message "' .. commitMessage .. '"\n')
		end)
	end)
end

M.active_tools = function()
	local bufnr = vim.api.nvim_get_current_buf()

	-- LSP clients
	local lsp = {}
	for _, c in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		table.insert(lsp, c.name)
	end

	-- Conform (formatters)
	local fmt = {}
	pcall(function()
		local conform = require("conform")
		for _, f in ipairs(conform.list_formatters(bufnr)) do
			table.insert(fmt, f.name or f)
		end
	end)

	-- nvim-lint (linters)
	local linters = {}
	pcall(function()
		local lint = require("lint")
		local ft = vim.bo[bufnr].filetype
		local by_ft = lint.linters_by_ft or {}
		for _, l in ipairs(by_ft[ft] or {}) do
			table.insert(linters, l)
		end
	end)

	vim.notify(
		("%s\n%s\n%s"):format(
			"LSP: " .. (#lsp > 0 and table.concat(lsp, ", ") or "—"),
			"Formatters: " .. (#fmt > 0 and table.concat(fmt, ", ") or "—"),
			"Linters: " .. (#linters > 0 and table.concat(linters, ", ") or "—")
		),
		vim.log.levels.INFO,
		{ title = "Active_Tools" }
	)
end

-- toggle the quickfix window
-- in mappings.lua gq is mapped to this
vim.cmd([[
  function! ToggleQuickFix()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen 15
      setlocal norelativenumber
    else
      cclose
    endif
  endfunction
]])

-- blog post
vim.cmd([[
function! s:NewPost(fn)
  execute "e " . "~/projects/blog/data/blog/" . a:fn . ".md"
endfunction
command! -nargs=1 Mp call s:NewPost(<q-args>)
]])

local diagnostic_state = 1
function M.cycle_diagnostics()
	if diagnostic_state == 1 then
		-- Mode 1: Signs and Underlines
		vim.diagnostic.config({
			signs = true,
			underline = true,
			virtual_text = false,
			virtual_lines = false,
		})
		vim.notify("Diagnostics: Signs and Underlines", vim.log.levels.INFO)
		diagnostic_state = 2
	elseif diagnostic_state == 2 then
		-- Mode 2: Virtual Text (at end of line)
		vim.diagnostic.config({
			signs = true,
			underline = true,
			virtual_text = true,
			virtual_lines = false,
		})
		vim.notify("Diagnostics: Virtual Text", vim.log.levels.INFO)
		diagnostic_state = 3
	elseif diagnostic_state == 3 then
		-- Mode 3: Virtual Lines (new lines below)
		vim.diagnostic.config({
			signs = true,
			underline = true,
			virtual_text = false,
			virtual_lines = true,
		})
		vim.notify("Diagnostics: Virtual Lines", vim.log.levels.INFO)
		diagnostic_state = 4
	else
		-- Mode 4: Disabled
		vim.diagnostic.config({
			signs = false,
			underline = false,
			virtual_text = false,
			virtual_lines = false,
		})
		vim.notify("Diagnostics: Disabled", vim.log.levels.INFO)
		diagnostic_state = 1
	end
end

return M

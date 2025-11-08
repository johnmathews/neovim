function PrintTable(tbl, indent)
	local formatting
	if not indent then
		indent = 0
	end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			PrintTable(v, indent + 1)
		else
			print(formatting .. tostring(v))
		end
	end
end

local M = {}

-- Function to toggle diagnostic configuration
function M.setDiagnosticConfig()
	local current_config = vim.diagnostic.config()

	-- print("before")
	-- printTable(vim.diagnostic.config(), 2)

	local custom_config

	if type(current_config.virtual_text) == "table" and current_config.virtual_text["source"] == true then
		custom_config = {
			virtual_text = false,
		}
	else
		custom_config = {
			severity_sort = true,
			virtual_text = {
				source = true,
			},
		}
	end

	-- set the configuration
	vim.diagnostic.config(custom_config)

	-- print("after")
	-- printTable(vim.diagnostic.config(), 2)
end

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

-- convert ascii typographuc quotes to normal quotes including slanty quotes,
function M.Convert_smart_and_fancy_ascii_chars_to_normal_chars()
	vim.cmd([[
    exe 'normal! ma' | %!iconv -f utf-8 -t ascii//translit | if search('pattern') == 0 | exe 'normal! `a' | endif
  ]])
end

M.toggle_diagnostics = (function()
	local modes = {
		{ name = "Normal", vt = false, vl = false, signs = true, underline = true },
		{
			name = "Text",
			vt = { source = true, spacing = 1, prefix = "" },
			vl = false,
			signs = true,
			underline = true,
		},
		{ name = "Lines", vt = false, vl = { only_current_line = false }, signs = true, underline = true },
		{ name = "Silent", vt = false, vl = false, signs = false, underline = false },
	}

	local i = 1
	return function()
		local m = modes[i]
		vim.diagnostic.config({
			virtual_text = m.vt,
			virtual_lines = m.vl,
			signs = m.signs,
			underline = m.underline,
			severity_sort = true,
		})
		vim.notify(("Diagnostics mode: %s"):format(m.name), vim.log.levels.INFO, { title = "LSP_Diagnostics" })
		i = (i % #modes) + 1
	end
end)()

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

-- Clear all registers (letters, numbers, and special)
function M.clear_all_registers()
	local regs = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-="*+'
	for i = 1, #regs do
		local reg = regs:sub(i, i)
		vim.fn.setreg(reg, "")
	end
	vim.cmd("wshada!") -- Write shada to persist register state
	vim.notify("Cleared all registers. Inspect with :reg", vim.log.levels.INFO)
end

-- Clear letter registers only
function M.clear_letter_registers()
	local regs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	for i = 1, #regs do
		local reg = regs:sub(i, i)
		vim.fn.setreg(reg, "")
	end
	vim.cmd("wshada!")
	vim.notify("Cleared letter registers. Inspect with :reg", vim.log.levels.INFO)
end

-- Clear number registers only
function M.clear_number_registers()
	local regs = "0123456789"
	for i = 1, #regs do
		local reg = regs:sub(i, i)
		vim.fn.setreg(reg, "")
	end
	vim.cmd("wshada!")
	vim.notify("Reset registers 1-9. Inspect with :reg", vim.log.levels.INFO)
end

-- Create commands
vim.api.nvim_create_user_command("ClearAllRegisters", M.clear_all_registers, {})
vim.api.nvim_create_user_command("ClearLetterRegisters", M.clear_letter_registers, {})
vim.api.nvim_create_user_command("ClearNumberRegisters", M.clear_number_registers, {})

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

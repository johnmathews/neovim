--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

local map = vim.api.nvim_set_keymap
local default_options = { noremap = true, silent = true }
local expr_options = { noremap = true, expr = true, silent = true }

-- this cannot be local if anything in the module is to be used as a keybind
Functions_ok, Functions = pcall(require, "functions")
if not Functions_ok then
	print("luaFunctions could not be loaded")
	return
end

----- INSERT MODE ---------------
map("i", "kj", "<ESC>", KeymapOptions("enter Insert Mode"))
--jump back one word
map("i", "<C-h>", "<C-o>b", KeymapOptions("jump back one word"))
-- delete the word infront of the cursor
map("i", "<C-e>", "<C-o>de", KeymapOptions("delete the next word"))

map("n", "<F1>", ":e<CR>|:lua vim.notify('Buffer Refreshed!')<CR>", KeymapOptions("Refresh buffer")) -- refresh buffer
map("n", "<F2>", ":set nowrap!<CR>|:lua vim.notify('Toggle linewrap')<CR>", KeymapOptions("Toggle linewrap")) -- toggle linewrap
map(
	"n",
	"<F3>",
	":set relativenumber!<CR>|:lua vim.notify('Toggle rel line nums')<CR>",
	KeymapOptions("Toggle rel line nums")
) -- toggle relative linenumbers
map("n", "<F4>", ":LspRestart<CR>|:lua vim.notify('LspRestart')<CR>", KeymapOptions("Restart LSP")) -- restart LSP
map(
	"n",
	"<F5>",
	":setlocal spell!<CR>|:lua vim.notify('Toggle local spell check')<CR>",
	KeymapOptions("Toggle spell checker")
) -- toggle spellcheck
-- F6 is toggle term. see plugins/toggleterm.lua

--Remap space as leader key
map("n", "<Space>", "<Nop>", KeymapOptions("unmap space so it can be the Leader Key"))
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

map("n", "<leader>ve", ":edit $MYVIMRC<CR>", KeymapOptions("edit vimrc"))
map("n", "<leader>vr", ":source $MYVIMRC<CR>|:autocmd User VimReload<CR>", KeymapOptions("reload vimrc file"))

-- open filetype plugin for current buffer
map(
	"n",
	"<leader>vf",
	":edit ~/.config/nvim/ftplugin/<C-R>=&filetype<CR>.vim<CR>",
	KeymapOptions("edit ftplugin file for current buffers filetype")
)

-- Natural cursor movement over wrapped lines
map("n", "j", "v:count == 0 ? 'gj' : 'j'", expr_options)
map("n", "k", "v:count == 0 ? 'gk' : 'k'", expr_options)

-- paste over currently selected text without yanking it
-- this might messup "<number>p
-- map("v", "p", '"_dP', default_options)

-- Searching
map("n", "`", "/", { noremap = true, silent = false })
map("n", "``", ": nohlsearch<CR>", default_options)
map("n", "*", "*``", default_options)

map("n", "o", "o<ESC>", default_options)
map("n", "O", "O<ESC>", default_options)

-- swap semicolon and colon
map("n", ";", ":", { noremap = true, silent = false })
map("n", ":", ";", { noremap = true, silent = false })
map("v", ";", ":", { noremap = true, silent = false })
map("v", ":", ";", { noremap = true, silent = false })

map("n", "<Tab>ww", ":wa<CR>", KeymapOptions("Write all buffers"))
map("n", "<Tab>qq", ":NvimTreeClose<CR>|:qa<CR>", KeymapOptions("Quit Vim"))

-- query which color - what and which kind of syntax is this color? - wc
-- ghl. highlight group
map(
	"n",
	"wc",
	":echo 'hi<' . synIDattr(synID(line('.'),col('.'),1),'name') . '> trans<' . synIDattr(synID(line('.'),col('.'),0),'name') .'> lo<' . synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name') . '>'<CR>",
	KeymapOptions("Get current highlight group")
)

-- open the current file in the default app
-- gx is mapped to open a url using the open-browser plugin
map("n", "<leader>x", ":!xdg-open %<CR><CR>", KeymapOptions("Open current file in default app"))

-- Split navigations
map("n", "<C-H>", "<C-W><C-H>", default_options)
map("n", "<C-J>", "<C-W><C-J>", default_options)
map("n", "<C-K>", "<C-W><C-K>", default_options)
map("n", "<C-L>", "<C-W><C-L>", default_options)

-- FUNCTIONS
-- the function should be defined in lua/functions.lua
map("n", "gq", ":call ToggleQuickFix()<CR>", KeymapOptions("Toggle QuickFix window"))
map("n", "<leader>ta", ":lua Functions.active_tools()<CR>", KeymapOptions("Show active LSP/formatters/linters"))
map("n", "<Tab>dd", ":lua Functions.cycle_diagnostics()<CR>", KeymapOptions("Cycle diagnostics display"))

-- Jump List
map("n", "<C-p>", "<C-i>", default_options)

-- auto session
local ok = pcall(require, "session-lens")
if ok then
	vim.keymap.set("n", "<leader>fs", function()
		require("session-lens").search_session()
	end, KeymapOptions("Sessions: search"))
end

-- backgroud git commit and push
map("n", "gG", ":lua Functions.asyncGitCommitAndPush()<CR>", KeymapOptions("Quietly push all changes to remote"))


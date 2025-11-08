-- ToggleTerm: Terminal manager with lazygit and lazydocker integration
local toggleterm_status_ok, toggleterm = pcall(require, "toggleterm")
if not toggleterm_status_ok then
	print("toggleterm not found")
	return
end

toggleterm.setup({
	-- size can be a number or function which is passed the current terminal
	size = function(term)
		if term.direction == "horizontal" then
			return 20
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.4
		end
	end,
	-- open_mapping = [[<c-\>]],
	open_mapping = [[<F6>]], -- toggle toggleterm
	insert_mappings = false, -- whether or not the open mapping applies in insert mode
	terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
	start_in_insert = true, -- open a terminal window in normal mode or insert mode

	-- on_open = fun(t: Terminal), -- function to run when the terminal opens
	-- on_close = fun(t: Terminal), -- function to run when the terminal closes
	hide_numbers = true, -- hide the number column in toggleterm buffers
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = "1", -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
	persist_size = true,
	-- direction = 'vertical' | 'horizontal' | 'window' | 'float',
	direction = "float",
	close_on_exit = true, -- close the terminal window when the process exits
	shell = vim.o.shell, -- change the default shell
	-- This field is only relevant if direction is set to 'float'
	float_opts = {
		-- The border key is *almost* the same as 'nvim_open_win'
		-- see :h nvim_open_win for details on borders however
		-- the 'curved' border is a custom border type
		-- not natively supported but implemented in this plugin.
		-- border = 'single' | 'double' | 'shadow' | 'curved',
		border = "curved",
		-- width = 100,
		-- height = <value>,
		winblend = 0,
		highlights = {
			border = "Normal",
			background = "Normal",
		},
	},
})

local Terminal = require("toggleterm.terminal").Terminal

-- https://github.com/jesseduffield/lazygit
-- https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })
function _LAZYGIT_TOGGLE()
	lazygit:toggle()
end

-- https://github.com/jesseduffield/lazydocker
local lazydocker = Terminal:new({ cmd = "lazydocker", hidden = true })
function _LAZYDOCKER_TOGGLE()
	lazydocker:toggle()
end

local htop = Terminal:new({ cmd = "htop", hidden = true })
function _HTOP_TOGGLE()
	htop:toggle()
end

local python = Terminal:new({ cmd = "python", hidden = true })
function _PYTHON_TOGGLE()
	python:toggle()
end

-- lazygit keybind
vim.api.nvim_set_keymap(
	"n",
	"<Leader>g",
	"<cmd>lua _LAZYGIT_TOGGLE()<CR>",
	{ noremap = true, silent = true, desc = "lazygit" }
)

-- lazydocker keybind
-- vim.api.nvim_set_keymap("n", "<Leader>d", "<cmd>lua _LAZYDOCKER_TOGGLE()<CR>", { noremap = true, silent = true, desc = "lazydocker" })

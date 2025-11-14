-- Telescope: Fuzzy finder for files, buffers, git, LSP, and more
local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
	return
end

local map = vim.api.nvim_set_keymap
local default_options = { noremap = true, silent = true }

-- Telescope
-- tab-V/S/A are taken by toggle-lsp plugin

map(
	"n",
	"<Tab>i",
	":Telescope current_buffer_fuzzy_find fuzzy=true<CR>",
	KeymapOptions("Telescope current buffer fuzzy find")
)

-- buffers with sort_lastused, ignore_current_buffer, and get_substr_matcher (old config)
-- map("n", "<Tab>r", ":lua require('telescope.builtin').buffers(...)<CR>", default_options)
map(
	"n",
	"<Tab>r",
	":lua require('telescope.builtin').buffers({ ignore_current_buffer = false, sort_mru = true })<CR>",
	default_options
)
map("n", "<Tab>o", ":Telescope oldfiles<CR>", default_options)

-- map("n", "<Tab>s", ":Telescope grep_string only_sort_text=true<CR>", default_options)
map(
	"n",
	"<Tab>s",
	":Telescope live_grep<CR>",
	{ noremap = true, silent = true, desc = "Telescope ripgrep (not fuzzy)" }
)
map(
	"n",
	"<Tab>y",
	":lua require'telescope.builtin'.grep_string{ shorten_path = true, word_match = '-w', only_sort_text = true, search = '' }<CR>",
	{ noremap = true, silent = true, desc = "Telescope fuzzy-find text in PWD" }
)

-- ripgrep https://github.com/nvim-telescope/telescope-live-grep-args.nvim
map(
	"n",
	"<Tab>x",
	":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
	{ noremap = true, silent = true, desc = "Telescope ripgrep with args" }
)

map("n", "<Tab>p", ":Telescope projects<CR>", default_options)
map("n", "<Tab>h", ":Telescope help_tags<cr>", default_options)

map("n", "<Tab>tc", ":Telescope command_history<CR>", default_options)
map("n", "<Tab>ts", ":Telescope search_history<CR>", default_options)
map("n", "<Tab>tk", ":Telescope keymaps<CR>", default_options)

-- Treesitter picker
map("n", "<Tab>tt", ":Telescope treesitter<CR>", default_options)

-- Vim pickers
map("n", "<Tab>ta", ":Telescope autocommands<CR>", default_options)
map("n", "<Tab>tr", ":Telescope registers<CR>", default_options)
map("n", "<Tab>to", ":Telescope vim_options<CR>", default_options)

-- map("n", "<Tab>j", ":Telescope jumplist<CR>", default_options)
-- map("n", "<Tab>l", ":Telescope loclist<CR>", default_options)
-- map("n", "<Tab>qf", ":Telescope quickfix<CR>", default_options)

map("n", "<Tab>z", ":Telescope resume<CR>", default_options)

map(
	"n",
	"<Tab>f",
	"<CMD>lua require'plugins.telescope'.find_files_fallback()<CR>",
	KeymapOptions("Telescope find git files fallback")
)

-- Searches all files, doesnt ignore anything (--no-ignore) see pickers.all_files below
-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#file-and-text-search-in-hidden-files-and-directories
map("n", "<Tab>a", ":Telescope find_files<CR>", default_options)

-- Git pickers
map("n", "<Tab>gc", ":Telescope git_commits<CR>", default_options)
map("n", "<Tab>gb", ":Telescope git_bcommits<CR>", default_options)
map("n", "<Tab>gr", ":Telescope git_branches<CR>", default_options)
map("n", "<Tab>gs", ":Telescope git_status<CR>", default_options)

-- LSP pickers (Telescope)
map("n", "<localleader>r", ":Telescope lsp_references<CR>", default_options)
map("n", "<localleader>d", ":Telescope lsp_definitions<CR>", default_options)
map("n", "<localleader>i", ":Telescope lsp_implementations<CR>", default_options)
map("n", "<Tab>b", ":Telescope lsp_workspace_symbols<CR>", default_options)

-- register extensions
telescope.load_extension("projects")
-- telescope-fzf-native: https://github.com/nvim-telescope/telescope.nvim/wiki/Switching-from-fzf-to-telescope
telescope.load_extension("fzf")
telescope.load_extension("harpoon")
telescope.load_extension("live_grep_args")
telescope.load_extension("smart_history")

-- Custom actions
local transform_mod = require("telescope.actions.mt").transform_mod
local nvb_actions = transform_mod({
	file_path = function(prompt_bufnr)
		-- Get selected entry and the file full path
		local content = require("telescope.actions.state").get_selected_entry()
		local full_path = content.cwd .. require("plenary.path").path.sep .. content.value
		print("*** full_path = ", full_path)

		-- Yank the path to unnamed register
		vim.fn.setreg('"', full_path)

		-- Close the popup
		-- require("utils").info "File path is yanked "
		require("telescope.actions").close(prompt_bufnr)
	end,
})

-- map("n", "<leader>pw", ":lua require(\"telescope.builtin\").grep_string({search=vim.fn.expand(\"<cword>\")})<CR>", default_options)
-- map("n", "<leader>ps", ":lua require(\"telescope.builtin\").grep_string({ search = vim.fn.input(\"Grep For > \")})<CR>", default_options)

-- dont preview binaries
-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#falling-back-to-find_files-if-git_files-cant-find-a-git-directory
local previewers = require("telescope.previewers")
local Job = require("plenary.job")
local new_maker = function(filepath, bufnr, opts)
	filepath = vim.fn.expand(filepath)
	Job:new({
		command = "file",
		args = { "--mime-type", "-b", filepath },
		on_exit = function(j)
			local mime_type = vim.split(j:result()[1], "/")[1]
			if mime_type == "text" then
				previewers.buffer_previewer_maker(filepath, bufnr, opts)
			else
				-- maybe we want to write something to the buffer here
				vim.schedule(function()
					vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
				end)
			end
		end,
	}):sync()
end

local actions = require("telescope.actions")
telescope.setup({
	defaults = {
		buffer_previewer_maker = new_maker,
		prompt_prefix = "  ",
		selection_caret = "  ",
		entry_prefix = "   ",
		path_display = { "truncate" },
		history = {
			path = "~/.local/share/nvim/databases/telescope_history.sqlite3",
			limit = 100,
		},

		mappings = {
			i = {
				["<esc>"] = actions.close,
				["<C-n>"] = actions.cycle_history_next,
				["<C-p>"] = actions.cycle_history_prev,

				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,

				["<C-c>"] = actions.close,

				["<Down>"] = actions.move_selection_next,
				["<Up>"] = actions.move_selection_previous,

				["<CR>"] = actions.select_default,
				["<C-x>"] = actions.select_horizontal,
				["<C-v>"] = actions.select_vertical,
				["<C-t>"] = actions.select_tab,

				-- ["<C-u>"] = actions.preview_scrolling_up,
				-- ["<C-d>"] = actions.preview_scrolling_down,
				["<C-d>"] = actions.delete_buffer,

				["<PageUp>"] = actions.results_scrolling_up,
				["<PageDown>"] = actions.results_scrolling_down,

				["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
				["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
				["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
				["<C-l>"] = actions.complete_tag,
				["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
			},

			n = {
				["<esc>"] = actions.close,
				["<CR>"] = actions.select_default,
				["<C-x>"] = actions.select_horizontal,
				["<C-v>"] = actions.select_vertical,
				["<C-t>"] = actions.select_tab,

				["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
				["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
				["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

				["j"] = actions.move_selection_next,
				["k"] = actions.move_selection_previous,
				["H"] = actions.move_to_top,
				["M"] = actions.move_to_middle,
				["L"] = actions.move_to_bottom,

				["<Down>"] = actions.move_selection_next,
				["<Up>"] = actions.move_selection_previous,
				["gg"] = actions.move_to_top,
				["G"] = actions.move_to_bottom,

				["<C-u>"] = actions.preview_scrolling_up,
				["<C-d>"] = actions.preview_scrolling_down,

				["<PageUp>"] = actions.results_scrolling_up,
				["<PageDown>"] = actions.results_scrolling_down,

				["?"] = actions.which_key,
			},
		},
	},
	pickers = {
		-- https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#automatic-filtering
		find_files = {
			-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
			find_command = { "rg", "--files", "--no-ignore" },
			mappings = {
				n = {
					["y"] = nvb_actions.file_path,
				},
				i = {
					["<C-y>"] = nvb_actions.file_path,
				},
			},
		},
		git_files = {
			-- theme = "ivy",  --dropdown
			mappings = {
				n = {
					["y"] = nvb_actions.file_path,
				},
				i = {
					["<C-y>"] = nvb_actions.file_path,
				},
			},
		},
	},
	extensions = {
		fzf = { -- this is telescope-fzf-native and is recommended - https://github.com/nvim-telescope/telescope.nvim/wiki/Switching-from-fzf-to-telescope
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
		},
		projects = {},
	},
})

local M = {}

M.find_files_fallback = function()
	local opts = {} -- define here if you want to define something
	local ok = pcall(require("telescope.builtin").git_files, opts)
	if not ok then
		require("telescope.builtin").find_files(opts)
	end
end

return M

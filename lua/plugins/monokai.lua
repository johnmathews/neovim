local status_ok, monokai = pcall(require, "monokai")
if not status_ok then
	return
end

-- pro, soda, ristretto
-- local palette = require("monokai").pro
local palette = monokai.pro

monokai.setup({
	italics = true,
	palette = {
		name = "monokai_pro",
		base0 = "#222426",
		base1 = "#211F22",
		base2 = "#26292C",
		base3 = "#2E323C",
		base4 = "#333842",
		base5 = "#4d5154",
		base6 = "#72696A",
		base7 = "#B1B1B1",
		base8 = "#e3e3e1",
		border = "#A1B5B1",
		brown = "#504945",
		white = "#FFF1F3",
		grey = "#72696A",
		black = "#000000",
		pink = "#FF6188",
		green = "#A9DC76",
		aqua = "#78DCE8",
		yellow = "#FFD866",
		orange = "#FC9867",
		purple = "#AB9DF2",
		red = "#FD6883",
		diff_add = "#3d5213",
		diff_remove = "#4a0f23",
		diff_change = "#27406b",
		diff_text = "#23324d",
	},
	custom_hlgroups = {

		mkdNonListItemBlock = {
			fg = palette.white,
			bg = palette.black,
		},
		Normal = {
			fg = palette.white,
			bg = palette.black,
		},
		-- background, and normal text
		-- normal = {
		--   fg = palette.white,
		--   bg = palette.black,
		-- },

		-- nvim-tree
		-- NvimTreeFolderName = {
		--   fg = palette.green,
		-- },
		-- NvimTreeRootFolder = {
		--   fg = palette.base8,
		-- },
		-- NvimTreeFolderIcon = {
		--   fg = palette.green,
		-- },
		-- NvimTreeOpenedFolderName = {
		--   fg = palette.aqua,
		-- },
		-- NvimTreeFileIcon = {
		--   fg = palette.aqua,
		-- },
		-- NvimTreeSpecialFile = {
		--   fg = palette.purple,
		-- },
		-- NvimTreeSymlink = {
		--   fg = palette.green,
		-- },
		-- CopilotSuggestion = {
		--   fg = palette.base0,
		--   bg = palette.green,
		-- },
		-- -- hrsh7th/nvim-cmp
		-- CmpDocumentation = {
		--   fg = palette.white,
		--   bg = palette.base1,
		-- },
		-- TSInclude = {
		--   fg = palette.aqua,
		-- },
		GitSignsAdd = {
			fg = palette.green,
			bg = palette.base2,
		},
		GitSignsDelete = {
			fg = palette.pink,
			bg = palette.base2,
		},
		GitSignsChange = {
			fg = palette.orange,
			bg = palette.base2,
		},
		MatchParen = {
			fg = palette.black,
			bg = palette.yellow,
		},
		-- rainbow colors for matching pairs of parentheses
		rainbowcol1 = {
			fg = "red",
		},
		rainbowcol2 = {
			fg = palette.yellow,
		},
		rainbowcol3 = {
			fg = palette.green,
		},
		rainbowcol4 = {
			fg = palette.yellow,
		},
		rainbowcol5 = {
			fg = palette.red,
		},
		rainbowcol6 = {
			fg = palette.aqua,
		},
		LineNr = {
			fg = palette.green,
			-- fg = palette.base8,
		},
		Comment = {
			fg = palette.aqua,
			style = "italic",
		},
		pythonStatement = {
			fg = palette.red,
			style = "italic",
		},
		pythonInclude = {
			fg = palette.red,
			style = "italic",
		},
		pythonString = {
			fg = palette.yellow,
			style = "italic",
		},
		pythonBuiltin = {
			fg = palette.yellow,
			style = "italic",
		},
		-- visual mode
		Visual = {
			bg = palette.base5,
		},
		-- requirements.txt
		requirementsPackageName = {
			fg = palette.green,
		},
		requirementsVersionSpecifiers = {
			fg = palette.orange,
		},
		requirementsComment = {
			fg = palette.aqua,
		},
		requirementsCommandOption = {
			fg = palette.red,
		},
		-- Docker
		dockerfileKeywords = {
			fg = palette.orange,
		},
		dockerfileComment = {
			fg = palette.aqua,
		},
		bashStatement = {
			fg = palette.red,
		},
		dockerfileEnv = {
			fg = palette.yellow,
		},
		dockerfileEnvWithComment = {
			fg = palette.green,
		},
		-- Telescope
		TelescopeBorder = {
			-- fg = palette.base7,
			-- fg = palette.base7,
			fg = palette.green,
		},
		TelescopeNormal = {
			fg = palette.base8,
		},
		TelescopeMatching = {
			fg = palette.aqua,
		},
		-- ansible
		yamlBlockMappingKey = {
			fg = palette.orange,
		},
		ansible_name = {
			fg = palette.aqua,
		},
		ansible_normal_keywords = {
			fg = palette.red,
		},
		ansible_extra_keywords = {
			fg = palette.green,
		},
		ansible_extra_special_keywords = {
			fg = palette.green,
		},
		ansible_loop_keywords = {
			fg = palette.yellow,
		},
	},
})

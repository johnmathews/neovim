-- One Monokai: Alternative Monokai color scheme with custom highlights
require("one_monokai").setup({
	transparent = false,
	italics = true,
	colors = {
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
	highlights = function(colors)
		return {
			-- nvim-tree
			-- NvimTreeFolderName = {
			--   fg = colors.green,
			-- },
			-- NvimTreeRootFolder = {
			--   fg = colors.base8,
			-- },
			-- NvimTreeFolderIcon = {
			--   fg = colors.green,
			-- },
			-- NvimTreeOpenedFolderName = {
			--   fg = colors.aqua,
			-- },
			-- NvimTreeFileIcon = {
			--   fg = colors.aqua,
			-- },
			-- NvimTreeSpecialFile = {
			--   fg = colors.purple,
			-- },
			-- NvimTreeSymlink = {
			--   fg = colors.green,
			-- },
			-- CopilotSuggestion = {
			--   fg = colors.base0,
			--   bg = colors.green,
			-- },
			-- -- hrsh7th/nvim-cmp
			-- CmpDocumentation = {
			--   fg = colors.white,
			--   bg = colors.base1,
			-- },
			-- TSInclude = {
			--   fg = colors.aqua,
			-- },
			GitSignsAdd = {
				fg = colors.green,
				bg = colors.base2,
			},
			GitSignsDelete = {
				fg = colors.pink,
				bg = colors.base2,
			},
			GitSignsChange = {
				fg = colors.orange,
				bg = colors.base2,
			},
			-- background, and normal text
			normal = {
				fg = colors.white,
				bg = colors.base0,
			},

			MatchParen = {
				fg = colors.black,
				bg = colors.yellow,
			},
			-- rainbow colors for matching pairs of parentheses
			rainbowcol1 = {
				fg = "red",
			},
			rainbowcol2 = {
				fg = colors.yellow,
			},
			rainbowcol3 = {
				fg = colors.green,
			},
			rainbowcol4 = {
				fg = colors.yellow,
			},
			rainbowcol5 = {
				fg = colors.red,
			},
			rainbowcol6 = {
				fg = colors.aqua,
			},
			LineNr = {
				fg = colors.green,
				-- fg = colors.base8,
			},
			Comment = {
				fg = colors.aqua,
				-- style = "italic",
			},
			pythonStatement = {
				fg = colors.red,
				-- style = "italic",
			},
			pythonInclude = {
				fg = colors.red,
				-- style = "italic",
			},
			pythonString = {
				fg = colors.yellow,
				-- style = "italic",
			},
			pythonBuiltin = {
				fg = colors.yellow,
				-- style = "italic",
			},
			-- visual mode
			Visual = {
				bg = colors.base5,
			},
			-- requirements.txt
			requirementsPackageName = {
				fg = colors.green,
			},
			requirementsVersionSpecifiers = {
				fg = colors.orange,
			},
			requirementsComment = {
				fg = colors.aqua,
			},
			requirementsCommandOption = {
				fg = colors.red,
			},
			-- Docker
			dockerfileKeywords = {
				fg = colors.orange,
			},
			dockerfileComment = {
				fg = colors.aqua,
			},
			bashStatement = {
				fg = colors.red,
			},
			dockerfileEnv = {
				fg = colors.yellow,
			},
			dockerfileEnvWithComment = {
				fg = colors.green,
			},
			-- Telescope
			TelescopeBorder = {
				-- fg = colors.base7,
				-- fg = colors.base7,
				fg = colors.green,
			},
			TelescopeNormal = {
				fg = colors.base8,
			},
			TelescopeMatching = {
				fg = colors.aqua,
			},
			-- ansible
			yamlBlockMappingKey = {
				fg = colors.orange,
			},
			ansible_name = {
				fg = colors.aqua,
			},
			ansible_normal_keywords = {
				fg = colors.red,
			},
			ansible_extra_keywords = {
				fg = colors.green,
			},
			ansible_extra_special_keywords = {
				fg = colors.green,
			},
			ansible_loop_keywords = {
				fg = colors.yellow,
			},
		}
	end,
})

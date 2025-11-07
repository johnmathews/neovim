---@diagnostic disable: lowercase-global

globals = {
	"vim",
	"P",
	"Functions",
	"KeymapOptions",
	"Functions_ok",
	"PrintTable",
	"choice_popup",
	"update_choice_popup",
	"choice_popup_close",
	"_LAZYGIT_TOGGLE",
	"_LAZYDOCKER_TOGGLE",
	"_HTOP_TOGGLE",
	"_PYTHON_TOGGLE",
}

-- Enforce max line length of 150 characters
max_line_length = 150

-- Snippet files often have unused helper imports
files["lua/snippets/"] = {
	ignore = { "211", "212", "213" } -- unused variables/functions/arguments
}

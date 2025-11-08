-- Notify: Fancy notification manager with animations
local ok, notify = pcall(require, "notify")
if not ok then
	return
end

notify.setup({
	stages = "fade_in_slide_out",
	render = "compact",
	timeout = 3000,
	top_down = false,
	background_colour = "#000000",
})

vim.notify = notify

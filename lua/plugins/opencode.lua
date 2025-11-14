return {
	setup = function()
		-- Get the plugin's directory
		local plugin_dir = vim.fn.stdpath("data") .. "/lazy/opencode.nvim"

		-- Add the plugin's lua directory to the runtime path if it exists
		if vim.fn.isdirectory(plugin_dir) == 1 then
			vim.opt.rtp:append(plugin_dir)
		end

		-- Setup opencode with default configuration
		require("opencode").setup({})

		package.preload["lua.opencode.api"] = function()
			return require("opencode.api")
		end
	end,
}

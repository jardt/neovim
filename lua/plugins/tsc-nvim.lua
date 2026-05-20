return {
	{
		"dmmulroy/tsc.nvim",
		name = "tsc-nvim",
		enabled = require("config.nix").enableForCategory("langs.web", false),
		event = "VeryLazy",
		config = function()
			require("tsc").setup({
				-- Your config here
			})
		end,
	},
}

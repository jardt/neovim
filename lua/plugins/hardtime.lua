return {
	{
		"m4xshen/hardtime.nvim",
		lazy = false,
		enabled = require("config.nix").enableForCategory("practice", false),
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {
			disabled_keys = {
				["<Up>"] = false,
				["<Down>"] = false,
				["<Left>"] = false,
				["<Right>"] = false,
			},
		},
	},
}

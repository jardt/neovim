return {
	{
		"m4xshen/hardtime.nvim",
		lazy = false,
		enabled = require("nixCatsUtils").enableForCategory("practice", false),
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

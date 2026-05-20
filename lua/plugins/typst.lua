return {
	{
		"chomosuke/typst-preview.nvim",
		ft = "typst",
		enabled = require("config.nix").enableForCategory("langs.typst", false),
		opts = {}, -- lazy.nvim will implicitly calls `setup {}`
	},
}

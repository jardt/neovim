return {
	{
		"chomosuke/typst-preview.nvim",
		ft = "typst",
		enabled = require("config.nix").enableForCategory("langs.typst", false),
		opts = {}, -- plugin manager calls `setup {}`
	},
}

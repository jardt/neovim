return {
	{
		"chomosuke/typst-preview.nvim",
		ft = "typst",
		enabled = require("nixCatsUtils").enableForCategory("langs.typst", false),
		opts = {}, -- lazy.nvim will implicitly calls `setup {}`
	},
}

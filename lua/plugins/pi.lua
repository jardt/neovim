return {
	{
		"pi",
		enabled = require("config.nix").enableForCategory("ai", false),
		dependencies = { { "folke/snacks.nvim", opts = { input = {}, picker = {} } } },
		config = function()
			require("pi").setup()
		end,
	},
}

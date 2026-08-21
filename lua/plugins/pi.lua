return {
	{
		"pi",
		enabled = require("config.nix").enableForCategory("ai", true),
		dependencies = { { "folke/snacks.nvim", opts = { input = {}, picker = {} } } },
		config = function()
			require("pi").setup()
		end,
	},
}

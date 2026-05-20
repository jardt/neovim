return {
	{
		"saghen/blink.indent",
		enabled = require("config.nix").enableForCategory("general", false),
		name = "blink-indent",
		event = "BufRead",
		--- @module 'blink.indent'
		--- @type blink.indent.Config
		-- opts = {},
	},
}

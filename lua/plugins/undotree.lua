return {
	{
		"mbbill/undotree",
		enabled = require("config.nix").enableForCategory("undotree", true),
		event = "BufRead",
		config = function()
			vim.keymap.set("n", "<leader>uu", vim.cmd.UndotreeToggle)
		end,
	},
}

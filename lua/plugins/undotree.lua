return {
	{
		"mbbill/undotree",
		event = "BufRead",
		config = function()
			vim.keymap.set("n", "<leader>uu", vim.cmd.UndotreeToggle)
		end,
	},
}

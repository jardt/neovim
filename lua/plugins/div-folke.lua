return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			indent = { enabled = false },
			input = { enabled = true },
			notifier = { enabled = true },
			scope = { enabled = false },
			scroll = { enabled = false },
			statuscolumn = { enabled = false }, -- we set this in options.lua
			words = { enabled = true },
			lazygit = { enabled = true },
		},
		keys = {
			{
				"<leader>gl",
				desc = "lazygit",
				function()
					---@param opts? snacks.lazygit.Config
					Snacks.lazygit.open(opts)
				end,
			},
		},
	},
	{
		"folke/ts-comments.nvim",
		event = "VeryLazy",
		opts = {},
	},
}

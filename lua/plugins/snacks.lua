return {
	{
		"folke/snacks.nvim",
		enabled = require("nixCatsUtils").enableForCategory("general", true),
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			indent = { enabled = false },
			input = {
				enabled = true,
				icon = " ",
				icon_hl = "SnacksInputIcon",
				icon_pos = "left",
				prompt_pos = "title",
				win = { style = "input" },
				expand = true,
			},
			notifier = { enabled = true },
			scroll = { enabled = false },
			statuscolumn = { enabled = false }, -- we set this in options.lua
			words = { enabled = true },
			lazygit = { enabled = require("nixCatsUtils").enableForCategory("git", true) },
			gh = { enabled = require("nixCatsUtils").enableForCategory("git", true) },
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
			{
				"<leader>gi",
				function()
					Snacks.picker.gh_issue()
				end,
				desc = "GitHub Issues (open)",
			},
			{
				"<leader>gI",
				function()
					Snacks.picker.gh_issue({ state = "all" })
				end,
				desc = "GitHub Issues (all)",
			},
			{
				"<leader>gp",
				function()
					Snacks.picker.gh_pr()
				end,
				desc = "GitHub Pull Requests (open)",
			},
			{
				"<leader>gP",
				function()
					Snacks.picker.gh_pr({ state = "all" })
				end,
				desc = "GitHub Pull Requests (all)",
			},
		},
	},
}

return {
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
			"TmuxNavigatorProcessList",
		},
		keys = {
			{
				"<c-h>",
				function()
					require("config.multiplexer_navigation").navigate("left")
				end,
				desc = "Navigate left (window/herdr/tmux)",
			},
			{
				"<c-j>",
				function()
					require("config.multiplexer_navigation").navigate("down")
				end,
				desc = "Navigate down (window/herdr/tmux)",
			},
			{
				"<c-k>",
				function()
					require("config.multiplexer_navigation").navigate("up")
				end,
				desc = "Navigate up (window/herdr/tmux)",
			},
			{
				"<c-l>",
				function()
					require("config.multiplexer_navigation").navigate("right")
				end,
				desc = "Navigate right (window/herdr/tmux)",
			},
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	},
}

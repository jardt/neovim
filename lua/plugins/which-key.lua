return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts_extend = { "spec" },
		opts = {
			preset = "helix",
			icons = {
				mappings = vim.g.have_nerd_font,
			},
			defaults = {},
			spec = {
				{
					mode = { "n", "v" },
					{ "<leader>c", group = "[c]ode" },
					{ "<leader>d", group = "[d]iagnostics" },
					{ "<leader>D", group = "[D]ebug" },
					{ "<leader>Dp", group = "profiler" },
					{ "<leader>f", group = "[f]ile/[f]ind" },
					{ "<leader>g", group = "[g]it" },
					{ "<leader>q", group = "[q]uit/session" },
					{ "<leader>s", group = "[s]earch" },
					{ "<leader>u", group = "[u]i", icon = { icon = "󰙵 ", color = "cyan" } },
					{ "<leader>x", group = "close", icon = { color = "red" } },
					{ "<leader>t", group = "[t]odos", icon = { color = "green" } },
					{ "<leader>A", group = "[A]nsible", icon = { icon = "󱂚", color = "red" } },
					{ "[", group = "prev" },
					{ "]", group = "next" },
					{ "z", group = "fold" },
					{
						"<leader>b",
						group = "[b]uffer",
						expand = function()
							return require("which-key.extras").expand.buf()
						end,
					},
					{
						"<leader>w",
						group = "[w]indows",
						proxy = "<c-w>",
						expand = function()
							return require("which-key.extras").expand.win()
						end,
					},
					-- better descriptions
					{ "gx", desc = "Open with system app" },
				},
			},
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Keymaps (which-key)",
			},
			{
				"<c-w><space>",
				function()
					require("which-key").show({ keys = "<c-w>", loop = true })
				end,
				desc = "Window Hydra Mode (which-key)",
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			if not vim.tbl_isempty(opts.defaults) then
				wk.register(opts.defaults)
			end
		end,
	},
}

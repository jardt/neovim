return {
	{
		"folke/noice.nvim",
		enabled = require("nixCatsUtils").enableForCategory("notify", false),
		event = "VeryLazy",
		opts = {
			cmdline = {
				enabled = true, -- enables the Noice cmdline UI
				view = "cmdline", -- classic at bottom left
				opts = {}, -- global options for the cmdline. See section on views
			},
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			routes = {
				{
					filter = {
						event = "notify",
						find = "Request textDocument/documentHighlight",
					},
					opts = { skip = true },
				},
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
						},
					},
					view = "mini",
				},
			},
			presets = {
				bottom_search = true,
				command_palette = false,
				long_message_to_split = true,
			},
		},
        -- stylua: ignore
        keys = {
            { "<leader>sn",  "",                                                            desc = "+noice" },
            { "<S-Enter>",   function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c",                              desc = "Redirect Cmdline" },
            { "<leader>snl", function() require("noice").cmd("last") end,                   desc = "Noice Last Message" },
            { "<leader>snh", function() require("noice").cmd("history") end,                desc = "Noice History" },
            { "<leader>sna", function() require("noice").cmd("all") end,                    desc = "Noice All" },
            { "<leader>snd", function() require("noice").cmd("dismiss") end,                desc = "Dismiss All" },
            { "<leader>snt", function() require("noice").cmd("pick") end,                   desc = "Noice Picker (Telescope/FzfLua)" },
        },
		config = function(_, opts)
			-- HACK: noice shows messages from before it was enabled,
			-- but this is not ideal when Lazy is installing plugins,
			-- so clear the messages in this case.
			if vim.o.filetype == "lazy" then
				vim.cmd([[messages clear]])
			end
			require("noice").setup(opts)
		end,
	},
}

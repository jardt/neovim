return {
	{
		"nvim-lualine/lualine.nvim",
		event = "BufReadPre",
		enabled = require("nixCatsUtils").enableForCategory("statusline", false),
		dependencies = { "folke/trouble.nvim" },
		init = function()
			vim.g.lualine_laststatus = vim.o.laststatus
			if vim.fn.argc(-1) > 0 then
				-- set an empty statusline till lualine loads
				vim.o.statusline = " "
			else
				-- hide the statusline on the starter page
				vim.o.laststatus = 0
			end
		end,
		opts = function()
			local trouble = require("trouble")
			local symbols = trouble.statusline({
				mode = "lsp_document_symbols",
				groups = {},
				title = false,
				filter = { range = true },
				format = "{kind_icon}{symbol.name:Normal}",
				-- The following line is needed to fix the background color
				-- Set it to the lualine section you want to use
				hl_group = "lualine_c_normal",
			})
			return {
				options = {
					icons_enabled = true,
					theme = "auto",
				},
				sections = {
					lualine_c = {
						{ "filename", path = 1 },
						{
							symbols.get,
							cond = symbols.has,
						},
					},
					lualine_x = {
						{
							function()
								return require("noice").api.status.mode.get()
							end,
							cond = function()
								return package.loaded["noice"] and require("noice").api.status.mode.has()
							end,
							color = function()
								return { fg = "#ff9e64" }
							end,
						},
					},
				},
				extensions = { "neo-tree", "lazy", "quickfix", "nvim-dap-ui", "trouble", "fzf" },
			}
		end,
	},
}

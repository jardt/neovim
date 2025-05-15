return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		-- This will provide type hinting with LuaLS
		---@module "conform"
		---@type conform.setupOpts
		opts = {
			keys = {
				{
					"<leader>F",
					function()
						require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
					end,
					mode = { "n", "v" },
					desc = "Format Injected Langs",
				},
			},
			formatters_by_ft = {
				lua = { "stylua" },
				-- You can customize some of the format options for the filetype (:help conform.format)
				rust = { "rustfmt", lsp_format = "fallback" },
				-- Conform will run the first available formatter
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				svelte = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "yamlfmt", stop_after_first = true },
				json = { "fixjson", stop_after_first = true },
				markdown = { "markdownlint", stop_after_first = true },
				go = { "goimports", "gofumpt" },
				sql = { "sqruff" },
				mysql = { "sqruff" },
				plsql = { "sqruff" },
				nix = { "nixfmt" },
				["*"] = { "injected" }, -- enables injected-lang formatting for all filetypes
			},
			formatters = {
				sqruff = {
					inherit = false,
					command = "sqruff",
					args = { "fix", "--force", "$FILENAME" },
					stdin = false,
				},
			},
			default_format_opts = {
				lsp_format = "fallback",
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
	},
}

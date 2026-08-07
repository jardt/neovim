local nix = require("config.nix")

local formatters_by_ft = {
	lua = { "stylua" },
	-- You can customize some of the format options for the filetype (:help conform.format)
	rust = { "rustfmt", lsp_format = "fallback" },
	-- Conform will run the first available formatter
	javascript = { "prettierd", "prettier", stop_after_first = true },
	typescript = { "prettierd", "prettier", stop_after_first = true },
	htmlangular = { "prettierd", "prettier", stop_after_first = true },
	css = { "prettierd", "prettier", stop_after_first = true },
	svelte = { "prettierd", "prettier", stop_after_first = true },
	typescriptreact = { "prettierd", "prettier", stop_after_first = true },
	yaml = { "yamlfmt", stop_after_first = true },
	json = { "fixjson", stop_after_first = true },
	markdown = { "markdownlint", stop_after_first = true },
	go = { "goimports-reviser", "gofumpt" },
	sql = { "sqruff" },
	mysql = { "sqruff" },
	plsql = { "sqruff" },
	nix = { "nixfmt" },
	hlc = { "packer_fmt" },
	typst = { "typstyle" },
	tf = { "terraform_fmt" },
	terraform = { "terraform_fmt" },
	["terraform-vars"] = { "terraform_fmt" },
	["*"] = { "injected" }, -- enables injected-lang formatting for all filetypes
}

-- The PowerShell toolchain is heavy, so the langs.powershell Nix category
-- controls both the runtime packages and this formatter entry.
if nix.enableForCategory("langs.powershell", false) then
	formatters_by_ft.ps1 = { "pwsh_format" }
end

return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		enabled = nix.enableForCategory("formatlint", true),
		cmd = { "ConformInfo" },
		-- This will provide type hinting with LuaLS
		---@module "conform"
		---@type conform.setupOpts
		opts = {
			keys = {
				{
					"<leader>F",
					function()
						require("conform").format({ formatters = { "injected" }, timeout_ms = 5000 })
					end,
					mode = { "n", "v" },
					desc = "Format Injected Langs",
				},
			},
			formatters_by_ft = formatters_by_ft,
			formatters = {
				sqruff = {
					inherit = false,
					command = "sqruff",
					args = { "fix", "--force", "$FILENAME" },
					stdin = false,
				},
				-- Wrapper around PSScriptAnalyzer's Invoke-Formatter, supplied by
				-- the langs.powershell Nix spec. The filename lets the wrapper
				-- find a PSScriptAnalyzerSettings.psd1 near the buffer.
				pwsh_format = {
					inherit = false,
					command = "pwsh-format",
					args = { "$FILENAME" },
					stdin = true,
					condition = function()
						return vim.fn.executable("pwsh-format") == 1
					end,
				},
			},
			default_format_opts = {
				lsp_format = "fallback",
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 2500,
				lsp_format = "fallback",
			},
		},
	},
}

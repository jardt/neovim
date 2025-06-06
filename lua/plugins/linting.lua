return {
	{
		"mfussenegger/nvim-lint",
		enabled = require("nixCatsUtils").enableForCategory("formatlint", false),
		event = {
			"BufReadPre",
			"BufNewFile",
		},
		opts = {},
		config = function(_, _opts)
			local lint = require("lint")

			lint.linters_by_ft = {
				solidity = { "solhint" },
				typescript = { "eslint_d" },
				javascript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				svelte = { "eslint_d" },
				lua = { "luacheck" },
				sql = { "sqruff" },
				mysql = { "sqruff" },
				plsql = { "sqruff" },
				dockerfile = { "hadolint" },
				terraform = { "terraform_validate" },
				tf = { "terraform_validate" },
			}

			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "BufEnter" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
}

return {
	{
		"dmmulroy/ts-error-translator.nvim",
		name = "ts-error-translator",
		enabled = require("nixCatsUtils").enableForCategory("langs.web", false),
		event = "LspAttach",
		config = function()
			require("ts-error-translator").setup({
				servers = {
					"vtsls",
					"svelte",
				},
			})
		end,
	},
}

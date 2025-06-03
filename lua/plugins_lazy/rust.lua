return {
	{
		"mrcjkb/rustaceanvim",
		version = "^5", -- Recommended
		event = "BufRead",
		ft = "rust",
	},
	{ "cordx56/rustowl", lazy = true, dependencies = { "neovim/nvim-lspconfig" } },
}

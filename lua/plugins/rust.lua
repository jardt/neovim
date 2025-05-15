return {
	{
		"mrcjkb/rustaceanvim",
		version = "^5", -- Recommended
		event = "BufRead",
		ft = "rust",
		config = function(_, opts)
			local package_path = require("mason-registry").get_package("codelldb"):get_install_path()
			local codelldb = package_path .. "/extension/adapter/codelldb"
			local library_path = package_path .. "/extension/lldb/lib/liblldb.dylib"
			opts.dap = {
				adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path),
			}
		end,
	},
	{ "cordx56/rustowl", lazy = true, dependencies = { "neovim/nvim-lspconfig" } },
}

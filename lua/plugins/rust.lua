return {
	{
		"mrcjkb/rustaceanvim",
		version = "^5", -- Recommended
		enabled = require("nixCatsUtils").enableForCategory("langs.rust", false),
		event = "BufRead",
		ft = "rust",
	},
	-- TODO: rustowl
	{
		"cordx56/rustowl",
		version = "*", -- Latest stable version
		build = "cargo binstall rustowl",
		enabled = false,
		lazy = false, -- This plugin is already lazy
		opts = {
			client = {
				on_attach = function(_, buffer)
					vim.keymap.set("n", "<leader>o", function()
						require("rustowl").toggle(buffer)
					end, { buffer = buffer, desc = "Toggle RustOwl" })
				end,
			},
		},
	},
}

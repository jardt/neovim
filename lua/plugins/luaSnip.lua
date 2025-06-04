return {
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		event = "InsertEnter",
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		name = "luasnip",
		-- install jsregexp (optional!).
		build = require("nixCatsUtils").lazyAdd((function()
			-- Build Step is needed for regex support in snippets.
			-- This step is not supported in many windows environments.
			-- Remove the below condition to re-enable on windows.
			if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
				return
			end
			return "make install_jsregexp"
		end)()),
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			local luasnip = require("luasnip")
			luasnip.config.setup({
				history = true,
				updateevents = "TextChanged,TextChangedI",
				enable_autosnippets = true,
			})

			-- add vscode exported completions
			--require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippets" })
			local ls = require("luasnip")
			vim.keymap.set({ "i" }, "<C-e>", function()
				ls.expand()
			end, { silent = true })
			vim.keymap.set({ "i", "s" }, "<C-n>", function()
				ls.jump(1)
			end, { silent = true })
			vim.keymap.set({ "i", "s" }, "<C-p>", function()
				ls.jump(-1)
			end, { silent = true })
			vim.keymap.set({ "i", "s" }, "<C-c>", function()
				if ls.choice_active() then
					ls.change_choice(1)
				end
			end, { silent = true })
		end,
	},
}

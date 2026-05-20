vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

_G.nix_config = require("config.nix")

local config_source = debug.getinfo(1, "S").source:sub(2)
local config_root = vim.fn.fnamemodify(config_source, ":p:h")
vim.opt.runtimepath:prepend(config_root)
package.path = config_root .. "/lua/?.lua;" .. config_root .. "/lua/?/init.lua;" .. package.path

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local function getlockfilepath()
	local unwrapped = nix_config.get(nil, "settings", "unwrappedCfgPath")
	if nix_config.is_nix and type(unwrapped) == "string" then
		return unwrapped .. "/lazy-lock.json"
	end
	return vim.fn.stdpath("config") .. "/lazy-lock.json"
end

local lazyOptions = {
	lockfile = getlockfilepath(),
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
}

require("config.lazy").setup(lazyOptions)

require("config.lsp")
require("config.options")
require("config.keymaps")
require("config.autocommands")
require("config.macros")

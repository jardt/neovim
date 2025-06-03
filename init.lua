vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("nixCatsUtils").setup({
	non_nix_value = true,
})

local lazyCat = require("nixCatsUtils.lazyCat")
lazyCat.setup(nixCats.pawsible({ "allPlugins", "start", "lazy.nvim" }), { import = "plugins" })

-- not needed with nixcats
--require("config.lazy")

require("config.lsp")
require("config.options")
require("config.keymaps")
require("config.autocommands")
require("config.macros")

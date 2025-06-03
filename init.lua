vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nixCatsUtils").setup({
	non_nix_value = true,
})

require("config.lazy")

require("config.lsp")
require("config.options")
require("config.keymaps")
require("config.autocommands")
require("config.macros")

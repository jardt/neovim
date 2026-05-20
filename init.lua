vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local config_source = debug.getinfo(1, "S").source:sub(2)
local config_root = vim.fn.fnamemodify(config_source, ":p:h")
vim.opt.runtimepath:prepend(config_root)
package.path = config_root .. "/lua/?.lua;" .. config_root .. "/lua/?/init.lua;" .. package.path

_G.nix_config = require("config.nix")
_G.pack_config = require("config.pack")
pack_config.add()
vim.cmd.packloadall()

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

_G.lze = require("config.lze").setup()

require("config.plugins").setup()
require("config.lazy_plugins").setup()

require("config.lsp")
require("config.options")
require("config.keymaps")
require("config.autocommands")
require("config.macros")

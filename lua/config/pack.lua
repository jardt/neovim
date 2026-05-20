local M = {}

local function gh(repo)
	return "https://github.com/" .. repo
end

local function plugin(repo, name, version)
	name = name or repo:match("/([^/]+)$")
	local spec = { src = gh(repo), name = name }
	if version ~= nil then
		spec.version = version
	end
	return spec
end

M.plugins = {
	plugin("BirdeeHub/lze"),
	plugin("BirdeeHub/lzextras"),
	plugin("folke/snacks.nvim"),
	plugin("ibhagwan/fzf-lua"),
	plugin("nvim-treesitter/nvim-treesitter", nil, "master"),
	plugin("nvim-treesitter/nvim-treesitter-textobjects", nil, "master"),
	plugin("neovim/nvim-lspconfig"),
	plugin("folke/which-key.nvim"),
	plugin("folke/lazydev.nvim"),
	plugin("b0o/schemastore.nvim"),
	plugin("saghen/blink.cmp"),
	plugin("saghen/blink.compat"),
	plugin("saghen/blink.download", "blink.download"),
	plugin("saghen/blink.lib", "blink.lib"),
	plugin("L3MON4D3/LuaSnip"),
	plugin("rafamadriz/friendly-snippets"),
	plugin("nvim-lua/plenary.nvim"),
	plugin("MunifTanjim/nui.nvim"),
	plugin("echasnovski/mini.icons"),
	plugin("echasnovski/mini.ai"),
	plugin("echasnovski/mini.base16"),
	plugin("echasnovski/mini.hipatterns"),
	plugin("echasnovski/mini.pairs"),
	plugin("catppuccin/nvim", "catppuccin"),
	plugin("rebelot/kanagawa.nvim"),
	plugin("ellisonleao/gruvbox.nvim"),
	plugin("scottmckendry/cyberdream.nvim"),
	plugin("shaunsingh/nord.nvim"),
	plugin("nvim-lualine/lualine.nvim"),
	plugin("lewis6991/gitsigns.nvim"),
	plugin("tpope/vim-fugitive"),
	plugin("folke/todo-comments.nvim"),
	plugin("kylechui/nvim-surround"),
	plugin("christoomey/vim-tmux-navigator"),
	plugin("stevearc/conform.nvim"),
	plugin("mfussenegger/nvim-lint"),
	plugin("MagicDuck/grug-far.nvim"),
	plugin("RRethy/vim-illuminate"),
	plugin("saghen/blink.indent"),
	plugin("chrisgrieser/nvim-lsp-endhints"),
	plugin("mikavilpas/yazi.nvim"),
}

M.lazy_plugins = {
	plugin("tpope/vim-dadbod"),
	plugin("kristijanhusak/vim-dadbod-ui"),
	plugin("kristijanhusak/vim-dadbod-completion"),
	plugin("mfussenegger/nvim-dap"),
	plugin("rcarriga/nvim-dap-ui"),
	plugin("theHamsta/nvim-dap-virtual-text"),
	plugin("leoluz/nvim-dap-go"),
	plugin("nvim-neotest/nvim-nio"),
	plugin("nvim-neotest/neotest"),
	plugin("marilari88/neotest-vitest"),
	plugin("fredrikaverpil/neotest-golang"),
	plugin("nsidorenco/neotest-vstest"),
	plugin("folke/flash.nvim"),
	plugin("NeogitOrg/neogit"),
	plugin("sindrets/diffview.nvim"),
	plugin("nvim-neo-tree/neo-tree.nvim"),
	plugin("folke/noice.nvim"),
	plugin("folke/trouble.nvim"),
	plugin("folke/sidekick.nvim"),
	plugin("m4xshen/hardtime.nvim"),
	plugin("ThePrimeagen/harpoon"),
	plugin("MeanderingProgrammer/render-markdown.nvim"),
	plugin("iamcco/markdown-preview.nvim"),
	plugin("obsidian-nvim/obsidian.nvim"),
	plugin("mrcjkb/rustaceanvim"),
	plugin("cordx56/rustowl"),
	plugin("chomosuke/typst-preview.nvim"),
	plugin("lervag/vimtex"),
	plugin("mfussenegger/nvim-ansible"),
	plugin("dmmulroy/ts-error-translator.nvim"),
	plugin("dmmulroy/tsc.nvim"),
	plugin("goolord/alpha-nvim"),
	plugin("mbbill/undotree"),
	plugin("elkowar/yuck.vim"),
}

local function is_nix()
	local nix = rawget(_G, "nix_config")
	if nix == nil then
		local ok, loaded = pcall(require, "config.nix")
		nix = ok and loaded or nil
	end
	return nix ~= nil and nix.is_nix
end

function M.add()
	if is_nix() then
		return
	end

	if vim.pack == nil then
		vim.notify("This config requires Neovim with vim.pack for non-Nix plugin management", vim.log.levels.ERROR)
		return
	end

	vim.pack.add(M.plugins, { confirm = false, load = false })
	pcall(vim.cmd.packadd, "lze")
	pcall(vim.cmd.packadd, "lzextras")
	vim.pack.add(M.lazy_plugins, { confirm = false, load = false })
end

function M.load(name)
	return pcall(vim.cmd.packadd, name)
end

return M

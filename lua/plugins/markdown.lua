return {
	{
		"iamcco/markdown-preview.nvim",
		enabled = require("nixCatsUtils").enableForCategory("langs.markdown", false),
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "mkdp#util#install()",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		enabled = require("nixCatsUtils").enableForCategory("langs.markdown", false),
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" }, -- if you use standalone mini plugins
		ft = "markdown",
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {},
	},
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		enabled = require("nixCatsUtils").enableForCategory("obsidian", false),
		lazy = true,
		ft = "markdown",
		-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
		-- event = {
		--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
		--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
		--   -- refer to `:h file-pattern` for more examples
		--   "BufReadPre path/to/my-vault/*.md",
		--   "BufNewFile path/to/my-vault/*.md",
		-- },
		dependencies = {
			-- Required.
			"nvim-lua/plenary.nvim",
		},
		opts = {
			ui = { enable = false },
			workspaces = {
				-- {
				-- 	name = "notes",
				-- 	path = "/Users/jardar.ton/notes",
				-- },
				-- {
				--     name = "master",
				--     path = "/Users/jardar/Library/Mobile Documents/iCloud~md~obsidian/Documents/master",
				-- },
				-- {
				--     name = "audit",
				--     path = "/Users/jardar/Library/Mobile Documents/iCloud~md~obsidian/Documents/audit",
				-- },
			},
			-- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
			completion = {
				-- Set to false to disable completion.
				nvim_cmp = false,
				-- Trigger completion at 2 chars.
				min_chars = 2,
			},

			-- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
			-- way then set 'mappings = {}'.
			mappings = {
				["gd"] = {
					action = function()
						return require("obsidian").util.gf_passthrough()
					end,
					opts = { noremap = false, expr = true, buffer = true },
				},
				-- Toggle check-boxes.
				["<leader>ch"] = {
					action = function()
						return require("obsidian").util.toggle_checkbox()
					end,
					opts = { buffer = true },
				},
				-- Smart action depending on context, either follow link or toggle checkbox.
				["<cr>"] = {
					action = function()
						return require("obsidian").util.smart_action()
					end,
					opts = { buffer = true, expr = true },
				},
				-- Smart action depending on context, either follow link or toggle checkbox.
				["<leader>N"] = {
					action = function()
						return "<cmd>ObsidianNew<cr>"
					end,
					opts = { buffer = true, expr = true },
				},
				["<leader>oo"] = {
					action = function()
						return "<cmd>ObsidianOpen<cr>"
					end,
					opts = { buffer = true, expr = true },
				},
				["<leader>fl"] = {
					action = function()
						return "<cmd>ObsidianLinks<cr>"
					end,
					opts = { buffer = true, expr = true },
				},
				["<leader>gr"] = {
					action = function()
						return "<cmd>ObsidianBacklinks<cr>"
					end,
					opts = { buffer = true, expr = true },
				},
			},
		},
		config = function(_, opts)
			require("obsidian").setup(opts)

			-- HACK: fix error, disable completion.nvim_cmp option, manually register sources
			local cmp = require("cmp")
			cmp.register_source("obsidian", require("cmp_obsidian").new())
			cmp.register_source("obsidian_new", require("cmp_obsidian_new").new())
			cmp.register_source("obsidian_tags", require("cmp_obsidian_tags").new())
		end,
	},
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- last release is way too old and doesn't work on Windows
		build = require("nixCatsUtils").lazyAdd(":TSUpdate"),
		event = { "VeryLazy" },
		lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
		init = function(plugin)
			-- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
			-- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
			-- no longer trigger the **nvim-treesitter** module to be loaded in time.
			-- Luckily, the only things that those plugins need are the custom queries, which we make available
			-- during startup.
			require("lazy.core.loader").add_to_rtp(plugin)
			require("nvim-treesitter.query_predicates")
		end,
		opts_extend = { "ensure_installed" },
		---@type TSConfig
		---@diagnostic disable-next-line: missing-fields
		config = function()
			require("nvim-treesitter.install").prefer_git = true
			local configs = require("nvim-treesitter.configs")
			configs.setup({

				ensure_installed = require("nixCatsUtils").lazyAdd({
					"c",
					"ron", --rust object notation
					"lua",
					"vim",
					"vimdoc",
					"javascript",
					"html",
					"typescript",
					"tsx",
					"css",
					"c_sharp",
					"bash",
					"go",
					"gomod",
					"gowork",
					"gosum",
					"comment",
					"css",
					"diff",
					"toml",
					"git_rebase",
					"vim",
					"jsdoc",
					"vimdoc",
					"gitcommit",
					"gitignore",
					"jsdoc",
					"json",
					"json5",
					"jsonc",
					"markdown",
					"markdown_inline",
					"astro",
					"pug",
					"regex",
					"rust",
					"yaml",
					"solidity",
					"java",
					"kotlin",
					"angular",
					"svelte",
					"sql",
					"c_sharp",
					"tmux",
					"xml",
					"dockerfile",
					"csv",
					"yuck",
				}),
				highlight = { enable = true, use_languagetree = true },
				indent = { enable = true },
				rainbow = { enable = true, extended_mode = true, max_file_lines = 1000 },
				sync_install = true,
				auto_install = require("nixCatsUtils").lazyAdd(true, false),
				autopairs = { enable = true },
				autotag = { enable = true },
				context_commentstring = { enable = true },
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		config = function()
			require("nvim-treesitter.configs").setup({
				textobjects = {
					select = {
						enable = true,

						-- Automatically jump forward to textobj, similar to targets.vim
						lookahead = true,

						keymaps = {
							["af"] = { query = "@function.outer", desc = "Function inner" },
							["if"] = { query = "@function.inner", desc = "Function outer" },
							["ac"] = { query = "@class.outer", desc = "Class outer" },
							["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
							-- You can also use captures from other query groups like `locals.scm`
							["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
							["ia"] = {
								query = "@parameter.inner",
								desc = "argument inner",
							},
							["aa"] = {
								query = "@parameter.outer",
								desc = "argument outer",
							},
						},
						-- You can choose the select mode (default is charwise 'v')
						--
						-- Can also be a function which gets passed a table with the keys
						-- * query_string: eg '@function.inner'
						-- * method: eg 'v' or 'o'
						-- and should return the mode ('v', 'V', or '<c-v>') or a table
						-- mapping query_strings to modes.
						selection_modes = {
							["@parameter.outer"] = "v", -- charwise
							["@function.outer"] = "V", -- linewise
							["@class.outer"] = "<c-v>", -- blockwise
						},
						-- If you set this to `true` (default is `false`) then any textobject is
						-- extended to include preceding or succeeding whitespace. Succeeding
						-- whitespace has priority in order to act similarly to eg the built-in
						-- `ap`.
						--
						-- Can also be a function which gets passed a table with the keys
						-- * query_string: eg '@function.inner'
						-- * selection_mode: eg 'v'
						-- and should return true or false
						include_surrounding_whitespace = true,
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]r"] = "@return.outer",
							["]]"] = { query = "@class.outer", desc = "Next class start" },
							--
							-- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queries.
							["]o"] = "@loop.*",
							-- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
							--
							-- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
							-- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
							["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
							["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
						},
						goto_next_end = {
							["]M"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[["] = "@class.outer",
						},
						goto_previous_end = {
							["[M"] = "@function.outer",
						},
						-- Below will go to either the start or the end, whichever is closer.
						-- Use if you want more granular movements
						-- Make it even more gradual by adding multiple queries and regex.
						goto_next = {
							["]c"] = "@conditional.outer",
						},
						goto_previous = {
							["[C"] = "@conditional.outer",
						},
					},
				},
			})
		end,
	},
}

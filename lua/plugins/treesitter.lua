return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = require("nixCatsUtils").lazyAdd(":TSUpdate"),
		lazy = false,
		branch = "main",
		---@type TSConfig
		---@diagnostic disable-next-line: missing-fields
		config = function()
			local ts = require("nvim-treesitter")

			-- State tracking for async parser loading
			local parsers_loaded = {}
			local parsers_pending = {}
			local parsers_failed = {}

			local ns = vim.api.nvim_create_namespace("treesitter.async")

			-- Helper to start highlighting and indentation
			local function start(buf, lang)
				local ok = pcall(vim.treesitter.start, buf, lang)
				if ok then
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
				return ok
			end

			-- Install core parsers after lazy.nvim finishes loading all plugins
			vim.api.nvim_create_autocmd("User", {
				pattern = "LazyDone",
				once = true,
				callback = function()
					ts.install(require("nixCatsUtils").lazyAdd({
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
					}, {
						max_jobs = 8,
					}))
				end,
			})

			-- Decoration provider for async parser loading
			vim.api.nvim_set_decoration_provider(ns, {
				on_start = vim.schedule_wrap(function()
					if #parsers_pending == 0 then
						return false
					end
					for _, data in ipairs(parsers_pending) do
						if vim.api.nvim_buf_is_valid(data.buf) then
							if start(data.buf, data.lang) then
								parsers_loaded[data.lang] = true
							else
								parsers_failed[data.lang] = true
							end
						end
					end
					parsers_pending = {}
				end),
			})

			local group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true })

			local ignore_filetypes = {
				"checkhealth",
				"lazy",
				"mason",
				"snacks_dashboard",
				"snacks_notif",
				"snacks_win",
			}
			-- Auto-install parsers and enable highlighting on FileType
			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				desc = "Enable treesitter highlighting and indentation (non-blocking)",
				callback = function(event)
					if vim.tbl_contains(ignore_filetypes, event.match) then
						return
					end

					local lang = vim.treesitter.language.get_lang(event.match) or event.match
					local buf = event.buf

					if parsers_failed[lang] then
						return
					end

					if parsers_loaded[lang] then
						-- Parser already loaded, start immediately (fast path)
						start(buf, lang)
					else
						-- Queue for async loading
						table.insert(parsers_pending, { buf = buf, lang = lang })
					end

					-- Auto-install missing parsers (async, no-op if already installed)
					--	ts.install({ lang })
				end,
			})
		end,
	},
	{

		"nvim-treesitter/nvim-treesitter-textobjects",
		name = "treesitter-textobjects",
		lazy = false,
		config = function()
			-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main?tab=readme-ov-file#using-a-package-manager

			-- Disable entire built-in ftplugin mappings to avoid conflicts.

			-- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.

			vim.g.no_plugin_maps = true

			-- Or, disable per filetype (add as you like)

			-- vim.g.no_python_maps = true

			-- vim.g.no_ruby_maps = true

			-- vim.g.no_rust_maps = true

			-- vim.g.no_go_maps = true
		end,

		after = function(plugin)
			require("nvim-treesitter-textobjects").setup({

				select = {

					-- Automatically jump forward to textobj, similar to targets.vim

					lookahead = true,

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

						-- ['@class.outer'] = '<c-v>', -- blockwise
					},

					-- If you set this to `true` (default is `false`) then any textobject is

					-- extended to include preceding or succeeding whitespace. Succeeding

					-- whitespace has priority in order to act similarly to eg the built-in

					-- `ap`.

					--

					-- Can also be a function which gets passed a table with the keys

					-- * query_string: eg '@function.inner'

					-- * selection_mode: eg 'v'

					-- and should return true of false

					include_surrounding_whitespace = false,
				},
				textobjects = {
					swap = {
						enable = true,
						swap_next = {
							["<leader><Right>"] = "@parameter.inner",
						},
						swap_previous = {
							["<leader><Left>"] = "@parameter.inner",
						},
					},
				},
			})

			-- keymaps

			-- You can use the capture groups defined in `textobjects.scm`

			vim.keymap.set({ "x", "o" }, "am", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
			end)

			vim.keymap.set({ "x", "o" }, "im", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
			end)

			vim.keymap.set({ "x", "o" }, "ac", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
			end)

			vim.keymap.set({ "x", "o" }, "ic", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
			end)

			-- You can also use captures from other query groups like `locals.scm`

			vim.keymap.set({ "x", "o" }, "as", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
			end)

			-- NOTE: for more textobjects options, see the following link.

			-- This template is using the new `main` branch of the repo.

			-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
		end,
	},
}
-- set_jumps = true, -- whether to set jumps in the jumplist
-- goto_next_start = {
-- 	["]r"] = "@return.outer",
-- 	["]]"] = { query = "@class.outer", desc = "Next class start" },
-- 	--
-- 	-- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queries.
-- 	["]o"] = "@loop.*",
-- 	-- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
-- 	--
-- 	-- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
-- 	-- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
-- 	["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
-- 	["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
-- },
-- goto_next_end = {
-- 	["]M"] = "@function.outer",
-- 	["]["] = "@class.outer",
-- },
-- goto_previous_start = {
-- 	["[m"] = "@function.outer",
-- 	["[["] = "@class.outer",
-- },
-- goto_previous_end = {
-- 	["[M"] = "@function.outer",
-- },
-- -- Below will go to either the start or the end, whichever is closer.
-- -- Use if you want more granular movements
-- -- Make it even more gradual by adding multiple queries and regex.
-- goto_next = {
-- 	["]c"] = "@conditional.outer",
-- },
-- goto_previous = {
-- 	["[C"] = "@conditional.outer",

return {
	{
		"saghen/blink.cmp",
		enabled = require("nixCatsUtils").enableForCategory("completion", false),
		-- optional: provides snippets for the snippet source
		dependencies = {
			{ "rafamadriz/friendly-snippets" },
			{ "saghen/blink.compat", version = "*", opts = { impersonate_nvim_cmp = true } },
			{ "mikavilpas/blink-ripgrep.nvim" },
			{ "jdrupal-dev/css-vars.nvim", name = "blink-css-vars" },
			{ "folke/lazydev.nvim" },
		},
		event = "InsertEnter",

		-- use a release tag to download pre-built binaries
		version = "*",
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',
		config = function()
			---@type blink.cmp.Config
			local blink_opts = {
				-- 'default' for mappings similar to built-in completion
				-- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
				-- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
				-- See the full "keymap" documentation for information on defining your own keymap.
				keymap = {
					preset = "default",
					--w["<CR>"] = { "accept", "fallback" }, --not working well for cmd
					["<C-u>"] = { "scroll_documentation_up", "fallback" },
					["<C-d>"] = { "scroll_documentation_down", "fallback" },
				},

				completion = {
					documentation = {
						auto_show = true,
						auto_show_delay_ms = 500,
						window = { border = "rounded" },
					},
					accept = {
						-- experimental auto-brackets support
						auto_brackets = {
							enabled = false,
						},
					},
					menu = {
						draw = {
							treesitter = { "lsp" },
							columns = { { "kind_icon" }, { "label", gap = 1 } },
							components = {
								label = {
									text = function(ctx)
										return require("colorful-menu").blink_components_text(ctx)
									end,
									highlight = function(ctx)
										return require("colorful-menu").blink_components_highlight(ctx)
									end,
								},
							},
						},
						border = "rounded",
					},
					ghost_text = {
						enabled = vim.g.ai_cmp,
					},
				},

				appearance = {
					-- Sets the fallback highlight groups to nvim-cmp's highlight groups
					-- Useful for when your theme doesn't support blink.cmp
					-- Will be removed in a future release
					use_nvim_cmp_as_default = true,
					-- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
					-- Adjusts spacing to ensure icons are aligned
					nerd_font_variant = "mono",
				},

				-- Default list of enabled providers defined so that you can extend it
				-- elsewhere in your config, without redefining it, due to `opts_extend`
				--
				snippets = {},
				sources = {
					default = {
						"lsp",
						"path",
						"snippets",
						"buffer",
						"ripgrep",
						"obsidian",
						"obsidian_new",
						"obsidian_tags",
						"lazydev",
					},
					providers = {
						lsp = {
							name = "LSP",
							module = "blink.cmp.sources.lsp",
							score_offset = 0, -- Boost/penalize the score of the items
						},
						ripgrep = {
							module = "blink-ripgrep",
							name = "Ripgrep",
							opts = {
								prefix_min_len = 3,
								context_size = 5,
								max_filesize = "1M",
								additional_rg_options = {},
							},
						},
						lazydev = {
							name = "LazyDev",
							module = "lazydev.integrations.blink",
							score_offset = 100, -- show at a higher priority than lsp
						},
					},
				},
				signature = {
					enabled = true,
					window = { border = "rounded" },
				},
				fuzzy = { implementation = "prefer_rust_with_warning" },
			}

			if require("nixCatsUtils").getCatOrDefault("langs.markdown", true) then
				blink_opts.sources.providers.obsidian = {
					name = "obsidian",
					module = "blink.compat.source",
				}
				blink_opts.sources.providers.obsidian_new = {
					name = "obsidian_new",
					module = "blink.compat.source",
				}
				blink_opts.sources.providers.obsidian_tags = {
					name = "obsidian_tags",
					module = "blink.compat.source",
				}
			end

			-- add dadbod completion
			if require("nixCatsUtils").getCatOrDefault("database", true) then
				blink_opts.sources.providers.dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" }
				table.insert(blink_opts.sources.default, "dadbod")
			end
			if require("nixCatsUtils").getCatOrDefault("snippets", true) then
				blink_opts.snippets.preset = "luasnip"
			end

			if require("nixCatsUtils").getCatOrDefault("langs.web", true) then
				blink_opts.sources.providers.css_vars = {
					name = "css-vars",
					module = "css-vars.blink",
					opts = {
						-- WARNING: The search is not optimized to look for variables in JS files.
						-- If you change the search_extensions you might get false positives and weird completion results.
						search_extensions = { ".css", ".js", ".ts", ".jsx", ".tsx" },
					},
				}
			end
			if require("nixCatsUtils").getCatOrDefault("langs.tex", true) then
				blink_opts.sources.providers.vimtex = {
					name = "vimtex",
					module = "blink.compat.source",
					score_offset = 3,
				}
			end

			require("blink.cmp").setup(blink_opts)
		end,
	},
}

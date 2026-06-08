local M = {}

local nix = require("config.nix")

local loaded = false

local function load_completion()
	if loaded or not nix.enableForCategory("completion", true) then
		return
	end
	loaded = true

	local pack = require("config.pack")
	local plugins = { "blink.cmp", "blink.compat", "blink-ripgrep.nvim", "colorful-menu.nvim", "friendly-snippets", "lazydev.nvim", "vim-dadbod-completion" }
	if nix.getCatOrDefault("snippets", true) then
		table.insert(plugins, "luasnip")
	end
	for _, plugin in ipairs(plugins) do
		pack.load(plugin)
	end
	local ok, blink = pcall(require, "blink.cmp")
	if not ok then
		return
	end

	local opts = {
		keymap = {
			preset = "default",
			["<C-u>"] = { "scroll_documentation_up", "fallback" },
			["<C-d>"] = { "scroll_documentation_down", "fallback" },
			["<Tab>"] = {
				"snippet_forward",
				function()
					return require("sidekick").nes_jump_or_apply()
				end,
				function()
					return vim.lsp.inline_completion and vim.lsp.inline_completion.get()
				end,
				"select_and_accept",
				"fallback",
			},
		},
		completion = {
			trigger = { show_on_keyword = true },
			documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = "rounded" } },
			accept = { auto_brackets = { enabled = false } },
			menu = {
				draw = {
					treesitter = { "lsp" },
					columns = { { "kind_icon" }, { "label", gap = 1 } },
					components = {
						label = {
							text = function(ctx)
								local ok_menu, menu = pcall(require, "colorful-menu")
								return ok_menu and menu.blink_components_text(ctx) or ctx.label
							end,
							highlight = function(ctx)
								local ok_menu, menu = pcall(require, "colorful-menu")
								return ok_menu and menu.blink_components_highlight(ctx) or nil
							end,
						},
					},
				},
				border = "rounded",
			},
			ghost_text = { enabled = vim.g.ai_cmp },
		},
		appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = "mono" },
		snippets = {},
		sources = {
			default = { "lsp", "path", "buffer", "ripgrep", "lazydev" },
			per_filetype = { snacks_input = { "sidekick_templates", "buffer" }, pi_prompt = { "sidekick_templates", "buffer" } },
			providers = {
				lsp = { name = "LSP", module = "blink.cmp.sources.lsp", score_offset = 99 },
				ripgrep = { module = "blink-ripgrep", name = "Ripgrep", score_offset = 0, opts = { prefix_min_len = 3, context_size = 5, max_filesize = "1M", additional_rg_options = {} } },
				lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
				sidekick_templates = { name = "SidekickTemplates", module = "blink.sources.sidekick_templates", score_offset = 100, min_keyword_length = 0 },
			},
		},
		signature = { enabled = true, window = { border = "rounded" } },
		fuzzy = { implementation = "prefer_rust_with_warning" },
	}

	if nix.getCatOrDefault("langs.markdown", true) then
		opts.sources.providers.obsidian = { name = "obsidian", module = "blink.compat.source" }
		opts.sources.providers.obsidian_new = { name = "obsidian_new", module = "blink.compat.source" }
		opts.sources.providers.obsidian_tags = { name = "obsidian_tags", module = "blink.compat.source" }
		vim.list_extend(opts.sources.default, { "obsidian", "obsidian_new", "obsidian_tags" })
	end

	if nix.getCatOrDefault("database", true) and pack.load("vim-dadbod-completion") then
		local has_dadbod = pcall(require, "vim_dadbod_completion.blink")
		if has_dadbod then
			opts.sources.providers.dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" }
			table.insert(opts.sources.default, "dadbod")
		end
	end
	if nix.getCatOrDefault("snippets", true) then
		opts.snippets.preset = "luasnip"
		table.insert(opts.sources.default, 3, "snippets")
	end
	if nix.getCatOrDefault("langs.tex", true) then
		opts.sources.providers.vimtex = { name = "vimtex", module = "blink.compat.source", score_offset = 3 }
	end

	blink.setup(opts)
end

function M.setup()
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = vim.api.nvim_create_augroup("LoadCompletion", { clear = true }),
		once = true,
		callback = load_completion,
	})
end

return M

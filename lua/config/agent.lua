local M = {}

function M.setup()
	vim.opt.number = true
	vim.opt.termguicolors = true
	vim.opt.ignorecase = true
	vim.opt.smartcase = true
	vim.opt.splitbelow = true
	vim.opt.splitright = true
	vim.opt.undofile = true
	vim.opt.expandtab = true
	vim.opt.shiftwidth = 2
	vim.opt.tabstop = 2

	-- Only the UI primitives used by the local Pi integration.
	require("snacks").setup({ input = { enabled = true }, picker = { enabled = true } })
	require("config.plugins").setup({ "plugins.themes", "plugins.treesitter", "plugins.fff", "plugins.yazi" })
	require("pi").setup()

	require("config.pack").load("blink.cmp")
	require("blink.cmp").setup({
		keymap = { preset = "default" },
		sources = {
			default = { "path", "buffer" },
			per_filetype = { pi_prompt = { "pi_templates", "buffer" } },
			providers = {
				pi_templates = {
					name = "PiTemplates",
					module = "blink.sources.pi_templates",
					min_keyword_length = 0,
				},
			},
		},
		completion = {
			documentation = { auto_show = true },
			accept = { auto_brackets = { enabled = false } },
		},
	})

	require("render-markdown").setup({})
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("AgentMarkdown", { clear = true }),
		pattern = "markdown",
		callback = function()
			vim.opt_local.wrap = true
			vim.opt_local.linebreak = true
			vim.opt_local.breakindent = true
			vim.opt_local.conceallevel = 2
			vim.opt_local.textwidth = 0
			vim.opt_local.formatoptions:remove("t")
			vim.opt_local.formatoptions:append("n")
			vim.keymap.set("n", "j", "gj", { buffer = true })
			vim.keymap.set("n", "k", "gk", { buffer = true })
		end,
	})
end

return M

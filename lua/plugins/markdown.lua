local specs = {
	{
		"iamcco/markdown-preview.nvim",
		enabled = require("config.nix").enableForCategory("langs.markdown", false),
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "mkdp#util#install()",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
			vim.g.mkdp_command_for_global = 1
		end,
		ft = { "markdown" },
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		enabled = require("config.nix").enableForCategory("langs.markdown", false),
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
		ft = "markdown",
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {},
	},
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*",
		enabled = require("config.nix").enableForCategory("obsidian", false),
		lazy = true,
		ft = "markdown",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			ui = { enable = false },
			workspaces = {},
			completion = { nvim_cmp = false, min_chars = 2 },
			mappings = {
				["gd"] = {
					action = function()
						return require("obsidian").util.gf_passthrough()
					end,
					opts = { noremap = false, expr = true, buffer = true },
				},
				["<leader>ch"] = {
					action = function()
						return require("obsidian").util.toggle_checkbox()
					end,
					opts = { buffer = true },
				},
				["<cr>"] = {
					action = function()
						return require("obsidian").util.smart_action()
					end,
					opts = { buffer = true, expr = true },
				},
			},
		},
	},
}

local preview_loaded = false

local function load_markdown_preview()
	if preview_loaded then
		return true
	end

	if specs[1].enabled == false then
		vim.notify("markdown-preview.nvim is disabled", vim.log.levels.WARN)
		return false
	end

	if type(specs[1].init) == "function" then
		specs[1].init()
	end

	pcall(vim.api.nvim_del_user_command, "MarkdownPreview")
	pcall(vim.api.nvim_del_user_command, "MarkdownPreviewStop")
	pcall(vim.api.nvim_del_user_command, "MarkdownPreviewToggle")
	require("config.pack").load("markdown-preview.nvim")
	preview_loaded = true
	return true
end

local function preview_command(command, args)
	if not load_markdown_preview() then
		return
	end
	vim.cmd(command .. (args ~= "" and " " .. args or ""))
end

local function setup_render_markdown()
	if specs[2].enabled == false then
		return
	end
	require("config.pack").load("render-markdown.nvim")
	local ok, render = pcall(require, "render-markdown")
	if ok and type(render.setup) == "function" then
		render.setup(specs[2].opts)
	end
end

function specs.setup()
	if specs[1].enabled ~= false and type(specs[1].init) == "function" then
		specs[1].init()
	end

	for _, command in ipairs({ "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" }) do
		vim.api.nvim_create_user_command(command, function(opts)
			preview_command(command, opts.args)
		end, { nargs = "*", bang = true })
	end

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "markdown",
		callback = setup_render_markdown,
	})
end

return specs

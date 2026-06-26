local config = {
	base_path = vim.fn.getcwd(),
	prompt = "❯ ",
	max_results = 100,
	lazy_sync = true,
	prompt_vim_mode = true,
	layout = {
		height = 0.8,
		width = 0.8,
		prompt_position = "bottom",
		preview_position = "right",
		preview_size = 0.5,
		anchor = "center",
	},
	preview = {
		enabled = true,
		line_numbers = false,
		wrap_lines = false,
	},
	keymaps = {
		close = "<Esc>",
		select_split = "<C-b>",
		select_vsplit = "<C-v>",
		select_tab = "<C-t>",
		preview_scroll_up = "<C-u>",
		preview_scroll_down = "<C-d>",
		send_to_quickfix = "<C-q>",
	},
	grep = {
		smart_case = true,
		modes = { "plain", "regex", "fuzzy" },
	},
}

return {
	{
		"dmtrKovalenko/fff.nvim",
		lazy = false,
		init = function()
			vim.g.fff = config
		end,
		keys = {
			{
				"<leader>o",
				function()
					require("fff").find_files()
				end,
				desc = "Find Files",
			},
			{
				"<leader><tab>",
				function()
					require("fff").find_files({ resume = true })
				end,
				desc = "Resume",
			},
			{
				"<leader>/",
				function()
					require("fff").live_grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>sw",
				function()
					require("fff").live_grep({ query = vim.fn.expand("<cword>") })
				end,
				desc = "Word (Root Dir)",
			},
			{
				"<leader>*",
				function()
					require("fff").live_grep({ query = vim.fn.expand("<cword>") })
				end,
				desc = "Word (Root Dir)",
			},
		},
		config = function()
			vim.g.fff = config

			local ok, rust = pcall(require, "fff.rust")
			if not ok or rust == nil then
				local download_ok, download = pcall(require, "fff.download")
				if download_ok then
					pcall(download.download_or_build_binary)
				end
			end

			require("fff").setup(config)
		end,
	},
}

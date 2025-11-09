return {
	{
		"NeogitOrg/neogit",
		enabled = false,
		event = "BufReadPre",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration
			"ibhagwan/fzf-lua", -- optional
		},
		config = true,
		keys = {
			{
				"<leader>gg",
				function()
					require("neogit").open({ kind = "floating" })
				end,
				desc = "Neogit",
			},
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		enabled = require("nixCatsUtils").enableForCategory("git", true),
		event = "BufReadPre",
		opts = {
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
			numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
			linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
			word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
			watch_gitdir = {
				follow_files = true,
			},
			attach_to_untracked = true,
			current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
				delay = 1000,
				ignore_whitespace = false,
				virt_text_priority = 100,
			},
			current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
			sign_priority = 6,
			update_debounce = 100,
			status_formatter = nil, -- Use default
			max_file_length = 40000, -- Disable if file is longer than this (in lines)
			preview_config = {
				-- Options passed to nvim_open_win
				border = "single",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
		},
	},
	{
		"tpope/vim-fugitive",
		enabled = require("nixCatsUtils").enableForCategory("git", true),
		cmd = {
			"Gco",
			"Git",
			"Gcb",
			"Gl",
			"Gp",
			"Gmom",
			"Gpom",
			"Gread",
			"Gvsplit",
			"Cpr",
		},
	},
	{
		"sindrets/diffview.nvim",
		enabled = require("nixCatsUtils").enableForCategory("git", true),
		cmd = {
			"DiffviewClose",
			"DiffviewFileHistory",
			"DiffviewFocusFiles",
			"DiffviewLog",
			"DiffviewOpen",
			"DiffviewRefresh",
			"DiffviewToggleFiles",
		},
		keys = {
			{ "<Leader>gd", "<cmd>DiffviewFileHistory %<CR>", desc = "diff file" },
			{ "<Leader>gd", "<cmd>DiffviewFileHistory <CR>", desc = "diff all files" },
			{ "<Leader>gs", "<cmd>DiffviewOpen<CR>", desc = "diff status" },
			{ "<Leader>qd", "<cmd>DiffviewClose<CR>", desc = "close diff view" },
			{
				"<leader>gS",
				"<cmd>DiffviewOpen origin/main...HEAD --imply-local<CR>",
				desc = "diff against origin main",
			},
		},
	},
}

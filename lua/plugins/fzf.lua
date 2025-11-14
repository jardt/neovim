return {
	{
		"ibhagwan/fzf-lua",
		event = "VeryLazy",
		enabled = require("nixCatsUtils").getCatOrDefault("opts.picker.fzf", false),
		dependencies = { "echasnovski/mini.icons" },
		opts = function()
			local fzf = require("fzf-lua")
			local config = fzf.config
			local actions = fzf.actions

			-- keymaps
			config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
			config.defaults.keymap.fzf["ctrl-s"] = "jump"
			config.defaults.keymap.fzf["ctrl-d"] = "preview-page-down"
			config.defaults.keymap.fzf["ctrl-u"] = "preview-page-up"
			config.defaults.keymap.builtin["<c-d>"] = "preview-page-down"
			config.defaults.keymap.builtin["<c-u>"] = "preview-page-up"
			config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"

			return {
				"default-title",
				fzf_colors = {
					true,
					bg = "-1",
					gutter = "-1",
				},
				fzf_opts = {
					["--no-scrollbar"] = true,
				},
				defaults = {
					formatter = "path.filename_first",
					--formatter = "path.dirname_first",
				},
				actions = {
					files = {
						["default"] = actions.file_edit_or_qf,
						["ctrl-y"] = actions.file_edit,
						["ctrl-b"] = actions.file_split,
						["ctrl-v"] = actions.file_vsplit,
						["ctrl-t"] = actions.file_tabedit,
					},
				},
				winopts = {
					width = 0.8,
					height = 0.8,
					row = 0.5,
					col = 0.5,
					preview = {
						scrollchars = { "┃", "" },
					},
				},
				files = {
					cwd_prompt = false,
					actions = {
						["ctrl-i"] = { actions.toggle_ignore },
						["ctrl-h"] = { actions.toggle_hidden },
					},
				},
				grep = {
					actions = {
						["ctrl-i"] = { actions.toggle_ignore },
						["ctrl-h"] = { actions.toggle_hidden },
					},
				},
				lsp = {
					symbols = {
						symbol_hl = function(s)
							return "TroubleIcon" .. s
						end,
						symbol_fmt = function(s)
							return s:lower() .. "\t"
						end,
						child_prefix = false,
					},
					code_actions = {
						previewer = "codeaction_native",
						preview_pager = "delta --side-by-side --width=$FZF_PREVIEW_COLUMNS --hunk-header-style='omit' --file-style='omit'",
					},
				},
			}
		end,
		keys = {
			{ "<leader>:", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
			-- find
			{ "<leader>b", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
			{ "<leader>o", "<cmd>FzfLua files<cr>", desc = "Find Files (Root Dir)" },
			{ "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Find Files (git-files)" },
			{ "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
			-- git
			{ "<leader>gcb", "<cmd>FzfLua git_bcommits<CR>", desc = "Commits buffer" },
			{ "<leader>gcc", "<cmd>FzfLua git_commits<CR>", desc = "Commits" },
			{ "<leader>gs", "<cmd>FzfLua git_status<CR>", desc = "Status" },
			{ "<leader>gb", "<cmd>FzfLua git_blame<CR>", desc = "Blame buffer" },
			{ "<leader>gt", "<cmd>FzfLua git_tags<CR>", desc = "Tags" },
			-- search
			{ '<leader>s"', "<cmd>FzfLua registers<cr>", desc = "Registers" },
			{ "<leader>sa", "<cmd>FzfLua autocmds<cr>", desc = "Auto Commands" },
			{ "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>", desc = "Buffer" },
			{ "<leader>sc", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
			{ "<leader>sC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
			{ "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document Diagnostics" },
			{ "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace Diagnostics" },
			{ "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Grep (Root Dir)" },
			{ "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
			{ "<leader>sH", "<cmd>FzfLua highlights<cr>", desc = "Search Highlight Groups" },
			{ "<leader>sj", "<cmd>FzfLua jumps<cr>", desc = "Jumplist" },
			{ "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Key Maps" },
			{ "<leader>sl", "<cmd>FzfLua loclist<cr>", desc = "Location List" },
			{ "<leader>sM", "<cmd>FzfLua man_pages<cr>", desc = "Man Pages" },
			{ "<leader>sm", "<cmd>FzfLua marks<cr>", desc = "Jump to Mark" },
			{ "<leader><tab>", "<cmd>FzfLua resume<cr>", desc = "Resume" },
			{ "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
			{ "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "Word (Root Dir)" },
			{ "<leader>*", "<cmd>FzfLua grep_cword<cr>", desc = "Word (Root Dir)" },
			{ "<leader>sW", "<cmd>FzfLua grep_visual<cr>", mode = "v", desc = "Selection (Root Dir)" },
			{
				"<leader>l",
				function()
					require("fzf-lua").lsp_document_symbols({
						regex_filter = symbols_filter,
					})
				end,
				desc = "Goto Symbol",
			},
			{
				"<leader>sL",
				function()
					require("fzf-lua").lsp_live_workspace_symbols({
						regex_filter = symbols_filter,
					})
				end,
				desc = "Goto Symbol (Workspace)",
			},
			-- dap
			{ "<leader>DD", "<cmd>FzfLua dap_commands<cr>", desc = "dap commands" },
			{ "<leader>DDb", "<cmd>FzfLua dap_breakpoints<cr>", desc = "dap commands" },
			{ "<leader>DDv", "<cmd>dap_variables<cr>", desc = "dap commands" },

			-- spelling
			{ "<leader>=", "<cmd>FzfLua spell_suggest<cr>", desc = "Spelling suggestions" },

			{
				"<leader>/",
				desc = "Grep",
				function()
					require("fzf-lua").live_grep_native({
						multiprocess = true,
						rg_opts = [=[--column --line-number --hidden --no-heading --color=always --smart-case --max-columns=4096 -g '!.git' -e]=],
					})
				end,
			},
			{
				"<leader>gd",
				"<cmd>FzfLua lsp_definitions jump1 ignore_current_line=true<cr>",
				desc = "lsp definitins",
			},
			{
				"<leader>gr",
				"<cmd>FzfLua lsp_references jump1 ignore_current_line=true<cr>",
				desc = "lsp references",
			},
			{
				"<leader>gI",
				"<cmd>FzfLua lsp_implementations jump1 ignore_current_line=true<cr>",
				desc = "lsp definitins",
			},
			{
				"<leader>gt",
				"<cmd>FzfLua lsp_typedefs jump1 ignore_current_line=true<cr>",
				desc = "lsp typedefs",
			},
			{

				"<space>ca",
				function()
					require("fzf-lua").lsp_code_actions({
						winopts = {
							relative = "cursor",
							width = 0.6,
							height = 0.6,
							row = 1,
							preview = { vertical = "up:70%" },
						},
					})
				end,
				desc = "code action",
			},
		},
	},
}

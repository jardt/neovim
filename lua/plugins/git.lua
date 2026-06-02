local M = {}

local nix = require("config.nix")

function M.setup()
	if not nix.enableForCategory("git", true) then
		return
	end

	local pack = require("config.pack")
	for _, plugin in ipairs({ "gitsigns.nvim", "diffview.nvim", "delta-lua", "delta.lua", "deltaview", "deltaview.nvim" }) do
		pack.load(plugin)
	end

	local delta_ok, delta = pcall(require, "delta")
	if delta_ok and delta.parse then
		local get_diff_data_git = delta.parse.get_diff_data_git
		local get_language_from_filename = delta.parse.get_language_from_filename
		local function language_from_filename(path)
			if path and path:match("%.nix$") then
				return "nix"
			end
			return get_language_from_filename(path)
		end

		delta.parse.get_language_from_filename = language_from_filename
		delta.parse.get_diff_data_git = function(diff)
			local diff_data_set = get_diff_data_git(diff)
			for _, diff_data in ipairs(diff_data_set or {}) do
				diff_data.language = diff_data.language or language_from_filename(diff_data.new_path or diff_data.old_path)
			end
			return diff_data_set
		end
	end

	local deltaview_ok, deltaview = pcall(require, "deltaview")
	if deltaview_ok then
		deltaview.setup({
			-- deltaview does not support Snacks directly yet; use vim.ui.select,
			-- which Snacks picker owns via `picker.ui_select = true`.
			fzf_picker = "ui_select",
		})
	end

	local ok, gitsigns = pcall(require, "gitsigns")
	if ok then
		gitsigns.setup({
			signs = { add = { text = "│" }, change = { text = "│" }, delete = { text = "_" }, topdelete = { text = "‾" }, changedelete = { text = "~" }, untracked = { text = "┆" } },
			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = false,
			watch_gitdir = { follow_files = true },
			attach_to_untracked = true,
			current_line_blame = true,
			current_line_blame_opts = { virt_text = true, virt_text_pos = "eol", delay = 1000, ignore_whitespace = false, virt_text_priority = 100 },
			current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
			sign_priority = 6,
			update_debounce = 100,
			status_formatter = nil,
			max_file_length = 40000,
			preview_config = { border = "single", style = "minimal", relative = "cursor", row = 0, col = 1 },
		})
	end

	vim.api.nvim_create_user_command("Review", function()
		vim.cmd("DiffviewOpen origin/main...HEAD --imply-local")
	end, { desc = "Open Diffview against origin/main" })
	vim.api.nvim_create_user_command("FileHistory", function()
		vim.cmd("DiffviewFileHistory %")
	end, { desc = "Open Diffview file history for current file" })
	vim.keymap.set("n", "<Leader>gd", "<cmd>DiffviewFileHistory %<CR>", { desc = "diff file" })
	vim.keymap.set("n", "<Leader>gs", "<cmd>DiffviewOpen<CR>", { desc = "diff status" })
	vim.keymap.set("n", "<Leader>qd", "<cmd>DiffviewClose<CR>", { desc = "close diff view" })
	vim.keymap.set("n", "<leader>gS", "<cmd>DiffviewOpen origin/main...HEAD --imply-local<CR>", { desc = "diff against origin main" })
	vim.cmd([[cabbrev dm DeltaMenu]])
	vim.cmd([[cabbrev dv DeltaView]])
end

return M

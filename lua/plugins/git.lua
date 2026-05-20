local M = {}

local nix = require("config.nix")

function M.setup()
	if not nix.enableForCategory("git", true) then
		return
	end

	local pack = require("config.pack")
	for _, plugin in ipairs({ "gitsigns.nvim", "diffview.nvim" }) do
		pack.load(plugin)
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
end

return M

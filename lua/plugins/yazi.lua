local M = {}

function M.setup()
	local pack = require("config.pack")
	pack.load("yazi.nvim")

	local ok, yazi = pcall(require, "yazi")
	if not ok then
		return
	end

	yazi.setup({
		open_for_directories = false,
		keymaps = {
			show_help = "<f1>",
			copy_relative_path_to_selected_files = false,
		},
	})

	vim.keymap.set("n", "<leader>y", "<cmd>Yazi<cr>", { desc = "Open yazi at the current file" })
	vim.keymap.set("n", "<leader>Y", "<cmd>Yazi cwd<cr>", { desc = "Open the file manager in nvim's working directory" })
	vim.keymap.set("n", "<c-up>", "<cmd>Yazi toggle<cr>", { desc = "Resume the last yazi session" })
end

return M

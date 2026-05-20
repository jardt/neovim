local M = {}

local loaded = false

local function load_yazi()
	if loaded then
		return true
	end

	pcall(vim.api.nvim_del_user_command, "Yazi")
	require("config.pack").load("yazi.nvim")

	local ok, yazi = pcall(require, "yazi")
	if not ok then
		vim.notify("Failed to load yazi.nvim: " .. tostring(yazi), vim.log.levels.WARN)
		return false
	end

	yazi.setup({
		open_for_directories = false,
		keymaps = {
			show_help = "<f1>",
			copy_relative_path_to_selected_files = false,
		},
	})

	loaded = true
	return true
end

local function yazi_command(args)
	if not load_yazi() then
		return
	end
	vim.cmd("Yazi " .. args)
end

function M.setup()
	vim.api.nvim_create_user_command("Yazi", function(opts)
		yazi_command(opts.args)
	end, { nargs = "*", complete = "file" })

	vim.keymap.set("n", "<leader>y", function()
		yazi_command("")
	end, { desc = "Open yazi at the current file" })
	vim.keymap.set("n", "<leader>Y", function()
		yazi_command("cwd")
	end, { desc = "Open the file manager in nvim's working directory" })
	vim.keymap.set("n", "<c-up>", function()
		yazi_command("toggle")
	end, { desc = "Resume the last yazi session" })
end

return M

local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>uu", function()
		vim.cmd.packadd("nvim.undotree")
		require("undotree").open()
	end, { desc = "Undo tree" })
end

return M

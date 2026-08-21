local M = {}

function M.setup()
	vim.o.autoread = true
	vim.keymap.set({ "n", "x" }, "<leader>e", function()
		require("pi.prompt").open()
	end, { desc = "Ask Pi" })
	vim.keymap.set({ "n", "x" }, "go", function()
		require("pi.prompt").open("{this}")
	end, { desc = "Ask Pi about this" })
	vim.keymap.set("n", "goo", function()
		require("pi.prompt").open("{file}")
	end, { desc = "Ask Pi about file" })
	vim.keymap.set({ "n", "x" }, "<C-f>", function()
		require("pi.herdr").select()
	end, { desc = "Select Pi agent" })
	vim.keymap.set("n", "<S-C-u>", function()
		require("pi.herdr").focus()
	end, { desc = "Focus Pi agent" })
end

return M

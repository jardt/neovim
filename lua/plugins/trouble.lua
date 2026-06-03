local specs = {
	{
		"folke/trouble.nvim",
		cmd = { "Trouble" },
		opts = {
			modes = {
				lsp = {
					win = { position = "right" },
				},
			},
		},
	},
}

local loaded = false

local function load_trouble()
	if loaded then
		return true
	end

	pcall(vim.api.nvim_del_user_command, "Trouble")
	require("config.pack").load("trouble.nvim")

	local ok, trouble = pcall(require, "trouble")
	if not ok then
		vim.notify("Failed to load trouble.nvim: " .. tostring(trouble), vim.log.levels.WARN)
		return false
	end

	trouble.setup(specs[1].opts)
	loaded = true
	return true
end

local function trouble_command(args)
	if not load_trouble() then
		return
	end
	vim.cmd("Trouble " .. args)
end

local function trouble_prev()
	if load_trouble() and require("trouble").is_open() then
		require("trouble").prev({ skip_groups = true, jump = true })
	else
		local ok, err = pcall(vim.cmd.cprev)
		if not ok then
			vim.notify(err, vim.log.levels.ERROR)
		end
	end
end

local function trouble_next()
	if load_trouble() and require("trouble").is_open() then
		require("trouble").next({ skip_groups = true, jump = true })
	else
		local ok, err = pcall(vim.cmd.cnext)
		if not ok then
			vim.notify(err, vim.log.levels.ERROR)
		end
	end
end

function specs.setup()
	vim.api.nvim_create_user_command("Trouble", function(opts)
		trouble_command(opts.args)
	end, { nargs = "*", bang = true })

	vim.keymap.set("n", "<leader>dt", function()
		trouble_command("diagnostics toggle")
	end, { desc = "Diagnostics (Trouble)" })
	vim.keymap.set("n", "<leader>db", function()
		trouble_command("diagnostics toggle filter.buf=0")
	end, { desc = "Buffer Diagnostics (Trouble)" })
	vim.keymap.set("n", "<leader>cs", function()
		trouble_command("symbols toggle")
	end, { desc = "Symbols (Trouble)" })
	vim.keymap.set("n", "<leader>cS", function()
		trouble_command("lsp toggle")
	end, { desc = "LSP references/definitions/... (Trouble)" })
	vim.keymap.set("n", "<leader>dL", function()
		trouble_command("loclist toggle")
	end, { desc = "Location List (Trouble)" })
	vim.keymap.set("n", "<leader>dQ", function()
		trouble_command("qflist toggle")
	end, { desc = "Quickfix List (Trouble)" })
	vim.keymap.set("n", "[q", trouble_prev, { desc = "Previous Trouble/Quickfix Item" })
	vim.keymap.set("n", "]q", trouble_next, { desc = "Next Trouble/Quickfix Item" })
end

return specs

local specs = {
	{
		"MagicDuck/grug-far.nvim",
		opts = { headerMaxWidth = 80 },
		cmd = "GrugFar",
		keys = {
			{
				"<leader>sr",
				function()
					local grug = require("grug-far")
					local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
					grug.open({
						transient = true,
						prefills = {
							filesFilter = ext and ext ~= "" and "*." .. ext or nil,
						},
					})
				end,
				mode = { "n", "v" },
				desc = "Search and Replace",
			},
		},
	},
}

local loaded = false

local function load_grugfar()
	if loaded then
		return true
	end

	pcall(vim.api.nvim_del_user_command, "GrugFar")
	require("config.pack").load("grug-far.nvim")

	local ok, grug = pcall(require, "grug-far")
	if not ok then
		vim.notify("Failed to load grug-far.nvim: " .. tostring(grug), vim.log.levels.WARN)
		return false
	end

	grug.setup(specs[1].opts)
	loaded = true
	return true
end

local function open_transient()
	if not load_grugfar() then
		return
	end
	local grug = require("grug-far")
	local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
	grug.open({
		transient = true,
		prefills = {
			filesFilter = ext and ext ~= "" and "*." .. ext or nil,
		},
	})
end

function specs.setup()
	vim.api.nvim_create_user_command("GrugFar", function(opts)
		if not load_grugfar() then
			return
		end
		vim.cmd("GrugFar " .. opts.args)
	end, { nargs = "*", bang = true })

	vim.keymap.set({ "n", "v" }, "<leader>sr", open_transient, { desc = "Search and Replace", silent = true })
end

return specs

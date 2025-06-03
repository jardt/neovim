return {
	{
		"mfussenegger/nvim-ansible",
		ft = {},
		keys = {
			{
				"<leader>AR",
				function()
					require("ansible").run()
				end,
				desc = "Ansible Run Playbook/Role",
				silent = true,
			},
		},
	},
}

return {
	{
		"mfussenegger/nvim-ansible",
		enabled = require("nixCatsUtils").enableForCategory("devops", true),
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

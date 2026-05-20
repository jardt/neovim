return {
	{
		"mfussenegger/nvim-ansible",
		enabled = require("config.nix").enableForCategory("devops", true),
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

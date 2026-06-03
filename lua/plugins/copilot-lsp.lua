return {
	{
		"copilotlsp-nvim/copilot-lsp",
		name = "copilot-lsp",
		enabled = require("config.nix").enableForCategory("ai", false),
		config = function()
			vim.api.nvim_create_user_command("LspCopilotSignIn", function()
				local clients = vim.tbl_filter(function(client)
					return client.name:lower():find("copilot") ~= nil
				end, vim.lsp.get_clients({ bufnr = 0 }))

				if #clients == 0 then
					clients = vim.tbl_filter(function(client)
						return client.name:lower():find("copilot") ~= nil
					end, vim.lsp.get_clients())
				end

				local client = clients[1]
				if not client then
					vim.notify("Copilot LSP is not running", vim.log.levels.WARN)
					return
				end

				client:request("signIn", vim.empty_dict(), require("copilot-lsp.handlers").signIn, 0)
			end, { desc = "Sign in to GitHub Copilot LSP" })
		end,
	},
}

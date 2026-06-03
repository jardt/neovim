local servers = {
	lua = "lua-language-server",
	yaml = "yaml-language-server",
	nix = "nixd",
	ts = "vtsls",
	svelte = "svelteserver",
	bash = "bash-language-server",
	go = "gopls",
	docker = "docker-langserver",
	markdown = "marksman",
	json = "vscode-json-language-server",
	toml = "taplo",
	tailwind = "tailwindcss-language-server",
	html = "vscode-html-language-server",
	css = "vscode-css-language-server",
	terraform = "terraform-ls",
	qml = "qmlls",
	angular = "ngserver",
	roslyn = "Microsoft.CodeAnalysis.LanguageServer",
	typst = "tinymist",
	copilot_ls = "copilot-language-server",
}

local enabled = {}
for server, executable in pairs(servers) do
	if vim.fn.executable(executable) == 1 then
		table.insert(enabled, server)
	end
end

vim.lsp.enable(enabled)

vim.lsp.config("*", {
	on_attach = function(client, bufnr)
		-- these will be buffer-local keybindings
		-- because they only work if you have an active language server
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gh", vim.lsp.buf.signature_help, opts)
		vim.keymap.set(
			"n",
			"<space>Wa",
			vim.lsp.buf.add_workspace_folder,
			{ desc = "add workspace folder", buffer = bufnr }
		)
		vim.keymap.set(
			"n",
			"<space>Wr",
			vim.lsp.buf.remove_workspace_folder,
			{ desc = "remove workspace folder", buffer = bufnr }
		)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
		vim.keymap.set("n", "<space>Wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, { desc = "List workspace folder", buffer = bufnr })
		vim.keymap.set("n", "<leader>i", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ 0 }), { 0 })
		end, { desc = "toggle inlay hints" })
	end,
})

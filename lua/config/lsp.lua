vim.lsp.enable({
	"lua",
	"yaml",
	"nix",
	"ts",
	"svelte",
	"bash",
	"go",
	"docker",
	"markdown",
	"json",
	-- "ansible", unmaintained in nixpkgs
	"toml",
	"tailwind",
	"html",
	"css-variables",
	"css",
	"terraform",
	"qml",
	"angular",
	"roslyn",
})

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
		vim.keymap.set("n", "<space>Wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, { desc = "List workspace folder", buffer = bufnr })
		vim.keymap.set("n", "<leader>i", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ 0 }), { 0 })
		end, { desc = "toggle inlay hints" })
	end,
})

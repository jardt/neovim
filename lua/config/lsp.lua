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
	"ansible",
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
		vim.keymap.set("n", "gd", "<cmd>FzfLua lsp_definitions jump1 ignore_current_line=true<cr>", opts)
		vim.keymap.set("n", "gr", "<cmd>FzfLua lsp_references jump1 ignore_current_line=true<cr>", opts)
		vim.keymap.set("n", "gI", "<cmd>FzfLua lsp_implementations jump1 ignore_current_line=true<cr>", opts)
		vim.keymap.set("n", "gt", "<cmd>FzfLua lsp_typedefs jump1 ignore_current_line=true<cr>", opts)
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
		vim.keymap.set("n", "<space>ca", function()
			require("fzf-lua").lsp_code_actions({
				winopts = {
					relative = "cursor",
					width = 0.6,
					height = 0.6,
					row = 1,
					preview = { vertical = "up:70%" },
				},
			})
		end, opts)
		vim.keymap.set("n", "<space>Wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, { desc = "List workspace folder", buffer = bufnr })
		vim.keymap.set("n", "<leader>i", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ 0 }), { 0 })
		end, { desc = "toggle inlay hints" })
	end,
})

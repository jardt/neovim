local function augroup(name)
	return vim.api.nvim_create_augroup("vimmer_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	desc = "LSP actions",
	callback = function(event)
		local opts = { buffer = event.buf }
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
			{ desc = "add workspace folder", buffer = event.buf }
		)
		vim.keymap.set(
			"n",
			"<space>Wr",
			vim.lsp.buf.remove_workspace_folder,
			{ desc = "remove workspace folder", buffer = event.buf }
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
		end, { desc = "List workspace folder", buffer = event.buf })
		vim.keymap.set("n", "<leader>i", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ 0 }), { 0 })
		end, { desc = "toggle inlay hints" })
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
	group = augroup("remove cursorline in insert"),
	callback = function()
		vim.cmd("set nocursorline")
	end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
	group = augroup("add cursorline in normalmode"),
	callback = function()
		vim.cmd("set cursorline")
	end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_loc"),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
			return
		end
		vim.b[buf].lazyvim_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"checkhealth",
		"dbout",
		"gitsigns-blame",
		"grug-far",
		"help",
		"lspinfo",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd("close")
				pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
	group = augroup("json_conceal"),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

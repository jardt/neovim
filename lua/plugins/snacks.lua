local function lsp_type_hierarchy(direction)
	if not Snacks or not Snacks.picker then
		vim.notify("Snacks picker is not available", vim.log.levels.WARN)
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local params = vim.lsp.util.make_position_params()

	vim.lsp.buf_request_all(bufnr, "textDocument/prepareTypeHierarchy", params, function(results)
		local client_id
		local prepared

		for id, res in pairs(results) do
			if res.result and not vim.tbl_isempty(res.result) then
				client_id = id
				prepared = res.result
				break
			end
		end

		if not prepared then
			vim.notify("No type hierarchy available", vim.log.levels.INFO)
			return
		end

		local client = vim.lsp.get_client_by_id(client_id)
		if not client then
			vim.notify("No LSP client for type hierarchy", vim.log.levels.WARN)
			return
		end

		local method = direction == "supertypes" and "typeHierarchy/supertypes" or "typeHierarchy/subtypes"
		client.request(method, { item = prepared[1] }, function(err, items)
			if err or not items or vim.tbl_isempty(items) then
				vim.notify("No type hierarchy results", vim.log.levels.INFO)
				return
			end

			local picker_items = {}
			for _, item in ipairs(items) do
				local range = item.selectionRange or item.range
				local pos = range and range.start and { range.start.line + 1, range.start.character + 1 } or { 1, 1 }
				local kind = vim.lsp.protocol.SymbolKind[item.kind] or "Symbol"
				local detail = item.detail and item.detail ~= "" and (" " .. item.detail) or ""
				local file = item.uri and vim.uri_to_fname(item.uri) or ""

				table.insert(picker_items, {
					text = string.format("%s %s%s", kind, item.name or "?", detail),
					kind = kind,
					file = file,
					pos = pos,
					lsp_item = item,
				})
			end

			Snacks.picker.pick({
				title = direction == "supertypes" and "Type Hierarchy (Supertypes)" or "Type Hierarchy (Subtypes)",
				items = picker_items,
				format = "lsp_symbol",
				preview = "preview",
				jump = { tagstack = true, reuse_win = true },
				auto_confirm = true,
				confirm = function(picker, selected)
					if not selected or not selected.lsp_item then
						return
					end
					picker:close()
					vim.lsp.util.jump_to_location({
						uri = selected.lsp_item.uri,
						range = selected.lsp_item.selectionRange or selected.lsp_item.range,
					}, client.offset_encoding)
				end,
			})
		end, bufnr)
	end)
end

return {
	{
		"folke/snacks.nvim",
		enabled = require("nixCatsUtils").enableForCategory("general", true),
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			indent = { enabled = false },
			input = {
				enabled = true,
				icon = " ",
				icon_hl = "SnacksInputIcon",
				icon_pos = "left",
				prompt_pos = "title",
				win = { style = "input" },
				expand = true,
			},
			notifier = { enabled = true },
			scroll = { enabled = false },
			statuscolumn = { enabled = false }, -- we set this in options.lua
			words = { enabled = true },
			lazygit = { enabled = require("nixCatsUtils").enableForCategory("git", true) },
			gh = { enabled = require("nixCatsUtils").enableForCategory("git", true) },
			---@class snacks.picker.Config
			picker = {
				enabled = require("nixCatsUtils").getCatOrDefault("opts.picker.snacks", false),
				cwd = true,
				ui_select = true,
			},
		},
		keys = {
			--git
			{
				"<leader>lg",
				desc = "lazygit",
				function()
					---@param opts? snacks.lazygit.Config
					Snacks.lazygit.open(opts)
				end,
			},
			-- picker
			{
				"<leader>fo'",
				function()
					Snacks.picker.smart()
				end,
				desc = "Smart Find Files",
			},
			{
				"<leader>b",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>/",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>n",
				function()
					Snacks.picker.notifications()
				end,
				desc = "Notification History",
			},
			{
				"<leader>e",
				function()
					Snacks.explorer()
				end,
				desc = "File Explorer",
			},
			-- find
			{
				"<leader>fc",
				function()
					Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "Find Config File",
			},
			{
				"<leader>o",
				function()
					Snacks.picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>gf",
				function()
					Snacks.picker.git_files()
				end,
				desc = "Find Git Files",
			},
			{
				"<leader>fp",
				function()
					Snacks.picker.projects()
				end,
				desc = "Projects",
			},
			{
				"<leader>r",
				function()
					Snacks.picker.recent()
				end,
				desc = "Recent",
			},
			-- git
			{
				"<leader>gb",
				function()
					Snacks.picker.git_branches()
				end,
				desc = "Git Branches",
			},
			{
				"<leader>gl",
				function()
					Snacks.picker.git_log()
				end,
				desc = "Git Log",
			},
			{
				"<leader>gL",
				function()
					Snacks.picker.git_log_line()
				end,
				desc = "Git Log Line",
			},
			{
				"<leader>gs",
				function()
					Snacks.picker.git_status()
				end,
				desc = "Git Status",
			},
			{
				"<leader>gS",
				function()
					Snacks.picker.git_stash()
				end,
				desc = "Git Stash",
			},
			{
				"<leader>gd",
				function()
					Snacks.picker.git_diff()
				end,
				desc = "Git Diff (Hunks)",
			},
			{
				"<leader>gf",
				function()
					Snacks.picker.git_log_file()
				end,
				desc = "Git Log File",
			},
			-- gh
			{
				"<leader>gi",
				function()
					Snacks.picker.gh_issue()
				end,
				desc = "GitHub Issues (open)",
			},
			{
				"<leader>gI",
				function()
					Snacks.picker.gh_issue({ state = "all" })
				end,
				desc = "GitHub Issues (all)",
			},
			{
				"<leader>gp",
				function()
					Snacks.picker.gh_pr()
				end,
				desc = "GitHub Pull Requests (open)",
			},
			{
				"<leader>gP",
				function()
					Snacks.picker.gh_pr({ state = "all" })
				end,
				desc = "GitHub Pull Requests (all)",
			},
			-- Grep
			{
				"<leader>sb",
				function()
					Snacks.picker.lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>sB",
				function()
					Snacks.picker.grep_buffers()
				end,
				desc = "Grep Open Buffers",
			},
			{
				"<leader>sg",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>sw",
				function()
					Snacks.picker.grep_word()
				end,
				desc = "Visual selection or word",
				mode = { "n", "x" },
			},
			-- search
			{
				'<leader>s"',
				function()
					Snacks.picker.registers()
				end,
				desc = "Registers",
			},
			{
				"<leader>s/",
				function()
					Snacks.picker.search_history()
				end,
				desc = "Search History",
			},
			{
				"<leader>sa",
				function()
					Snacks.picker.autocmds()
				end,
				desc = "Autocmds",
			},
			{
				"<leader>sb",
				function()
					Snacks.picker.lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>sc",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>sC",
				function()
					Snacks.picker.commands()
				end,
				desc = "Commands",
			},
			{
				"<leader>sd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>sD",
				function()
					Snacks.picker.diagnostics_buffer()
				end,
				desc = "Buffer Diagnostics",
			},
			{
				"<leader>sh",
				function()
					Snacks.picker.help()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>sH",
				function()
					Snacks.picker.highlights()
				end,
				desc = "Highlights",
			},
			{
				"<leader>si",
				function()
					Snacks.picker.icons()
				end,
				desc = "Icons",
			},
			{
				"<leader>sj",
				function()
					Snacks.picker.jumps()
				end,
				desc = "Jumps",
			},
			{
				"<leader>sk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>sl",
				function()
					Snacks.picker.loclist()
				end,
				desc = "Location List",
			},
			{
				"<leader>sm",
				function()
					Snacks.picker.marks()
				end,
				desc = "Marks",
			},
			{
				"<leader>sM",
				function()
					Snacks.picker.man()
				end,
				desc = "Man Pages",
			},
			{
				"<leader>sp",
				function()
					Snacks.picker.lazy()
				end,
				desc = "Search for Plugin Spec",
			},
			{
				"<leader>sq",
				function()
					Snacks.picker.qflist()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader><tab>",
				function()
					Snacks.picker.resume()
				end,
				desc = "Resume",
			},
			{
				"<leader>su",
				function()
					Snacks.picker.undo()
				end,
				desc = "Undo History",
			},
			{
				"<leader>uC",
				function()
					Snacks.picker.colorschemes()
				end,
				desc = "Colorschemes",
			},
			-- LSP
			{
				"gd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				desc = "Goto Definition",
			},
			{
				"gD",
				function()
					Snacks.picker.lsp_declarations()
				end,
				desc = "Goto Declaration",
			},
			{
				"gr",
				function()
					Snacks.picker.lsp_references()
				end,
				nowait = true,
				desc = "References",
			},
			{
				"gI",
				function()
					Snacks.picker.lsp_implementations()
				end,
				desc = "Goto Implementation",
			},
			{
				"gy",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				desc = "Goto T[y]pe Definition",
			},
			{
				"gai",
				function()
					Snacks.picker.lsp_incoming_calls()
				end,
				desc = "C[a]lls Incoming",
			},
			{
				"gao",
				function()
					Snacks.picker.lsp_outgoing_calls()
				end,
				desc = "C[a]lls Outgoing",
			},
			{
				"<leader>lt",
				function()
					lsp_type_hierarchy("subtypes")
				end,
				desc = "Type Hierarchy (Subtypes)",
			},
			{
				"<leader>lT",
				function()
					lsp_type_hierarchy("supertypes")
				end,
				desc = "Type Hierarchy (Supertypes)",
			},
			{
				"<leader>ss",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "LSP Symbols",
			},
			{
				"<leader>sS",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				desc = "LSP Workspace Symbols",
			},
			{
				"<leader>st",
				function()
					Snacks.picker.todo_comments()
				end,
				desc = "Todo",
			},
			{
				"<leader>sT",
				function()
					Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
				end,
				desc = "Todo/Fix/Fixme",
			},
		},
	},
}

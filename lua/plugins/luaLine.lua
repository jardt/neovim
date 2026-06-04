local M = {}

local nix = require("config.nix")

local loaded = false

local function load_lualine()
	if loaded or not nix.enableForCategory("statusline", true) then
		return
	end
	loaded = true

	require("config.pack").load("lualine.nvim")
	local ok, lualine = pcall(require, "lualine")
	if not ok then
		return
	end

	vim.g.lualine_laststatus = vim.o.laststatus
	if vim.fn.argc(-1) > 0 then
		vim.o.statusline = " "
	else
		vim.o.laststatus = 0
	end

	local theme = nix.getCatOrDefault("settings.theme.name", "base16")
	local ok_theme, auto = pcall(require, "lualine.themes.auto")
	if ok_theme then
		for _, field in ipairs({ "insert", "normal", "visual", "command", "replace", "inactive", "terminal" }) do
			if auto[field] and auto[field].c then
				auto[field].c.bg = "NONE"
			end
		end
	end

	local opts = {
		options = { icons_enabled = true, theme = theme, component_separators = "", section_separators = "" },
		sections = {
			lualine_c = { { "filename", file_status = true, newfile_status = false, path = 4, shorting_target = 40, symbols = { modified = "[+]", readonly = "[RO]", unnamed = "[No Name]", newfile = "[New]" } } },
			lualine_x = { { "lsp_status" } },
			lualine_z = {},
		},
		inactive_sections = {},
		extensions = { "neo-tree", "quickfix", "nvim-dap-ui", "trouble", "fzf" },
	}

	if nix.enableForCategory("ai", false) then
		table.insert(opts.sections.lualine_c, {
			function()
				return " "
			end,
			color = function()
				local ok_status, status_mod = pcall(require, "sidekick.status")
				local status = ok_status and status_mod.get() or nil
				return status and (status.kind == "Error" and "DiagnosticError" or status.busy and "DiagnosticWarn" or "Special") or nil
			end,
			cond = function()
				local ok_status, status = pcall(require, "sidekick.status")
				return ok_status and status.get() ~= nil
			end,
		})
	end

	lualine.setup(opts)
end

function M.setup()
	if not nix.enableForCategory("statusline", true) then
		return
	end

	vim.api.nvim_create_autocmd("VimEnter", {
		group = vim.api.nvim_create_augroup("LoadLualine", { clear = true }),
		once = true,
		callback = function()
			vim.schedule(load_lualine)
		end,
	})
end

return M

return {
	{
		"nvim-lualine/lualine.nvim",
		event = "BufReadPre",
		enabled = require("nixCatsUtils").enableForCategory("statusline", false),
		init = function()
			vim.g.lualine_laststatus = vim.o.laststatus
			if vim.fn.argc(-1) > 0 then
				-- set an empty statusline till lualine loads
				vim.o.statusline = " "
			else
				-- hide the statusline on the starter page
				vim.o.laststatus = 0
			end
		end,
		opts = function()
			-- transparent bg
			local auto = require("lualine.themes.auto")
			local lualine_modes = { "insert", "normal", "visual", "command", "replace", "inactive", "terminal" }
			for _, field in ipairs(lualine_modes) do
				if auto[field] and auto[field].c then
					auto[field].c.bg = "NONE"
				end
			end
			return {
				options = {
					icons_enabled = true,
					theme = require("nixCatsUtils").getCatOrDefault("opts.theme.name", "base16"),
					component_separators = "",
					section_separators = "",
				},
				sections = {
					lualine_c = {
						{
							"filename",
							file_status = true, -- Displays file status (readonly status, modified status)
							newfile_status = false, -- Display new file status (new file means no write after created)
							path = 4, -- 0: Just the filename
							-- 1: Relative path
							-- 2: Absolute path
							-- 3: Absolute path, with tilde as the home directory
							-- 4: Filename and parent dir, with tilde as the home directory

							shorting_target = 40, -- Shortens path to leave 40 spaces in the window
							-- for other components. (terrible name, any suggestions?)
							symbols = {
								modified = "[+]", -- Text to show when the file is modified.
								readonly = "[RO]", -- Text to show when the file is non-modifiable or readonly.
								unnamed = "[No Name]", -- Text to show for unnamed buffers.
								newfile = "[New]", -- Text to show for newly created file before first write
							},
						},
					},
					lualine_x = {
						{ "lsp_status" },
					},
					lualine_z = {
						{
							require("opencode").statusline,
						},
					},
				},
				inactive_sections = {},
				extensions = { "neo-tree", "lazy", "quickfix", "nvim-dap-ui", "trouble", "fzf" },
			}
		end,
	},
}

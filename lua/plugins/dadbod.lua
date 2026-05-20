local M = {}

local nix = require("config.nix")

function M.setup()
	local data_path = vim.fn.stdpath("data")

	vim.g.db_ui_auto_execute_table_helpers = 1
	vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
	vim.g.db_ui_show_database_icon = true
	vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
	vim.g.db_ui_use_nerd_fonts = true
	vim.g.db_ui_use_nvim_notify = true
	vim.g.db_ui_execute_on_save = true
end

if not nix.enableForCategory("database", true) then
	return {}
end

return {
	{
		"vim-dadbod",
		cmd = "DB",
	},
	{
		"vim-dadbod-completion",
		ft = { "sql", "mysql", "plsql" },
	},
	{
		"vim-dadbod-ui",
		cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
		keys = {
			{ "<leader>D", "<cmd>DBUIToggle<CR>", desc = "Toggle DBUI" },
		},
		before = function()
			M.setup()
		end,
	},
}

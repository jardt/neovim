local M = {}

local nix = require("config.nix")

local function colorscheme(name)
	pcall(vim.cmd.colorscheme, name)
end

function M.setup()
	local theme = nix.getCatOrDefault("opts.theme.name", "kanagawa")

	if theme == "nord" then
		colorscheme("nord")
	elseif theme == "gruvbox" then
		colorscheme("gruvbox")
	elseif theme == "cyberdream" then
		local ok, cyberdream = pcall(require, "cyberdream")
		if ok then
			cyberdream.setup({
				variant = "auto",
				transparent = true,
				italic_comments = true,
				hide_fillchars = true,
				terminal_colors = false,
				cache = true,
				borderless_pickers = true,
			})
		end
		colorscheme("cyberdream")
	elseif theme == "catppuccin-gruvbox" then
		local ok, catppuccin = pcall(require, "catppuccin")
		if ok then
			catppuccin.setup({
				background = { light = "latte", dark = "mocha" },
				show_end_of_buffer = false,
				integration_default = false,
			})
		end
		colorscheme("catppuccin")
	else
		local ok, kanagawa = pcall(require, "kanagawa")
		if ok then
			kanagawa.setup({
				background = { dark = "dragon", light = "lotus" },
				compile = false,
				functionStyle = { bold = true },
				dimInactive = true,
				transparent = true,
				overrides = function(colors)
					local theme_colors = colors.theme
					return {
						Pmenu = { fg = theme_colors.ui.shade0, bg = theme_colors.ui.bg_p1 },
						PmenuSel = { fg = "NONE", bg = theme_colors.ui.bg_p2 },
						PmenuSbar = { bg = theme_colors.ui.bg_m1 },
						PmenuThumb = { bg = "#C0A36E" },
						NormalFloat = { bg = "none" },
						FloatBorder = { bg = "none" },
						FloatTitle = { bg = "none" },
						LineNr = { fg = "#C0A36E", bg = "NONE" },
						CursorLineNr = { fg = colors.palette.sakuraPink, bg = "NONE" },
					}
				end,
			})
			kanagawa.load("wave")
		else
			colorscheme(theme)
		end
	end
end

return M

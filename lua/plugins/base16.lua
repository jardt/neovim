return {
	{
		"echasnovski/mini.base16",
		enabled = require("nixCatsUtils").getCatOrDefault("opts.theme.base16.enable", false),
		version = false,
		config = function()
			-- fallback kanagawa theme
			local _theme = {
				base00 = "#1F1F28",
				base01 = "#16161D",
				base02 = "#223249",
				base03 = "#54546D",
				base04 = "#727169",
				base05 = "#DCD7BA",
				base06 = "#C8C093",
				base07 = "#717C7C",
				base08 = "#C34043",
				base09 = "#FFA066",
				base0A = "#C0A36E",
				base0B = "#76946A",
				base0C = "#6A9589",
				base0D = "#7E9CD8",
				base0E = "#957FB8",
				base0F = "#D27E99",
			}

			if require("nixCatsUtils").getCatOrDefault("opts.theme.base16.enable", false) then
				_theme = require("nixCatsUtils").getCatOrDefault("opts.theme.base16.table", _theme)
			end

			require("mini.base16").setup({
				palette = _theme,
			})
		end,
		init = function() end,
	},
}

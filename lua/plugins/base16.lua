-- thanks https://github.com/SamD2021/lazyvim/blob/3943e323cf15c9e811f72d9c0ee0add578664348/lua/plugins/colorscheme.lua#L4
local function load_stylix_palette(filepath)
	local file = io.open(filepath, "r")
	if not file then
		return nil
	end
	local content = file:read("*a")
	file:close()
	local palette, err = vim.json.decode(content)
	if err then
		vim.notify("Error parsing JSON from " .. filepath .. ": " .. err, vim.log.levels.ERROR)
		return nil
	end
	return palette
end

local stylix_colors = load_stylix_palette(vim.fn.expand("~/.config/stylix/palette.json"))
	or load_stylix_palette("/etc/stylix/palette.json")

if not stylix_colors then
	vim.notify("Stylix palette not found in either location", vim.log.levels.WARN)
	return {}
end

return {
	{
		"echasnovski/mini.base16",
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

			if stylix_colors then
				_theme = {
					base00 = "#" .. stylix_colors.base00,
					base01 = "#" .. stylix_colors.base01,
					base02 = "#" .. stylix_colors.base02,
					base03 = "#" .. stylix_colors.base03,
					base04 = "#" .. stylix_colors.base04,
					base05 = "#" .. stylix_colors.base05,
					base06 = "#" .. stylix_colors.base06,
					base07 = "#" .. stylix_colors.base07,
					base08 = "#" .. stylix_colors.base08,
					base09 = "#" .. stylix_colors.base09,
					base0A = "#" .. stylix_colors.base0A,
					base0B = "#" .. stylix_colors.base0B,
					base0C = "#" .. stylix_colors.base0C,
					base0D = "#" .. stylix_colors.base0D,
					base0E = "#" .. stylix_colors.base0E,
					base0F = "#" .. stylix_colors.base0F,
				}
			end

			require("mini.base16").setup({
				palette = _theme,
			})
		end,
		init = function() end,
	},
}

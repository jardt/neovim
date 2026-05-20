local M = {}

local eager_modules = {
	"plugins.themes",
	"plugins.treesitter",
	"plugins.completion",
	"plugins.git",
	"plugins.yazi",
	"plugins.luaLine",
}

local function setup_icons()
	local pack = require("config.pack")
	pack.load("mini.icons")

	local ok, icons = pcall(require, "mini.icons")
	if not ok then
		return
	end

	icons.setup({
		file = {
			[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
			[".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
			["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
			[".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
			[".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
			[".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
			[".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
			["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
			["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
			["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
			["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
			["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
		},
		filetype = {
			dotenv = { glyph = "", hl = "MiniIconsYellow" },
			gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
		},
	})
	icons.mock_nvim_web_devicons()
end

function M.setup()
	setup_icons()

	for _, module in ipairs(eager_modules) do
		local ok, plugin = pcall(require, module)
		if ok and type(plugin) == "table" and type(plugin.setup) == "function" then
			plugin.setup()
		elseif not ok then
			vim.schedule(function()
				vim.notify("Failed to load " .. module .. ": " .. tostring(plugin), vim.log.levels.WARN)
			end)
		end
	end
end

return M

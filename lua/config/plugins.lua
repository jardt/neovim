local M = {}

local function plugin_name(repo)
	return repo:match("/([^/]+)$") or repo
end

local function main_module(name)
	name = name:gsub("%.nvim$", ""):gsub("%-nvim$", ""):gsub("^nvim%-", ""):gsub("%-", ".")
	return name
end

local function normalize_modes(mode)
	if mode == nil then
		return { "n" }
	end
	if type(mode) == "string" then
		return { mode }
	end
	return mode
end

local function setup_specs(specs)
	for _, spec in ipairs(specs or {}) do
		if spec.enabled ~= false then
			if type(spec.init) == "function" then
				spec.init()
			end
			local name = spec.name or plugin_name(spec[1])
			require("config.pack").load(name)
			local opts = type(spec.opts) == "function" and spec.opts() or spec.opts
			if type(spec.config) == "function" then
				spec.config(spec, opts)
			elseif opts ~= nil then
				local ok, mod = pcall(require, spec.main or main_module(name))
				if ok and type(mod.setup) == "function" then
					mod.setup(opts)
				end
			end
			local keys = type(spec.keys) == "function" and spec.keys() or spec.keys
			for _, key in ipairs(keys or {}) do
				local lhs, rhs = key[1], key[2]
				if lhs ~= nil and rhs ~= nil then
					local key_opts = { desc = key.desc, silent = key.silent ~= false, noremap = key.noremap ~= false, expr = key.expr }
					for _, mode in ipairs(normalize_modes(key.mode)) do
						vim.keymap.set(mode, lhs, rhs, key_opts)
					end
				end
			end
		end
	end
end

local eager_modules = {
	"plugins.themes",
	"plugins.treesitter",
	"plugins.completion",
	"plugins.git",
	"plugins.snacks",
	"plugins.luaSnip",
	"plugins.formatting",
	"plugins.markdown",
	"plugins.sidekick",
	"plugins.harpoon",
	"plugins.flash",
	"plugins.notify",
	"plugins.todo-comment",
	"plugins.yazi",
	"plugins.grugfar",
	"plugins.trouble",
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
		elseif ok and type(plugin) == "table" then
			setup_specs(plugin)
		elseif not ok then
			vim.schedule(function()
				vim.notify("Failed to load " .. module .. ": " .. tostring(plugin), vim.log.levels.WARN)
			end)
		end
	end
end

return M

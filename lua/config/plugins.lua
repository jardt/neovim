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

local function has_lazy_trigger(spec)
	return spec.event ~= nil or spec.cmd ~= nil or spec.ft ~= nil or spec.keys ~= nil or spec.colorscheme ~= nil
end

local function load_dependencies(spec)
	local pack = require("config.pack")
	for _, dependency in ipairs(spec.dependencies or {}) do
		local dependency_name = type(dependency) == "table" and (dependency.name or plugin_name(dependency[1])) or plugin_name(dependency)
		pack.load(dependency_name)
	end
end

local function configure_spec(spec, name)
	local opts = type(spec.opts) == "function" and spec.opts() or spec.opts
	if type(spec.config) == "function" then
		spec.config(spec, opts)
	elseif opts ~= nil then
		local ok, mod = pcall(require, spec.main or main_module(name))
		if ok and type(mod.setup) == "function" then
			mod.setup(opts)
		end
	end
end

local function normalize_event(event)
	if event == "VeryLazy" then
		return "DeferredUIEnter"
	end
	return event
end

local function normalize_events(events)
	if type(events) == "string" then
		return normalize_event(events)
	end
	if type(events) ~= "table" then
		return events
	end

	local normalized = vim.deepcopy(events)
	for index, event in ipairs(normalized) do
		normalized[index] = normalize_event(event)
	end
	return normalized
end

local function load_lazy_spec(spec, name)
	local lze = rawget(_G, "lze")
	if not lze or type(lze.load) ~= "function" then
		return false
	end

	local before = spec.before
	local after = spec.after
	spec.name = name
	spec.event = normalize_events(spec.event)
	spec.before = function(plugin)
		if type(spec.init) == "function" then
			spec.init()
		end
		load_dependencies(spec)
		if type(before) == "function" then
			before(plugin)
		end
	end
	spec.after = function(plugin)
		configure_spec(spec, name)
		if type(after) == "function" then
			after(plugin)
		end
	end

	lze.load(spec)
	return true
end

local function set_spec_keys(spec)
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

local function setup_specs(specs)
	for _, spec in ipairs(specs or {}) do
		if spec.enabled ~= false then
			local name = spec.name or plugin_name(spec[1])
			if spec.lazy ~= false and has_lazy_trigger(spec) and load_lazy_spec(spec, name) then
				goto continue
			end

			if type(spec.init) == "function" then
				spec.init()
			end
			load_dependencies(spec)
			require("config.pack").load(name)
			configure_spec(spec, name)
			set_spec_keys(spec)
		end
		::continue::
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
	"plugins.copilot-lsp",
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

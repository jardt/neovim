local M = {}

local plugin_name = vim.g.nix_info_plugin_name
local ok, info = false, nil

if plugin_name then
	ok, info = pcall(require, plugin_name)
end

if not ok or (type(info) ~= "function" and type(info) ~= "table") then
	info = function(default)
		return default
	end
end

M.is_nix = plugin_name ~= nil and ok
M.info = info

function M.get(default, ...)
	return M.info(default, ...)
end

function M.plugin_path(name)
	return M.get(nil, "plugins", name, "path") or M.get(nil, "plugins", name)
end

local function split_key(key)
	if type(key) ~= "string" then
		return { key }
	end

	local parts = {}
	for part in key:gmatch("[^.]+") do
		parts[#parts + 1] = part
	end
	return parts
end

function M.getCatOrDefault(key, default)
	return M.get(default, unpack(split_key(key)))
end

function M.enableForCategory(key, default)
	return M.getCatOrDefault(key, default)
end

function M.lazyAdd(value, default)
	if M.is_nix then
		return default
	end
	return value
end

return M

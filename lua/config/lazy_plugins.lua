local M = {}

local lazy_modules = {
	"plugins.dadbod",
}

function M.setup()
	local lze = rawget(_G, "lze")
	if not lze or type(lze.load) ~= "function" then
		return
	end

	for _, module in ipairs(lazy_modules) do
		local ok, specs = pcall(require, module)
		if ok and specs ~= nil then
			lze.load(specs)
		elseif not ok then
			vim.schedule(function()
				vim.notify("Failed to load lazy specs " .. module .. ": " .. tostring(specs), vim.log.levels.WARN)
			end)
		end
	end
end

return M

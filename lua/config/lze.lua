local M = {}

function M.setup()
	local ok_lze, lze = pcall(require, "lze")
	if not ok_lze then
		return nil
	end

	local ok_extras, lzextras = pcall(require, "lzextras")
	if ok_extras then
		setmetatable(lze, getmetatable(lzextras))
		if type(lze.register_handlers) == "function" then
			local handlers = {}
			for _, handler in ipairs({ "lsp", "merge" }) do
				local ok_handler, loaded = pcall(function()
					return lzextras[handler]
				end)
				if ok_handler and loaded ~= nil then
					table.insert(handlers, loaded)
				end
			end
			if #handlers > 0 then
				lze.register_handlers(handlers)
			end
		end
	end

	return lze
end

return M

local M = {}

function M.setup()
	local ok_lze, lze = pcall(require, "lze")
	if not ok_lze then
		return nil
	end

	local ok_extras, lzextras = pcall(require, "lzextras")
	if ok_extras then
		setmetatable(lze, getmetatable(lzextras))
		vim.g.lze = vim.tbl_extend("force", vim.g.lze or {}, {
			load = lzextras.loaders.with_after,
		})
		if type(lze.register_handlers) == "function" then
			local handlers = {}
			for _, handler in ipairs({ "merge", "lsp" }) do
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

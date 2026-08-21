local M = {}

local function absolute_path(origin, name)
	if name:sub(1, 1) ~= "/" then
		name = vim.fs.joinpath(origin.cwd, name)
	end
	return vim.fs.normalize(name)
end

local function file_path(origin)
	local name = vim.api.nvim_buf_get_name(origin.buf)
	if name == "" or vim.bo[origin.buf].buftype ~= "" then
		return nil, "The current buffer has no file to reference"
	end
	if vim.bo[origin.buf].modified then
		return nil, "Write the current buffer before sending a file reference to Pi"
	end
	return absolute_path(origin, name)
end

local function location(origin, kind)
	local path, err = file_path(origin)
	if not path then
		return nil, err
	end
	if kind == "file" then
		return "@" .. path
	end
	local range = origin.range
	if range then
		if range.start_line == range.end_line then
			return string.format("@%s:%d", path, range.start_line)
		end
		return string.format("@%s:%d-%d", path, range.start_line, range.end_line)
	end
	if kind == "line" then
		return string.format("@%s:%d", path, origin.row)
	end
	return string.format("@%s:%d:%d", path, origin.row, origin.col)
end

local severity = { "ERROR", "WARN", "INFO", "HINT" }

local function diagnostics(origin, all)
	local items = vim.diagnostic.get(all and nil or origin.buf)
	if #items == 0 then
		return "No diagnostics"
	end
	local lines = {}
	for _, item in ipairs(items) do
		local name = vim.api.nvim_buf_get_name(item.bufnr)
		local path = absolute_path(origin, name)
		lines[#lines + 1] = string.format(
			"@%s:%d:%d [%s] %s",
			path,
			item.lnum + 1,
			item.col + 1,
			severity[item.severity] or "DIAGNOSTIC",
			item.message:gsub("\n", " ")
		)
	end
	return table.concat(lines, "\n")
end

local function quickfix(origin)
	local lines = {}
	for _, item in ipairs(vim.fn.getqflist()) do
		local name = item.filename
		if (not name or name == "") and item.bufnr and item.bufnr > 0 then
			name = vim.api.nvim_buf_get_name(item.bufnr)
		end
		local path = name and absolute_path(origin, name) or "[unknown]"
		lines[#lines + 1] =
			string.format("@%s:%d:%d %s", path, item.lnum or 1, item.col or 1, (item.text or ""):gsub("\n", " "))
	end
	return #lines > 0 and table.concat(lines, "\n") or "Quickfix list is empty"
end

function M.origin()
	local win = vim.api.nvim_get_current_win()
	local cursor = vim.api.nvim_win_get_cursor(win)
	local mode = vim.api.nvim_get_mode().mode
	local origin = {
		win = win,
		buf = vim.api.nvim_get_current_buf(),
		mode = mode,
		cwd = vim.fs.normalize(vim.fn.getcwd(0)),
		row = cursor[1],
		col = cursor[2] + 1,
	}
	if mode:match("^[vV\22]") then
		local first = vim.fn.getpos("v")[2]
		local last = cursor[1]
		origin.range = { start_line = math.min(first, last), end_line = math.max(first, last) }
	end
	return origin
end

function M.render(text, origin)
	local replacements = {
		file = function()
			return location(origin, "file")
		end,
		this = function()
			return location(origin, origin.range and "selection" or "position")
		end,
		selection = function()
			return location(origin, "selection")
		end,
		line = function()
			return location(origin, "line")
		end,
		position = function()
			return location(origin, "position")
		end,
		diagnostics = function()
			return diagnostics(origin, false)
		end,
		diagnostics_all = function()
			return diagnostics(origin, true)
		end,
		quickfix = function()
			return quickfix(origin)
		end,
	}
	local err
	local rendered = text:gsub("{([%w_]+)}", function(token)
		local replacement = replacements[token]
		if not replacement then
			return "{" .. token .. "}"
		end
		local value, message = replacement()
		if not value then
			err = message
		end
		return value or ""
	end)
	return err and nil or rendered, err
end

return M

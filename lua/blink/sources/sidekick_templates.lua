local kinds = require("blink.cmp.types").CompletionItemKind

local source = {}

local templates = {
	{ token = "{file}", detail = "Current file" },
	{ token = "{this}", detail = "Current thing / selection context" },
	{ token = "{selection}", detail = "Visual selection" },
	{ token = "{line}", detail = "Current line" },
	{ token = "{position}", detail = "Current cursor position" },
	{ token = "{buffers}", detail = "Open buffers" },
	{ token = "{quickfix}", detail = "Quickfix entries" },
	{ token = "{diagnostics}", detail = "Diagnostics for current file" },
	{ token = "{diagnostics_all}", detail = "Diagnostics for all files" },
	{ token = "{function}", detail = "Current function" },
	{ token = "{class}", detail = "Current class" },
}

function source.new(opts)
	local self = setmetatable({}, { __index = source })
	self.opts = opts or {}
	return self
end

function source:enabled()
	return vim.bo.filetype == "snacks_input"
end

function source:get_trigger_characters()
	return { "{" }
end

function source:get_completions(_, callback)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local before = line:sub(1, col)
	local prefix = before:match("{[%w_]*$")

	if not prefix then
		callback({ items = {}, is_incomplete_forward = false, is_incomplete_backward = false })
		return function() end
	end

	local needle = prefix:sub(2):lower()
	local start_col = col - #prefix
	local items = {}

	for index, entry in ipairs(templates) do
		local name = entry.token:sub(2, -2)
		if needle == "" or name:lower():find("^" .. vim.pesc(needle)) then
			items[#items + 1] = {
				label = entry.token,
				kind = kinds.Text,
				detail = entry.detail,
				sortText = string.format("%03d", index),
				filterText = entry.token,
				insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
				textEdit = {
					newText = entry.token,
					range = {
						start = { line = row - 1, character = start_col },
						["end"] = { line = row - 1, character = col },
					},
				},
				documentation = {
					kind = "markdown",
					value = string.format("`%s`\n\n%s", entry.token, entry.detail),
				},
			}
		end
	end

	callback({
		items = items,
		is_incomplete_forward = false,
		is_incomplete_backward = false,
	})

	return function() end
end

return source

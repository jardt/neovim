---@type vim.lsp.Config
return {
	cmd = { "qmlls", "-E" },
	filetypes = { "qml" },
	single_file_support = true,
	root_markers = { ".git" },
}

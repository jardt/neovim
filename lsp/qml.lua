---@type vim.lsp.Config
return {
	cmd = { "qmlls", "-E" },
	filetypes = { "qml", "qmljs" },
	single_file_support = true,
	root_markers = { ".git" },
}

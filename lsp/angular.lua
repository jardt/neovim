---@type vim.lsp.Config
return {
	cmd = {
		"ngserver",
		"--stdio",
		"--tsProbeLocations",
		"../..,?/node_modules",
		"--ngProbeLocations",
		"../../@angular/language-server/node_modules,?/node_modules/@angular/language-server/node_modules",
		"--angularCoreVersion",
		"",
	},
	filetypes = { "typescript", "html", "htmlangular" },
	root_markers = { "angular.json", "nx.json" },
}

---@type vim.lsp.Config
return {
	filetypes = { "yaml" },
	cmd = { "yaml-language-server", "--stdio" },
	settings = {
		yaml = {
			keyOrdering = false,
			format = {
				enable = true,
			},
			validate = true,
			schemaStore = {
				-- You must disable built-in schemaStore support if you want to use
				-- this plugin and its advanced options like `ignore`.
				enable = false,
				-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
				url = "",
			},
			schemas = require("schemastore").yaml.schemas({
				-- extra = {
				-- 	{
				-- 		description = "k8s jsonschema",
				-- 		fileMatch = "*.yml",
				-- 		name = "k8s",
				-- 		url = "https://kubernetesjsonschema.dev/v1.14.0/deployment-apps-v1.json",
				-- 	},
				-- },
			}),
		},
	},
}

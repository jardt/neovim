local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument = capabilities.textDocument or {}
capabilities.textDocument.completion = capabilities.textDocument.completion or {}
capabilities.textDocument.completion.completionItem = capabilities.textDocument.completion.completionItem or {}
capabilities.textDocument.completion.completionItem.insertReplaceSupport = false

---@type vim.lsp.Config
return {
	cmd = { "vtsls", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
	root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
	capabilities = capabilities,

	settings = {
		complete_function_calls = true,
		vtsls = {
			enableMoveToFileCodeAction = true,
			autoUseWorkspaceTsdk = true,
			experimental = {
				maxInlayHintLength = 30,
				completion = {
					enableServerSideFuzzyMatch = true,
				},
			},
		},
		typescript = {
			tsserver = {
				maxTsServerMemory = 4096,
			},
			updateImportsOnFileMove = { enabled = "always" },
			referencesCodeLens = { enabled = true },
			implementationsCodeLens = { enabled = true },
			suggest = {
				autoImports = true,
				completeFunctionCalls = true,
			},
			inlayHints = {
				enumMemberValues = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				variableTypes = { enabled = false },
			},
		},
		javascript = {
			implementationsCodeLens = { enabled = true },
			suggest = {
				autoImports = true,
			},
		},
	},
}

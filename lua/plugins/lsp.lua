return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				opts = {
					ensure_installed = {
						"ansible-lint",
						"ansiblels",
						"astro",
						"bashls",
						"clangd",
						"codelldb",
						"csharpier",
						"css-variables-language-server",
						"cssls",
						"delve",
						"dockerls",
						"eslint_d",
						"fixjson",
						"gofumpt",
						"goimports",
						"gomodifytags",
						"gopls",
						"gopls",
						"hadolint",
						"html",
						"impl",
						"jdtls",
						"jsonls",
						"kotlin_language_server",
						"ktlint",
						"lua_ls",
						"luacheck",
						"markdownlint",
						"marksman",
						"omnisharp",
						"prettier",
						"prettierd",
						"rust_analyzer",
						"solhint",
						"solidity_ls_nomicfoundation",
						"sqlfluff",
						"sqruff",
						"stylua",
						"svelte",
						"tailwindcss",
						"taplo",
						"typescript-language-server",
						"vtsls",
						"yamlfmt",
						"yamllint",
						"yamlls",
						"zls",
					},
				},
			},
			{ "b0o/schemastore.nvim" },
			{
				"williamboman/mason-lspconfig.nvim",
				config = function(_, _opts)
					require("mason").setup()
					require("mason-lspconfig").setup()
				end,
				dependencies = {
					"williamboman/mason.nvim",
				},
			},
		},
		opts = function()
			---@class PluginLspOpts
			local ret = {
				keys = {
					{ "K", mode = { "n" }, vim.lsp.buf.hover, desc = "Hover lsp" },
					{ "gD", mode = { "n" }, vim.lsp.buf.declaration(), desc = "Decleration lsp" },
					{ "L", mode = { "n" }, vim.lsp.buf.hover, desc = "Hover lsp" },
					--vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					--vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				},
				inlay_hints = {
					enabled = true,
					exclude = {}, -- filetypes for which you don't want to enable inlay hints
				},
				capabilities = {
					workspace = {
						fileOperations = {
							didRename = true,
							willRename = true,
						},
					},
				},
				-- LSP Server Settings
				---@type lspconfig.options
				servers = {
					bashls = {},
					marksman = {},
					jsonls = {
						settings = {
							json = {
								schemas = require("schemastore").json.schemas(),
								validate = { enable = true },
							},
						},
					},
					yamlls = {
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
					},
					taplo = {},
					html = { "svelte", "html", "typescriptreact", "javascriptreact " },
					cssls = {
						filetypes = { "svelte", "css", "less", "sass", "typescriptreact", "javascriptreact " },
					},
					tailwindcss = {},
					lua_ls = {
						settings = {
							Lua = {
								diagnostics = { globals = { "vim" } },
								workspace = {
									checkThirdParty = false,
								},
								codeLens = {
									enable = true,
								},
								completion = {
									callSnippet = "Replace",
								},
								doc = {
									privateName = { "^_" },
								},
								hint = {
									enable = true,
									setType = false,
									paramType = true,
									paramName = "Disable",
									semicolon = "Disable",
									arrayIndex = "Disable",
								},
							},
						},
					},
					rust_analyzer = {
						enabled = false,
					},
					gopls = {
						filetypes = { "go", "gomod", "gowork", "gosum" },
						root_markers = { "go.work", "go.mod", ".git" },
						settings = {
							gopls = {
								gofumpt = true,
								codelenses = {
									gc_details = false,
									generate = true,
									regenerate_cgo = true,
									run_govulncheck = true,
									test = true,
									tidy = true,
									upgrade_dependency = true,
									vendor = true,
								},
								hints = {
									assignVariableTypes = true,
									compositeLiteralFields = true,
									compositeLiteralTypes = true,
									constantValues = true,
									functionTypeParameters = true,
									parameterNames = true,
									rangeVariableTypes = true,
								},
								analyses = {
									nilness = true,
									unusedparams = true,
									unusedwrite = true,
									useany = true,
								},
								usePlaceholders = true,
								completeUnimported = true,
								staticcheck = true,
								directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
								semanticTokens = true,
							},
						},
					},
					solidity_ls_nomicfoundation = {},
					vtsls = {
						filetypes = {
							"javascript",
							"javascriptreact",
							"javascript.jsx",
							"typescript",
							"typescriptreact",
							"typescript.tsx",
						},
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
								updateImportsOnFileMove = { enabled = "always" },
								suggest = {
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
						},
					},
					svelte = {
						workspace = {
							didChangeWatchedFiles = vim.fn.has("nvim-0.10") == 0 and { dynamicRegistration = true },
						},
					},
					clangd = {},
					jdtls = {},
					kotlin_language_server = {},
					css_variables = {
						filetypes = { "svelte", "css", "less", "sass", "typescriptreact", "javascriptreact " },
					},
					dockerls = {},
					ansiblels = {
						filetypes = { "yaml.ansible" },
					},
					nixd = {
						settings = {
							nixd = {
								nixpkgs = {
									expr = "import <nixpkgs> { }",
								},
								formatting = {
									command = { "nixfmt" },
								},
							},
						},
					},
				},
				setup = {},
			}
			return ret
		end,
		config = function(_, opts)
			-- add completion to servers
			local lspconfig = require("lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())

			for server, server_opts in pairs(opts.servers) do
				server_opts.capabilities =
					vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})
				if server_opts.enabled ~= false then
					lspconfig[server].setup(server_opts)
				end
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				desc = "LSP actions",
				callback = function(event)
					local opts = { buffer = event.buf }
					-- these will be buffer-local keybindings
					-- because they only work if you have an active language server
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gd", "<cmd>FzfLua lsp_definitions jump1 ignore_current_line=true<cr>", opts)
					vim.keymap.set("n", "gr", "<cmd>FzfLua lsp_references jump1 ignore_current_line=true<cr>", opts)
					vim.keymap.set(
						"n",
						"gI",
						"<cmd>FzfLua lsp_implementations jump1 ignore_current_line=true<cr>",
						opts
					)
					vim.keymap.set("n", "gt", "<cmd>FzfLua lsp_typedefs jump1 ignore_current_line=true<cr>", opts)
					vim.keymap.set("n", "gh", vim.lsp.buf.signature_help, opts)
					vim.keymap.set(
						"n",
						"<space>Wa",
						vim.lsp.buf.add_workspace_folder,
						{ desc = "add workspace folder", buffer = event.buf }
					)
					vim.keymap.set(
						"n",
						"<space>Wr",
						vim.lsp.buf.remove_workspace_folder,
						{ desc = "remove workspace folder", buffer = event.buf }
					)
					vim.keymap.set("n", "<space>ca", function()
						require("fzf-lua").lsp_code_actions({
							winopts = {
								relative = "cursor",
								width = 0.6,
								height = 0.6,
								row = 1,
								preview = { vertical = "up:70%" },
							},
						})
					end, opts)
					vim.keymap.set("n", "<space>Wl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, { desc = "List workspace folder", buffer = event.buf })
					vim.keymap.set("n", "<leader>i", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ 0 }), { 0 })
					end, { desc = "toggle inlay hints" })
				end,
			})
		end,
	},
	{
		"chrisgrieser/nvim-lsp-endhints",
		event = "LspAttach",
		opts = {}, -- required, even if empty
	},
}

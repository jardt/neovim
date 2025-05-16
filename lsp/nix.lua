---@type vim.lsp.Config
return {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_markers = { "flake-lock" },
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
}

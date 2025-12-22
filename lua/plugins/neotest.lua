return {
	{
		"nvim-neotest/neotest",
		enabled = require("nixCatsUtils").enableForCategory("debugtest", false),
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			{
				"marilari88/neotest-vitest",
				enabled = require("nixCatsUtils").enableForCategory("langs.web", false),
			},
			-- "llllvvuu/neotest-foundry",
			{
				"fredrikaverpil/neotest-golang",
				enabled = require("nixCatsUtils").enableForCategory("langs.go", false),
				dependencies = {
					"leoluz/nvim-dap-go",
				},
			},
			{
				"nsidorenco/neotest-vstest",
				enabled = require("nixCatsUtils").enableForCategory("langs.dotnet", false),
			},
		},
		lazy = true,
		config = function()
			local setup = {
				adapters = {
					-- require("neotest-foundry"),
				},
			}
			if require("nixCatsUtils").getCatOrDefault("langs.web", false) then
				table.insert(setup.adapters, require("neotest-vitest"))
			end
			if require("nixCatsUtils").getCatOrDefault("langs.dotnet", false) then
				table.insert(setup.adapters, require("neotest-vstest"))
			end
			if require("nixCatsUtils").getCatOrDefault("langs.rust", false) then
				table.insert(setup.adapters, require("rustaceanvim.neotest"))
			end
			if require("nixCatsUtils").getCatOrDefault("langs.rust", false) then
				table.insert(setup.adapters, require("rustaceanvim.neotest"))
			end

			if require("nixCatsUtils").getCatOrDefault("langs.rust", false) then
				setup.adapters["neotest-golang"] = {
					-- Here we can set options for neotest-golang, e.g.
					-- go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
					dap_go_enabled = true, -- requires leoluz/nvim-dap-go
				}
			end
			require("neotest").setup(setup)
		end,
		keys = {
			{ "<leader>t", "", desc = "+test" },
			{
				"<leader>tt",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "Run File (Neotest)",
			},
			{
				"<leader>tT",
				function()
					require("neotest").run.run(vim.uv.cwd())
				end,
				desc = "Run All Test Files (Neotest)",
			},
			{
				"<leader>tr",
				function()
					require("neotest").run.run()
				end,
				desc = "Run Nearest (Neotest)",
			},
			{
				"<leader>tl",
				function()
					require("neotest").run.run_last()
				end,
				desc = "Run Last (Neotest)",
			},
			{
				"<leader>ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "Toggle Summary (Neotest)",
			},
			{
				"<leader>to",
				function()
					require("neotest").output.open({ enter = true, auto_close = true })
				end,
				desc = "Show Output (Neotest)",
			},
			{
				"<leader>tO",
				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "Toggle Output Panel (Neotest)",
			},
			{
				"<leader>tS",
				function()
					require("neotest").run.stop()
				end,
				desc = "Stop (Neotest)",
			},
			{
				"<leader>tw",
				function()
					require("neotest").watch.toggle(vim.fn.expand("%"))
				end,
				desc = "Toggle Watch (Neotest)",
			},
		},
	},
}

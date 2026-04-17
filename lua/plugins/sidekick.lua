return {
	{
		"folke/sidekick.nvim",
		name = "sidekick",
		enabled = require("nixCatsUtils").enableForCategory("ai", false),
		dependencies = {
			{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
		},
		config = function()
			require("sidekick").setup({
				nes = { enabled = false },
				cli = {
					mux = {
						backend = "tmux",
						enabled = true,
						create = "split", ---@type "terminal"|"window"|"split"
					},
				},
			})

			vim.o.autoread = true

			vim.keymap.set({ "n", "x" }, "<leader>e", function()
				Snacks.input({
					prompt = "Ask pi: ",
				}, function(input)
					if not input or input == "" then
						return
					end

					require("sidekick.cli").send({
						msg = input,
						submit = true,
						filter = { name = "pi" },
						focus = true,
					})
				end)
			end, { desc = "Ask pi with templates" })

			vim.keymap.set({ "n", "x" }, "<C-f>", function()
				require("sidekick.cli").select({ focus = true })
			end, { desc = "Select Sidekick CLI…" })

			vim.keymap.set({ "n", "t" }, "<C-e>", function()
				require("sidekick.cli").toggle()
			end, { desc = "Toggle Sidekick" })

			vim.keymap.set({ "n", "x" }, "go", function()
				require("sidekick.cli").send({ msg = "{this}" })
			end, { desc = "Send range to Sidekick" })

			vim.keymap.set("n", "goo", function()
				require("sidekick.cli").send({ msg = "{file}" })
			end, { desc = "Send file to Sidekick" })

			vim.keymap.set("n", "<S-C-u>", function()
				require("sidekick.cli").focus()
			end, { desc = "Focus Sidekick" })

			vim.keymap.set("n", "<S-C-d>", function()
				require("sidekick.cli").close()
			end, { desc = "Detach Sidekick session" })
		end,
	},
}

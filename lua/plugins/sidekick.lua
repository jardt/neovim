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

			local Context = require("sidekick.cli.context")

			local function close_pi_prompt(win, origin)
				if vim.api.nvim_get_current_win() == win.win then
					vim.cmd.stopinsert()
				end
				win:close()
				if origin and origin.mode:sub(1, 1) == "i" and vim.api.nvim_win_is_valid(origin.win) then
					vim.api.nvim_set_current_win(origin.win)
					vim.schedule(function()
						if vim.api.nvim_win_is_valid(origin.win) then
							vim.cmd.startinsert()
						end
					end)
				end
			end

			local function render_origin_message(msg, origin)
				local context = Context.get()
				context.ctx = {
					win = origin.win,
					buf = origin.buf,
					cwd = origin.cwd,
					row = origin.row,
					col = origin.col,
					range = origin.range,
				}
				context.context = {}
				return context:render({ msg = msg })
			end

			local function send_pi_prompt(win, origin, submit)
				local lines = vim.api.nvim_buf_get_lines(win.buf, 0, -1, false)
				local msg = table.concat(lines, "\n"):gsub("\n+$", "")
				if msg:match("^%s*$") then
					close_pi_prompt(win, origin)
					return
				end

				local rendered, text = render_origin_message(msg, origin)
				if not rendered or not text then
					vim.notify("Nothing to send", vim.log.levels.WARN)
					close_pi_prompt(win, origin)
					return
				end

				close_pi_prompt(win, origin)
				if vim.api.nvim_win_is_valid(origin.win) then
					vim.api.nvim_set_current_win(origin.win)
				end

				require("sidekick.cli").send({
					text = text,
					submit = submit,
					filter = { name = "pi" },
					focus = true,
				})
			end

			local function open_pi_prompt()
				local origin = {
					win = vim.api.nvim_get_current_win(),
					buf = vim.api.nvim_get_current_buf(),
					mode = vim.api.nvim_get_mode().mode,
					cwd = vim.fs.normalize(vim.fn.getcwd(0)),
				}
				local cursor = vim.api.nvim_win_get_cursor(origin.win)
				origin.row = cursor[1]
				origin.col = cursor[2] + 1
				if origin.mode:match("^[vV\\22]") then
					origin.range = Context.selection(origin.buf)
				end
				local win = Snacks.win({
					position = "float",
					relative = "editor",
					enter = true,
					border = "rounded",
					title = " Ask pi ",
					title_pos = "center",
					footer = "[Enter] send+submit   [Ctrl-Enter] send",
					footer_pos = "right",
					backdrop = 60,
					width = 0.55,
					height = 0.22,
					min_width = 60,
					max_width = 100,
					min_height = 8,
					max_height = 14,
					bo = {
						filetype = "pi_prompt",
						buftype = "",
						swapfile = false,
					},
					b = {
						completion = true,
					},
					wo = {
						wrap = true,
						linebreak = true,
						spell = false,
					},
					text = { "" },
					keys = {
						q = {
							"q",
							function(self)
								close_pi_prompt(self, origin)
							end,
							mode = "n",
							desc = "Close",
						},
						esc = {
							"<esc>",
							function(self)
								close_pi_prompt(self, origin)
							end,
							mode = { "n", "i" },
							desc = "Close",
						},
						submit = {
							"<cr>",
							function(self)
								send_pi_prompt(self, origin, true)
							end,
							mode = "n",
							desc = "Send and submit",
						},
						submit_i = {
							"<cr>",
							function(self)
								send_pi_prompt(self, origin, true)
							end,
							mode = "i",
							desc = "Send and submit",
						},
						send = {
							"<c-cr>",
							function(self)
								send_pi_prompt(self, origin, false)
							end,
							mode = { "n", "i" },
							desc = "Send without submit",
						},
					},
					on_win = function()
						vim.schedule(function()
							if vim.bo.filetype == "pi_prompt" then
								vim.cmd.startinsert()
							end
						end)
					end,
				})
				return win
			end

			vim.keymap.set({ "n", "x" }, "<leader>e", open_pi_prompt, { desc = "Ask pi with templates" })

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

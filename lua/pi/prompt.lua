local M = {}

local function close(win, origin)
	if vim.api.nvim_get_current_win() == win.win then
		vim.cmd.stopinsert()
	end
	win:close()
	if origin.mode:sub(1, 1) == "i" and vim.api.nvim_win_is_valid(origin.win) then
		vim.api.nvim_set_current_win(origin.win)
		vim.schedule(function()
			if vim.api.nvim_win_is_valid(origin.win) then
				vim.cmd.startinsert()
			end
		end)
	end
end

function M.open(initial)
	local Context = require("pi.context")
	local origin = Context.origin()
	local function finish(win, submit)
		local text = table.concat(vim.api.nvim_buf_get_lines(win.buf, 0, -1, false), "\n"):gsub("\n+$", "")
		if text:match("^%s*$") then
			close(win, origin)
			return
		end
		local rendered, err = Context.render(text, origin)
		if not rendered then
			vim.notify(err, vim.log.levels.WARN, { title = "Pi" })
			return
		end
		close(win, origin)
		require("pi.herdr").send(rendered, submit)
	end
	local win = Snacks.win({
		position = "float",
		relative = "editor",
		enter = true,
		border = "rounded",
		title = " Ask Pi ",
		title_pos = "center",
		footer = "[Enter] stage   [Ctrl-Enter] submit",
		footer_pos = "right",
		backdrop = 60,
		width = 0.55,
		height = 0.22,
		min_width = 60,
		max_width = 100,
		min_height = 8,
		max_height = 14,
		bo = { filetype = "pi_prompt", buftype = "", swapfile = false },
		b = { completion = true },
		wo = { wrap = true, linebreak = true, spell = false },
		text = { initial or "" },
		keys = {
			q = {
				"q",
				function(self)
					close(self, origin)
				end,
				mode = "n",
				desc = "Close",
			},
			esc = {
				"<esc>",
				function(self)
					close(self, origin)
				end,
				mode = { "n", "i" },
				desc = "Close",
			},
			stage = {
				"<cr>",
				function(self)
					finish(self, false)
				end,
				mode = { "n", "i" },
				desc = "Stage in Pi",
			},
			submit = {
				"<c-cr>",
				function(self)
					finish(self, true)
				end,
				mode = { "n", "i" },
				desc = "Submit to Pi",
			},
		},
			on_win = function()
				local prompt_win = vim.api.nvim_get_current_win()
				local prompt_buf = vim.api.nvim_get_current_buf()
				vim.schedule(function()
					if vim.api.nvim_win_is_valid(prompt_win) and vim.api.nvim_buf_is_valid(prompt_buf) then
						local line_count = vim.api.nvim_buf_line_count(prompt_buf)
						local line = vim.api.nvim_buf_get_lines(prompt_buf, line_count - 1, line_count, false)[1] or ""
						vim.api.nvim_win_set_cursor(prompt_win, { line_count, #line })
						vim.api.nvim_set_current_win(prompt_win)
						vim.cmd.startinsert({ bang = true })
					end
				end)
		end,
	})
	return win
end

return M

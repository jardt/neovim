local M = {}

local directions = {
	left = { wincmd = "h", tmux = "Left" },
	down = { wincmd = "j", tmux = "Down" },
	up = { wincmd = "k", tmux = "Up" },
	right = { wincmd = "l", tmux = "Right" },
}

function M.navigate(direction)
	local spec = directions[direction]
	if not spec then
		return
	end

	local previous_win = vim.api.nvim_get_current_win()
	vim.cmd("wincmd " .. spec.wincmd)
	if vim.api.nvim_get_current_win() ~= previous_win then
		return
	end

	if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
		local herdr = vim.env.HERDR_BIN_PATH
		if not herdr or herdr == "" then
			herdr = "herdr"
		end
		vim.fn.jobstart({ herdr, "pane", "focus", "--direction", direction, "--current" }, { detach = true })
		return
	end

	if vim.env.TMUX and vim.env.TMUX ~= "" then
		pcall(vim.cmd, "TmuxNavigate" .. spec.tmux)
	end
end

return M

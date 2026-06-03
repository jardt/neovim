local M = {}

local nix = require("config.nix")

local delta_pr_base_cache = {}

local function trim(value)
	return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function system_lines(cmd, opts)
	local result = vim.system(cmd, opts or {}):wait()
	if result.code ~= 0 then
		return {}
	end
	return vim.split(trim(result.stdout), "\n", { plain = true, trimempty = true })
end

local function system_line(cmd, opts)
	return system_lines(cmd, opts)[1]
end

local function git_root()
	return system_line({ "git", "rev-parse", "--show-toplevel" })
end

local function current_branch(root)
	return system_line({ "git", "branch", "--show-current" }, { cwd = root }) or "HEAD"
end

local function normalize_remote_branch(branch)
	if not branch or branch == "" then
		return nil
	end
	if branch:find("/", 1, true) or branch:find("%.%.%.", 1, true) then
		return branch
	end
	return "origin/" .. branch
end

local function default_base_branch(root)
	local origin_head = system_line({ "git", "symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD" }, { cwd = root })
	return origin_head or "origin/main"
end

local function detect_pr_base(root, refresh)
	local cache_key = root .. ":" .. current_branch(root)
	if not refresh and delta_pr_base_cache[cache_key] then
		return delta_pr_base_cache[cache_key]
	end

	local base
	if vim.fn.executable("gh") == 1 then
		base = system_line({ "gh", "pr", "view", "--json", "baseRefName", "--jq", ".baseRefName" }, { cwd = root })
	end
	base = normalize_remote_branch(base) or default_base_branch(root)
	delta_pr_base_cache[cache_key] = base
	return base
end

local function open_delta_pr(opts)
	local root = git_root()
	if not root then
		vim.notify("DeltaPR must be run inside a git repository", vim.log.levels.WARN)
		return
	end

	local refresh = vim.tbl_contains(opts.fargs, "--refresh")
	local base = opts.fargs[1]
	if base == "--refresh" then
		base = nil
	end
	base = normalize_remote_branch(base) or detect_pr_base(root, refresh)
	local ref = base:find("%.%.%.", 1, false) and base or (base .. "...HEAD")
	vim.notify("Opening Delta PR review against " .. ref, vim.log.levels.INFO)
	vim.cmd("DeltaMenu" .. (opts.bang and "! " or " ") .. vim.fn.fnameescape(ref))
end

local function complete_delta_pr(arg_lead)
	local root = git_root()
	if not root then
		return {}
	end
	local branches = system_lines({ "git", "for-each-ref", "--format=%(refname:short)", "refs/heads", "refs/remotes" }, { cwd = root })
	branches[#branches + 1] = "--refresh"
	return vim.tbl_filter(function(branch)
		return branch:find(arg_lead, 1, true) == 1
	end, branches)
end

function M.setup()
	if not nix.enableForCategory("git", true) then
		return
	end

	local pack = require("config.pack")
	for _, plugin in ipairs({ "gitsigns.nvim", "diffview.nvim", "delta-lua", "delta.lua", "deltaview", "deltaview.nvim" }) do
		pack.load(plugin)
	end

	local delta_ok, delta = pcall(require, "delta")
	if delta_ok and delta.parse then
		local get_diff_data_git = delta.parse.get_diff_data_git
		local get_language_from_filename = delta.parse.get_language_from_filename
		local function has_parser(lang)
			return lang and pcall(vim.treesitter.language.add, lang)
		end
		local function language_from_filename(path)
			local lang = path and path:match("%.nix$") and "nix" or get_language_from_filename(path)
			if has_parser(lang) then
				return lang
			end
		end

		delta.parse.get_language_from_filename = language_from_filename
		delta.parse.get_diff_data_git = function(diff)
			local diff_data_set = get_diff_data_git(diff)
			for _, diff_data in ipairs(diff_data_set or {}) do
				diff_data.language = diff_data.language or language_from_filename(diff_data.new_path or diff_data.old_path)
			end
			return diff_data_set
		end
	end

	local deltaview_ok, deltaview = pcall(require, "deltaview")
	if deltaview_ok then
		deltaview.setup({
			-- deltaview does not support Snacks directly yet; use vim.ui.select,
			-- which Snacks picker owns via `picker.ui_select = true`.
			fzf_picker = "ui_select",
		})
	end

	local ok, gitsigns = pcall(require, "gitsigns")
	if ok then
		gitsigns.setup({
			signs = { add = { text = "│" }, change = { text = "│" }, delete = { text = "_" }, topdelete = { text = "‾" }, changedelete = { text = "~" }, untracked = { text = "┆" } },
			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = false,
			watch_gitdir = { follow_files = true },
			attach_to_untracked = true,
			current_line_blame = true,
			current_line_blame_opts = { virt_text = true, virt_text_pos = "eol", delay = 1000, ignore_whitespace = false, virt_text_priority = 100 },
			current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
			sign_priority = 6,
			update_debounce = 100,
			status_formatter = nil,
			max_file_length = 40000,
			preview_config = { border = "single", style = "minimal", relative = "cursor", row = 0, col = 1 },
		})
	end

	vim.api.nvim_create_user_command("Review", function()
		vim.cmd("DiffviewOpen origin/main...HEAD --imply-local")
	end, { desc = "Open Diffview against origin/main" })
	vim.api.nvim_create_user_command("FileHistory", function()
		vim.cmd("DiffviewFileHistory %")
	end, { desc = "Open Diffview file history for current file" })
	vim.api.nvim_create_user_command("DeltaPR", open_delta_pr, {
		nargs = "*",
		bang = true,
		complete = complete_delta_pr,
		desc = "Review PR files in DeltaView against the detected or provided target branch",
	})
	vim.keymap.set("n", "<Leader>gd", "<cmd>DiffviewFileHistory %<CR>", { desc = "diff file" })
	vim.keymap.set("n", "<Leader>gs", "<cmd>DiffviewOpen<CR>", { desc = "diff status" })
	vim.keymap.set("n", "<Leader>qd", "<cmd>DiffviewClose<CR>", { desc = "close diff view" })
	vim.keymap.set("n", "<leader>gS", "<cmd>DiffviewOpen origin/main...HEAD --imply-local<CR>", { desc = "diff against origin main" })
	vim.keymap.set("n", "<leader>gR", "<cmd>DeltaPR<CR>", { desc = "review PR with DeltaView" })
	vim.cmd([[cabbrev dm DeltaMenu]])
	vim.cmd([[cabbrev dpr DeltaPR]])
	vim.cmd([[cabbrev dv DeltaView]])
end

return M

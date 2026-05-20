local M = {}

function M.setup()
	local ok, ts = pcall(require, "nvim-treesitter")
	if not ok then
		return
	end

	local parsers_loaded = {}
	local parsers_pending = {}
	local parsers_failed = {}
	local ns = vim.api.nvim_create_namespace("treesitter.async")

	local function start(buf, lang)
		local started = pcall(vim.treesitter.start, buf, lang)
		if started then
			vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
		return started
	end

	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			if not require("config.nix").is_nix and type(ts.install) == "function" then
				ts.install({
					"c", "ron", "lua", "vim", "vimdoc", "javascript", "html", "typescript", "tsx", "css",
					"c_sharp", "bash", "go", "gomod", "gowork", "gosum", "comment", "diff", "toml",
					"git_rebase", "jsdoc", "gitcommit", "gitignore", "json", "json5", "jsonc", "markdown",
					"markdown_inline", "astro", "pug", "regex", "rust", "yaml", "solidity", "java", "kotlin",
					"angular", "svelte", "sql", "tmux", "xml", "dockerfile", "csv", "yuck",
				}, { max_jobs = 8 })
			end
		end,
	})

	vim.api.nvim_set_decoration_provider(ns, {
		on_start = vim.schedule_wrap(function()
			if #parsers_pending == 0 then
				return false
			end
			for _, data in ipairs(parsers_pending) do
				if vim.api.nvim_buf_is_valid(data.buf) then
					if start(data.buf, data.lang) then
						parsers_loaded[data.lang] = true
					else
						parsers_failed[data.lang] = true
					end
				end
			end
			parsers_pending = {}
		end),
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true }),
		desc = "Enable treesitter highlighting and indentation (non-blocking)",
		callback = function(event)
			if vim.tbl_contains({ "checkhealth", "lazy", "mason", "snacks_dashboard", "snacks_notif", "snacks_win" }, event.match) then
				return
			end
			local lang = vim.treesitter.language.get_lang(event.match) or event.match
			if parsers_failed[lang] then
				return
			end
			if parsers_loaded[lang] then
				start(event.buf, lang)
			else
				table.insert(parsers_pending, { buf = event.buf, lang = lang })
			end
		end,
	})

	vim.g.no_plugin_maps = true
	local ok_textobjects, textobjects = pcall(require, "nvim-treesitter-textobjects")
	if ok_textobjects and type(textobjects.setup) == "function" then
		textobjects.setup({
			select = { lookahead = true, selection_modes = { ["@parameter.outer"] = "v", ["@function.outer"] = "V" }, include_surrounding_whitespace = false },
			textobjects = { swap = { enable = true, swap_next = { ["<leader><Right>"] = "@parameter.inner" }, swap_previous = { ["<leader><Left>"] = "@parameter.inner" } } },
		})
	end
end

return M

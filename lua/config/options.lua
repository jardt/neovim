vim.opt.number = true
vim.opt.relativenumber = true
vim.g.have_nerd_font = true
-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"
-- Decrease update time
vim.opt.updatetime = 250
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

--- SPLITS
vim.opt.splitbelow = true -- open splits below
vim.opt.splitright = true -- open splits right

vim.opt.inccommand = "split" -- show subsition result in new split window

vim.opt.expandtab = true -- tabs instead of spaces
vim.opt.tabstop = 4 --- 4 spaces for tabs
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.smartindent = true

vim.opt.virtualedit = "block"

vim.opt.wrap = false -- disable linewraps

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true -- use colors from term

vim.opt.scrolloff = 999
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "180"

vim.opt.backspace = "2"
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.autoread = true

vim.g.border_style = "rounded"

vim.opt.clipboard = "unnamedplus" -- use system cliipboard

vim.opt.ignorecase = true --comamnds ignore casing

-- swap and undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.smoothscroll = true

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

---@type vim.diagnostic.Opts
vim.diagnostic.config({
	virtual_lines = {
		-- Only show virtual line diagnostics for the current cursor line
		current_line = true,
	},
	underline = true,
	update_in_insert = false,
	virtual_text = {
		spacing = 4,
		source = "if_many",
	},
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚",
			[vim.diagnostic.severity.WARN] = "󰀪",
			[vim.diagnostic.severity.HINT] = "󰌶",
			[vim.diagnostic.severity.INFO] = "",
		},
	},
})

-- transparent nvim
vim.cmd.highlight({ "Normal", "guibg=NONE", "ctermbg=NONE" })
vim.cmd.highlight({ "NonText", "guibg=NONE", "ctermbg=NONE" })
vim.cmd.highlight({ "SignColumn", "guibg=NONE", "ctermbg=NONE" })
vim.cmd.highlight({ "LineNr", "guibg=NONE", "ctermbg=NONE" })
vim.cmd.highlight({ "LineNrAbove", "guibg=NONE", "ctermbg=NONE" })
vim.cmd.highlight({ "LineNrBelow", "guibg=NONE", "ctermbg=NONE" })

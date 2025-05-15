local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)

vim.fn.setreg("l", "yoconsole.log('" .. esc .. "pA', " .. esc .. "pA);" .. esc)

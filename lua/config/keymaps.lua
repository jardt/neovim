local map = vim.keymap.set

-- Duplicate a line aod comment out the first line
vim.api.nvim_set_keymap("n", "yc", ":norm yygccp<CR>", { noremap = true })
-- change in word
vim.keymap.set("n", "<C-c>", "ciw")
-- move selected lines with shift j and k
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

map("n", "<leader>p", function()
	vim.cmd(':normal "0p')
end, { desc = "Code Action rust" })

map("n", "<leader>w", function()
	vim.cmd(":w")
end, { desc = "write file" })

map("n", "<leader>x", function()
	vim.cmd(":bd")
end, { desc = "buffer close" })

map("n", "<leader>a", function()
	vim.cmd(":b#")
end, { desc = "alernate file" })

map("n", "<leader>v", function()
	vim.cmd(":vs")
end, { desc = "vertical split" })

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
-- quit
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit All" })

-- save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- #### RUST

map("n", "<leader>cr", function()
	vim.cmd.RustLsp("codeAction")
end, { desc = "Code Action rust" })

map("n", "<leader>re", function()
	vim.cmd(":RustLsp renderDiagnostic current")
end, { desc = "rust diagnostic" })

map("n", "<leader>rr", function()
	vim.cmd(":RustLsp relatedDiagnostics")
end, { desc = "rust related diagnostic" })

map("n", "<leader>rE", function()
	vim.cmd(":RustLsp renderDiagnostic cycle")
end, { desc = "rust diagnostic" })

map("n", "<leader>rh", function()
	vim.cmd(":RustLsp explainError current")
end, { desc = "rust explainError" })

map("n", "<leader>rH", function()
	vim.cmd(":RustLsp explainError cycle")
end, { desc = "rust explainError" })

map("n", "<leader>rt", function()
	vim.cmd(":RustLsp testables ")
end, { desc = "rust run tests" })

map("n", "<leader>rD", function()
	vim.cmd(":RustLsp debuggables")
end, { desc = "rust run debug" })

map("n", "<leader>ro", function()
	vim.cmd(":RustLsp openDocs")
end, { desc = "rust open docs" })

vim.cmd([[
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
]])

vim.g.mapleader = " "
vim.g.rust_recommended_style = 0
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("i", "<C-z>", "<C-O>u")
vim.keymap.set("i", "<C-BS>", "<C-w>")
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>i<Right>")

vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("n", "<C-a>", ":so<CR>")

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", ":bnext<CR>")
vim.keymap.set("n", "<C-j>", ":bprev<CR>")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>o", ":normal o<CR>")
vim.keymap.set("n", "<leader>O", ":normal O<CR>")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set({"n", "x", "o"}, "f", "<Plug>(leap-forward-to)")
vim.keymap.set({"n", "x", "o"}, "F", "<Plug>(leap-backward-to)")
